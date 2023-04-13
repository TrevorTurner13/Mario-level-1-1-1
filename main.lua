function love.load()
    wf = require 'Libraries/windfield'
    world = wf.newWorld(0, 2000)

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
    world:addCollisionClass('killEnemy')
    world:addCollisionClass('fall')
    world:addCollisionClass('WallClass')
    world:addCollisionClass('win')

    walls = {}
    
    if gameMap.layers["Walls"] then 
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setCollisionClass('WallClass')
            wall:setType('static')
            table.insert(walls,wall)
        end
    end

    

    player = {}
    player.dx = 0 
    player.dy = 0
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
    player.is_on_ground = false
    player.isDead = false
    player.deathAnimDone = false

    player.collider = world:newBSGRectangleCollider( 0, 0, 16, 16, 0)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass('Player')
    player.collider:setObject(player)
    
    gambu = {}
    gambu.dx = 50
    gambu.dy = 0
    gambu.spriteSheet = love.graphics.newImage('Sprites/gambu.png')
    gambu.grid = anim8.newGrid( 16, 16, gambu.spriteSheet:getWidth(), gambu.spriteSheet:getHeight())
    
    gambu.animations = {}
    gambu.animations.moving = anim8.newAnimation( gambu.grid( '1-2', 1), 0.1)
    gambu.animations.dead = anim8.newAnimation( gambu.grid( "3-1", 1), 0.06)
    gambu.anim = gambu.animations.moving

    gambu.collider = world:newBSGRectangleCollider(300, 270, 16, 16, 0)
    gambu.collider:setFixedRotation(true)
    gambu.collider:setCollisionClass('Enemy')
    gambu.collider:setObject(gambu)

    gambu.collider1 = world:newBSGRectangleCollider(100, 240, 16, 1, 0)
    gambu.collider1:setType('static')
    gambu.collider1:setFixedRotation(true)
    gambu.collider1:setCollisionClass('killEnemy')
    gambu.collider1:setObject(gambu)

    gambu.isDead = false
    gambu.deathAnimDone = false
    gambu.isMovingRight = true

    fall = {}
    fall.collider = world:newBSGRectangleCollider( 0, 320, 3680, 2, 0)
    fall.collider:setFixedRotation(true)
    fall.collider:setType('static')
    fall.collider:setCollisionClass('fall')
    fall.collider:setObject(fall)

    win = {}
    win.collider = world:newBSGRectangleCollider( 3497, 200, 2, 200, 0)
    win.collider:setFixedRotation(true)
    win.collider:setType('static')
    win.collider:setCollisionClass('win')
    win.collider:setObject(win)


    vx = 0
    vy = 0

    timer = 0
    timerSpeed = 1

    
end

function love.update(dt)

    world:update(dt)
    if not player.isDead and not player.isDeadAnimDone and not player.win then
        sounds.music:play()
        player.isMoving = false
        if not gambu.isDead then
            

            gambu.x = gambu.collider:getX() - 8
            gambu.y = gambu.collider:getY() - 8

            gambu.collider1:setX(gambu.collider:getX())
            gambu.collider1:setY(gambu.collider:getY() - 10)

            if gambu.isMovingRight and gambu.dx <= 400 then
                gambu.collider:setLinearVelocity(20,0)
                if gambu.collider:getX() >= 400 then
                    gambu.isMovingRight = false
                end
            end
    
            if gambu.isMovingRight == false and gambu.dx <= 200 then
                gambu.collider:setLinearVelocity(-20,0)
                if gambu.collider:getX() <= 200 then
                    gambu.isMovingRight = true
                end
            end
            gambu.anim:update(dt)
            
        end

        

        --world.update(dt)

        if player.collider:enter('WallClass') then
            local collision_data = player.collider:getEnterCollisionData('WallClass')
            local wall = collision_data.collider:getObject()
            player.is_on_ground = true
        end

        
        if player.collider:enter('Enemy') then
            local collision_data = player.collider:getEnterCollisionData('Enemy')
            local gambu = collision_data.collider:getObject()
            player.isDead = true
            sounds.die:play()
        end

        if player.collider:enter('killEnemy') then
            local collision_data = player.collider:getEnterCollisionData('killEnemy')
            local gambu = collision_data.collider:getObject()
            player.collider:applyLinearImpulse(0, -275)
            gambu.isDead = true
            sounds.Squish:play()
        end

        player.dx , player.dy = player.collider:getLinearVelocity()

        if love.keyboard.isDown("d") and not love.keyboard.isDown('lshift') then  
            player.collider:setLinearVelocity(200,player.dy)
            player.anim = player.animations.right
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = false
            end
        
        elseif love.keyboard.isDown("d") and love.keyboard.isDown('lshift') then
            player.collider:setLinearVelocity(200,player.dy)
            player.anim = player.animations.right
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = false
            end
        
        elseif love.keyboard.isDown("a") and not love.keyboard.isDown('lshift') then
            player.collider:setLinearVelocity(-200,player.dy)
            player.anim = player.animations.right
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = true
            end
        
        elseif love.keyboard.isDown("a") and love.keyboard.isDown('lshift') then
            player.collider:setLinearVelocity(-200,player.dy)
            player.anim = player.animations.right
            if not player.isJumping then
                player.isMoving = true
                player.isMovingLeft = true
            end
        else
            player.collider:setLinearVelocity(player.dx,player.dy)
            player.isMoving = false
        end

        function love.keypressed(key)
            if key == 'space' and player.is_on_ground then
                player.collider:applyLinearImpulse(0, -275)
                player.is_on_ground = false
                sounds.jump:play()
            end
        end
        
        function love.keyreleased(key)
            -- because love2d uses a physics engine
            -- all force puts inertia onto a body.
            -- We need to stop the body inertia 
            -- once we are not longer pressing a key
            if key == 'd' or key == 'a' then
                -- again, we need to keep the y component
                player.dx , player.dy = player.collider:getLinearVelocity()
                player.collider:setLinearVelocity(0,player.dy)
            end
        end
        
        if not player.is_on_ground then
            player.anim = player.animations.jump
            player.anim:gotoFrame(1)
        elseif not player.isMoving and player.is_on_ground then
            player.anim = player.animations.right
            player.anim:gotoFrame(4)
        end

        if player.collider:enter('fall') then
            local collision_data = player.collider:getEnterCollisionData('fall')
            local fall = collision_data.collider:getObject()
            player.isDead = true
        end

        if player.collider:enter('win') then
            local collision_data = player.collider:getEnterCollisionData('win')
            local win = collision_data.collider:getObject()
             player.win = true 
        end

        if player.isDead and not player.deathAnimDone then
            sounds.music:pause()
            if not gambu.isDead then
                gambu.collider1:setType('dynamic')
            end
            sounds.die:play()
            player.anim = player.animations.death
            player.collider:applyLinearImpulse(0, -275)
            if timer > 1 then
                player.deathAnimDone = true
                
                timer = timer - 1
           end
      
           timer = timer + dt * timerSpeed
        end


        if gambu.isDead and not gambu.deathAnimDone then
            gambu.anim = gambu.animations.dead
            gambu.anim:gotoFrame(1)
            if timer > 1 then
                gambu.deathAnimDone = true
                gambu.collider:destroy()
                gambu.collider1:destroy()
                timer = timer - 1
           end
      
           timer = timer + dt * timerSpeed
            
        end

        if isMovingLeft then
            player.x = player.collider:getX() - 8
        else
            player.x = player.collider:getX() - 8
        end
        player.y = player.collider:getY() - 8

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
        
    end

    if isMovingLeft then
        player.x = player.collider:getX() - 8
    else
        player.x = player.collider:getX() - 8
    end
    player.y = player.collider:getY() - 8
    
    if player.win or player.isDead then
        if love.keyboard.isDown("escape") then
            love.event.quit()
        end
    end
end

function love.draw()
  
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
        gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
    

    if not gambu.deathAnimDone then
        gambu.anim:draw(gambu.spriteSheet, gambu.x, gambu.y, nil, 1, 1)
    end
    if player.isMovingLeft then 
        player.anim:draw(player.spriteSheet, player.x + 15, player.y, nil, -1, 1)
    else
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 1, 1)
    end
    
    --world:draw()
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
            love.graphics.printf("Oh a No! You a Died! Press ESC to exit game.", 250, 310 - rectHeight / 2, rectWidth, "center")
    end

    if player.win then
        local rectWidth, rectHeight = 100, 100 -- change the size of the rectangle here
            love.graphics.setColor(0, 0, 0) -- set the fill color to black
            love.graphics.rectangle("fill", 250, 250, rectWidth, rectHeight)
            love.graphics.setColor(1, 1, 1) -- set the outline color to white
            love.graphics.setLineWidth(1) -- set the line width to 5
            love.graphics.rectangle("line", 250, 250, rectWidth, rectHeight)
            love.graphics.setColor(1, 1, 1) -- set the text color to white
            love.graphics.setFont(love.graphics.newFont(12)) -- change the font size here
            love.graphics.printf("Mama Mia! You've a done it! Press ESC to exit game.", 250, 310 - rectHeight / 2, rectWidth, "center")
    end
end