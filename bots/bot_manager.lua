local BotManager = {}
BotManager.__index = BotManager

function BotManager.new()
    local self = setmetatable({}, BotManager)
    self.bots = {}
    self.character_manager = nil
    return self
end

function BotManager:setCharacterManager(character_manager)
    self.character_manager = character_manager
end

function BotManager:addBot(x, y)
    local bot = nil
    if self.character_manager then
        bot = self.character_manager:createBot(x, y)
    else
        local Bot = require("bots.base_bot")
        bot = Bot.new(x, y)
    end
    table.insert(self.bots, bot)
    return bot
end

function BotManager:addChicken(x, y)
    local ChickenBot = require("bots.chicken_bot")
    local chicken = ChickenBot.new(x, y)
    table.insert(self.bots, chicken)
    return chicken
end

function BotManager:removeBot(bot)
    for i, b in ipairs(self.bots) do
        if b == bot then
            table.remove(self.bots, i)
            if self.character_manager then
                self.character_manager:removeCharacter(bot)
            end
            break
        end
    end
end

function BotManager:update(dt, collectable_manager, zone_manager)
    for _, bot in ipairs(self.bots) do
        bot:update(dt, collectable_manager, zone_manager)
    end
end

function BotManager:draw()
    for _, bot in ipairs(self.bots) do
        bot:draw()
    end
end

return BotManager