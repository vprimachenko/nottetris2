controls = {}
controls.settings = {}

controls.settings.left = {"key", {"left"}}
controls.settings.right = {"key", {"right"}}
controls.settings.up = {"key", {"up"}}
controls.settings.down = {"key", {"down"}}
controls.settings["return"] = {"key", {"return", "kpenter"}}
controls.settings.escape = {"key", {"escape"}}
controls.settings.rotateleft = {"key", {"y", "z", "w"}}
controls.settings.rotateright = {"key", {"x", "up"}}

-- multiplayer player 1
controls.settings.p1left = {"key", {"a"}}
controls.settings.p1right = {"key", {"d"}}
controls.settings.p1down = {"key", {"s"}}
controls.settings.p1rotateleft = {"key", {"g"}}
controls.settings.p1rotateright = {"key", {"h"}}

--player 2
controls.settings.leftp2 = {"key", {"left"}}
controls.settings.rightp2 = {"key", {"right"}}
controls.settings.downp2 = {"key", {"down"}}
controls.settings.rotateleftp2 = {"key", {"kp1"}}
controls.settings.rotaterightp2 = {"key", {"kp2"}}

function controls.check(t, key)
	if controls.settings[t][1] == "key" then
		for i = 1, #controls.settings[t][2] do
			if key == controls.settings[t][2][i] then
				return true
			end
		end
		return false
	end
end

function controls.isDown(t)
	if controls.settings[t][1] == "key" then
		for i = 1, #controls.settings[t][2] do
			if love.keyboard.isDown(controls.settings[t][2][i]) then
				return true
			end
		end
		return false
	end
end
