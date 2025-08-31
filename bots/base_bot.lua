local StateMachine = require("utils.state_machine")
local Character = require("character")
local CharacterGraphics = require("graphics.character_graphics")

local Bot = {}
Bot.__index = Bot
setmetatable(Bot, {__index = Character})

function Bot.new(x, y)
    local self = Character.new(x or 200, y or 200, 15, 120.0, 5.0, 35, {1, 0.75, 0.8})
    setmetatable(self, Bot)
    
    self.target_x = self.x
    self.target_y = self.y
    self.target_zone = nil
    self.target_collectable = nil
    self.drop_timer = 0
    self.drop_interval = 0.05
    
    -- Accepted items (data-driven, like zones)
    self.accepted_items = { coin = true }
    
    self.state_machine = StateMachine.new("idle")
    self:setupStates()
    
    return self
end

function Bot:setupStates()
    self.state_machine:addState("idle", {
        update = function(dt)
            self:findCoinsOrZone()
        end
    })
    
    self.state_machine:addState("moving_to_coin", {
        update = function(dt)
            -- If coin count reached capacity, deliver instead
            local coins = self.inventory:getQuantity("coin")
            if coins >= self.capacity then
                self:selectNearestZone()
                if self.target_zone then
                    self.state_machine:setState("moving_to_zone")
                    return
                end
            end

            -- Revalidate target collectable
            if not self:isCollectableValid(self.target_collectable) then
                self.target_collectable, self.target_x, self.target_y = self:findNearestAcceptableCollectable()
                if not self.target_collectable then
                    self.state_machine:setState("idle")
                    return
                end
            else
                -- Keep moving toward the collectable's current position
                self.target_x = self.target_collectable.x
                self.target_y = self.target_collectable.y
            end

            self:moveToTarget(dt)
            if self:distanceTo(self.target_x, self.target_y) < 5 then
                -- Close enough but item may have been taken; re-evaluate immediately
                self.target_collectable = nil
                self.state_machine:setState("idle")
            end
        end
    })
    
    self.state_machine:addState("moving_to_zone", {
        update = function(dt)
            if not self.target_zone or not self:isZoneValid(self.target_zone) then
                self.state_machine:setState("idle")
                return
            end
            
            local zone_center_x = self.target_zone.x + self.target_zone.width / 2
            local zone_center_y = self.target_zone.y + self.target_zone.height / 2
            self.target_x = zone_center_x
            self.target_y = zone_center_y
            
            self:moveToTarget(dt)
            
            if self:isInZone(self.target_zone) then
                self.state_machine:setState("delivering")
            end
        end
    })
    
    self.state_machine:addState("delivering", {
        update = function(dt)
            if not self.target_zone or not self:isZoneValid(self.target_zone) then
                self.state_machine:setState("idle")
                return
            end
            if not self:isInZone(self.target_zone) then
                self.state_machine:setState("idle")
                return
            end
            
            local coins = self.inventory:getQuantity("coin")
            if coins <= 0 then
                -- No coins left; go back to collecting
                self.target_zone = nil
                self.state_machine:setState("idle")
                return
            end
            
            -- Drop coins at a steady rate while inside the zone
            self.drop_timer = self.drop_timer + dt
            while self.drop_timer >= self.drop_interval and coins > 0 do
                self.drop_timer = self.drop_timer - self.drop_interval
                self.inventory:removeItem("coin", 1)
                if self.collectable_manager then
                    self.collectable_manager:spawnCoin(self.x, self.y)
                end
                coins = coins - 1
            end
        end
    })
end

function Bot:findCoinsOrZone()
    local coins = self.inventory:getQuantity("coin")
    if coins >= self.capacity then
        self:selectNearestZone()
        if self.target_zone then
            self.state_machine:setState("moving_to_zone")
            return
        end
    end
    
    self.target_collectable, self.target_x, self.target_y = self:findNearestAcceptableCollectable()
    if self.target_collectable then
        self.state_machine:setState("moving_to_coin")
    end
end

function Bot:selectNearestZone()
    self.target_zone = self:findNearestZoneThatAcceptsCoin()
end

function Bot:findNearestAcceptableCollectable()
    if not self.collectable_manager or not self.collectable_manager.collectables then
        return nil, nil
    end
    
    local nearest, nearest_x, nearest_y = nil, nil, nil
    local nearest_distance = math.huge
    
    for _, c in ipairs(self.collectable_manager.collectables) do
        if not c.collected and self:canAcceptItem(c.type) then
            local distance = self:distanceTo(c.x, c.y)
            if distance < nearest_distance then
                nearest_distance = distance
                nearest = c
                nearest_x = c.x
                nearest_y = c.y
            end
        end
    end
    
    return nearest, nearest_x, nearest_y
end

function Bot:findNearestZone()
    if not self.zone_manager or not self.zone_manager.zones then
        return nil
    end
    
    local nearest_zone = nil
    local nearest_distance = math.huge
    
    for _, zone in ipairs(self.zone_manager.zones) do
        if zone.active and zone.active_for_bots and not zone.completed and zone.progress < zone.cost then
            local zone_center_x = zone.x + zone.width / 2
            local zone_center_y = zone.y + zone.height / 2
            local distance = self:distanceTo(zone_center_x, zone_center_y)
            
            if distance < nearest_distance then
                nearest_distance = distance
                nearest_zone = zone
            end
        end
    end
    
    return nearest_zone
end

function Bot:findNearestZoneThatAcceptsCoin()
    if not self.zone_manager or not self.zone_manager.zones then
        return nil
    end
    
    local nearest_zone = nil
    local nearest_distance = math.huge
    
    for _, zone in ipairs(self.zone_manager.zones) do
        if self:isZoneValid(zone) then
            local zone_center_x = zone.x + zone.width / 2
            local zone_center_y = zone.y + zone.height / 2
            local distance = self:distanceTo(zone_center_x, zone_center_y)
            if distance < nearest_distance then
                nearest_distance = distance
                nearest_zone = zone
            end
        end
    end
    
    return nearest_zone
end

function Bot:moveToTarget(dt)
    local dx = self.target_x - self.x
    local dy = self.target_y - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance > 0 then
        dx = dx / distance
        dy = dy / distance
        
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end
end

function Bot:distanceTo(x, y)
    local dx = x - self.x
    local dy = y - self.y
    return math.sqrt(dx*dx + dy*dy)
end

function Bot:isInZone(zone)
    return self.x >= zone.x and self.x <= zone.x + zone.width and
           self.y >= zone.y and self.y <= zone.y + zone.height
end

function Bot:isZoneValid(zone)
    return zone
        and zone.active
        and zone.active_for_bots
        and zone.canAcceptItem
        and zone:canAcceptItem("coin")
end

function Bot:isCollectableValid(c)
    return c ~= nil and (not c.collected) and self:canAcceptItem(c.type)
end

function Bot:setAcceptedItems(items)
    self.accepted_items = items or {}
end

function Bot:canAcceptItem(item_type)
    return self.accepted_items and self.accepted_items[item_type] == true
end

function Bot:update(dt, collectable_manager, zone_manager)
    self.collectable_manager = collectable_manager
    self.zone_manager = zone_manager
    
    if collectable_manager then
        -- Filter so bots only pick up items they accept
        local filter_inventory = {
            canAddItem = function(_, item_name, quantity, weight_per_unit)
                if not self:canAcceptItem(item_name) then return false end
                -- Enforce bot capacity by count for coins (not weight-based)
                if item_name == "coin" then
                    local have = self.inventory:getQuantity("coin")
                    return (have + (quantity or 1)) <= self.capacity
                end
                -- Default to inventory checks for other types (if ever enabled)
                return self.inventory:canAddItem(item_name, quantity, weight_per_unit)
            end
        }
        local collected_item = collectable_manager:update(
            dt,
            self.x,
            self.y,
            self.collection_radius,
            filter_inventory
        )
        if collected_item then
            -- Treat items generically via inventory
            self:addItem(collected_item.type, collected_item.value, collected_item.weight)
            if collected_item.type == "coin" and self.inventory:getQuantity("coin") >= self.capacity then
                self:selectNearestZone()
                if self.target_zone then
                    self.state_machine:setState("moving_to_zone")
                end
            end
        end
    end
    
    self.state_machine:update(dt)
end

function Bot:draw()
    CharacterGraphics.drawBot(self)
end

return Bot
