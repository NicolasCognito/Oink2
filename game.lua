local CollectableManager = require("collectables").CollectableManager
local ZoneManager = require("zones.zone_manager")
local UpgradeZone = require("zones.upgrade_zone")
local BuildZone = require("zones.build_zone")
local MineZone = require("zones.mine_zone")
local Services = require("utils.services")

local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    
    self.player = Services.character_manager:createPlayer()
    self.collectable_manager = CollectableManager.new()
    self.zone_manager = ZoneManager.new()
    self.bot_manager = Services.bot_manager
    
    self.player:setCollectableManager(self.collectable_manager)
    
    local upgrade_zone = UpgradeZone.new(
        100, 100, 120, 80, 50,
        "Upgrade Capacity",
        {1, 0.8, 0.2},
        5.0
    )
    upgrade_zone:setAcceptedItems({coin = true})
    self.zone_manager:addZone(upgrade_zone)
    
    local build_zone = BuildZone.new(
        300, 150, 100, 60, 30,
        "Build Bot",
        {0.2, 0.8, 0.4}
    )
    build_zone:setAcceptedItems({coin = true})
    self.zone_manager:addZone(build_zone)
    
    local mine_zone = MineZone.new(
        500, 100, 120, 80, 100,
        "Mine",
        {0.6, 0.4, 0.2}
    )
    mine_zone:setCollectableManager(self.collectable_manager)
    mine_zone:setAcceptedItems({})
    self.zone_manager:addZone(mine_zone)
    
    self.bot_manager:addBot(150, 200)
    self.bot_manager:addChicken(400, 300)
    
    return self
end

function Game:update(dt)
    self.player:update(dt)
    
    -- First: zones absorb collectables
    self.collectable_manager:processZoneAbsorption(self.zone_manager)
    
    -- Second: player collects remaining collectables
    local collected_item = self.collectable_manager:update(
        dt,
        self.player.x,
        self.player.y,
        self.player.collection_radius,
        self.player.capacity,
        self.player.carried_coins
    )
    
    if collected_item then
        if collected_item.type == "coin" then
            self.player:addCoins(collected_item.value)
        elseif collected_item.type == "egg" then
            self.player:addItem("eggs", collected_item.value)
        elseif collected_item.type == "ruby" then
            self.player:addItem("rubies", collected_item.value)
        end
    end
    
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
    love.graphics.print(string.format("Eggs: %d", self.player:getItemCount("eggs")), 10, 30)
    love.graphics.print(string.format("Rubies: %d", self.player:getItemCount("rubies")), 10, 50)
    love.graphics.print("WASD to move, SPACE to drop coins, ESC to quit", 10, 70)
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
