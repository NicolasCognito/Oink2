local Game = require("game")

local game

function love.load()
    love.window.setTitle("Arcade Idle Circle")
    love.window.setMode(800, 600)
    
    game = Game.new()
    game.player.x = love.graphics.getWidth() / 2
    game.player.y = love.graphics.getHeight() / 2
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "q" then
        if game and game.cycleZoneMode then game:cycleZoneMode(-1) end
    elseif key == "e" then
        if game and game.cycleZoneMode then game:cycleZoneMode(1) end
    elseif key == "x" then
        if game and game.toggleZoneActive then game:toggleZoneActive() end
    elseif key == "space" then
        if game and game.player then
            game.player:toggleAutoDrop()
        end
    end
end
