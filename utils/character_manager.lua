local Player = require("player")
local Bot = require("bots.base_bot")

local CharacterManager = {}
CharacterManager.__index = CharacterManager

function CharacterManager.new()
    local self = setmetatable({}, CharacterManager)
    self.characters = {}
    self.player = nil
    return self
end

function CharacterManager:createPlayer(x, y)
    if self.player then
        error("Player already exists")
    end
    
    self.player = Player.new(x, y)
    table.insert(self.characters, self.player)
    return self.player
end

function CharacterManager:createBot(x, y)
    local bot = Bot.new(x, y)
    table.insert(self.characters, bot)
    return bot
end

function CharacterManager:removeCharacter(character)
    for i, c in ipairs(self.characters) do
        if c == character then
            table.remove(self.characters, i)
            if c == self.player then
                self.player = nil
            end
            break
        end
    end
end

function CharacterManager:getPlayer()
    return self.player
end

function CharacterManager:getAllCharacters()
    return self.characters
end

function CharacterManager:getBots()
    local bots = {}
    for _, character in ipairs(self.characters) do
        if character ~= self.player then
            table.insert(bots, character)
        end
    end
    return bots
end

return CharacterManager