return {
	enter = function()
		removeOne = function()
			table.remove(tetrominos, #tetrominos)
		end

		removerTimer = timer(0.1, true, function() removeOne() end)
		removerTimer:activate()
	end,	
	
	update = function(dt)
		if #tetrominos > 0 then 
			removerTimer:update(dt)
		end
	end,
	
	draw = function()
		love.graphics.setColor(.1, .1, .1)
		love.graphics.rectangle("fill", GAME_WIDTH, 0, SIDEBAR_WIDTH, GAME_HEIGHT)
		
		if shaders then
			for i = 1, 20, 1 do
				love.graphics.setColor((1-i/20)*0.5, (1-i/20)*0.5, (1-i/20)*0.5)
				love.graphics.rectangle("line", 10*i, 10*i, GAME_WIDTH-20*i, GAME_HEIGHT-20*i)
			end
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
	end,

	input = function(key)
		if key == "r" then
			GameState.set("game")
		end
	end
}