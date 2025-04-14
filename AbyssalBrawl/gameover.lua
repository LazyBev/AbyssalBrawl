local config = require("config")
local gamestate = require("gamestate")
local player = require("player")
local ui = require("ui")
local shaders = require("shaders")

local gameover = {}

function gameover.initialize()
    -- Capture current statistics
    gameover.stats.depth = player.data.depth
    gameover.stats.maxDepth = player.data.maxDepth
    gameover.stats.timeAlive = gamestate.gameTime
    
    -- These would be tracked during gameplay
    -- For now we'll just set them based on depth as a placeholder
    gameover.stats.enemiesDefeated = math.floor(player.data.depth / 20)
    gameover.stats.itemsUsed = math.floor(player.data.depth / 30)
    gameover.stats.currencyCollected = player.data.currency
end

function gameover.formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = math.floor(seconds % 60)
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

function gameover.keypressed(key)
    if key == "space" or key == "return" then
        gamestate.currentGameState = gamestate.GameState.TITLE
        player.initialize()
        gameover.reset()
    end
end

function gameover.mousepressed(x, y, button)
    if button ~= 1 then return end
    local currentButtons = ui.buttons.gameOver or {}
    for _, btn in ipairs(currentButtons) do
        if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
            btn.pressed = true
            btn.animating = true
            btn.animTimer = 0
            return
        end
    end
end

return gameover