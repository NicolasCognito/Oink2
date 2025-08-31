local Inventory = require("inventory")
local ZoneGraphics = require("graphics.zone_graphics")

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
    self.active = true
    self.active_for_bots = true
    self.inventory = Inventory.new()
    self.accepted_items = {}
    return self
end

function Zone:update(dt, player)
    -- Zones no longer auto-spend player coins
    -- All resource consumption happens via absorption of dropped collectables
end

-- Default: zones without modes can ignore cycle requests
function Zone:cycleMode(delta)
    -- no-op in base
end

function Zone:toggleActive()
    self.active = not self.active
end

function Zone:toggleActiveForBots()
    self.active_for_bots = not self.active_for_bots
end

function Zone:isActive()
    return self.active
end

function Zone:isActiveForBots()
    return self.active_for_bots
end

function Zone:setAcceptedItems(items)
    self.accepted_items = items or {}
end

function Zone:canAcceptItem(item_type)
    return self.accepted_items[item_type] == true
end

function Zone:absorbCollectable(collectable)
    if not self:canAcceptItem(collectable.type) then
        return false
    end
    
    local value = collectable:collect()
    self.inventory:addItem(collectable.type, value)
    self.progress = self.progress + value
    
    if self.progress >= self.cost then
        self:onComplete()
    end
    
    return true
end

function Zone:onComplete(player)
    self.completed = true
end

function Zone:draw()
    ZoneGraphics.drawBase(self)

    if self.drawExtra then
        self:drawExtra()
    end
end

function Zone:getDisplayLabel()
    return self.label
end

function Zone:getDisplayColor()
    return self.color
end

function Zone:drawExtra()
    -- no-op by default
end

return Zone
