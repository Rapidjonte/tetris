local Timer = Class:extend()

function Timer:new(duration, repeated, func)
	self.duration = duration
	self.repeated = repeated or false
	self.func = func or nil

	self.time = 0
	self.active = false
	self.finished = false
end

function Timer:activate()
	self.active = true
	self.time = 0
	self.finished = false
end

function Timer:deactivate()
	self.active = false
	self.finished = true
end

function Timer:update(dt)
	if self.active then
		self.time = self.time + dt
		if self.time >= self.duration then
			if self.func and self.time ~= 0 then
				self.func()
			end

			self:deactivate()

			if self.repeated then
				self:activate()
			end
		end
	end
end

return Timer