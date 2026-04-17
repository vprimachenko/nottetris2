function gameBmulti_load()
	if musicno < 4 then
		love.audio.stop(music[musicno])
	end
	
	gamestate = "gameBmulti"
	gamestarted = false
	
	beeped = {false, false, false}
	
	--figure out the multiplayer scale
	mpscale = scale
	while 274*mpscale > desktopwidth do
		mpscale = mpscale - 1
	end
	physicsmpscale = mpscale/4
	
	mpfullscreenoffsetX = (desktopwidth-274*mpscale)/2
	mpfullscreenoffsetY = (desktopheight-144*mpscale)/2
	
	if not fullscreen then
		applyWindowMode(274 * mpscale, 144 * mpscale, fullscreen, 16)
	end
	
	--nextpieces
	nextpieceimgmp = {}
	for i = 1, 7 do
		nextpieceimgmp[i] = newPaddedImage( "graphics/pieces/"..i..".png", mpscale )
	end
	
	difficulty_speed = 100

	p1fail = false
	p2fail = false
	
	p1color = {255, 50, 50}
	p2color = {50, 255, 50}
	
	--p1color = {116, 92, 73}
	--p2color = {209, 174, 145}
	
	scorescorep1 = 0
	linesscorep1 = 0
	
	scorescorep2 = 0
	linesscorep2 = 0
	
	counterp1 = 0 --first piece is 1
	counterp2 = 0 --first piece is 1
	
	tetrikindp1 = {}
	tetriimagedatap1 = {}
	tetriimagesp1 = {}
	
	tetrikindp2 = {}
	tetriimagedatap2 = {}
	tetriimagesp2 = {}
	
	randomtable = {}
	nextpiecep1 = nil
	nextpiecep2 = nil
	
	nextpiecerot = 0
	
	--PHYSICS--
	meter = 30
	world = love.physics.newWorld(0, 500, true)
	
	
	wallshapesp1 = {}
	wallfixturesp1 = {}
	tetrishapesp1 = {}
	tetrifixturesp1 = {}
	tetribodiesp1 = {}
	
	wallshapesp2 = {}
	wallfixturesp2 = {}
	tetrishapesp2 = {}
	tetrifixturesp2 = {}
	tetribodiesp2 = {}
	--WALLS P1--
	wallbodiesp1 = love.physics.newBody(world, 32, -64, "static")
	
	wallshapesp1[0] = love.physics.newPolygonShape(164, 0, 164,672, 196,672, 196, 0)
	wallfixturesp1[0] = createFixture(wallbodiesp1, wallshapesp1[0], nil, "leftp1")
	wallfixturesp1[0]:setFriction(0.0001)
	
	wallshapesp1[1] = love.physics.newPolygonShape(516,0, 516,672, 548,672, 548,0)
	wallfixturesp1[1] = createFixture(wallbodiesp1, wallshapesp1[1], nil, "rightp1")
	wallfixturesp1[1]:setCategory(2)
	wallfixturesp1[1]:setFriction(0.0001)
	
	wallshapesp1[2] = love.physics.newPolygonShape(196,640, 196,672, 516,672, 516,640)
	wallfixturesp1[2] = createFixture(wallbodiesp1, wallshapesp1[2], nil, "groundp1")
	
	--WALLS P2--
	wallbodiesp2 = love.physics.newBody(world, 32, -64, "static")
	
	wallshapesp2[0] = love.physics.newPolygonShape(484, 0, 484,672, 516,672, 516, 0)
	wallfixturesp2[0] = createFixture(wallbodiesp2, wallshapesp2[0], nil, "leftp2")
	wallfixturesp2[0]:setCategory(3)
	wallfixturesp2[0]:setFriction(0.0001)
	
	wallshapesp2[1] = love.physics.newPolygonShape(836,0, 836,672, 868,672, 868,0)
	wallfixturesp2[1] = createFixture(wallbodiesp2, wallshapesp2[1], nil, "rightp2")
	wallfixturesp2[1]:setFriction(0.0001)
	
	wallshapesp2[2] = love.physics.newPolygonShape(516,640, 516,672, 836,672, 836,640)
	wallfixturesp2[2] = createFixture(wallbodiesp2, wallshapesp2[2], nil, "groundp2")
	-----------	
	world:setCallbacks(collideBmulti)
	-----------
	
	randomtable[1] = math.random(7)
	starttimer = love.timer.getTime()
	--first piece! hooray.
end

function gameBmulti_draw()
	if fullscreen then
		love.graphics.translate(mpfullscreenoffsetX, mpfullscreenoffsetY)
		
		love.graphics.setScissor(mpfullscreenoffsetX, mpfullscreenoffsetY, 274*mpscale, 144*mpscale)
	end

	--background--
	if gamestate ~= "gameBmulti_results" then
		love.graphics.draw(gamebackgroundmulti, 0, 0, 0, mpscale)
	else
		love.graphics.draw(multiresults, 0, 0, 0, mpscale)
	end
	---------------
	if gamestarted == false then
		if newtime - starttimer > 2 then
			love.graphics.draw( number1, 73*mpscale, 48*mpscale, 0, mpscale)
			love.graphics.draw( number1, 153*mpscale, 48*mpscale, 0, mpscale)
		elseif newtime - starttimer > 1 then
			love.graphics.draw( number2, 73*mpscale, 48*mpscale, 0, mpscale)
			love.graphics.draw( number2, 153*mpscale, 48*mpscale, 0, mpscale)
		elseif newtime - starttimer > 0 then
			love.graphics.draw( number3, 73*mpscale, 48*mpscale, 0, mpscale)
			love.graphics.draw( number3, 153*mpscale, 48*mpscale, 0, mpscale)
		end
	end
	--tetrishapes P1--
	
	for i,v in pairs(tetribodiesp1) do
		setColor255(255, 255, 255)
		--set color:
		if gamestate == "failingBmulti" or gamestate == "failedBmulti" then
			timepassed = love.timer.getTime() - colorizetimer
			if v:getY() > 576 - (576*(timepassed/colorizeduration)) then
				setColor255(unpack(p1color))
			end
		end
		
		love.graphics.draw( tetriimagesp1[i], v:getX()*physicsmpscale, v:getY()*physicsmpscale, v:getAngle(), 1, 1, piececenter[tetrikindp1[i]][1]*mpscale, piececenter[tetrikindp1[i]][2]*mpscale)
	end
	
	if p1fail == false and nextpiecep1 then
		--Next piece
		love.graphics.draw(nextpieceimgmp[nextpiecep1], 24*mpscale, 120*mpscale, -nextpiecerot, 1, 1, piececenterpreview[nextpiecep1][1]*mpscale, piececenterpreview[nextpiecep1][2]*mpscale)
	end
	
	----------------
	--tetrishapes P2--	
	for i,v in pairs(tetribodiesp2) do
		setColor255(255, 255, 255)
		--set color:
		if gamestate == "failingBmulti" or gamestate == "failedBmulti" then
			timepassed = love.timer.getTime() - colorizetimer
			if v:getY() > 576 - (576*(timepassed/colorizeduration)) then
				setColor255(unpack(p2color))
			end
		end
		love.graphics.draw( tetriimagesp2[i], v:getX()*physicsmpscale, v:getY()*physicsmpscale, v:getAngle(), 1, 1, piececenter[tetrikindp2[i]][1]*mpscale, piececenter[tetrikindp2[i]][2]*mpscale)
	end
	----------------	
	setColor255(255, 255, 255)
	
	if p2fail == false and nextpiecep2 then
		--Next piece
		love.graphics.draw(nextpieceimgmp[nextpiecep2], 250*mpscale, 120*mpscale, nextpiecerot, 1, 1, piececenterpreview[nextpiecep2][1]*mpscale, piececenterpreview[nextpiecep2][2]*mpscale)
	end
	--SCORES P1---------------------------------------
	
	--"score"--
	offsetX = 0
	
	scorestring = tostring(scorescorep1)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*mpscale
	end
	love.graphics.print( scorescorep1, 36*mpscale + offsetX, 24*mpscale, 0, mpscale)
	
	--"tiles"--
	offsetX = 0
	
	scorestring = tostring(linesscorep1)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*mpscale
	end
	love.graphics.print( linesscorep1, 28*mpscale + offsetX, 80*mpscale, 0, mpscale)
	-----------------------------------------------
	
	--SCORES P2---------------------------------------
	--"score"--
	offsetX = 0
	
	scorestring = tostring(scorescorep2)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*mpscale
	end
	love.graphics.print( scorescorep2, 262*mpscale + offsetX, 24*mpscale, 0, mpscale)
	
	--"tiles"--
	offsetX = 0
	
	scorestring = tostring(linesscorep2)
	for i = 1, scorestring:len() - 1 do
		offsetX = offsetX - 8*mpscale
	end
	love.graphics.print( linesscorep2, 254*mpscale + offsetX, 80*mpscale, 0, mpscale)
	-----------------------------------------------
	
	if gamestate == "gameBmulti_results" then
		--win counter
		if p1wins < 10 then
			love.graphics.print( "0"..p1wins, 111*mpscale, 128*mpscale, 0, mpscale)
		else
			love.graphics.print( p1wins, 111*mpscale, 128*mpscale, 0, mpscale)
		end
		
		if p2wins < 10 then
			love.graphics.print( "0"..p2wins, 193*mpscale, 128*mpscale, 0, mpscale)
		else
			love.graphics.print( p2wins, 193*mpscale, 128*mpscale, 0, mpscale)
		end
		
		if winner == 1 then
			--mario
			if jumpframe == false then
				love.graphics.draw( marioidle, mariobody:getX()*physicsmpscale, mariobody:getY()*physicsmpscale, mariobody:getAngle(), mpscale, mpscale, 12, 13.5)
			else
				love.graphics.draw( mariojump, mariobody:getX()*physicsmpscale, mariobody:getY()*physicsmpscale, mariobody:getAngle(), mpscale, mpscale, 12, 13.5)
			end
			
			--luigi
			if cryframe == false then
				love.graphics.draw( luigicry1, 162*mpscale, 66*mpscale,  0, mpscale, mpscale)
			else
				love.graphics.draw( luigicry2, 162*mpscale, 66*mpscale,  0, mpscale, mpscale)
				love.graphics.print( "mario", 93*mpscale, 20*mpscale, 0, mpscale)
				love.graphics.print( "wins!", 141*mpscale, 20*mpscale, 0, mpscale)
				for i = 1, 5 do
					love.graphics.draw( congratsline, (86+(8*i-1))*mpscale, 28*mpscale, 0, mpscale, mpscale)
					love.graphics.draw( congratsline, (134+(8*i-1))*mpscale, 28*mpscale, 0, mpscale, mpscale)
				end
			end
		elseif winner == 2 then
			--luigi
			if jumpframe == false then
				love.graphics.draw( luigiidle, luigibody:getX()*physicsmpscale, luigibody:getY()*physicsmpscale, luigibody:getAngle(), mpscale, mpscale, 14, 15.5)
			else
				love.graphics.draw( luigijump, luigibody:getX()*physicsmpscale, luigibody:getY()*physicsmpscale, luigibody:getAngle(), mpscale, mpscale, 14, 15.5)
			end
			
			--mario
			if cryframe == false then
				love.graphics.draw( mariocry1, 83*mpscale, 66*mpscale, 0, mpscale, mpscale)
			else
				love.graphics.draw( mariocry2, 83*mpscale, 66*mpscale, 0, mpscale, mpscale)
				love.graphics.print( "luigi", 93*mpscale, 20*mpscale, 0, mpscale)
				love.graphics.print( "wins!", 141*mpscale, 20*mpscale, 0, mpscale)
				for i = 1, 5 do
					love.graphics.draw( congratsline, (86+(8*i-1))*mpscale, 28*mpscale, 0, mpscale, mpscale)
					love.graphics.draw( congratsline, (134+(8*i-1))*mpscale, 28*mpscale, 0, mpscale, mpscale)
				end
			end
		else --draw
			--mario
			love.graphics.draw( marioidle, 84*mpscale, 69*mpscale, 0, mpscale, mpscale)
			if cryframe == false then
				love.graphics.print( "draw", 160*mpscale, 40*mpscale, 0, mpscale)
			end
			
			--luigi
			love.graphics.draw( luigiidle, 162*mpscale, 65*mpscale,  0, mpscale, mpscale)
			if cryframe == false then
				love.graphics.print( "draw", 80*mpscale, 40*mpscale, 0, mpscale)
			end
			
		end
	end
	
	if fullscreen then
		love.graphics.translate(-mpfullscreenoffsetX, -mpfullscreenoffsetY)
		
		love.graphics.setScissor()
	end
end
	
function gameBmulti_update(dt)

	--NEXTPIECE ROTATION (rotating allday erryday)
	nextpiecerot = nextpiecerot + nextpiecerotspeed*dt
	while nextpiecerot > math.pi*2 do
		nextpiecerot = nextpiecerot - math.pi*2
	end

	world:update(dt)
	newtime = love.timer.getTime()
	if gamestarted == false then
		if newtime - starttimer > 3 then
			if musicno < 4 then
				love.audio.play(music[musicno])
			end
			startgame()
			gamestarted = true
		elseif newtime - starttimer > 2 and beeped[3] == false then
			beeped[3] = true
			love.audio.stop(highscorebeep)
			love.audio.play(highscorebeep)
		elseif newtime - starttimer > 1 and beeped[2] == false then
			beeped[2] = true
			love.audio.stop(highscorebeep)
			love.audio.play(highscorebeep)
		elseif newtime - starttimer > 0 and beeped[1] == false then
			beeped[1] = true
			love.audio.stop(highscorebeep)
			love.audio.play(highscorebeep)
		end
		
	elseif gamestate == "gameBmulti" then
		--PLAYER 1--
		if p1fail == false then
			if controls.isDown("p1rotateright") then --clockwise
				if tetribodiesp1[counterp1]:getAngularVelocity() < 3 then
					tetribodiesp1[counterp1]:applyTorque(controltorque)
				end
			end
			if controls.isDown("p1rotateleft") then --counterclockwise
				if tetribodiesp1[counterp1]:getAngularVelocity() > -3 then
					tetribodiesp1[counterp1]:applyTorque(-controltorque)
				end
			end
		   
			if controls.isDown("p1left") then --left
				x, y = tetribodiesp1[counterp1]:getWorldCenter()
				tetribodiesp1[counterp1]:applyForce(-controlforce, 0, x, y)
			end
			if controls.isDown("p1right") then --right
				x, y = tetribodiesp1[counterp1]:getWorldCenter()
				tetribodiesp1[counterp1]:applyForce(controlforce, 0, x, y)
			end
			
			local x, y = tetribodiesp1[counterp1]:getLinearVelocity()
			if controls.isDown("p1down") then --down
				if y > difficulty_speed*5 then
					tetribodiesp1[counterp1]:setLinearVelocity(x, difficulty_speed*5)
				else
					local cx, cy = tetribodiesp1[counterp1]:getWorldCenter()
					tetribodiesp1[counterp1]:applyForce(0, softdropforce, cx, cy)
				end
			else
				if y > difficulty_speed then
					tetribodiesp1[counterp1]:setLinearVelocity(x, y-2000*dt)
				end
			end
		end
		--PLAYER 2--
		if p2fail == false then
			if controls.isDown("rotaterightp2") then --clockwise
				if tetribodiesp2[counterp2]:getAngularVelocity() < 3 then
					tetribodiesp2[counterp2]:applyTorque(controltorque)
				end
			end
			if controls.isDown("rotateleftp2") then --counterclockwise
				if tetribodiesp2[counterp2]:getAngularVelocity() > -3 then
					tetribodiesp2[counterp2]:applyTorque(-controltorque)
				end
			end
		   
			if controls.isDown("leftp2") then --left
				x, y = tetribodiesp2[counterp2]:getWorldCenter()
				tetribodiesp2[counterp2]:applyForce(-controlforce, 0, x, y)
			end
			if controls.isDown("rightp2") then --right
				x, y = tetribodiesp2[counterp2]:getWorldCenter()
				tetribodiesp2[counterp2]:applyForce(controlforce, 0, x, y)
			end
			
			local x, y = tetribodiesp2[counterp2]:getLinearVelocity()
			if controls.isDown("downp2") then --down
				if y > difficulty_speed*5 then
					tetribodiesp2[counterp2]:setLinearVelocity(x, difficulty_speed*5)
				else
					local cx, cy = tetribodiesp2[counterp2]:getWorldCenter()
					tetribodiesp2[counterp2]:applyForce(0, softdropforce, cx, cy)
				end
			else
				if y > difficulty_speed then
					tetribodiesp2[counterp2]:setLinearVelocity(x, y-2000*dt)
				end
			end
		end
	elseif gamestate == "failingBmulti" then
		timepassed = love.timer.getTime() - colorizetimer
		if timepassed > colorizeduration then
			gamestate = "failedBmulti"
			
			wallfixturesp1[2]:destroy()
			clearShapeFixture(wallshapesp1[2])
			wallfixturesp1[2] = nil
			wallshapesp1[2] = nil
			wallfixturesp2[2]:destroy()
			clearShapeFixture(wallshapesp2[2])
			wallfixturesp2[2] = nil
			wallshapesp2[2] = nil
			
			love.audio.stop(gameover2)
			love.audio.play(gameover2)
		end
	elseif gamestate == "failedBmulti" then
		clearcheck = true
		for i,v in pairs(tetribodiesp1) do
			if v:getY() < 162*mpscale then
				clearcheck = false
			end
		end
		
		for i,v in pairs(tetribodiesp2) do
			if v:getY() < 162*mpscale then
				clearcheck = false
			end
		end
		
		if clearcheck then --RESULTS SCREEN INI!--
			gamestate = "gameBmulti_results"
			jumptimer = love.timer.getTime()
			crytimer = love.timer.getTime()
			
			love.audio.play(musicresults)
			
			resultsfloorbody = love.physics.newBody(world, 32, -64, "static")
			resultsfloorshape = love.physics.newPolygonShape(196,448, 196,480, 836,480, 836,448)
			resultsfloorfixture = createFixture(resultsfloorbody, resultsfloorshape, nil, "resultsfloor")
			
			if winner == 1 then
				mariobody = love.physics.newBody(world, 388, 320, "dynamic")
				marioshape = love.physics.newRectangleShape(0, 0, 64, 108)
				mariofixture = createFixture(mariobody, marioshape, density, "mario")
				mariofixture:setMask(3)
				mariobody:setLinearDamping(0.5)
			elseif winner == 2 then
				luigibody = love.physics.newBody(world, 704, 320, "dynamic")
				luigishape = love.physics.newRectangleShape(0, 0, 64, 124)
				luigifixture = createFixture(luigibody, luigishape, density, "luigi")
				luigifixture:setMask(2)
				luigibody:setLinearDamping(0.5)
			end
			
			if winner == 1 then
				mariobody:setY(mariobody:getY()-1)
				x, y = mariobody:getLinearVelocity( )
				mariobody:setLinearVelocity(x, -300)
			elseif winner == 2 then
				luigibody:setY(luigibody:getY()-1)
				x, y = luigibody:getLinearVelocity( )
				luigibody:setLinearVelocity(x, -300)
			end
			jumpframe = true
		end
	elseif gamestate == "gameBmulti_results" then
		jumptimepassed = love.timer.getTime() - jumptimer
		if jumptimepassed > 2 then
			jumptimer = love.timer.getTime()
			jumpframe = true
			if winner == 1 then
				mariobody:setY(mariobody:getY()-1)
				x, y = mariobody:getLinearVelocity( )
				mariobody:setLinearVelocity(x, -300)
			elseif winner == 2 then
				luigibody:setY(luigibody:getY()-1)
				x, y = luigibody:getLinearVelocity( )
				luigibody:setLinearVelocity(x, -300)
			end
		end
		
		crytimepassed = love.timer.getTime() - crytimer
		if crytimepassed > 0.4 then
			cryframe = not cryframe
			crytimer = love.timer.getTime()
		end
		
		if winner == 1 then
			if controls.isDown("p1left") then
				x, y = mariobody:getWorldCenter()
				mariobody:applyForce(-controlforce / 2, 0, x, y-8)
			end
			if controls.isDown("p1right") then
				x, y = mariobody:getWorldCenter()
				mariobody:applyForce(controlforce / 2, 0, x, y-8)
			end
		elseif winner == 2 then
			if controls.isDown("leftp2") then
				x, y = luigibody:getWorldCenter()
				luigibody:applyForce(-controlforce / 2, 0, x, y-8)
			end
			if controls.isDown("rightp2") then
				x, y = luigibody:getWorldCenter()
				luigibody:applyForce(controlforce / 2, 0, x, y-8)
			end
		end
	end
end

function startgame()
	--FIRST "nextpiece" for p1 (Which gets immediately removed, duh)--
	if randomtable[1] == 2 then
		nextpiecep1 = 3
	elseif randomtable[1] == 3 then
		nextpiecep1 = 2
	elseif randomtable[1] == 5 then
		nextpiecep1 = 7
	elseif randomtable[1] == 7 then
		nextpiecep1 = 5
	else
		nextpiecep1 = randomtable[1]
	end
	
	----------------
	--FIRST "nextpiece" for p2 (Which gets immediately removed, duh)--
	nextpiecep2 = randomtable[1]
	
	----------------
	game_addTetriBmultip1()
	game_addTetriBmultip2()
end

function game_addTetriBmultip1()
	counterp1 = counterp1 + 1
	--NEW BLOCK--
	randomblockp1 = nextpiecep1
	createtetriBmultip1(randomblockp1, counterp1, 388, blockstartY)
	tetribodiesp1[counterp1]:setLinearVelocity(0, difficulty_speed)
	
	--RANDOMIZE
	if counterp1 > #randomtable then
		table.insert(randomtable, math.random(7))
	end
	--MIRROR PIECES
	if randomtable[counterp1] == 2 then
		nextpiecep1 = 3
	elseif randomtable[counterp1] == 3 then
		nextpiecep1 = 2
	elseif randomtable[counterp1] == 5 then
		nextpiecep1 = 7
	elseif randomtable[counterp1] == 7 then
		nextpiecep1 = 5
	else
		nextpiecep1 = randomtable[counterp1]
	end
	
end

function game_addTetriBmultip2()
	counterp2 = counterp2 + 1
	--NEW BLOCK--
	randomblockp2 = nextpiecep2
	createtetriBmultip2(randomblockp2, counterp2, 708, blockstartY)
	tetribodiesp2[counterp2]:setLinearVelocity(0, difficulty_speed)
	
	--RANDOMIZE
	if counterp2 > #randomtable then
		table.insert(randomtable, math.random(7))
	end
	nextpiecep2 = randomtable[counterp2]
end

local function createMultiplayerPiece(bodyTable, shapeTable, fixtureTable, imageTable, kindTable, playerTag, maskCategory, piece, uniqueid, x, y)
	imageTable[uniqueid] = newPaddedImage("graphics/pieces/" .. piece .. ".png", mpscale)
	kindTable[uniqueid] = piece
	shapeTable[uniqueid] = {}
	fixtureTable[uniqueid] = {}
	bodyTable[uniqueid] = newBodyWithAngle(world, x, y, blockrot)

	local shapeLayouts = {
		[1] = {{-48, 0}, {-16, 0}, {16, 0}, {48, 0}},
		[2] = {{-32, -16}, {0, -16}, {32, -16}, {32, 16}},
		[3] = {{-32, -16}, {0, -16}, {32, -16}, {-32, 16}},
		[4] = {{-16, -16}, {-16, 16}, {16, 16}, {16, -16}},
		[5] = {{-32, 16}, {0, -16}, {32, -16}, {0, 16}},
		[6] = {{-32, -16}, {0, -16}, {32, -16}, {0, 16}},
		[7] = {{0, 16}, {0, -16}, {32, 16}, {-32, -16}}
	}

	for index, offset in ipairs(shapeLayouts[piece]) do
		shapeTable[uniqueid][index] = love.physics.newRectangleShape(offset[1], offset[2], 32, 32)
		fixtureTable[uniqueid][index] = createFixture(bodyTable[uniqueid], shapeTable[uniqueid][index], density, playerTag .. uniqueid)
		fixtureTable[uniqueid][index]:setMask(maskCategory)
	end

	bodyTable[uniqueid]:setLinearDamping(0.5)
	bodyTable[uniqueid]:setBullet(true)
end

function createtetriBmultip1(i, uniqueid, x, y)
	createMultiplayerPiece(tetribodiesp1, tetrishapesp1, tetrifixturesp1, tetriimagesp1, tetrikindp1, "p1-", 3, i, uniqueid, x, y)
end

function createtetriBmultip2(i, uniqueid, x, y)
	createMultiplayerPiece(tetribodiesp2, tetrishapesp2, tetrifixturesp2, tetriimagesp2, tetrikindp2, "p2-", 2, i, uniqueid, x, y)
end

function collideBmulti(a, b)
	if type(a) == "userdata" and a.typeOf and a:typeOf("Fixture") then
		a = a:getUserData()
	end
	if type(b) == "userdata" and b.typeOf and b:typeOf("Fixture") then
		b = b:getUserData()
	end

	if (a == "p1-"..counterp1 and b ~= "p2-"..counterp2) or (b == "p1-"..counterp1 and b ~= "p2-"..counterp2) then --One of the pieces is the current piece and the other isn't the other player's one
		if p1fail == false and a ~= "leftp1" and a ~= "rightp1" and b ~= "leftp1" and b ~= "rightp1" then 
			endblockp1()
		end
	elseif (a == "p2-"..counterp2 and b ~= "p1-"..counterp1) or (b == "p2-"..counterp2 and a ~= "p1-"..counterp1) then
		if p2fail == false and a ~= "leftp2" and a ~= "rightp2" and b ~= "leftp2" and b ~= "rightp2" then 
			endblockp2()
		end
	elseif gamestate == "gameBmulti_results" then
		if (a == "mario" and b == "resultsfloor") or (b == "mario" and a == "resultsfloor") then
			jumpframe = false
		elseif (a == "luigi" and b == "resultsfloor") or (b == "luigi" and a == "resultsfloor") then
			jumpframe = false
		end
	end
end

function endblockp1()
	if gameno == 2 then
		for i, v in pairs(tetrifixturesp1[counterp1]) do --make shapes pass through the center
			v:setMask(3, 2)
		end
	end
	
	if tetribodiesp1[counterp1]:getY() < losingY then --P1 hit the top
		--FAIL P1--
		p1fail = true
		
		
		if p2fail == true then --Both players have hit the top
			endgame()
		end
	else --P1 didn't hit the top yet
		love.audio.stop(blockfall)
		love.audio.play(blockfall)
		linesscorep1 = linesscorep1 + 1
		scorescorep1 = linesscorep1 * 100
		game_addTetriBmultip1()
	end
end

function endblockp2()
	if gameno == 2 then
		for i, v in pairs(tetrifixturesp2[counterp2]) do --make shapes pass through the center
			v:setMask(2, 3)
		end
	end
	
	if tetribodiesp2[counterp2]:getY() < losingY then --P2 hit the top
		--FAIL P2--
		p2fail = true
		
		if p1fail == true then --Both players have hit the top
			endgame()
		end
	else --P2 didn't hit the top yet
		love.audio.stop(blockfall)
		love.audio.play(blockfall)
		linesscorep2 = linesscorep2 + 1
		scorescorep2 = linesscorep2 * 100
		game_addTetriBmultip2()
	end
end

function endgame()
	colorizetimer = love.timer.getTime()
	gamestate = "failingBmulti"
	
	if musicno < 4 then
		love.audio.stop(music[musicno])
	end
	
	love.audio.stop(gameover1)
	love.audio.play(gameover1)
	
	if scorescorep1 > scorescorep2 then
		p1wins = p1wins + 1
		winner = 1
	elseif scorescorep1 < scorescorep2 then
		p2wins = p2wins + 1
		winner = 2
	else
		winner = 3
	end
	if p1wins > 99 then
		p1wins = math.fmod(p1wins, 100)
	end
	if p2wins > 99 then
		p2wins = math.fmod(p2wins, 100)
	end
end
