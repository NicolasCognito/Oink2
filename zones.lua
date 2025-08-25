local Zone = {}
Zone.__index = Zone

function Zone.new(x, y, width, height, cost, label, color)
    local self = setmetatable({}, Zone)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.progress = 0
    self.cost = cost
    self.label = label
    self.color = color or {1, 1, 1}
    self.completed = false
    self.spend_rate = 8.0
    return self
end

function Zone:update(dt, player)
    if player:isInZone(self) and player.carried_coins > 0 and self.progress < self.cost then
        local spend_amount = math.min(self.spend_rate * dt, player.carried_coins, self.cost - self.progress)
        self.progress = self.progress + spend_amount
        player:spendCoins(spend_amount)
        
        if self.progress >= self.cost then
            self:onComplete(player)
        end
    end
end

function Zone:onComplete(player)
    self.completed = true
end

function Zone:draw()
    love.graphics.setColor(self.color[1] * 0.3, self.color[2] * 0.3, self.color[3] * 0.3)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(self.color)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    if self.progress > 0 and not self.completed then
        local progress_width = (self.progress / self.cost) * self.width
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.7)
        love.graphics.rectangle("fill", self.x, self.y, progress_width, self.height)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.label, self.x + 5, self.y + 5)
    love.graphics.print(string.format("%.1f/%.0f", self.progress, self.cost), self.x + 5, self.y + 20)
    
    if self.completed then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("BUILT!", self.x + self.width/2 - 20, self.y + self.height/2)
    end
end

local UpgradeZone = {}
UpgradeZone.__index = UpgradeZone
setmetatable(UpgradeZone, {__index = Zone})

function UpgradeZone.new(x, y, width, height, cost, label, color, capacity_upgrade)
    local self = Zone.new(x, y, width, height, cost, label, color)
    setmetatable(self, UpgradeZone)
    self.capacity_upgrade = capacity_upgrade or 5.0
    return self
end

function UpgradeZone:onComplete(player)
    player:upgradeCapacity(self.capacity_upgrade)
    self.cost = self.cost * 1.5
    self.progress = 0
    self.completed = false
end

local ZoneManager = {}
ZoneManager.__index = ZoneManager

function ZoneManager.new()
    local self = setmetatable({}, ZoneManager)
    self.zones = {}
    return self
end

function ZoneManager:addZone(zone)
    table.insert(self.zones, zone)
end

function ZoneManager:update(dt, player)
    for _, zone in ipairs(self.zones) do
        zone:update(dt, player)
    end
end

function ZoneManager:draw()
    for _, zone in ipairs(self.zones) do
        zone:draw()
    end
end

return {
    Zone = Zone,
    UpgradeZone = UpgradeZone,
    ZoneManager = ZoneManager
}