local Zone = require("zones.base_zone")
local Services = require("utils.services")

local UpgradeZone = {}
UpgradeZone.__index = UpgradeZone
setmetatable(UpgradeZone, {__index = Zone})

function UpgradeZone.new(x, y, width, height, cost, label, color, capacity_upgrade, speed_upgrade, range_upgrade)
    local self = Zone.new(x, y, width, height, cost, label, color)
    setmetatable(self, UpgradeZone)
    self.capacity_upgrade = capacity_upgrade or 5.0
    self.speed_upgrade = speed_upgrade or 40.0
    self.range_upgrade = range_upgrade or 10.0
    self.modes = {"capacity", "speed", "range"}
    self.mode_index = 1
    return self
end

function UpgradeZone:onComplete(character)
    -- Always upgrade the player, regardless of who completed the zone
    local player = Services.character_manager:getPlayer()
    if not player then
        return -- No player to upgrade
    end
    
    local mode = self.modes[self.mode_index] or "capacity"
    if mode == "capacity" then
        player:upgradeCapacity(self.capacity_upgrade)
    elseif mode == "speed" then
        player.speed = player.speed + self.speed_upgrade
    elseif mode == "range" then
        player.collection_radius = player.collection_radius + self.range_upgrade
    end
    self.cost = self.cost * 1.5
    self.progress = 0
    self.completed = false
end

function UpgradeZone:cycleMode(delta)
    if not self.modes or #self.modes == 0 then return end
    local count = #self.modes
    self.mode_index = ((self.mode_index - 1 + delta) % count) + 1
end

function UpgradeZone:getCurrentMode()
    return self.modes[self.mode_index] or "capacity"
end

function UpgradeZone:getDisplayLabel()
    local mode = self:getCurrentMode()
    local modeTitle = (mode == "capacity" and "Capacity")
        or (mode == "speed" and "Speed")
        or (mode == "range" and "Range")
        or mode
    return string.format("%s [%s]", self.label, modeTitle)
end

function UpgradeZone:getDisplayColor()
    local mode = self:getCurrentMode()
    if mode == "capacity" then
        return {64/255, 224/255, 208/255} -- teal-ish
    elseif mode == "speed" then
        return {1.0, 0.6, 0.2} -- orange
    elseif mode == "range" then
        return {0.6, 0.5, 1.0} -- violet
    end
    return self.color
end

function UpgradeZone:drawExtra()
    local mode = self:getCurrentMode()
    local info
    if mode == "capacity" then
        info = string.format("+%.0f capacity", self.capacity_upgrade)
    elseif mode == "speed" then
        info = string.format("+%.0f speed", self.speed_upgrade)
    elseif mode == "range" then
        info = string.format("+%.0f range", self.range_upgrade)
    end
    if info then
        love.graphics.setColor(1,1,1)
        love.graphics.print(info, self.x + 5, self.y + 35)
    end
end

return UpgradeZone
