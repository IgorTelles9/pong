push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
	love.graphics.setDefaultFilter('nearest', 'nearest')

	love.window.setTitle('Pong')

	math.randomseed(os.time())
	-- retro font for any text
	smallFont = love.graphics.newFont('font.ttf', 8)
	-- larger font for write the winning message
	largeFont = love.graphics.newFont('font.ttf', 16)
	-- larger font for drawing the score
	scoreFont = love.graphics.newFont('font.ttf', 32)
	love.graphics.setFont(smallFont)

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
		['clapping'] = love.audio.newSource('sounds/clapping.mp3', 'static')
	}

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
	fullscreen = false,
	resizable = true,
	vsync = true
	})

	player1Score = 0 
	player2Score = 0

	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	ball = Ball(VIRTUAL_WIDTH/ 2 -2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	gameState = 'start'
end

function love.resize(w, h)
	push:resize(w, h)

end

function love.update(dt)
	if gameState == 'serve' then
		-- before switching to play, initialize ball's velocity based on
		-- player who last scored
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end

	elseif gameState == 'play' then

		if chanceOfError == 1 then
			player1.y = ball.y + 5
		else
			player1.y = ball.y
		end

		--detec ball collision with paddle, reversing dx if true and
		-- slightly increasing it, then altering the dy base on the pos 
		if ball:colides(player1) then
			ball.dx = -ball.dx *1.03
			ball.x = player1.x + 5
			chanceOfError = math.random(1,10)

			--keep velocity going in the same direction, but randomize it
			if ball.dy < 0 then 
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		if ball:colides(player2) then
			ball.dx = -ball.dx*1.03
			ball.x = player2.x - 4
			chanceOfError = math.random(1,10)

			if ball.dy < 0 then 
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		-- detect upper and lower screen boundary collision and reverse
		-- dy when it colides
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
			sounds['wall_hit']:play()
		end

		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy 
			sounds['wall_hit']:play()
		end

		-- scoring 
		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			sounds['score']:play()

			--if we've reached the match score, the game is over
			--so we set the state to done so we can show a victory msg
			if player2Score == 5 then
				winningPlayer = 2
				sounds['clapping']:play()
				gameState = 'done'
			else 
				gameState = 'serve'
				ball:reset()
			end		
		end

		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			sounds['score']:play()
			
			--same from above
			if player1Score == 5 then
				sounds['clapping']:play()
				winningPlayer = 1
				gameState = 'done'
			else 
				gameState = 'serve'
				ball:reset()
			end
		end
	end

	--player 1 move
	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED

	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED 


	else
		player1.dy = 0

	end
	
	--player 2 move
	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED

	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED

	else

		player2.dy = 0

	end

	--update our ball based on its DX ad DY only if we're in play state;
	if gameState == 'play' then
		ball:update(dt)
	end

	player1:update(dt)
	player2:update(dt)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()

	elseif key == 'enter' or key == 'return' then
		-- if the game is in the start state so change it to the serve state
		if gameState == 'start' then
			-- randomize who's serving then change the state
			servingPlayer = math.random(1,2)
			gameState = 'serve'
		-- if the game is in the serve state so change it to the game state
		elseif gameState == 'serve' then
			gameState = 'play'
		-- if the is in the done state so restart the match, going back to the serve state
		elseif gameState == 'done' then
			gameState = 'serve'

			ball:reset()

			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end
		end
	end
end

function love.draw()

	push:apply('start')
	
	love.graphics.clear(0, 0, 0, 255)

	if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Bem vindo ao Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Pressione Enter para iniciar!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Saque do jogador ' .. tostring(servingPlayer) .. "!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Pressione Enter para sacar!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('O jogador ' .. tostring(winningPlayer) .. ' venceu!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Pressione Enter para uma revanche!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

	displayScore()

	--rendering paddles
	player1:render()
	player2:render()

	--rendering ball
	ball:render()

	--displaying fps
	--displayFPS()

	push:apply('end')
end

function displayScore()
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
		VIRTUAL_HEIGHT / 3)
	love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 50,
		VIRTUAL_HEIGHT / 3)
end

function displayFPS()
	-- simple FPS display 
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end