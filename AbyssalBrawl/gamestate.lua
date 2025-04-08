-- gamestate.lua

local config = require("config")

local gamestate = {
    GameState = {
        TITLE = "title",
        EXPLORE = "explore",
        COMBAT = "combat",
        SHOP = "shop",
        INVENTORY = "inventory",
        PAUSE = "pause",
        GAME_OVER = "gameOver"
    },
    CombatState = {
        ATTACK = 1,
        COUNTER = 2,
        USE_ITEM = 3,
        REFILL_OXYGEN = 4
    },
    currentGameState = nil,
    previousGameState = nil,
    currentCombatState = nil,
    gameTime = 0,
    depthLevel = 1
}

function gamestate.isGameplayState()
    return gamestate.currentGameState ~= gamestate.GameState.GAME_OVER and
           gamestate.currentGameState ~= gamestate.GameState.TITLE
end

function gamestate.initialize()
    gamestate.currentGameState = gamestate.GameState.TITLE
    gamestate.previousGameState = gamestate.GameState.TITLE
end

return gamestate