local StateMachine = require("utils.state_machine")
local Character = require("character")

local Bot = {}
Bot.__index = Bot
setmetatable(Bot, {__index = Character})

function Bot.new(x, y)
    local self = Character.new(x or 200, y or 200, 15, 120.0, 5.0, 35, {1, 0.75, 0.8})
    setmetatable(self, Bot)
    
    self.target_x = self.x
    self.target_y = self.y
    self.target_zone = nil
    
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
            self:moveToTarget(dt)
            if self:distanceTo(self.target_x, self.target_y) < 5 then
                self.state_machine:setState("idle")
            end
        end
    })
    
    self.state_machine:addState("moving_to_zone", {
        update = function(dt)
            if not self.target_zone then
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
            -- Bots no longer spend coins directly in zones
            -- They just collect coins for now (future: may drop coins when implemented)
            self.target_zone = nil
            self.state_machine:setState("idle")
        end
    })
end

function Bot:findCoinsOrZone()
    -- Bots only look for coins now, no zone interaction
    local coin_x, coin_y = self:findNearestCoin()
    if coin_x then
        self.target_x = coin_x
        self.target_y = coin_y
        self.state_machine:setState("moving_to_coin")
    end
end

function Bot:findNearestCoin()
    if not self.collectable_manager or not self.collectable_manager.collectables then
        return nil, nil
    end
    
    local nearest_x, nearest_y = nil, nil
    local nearest_distance = math.huge
    
    for _, coin in ipairs(self.collectable_manager.collectables) do
        if not coin.collected then
            local distance = self:distanceTo(coin.x, coin.y)
            if distance < nearest_distance then
                nearest_distance = distance
                nearest_x = coin.x
                nearest_y = coin.y
            end
        end
    end
    
    return nearest_x, nearest_y
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

function Bot:update(dt, collectable_manager, zone_manager)
    self.collectable_manager = collectable_manager
    self.zone_manager = zone_manager
    
    if collectable_manager then
        local collected_item = collectable_manager:update(
            dt,
            self.x,
            self.y,
            self.collection_radius,
            self.capacity,
            self.carried_coins
        )
        if collected_item and collected_item.type == "coin" then
            self.carried_coins = math.min(self.capacity, self.carried_coins + collected_item.value)
        end
    end
    
    self.state_machine:update(dt)
end

function Bot:draw()
    love.graphics.setColor(self.color[1] * 0.3, self.color[2] * 0.3, self.color[3] * 0.3, 0.2)
    love.graphics.circle("line", self.x, self.y, self.collection_radius)
    
    -- Pig body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    -- Pig snout
    love.graphics.setColor(self.color[1] * 0.8, self.color[2] * 0.8, self.color[3] * 0.8)
    love.graphics.circle("fill", self.x, self.y + 3, 5)
    
    -- Pig nostrils
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.circle("fill", self.x - 2, self.y + 3, 1)
    love.graphics.circle("fill", self.x + 2, self.y + 3, 1)
    
    -- Pig eyes
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", self.x - 4, self.y - 3, 2)
    love.graphics.circle("fill", self.x + 4, self.y - 3, 2)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("%.0f", self.carried_coins), self.x - 5, self.y - 20)
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print(self.state_machine:getCurrentState(), self.x - 15, self.y + 25)
end

return Bot
