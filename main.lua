function love.load()
    wf = require 'Libraries/windfield'
    world = wf.newWorld(0, 40000)

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
    player.speed = 15000
    player.maxSpeed = 225
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
    player.onGround = true

    vx = 0
    vy = 0
    player.collider = world:newBSGRectangleCollider( 0, 0, 16, 16, 0)
    player.collider:setFixedRotation(true)
    --player.ground = 0 -- This makes the character land on the plaform.

	player.y_velocity = 0        -- Whenever the character hasn't jumped yet, the Y-Axis velocity is always at 0.

	player.jump_height = -80000   -- Whenever the character jumps, he can reach this height.
	player.gravity = -78000     -- Whenever the character falls, he will descend at this rate.

    walls = {}
    if gameMap.layers["Walls"] then 
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls,wall)
        end
    end
end

function love.update(dt)
    player.isMoving = false
    player.isJumping = false

   

    if love.keyboard.isDown("d") and not love.keyboard.isDown('lshift') then  
        vx = player.speed   
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = false
        end
    

    elseif love.keyboard.isDown("d") and love.keyboard.isDown('lshift') then
        vx = player.maxSpeed
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = false
        end
    

    elseif love.keyboard.isDown("a") and not love.keyboard.isDown('lshift') then
        vx = player.speed
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = true
        end
    

    elseif love.keyboard.isDown("a") and love.keyboard.isDown('lshift') then
        vx = player.maxSpeed
        player.anim = player.animations.right
        if not player.isJumping then
            player.isMoving = true
            player.isMovingLeft = true
        end
    else
        vx = 0
        player.isMoving = false
	end

    if love.keyboard.isDown('space') then
		if player.y_velocity == 0 then
			player.y_velocity = player.jump_height
		end
    end

	if player.y_velocity ~= 0 then
		vy = player.y_velocity * dt
		player.y_velocity = player.y_velocity - player.gravity * dt
        player.isJumping = true
	end

	if vy > 0 then
		player.y_velocity = 0
    	vy = 0
	end
    
    if player.isJumping then
        player.anim = player.animations.jump
        player.anim:gotoFrame(1)
    elseif not player.isMoving and not player.isJumping then
        player.anim = player.animations.right
        player.anim:gotoFrame(4)
        vx = 0
    end

    player.collider:setLinearVelocity(vx, vy)
    
    if isMovingLeft then
        player.x = player.collider:getX() - 8
    else
        player.x = player.collider:getX() - 8 
    end
    player.y = player.collider:getY() - 8

    player.anim:update(dt)

world:update(dt)

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