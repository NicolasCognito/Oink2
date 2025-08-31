local Character = require("character")

local Player = {}
Player.__index = Player
setmetatable(Player, {__index = Character})

function Player.new(x, y)
    local self = Character.new(x or 400, y or 300, 20, 280.0, 10.0, 40, {64/255, 224/255, 208/255})
    setmetatable(self, Player)
    
    self.base_capacity = self.capacity
    self.collectable_manager = nil
    self.auto_drop = false
    self.drop_timer = 0
    self.drop_interval = 0.1
    
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
    
    -- Auto drop coins via inventory
    if self.auto_drop and self.inventory:getQuantity("coin") > 0 then
        self.drop_timer = self.drop_timer + dt
        if self.drop_timer >= self.drop_interval then
            self:dropCoins()
            self.drop_timer = 0
        end
    end
end

function Player:setCollectableManager(manager)
    self.collectable_manager = manager
end

function Player:dropCoins()
    if not self.collectable_manager then return end
    local coins = self.inventory:getQuantity("coin")
    if coins <= 0 then return end
    self.inventory:removeItem("coin", 1)
    self.collectable_manager:spawnCoin(self.x, self.y)
end

function Player:toggleAutoDrop()
    self.auto_drop = not self.auto_drop
    self.drop_timer = 0
end

return Player
