local StateMachine = require("utils.state_machine")

local Bot = {}
Bot.__index = Bot

function Bot.new(x, y)
    local self = setmetatable({}, Bot)
    self.x = x or 200
    self.y = y or 200
    self.radius = 15
    self.speed = 120.0
    self.carried_coins = 0
    self.capacity = 5.0
    self.color = {255/255, 165/255, 0/255}
    self.collection_radius = 35
    
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
            if not self.target_zone or not self:isInZone(self.target_zone) then
                self.state_machine:setState("idle")
                return
            end
            
            if self.carried_coins > 0 and self.target_zone.progress < self.target_zone.cost then
                local spend_amount = math.min(self.target_zone.spend_rate * dt, self.carried_coins, self.target_zone.cost - self.target_zone.progress)
                self.target_zone.progress = self.target_zone.progress + spend_amount
                self.carried_coins = self.carried_coins - spend_amount
                
                if self.target_zone.progress >= self.target_zone.cost then
                    self.target_zone:onComplete({spendCoins = function() end, upgradeCapacity = function() end})
                end
            end
            
            if self.carried_coins == 0 then
                self.target_zone = nil
                self.state_machine:setState("idle")
            end
        end
    })
end

function Bot:findCoinsOrZone()
    if self.carried_coins >= self.capacity then
        local zone = self:findNearestZone()
        if zone then
            self.target_zone = zone
            self.state_machine:setState("moving_to_zone")
        end
    else
        local coin_x, coin_y = self:findNearestCoin()
        if coin_x then
            self.target_x = coin_x
            self.target_y = coin_y
            self.state_machine:setState("moving_to_coin")
        end
    end
end

function Bot:findNearestCoin()
    return nil, nil
end

function Bot:findNearestZone()
    return nil
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
    if collectable_manager then
        local coins_collected = collectable_manager:update(
            dt,
            self.x,
            self.y,
            self.collection_radius,
            self.capacity,
            self.carried_coins
        )
        self.carried_coins = math.min(self.capacity, self.carried_coins + coins_collected)
    end
    
    if zone_manager then
        self.zone_manager = zone_manager
    end
    
    self.state_machine:update(dt)
end

function Bot:draw()
    love.graphics.setColor(self.color[1] * 0.3, self.color[2] * 0.3, self.color[3] * 0.3, 0.2)
    love.graphics.circle("line", self.x, self.y, self.collection_radius)
    
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("%.0f", self.carried_coins), self.x - 5, self.y - 20)
    
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print(self.state_machine:getCurrentState(), self.x - 15, self.y + 25)
end

return Bot