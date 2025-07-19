local Block = Class:extend()

function colorHEX(rgba)
	local rb = tonumber(string.sub(rgba, 2, 3), 16) 
	local gb = tonumber(string.sub(rgba, 4, 5), 16) 
	local bb = tonumber(string.sub(rgba, 6, 7), 16)
	local ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
	return love.math.colorFromBytes( rb, gb, bb, ab )
end

function Block:new(x,y,c)
	self.color = c
	self.x = x
	self.y = y
	return self
end

function Block:draw()
	local x,y=self.x,self.y
	if (self.color == "v1") then
		love.graphics.setColor(colorHEX(colors[level+1][1]))
		love.graphics.draw(v1b, x*CELL_SIZE, y*CELL_SIZE, 0, CELL_SIZE/8)
		love.graphics.setColor(colorHEX(colors[level+1][2]))
		love.graphics.draw(v1h,x*CELL_SIZE, y*CELL_SIZE, 0, CELL_SIZE/8)
	elseif (self.color == "v2") then
		love.graphics.setColor(colorHEX(colors[level+1][3]))
		love.graphics.draw(v2b, x*CELL_SIZE, y*CELL_SIZE, 0, CELL_SIZE/8)
		love.graphics.setColor(colorHEX(colors[level+1][4]))
		love.graphics.draw(v2h,x*CELL_SIZE, y*CELL_SIZE, 0, CELL_SIZE/8)
	elseif (self.color == "v3") then
		love.graphics.setColor(colorHEX(colors[level+1][5]))
		love.graphics.draw(v2b, x*CELL_SIZE, y*CELL_SIZE, 0, CELL_SIZE/8)
		love.graphics.setColor(colorHEX(colors[level+1][6]))
		love.graphics.draw(v2h, x*CELL_SIZE, y*CELL_SIZE, 0, CELL_SIZE/8)
	end
end

function Block:horizontal_collide(amount)
	if self.x+amount < 0 or self.x+amount >= COLUMNS then
    	return true
	end
	if field_data[self.y+1] and field_data[self.y+1][self.x+1+amount] ~= nil and field_data[self.y+1][self.x+1+amount] > 0 then
		return true
	end
	return false
end

function Block:vertical_collide(amount)
	if self.y+amount >= ROWS then
    	return true
	end
	if field_data[self.y+1+amount] and field_data[self.y+1+amount][self.x+1] ~= nil and field_data[self.y+1+amount][self.x+1] > 0 then
		return true
	end
	return false
end

function Block:rotate(pivot, amount)
	local dx = self.x - pivot.x
    local dy = self.y - pivot.y

    local rotated_x = dy * amount
    local rotated_y = -dx * amount

    self.x = pivot.x + rotated_x
    self.y = pivot.y + rotated_y
end

return Block