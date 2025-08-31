local CharacterGraphics = {}

function CharacterGraphics.drawBase(character)
    -- Draw collection radius
    love.graphics.setColor(character.color[1] * 0.3, character.color[2] * 0.3, character.color[3] * 0.3, 0.2)
    love.graphics.circle("line", character.x, character.y, character.collection_radius)
    
    -- Draw character
    love.graphics.setColor(character.color)
    love.graphics.circle("fill", character.x, character.y, character.radius)
end

function CharacterGraphics.drawBot(bot)
    -- Collection radius
    love.graphics.setColor(bot.color[1] * 0.3, bot.color[2] * 0.3, bot.color[3] * 0.3, 0.2)
    love.graphics.circle("line", bot.x, bot.y, bot.collection_radius)
    
    -- Pig body
    love.graphics.setColor(bot.color)
    love.graphics.circle("fill", bot.x, bot.y, bot.radius)
    
    -- Pig snout
    love.graphics.setColor(bot.color[1] * 0.8, bot.color[2] * 0.8, bot.color[3] * 0.8)
    love.graphics.circle("fill", bot.x, bot.y + 3, 5)
    
    -- Pig nostrils
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.circle("fill", bot.x - 2, bot.y + 3, 1)
    love.graphics.circle("fill", bot.x + 2, bot.y + 3, 1)
    
    -- Pig eyes
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", bot.x - 4, bot.y - 3, 2)
    love.graphics.circle("fill", bot.x + 4, bot.y - 3, 2)
    
    -- Coin count (from inventory)
    love.graphics.setColor(1, 1, 1)
    local coins = (bot.inventory and bot.inventory.getQuantity) and bot.inventory:getQuantity("coin") or 0
    love.graphics.print(string.format("%d", coins), bot.x - 5, bot.y - 20)
    
    -- State
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print(bot.state_machine:getCurrentState(), bot.x - 15, bot.y + 25)
end

function CharacterGraphics.drawChicken(chicken)
    -- Body
    love.graphics.setColor(chicken.color)
    love.graphics.circle("fill", chicken.x, chicken.y, chicken.radius)
    
    -- Eye
    love.graphics.setColor(1, 0.8, 0)
    love.graphics.circle("fill", chicken.x - 3, chicken.y - 3, 2)
    
    -- Beak
    love.graphics.setColor(1, 0.5, 0)
    local beak_x = chicken.x - chicken.radius + 2
    local beak_y = chicken.y
    love.graphics.polygon("fill", beak_x, beak_y, beak_x - 4, beak_y - 2, beak_x - 4, beak_y + 2)
    
    -- State
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print(chicken.state_machine:getCurrentState(), chicken.x - 20, chicken.y + 20)
end

return CharacterGraphics
