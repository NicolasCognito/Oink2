local CollectableGraphics = {}

function CollectableGraphics.draw(collectable)
    if collectable.collected then return end
    
    love.graphics.setColor(collectable.color)
    love.graphics.circle("fill", collectable.x, collectable.y, collectable.radius)
end

return CollectableGraphics