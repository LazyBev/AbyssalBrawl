local config = require("config")
local gamestate = require("gamestate")
local player = require("player")
local combat = require("combat")
local ui = require("ui")
local shop = require("shop")
local inventory = require("inventory")
local enemies = require("enemies")
local gameover = require("gameover")

local render = {}
local drawFunctions = {
    Jellyfish = enemies.drawJellyfish,
    Angler = enemies.drawAngler,
    Squid = enemies.drawSquid,
    Kraken = enemies.drawKraken,
    Leviathan = enemies.drawLeviathan
}

function render.drawEnemy()
    if not combat.currentEnemy then return end
    local x, y = config.GAME_WIDTH / 2, config.GAME_HEIGHT / 2 - 50
    local drawFunc = drawFunctions[combat.currentEnemy.name]
    if drawFunc then
        drawFunc(x, y, combat.currentEnemy.animState, combat.currentEnemy.baseColor)
    else
        love.graphics.setColor(0.5, 0.5, 1, 1)
        love.graphics.circle("fill", x, y, 75)
    end
    combat.currentEnemy.animState = 0
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(ui.fonts.small)
    love.graphics.printf(combat.currentEnemy.name, x - 100, y - 100, 200, "center")
    love.graphics.setColor(0.7, 0.2, 0.2)
    love.graphics.rectangle("fill", x - 50, y + 100, 100, 15)
    love.graphics.setColor(0.2, 0.7, 0.2)
    love.graphics.rectangle("fill", x - 50, y + 100, (combat.currentEnemy.health / combat.currentEnemy.maxHealth) * 100, 15)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x - 50, y + 100, 100, 15)
    love.graphics.printf(math.floor(combat.currentEnemy.health) .. "/" .. combat.currentEnemy.maxHealth, x - 50, y + 99, 100, "center")
end

function render.drawPlayerStats()
    love.graphics.setFont(ui.fonts.stats)

    -- Player Stats
    local xOffset, barWidth, barHeight, spacing = 25, 190, 20, 10
    local startX, startY = config.GAME_WIDTH - 220 + xOffset, 20

    -- Function to draw a single bar
    local function drawBar(label, value, max, colorBack, colorFront, x, y)
        love.graphics.setColor(colorBack)
        love.graphics.rectangle("fill", x, y, barWidth, barHeight)
        love.graphics.setColor(colorFront)
        love.graphics.rectangle("fill", x, y, (value / max) * barWidth, barHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", x, y, barWidth, barHeight)
        love.graphics.print(label .. ": " .. math.floor(value) .. "/" .. max, x + 20, y + 2)
    end

    local y = startY
    drawBar("Health", player.data.health, player.data.maxHealth, {0.5, 0.2, 0.2}, {0.2, 0.7, 0.2}, startX, y)
    y = y + barHeight + spacing
    drawBar("Oxygen", player.data.oxygen, player.data.maxOxygen, {0.2, 0.2, 0.5}, {0.2, 0.6, 1.0}, startX, y)

    if gamestate.currentGameState ~= gamestate.GameState.COMBAT then
        y = y + barHeight + spacing
        drawBar("Attack", player.data.attack, player.data.maxAttack, {0.5, 0.3, 0.2}, {0.8, 0.4, 0.2}, startX, y)
        y = y + barHeight + spacing
        drawBar("Defense", player.data.defense, player.data.maxDefense, {0.3, 0.3, 0.3}, {0.6, 0.6, 0.6}, startX, y)
        y = y + barHeight + spacing
        drawBar("Luck", player.data.luck, player.data.maxLuck, {0.4, 0.5, 0.2}, {0.6, 0.8, 0.3}, startX, y)
        y = y + barHeight + spacing
        drawBar(config.CURRENCY_NAME, player.data.currency, player.data.maxCurrency, {0.5, 0.4, 0.2}, {1.0, 0.8, 0.2}, startX, y)
        y = y + barHeight + spacing
        drawBar("Items", #player.data.inventory + #player.data.primedCombatItems, player.data.maxInventory, {0.3, 0.2, 0.4}, {0.6, 0.4, 0.8}, startX, y)
    end

    -- Enemy Stats
    if enemy and enemy.data then
        local enemyStartX = xOffset
        local enemyStartY = 20
        local ey = enemyStartY

        drawBar("Enemy HP", enemy.data.health, enemy.data.maxHealth, {0.4, 0.1, 0.1}, {0.8, 0.2, 0.2}, enemyStartX, ey)

        -- Optional: add more enemy stats like attack, defense, etc.
        -- ey = ey + barHeight + spacing
        -- drawBar("Enemy Attack", enemy.data.attack, enemy.data.maxAttack, {0.3, 0.1, 0.1}, {0.8, 0.3, 0.3}, enemyStartX, ey)
    end
end


function render.drawCombatLog()
    love.graphics.setFont(ui.fonts.tiny)
    for i = 1, #combat.combatLog.entries do
        local idx = (combat.combatLog.head - 1 - i) % combat.combatLog.maxSize + 1
        if combat.combatLog.entries[idx] then
            love.graphics.setColor(1, 1, 1, 1 - i * 0.2)
            love.graphics.print(combat.combatLog.entries[idx], 20, config.GAME_HEIGHT - 140 - (i * 20))
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function render.drawTitle()
    love.graphics.setShader(shaders.background)
    love.graphics.rectangle("fill", 0, 0, config.GAME_WIDTH, config.GAME_HEIGHT)
    love.graphics.setShader()
    love.graphics.setFont(ui.fonts.title)
    love.graphics.setColor(0.5, 0.7, 1.0, 1.0)
    love.graphics.printf("Abyssal Brawl", 0, config.GAME_HEIGHT / 7, config.GAME_WIDTH, "center")
    love.graphics.setFont(ui.fonts.medium)
    love.graphics.setColor(0.7, 0.8, 1.0, 0.8)
    love.graphics.printf("A Deep Sea Roguelike", 0, config.GAME_HEIGHT / 6 + 70, config.GAME_WIDTH, "center")
    render.drawButtons(ui.buttons.title)
end

function render.drawExplore()
    love.graphics.setShader(shaders.fight)
    love.graphics.rectangle("fill", 0, 0, config.GAME_WIDTH, config.GAME_HEIGHT)
    love.graphics.setShader()
    local yOffset = 150
    love.graphics.setFont(ui.fonts.abyss)
    love.graphics.setColor(0, 0, 0, 0.5) love.graphics.printf("Explore the Abyss", 2, -62 + yOffset, config.GAME_WIDTH, "center")
    love.graphics.setColor(0.5, 0.7, 1, 1) love.graphics.printf("Explore the Abyss", 0, -60 + yOffset, config.GAME_WIDTH, "center")
    local gaugeWidth, gaugeHeight, gaugeX, gaugeY = 225, 80, (config.GAME_WIDTH - 230), 100 + yOffset
    love.graphics.setColor(0.2, 0.3, 0.5, 0.7) love.graphics.rectangle("fill", gaugeX, gaugeY, gaugeWidth, gaugeHeight, 10, 10)
    love.graphics.setColor(0.8, 0.9, 1, 0.5) love.graphics.rectangle("line", gaugeX, gaugeY, gaugeWidth, gaugeHeight, 10, 10)
    love.graphics.setFont(ui.fonts.large)
    love.graphics.setColor(0, 0, 0, 0.5) love.graphics.printf("Depth: " .. player.data.depth .. "m", gaugeX + 2, gaugeY + 12, gaugeWidth, "center")
    love.graphics.setColor(1, 1, 1, 0.9) love.graphics.printf("Depth: " .. player.data.depth .. "m", gaugeX, gaugeY + 10, gaugeWidth, "center")
    love.graphics.setFont(ui.fonts.medium)
    love.graphics.setColor(0, 0, 0, 0.5) love.graphics.printf("Max Depth: " .. player.data.maxDepth .. "m", gaugeX + 2, gaugeY + 47, gaugeWidth, "center")
    love.graphics.setColor(0.7, 0.8, 1, 0.9) love.graphics.printf("Max Depth: " .. player.data.maxDepth .. "m", gaugeX, gaugeY + 45, gaugeWidth, "center")
    render.drawButtons(ui.buttons.explore, true)
    render.drawPlayerStats()
end

function render.drawCombat()
    love.graphics.setShader(shaders.fight)
    love.graphics.rectangle("fill", 0, 0, config.GAME_WIDTH, config.GAME_HEIGHT)
    love.graphics.setShader()
    render.drawEnemy()
    render.drawCombatLog()
    render.drawButtons(ui.buttons.combat)
    render.drawPlayerStats()
end

function render.drawShop()
    love.graphics.setShader(shaders.swirl)
    love.graphics.rectangle("fill", 0, 0, config.GAME_WIDTH, config.GAME_HEIGHT)
    love.graphics.setShader()
    love.graphics.setFont(ui.fonts.large)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Deep Sea Shop", 0, 70, config.GAME_WIDTH, "center")
    love.graphics.setFont(ui.fonts.medium)
    love.graphics.printf(config.CURRENCY_NAME .. ": " .. player.data.currency, 0, 120, config.GAME_WIDTH, "center")
    local itemsPerRow, itemWidth, itemHeight, startX, startY = 3, 200, 120, (config.GAME_WIDTH - (200 * 3 + 20 * 2)) / 2, config.GAME_HEIGHT - 370
    for i, item in ipairs(shop.shopInventory) do
        local row, col = math.floor((i - 1) / itemsPerRow), (i - 1) % itemsPerRow
        local x, y = startX + col * (itemWidth + 20) + 10, startY + row * (itemHeight + 20) + 5
        local mx, my = love.mouse.getPosition()
        local hover = mx >= x and mx <= x + itemWidth and my >= y and my <= y + itemHeight
        love.graphics.setColor(hover and {0.3, 0.5, 0.8, 0.8} or {0.2, 0.3, 0.6, 0.7})
        love.graphics.rectangle("fill", x, y, itemWidth, itemHeight, 5, 5)
        love.graphics.setColor(0.5, 0.7, 1.0, hover and 1.0 or 0.7)
        love.graphics.rectangle("line", x, y, itemWidth, itemHeight, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ui.fonts.medium)
        love.graphics.printf(item.name, x + 10, y + 10, itemWidth - 20, "center")
        love.graphics.setFont(ui.fonts.tiny)
        love.graphics.printf(item.description, x + 10, y + 40, itemWidth - 20, "center")
        love.graphics.setColor(player.data.currency >= item.price and {0.2, 1.0, 0.2} or {1.0, 0.2, 0.2})
        love.graphics.printf(item.price .. " " .. config.CURRENCY_NAME, x + 10, y + itemHeight - 30, itemWidth - 20, "center")
        if item.isConsumable then
            love.graphics.setColor(1, 1, 0.5)
            love.graphics.printf("(Consumable)", x + 10, y + itemHeight - 50, itemWidth - 20, "center")
        end
    end

    render.drawButtons(ui.buttons.shop)
    render.drawPlayerStats()
end

function render.drawInventory()
    love.graphics.setShader(shaders.swirl)
    love.graphics.rectangle("fill", 0, 0, config.GAME_WIDTH, config.GAME_HEIGHT)
    love.graphics.setShader()
    love.graphics.setFont(ui.fonts.large)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Inventory", 0, 50, config.GAME_WIDTH, "center")
    if #player.data.inventory == 0 and #player.data.primedCombatItems == 0 then
        love.graphics.setFont(ui.fonts.medium)
        love.graphics.printf("Your inventory is empty", 0, config.GAME_HEIGHT / 2 - 20, config.GAME_WIDTH, "center")
    else
        love.graphics.setFont(ui.fonts.medium)
        love.graphics.printf("Items (" .. #player.data.inventory .. "/" .. player.data.maxInventory .. ")", 0, 100, config.GAME_WIDTH, "center")
        local itemsPerRow, itemWidth, itemHeight, startX, startY = 4, 150, 100, (config.GAME_WIDTH - (150 * 4 + 20 * 3)) / 2, 150
        for i, item in ipairs(player.data.inventory) do
            local row, col = math.floor((i - 1) / itemsPerRow), (i - 1) % itemsPerRow
            local x, y = startX + col * (itemWidth + 20), startY + row * (itemHeight + 20)
            local mx, my = love.mouse.getPosition()
            local hover, selected = mx >= x and mx <= x + itemWidth and my >= y and my <= y + itemHeight, i == inventory.selectedItem
            love.graphics.setColor(selected and {0.4, 0.8, 0.4, 0.8} or hover and {0.3, 0.5, 0.8, 0.8} or {0.2, 0.3, 0.6, 0.7})
            love.graphics.rectangle("fill", x, y, itemWidth, itemHeight, 5, 5)
            love.graphics.setColor(selected and {0.5, 1.0, 0.5, 1.0} or {0.5, 0.7, 1.0, hover and 1.0 or 0.7})
            love.graphics.rectangle("line", x, y, itemWidth, itemHeight, 5, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(ui.fonts.tiny)
            love.graphics.printf(item.name, x + 5, y + 10, itemWidth - 10, "center")
            love.graphics.printf(item.description, x + 5, y + 40, itemWidth - 10, "center")
            love.graphics.setColor(1, 1, 0.5)
            love.graphics.printf("(Primes for Combat)", x + 5, y + itemHeight - 25, itemWidth - 10, "center")
        end
        local primedStartY = startY + (#player.data.inventory > 0 and math.ceil(#player.data.inventory / itemsPerRow) * (itemHeight + 20) + 100 or 100)
        love.graphics.setFont(ui.fonts.medium)
        love.graphics.printf("Primed Items (" .. #player.data.primedCombatItems .. "/" .. player.data.maxInventory .. ")", 0, primedStartY - 50, config.GAME_WIDTH, "center")
        for i, item in ipairs(player.data.primedCombatItems) do
            local row, col = math.floor((i - 1) / itemsPerRow), (i - 1) % itemsPerRow
            local x, y = startX + col * (itemWidth + 20), primedStartY + row * (itemHeight + 20)
            local mx, my = love.mouse.getPosition()
            local hover = mx >= x and mx <= x + itemWidth and my >= y and my <= y + itemHeight
            love.graphics.setColor(0.5, 0.3, 0.6, 0.7)
            love.graphics.rectangle("fill", x, y, itemWidth, itemHeight, 5, 5)
            love.graphics.setColor(0.7, 0.5, 1.0, hover and 1.0 or 0.7)
            love.graphics.rectangle("line", x, y, itemWidth, itemHeight, 5, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(ui.fonts.tiny)
            love.graphics.printf(item.name, x + 5, y + 10, itemWidth - 10, "center")
            love.graphics.printf(item.description, x + 5, y + 40, itemWidth - 10, "center")
            love.graphics.setColor(1, 0.5, 0.5)
            love.graphics.printf("(Primed for Combat)", x + 5, y + itemHeight - 25, itemWidth - 10, "center")
        end
    end
    if inventory.selectedItem and player.data.inventory[inventory.selectedItem] then
        local buttonX, buttonY, buttonWidth, buttonHeight = config.GAME_WIDTH / 2 - 75, config.GAME_HEIGHT - 120, 150, 40
        love.graphics.setColor(0.2, 0.7, 0.3, 0.8)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 5, 5)
        love.graphics.setColor(0.5, 1.0, 0.5, 1.0)
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight, 5, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(ui.fonts.medium)
        love.graphics.printf(gamestate.currentGameState == gamestate.GameState.COMBAT and "Use Item" or "Prime Item", buttonX, buttonY + 10, buttonWidth, "center")
    end
    render.drawButtons(ui.buttons.inventory)
    render.drawPlayerStats()
end

function render.drawPause()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, config.GAME_WIDTH, config.GAME_HEIGHT)
    love.graphics.setFont(ui.fonts.large)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Paused", 0, config.GAME_HEIGHT / 2 - 75, config.GAME_WIDTH, "center")
    render.drawButtons(ui.buttons.pause)
    render.drawPlayerStats()
end

function render.drawGameOver()
    -- Set background shader
    love.graphics.setShader(shaders.lost)
    love.graphics.rectangle("fill", 0, 0, config.GAME_WIDTH, config.GAME_HEIGHT)
    love.graphics.setShader()

    if player.data.health <= 0 then
        -- Title display
        love.graphics.setFont(ui.fonts.title)
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.printf("You got killed", 0, config.GAME_HEIGHT / 7 - 25, config.GAME_WIDTH, "center")
    elseif player.data.oxygen <= 0 then
        -- Title display
        love.graphics.setFont(ui.fonts.title)
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.printf("You suffocated", 0, config.GAME_HEIGHT / 7 - 25, config.GAME_WIDTH, "center")
    end
    
    -- Stats box
    local boxWidth, boxHeight = 400, 250
    local boxX, boxY = (config.GAME_WIDTH/2 - boxWidth/2), (config.GAME_HEIGHT/2 - boxHeight/2) + 20
    
    -- Draw semi-transparent stats box
    love.graphics.setColor(0.1, 0.2, 0.3, 0.8)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10, 10)
    love.graphics.setColor(0.5, 0.7, 1.0, 0.8)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10, 10)
    
    -- Header
    love.graphics.setFont(ui.fonts.large)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Expedition Results", boxX, boxY + 15, boxWidth, "center")
    
    -- Stats display
    love.graphics.setFont(ui.fonts.medium)
    local textY = boxY + 60
    local lineHeight = ui.fonts.medium:getHeight() + 10
    
    love.graphics.setColor(0.9, 0.9, 1.0, 0.9)
    love.graphics.printf("Final Depth: " .. player.data.depth .. "m / " .. player.data.maxDepth .. "m", boxX + 20, textY, boxWidth - 40, "left")
    textY = textY + lineHeight
    
    love.graphics.printf("Enemies Defeated: " .. player.data.enemiesDefeated, boxX + 20, textY, boxWidth - 40, "left")
    textY = textY + lineHeight
    
    love.graphics.printf("Items Used: " .. player.data.itemsUsed, boxX + 20, textY, boxWidth - 40, "left")
    textY = textY + lineHeight
    
    love.graphics.printf(config.CURRENCY_NAME .. " Collected: " .. player.data.currencyCollected, boxX + 20, textY, boxWidth - 40, "left")
    textY = textY + lineHeight
    
    love.graphics.printf("Time Survived: " .. gameover.formatTime(player.data.timeAlive), boxX + 20, textY, boxWidth - 40, "left")

    render.drawButtons(ui.buttons.gameOver)
end

function render.drawButtons(buttons, isExplore)
    for _, btn in ipairs(buttons) do
        local buttonWidth, buttonHeight, buttonX, buttonY = btn.width, btn.height, btn.x, btn.y
        if btn.animating then
            local animProgress = btn.animTimer / 0.2
            buttonWidth = btn.baseWidth * (1 + 0.1 * (1 - animProgress))
            buttonHeight = btn.baseHeight * (1 + 0.1 * (1 - animProgress))
            buttonX = btn.x - (buttonWidth - btn.baseWidth) / 2
            buttonY = btn.y - (buttonHeight - btn.baseHeight) / 2
        end
        if btn.hover then
            love.graphics.setColor(0.5, 0.7, 1, 0.3)
            love.graphics.rectangle("fill", buttonX - 5, buttonY - 5, buttonWidth + 10, buttonHeight + 10, 12, 12)
        end
        love.graphics.setColor(btn.pressed and {0.4, 0.5, 0.8, 0.9} or btn.hover and {0.3, 0.5, 0.9, 0.8} or {0.2, 0.3, 0.6, 0.7})
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 8, 8)
        love.graphics.setColor(0.8, 0.9, 1, 0.8)
        love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight, 8, 8)
        love.graphics.setFont(isExplore and ui.fonts.small or (gamestate.currentGameState == gamestate.GameState.SHOP and ui.fonts.small or ui.fonts.medium))
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.printf(btn.text, buttonX + 2, buttonY + buttonHeight/2 - ui.fonts.medium:getHeight()/2 + 2, buttonWidth, "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(btn.text, buttonX, buttonY + buttonHeight/2 - ui.fonts.medium:getHeight()/2, buttonWidth, "center")
    end
end

function render.draw()
    if player.data.depth == player.data.maxDepth or player.data.health == 0 then
        gamestate.currentGameState = gamestate.GameState.GAME_OVER
    end

    if gamestate.currentGameState == gamestate.GameState.TITLE then
        render.drawTitle()
    elseif gamestate.currentGameState == gamestate.GameState.EXPLORE then
        gamestate.previousGameState = gamestate.GameState.TITLE
        render.drawExplore()
    elseif gamestate.currentGameState == gamestate.GameState.COMBAT then
        gamestate.previousGameState = gamestate.GameState.EXPLORE
        render.drawCombat()
    elseif gamestate.currentGameState == gamestate.GameState.SHOP then
        gamestate.previousGameState = gamestate.GameState.EXPLORE
        render.drawShop()
    elseif gamestate.currentGameState == gamestate.GameState.INVENTORY then
        render.drawInventory()
    elseif gamestate.currentGameState == gamestate.GameState.GAME_OVER then
        gamestate.previousGameState = gamestate.GameState.COMBAT
        render.drawGameOver()
    elseif gamestate.currentGameState == gamestate.GameState.PAUSE then
        gamestate.previousGameState = gamestate.GameState.COMBAT
        render.drawCombat()
        render.drawPause()
    end
end

return render