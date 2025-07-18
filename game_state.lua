GameState = {
	current = "",
	states = {
		game = require("game"),
		death = require("death")
	}
}

function GameState.set(state)
	if GameState.states[current] and GameState.states[current].exit then
		GameState.states[current].exit()
	end

	GameState.current = state
	if GameState.states[state] and GameState.states[state].enter then
		GameState.states[state].enter()
	end
end

function GameState.update(dt)
	if GameState.states[GameState.current] and GameState.states[GameState.current].update then
		GameState.states[GameState.current].update(dt)
	end
end

function GameState.draw()
	if GameState.states[GameState.current] and GameState.states[GameState.current].draw then
		GameState.states[GameState.current].draw()
	end
end

function GameState.input(key)
	if GameState.states[GameState.current] and GameState.states[GameState.current].input then
		GameState.states[GameState.current].input(key)
	end
end

function GameState.released(key)
	if GameState.states[GameState.current] and GameState.states[GameState.current].released then
		GameState.states[GameState.current].released(key)
	end
end

return GameState