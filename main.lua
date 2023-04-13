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

    sounds = {}
    sounds.music = love.audio.newSource("sounds/01_Running_About.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.jump = love.audio.newSource("sounds/Jump.wav", "stream")
    sounds.jump:setLooping(false)
    sounds.coin = love.audio.newSource("sounds/Coin.wav", "stream")
    sounds.coin:setLooping(false)
    sounds.Squish = love.audio.newSource("sounds/Squish.wav", "stream")
    sounds.Squish:setLooping(false)
    sounds.die = love.audio.newSource("sounds/Die.wav", "stream")
    sounds.die:setLooping(false)

    world:addCollisionClass('Player')
    world:addCollisionClass('Enemy')

    player = {}
    player.x = 0 
    player.y = 270
    player.speed = 20000
    player.maxSpeed = 30000
    player.spriteSheet = love.graphics.newImage('Sprites/Mario.png')
    player.smallMarioGrid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.bigMarioGrid = anim8.newGrid(16, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight(), 0, 16)

    player.animations = {}
    player.animations.right = anim8.newAnimation( player.smallMarioGrid( '4-1', 1), 0.06)
    player.animations.jump = anim8.newAnimation( player.smallMarioGrid( '6-1 ', 1), 0.06)
    player.animations.death = anim8.newAnimation( player.smallMarioGrid( '7-6', 1), 0.06)
    player.anim = player.animations.right

    player.isMoving = false
    player.isMovingLeft = false
    player.isJumping = false
    player.onGround = true

    player.collider = world:newBSGRectangleCollider( 0, 0, 16, 16, 0)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass('Player')
    player.collider:setObject(player)
	player.jump_height = -80000
	player.gravity = -78000
    player.isDead = false
    player.isDeadAnimDone = false

    vx = 0
    vy = 0

    gambu = {}
    gambu.x = 200
    gambu.y = 240
    gambu.spriteSheet = love.graphics.newImage('Sprites/gambu.png')
    gambu.grid = anim8.newGrid( 16, 16, gambu.spriteSheet:getWidth(), gambu.spriteSheet:getHeight())

    gambu.animations = {}
    gambu.animations.moving = anim8.newAnimation( gambu.grid( '1-2', 1), 0.06)
    gambu.anim = gambu.animations.moving

    gambu.collider = world:newBSGRectangleCollider(200, 240, 16, 16, 0)
    gambu.collider:setFixedRotation(true)
    gambu.collider:setCollisionClass('Enemy')
    gambu.collider:setObject(gambu)
    gambu.speed = 90
    

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
    if not player.isDeadAnimDone then
        sounds.music:play()
        player.isMoving = false
        player.isJumping = false
        
        player.collider:setLinearVelocity(vx, vy)
        gambu.collider:setLinearVelocity(0, 0)

        if love.keyboard.isDown("d") and not love.keyboard.isDown('lshift') then  
            vx = player.speed * dt
            player.anim = player.animations.right
            print(vx)
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = false
            end
        
        elseif love.keyboard.isDown("d") and love.keyboard.isDown('lshift') then
            vx = player.maxSpeed * dt
            player.anim = player.animations.right
            print(vx)
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = false
            end
        
        elseif love.keyboard.isDown("a") and not love.keyboard.isDown('lshift') then
            vx = player.speed * dt * -1
            player.anim = player.animations.right
            print(vx)
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = true
            end
        
        elseif love.keyboard.isDown("a") and love.keyboard.isDown('lshift') then
            vx = player.maxSpeed * dt * -1
            player.anim = player.animations.right
            print(vx)
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = true
            end
        else
            vx = 0
            player.isMoving = false
        end

        if love.keyboard.isDown('space') then
            if not player.isJumping then
                vy = player.jump_height
                sounds.jump:play()
                print(vx)
                player.isJumping = true
            end
        end

        if player.isJumping then
            vy =  player.jump_height * dt
            vy = vy - (player.gravity * dt)
            print(vy)
        end
        
        if player.isJumping then
            player.anim = player.animations.jump
            player.anim:gotoFrame(1)
        elseif not player.isMoving and not player.isJumping then
            player.anim = player.animations.right
            player.anim:gotoFrame(4)
            vx = 0
        end
    
        if isMovingLeft then
            player.x = player.collider:getX() - 8
        else
            player.x = player.collider:getX() - 8
        end
        player.y = player.collider:getY() - 8

        gambu.x = gambu.collider:getX() - 8
        gambu.y = gambu.collider:getY() - 8

        if player.collider:enter('Enemy') then
            local collision_data = player.collider:getEnterCollisionData('Enemy')
            local gambu = collision_data.collider:getObject()
            player.isDead = true
        end

        if player.isDead then
            sounds.music:pause()
            player.anim = player.animations.death
            player.anim:gotoFrame(1)
            vx = 0
            if player.y_velocity == 0 then
                player.y_velocity = player.jump_height
                sounds.die:play()
            end
            if player.y_velocity ~= 0 then
                vy = player.y_velocity * dt
                player.y_velocity = player.y_velocity - player.gravity * dt
                player.isJumping = true
            end
            player.isDeadAnimDone = true
        end

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

        player.anim:update(dt)
        gambu.anim:update(dt)

        world:update(dt)
    end
end

function love.draw()
  
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
    if player.isMovingLeft then 
        player.anim:draw(player.spriteSheet, player.x + 15, player.y, nil, -1, 1)
    else
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, 1)
    end
    gambu.anim:draw(gambu.spriteSheet, gambu.x, gambu.y, nil, 1, 1)
    
    world:draw()
    cam:detach()

    if player.isDead then
        local rectWidth, rectHeight = 100, 100 -- change the size of the rectangle here
            love.graphics.setColor(0, 0, 0) -- set the fill color to black
            love.graphics.rectangle("fill", 250, 250, rectWidth, rectHeight)
            love.graphics.setColor(1, 1, 1) -- set the outline color to white
            love.graphics.setLineWidth(1) -- set the line width to 5
            love.graphics.rectangle("line", 250, 250, rectWidth, rectHeight)
            love.graphics.setColor(1, 1, 1) -- set the text color to white
            love.graphics.setFont(love.graphics.newFont(12)) -- change the font size here
            love.graphics.printf("You Failed! Try harder next time! Press ESC to exit game.", 250, 280 - rectHeight / 2, rectWidth, "center")
    end
end