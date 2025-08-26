local Zone = require("zones.base_zone")
local Services = require("utils.services")

local BuildZone = {}
BuildZone.__index = BuildZone
setmetatable(BuildZone, {__index = Zone})

function BuildZone.new(x, y, width, height, cost, label, color)
    local self = Zone.new(x, y, width, height, cost, label, color)
    setmetatable(self, BuildZone)
    return self
end

function BuildZone:onComplete(player)
    -- Spawn a bot at the center of this zone
    local bm = Services.bot_manager
    if bm and bm.addBot then
        local cx = self.x + self.width / 2
        local cy = self.y + self.height / 2
        bm:addBot(cx, cy)
    end
    -- Make zone repeatable: reset progress instead of permanently completing
    self.progress = 0
    self.completed = false
end

return BuildZone
