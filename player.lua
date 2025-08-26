local Character = require("character")

local Player = {}
Player.__index = Player
setmetatable(Player, {__index = Character})

function Player.new(x, y)
    local self = Character.new(x or 400, y or 300, 20, 280.0, 10.0, 40, {64/255, 224/255, 208/255})
    setmetatable(self, Player)
    
    self.base_capacity = self.capacity
    self.auto_spend = true
    
    return self
end

function Player:update(dt)
    local dx, dy = 0, 0
    
    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end
    if love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end
    
    if dx ~= 0 or dy ~= 0 then
        local length = math.sqrt(dx*dx + dy*dy)
        dx = dx / length
        dy = dy / length
    end
    
    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt
    
    local w, h = love.graphics.getDimensions()
    self.x = math.max(self.radius, math.min(w - self.radius, self.x))
    self.y = math.max(self.radius, math.min(h - self.radius, self.y))
end


return Player
