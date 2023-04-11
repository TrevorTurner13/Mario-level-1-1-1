function love.load()
    anim8 = require 'Libraries.anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 400
    player.y = 200
    player.speed = 5
    player.spriteSheet = love.graphics.newImage('Sprites/Mario.png')
    player.grid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.right = anim8.newAnimation( player.grid( '4-1', 1), 0.06)

    player.anim = player.animations.right

    PLAYERHITBOX = {
        x = 0,
        y = 0,
        width = 16,
        height = 16,
        speed = 90
    }

    local isMoving = false
    local isMovingLeft = false


end

function love.update(dt)
    isMoving = false
    
    PLAYERHITBOX.x = player.x
    PLAYERHITBOX.y = player.y

    
    if love.keyboard.isDown("d") then
         player.x = player.x + player.speed
         player.anim = player.animations.right
         isMoving = true
         isMovingLeft = false
    end

    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
        player.anim = player.animations.right
        isMoving = true
        isMovingLeft = true
   end

   if love.keyboard.isDown("s") then
        player.y = player.y + player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame(4)
    end

    player.anim:update(dt)
end

function love.draw()
    if isMovingLeft then 
        player.anim:draw(player.spriteSheet, player.x + 60, player.y, nil, -5, 5)
    else
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 5, 5)
    end

    love.graphics.rectangle("fill", PLAYERHITBOX.x + 2, PLAYERHITBOX.y - 1, 32, 32)
end

function checkCollision(a, b)
    a_left = a.x
    a_right = a.x + a.width
    a_top = a.y
    a_bottom = a.y + a.height

    b_left = b.x
    b_right = b.x + b.width
    b_top = b.y
    b_bottom = b.y + b.height

    --If Red's right side is further to the right than Blue's left side.
    if  a_right > b_left
    --and Red's left side is further to the left than Blue's right side.
    and a_left < b_right
    --and Red's bottom side is further to the bottom than Blue's top side.
    and a_bottom > b_top
    --and Red's top side is further to the top than Blue's bottom side then..
    and a_top < b_bottom then
        --There is collision!
        return true
    else
        --If one of these statements is false, return false.
        return false
    end
end