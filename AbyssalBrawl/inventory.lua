local config = require("config")
local gamestate = require("gamestate")
local player = require("player")
local combat = require("combat")

local inventory = {
    selectedItem = nil
}

function inventory.useItem(index)
    if not player.data.inventory[index] then return end
    local item = player.data.inventory[index]
    if gamestate.previousGameState == gamestate.GameState.COMBAT then
        local success, message = item.effect()
        if success then
            table.remove(player.data.inventory, index)
            if message then combat.addToCombatLog(message) end
            combat.addToCombatLog("You used " .. item.name .. "!")
            if not item.isConsumable then combat.enemyAttack() end
        elseif message then
            combat.addToCombatLog(message)
        end
    else
        if #player.data.primedCombatItems < player.data.maxInventory then
            table.insert(player.data.primedCombatItems, item)
            table.remove(player.data.inventory, index)
            combat.addToCombatLog("You primed " .. item.name .. " for combat!")
        else
            combat.addToCombatLog("Primed items full! Max " .. player.data.maxInventory .. "!")
        end
    end
    player.data.itemsUsed = player.data.itemsUsed + 1
end

function inventory.mousepressed(x, y, button)
    if button ~= 1 or gamestate.currentGameState ~= gamestate.GameState.INVENTORY then return end

    local itemsPerRow = 4
    local itemWidth = 150
    local itemHeight = 100
    local startX = (config.GAME_WIDTH - (itemWidth * itemsPerRow + 20 * (itemsPerRow - 1))) / 2
    local startY = 150

    -- Select an item
    for i, _ in ipairs(player.data.inventory) do
        local row = math.floor((i - 1) / itemsPerRow)
        local col = (i - 1) % itemsPerRow
        local ix = startX + col * (itemWidth + 20)
        local iy = startY + row * (itemHeight + 20)
        if x >= ix and x <= ix + itemWidth and y >= iy and y <= iy + itemHeight then
            inventory.selectedItem = i
            return
        end
    end

    -- Use selected item if "Use" button is clicked
    if inventory.selectedItem and player.data.inventory[inventory.selectedItem] then
        local buttonX = config.GAME_WIDTH / 2 - 75
        local buttonY = config.GAME_HEIGHT - 120
        local buttonWidth = 150
        local buttonHeight = 40
        if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
            inventory.useItem(inventory.selectedItem)
            inventory.selectedItem = nil
            return
        end
    end
end

return inventory