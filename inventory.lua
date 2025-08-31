local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(max_weight)
    local self = setmetatable({}, Inventory)
    self.items = {}
    self.item_weights = {}  -- stores weight per unit for each item type
    self.max_weight = max_weight or nil  -- nil means no weight limit
    return self
end

function Inventory:addItem(item_name, quantity, weight_per_unit)
    quantity = quantity or 1
    weight_per_unit = weight_per_unit or 0
    
    -- Store weight info for this item type
    if weight_per_unit > 0 then
        self.item_weights[item_name] = weight_per_unit
    end
    
    -- Check weight limit if it exists
    if self.max_weight then
        local current_weight = self:getTotalWeight()
        local additional_weight = quantity * (self.item_weights[item_name] or 0)
        if current_weight + additional_weight > self.max_weight then
            -- Calculate how much we can actually add
            local remaining_capacity = self.max_weight - current_weight
            local max_addable = math.floor(remaining_capacity / (self.item_weights[item_name] or 0))
            quantity = math.max(0, math.min(quantity, max_addable))
        end
    end
    
    if quantity > 0 then
        if not self.items[item_name] then
            self.items[item_name] = 0
        end
        self.items[item_name] = self.items[item_name] + quantity
    end
    
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

function Inventory:getTotalWeight()
    local total_weight = 0
    for item_name, quantity in pairs(self.items) do
        local weight_per_unit = self.item_weights[item_name] or 0
        total_weight = total_weight + (quantity * weight_per_unit)
    end
    return total_weight
end

function Inventory:getRemainingWeight()
    if not self.max_weight then
        return math.huge -- unlimited
    end
    return self.max_weight - self:getTotalWeight()
end

function Inventory:canAddItem(item_name, quantity, weight_per_unit)
    if not self.max_weight then
        return true -- no weight limit
    end
    
    quantity = quantity or 1
    weight_per_unit = weight_per_unit or self.item_weights[item_name] or 0
    local additional_weight = quantity * weight_per_unit
    
    return self:getTotalWeight() + additional_weight <= self.max_weight
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