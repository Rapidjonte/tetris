return {
	enter = function()
		removeOne = function()
			table.insert(explosions, ParticleExplosion.new(tetrominos[#tetrominos].blocks[1].x*CELL_SIZE, tetrominos[#tetrominos].blocks[1].y*CELL_SIZE, 4))
			table.remove(tetrominos, #tetrominos)
		end

		if shaders then
			effect = effect.chain(moonshine.effects.pixelate).chain(moonshine.effects.godsray)
			local a = { a = 20}
			pixeling = flux.to(a, 6, { a = 0.0001 })
		        :ease("quartout")
		        :onupdate(function()
		       		effect.pixelate.size = {a.a,0.0001}
		        end)
		end

		play(death)
		removerTimer = timer(0.1, true, function() removeOne() end)
		removerTimer:activate()

		end_score = score
		end_level = level
		end_lines = total_lines
	end,	
	
	update = function(dt)
		if #tetrominos > 0 then 
			removerTimer:update(dt)
		end
	end,
	
	draw = function()
		if shaders then
			for i = 1, 20, 1 do
				love.graphics.setColor((1-i/20)*0.5, (1-i/20)*0.5, (1-i/20)*0.5)
				love.graphics.rectangle("line", 10*i, 10*i, GAME_WIDTH-20*i, GAME_HEIGHT-20*i)
			end
		else
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("line", 0,0, GAME_WIDTH, GAME_HEIGHT)
		end
		love.graphics.setColor(.1, .1, .1)
		love.graphics.rectangle("fill", GAME_WIDTH, 0, SIDEBAR_WIDTH, GAME_HEIGHT)
		
		if next_tetromino then
			next_tetromino:draw()
		end

		love.graphics.setColor(1,1,1)
		love.graphics.printf("SCORE:               " .. score, font, GAME_WIDTH+13, GAME_HEIGHT-GAME_HEIGHT*SCORE_HEIGHT_FRACTION, SIDEBAR_WIDTH*2-50, left, 0, 0.5)
		
		--[[
		love.graphics.setColor(.2, .2, .2)
		for i = COLUMNS, 0, -1 do
			love.graphics.line(i*CELL_SIZE, 0, i*CELL_SIZE, GAME_HEIGHT)
		end
		for i = ROWS, 0, -1 do
			love.graphics.line(0, i*CELL_SIZE, GAME_WIDTH, i*CELL_SIZE)
		end
		]]--
		
		for _, tetromino in ipairs(tetrominos) do
			tetromino:draw()
		end

		if #tetrominos == 0 then
			local w, h = 490, 200
		    local x = (GAME_WIDTH + SIDEBAR_WIDTH - w) / 2
		    local y = (GAME_WIDTH - h) / 2 + 320
		    love.graphics.setColor(0.7,0.7,1,0.1)
			love.graphics.rectangle("fill", x-10, y-16, w+10, h, 20)

			love.graphics.setFont(smallerFont)
			love.graphics.setColor(0.5,0.5,1)
			love.graphics.printf("Press R to restart", 0, GAME_HEIGHT/2 - love.graphics.getFont():getHeight()/2, GAME_WIDTH+SIDEBAR_WIDTH, "center")

			love.graphics.setFont(smallestFont)
			love.graphics.printf("Score: " .. end_score, x+40, y + h/2 - love.graphics.getFont():getHeight()/2-20, w, "left")
			love.graphics.printf("Lines: " .. end_lines, x+40, y + h/2 - love.graphics.getFont():getHeight()/2+10, w, "left")
			love.graphics.printf("Level: " .. end_level, x+40, y + h/2 - love.graphics.getFont():getHeight()/2+40, w, "left")

			love.graphics.setFont(font)
		end
	end,

	input = function(key)
		if key == "r" then
			if pixeling then
				pixeling:stop()
			end
			GameState.set("game")
		end
	end
}