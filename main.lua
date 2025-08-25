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
    if key == "escape" or key == "q" then
        love.event.quit()
    end
end