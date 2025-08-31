local CharacterManager = require("utils.character_manager")
local BotManager = require("bots.bot_manager")

local Services = {}

-- Shared service registry (singleton-style). Assign from Game, read from anywhere.
Services.character_manager = CharacterManager.new()
Services.bot_manager = BotManager.new()

-- Wire up dependencies after all managers are created
Services.bot_manager:setCharacterManager(Services.character_manager)

return Services

