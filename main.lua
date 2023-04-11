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

    local isMoving = false
    local isMovingLeft = false

end

function love.update(dt)
    isMoving = false
    

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
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, -5, 5)
    else
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 5, 5)
    end
end