local Services = require("utils.services")

local BotManager = {}
BotManager.__index = BotManager

function BotManager.new()
    local self = setmetatable({}, BotManager)
    self.bots = {}
    return self
end

function BotManager:addBot(x, y)
    local bot = Services.character_manager:createBot(x, y)
    table.insert(self.bots, bot)
    return bot
end

function BotManager:removeBot(bot)
    for i, b in ipairs(self.bots) do
        if b == bot then
            table.remove(self.bots, i)
            Services.character_manager:removeCharacter(bot)
            break
        end
    end
end

function BotManager:update(dt, collectable_manager, zone_manager)
    for _, bot in ipairs(self.bots) do
        if zone_manager then
            bot.findNearestZone = function(self)
                local nearest_zone = nil
                local nearest_distance = math.huge
                
                for _, zone in ipairs(zone_manager.zones) do
                    if not zone.completed and zone.progress < zone.cost then
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
        end
        
        if collectable_manager then
            bot.findNearestCoin = function(self)
                local nearest_x, nearest_y = nil, nil
                local nearest_distance = math.huge
                
                if collectable_manager.collectables then
                    for _, coin in ipairs(collectable_manager.collectables) do
                        if not coin.collected then
                            local distance = self:distanceTo(coin.x, coin.y)
                            if distance < nearest_distance then
                                nearest_distance = distance
                                nearest_x = coin.x
                                nearest_y = coin.y
                            end
                        end
                    end
                end
                
                return nearest_x, nearest_y
            end
        end
        
        bot:update(dt, collectable_manager, zone_manager)
    end
end

function BotManager:draw()
    for _, bot in ipairs(self.bots) do
        bot:draw()
    end
end

return BotManager