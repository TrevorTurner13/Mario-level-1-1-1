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
    sounds.kick = love.audio.newSource("sounds/kick.wav", "stream")
    sounds.kick:setLooping(false)
    sounds.die = love.audio.newSource("sounds/Die.wav", "stream")
    sounds.die:setLooping(false)
    sounds.win = love.audio.newSource("sounds/win.mp3", "stream")
    sounds.win:setLooping(false) 
    sounds.item = love.audio.newSource("sounds/item.wav", "stream")
    sounds.item:setLooping(false) 
    sounds.Powerup = love.audio.newSource("sounds/Powerup.wav", "stream")
    sounds.Powerup:setLooping(false)

    world:addCollisionClass('Player')
    world:addCollisionClass('Enemy')
    world:addCollisionClass('KillGambu')
    world:addCollisionClass('ShellKapoo')
    world:addCollisionClass('fall')
    world:addCollisionClass('Platforms')
    world:addCollisionClass('win')
    world:addCollisionClass('Blocks')
    world:addCollisionClass('Mushroom')
    world:addCollisionClass('MushroomBlocks')

    walls = {}
    
    if gameMap.layers["Walls"] then 
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setCollisionClass('Platforms')
            wall:setType('static')
            table.insert(walls,wall)
        end
    end

    player = {}
    player.dx = 0 
    player.dy = 0
    player.spriteSheet = love.graphics.newImage('Sprites/Mario.png')
    player.smallMarioGrid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.bigMarioGrid = anim8.newGrid(16, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight(), 0, 16)

    player.animations = {}
    player.animations.right = anim8.newAnimation( player.smallMarioGrid( '4-1', 1), 0.06)
    player.animations.jump = anim8.newAnimation( player.smallMarioGrid( '6-1 ', 1), 0.06)
    player.animations.death = anim8.newAnimation( player.smallMarioGrid( '7-6', 1), 0.06)
    player.animations.rightBig = anim8.newAnimation( player.bigMarioGrid( '4-1', 1), 0.06)
    player.animations.jumpBig = anim8.newAnimation( player.bigMarioGrid( '6-1 ', 1), 0.06)
    player.animations.deathBig = anim8.newAnimation( player.bigMarioGrid( '7-6', 1), 0.06)
    player.anim = player.animations.right
    player.anim = player.animations.rightBig

    player.isMoving = false
    player.isMovingLeft = false
    player.is_on_ground = false
    player.isDead = false
    player.deathAnimDone = false
    player.isBig = false

    player.colliderSmall = world:newBSGRectangleCollider( 0, 0, 16, 16, 0)
    player.colliderSmall:setFixedRotation(true)
    player.colliderSmall:setCollisionClass('Player')
    player.colliderSmall:setObject(player)
    player.timer = 0

    
    
    gambus = {}
    spawnGambu(300, 270)
    spawnGambu(350, 270)
    spawnGambu(700, 270)
    spawnGambu(2000, 270)
    spawnGambu(2025, 270)
    spawnGambu(3000, 270)
    spawnGambu(2125, 270)
    

    kapoos = {}
    spawnKapoos(100, 270)
    spawnKapoos(500, 270)
    spawnKapoos(1200, 270)

    coins = {}
    spawnCoins(244, 225)
    spawnCoins(324, 225)
    spawnCoins(356, 225)
    spawnCoins(1428, 225)
    spawnCoins(1684, 161)
    spawnCoins(1860, 225)
    spawnCoins(1908, 225)
    spawnCoins(1956, 225)
    spawnCoins(1908, 161)
    spawnCoins(2228, 161)
    spawnCoins(2244, 161)
    spawnCoins(2932, 209)

    blocks = {}
    spawnBlocks(240, 240)
    spawnBlocks(320, 240)
    spawnBlocks(352, 240)
    spawnBlocks(1424, 240)
    spawnBlocks(1680, 176)
    spawnBlocks(1856, 240)
    spawnBlocks(1904, 240)
    spawnBlocks(1952, 240)
    spawnBlocks(1904, 176)
    spawnBlocks(2224, 176)
    spawnBlocks(2240, 176)
    spawnBlocks(2928, 224)

    mushrooms = {}
   
    mushroomBlocks = {}
    spawnMushroomBlocks(336,176)
    mushroomGrabbed = false

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

    
    
end

function love.update(dt)

    world:update(dt)
    if not player.isDead and not player.isDeadAnimDone and not player.win then
        sounds.music:play()
        player.isMoving = false
        for i, g in ipairs(gambus) do
            if not g.isDead then
                g.collider:setLinearVelocity(g.dx,g.dy)

                g.x = g.collider:getX() - 8
                g.y = g.collider:getY() - 8

                g.collider1:setX(g.collider:getX())
                g.collider1:setY(g.collider:getY() - 10)

                g.anim:update(dt)
                
            end
        end
        for i, k in ipairs(kapoos) do
            if not k.isDead and not k.shellHit then
                k.collider:setLinearVelocity(k.dx, k.dy)

                k.x = k.collider:getX() - 8
                k.y = k.collider:getY() - 12

                k.collider1:setX(k.collider:getX())
                k.collider1:setY(k.collider:getY() - 13)

                k.anim:update(dt)
            elseif k.shellHit then
                k.collider:setLinearVelocity(k.dx, k.dy)

                k.x = k.collider:getX() - 8
                k.y = k.collider:getY() - 8

                k.collider1:setX(k.collider:getX())
                k.collider1:setY(k.collider:getY() - 10)
                k.anim:gotoFrame(2)
                k.anim:update(dt)
            end
        end
       
        handleCollisions(dt)
        --world.update(dt)

        
        if not player.isBig then
            player.dx , player.dy = player.colliderSmall:getLinearVelocity()
            if love.keyboard.isDown("d") and not love.keyboard.isDown('lshift') then  
                player.colliderSmall:setLinearVelocity(150,player.dy)
                player.anim = player.animations.right
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = false
                end
            
            elseif love.keyboard.isDown("d") and love.keyboard.isDown('lshift') then
                player.colliderSmall:setLinearVelocity(200,player.dy)
                player.anim = player.animations.right
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = false
                end
            
            elseif love.keyboard.isDown("a") and not love.keyboard.isDown('lshift') then
                player.colliderSmall:setLinearVelocity(-150,player.dy)
                player.anim = player.animations.right
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = true
                end
            
            elseif love.keyboard.isDown("a") and love.keyboard.isDown('lshift') then
                player.colliderSmall:setLinearVelocity(-200,player.dy)
                player.anim = player.animations.right
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = true
                end
    
            
            else
                player.colliderSmall:setLinearVelocity(player.dx,player.dy)
                player.isMoving = false
            end
    
            function love.keypressed(key)
                if key == 'space' and player.is_on_ground then
                    player.colliderSmall:applyLinearImpulse(0, -275)
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
                    player.dx , player.dy = player.colliderSmall:getLinearVelocity()
                    player.colliderSmall:setLinearVelocity(0,player.dy)
                end
            end
            if not player.is_on_ground then
                player.anim = player.animations.jump
                player.anim:gotoFrame(1)
            elseif not player.isMoving and player.is_on_ground then
                player.anim = player.animations.right
                player.anim:gotoFrame(4)
            end
        else
            player.dx , player.dy = player.colliderBig:getLinearVelocity()

            if love.keyboard.isDown("d") and not love.keyboard.isDown('lshift') then  
                player.colliderBig:setLinearVelocity(150,player.dy)
                player.anim = player.animations.rightBig
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = false
                end
            
            elseif love.keyboard.isDown("d") and love.keyboard.isDown('lshift') then
                player.colliderBig:setLinearVelocity(200,player.dy)
                player.anim = player.animations.rightBig
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = false
                end
            
            elseif love.keyboard.isDown("a") and not love.keyboard.isDown('lshift') then
                player.colliderBig:setLinearVelocity(-150,player.dy)
                player.anim = player.animations.rightBig
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = true
                end
            
            elseif love.keyboard.isDown("a") and love.keyboard.isDown('lshift') then
                player.colliderBig:setLinearVelocity(-200,player.dy)
                player.anim = player.animations.rightBig
                if not player.isJumping then
                    player.isMoving = true
                    player.isMovingLeft = true
                end
    
            
            else
                player.colliderBig:setLinearVelocity(player.dx,player.dy)
                player.isMoving = false
            end
    
            function love.keypressed(key)
                if key == 'space' and player.is_on_ground then
                    player.colliderBig:applyLinearImpulse(0, -550)
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
                    player.dx , player.dy = player.colliderBig:getLinearVelocity()
                    player.colliderBig:setLinearVelocity(0,player.dy)
                end
            end
            if not player.is_on_ground then
                player.anim = player.animations.jumpBig
                player.anim:gotoFrame(1)
            elseif not player.isMoving and player.is_on_ground then
                player.anim = player.animations.rightBig
                player.anim:gotoFrame(4)
            end
            --player.animations.rightBig = anim8.newAnimation( player.bigMarioGrid( '4-1', 1), 0.06)
           --player.animations.jumpBig = anim8.newAnimation( player.bigMarioGrid( '6-1 ', 1), 0.06)
            --player.animations.deathBig = anim8.newAnimation( player.bigMarioGrid( '7-6', 1), 0.06)
        end


        
        
        

        if player.colliderSmall:enter('fall') then
            local collision_data = player.colliderSmall:getEnterCollisionData('fall')
            local fall = collision_data.collider:getObject()
            player.isDead = true
        end
        if player.isBig then
            if player.colliderBig:enter('fall') then
                local collision_data = player.colliderBig:getEnterCollisionData('fall')
                local fall = collision_data.collider:getObject()
                player.isDead = true
            end
        end
        

        if player.colliderSmall:enter('win') then
            local collision_data = player.colliderSmall:getEnterCollisionData('win')
            local win = collision_data.collider:getObject()
             player.win = true 
             sounds.win:play()
             sounds.music:stop()

        end

        if player.isBig then
            if player.colliderBig:enter('win') then
                local collision_data = player.colliderBig:getEnterCollisionData('win')
                local win = collision_data.collider:getObject()
                 player.win = true 
                 sounds.win:play()
                 sounds.music:stop()
    
            end
        end

        if player.isDead and not player.deathAnimDone then
            sounds.music:pause()
            for i, g in ipairs(gambus) do
                if not g.isDead then
                    g.collider1:setType('dynamic')
                end
            end
            if player.isBig then
                sounds.die:play()
                player.anim = player.animations.deathBig
                player.colliderBig:applyLinearImpulse(0, -550)
            else 
                sounds.die:play()
                player.anim = player.animations.death
                player.colliderSmall:applyLinearImpulse(0, -275)
            end

            if player.timer > 1 then
                player.deathAnimDone = true
                
                player.timer = 0
           end
      
           player.timer = player.timer + dt
        end

        for i, g in ipairs(gambus) do
            if g.isDead and not g.deathAnimDone then
                g.anim = g.animations.dead
                g.anim:gotoFrame(1)
                if g.timer >= 0.25 then
                    g.deathAnimDone = true
                    g.collider:destroy()
                    g.collider1:destroy()
                    g.timer = 0
                end
        
                g.timer = g.timer + dt
                
            end
        end

        if not player.isBig then
            if isMovingLeft then
                player.x = player.colliderSmall:getX() - 8
            else
                player.x = player.colliderSmall:getX() - 8
            end
            player.y = player.colliderSmall:getY() - 8

        else
            if isMovingLeft then
                player.x = player.colliderBig:getX() - 8
            else
                player.x = player.colliderBig:getX() - 8
            end
            player.y = player.colliderBig:getY() - 8

        end
        

        for i, b in ipairs(blocks) do
            b.x = b.collider:getX() - 8
            b.y = b.collider:getY() - 17
        end

        for i, mb in ipairs(mushroomBlocks) do
            if not mb.hit then 
                mb.x = mb.collider:getX() - 8
                mb.y = mb.collider:getY() - 17
            end
        end

        if mushroomGrabbed == false then
            for i, m in ipairs(mushrooms)  do
                m.x = m.collider:getX() - 8
                m.y = m.collider:getY() - 8
                m.collider:setLinearVelocity(100,m.dy)
                m.collider:applyLinearImpulse(m.dx, 90)
                
            end
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

       
            if player.colliderSmall:enter('Blocks') then
                local collision_data = player.colliderSmall:getEnterCollisionData('Blocks')
                local block = collision_data.collider:getObject()
                for i, c in ipairs(coins)  do
                    if c.x <= player.x + 18 and c.x >= player.x - 18 then
                        c.y = c.y - 16
                        sounds.coin:play()
                        c.hit = true
                    end
                end
                for i, b in ipairs(blocks) do
                    if b.x <= player.x + 18 and b.x >= player.x - 18 then
                        b.hit = true
                    end
                end
            end 
        
        if player.colliderSmall:enter('MushroomBlocks') then
            local collision_data = player.colliderSmall:getEnterCollisionData('MushroomBlocks')
            local block = collision_data.collider:getObject()
            spawnMushroom(336, 150)
            for i, m in ipairs(mushrooms)  do
                m.x = m.collider:getX() - 8
                m.y = m.collider:getY() - 16
                m.spawn = true
                if m.x <= player.x + 18 and m.x >= player.x - 18 then
                    
                    sounds.item:play()
                end
            end
            for i, b in ipairs(mushroomBlocks) do
                if b.x <= player.x + 18 and b.x >= player.x - 18 then
                    b.hit = true
                    if b.hit then
                        b.collider:destroy()
                    end
                end
            end
        end 

        if player.isBig then
            if player.colliderBig:enter('Blocks') then
                local collision_data = player.colliderBig:getEnterCollisionData('Blocks')
                local block = collision_data.collider:getObject()
                for i, c in ipairs(coins)  do
                    if c.x <= player.x + 18 and c.x >= player.x - 18 then
                        c.y = c.y - 16
                        sounds.coin:play()
                        c.hit = true
                    end
                end
                for i, b in ipairs(blocks) do
                    if b.x <= player.x + 18 and b.x >= player.x - 18 then
                        b.hit = true
                    end
                end
            end 
            if player.colliderBig:enter('MushroomBlocks') then
                local collision_data = player.colliderBig:getEnterCollisionData('MushroomBlocks')
                local block = collision_data.collider:getObject()
                spawnMushroom(336, 150)
                for i, m in ipairs(mushrooms)  do
                    m.x = m.collider:getX() - 8
                    m.y = m.collider:getY() - 16
                    m.spawn = true
                    if m.x <= player.x + 18 and m.x >= player.x - 18 then
                        
                        sounds.item:play()
                    end
                end
                for i, b in ipairs(mushroomBlocks) do
                    if b.x <= player.x + 18 and b.x >= player.x - 18 then
                        b.hit = true
                        if b.hit then
                            b.collider:destroy()
                        end
                    end
                end
            end 
        end




        for i, c in ipairs(coins) do
            c.anim:update(dt)
            if c.hit then
                c.timer = c.timer + dt
                if c.timer > 1 then
                    table.remove(coins, i)
                    c.timer = 0
                end
            end
        end
    end

    

    if not player.isBig then
        if isMovingLeft then
            player.x = player.colliderSmall:getX() - 8
        else
            player.x = player.colliderSmall:getX() - 8
        end
        player.y = player.colliderSmall:getY() - 8
    else
        if isMovingLeft then
            player.x = player.colliderBig:getX() - 8
        else
            player.x = player.colliderBig:getX() - 8
        end
        player.y = player.colliderBig:getY() - 16
    end



    
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

   for i, c in ipairs(coins) do 
        c.anim:draw(c.spriteSheet, c.x, c.y, nil, 1, 1)
    end
    
    
    for i, m in ipairs(mushrooms) do
        if m.spawn then
            love.graphics.draw(m.spriteSheet, m.x, m.y)
        end
    end

    for i, mb in ipairs(mushroomBlocks) do
        if not mb.hit then
            love.graphics.draw(mb.spriteSheet, mb.x, mb.y)
        else
            love.graphics.draw(mb.spriteSheet1, mb.x, mb.y)
        end
    end
    --coin2.anim:draw(coin1.spriteSheet, coin2.x, coin2.y, nil, 1, 1)
    for i, b in ipairs(blocks) do
        if not b.hit then
            love.graphics.draw(b.spriteSheet, b.x, b.y)
        else
            love.graphics.draw(b.spriteSheet1, b.x, b.y)
        end
    end
    
    for i, g in ipairs(gambus) do
        if not g.deathAnimDone then
            g.anim:draw(g.spriteSheet, g.x, g.y, nil, 1, 1)
        end 
    end

    for i, k in ipairs(kapoos) do
        if k.dx < 0 then
        k.anim:draw(k.spriteSheet, k.x, k.y, nil, 1, 1)
        else
        k.anim:draw(k.spriteSheet, k.x + 15, k.y, nil, -1, 1)
        end
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

function handleCollisions(dt)
    if player.colliderSmall:enter('Platforms') then
        local collision_data = player.colliderSmall:getEnterCollisionData('Platforms')
        local wall = collision_data.collider:getObject()
        player.is_on_ground = true
    end

    if player.isBig then
        if player.colliderBig:enter('Platforms') then
            local collision_data = player.colliderBig:getEnterCollisionData('Platforms')
            local wall = collision_data.collider:getObject()
            player.is_on_ground = true
        end
    end
    
    
    if player.colliderSmall:enter('Enemy') then
        local collision_data = player.colliderSmall:getEnterCollisionData('Enemy')
        local gambu = collision_data.collider:getObject()
        
        player.isDead = true
         
        
        sounds.die:play()
    end
    if player.isBig then
        if player.colliderBig:enter('Enemy') then
            
            local collision_data = player.colliderBig:getEnterCollisionData('Enemy')
            local gambu = collision_data.collider:getObject()
            
            player.isBig = false
      
            local tempX = player.colliderBig:getX()
            local tempY = player.colliderBig:getY()
            player.colliderBig:destroy()
            player.colliderSmall = world:newBSGRectangleCollider( tempX, tempY, 16, 16, 0)
            player.colliderSmall:setFixedRotation(true)
            player.colliderSmall:setCollisionClass('Player')
            player.colliderSmall:setObject(player)
            if player.isMovingLeft then
                 player.colliderSmall:setLinearVelocity(200, 0)
            else 
                 player.colliderSmall:setLinearVelocity(-200, 0)
            end
           
            
            
        end
    end
    

    if player.colliderSmall:enter('Mushroom') then
        local collision_data = player.colliderSmall:getEnterCollisionData('Mushroom')
        local mushroom = collision_data.collider:getObject()
        player.isBig = true
        local tempX = player.colliderSmall:getX()
        local tempY = player.colliderSmall:getY()
        mushroom.collider:destroy()
        table.remove(mushrooms, 1)
        mushroomGrabbed = true
        player.colliderSmall:destroy()
        player.colliderBig = world:newBSGRectangleCollider( tempX, tempY, 16, 32, 0)
        player.colliderBig:setFixedRotation(true)
        player.colliderBig:setCollisionClass('Player')
        player.colliderBig:setObject(player)
        sounds.Powerup:play()
    end

    
    if player.colliderSmall:enter('KillGambu') then
        local collision_data = player.colliderSmall:getEnterCollisionData('KillGambu')
        local enemy = collision_data.collider:getObject()
        player.colliderSmall:applyLinearImpulse(0, -275)
        for i, g in ipairs(gambus) do 
            if g.x <= player.x + 18 and g.x >= player.x - 18 then
            g.isDead = true
            end
        end
        sounds.Squish:play()
    end
    if player.isBig then
        if player.colliderBig:enter('KillGambu') then
            local collision_data = player.colliderBig:getEnterCollisionData('KillGambu')
            local enemy = collision_data.collider:getObject()
            player.colliderBig:applyLinearImpulse(0, -275)
            for i, g in ipairs(gambus) do 
                if g.x <= player.x + 18 and g.x >= player.x - 18 then
                g.isDead = true
                end
            end
            sounds.Squish:play()
        end
    end
    
    if not player.isBig then
        for i, k in ipairs(kapoos) do
            if player.colliderSmall:enter('ShellKapoo') and not k.shellHit and k.x <= player.x + 10 and k.x >= player.x - 10 then
                local collision_data = player.colliderSmall:getEnterCollisionData('ShellKapoo')
                local enemy = collision_data.collider:getObject()
                player.colliderSmall:applyLinearImpulse(0, -100)
                k.shellHit = true
                sounds.kick:play()
                k.dx = 0
                k.anim = k.animations.shell
                
                local tempx = k.collider:getX()
                local tempy = k.collider:getY()
                k.collider:destroy()
                k.collider = world:newBSGRectangleCollider(tempx, tempy, 16, 16, 0)
                k.collider:setFixedRotation(true)
                k.collider:setCollisionClass('Enemy')
                k.collider:setObject(k)
                k.x = k.collider:getX() - 8
                k.y = k.collider:getY() - 8
    
                k.collider1:setX(k.collider:getX())
                k.collider1:setY(k.collider:getY() - 5)
    
            elseif player.colliderSmall:enter('ShellKapoo') and k.shellHit then
                local collision_data = player.colliderSmall:getEnterCollisionData('ShellKapoo')
                local enemy = collision_data.collider:getObject()
                player.colliderSmall:applyLinearImpulse(0, -100)
                sounds.kick:play()
                k.dx = 150
            end
        end
    
        for i, k in ipairs(kapoos) do
           if k.collider:enter('Enemy') and k.shellHit then
                local collision_data = k.collider:getEnterCollisionData('Enemy')
                local enemy = collision_data.collider:getObject()
                
                for i, g in ipairs(gambus) do
                    if g.x <= k.x + 18 and g.x >= k.x - 18 then
                        g.isDead = true
                    end
                end
                sounds.Squish:play()
            end
        end
    
        for i, k in ipairs(kapoos) do
            if k.collider:enter('Enemy') and not k.shellHit then
                local collision_data = k.collider:getEnterCollisionData('Enemy')
                local enemy = collision_data.collider:getObject()
                k.dx = k.dx*-1
                for i, g in ipairs(gambus) do
                    if g.x <= k.x + 18 and g.x >= k.x - 18 then
                        g.dx = g.dx*-1
                    end
                end
            end                        
        end
    else
        for i, k in ipairs(kapoos) do
            if player.colliderBig:enter('ShellKapoo') and not k.shellHit and k.x <= player.x + 10 and k.x >= player.x - 10 then
                local collision_data = player.colliderBig:getEnterCollisionData('ShellKapoo')
                local enemy = collision_data.collider:getObject()
                player.colliderBig:applyLinearImpulse(0, -100)
                k.shellHit = true
                sounds.kick:play()
                k.dx = 0
                k.anim = k.animations.shell
                
                local tempx = k.collider:getX()
                local tempy = k.collider:getY()
                k.collider:destroy()
                k.collider = world:newBSGRectangleCollider(tempx, tempy, 16, 16, 0)
                k.collider:setFixedRotation(true)
                k.collider:setCollisionClass('Enemy')
                k.collider:setObject(k)
                k.x = k.collider:getX() - 8
                k.y = k.collider:getY() - 8
    
                k.collider1:setX(k.collider:getX())
                k.collider1:setY(k.collider:getY() - 5)
    
            elseif player.colliderBig:enter('ShellKapoo') and k.shellHit then
                local collision_data = player.colliderBig:getEnterCollisionData('ShellKapoo')
                local enemy = collision_data.collider:getObject()
                player.colliderBig:applyLinearImpulse(0, -100)
                
                sounds.kick:play()
                k.dx = 150
            end
        end
    
        for i, k in ipairs(kapoos) do
           if k.collider:enter('Enemy') and k.shellHit then
                local collision_data = k.collider:getEnterCollisionData('Enemy')
                local enemy = collision_data.collider:getObject()
                
                for i, g in ipairs(gambus) do
                    if g.x <= k.x + 18 and g.x >= k.x - 18 then
                        g.isDead = true
                    end
                end
                sounds.Squish:play()
            end
        end
    
        for i, k in ipairs(kapoos) do
            if k.collider:enter('Enemy') and not k.shellHit then
                local collision_data = k.collider:getEnterCollisionData('Enemy')
                local enemy = collision_data.collider:getObject()

                k.dx = k.dx*-1
                for i, g in ipairs(gambus) do
                    if g.x <= k.x + 18 and g.x >= k.x - 18 then
                        g.dx = g.dx*-1
                    end
                end
            end                        
        end
    end
    

    for i, g in ipairs(gambus) do
        if g.collider:enter('Platforms') then
            local collision_data = g.collider:getEnterCollisionData('Platforms')
            local wall = collision_data.collider:getObject()
            g.dx = g.dx * -1
        end
    end
    
    for i, k in ipairs(kapoos) do
        if k.collider:enter('Platforms') then
            local collision_data = k.collider:getEnterCollisionData('Platforms')
            local wall = collision_data.collider:getObject()
            k.dx = k.dx * -1
        elseif k.collider:enter('Platforms') and k.shellHit then
            local collision_data = k.collider:getEnterCollisionData('Platforms')
            local wall = collision_data.collider:getObject()
            k.dx = k.dx * -1
        end
    end
end

function spawnCoins(x, y)
    local coin = {}
    coin.x = x
    coin.y = y
    coin.timer = 0
    coin.spriteSheet = love.graphics.newImage('Sprites/coins.png')
    coin.spinGrid = anim8.newGrid( 8, 16, coin.spriteSheet:getWidth(), coin.spriteSheet:getHeight())

    coin.animations = {}
    coin.animations.spin = anim8.newAnimation( coin.spinGrid( '1-4', 1), 0.06)
    coin.anim = coin.animations.spin

    coin.hit = false
    
    table.insert(coins,coin)
end

function spawnBlocks(x, y)
    local block = {}
    block.dx = 245
    block.dy = 240
    block.spriteSheet = love.graphics.newImage('Sprites/question mark.png')
    block.spriteSheet1 = love.graphics.newImage('Sprites/blank block.png')
    block.collider = world:newBSGRectangleCollider(x, y, 16, 2, 0)
    block.collider:setFixedRotation(true)
    block.collider:setType('static')
    block.collider:setCollisionClass('Blocks')
    block.collider:setObject(block)

    block.hit = false
    table.insert(blocks, block)
end

function spawnMushroomBlocks(x, y)
    local block = {}
    block.dx = 245
    block.dy = 240
    block.spriteSheet = love.graphics.newImage('Sprites/question mark.png')
    block.spriteSheet1 = love.graphics.newImage('Sprites/blank block.png')
    block.collider = world:newBSGRectangleCollider(x, y, 16, 2, 0)
    block.collider:setFixedRotation(true)
    block.collider:setType('static')
    block.collider:setCollisionClass('MushroomBlocks')
    block.collider:setObject(block)

    block.hit = false
    table.insert(mushroomBlocks, block)
end

function spawnGambu( x, y)
    local gambu = {}
    gambu.dx = 20
    gambu.dy = 0
    gambu.timer = 0
    gambu.spriteSheet = love.graphics.newImage('Sprites/gambu.png')
    gambu.grid = anim8.newGrid( 16, 16, gambu.spriteSheet:getWidth(), gambu.spriteSheet:getHeight())
    
    gambu.animations = {}
    gambu.animations.moving = anim8.newAnimation( gambu.grid( '1-2', 1), 0.1)
    gambu.animations.dead = anim8.newAnimation( gambu.grid( "3-1", 1), 0.06)
    gambu.anim = gambu.animations.moving

    gambu.collider = world:newBSGRectangleCollider(x, y, 16, 16, 0)
    gambu.collider:setFixedRotation(true)
    gambu.collider:setCollisionClass('Enemy')
    gambu.collider:setObject(gambu)

    gambu.collider1 = world:newBSGRectangleCollider(x, y, 16, 1, 0)
    gambu.collider1:setType('static')
    gambu.collider1:setFixedRotation(true)
    gambu.collider1:setCollisionClass('KillGambu')
    gambu.collider1:setObject(gambu)

    gambu.isDead = false
    gambu.deathAnimDone = false
    table.insert(gambus, gambu)
end

function spawnKapoos(x, y)
    local kapoo = {}
    kapoo.dx = 20
    kapoo.dy = 0
    kapoo.timer = 0
    kapoo.spriteSheet = love.graphics.newImage('Sprites/kapoo.png')
    kapoo.walkGrid = anim8.newGrid( 16, 24, kapoo.spriteSheet:getWidth(), kapoo.spriteSheet:getHeight())
    kapoo.shellGrid = anim8.newGrid( 16, 16, kapoo.spriteSheet:getWidth(), kapoo.spriteSheet:getHeight(), 0, 8)

    kapoo.animations = {}
    kapoo.animations.moving = anim8.newAnimation( kapoo.walkGrid( '1-2', 1), 0.1)
    kapoo.animations.shell = anim8.newAnimation( kapoo.shellGrid( '4-3', 1), 0.1)
    kapoo.anim = kapoo.animations.moving

    kapoo.collider = world:newBSGRectangleCollider(x, y, 16, 24, 0)
    kapoo.collider:setFixedRotation(true)
    kapoo.collider:setCollisionClass('Enemy')
    kapoo.collider:setObject(kapoo)

    kapoo.collider1 = world:newBSGRectangleCollider(x, y, 16, 1, 0)
    kapoo.collider1:setType('static')
    kapoo.collider1:setFixedRotation(true)
    kapoo.collider1:setCollisionClass('ShellKapoo')
    kapoo.collider1:setObject(kapoo)

    kapoo.isDead = false
    kapoo.shellHit = false
    table.insert(kapoos, kapoo)
end

function spawnMushroom(x, y)
    local mushroom = {}
    mushroom.dx = 0
    mushroom.dy = 0
    mushroom.timer = 0
    mushroom.spriteSheet = love.graphics.newImage('Sprites/mushroom.png')

    mushroom.collider = world:newBSGRectangleCollider(x, y, 16, 16, 0)
    mushroom.collider:setFixedRotation(true)
    mushroom.collider:setCollisionClass('Mushroom')
    mushroom.collider:setObject(mushroom)

    mushroom.hit = false
    mushroom.spawn = false
    
    table.insert(mushrooms, mushroom)
end