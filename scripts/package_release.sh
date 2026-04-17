#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/dist/release}"
APP_NAME="${APP_NAME:-NotTetris2}"
LOVE_VERSION="${LOVE_VERSION:-11.5}"
LOVE_BASE_URL="${LOVE_BASE_URL:-https://github.com/love2d/love/releases/download/${LOVE_VERSION}}"

LOVE_FILE="${DIST_DIR}/${APP_NAME}.love"
WINDOWS_ZIP="${DIST_DIR}/${APP_NAME}-windows-x64.zip"
MACOS_ZIP="${DIST_DIR}/${APP_NAME}-macos.zip"
LINUX_TAR="${DIST_DIR}/${APP_NAME}-linux-x86_64.tar.gz"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$DIST_DIR"
rm -f "$LOVE_FILE" "$WINDOWS_ZIP" "$MACOS_ZIP" "$LINUX_TAR"

download() {
  local url="$1"
  local out="$2"
  curl --fail --location --silent --show-error "$url" --output "$out"
}

create_love() {
  git -C "$ROOT_DIR" archive --format=zip --output "$LOVE_FILE" HEAD
}

build_windows() {
  local zip_name="love-${LOVE_VERSION}-win64.zip"
  local zip_path="${WORK_DIR}/${zip_name}"
  local extract_dir="${WORK_DIR}/windows-extract"
  local app_dir="${WORK_DIR}/${APP_NAME}-windows-x64"
  local runtime_dir

  download "${LOVE_BASE_URL}/${zip_name}" "$zip_path"
  unzip -q "$zip_path" -d "$extract_dir"
  runtime_dir="$(find "$extract_dir" -type f -name love.exe -exec dirname {} \; | head -n 1)"

  if [[ -z "$runtime_dir" ]]; then
    echo "Unable to locate love.exe in ${zip_name}" >&2
    exit 1
  fi

  mkdir -p "$app_dir"
  cp -R "${runtime_dir}/." "$app_dir/"

  cat "${app_dir}/love.exe" "$LOVE_FILE" > "${app_dir}/${APP_NAME}.exe"
  rm -f "${app_dir}/love.exe" "${app_dir}/lovec.exe"

  (
    cd "$WORK_DIR"
    zip -q -r "$WINDOWS_ZIP" "${APP_NAME}-windows-x64"
  )
}

build_macos() {
  local zip_name="love-${LOVE_VERSION}-macos.zip"
  local zip_path="${WORK_DIR}/${zip_name}"
  local extract_dir="${WORK_DIR}/macos-extract"
  local app_dir="${WORK_DIR}/${APP_NAME}.app"
  local plist="${app_dir}/Contents/Info.plist"
  local source_app

  download "${LOVE_BASE_URL}/${zip_name}" "$zip_path"
  unzip -q "$zip_path" -d "$extract_dir"
  source_app="$(find "$extract_dir" -type d -name love.app | head -n 1)"

  if [[ -z "$source_app" ]]; then
    echo "Unable to locate love.app in ${zip_name}" >&2
    exit 1
  fi

  mv "$source_app" "$app_dir"
  cp "$LOVE_FILE" "${app_dir}/Contents/Resources/game.love"

  perl -0pi -e 's/<string>org\.love2d\.love<\/string>/<string>io.github.vprimachenko.nottetris2<\/string>/g' "$plist"
  perl -0pi -e 's/<string>LÖVE<\/string>/<string>NotTetris2<\/string>/' "$plist"
  perl -0pi -e 's/<string>LOVE<\/string>/<string>NotTetris2<\/string>/' "$plist"

  (
    cd "$WORK_DIR"
    zip -q -y -r "$MACOS_ZIP" "${APP_NAME}.app"
  )
}

build_linux() {
  local appimage_name="love-${LOVE_VERSION}-x86_64.AppImage"
  local appimage_path="${WORK_DIR}/${appimage_name}"
  local bundle_dir="${WORK_DIR}/${APP_NAME}-linux-x86_64"
  local launcher="${bundle_dir}/run-${APP_NAME}.sh"

  download "${LOVE_BASE_URL}/${appimage_name}" "$appimage_path"
  mkdir -p "$bundle_dir"
  cp "$LOVE_FILE" "${bundle_dir}/${APP_NAME}.love"
  mv "$appimage_path" "${bundle_dir}/${APP_NAME}.AppImage"
  chmod +x "${bundle_dir}/${APP_NAME}.AppImage"

  cat > "$launcher" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "${HERE}/NotTetris2.AppImage" "${HERE}/NotTetris2.love"
EOF
  chmod +x "$launcher"

  tar -C "$WORK_DIR" -czf "$LINUX_TAR" "${APP_NAME}-linux-x86_64"
}

create_love
build_windows
build_macos
build_linux

printf '%s\n' "$LOVE_FILE" "$WINDOWS_ZIP" "$MACOS_ZIP" "$LINUX_TAR"
