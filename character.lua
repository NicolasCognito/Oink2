local Inventory = require("inventory")
local CharacterGraphics = require("graphics.character_graphics")

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
    self.inventory = Inventory.new(capacity)
    return self
end

-- Generic coin helpers now delegate to inventory only
function Character:addCoins(amount)
    return self.inventory:addItem("coin", amount, 1.0)
end

function Character:spendCoins(amount)
    return self.inventory:removeItem("coin", amount)
end

function Character:addItem(item_name, amount, weight_per_unit)
    return self.inventory:addItem(item_name, amount, weight_per_unit)
end

function Character:getItemCount(item_name)
    return self.inventory:getQuantity(item_name)
end

function Character:upgradeCapacity(amount)
    -- Increase both the character's logical capacity and the
    -- inventory's max weight so weight checks and UI stay in sync
    self.capacity = self.capacity + amount
    if self.inventory then
        self.inventory.max_weight = self.capacity
    end
end

function Character:isInZone(zone)
    return self.x >= zone.x and self.x <= zone.x + zone.width and
           self.y >= zone.y and self.y <= zone.y + zone.height
end

function Character:draw()
    CharacterGraphics.drawBase(self)
end

return Character
