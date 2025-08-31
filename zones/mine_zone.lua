local Zone = require("zones.base_zone")

local MineZone = {}
MineZone.__index = MineZone
setmetatable(MineZone, {__index = Zone})

function MineZone.new(x, y, width, height, work_required, label, color)
    local self = Zone.new(x, y, width, height, work_required, label or "Mine", color or {0.6, 0.4, 0.2})
    setmetatable(self, MineZone)
    
    self.work_rate = 10.0
    self.rubies_per_job = 3
    self.ruby_spawn_radius = 50
    self.collectable_manager = nil
    self.active_for_bots = false
    
    return self
end

function MineZone:update(dt, player)
    if not self.active or self.completed then return end
    
    if player:isInZone(self) and self.progress < self.cost then
        self.progress = self.progress + self.work_rate * dt
        
        if self.progress >= self.cost then
            self:onWorkComplete(player)
        end
    end
end

function MineZone:onWorkComplete(player)
    self:spawnRubies()
    self.progress = 0
end

function MineZone:spawnRubies()
    if not self.collectable_manager then return end
    
    local center_x = self.x + self.width / 2
    local center_y = self.y + self.height / 2
    
    for i = 1, self.rubies_per_job do
        local angle = (i - 1) * (2 * math.pi / self.rubies_per_job)
        local distance = love.math.random(20, self.ruby_spawn_radius)
        
        local ruby_x = center_x + math.cos(angle) * distance
        local ruby_y = center_y + math.sin(angle) * distance
        
        local w, h = love.graphics.getDimensions()
        ruby_x = math.max(20, math.min(w - 20, ruby_x))
        ruby_y = math.max(20, math.min(h - 20, ruby_y))
        
        self.collectable_manager:spawnRuby(ruby_x, ruby_y)
    end
end

function MineZone:setCollectableManager(manager)
    self.collectable_manager = manager
end

function MineZone:getDisplayLabel()
    return "Mine - Work to earn rubies"
end

function MineZone:getDisplayColor()
    local work_intensity = math.min(1.0, self.progress / self.cost)
    return {
        self.color[1] + work_intensity * 0.3,
        self.color[2] + work_intensity * 0.1,
        self.color[3] + work_intensity * 0.1
    }
end

function MineZone:drawExtra()
    if self.progress > 0 and not self.completed then
        love.graphics.setColor(1, 1, 0, 0.7)
        love.graphics.print("WORKING...", self.x + 5, self.y + 35)
    end
end

return MineZone