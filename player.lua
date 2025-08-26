local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x or 400
    self.y = y or 300
    self.radius = 20
    self.speed = 280.0
    self.carried_coins = 0
    self.base_capacity = 10.0
    self.capacity = self.base_capacity
    self.color = {64/255, 224/255, 208/255}
    
    self.collection_radius = 40
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

function Player:draw()
    love.graphics.setColor(self.color[1] * 0.3, self.color[2] * 0.3, self.color[3] * 0.3, 0.2)
    love.graphics.circle("line", self.x, self.y, self.collection_radius)
    
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
end

function Player:addCoins(amount)
    local added = math.min(amount, self.capacity - self.carried_coins)
    self.carried_coins = self.carried_coins + added
    return added
end

function Player:spendCoins(amount)
    local spent = math.min(amount, self.carried_coins)
    self.carried_coins = self.carried_coins - spent
    return spent
end

function Player:upgradeCapacity(amount)
    self.capacity = self.capacity + amount
end

function Player:isInZone(zone)
    return self.x >= zone.x and self.x <= zone.x + zone.width and
           self.y >= zone.y and self.y <= zone.y + zone.height
end

return Player
