-- ui.lua
local config = require("config")
local gamestate = require("gamestate")
local player = require("player")
local combat = require("combat")
local shop = require("shop")

local ui = {
    buttons = {},
    fonts = {
        tiny = love.graphics.newFont(12),
        small = love.graphics.newFont(16),
        medium = love.graphics.newFont(18),
        large = love.graphics.newFont(24),
        title = love.graphics.newFont(74),
        abyss = love.graphics.newFont(37),
        stats = love.graphics.newFont(13)
    }
}

function ui.initialize()
    ui.updateButtons(dt)
    ui.update()
end

function ui.update()
    ui.buttons = {
        pause = {
            { text = "Resume", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT / 2 - 20, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, action = function() gamestate.currentGameState = gamestate.GameState.COMBAT end },
            { text = "Run", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT / 2 + 55, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, action = combat.runFromCombat }
        },
        title = {
            { text = "Start Game", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT / 2 - 20, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentGameState = gamestate.GameState.EXPLORE; player.data.depth = 0 end },
            { text = "Quit", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT / 2 + 55, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = love.event.quit }
        },
        explore = {
            { text = "Start Expedition", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT - 400, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() player.data.depth = player.data.depth + 10; if player.data.depth > player.data.maxDepth then player.data.maxDepth = player.data.depth end; combat.generateRandomEncounter(); combat.usePrimedItems(); if ui.buttons.explore and ui.buttons.explore[1] then if player.data.depth >= 10 then ui.buttons.explore[1].text = "Continue Deeper" end end end },
            { text = "Visit Shop", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT - 320, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentGameState = gamestate.GameState.SHOP; end },
            { text = "Inventory", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT - 240, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentGameState = gamestate.GameState.INVENTORY end },
            { text = "Quit", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT - 160, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = love.event.quit }
        },
        combat = {
            { text = "Attack", x = config.GAME_WIDTH - 775, y = config.GAME_HEIGHT - 80, baseWidth = 150, baseHeight = 50, width = 150, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentCombatState = gamestate.CombatState.ATTACK; config.OXY_DEPL_MULT = 1; combat.consumeOxygen(); combat.attackEnemy() end },
            { text = "Counter", x = config.GAME_WIDTH - 575, y = config.GAME_HEIGHT - 80, baseWidth = 150, baseHeight = 50, width = 150, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentCombatState = gamestate.CombatState.COUNTER; config.OXY_DEPL_MULT = 5; combat.consumeOxygen(); combat.counterEnemy() end },
            { text = "Use Item", x = config.GAME_WIDTH - 375, y = config.GAME_HEIGHT - 80, baseWidth = 150, baseHeight = 50, width = 150, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.previousGameState = gamestate.GameState.COMBAT; gamestate.currentCombatState = gamestate.CombatState.USE_ITEM; config.OXY_DEPL_MULT = 2; combat.consumeOxygen(); gamestate.currentGameState = gamestate.GameState.INVENTORY; shop.selectedInventoryItem = nil end },
            { text = "Refill Oxygen (+5)\nRegen Health (+1)", x = config.GAME_WIDTH - 175, y = config.GAME_HEIGHT - 80, baseWidth = 150, baseHeight = 50, width = 150, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentCombatState = gamestate.CombatState.REFILL_OXYGEN; combat.consumeOxygen(); combat.enemyAttack() end }
        },
        shop = {
            { text = "Return to Depths", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT - 80, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentGameState = gamestate.GameState.EXPLORE end },
            { text = "Reroll Shop (20 " .. config.CURRENCY_NAME .. ")", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT - 440, baseWidth = 210, baseHeight = 50, width = 210, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() if player.data.currency >= 20 then player.data.currency = player.data.currency - 20; shop.generateShopItems(); combat.addToCombatLog("Shop items rerolled for 20 " .. config.CURRENCY_NAME .. "!") else combat.addToCombatLog("Not enough " .. config.CURRENCY_NAME .. " to reroll shop!") end end }
        },
        inventory = {
            { text = "Return", x = config.GAME_WIDTH / 2 - 100, y = config.GAME_HEIGHT - 60, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() if gamestate.previousGameState == gamestate.GameState.COMBAT then gamestate.currentGameState = gamestate.GameState.COMBAT else gamestate.currentGameState = gamestate.GameState.EXPLORE end end }
        },
        gameOver = {
            { text = "Try Again", x = config.GAME_WIDTH / 2 - 220, y = config.GAME_HEIGHT / 2 + 175, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = function() gamestate.currentGameState = gamestate.GameState.TITLE; player.initialize(); shop.initialize(); combat.clearCombatLog() end },
            { text = "Quit", x = config.GAME_WIDTH / 2 + 20, y = config.GAME_HEIGHT / 2 + 175, baseWidth = 200, baseHeight = 50, width = 200, height = 50, hover = false, pressed = false, animating = false, animTimer = 0, holdable = true, holdDelay = 0.2, holdTimer = 0, action = love.event.quit }
        }
    }
end

function ui.resetButtonState(btn)
    btn.hover = false
    btn.pressed = false
    btn.animating = false
    btn.animTimer = 0
    btn.holdTimer = 0
end

function ui.updateButtons(dt)
    local mx, my = love.mouse.getPosition()
    local currentButtons = ui.buttons[gamestate.currentGameState] or {}
    for _, button in ipairs(currentButtons) do
        button.hover = mx >= button.x and mx <= button.x + button.width and my >= button.y and my <= button.y + button.height
        local targetWidth, targetHeight = button.baseWidth, button.baseHeight
        if button.pressed then
            targetWidth, targetHeight = button.baseWidth * 0.9, button.baseHeight * 0.9
        end
        button.width = button.width + (targetWidth - button.width) * dt * 10
        button.height = button.height + (targetHeight - button.height) * dt * 10
        if button.animating then
            button.animTimer = button.animTimer + dt
            if button.animTimer >= 0.1 then
                button.animTimer = 0
                button.animating = false
            end
        end
        if button.holdable and button.pressed then
            button.holdTimer = button.holdTimer + dt
            if button.holdTimer >= button.holdDelay then
                button.holdTimer = 0
            end
        else
            button.holdTimer = 0
        end
    end
end

function ui.mousepressed(x, y, button)
    if button ~= 1 then return end
    local currentButtons = ui.buttons[gamestate.currentGameState] or {}
    for _, btn in ipairs(currentButtons) do
        if x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
            btn.pressed = true
            btn.animating = true
            btn.animTimer = 0
            return
        end
    end
end

function ui.mousereleased(x, y, button)
    if button ~= 1 then return end
    local currentButtons = ui.buttons[gamestate.currentGameState] or {}
    for _, btn in ipairs(currentButtons) do
        if btn.pressed and x >= btn.x and x <= btn.x + btn.width and y >= btn.y and y <= btn.y + btn.height then
            btn.pressed = false
            btn.animating = false
            if btn.action then btn.action() end
        else
            btn.pressed = false
            btn.animating = false
        end
    end
end

function ui.mousemoved(x, y, dx, dy)
    local buttonSet = ui.buttons[gamestate.currentGameState] or {}
    for _, btn in ipairs(buttonSet) do
        local buttonX, buttonY, buttonWidth, buttonHeight = btn.x, btn.y, btn.width, btn.height
        if btn.animating then
            local animProgress = btn.animTimer / 0.2
            buttonWidth = btn.baseWidth * (1 + 0.1 * (1 - animProgress))
            buttonHeight = btn.baseHeight * (1 + 0.1 * (1 - animProgress))
            buttonX = btn.x - (buttonWidth - btn.baseWidth) / 2
            buttonY = btn.y - (buttonHeight - btn.baseHeight) / 2
        end
        buttonWidth = buttonWidth
        buttonHeight = buttonHeight
        buttonX = btn.x - (buttonWidth - btn.width) / 2
        buttonY = btn.y - (buttonHeight - btn.height) / 2
        btn.hover = x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight
    end
end

return ui