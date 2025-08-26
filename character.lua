local Character = {}
Character.__index = Character

function Character.new(x, y, radius, speed, capacity, collection_radius, color)
    local self = setmetatable({}, Character)
    self.x = x or 0
    self.y = y or 0
    self.radius = radius or 15
    self.speed = speed or 100.0
    self.carried_coins = 0
    self.capacity = capacity or 5.0
    self.collection_radius = collection_radius or 35
    self.color = color or {1, 1, 1}
    return self
end

function Character:addCoins(amount)
    local added = math.min(amount, self.capacity - self.carried_coins)
    self.carried_coins = self.carried_coins + added
    return added
end

function Character:spendCoins(amount)
    local spent = math.min(amount, self.carried_coins)
    self.carried_coins = self.carried_coins - spent
    return spent
end

function Character:upgradeCapacity(amount)
    self.capacity = self.capacity + amount
end

function Character:isInZone(zone)
    return self.x >= zone.x and self.x <= zone.x + zone.width and
           self.y >= zone.y and self.y <= zone.y + zone.height
end

function Character:draw()
    -- Draw collection radius
    love.graphics.setColor(self.color[1] * 0.3, self.color[2] * 0.3, self.color[3] * 0.3, 0.2)
    love.graphics.circle("line", self.x, self.y, self.collection_radius)
    
    -- Draw character
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Character