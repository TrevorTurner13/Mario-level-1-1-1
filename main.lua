function love.load()
    player = {}
    player.x = 400
    player.y = 200
    player.speed = 5
    player.spriteSheet = love.graphics.newImage('Sprites/Mario.png')
    

end

function love.update(dt)
    if love.keyboard.isDown("d") then
         player.x = player.x + player.speed
    end

    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
   end

   if love.keyboard.isDown("s") then
    player.y = player.y + player.speed
end

if love.keyboard.isDown("w") then
    player.y = player.y - player.speed
end
end

function love.draw()
    love.graphics.draw(player.sprite, player.x, player.y)

end