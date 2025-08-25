local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(initial_state)
    local self = setmetatable({}, StateMachine)
    self.current_state = initial_state
    self.states = {}
    return self
end

function StateMachine:addState(name, state_table)
    self.states[name] = state_table or {}
end

function StateMachine:setState(new_state)
    if self.states[self.current_state] and self.states[self.current_state].exit then
        self.states[self.current_state].exit()
    end
    
    self.current_state = new_state
    
    if self.states[self.current_state] and self.states[self.current_state].enter then
        self.states[self.current_state].enter()
    end
end

function StateMachine:update(dt, ...)
    if self.states[self.current_state] and self.states[self.current_state].update then
        self.states[self.current_state].update(dt, ...)
    end
end

function StateMachine:getCurrentState()
    return self.current_state
end

return StateMachine