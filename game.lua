local CollectableManager = require("collectables").CollectableManager
local ZoneManager = require("zones.zone_manager")
local UpgradeZone = require("zones.upgrade_zone")
local BuildZone = require("zones.build_zone")
local BotManager = require("bots.bot_manager")
local Services = require("utils.services")

local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    
    self.player = Services.character_manager:createPlayer()
    self.collectable_manager = CollectableManager.new()
    self.zone_manager = ZoneManager.new()
    self.bot_manager = BotManager.new()
    Services.bot_manager = self.bot_manager
    
    local upgrade_zone = UpgradeZone.new(
        100, 100, 120, 80, 50,
        "Upgrade Capacity",
        {1, 0.8, 0.2},
        5.0
    )
    self.zone_manager:addZone(upgrade_zone)
    
    local build_zone = BuildZone.new(
        300, 150, 100, 60, 30,
        "Build Bot",
        {0.2, 0.8, 0.4}
    )
    self.zone_manager:addZone(build_zone)
    
    Services.character_manager:createBot(150, 200)
    self.bot_manager:addChicken(400, 300)
    
    return self
end

function Game:update(dt)
    self.player:update(dt)
    
    local coins_collected = self.collectable_manager:update(
        dt,
        self.player.x,
        self.player.y,
        self.player.collection_radius,
        self.player.capacity,
        self.player.carried_coins
    )
    
    self.player:addCoins(coins_collected)
    
    self.zone_manager:update(dt, self.player)
    
    self.bot_manager:update(dt, self.collectable_manager, self.zone_manager)
end

function Game:draw()
    love.graphics.setColor(18/255, 18/255, 22/255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getDimensions())
    
    self.zone_manager:draw()
    self.collectable_manager:draw()
    self.player:draw()
    self.bot_manager:draw()
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("Coins: %.0f/%.0f", self.player.carried_coins, self.player.capacity), 10, 10)
    love.graphics.print("WASD to move, ESC to quit", 10, 30)
end

function Game:cycleZoneMode(delta)
    if not self.zone_manager or not self.zone_manager.zones then return end
    for _, zone in ipairs(self.zone_manager.zones) do
        if self.player:isInZone(zone) and zone.cycleMode then
            zone:cycleMode(delta)
            break
        end
    end
end

function Game:toggleZoneActive()
    if not self.zone_manager or not self.zone_manager.zones then return end
    for _, zone in ipairs(self.zone_manager.zones) do
        if self.player:isInZone(zone) and zone.toggleActive then
            zone:toggleActive()
            break
        end
    end
end

return Game
