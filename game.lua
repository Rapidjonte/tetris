return {
	enter = function(dt)
		level = 0
		score = 0
		softDrops = 0
		total_lines = 0
		lines_to_next = 10

		if shaders then
			if blurring then
				blurring:stop()
			end
			effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt).chain(moonshine.effects.chromasep).chain(moonshine.effects.desaturate).chain(moonshine.effects.boxblur)
			effect.chromasep.radius = 2
			effect.chromasep.angle = 2
			effect.desaturate.strength = 0.2
			effect.crt.scaleFactor = 1
			effect.scanlines.frequency = ROWS*10
			effect.scanlines.thickness = 0.5
			effect.scanlines.opacity = 0.2
			flashes = {}
			explosions = {}
			local a = { x = 500, y = 0}
			effect.boxblur.radius={a.x,a.y}
			blurring = flux.to(a, 0.1, { x = 0, y = 0 })
		        :ease("quartout")
		        :onupdate(function()
		       		effect.boxblur.radius = {a.x,a.y}
		        end)
		end

		DAS = 0
		frames_delayed = 0
		spawning = true

		next_piece = ""
		next_tetromino = nil

		delete_rows = {}
		function createGrid(columns, rows)
		    local grid = {}
		    for y = 1, rows do
		        grid[y] = {}
		        for x = 1, columns do
		            grid[y][x] = 0
		        end
		    end
		    return grid end
		field_data = createGrid(COLUMNS, ROWS)
		tetrominos = {}
		current = nil

		timers = { 
			timer(UPDATE_START_SPEED, true, function() if current then current:move_down() end end),
			timer(frameTime), --	[2] auto shift 
			timer(frameTime), --	[3] entry delay
			timer(frameTime), --	[4] auto shift 2
			timer(frameTime*86), --	[5] opening entry delay
			timer(frameTime), -- 	[6] a release cooldown
			timer(frameTime), -- 	[7] a release cooldown
		}
		timers[1]:activate()
		timers[5]:activate()

		soft_drop_hold_time = 0

		a_ready = true
		b_ready = true
		down_ready = false

		function update_fall_speed()
			if level < 30 then
				UPDATE_START_SPEED = speeds[level]
			else
				UPDATE_START_SPEED = speeds[29]
			end
			timers[1].duration = UPDATE_START_SPEED end
		update_fall_speed()

		function update_level(lines_cleared)
			total_lines = total_lines + lines_cleared
			lines_to_next = lines_to_next - lines_cleared

			while lines_to_next <= 0 do
				play(levelup)
				level = level + 1
				lines_to_next = lines_to_next + 10
				if level == 235 then
					lines_to_next = lines_to_next + 800
				end
				if level > 255 then
					level = 0
				end
				update_fall_speed()
			end end

		function check_finished_rows()
			delete_rows = {}
			for y = 1, #field_data do
				local filled = true
				for x = 1, #field_data[y] do
			        if field_data[y][x] == 0 then
			            filled = false
			            break
			        end
			    end
			    if filled then
			    	table.insert(delete_rows, y-1)
			    end
			end

			if #delete_rows > 0 then
				table.sort(delete_rows)

				local function find(t, value)
				    for _, v in ipairs(t) do
				        if v == value then return true end
				    end
				    return false
				end

				local tetrominos_to_remove = {}
				for _, tetromino in ipairs(tetrominos) do
				    local i = 1
				    while i <= #tetromino.blocks do
				        local block = tetromino.blocks[i]

				        if find(delete_rows, block.y) then
				            table.remove(tetromino.blocks, i)
				            field_data[block.y+1][block.x+1] = field_data[block.y+1][block.x+1] - 1
				      	else
				      		local offset = 0
								for _, row in ipairs(delete_rows) do
									if block.y < row then
										offset = offset + 1
									end
								end

								if offset > 0 then
									field_data[block.y + 1][block.x + 1] = field_data[block.y + 1][block.x + 1] - 1
									block.y = block.y + offset
									field_data[block.y + 1][block.x + 1] = field_data[block.y + 1][block.x + 1] + 1
								end

				      			i = i + 1
				      	end
				    end
				    if #tetromino.blocks == 0 then
				    	table.insert(tetrominos_to_remove, _)
				    end
				end
				for i = #tetrominos_to_remove, 1, -1 do
				    table.remove(tetrominos, tetrominos_to_remove[i])
				end

				score = score + SCORE_DATA[#delete_rows] * (level+1)
				if shaders then
					local textToShow = ""
					if #delete_rows == 1 then
						textToShow = " " .. #delete_rows .. " LINE CLEARED!"
					else
						textToShow = #delete_rows .. " LINES CLEARED!"
					end
					table.insert(flashes, flashtext.new(
			            textToShow, 
			            GAME_WIDTH/2, 
			            GAME_HEIGHT/2,
			            {.3, .7, .7},
			            font,
			            true
		        	))
	        	end
	        	if not (#delete_rows > 3) then
	        		play(clear)
	        	else
	        		play(tetris)
	        	end
			end 

			score = score + softDrops
			if shaders then
				local scoreToShow = softDrops
				if #delete_rows > 0 then
					scoreToShow = scoreToShow + SCORE_DATA[#delete_rows] * (level+1)
				end
					if scoreToShow > 0 then
					table.insert(flashes, flashtext.new(
			            "+" .. scoreToShow, 
			            GAME_WIDTH+13, 
			            GAME_HEIGHT-GAME_HEIGHT*SCORE_HEIGHT_FRACTION+97,
			            {.3, .3, .7},
			            font
		        	))
		        end
	        end
			softDrops = 0

			update_level(#delete_rows) end

		function b_pressed()
			return love.keyboard.isDown("a") or (activeJoystick and activeJoystick:isGamepadDown("dpleft")) end

		function a_pressed()
			return love.keyboard.isDown("d") or (activeJoystick and activeJoystick:isGamepadDown("dpright")) end

		function down_pressed()
			return love.keyboard.isDown("s") or (activeJoystick and activeJoystick:isGamepadDown("dpdown")) end

		function left_pressed()
			return love.keyboard.isDown("left") or (activeJoystick and activeJoystick:isGamepadDown("x")) end

		function right_pressed()
			return love.keyboard.isDown("right") or (activeJoystick and activeJoystick:isGamepadDown("b")) end
	end,
	
	update = function(dt)
		for i, timer in ipairs(timers) do
			if not (i == 1 and timers[5].active) then
				timer:update(dt)
			end
		end
		if timers[6].finished then
			a_ready = true
			timers[6].finished = false
		end
		if timers[7].finished then
			b_ready = true
			timers[7].finished = false
		end

		if spawning and not timers[3].active then
			if #delete_rows > 0 then ENTRY_DELAY = 18 else ENTRY_DELAY = 10 end
			if frames_delayed < ENTRY_DELAY then
				frames_delayed = frames_delayed + 1
				timers[3]:activate()
			else
				Tetromino:spawn()
				spawning = false
				frames_delayed = 0
			end
		end
		if down_pressed() and down_ready and not (b_pressed() or a_pressed()) and current then
			if soft_drop_hold_time >= frameTime * 3 then
				UPDATE_START_SPEED = speeds[19]
				timers[1].duration = UPDATE_START_SPEED
			else
				soft_drop_hold_time = soft_drop_hold_time + dt
				update_fall_speed()
			end
		else
			soft_drop_hold_time = 0
			update_fall_speed()
		end
		if a_pressed() and a_ready and not down_pressed() and current then
			if timers[2].active == false then 
				DAS = DAS + 1
				if DAS == -1 then DAS = 0 end
				if DAS >= 16 and current then
					current:move_horizontal(1) 
					if current:next_move_horizontal_collide(1) then DAS = 16 else DAS = 10 end
				end
				timers[2]:activate()
			end
		elseif b_pressed() and b_ready and not down_pressed() and current then
			if timers[4].active == false then 
				DAS = DAS + 1
				if DAS >= 16 and current then
					current:move_horizontal(-1) 
					if current:next_move_horizontal_collide(-1) then DAS = 16 else DAS = 10 end
				end
				timers[4]:activate()
			end
		end
	end,
	
	draw = function()
		if shaders then
			for i = 1, 20, 1 do
				love.graphics.setColor((1-i/20)*0.5, (1-i/20)*0.5, (1-i/20)*0.5)
				love.graphics.rectangle("line", 10*i, 10*i, GAME_WIDTH-20*i, GAME_HEIGHT-20*i)
			end
			if current then
				love.graphics.setBlendMode("lighten", "premultiplied")
				for _, block in ipairs(current.blocks) do
					local i = -1
					while not block:vertical_collide(i) do
						i = i + 1
					end
					if (block.color == "v1") then
						love.graphics.setColor(colorHEX(colors[level+1][1]))
					elseif (block.color == "v2") then
						love.graphics.setColor(colorHEX(colors[level+1][3]))
					elseif (block.color == "v3") then
						love.graphics.setColor(colorHEX(colors[level+1][5]))
					end
					local c1,c2,c3 = love.graphics.getColor()
					love.graphics.setColor(c1*0.1,c2*0.1,c3*0.1)
					if i > 0 then
						love.graphics.rectangle("fill", block.x*CELL_SIZE, block.y*CELL_SIZE, CELL_SIZE, CELL_SIZE*i)
					end
				end
				love.graphics.setBlendMode("alpha")
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
	end,

	input = function(key)
		if key == "r" then
			GameState.set("game")
		elseif current then
			if key == "right" then
				current:rotate(-1) 
			end
			if key == "left" then
				current:rotate(1) 
			end
			if key == "d" and a_ready and not timers[2].active and not down_pressed() then
				if not timers[3].active then
					if current:next_move_horizontal_collide(1) then DAS = 16 else DAS = -1 end
				end
				current:move_horizontal(1)
				timers[2]:activate()
			elseif key == "a" and b_ready and not timers[4].active and not down_pressed() then
				if not timers[3].active then
					if current:next_move_horizontal_collide(-1) then DAS = 16 else DAS = -1 end
				end
				if not a_pressed() then
					current:move_horizontal(-1)
				end
				timers[4]:activate()
			end
			if key == "s" then
				if timers[5].active then
					timers[5]:deactivate()
				end
				down_ready = true
			end
		end
	end,

	released = function(key)
		if key == "d" then
			a_ready = false
			timers[6]:activate()
		elseif key == "a" then
			b_ready = false
			timers[7]:activate()
		end
	end
}