local StateMachine = require("utils.state_machine")
local Character = require("character")
local CharacterGraphics = require("graphics.character_graphics")

local ChickenBot = {}
ChickenBot.__index = ChickenBot
setmetatable(ChickenBot, {__index = Character})

function ChickenBot.new(x, y)
    local self = Character.new(x or 200, y or 200, 12, 60.0, 0, 0, {1, 1, 1})
    setmetatable(self, ChickenBot)
    
    self.wander_target_x = self.x
    self.wander_target_y = self.y
    self.wander_timer = 0
    self.wander_interval = love.math.random(1.5, 4.0)
    
    self.egg_timer = 0
    self.egg_interval = love.math.random(8.0, 15.0)
    
    self.state_machine = StateMachine.new("wandering")
    self:setupStates()
    
    return self
end

function ChickenBot:setupStates()
    self.state_machine:addState("wandering", {
        update = function(dt)
            self:updateWandering(dt)
        end
    })
    
    self.state_machine:addState("laying_egg", {
        update = function(dt)
            self.egg_timer = self.egg_timer + dt
            if self.egg_timer >= 1.0 then
                self:layEgg()
                self.egg_timer = 0
                self.egg_interval = love.math.random(8.0, 15.0)
                self.state_machine:setState("wandering")
            end
        end
    })
end

function ChickenBot:updateWandering(dt)
    self.wander_timer = self.wander_timer + dt
    self.egg_timer = self.egg_timer + dt
    
    if self.egg_timer >= self.egg_interval then
        self.state_machine:setState("laying_egg")
        self.egg_timer = 0
        return
    end
    
    if self.wander_timer >= self.wander_interval then
        self:setNewWanderTarget()
        self.wander_timer = 0
        self.wander_interval = love.math.random(1.5, 4.0)
    end
    
    self:moveToWanderTarget(dt)
end

function ChickenBot:setNewWanderTarget()
    local w, h = love.graphics.getDimensions()
    local max_wander_distance = 100
    
    local angle = love.math.random() * 2 * math.pi
    local distance = love.math.random(30, max_wander_distance)
    
    self.wander_target_x = self.x + math.cos(angle) * distance
    self.wander_target_y = self.y + math.sin(angle) * distance
    
    self.wander_target_x = math.max(20, math.min(w - 20, self.wander_target_x))
    self.wander_target_y = math.max(20, math.min(h - 20, self.wander_target_y))
end

function ChickenBot:moveToWanderTarget(dt)
    local dx = self.wander_target_x - self.x
    local dy = self.wander_target_y - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance > 5 then
        dx = dx / distance
        dy = dy / distance
        
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end
end

function ChickenBot:layEgg()
    if self.collectable_manager then
        self.collectable_manager:spawnEgg(self.x, self.y)
    end
end

function ChickenBot:update(dt, collectable_manager, zone_manager)
    self.collectable_manager = collectable_manager
    self.state_machine:update(dt)
end

function ChickenBot:draw()
    CharacterGraphics.drawChicken(self)
end

return ChickenBot