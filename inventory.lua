local Inventory = {}
Inventory.__index = Inventory

function Inventory.new()
    local self = setmetatable({}, Inventory)
    self.items = {}
    return self
end

function Inventory:addItem(item_name, quantity)
    quantity = quantity or 1
    if not self.items[item_name] then
        self.items[item_name] = 0
    end
    self.items[item_name] = self.items[item_name] + quantity
    return quantity
end

function Inventory:removeItem(item_name, quantity)
    quantity = quantity or 1
    if not self.items[item_name] then
        return 0
    end
    
    local removed = math.min(quantity, self.items[item_name])
    self.items[item_name] = self.items[item_name] - removed
    
    if self.items[item_name] <= 0 then
        self.items[item_name] = nil
    end
    
    return removed
end

function Inventory:getQuantity(item_name)
    return self.items[item_name] or 0
end

function Inventory:hasItem(item_name, quantity)
    quantity = quantity or 1
    return self:getQuantity(item_name) >= quantity
end

function Inventory:getTotalItems()
    local total = 0
    for _, quantity in pairs(self.items) do
        total = total + quantity
    end
    return total
end

function Inventory:isEmpty()
    return next(self.items) == nil
end

function Inventory:clear()
    self.items = {}
end

function Inventory:getItemsList()
    local items_list = {}
    for item_name, quantity in pairs(self.items) do
        table.insert(items_list, {name = item_name, quantity = quantity})
    end
    return items_list
end

return Inventory