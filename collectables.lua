local Collectable = {}
Collectable.__index = Collectable

function Collectable.new(x, y, type)
    local self = setmetatable({}, Collectable)
    self.x = x or 0
    self.y = y or 0
    self.type = type or "coin"
    self.radius = 8
    self.collected = false
    
    if self.type == "coin" then
        self.color = {1, 1, 0}
        self.value = 1
    end
    
    return self
end

function Collectable:update(dt)
    if self.collected then return end
end

function Collectable:draw()
    if self.collected then return end
    
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Collectable:canCollect(player_x, player_y, collection_radius)
    if self.collected then return false end
    
    local dist = math.sqrt((player_x - self.x)^2 + (player_y - self.y)^2)
    return dist < collection_radius + self.radius
end

function Collectable:collect()
    self.collected = true
    return self.value
end

local CollectableManager = {}
CollectableManager.__index = CollectableManager

function CollectableManager.new()
    local self = setmetatable({}, CollectableManager)
    self.collectables = {}
    self.spawn_timer = 0
    self.spawn_interval = 0.7
    self.max_collectables = 40
    return self
end

function CollectableManager:update(dt, player_x, player_y, collection_radius, player_capacity, player_coins)
    self.spawn_timer = self.spawn_timer + dt
    if self.spawn_timer >= self.spawn_interval and #self.collectables < self.max_collectables then
        self.spawn_timer = 0
        self:spawnCollectable()
    end
    
    for i = #self.collectables, 1, -1 do
        local collectable = self.collectables[i]
        collectable:update(dt)
        
        if collectable:canCollect(player_x, player_y, collection_radius) and player_coins < player_capacity then
            collectable:collect()
            table.remove(self.collectables, i)
            return 1
        elseif collectable.collected then
            table.remove(self.collectables, i)
        end
    end
    
    return 0
end

function CollectableManager:spawnCollectable()
    local w, h = love.graphics.getDimensions()
    local collectable = Collectable.new(
        love.math.random(20, w - 20),
        love.math.random(20, h - 20),
        "coin"
    )
    table.insert(self.collectables, collectable)
end

function CollectableManager:draw()
    for _, collectable in ipairs(self.collectables) do
        collectable:draw()
    end
end

return {
    Collectable = Collectable,
    CollectableManager = CollectableManager
}