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

return ZoneManager
