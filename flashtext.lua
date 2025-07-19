local flux = require "flux"

local FlashText = {}
FlashText.__index = FlashText

function FlashText.new(text, x, y, color, font, static)
    local self = setmetatable({}, FlashText)

    self.static = static or false

    self.text = text
    self.x = x
    self.y = y
    self.startY = y
    self.alpha = 1
    self.size = 0.7
    self.scale = 0.3*self.size
    self.color = color or {1, 1, 1}
    self.font = font or love.graphics.getFont()
    self.dead = false
    self.rotation = 0

    local lifetime = 0.6
    if not static then
        self.rotation = math.random() * math.pi * 2 / 100
        flux.to(self, 0.3, { scale = 1.2*self.size }):ease("backout")
        flux.to(self, lifetime, { y = y - 20}):delay(0.2)
    else
        self.alpha = 0
        flux.to(self, 0.1, {alpha = 1 })
        self.scale = 0.8
        self.x = self.x - 220
        lifetime = 1
    end
    flux.to(self, lifetime, {alpha = 0 }):delay(0.2):oncomplete(function()
        self.dead = true
    end)

    return self
end

function FlashText:draw()
    love.graphics.setFont(self.font)
    local t = love.timer.getTime() * 50
    local pulse = 0.5 + 0.5 * math.sin(t)
    love.graphics.setColor(
        self.color[1] + (1 - self.color[1]) * pulse,
        self.color[2] + (1 - self.color[2]) * pulse,
        self.color[3] + (1 - self.color[3]) * pulse,
        self.alpha
    )
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)
    if self.static then
        love.graphics.scale(self.scale, self.scale*2)
    else
        love.graphics.scale(self.scale, self.scale)
    end
    love.graphics.print(self.text, 0, 0)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return FlashText