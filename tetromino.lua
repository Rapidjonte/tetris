local Tetromino = Class:extend()

function Tetromino:new(shape, x, y, size)
	self.shape = shape
    self.block_positions = TETROMINOS[shape].shape
    self.i = #tetrominos+1

    if size == nil then
    	self.size = 1
    else
		self.size = size
    end

    self.blocks = {}
    for i, pos in ipairs(self.block_positions) do
        local _x, _y = pos[1], pos[2]
        local block = Block(x + _x, y + _y, TETROMINOS[shape].color, self.size)
        table.insert(self.blocks, block)
    end

    return self
end

function Tetromino:spawn()
	local letters = {}
    for letter, _ in pairs(TETROMINOS) do
        table.insert(letters, letter)
    end
	math.randomseed(os.clock() * 1e9)

	if next_piece == "" then
		next_piece = letters[math.random(#letters)]
	end

	table.insert(tetrominos, (Tetromino(next_piece, math.floor(COLUMNS/2), 0)))
	next_piece = letters[math.random(#letters)]
	if next_piece == "I" then
		next_tetromino = Tetromino(next_piece, 15, 13.5,0.8)
	elseif next_piece == "O" then
		next_tetromino = Tetromino(next_piece, 15, 13,0.8)
	else
		next_tetromino = Tetromino(next_piece, 14.5, 13,0.8)
	end

	timers[1].time = 0
	current = tetrominos[#tetrominos]
	down_ready = false
	softDrops = 0
	if current:next_move_vertical_collide(0) then
		GameState.set("death")
	end
end

function Tetromino:draw()
	for _, i in ipairs(self.blocks) do
		i:draw()
	end
end

function Tetromino:move_horizontal(amount)
	if (self:next_move_horizontal_collide(amount) == false) then
		for _, i in ipairs(self.blocks) do
			i.x = i.x+amount
		end
		play(move)

		if shaders then
			local strength = 0
			if level < 30 then
				strength = speeds[level]
			else
				strength = speeds[29]
			end
			local blur = { radius_x = 35 + strength * 1.5 }
			flux.to(blur, 0.1, { radius_x = 0 })
		        :ease("quadout")
		        :onupdate(function()
		            effect.boxblur.radius_x = blur.radius_x
		        end)
		end
	end
end

function Tetromino:move_down()
	if not self:next_move_vertical_collide(1) then
		for _, i in ipairs(self.blocks) do
			i.y = i.y+1
		end
		if down_pressed() and down_ready then
			softDrops = softDrops+1
		end
	else
		for _, block in ipairs(self.blocks) do
			if field_data[block.y+1] and field_data[block.y+1][block.x+1] ~= nil then
				field_data[block.y+1][block.x+1] = field_data[block.y+1][block.x+1]+1
			end
		end

		if shaders then
			local strength = 0
			if level < 30 then
				strength = speeds[level]
			else
				strength = speeds[29]
			end
			local blur = { radius_y = 40 + strength * 1.5 }
			flux.to(blur, 0.6, { radius_y = 0 })
		        :ease("quadout")
		        :onupdate(function()
		            effect.boxblur.radius_y = blur.radius_y
		        end)
		    startShake(0.4, 2 + strength * 1.5)

		    table.insert(explosions, ParticleExplosion.new(self.blocks[1].x*CELL_SIZE, self.blocks[1].y*CELL_SIZE, 25))
		end

		play(land)
		check_finished_rows()
		spawning = true
		timers[3]:activate()
		current = nil
	end
end

function Tetromino:next_move_horizontal_collide(amount)
	collision_list = {}
	for _, block in ipairs(self.blocks) do
		table.insert(collision_list, block:horizontal_collide(amount))
	end
	for _, v in ipairs(collision_list) do
	    if v == true then
	        return true
	    end
	end
	return false
end

function Tetromino:next_move_vertical_collide(amount)
	collision_list = {}
	for _, block in ipairs(self.blocks) do
		table.insert(collision_list, block:vertical_collide(amount))
	end
	for _, v in ipairs(collision_list) do
	    if v == true then
	        return true
	    end
	end
	return false
end

function Tetromino:rotate(amount)
	if self.shape ~= "O" then
		local pivot_pos = self.blocks[1]
		
	    for i, block in ipairs(self.blocks) do
	    	block:rotate(pivot_pos, 1 * amount)
	   	end 

	   	if self:next_move_vertical_collide(0) or self:next_move_horizontal_collide(0) then
	   		for i, block in ipairs(self.blocks) do
	    		block:rotate(pivot_pos, -1 * amount)
	   		end 
	   	else
	   		play(rotate)
	   	end
	end
end

return Tetromino