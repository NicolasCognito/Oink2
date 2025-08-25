local Zone = require("zones.base_zone")

local BuildZone = {}
BuildZone.__index = BuildZone
setmetatable(BuildZone, {__index = Zone})

function BuildZone.new(x, y, width, height, cost, label, color)
    local self = Zone.new(x, y, width, height, cost, label, color)
    setmetatable(self, BuildZone)
    return self
end

function BuildZone:onComplete(player)
    self.completed = true
end

return BuildZone