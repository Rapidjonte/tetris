io.stdout:setvbuf("no")

local push = require("push")
GameState = require("game_state")
flux = require("flux")
Class = require("knife")
require("settings")
Block = require("block")
Tetromino = require("tetromino")
timer = require("timer")
require("glitched_extension")

shaders = true

moonshine = require 'moonshine'
require "shake"
flashtext = require "flashtext"
ParticleExplosion = require "particles"

local screenWidth, screenHeight = love.window.getDesktopDimensions()
local windowWidth, windowHeight = GAME_WIDTH*screenWidth/2560, GAME_HEIGHT*screenHeight/1440
push:setupScreen(GAME_WIDTH+SIDEBAR_WIDTH, GAME_HEIGHT, windowWidth+SIDEBAR_WIDTH*screenWidth/2560, windowHeight)
push:setBorderColor(0,0,0)

function love.load()
	love.window.setMode(windowWidth+SIDEBAR_WIDTH*screenWidth/2560, windowHeight, {
	    borderless = false,
	    fullscreen = false,
	    resizable = true,
	    vsync = true
	})
	love.window.setIcon(love.image.newImageData("images/icon.png"))

	love.graphics.setDefaultFilter("nearest", "nearest")
	v1b = love.graphics.newImage("images/var1base.png")
	v2b = love.graphics.newImage("images/var2base.png")
	v1h = love.graphics.newImage("images/var1high.png")
	v2h = love.graphics.newImage("images/var2high.png")
	font = love.graphics.newFont("font.ttf", 50)
	smallerFont = love.graphics.newFont("font.ttf", 25)
	smallestFont = love.graphics.newFont("font.ttf", 20)

	MusicManager = require("musicmanager"):new("music/game.ogg", "music/dead.ogg")
	MusicManager:setVolume("playing", 0.7)
	MusicManager:setVolume("dead", 0.7)

	clear = love.audio.newSource("sfx/clear.wav", "static")
	death = love.audio.newSource("sfx/death.wav", "static")
	land = love.audio.newSource("sfx/land.wav", "static")
	levelup = love.audio.newSource("sfx/levelup.wav", "static")
	move = love.audio.newSource("sfx/move.wav", "static")
	rotate = love.audio.newSource("sfx/rotate.wav", "static")
	tetris = love.audio.newSource("sfx/tetris.wav", "static")

	GameState.set("game")
end

function play(source)
    local s = source:clone()
    love.audio.play(s)
end

function love.update(dt)
	flux.update(dt)
	MusicManager:update(dt)

	if shaders then
		for i = #flashes, 1, -1 do
	        if flashes[i].dead then
	            table.remove(flashes, i)
	        end
	    end
	    for i = #explosions, 1, -1 do
	        explosions[i]:update(dt)
	        if explosions[i].dead then
	            table.remove(explosions, i)
	        end
	    end
	    updateShake(dt)
	end
	GameState.update(dt)
end

function love.draw()
	push:start()
	if shaders then
		local ox, oy = getShakeOffset()
		love.graphics.translate(ox, oy)
		effect(function()
		GameState.draw()
		for _, flash in ipairs(flashes) do
        	flash:draw()
    	end
    	for _, e in ipairs(explosions) do
        	e:draw()
    	end
		end)
	else
		GameState.draw()
	end
	push:finish()
end

function love.resize(w, h)
	push:resize(w, h)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.push('quit')
	else
		GameState.input(key)
	end
end

function love.keyreleased(key, scancode)
	GameState.released(key)
end

function love.gamepadpressed(joystick, button)
	if button == "dpleft" then
		GameState.input("a")
	elseif button == "dpright" then
		GameState.input("d")
	elseif button == "x" then
		GameState.input("left")
	elseif button == "b" then
		GameState.input("right")
	elseif button == "dpdown" then
		GameState.input("s")
	elseif button == "start" then
		GameState.input("r")
	end
end

function love.gamepadreleased(joystick, button)
	if button == "dpleft" then
		GameState.released("a")
	elseif button == "dpright" then
		GameState.released("d")
	elseif button == "x" then
		GameState.released("left")
	elseif button == "b" then
		GameState.released("right")
	elseif button == "dpdown" then
		GameState.released("s")
	end
end

function love.joystickadded(js)
	if js:isGamepad() then
		activeJoystick = js
	end
end

function love.joystickremoved(js)
	if js == activeJoystick then
		activeJoystick = nil
	end
end