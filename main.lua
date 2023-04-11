function love.load()
    anim8 = require 'Libraries.anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'Libraries/sti'
    gameMap = sti('Maps/')

    player = {}
    player.x = 400
    player.y = 400
    player.speed = 5
    player.spriteSheet = love.graphics.newImage('Sprites/Mario.png')
    player.smallMarioGrid = anim8.newGrid( 16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.bigMarioGrid = anim8.newGrid(16, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight(), 0, 16)

    player.animations = {}
    player.animations.right = anim8.newAnimation( player.smallMarioGrid( '4-1', 1), 0.06)
    player.animations.jump = anim8.newAnimation( player.smallMarioGrid( '6-1 ', 1), 0.06)
    

    player.anim = player.animations.right

    local isMoving = false
    local isMovingLeft = false
    local isJumping = false

    player.ground = player.y     -- This makes the character land on the plaform.

	player.y_velocity = 0        -- Whenever the character hasn't jumped yet, the Y-Axis velocity is always at 0.

	player.jump_height = -500    -- Whenever the character jumps, he can reach this height.
	player.gravity = -700        -- Whenever the character falls, he will descend at this rate.

end

function love.update(dt)
    isMoving = false
    isJumping = false
    

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
        player.anim = player.animations.right
        if not isJumping then
            isMoving = true
            isMovingLeft = false
        end
    end

    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
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
end

function love.draw()
    if isMovingLeft then 
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, -5, 5)
    else
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 5, 5)
    end
end