local flux = require("flux")

local MusicManager = {}
MusicManager.__index = MusicManager

function MusicManager:new(songPlaying, songDead)
    local self = setmetatable({}, MusicManager)

    local s1 = love.audio.newSource(songPlaying, "stream")
    local s2 = love.audio.newSource(songDead, "stream")

    self.isMuted = false
    self.originalVolumes = {
        [s1] = 1,
        [s2] = 1
    }

    s1:setLooping(true)
    s2:setLooping(true)

    s1:play()
    s2:play()

    self.songs = {
        playing = s1,
        dead = s2
    }

    self.volumes = {
        [s1] = 1,
        [s2] = 0
    }

    s1:setVolume(1)
    s2:setVolume(0)

    self.current = "playing"
    self.fadeDuration = 1.5

    return self
end

function MusicManager:update(dt)
    flux.update(dt)
end

function MusicManager:switch(toScene)
    if self.current == toScene then return end

    local fromSong = self.songs[self.current]
    local toSong = self.songs[toScene]

    flux.to(self.volumes, self.fadeDuration, { [fromSong] = 0 })
        :onupdate(function()
            fromSong:setVolume(self.volumes[fromSong])
        end)

    local targetVolume = self.originalVolumes[toSong] or 1

    flux.to(self.volumes, self.fadeDuration, { [toSong] = targetVolume })
        :onstart(function()
            if not toSong:isPlaying() then toSong:play() end
        end)
        :onupdate(function()
            toSong:setVolume(self.volumes[toSong])
        end)

    self.current = toScene
end


function MusicManager:setVolume(volume)
    for _, song in pairs(self.songs) do
        self.originalVolumes[song] = volume
        self.volumes[song] = volume
        song:setVolume(volume)
    end
end

function MusicManager:toggleMute()
    self.isMuted = not self.isMuted

    for _, song in pairs(self.songs) do
        local target = self.isMuted and 0 or (self.originalVolumes[song] or 1)

        flux.to(self.volumes, self.fadeDuration, { [song] = target })
            :onupdate(function()
                song:setVolume(self.volumes[song])
            end)
    end
end

return MusicManager