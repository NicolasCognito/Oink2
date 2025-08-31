local Inventory = require("inventory")

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
    local color = (self.getDisplayColor and self:getDisplayColor()) or self.color
    
    -- Dim inactive zones
    local alpha = self.active and 1.0 or 0.3
    
    love.graphics.setColor(color[1] * 0.3 * alpha, color[2] * 0.3 * alpha, color[3] * 0.3 * alpha)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(color[1] * alpha, color[2] * alpha, color[3] * alpha)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    if self.progress > 0 and not self.completed then
        local progress_width = (self.progress / self.cost) * self.width
        love.graphics.setColor(color[1] * alpha, color[2] * alpha, color[3] * alpha, 0.7)
        love.graphics.rectangle("fill", self.x, self.y, progress_width, self.height)
    end
    
    love.graphics.setColor(1 * alpha, 1 * alpha, 1 * alpha)
    local label = (self.getDisplayLabel and self:getDisplayLabel()) or self.label
    love.graphics.print(label, self.x + 5, self.y + 5)
    love.graphics.print(string.format("%.1f/%.0f", self.progress, self.cost), self.x + 5, self.y + 20)
    
    if not self.active then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("INACTIVE", self.x + 5, self.y + 35)
    end
    
    if not self.active_for_bots then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("BOTS OFF", self.x + 5, self.y + 50)
    end
    
    if self.completed then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("BUILT!", self.x + self.width/2 - 20, self.y + self.height/2)
    end

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
