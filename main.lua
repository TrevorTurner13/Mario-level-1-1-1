function love.load()
    wf = require 'Libraries/windfield'
    world = wf.newWorld(0,0)

    camera = require 'Libraries/camera'
    cam = camera()
    cam:zoom(3)

    anim8 = require 'Libraries.anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'Libraries/sti'
    gameMap = sti('Maps/mario_map.lua')

    player = {}
    player.x = 0 
    player.y = 270
    player.speed = 0.75
    player.maxSpeed = 1.2
    player.spriteSheet = love.graphics.newImage('Sprites/Mario.png')
    player.smallMarioGrid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.bigMarioGrid = anim8.newGrid(16, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight(), 0, 16)

    player.animations = {}
    player.animations.right = anim8.newAnimation( player.smallMarioGrid( '4-1', 1), 0.1)
    player.animations.jump = anim8.newAnimation( player.smallMarioGrid( '6-1 ', 1), 0.06)
    
    player.anim = player.animations.right

    player.isMoving = false
    player.isMovingLeft = false
    player.isJumping = false

    player.collider = world:newBSGRectangleCollider( player.x, player.y, 16, 16, 0)
    player.collider:setFixedRotation(true)
    vx = 0
    vy = 0
    
    player.ground = 270 -- This makes the character land on the plaform.

	player.y_velocity = 0        -- Whenever the character hasn't jumped yet, the Y-Axis velocity is always at 0.

	player.jump_height = -500   -- Whenever the character jumps, he can reach this height.
	player.gravity = -1650      -- Whenever the character falls, he will descend at this rate.

    walls = {}
    if gameMap.layers["walls"] then 
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls.wall)
        end
    end
end

function love.update(dt)
    player.isMoving = false
    player.isJumping = false

    if love.keyboard.isDown("d") and not love.keyboard.isDown('lshift') then  
        player.x = player.x + player.speed     
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = false
        end
    end

    if love.keyboard.isDown("d") and love.keyboard.isDown('lshift') then
        player.x = player.x + player.maxSpeed
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = false
        end
    end

    if love.keyboard.isDown("a") and not love.keyboard.isDown('lshift') then
        player.x = player.x + player.speed * -1
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = true
        end
    end

    if love.keyboard.isDown("a") and love.keyboard.isDown('lshift') then
        player.x = player.x + player.maxSpeed * -1
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = true
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
        player.isJumping = true
	end

	if player.y > player.ground then
		player.y_velocity = 0
    	player.y = player.ground
	end
    
    if player.isJumping then
        player.anim = player.animations.jump
        player.anim:gotoFrame(1)
    elseif not player.isMoving and not player.isJumping then
        player.anim = player.animations.right
        player.anim:gotoFrame(4)
    end

    --player.collider:setLinearVelocity(vx, vy)
    
    world:update(dt)

    if isMovingLeft then
        player.collider:setX(player.x + 12)
    else
        player.collider:setX(player.x + 8) 
    end
    player.collider:setY(player.y + 9)

    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x * 3 < w/2 then
        cam.x = w/2/3
    end

    if cam.y * 3 < w/2 then
        cam.y = w/2/3
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - w/2/3) then
        cam.x = (mapW - w/2/3)
    end

    if cam.y * 3 > (mapH - h/2/3) then
        cam.y = (mapH - h/2/3)
    end
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
        if player.isMovingLeft then 
        player.anim:draw(player.spriteSheet, player.x + 20, player.y, nil, -1, 1)
     else
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, 1)
        end
        world:draw()
        cam:detach()
end