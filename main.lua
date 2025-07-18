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
local moonshine = require 'moonshine'
shaders = false

local screenWidth, screenHeight = love.window.getDesktopDimensions()
local windowWidth, windowHeight = GAME_WIDTH*screenWidth/2560, GAME_HEIGHT*screenHeight/1440
push:setupScreen(GAME_WIDTH+SIDEBAR_WIDTH, GAME_HEIGHT, windowWidth+SIDEBAR_WIDTH*screenWidth/2560, windowHeight)
push:setBorderColor(0,0,0)

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	v1b = love.graphics.newImage("var1base.png")
	v2b = love.graphics.newImage("var2base.png")
	v1h = love.graphics.newImage("var1high.png")
	v2h = love.graphics.newImage("var2high.png")

	if shaders then
		effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.chromasep).chain(moonshine.effects.desaturate)
		effect.chromasep.radius = 2
		effect.chromasep.angle = 2
		effect.desaturate.strength = 0.2
		effect.crt.scaleFactor = 1
	end

	GameState.set("game")
end

function love.update(dt)
	flux.update(dt)
	GameState.update(dt)
end

function love.draw()
	push:start()
	if shaders then
		effect(function()
		GameState.draw()
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