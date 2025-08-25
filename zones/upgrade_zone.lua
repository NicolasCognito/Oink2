local Zone = require("zones.base_zone")

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

return UpgradeZone