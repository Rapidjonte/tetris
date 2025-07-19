local ParticleExplosion = {}
ParticleExplosion.__index = ParticleExplosion

local GRAVITY = 400

function ParticleExplosion.new(x, y, count)
    local self = setmetatable({}, ParticleExplosion)
    self.particles = {}

    for i = 1, count or 20 do
        local angle = math.random() * math.pi * 2
        local speed = math.random(10, 400)
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed

        table.insert(self.particles, {
            x = x,
            y = y,
            vx = vx,
            vy = vy,
            size = math.random(10, 20),
            rot = math.random() * math.pi * 2,
            rotSpeed = math.random() * 4 - 2,
            life = 0,
            maxLife = 2 + math.random() * 0.3,
            color = {colorHEX(colors[level+1][math.random(1, 3)])}
        })
    end

    self.dead = false
    return self
end

function ParticleExplosion:update(dt)
    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.life = p.life + dt
        if p.life > p.maxLife then
            table.remove(self.particles, i)
        else
            p.vy = p.vy + GRAVITY * dt

            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.rot = p.rot + p.rotSpeed * dt
        end
        if p.y > GAME_HEIGHT-9 then p.vy = -p.vy * 0.7 end
    end

    if #self.particles == 0 then
        self.dead = true
    end
end

function ParticleExplosion:draw()
    for _, p in ipairs(self.particles) do
        local alpha = 1 - (p.life / p.maxLife)
        love.graphics.setColor(p.color[1]+0.3, p.color[2]+0.3, p.color[3]+0.3, alpha)

        love.graphics.push()
        love.graphics.translate(p.x, p.y)
        love.graphics.rotate(p.rot)
        love.graphics.rectangle("fill", -p.size / 2, -p.size / 2, p.size, p.size)
        love.graphics.pop()
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return ParticleExplosion