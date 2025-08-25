local Zone = {}
Zone.__index = Zone

function Zone.new(x, y, width, height, cost, label, color)
    local self = setmetatable({}, Zone)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.progress = 0
    self.cost = cost
    self.label = label
    self.color = color or {1, 1, 1}
    self.completed = false
    self.spend_rate = 8.0
    return self
end

function Zone:update(dt, player)
    if player:isInZone(self) and player.carried_coins > 0 and self.progress < self.cost then
        local spend_amount = math.min(self.spend_rate * dt, player.carried_coins, self.cost - self.progress)
        self.progress = self.progress + spend_amount
        player:spendCoins(spend_amount)
        
        if self.progress >= self.cost then
            self:onComplete(player)
        end
    end
end

function Zone:onComplete(player)
    self.completed = true
end

function Zone:draw()
    love.graphics.setColor(self.color[1] * 0.3, self.color[2] * 0.3, self.color[3] * 0.3)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(self.color)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    if self.progress > 0 and not self.completed then
        local progress_width = (self.progress / self.cost) * self.width
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.7)
        love.graphics.rectangle("fill", self.x, self.y, progress_width, self.height)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(self.label, self.x + 5, self.y + 5)
    love.graphics.print(string.format("%.1f/%.0f", self.progress, self.cost), self.x + 5, self.y + 20)
    
    if self.completed then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("BUILT!", self.x + self.width/2 - 20, self.y + self.height/2)
    end
end

return Zone