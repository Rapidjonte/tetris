local shake = {
    time = 0,
    duration = 0.3,
    strength = 5,
    active = false
}

function startShake(duration, strength)
    shake.time = duration or 0.3
    shake.duration = shake.time
    shake.strength = strength or 5
    shake.active = true
end

function updateShake(dt)
    if shake.active then
        shake.time = shake.time - dt
        if shake.time <= 0 then
            shake.active = false
        end
    end
end

function getShakeOffset()
    if shake.active then
        local t = shake.time / shake.duration
        local s = shake.strength * t
        return love.math.random(-s, s), love.math.random(-s, s)
    else
        return 0, 0
    end
end
