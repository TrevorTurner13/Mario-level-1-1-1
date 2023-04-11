function love.load()
    camera = require 'Libraries/camera'
    cam = camera()
    cam:zoom(2)

    anim8 = require 'Libraries.anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'Libraries/sti'
    gameMap = sti('Maps/mario_map.lua')

    player = {}
    player.x = 0 
    player.y = 255
    player.speed = 1
    player.maxSpeed = 1.5
    player.spriteSheet = love.graphics.newImage('Sprites/Mario.png')
    player.smallMarioGrid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.bigMarioGrid = anim8.newGrid(16, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight(), 0, 16)

    player.animations = {}
    player.animations.right = anim8.newAnimation( player.smallMarioGrid( '4-1', 1), 0.1)
    player.animations.jump = anim8.newAnimation( player.smallMarioGrid( '6-1 ', 1), 0.06)
    

    player.anim = player.animations.right

    local isMoving = false
    local isMovingLeft = false
    local isJumping = false

    player.ground = player.y     -- This makes the character land on the plaform.

	player.y_velocity = 0        -- Whenever the character hasn't jumped yet, the Y-Axis velocity is always at 0.

	player.jump_height = -300    -- Whenever the character jumps, he can reach this height.
	player.gravity = -500        -- Whenever the character falls, he will descend at this rate.

end

function love.update(dt)
    isMoving = false
    isJumping = false
    
        
    if love.keyboard.isDown("d") and not love.keyboard.isDown('lshift') then  
        player.x = player.x + player.speed     
        player.anim = player.animations.right
        if not isJumping then
            isMoving = true
            isMovingLeft = false
        end
    end

    if love.keyboard.isDown('lshift') and love.keyboard.isDown("d") then
        player.x = player.x + player.maxSpeed
        player.anim = player.animations.right
        if not isJumping then
            isMoving = true
            isMovingLeft = false
        end
    end

    if love.keyboard.isDown("a") and not love.keyboard.isDown('lshift') then
        player.x = player.x - player.speed
        player.anim = player.animations.right
        if not isJumping then
            isMoving = true
            isMovingLeft = true
        end
    end

    if love.keyboard.isDown("a") and love.keyboard.isDown('lshift') then
        player.x = player.x - player.maxSpeed
        player.anim = player.animations.right
        if not isJumping then
            isMoving = true
            isMovingLeft = true
        end
    end

    if love.keyboard.isDown('space') then
		if player.y_velocity == 0 then
			player.y_velocity = player.jump_height
		end
	end

	if player.y_velocity ~= 0 then
		player.y = player.y + player.y_velocity * dt
		player.y_velocity = player.y_velocity - player.gravity * dt
        isJumping = true
	end

	if player.y > player.ground then
		player.y_velocity = 0
    	player.y = player.ground   
	end
    
    if isJumping then
        player.anim = player.animations.jump
        player.anim:gotoFrame(1)
    elseif not isMoving and not isJumping then
        player.anim = player.animations.right
        player.anim:gotoFrame(4)
    end

    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x *2 < w/2 then
        cam.x = w/2/2
    end

    if cam.y *2 < w/2 then
        cam.y = w/2/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - w/2/2) then
        cam.x = (mapW - w/2/2)
    end

    if cam.y *2 > (mapH - h/2/2) then
        cam.y = (mapH - h/2/2)
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
    if isMovingLeft then 
        player.anim:draw(player.spriteSheet, player.x + 30, player.y, nil, -1, 1)
    else
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, 1)
    end
        cam:detach()
end