local config = require("config")
local gamestate = require("gamestate")
local player = require("player")
local combat = require("combat")

local shop = {
    shopItems = {},
    shopInventory = {},
    hasGeneratedItems = false
}

function shop.initialize()
    shop.shopItems = {
        { name = "Health Potion", description = "Restore 20 health", price = 10, isConsumable = true, effect = player.createHealthPotion(20) },
        { name = "Mega Health Potion", description = "Restore 50 health", price = 40, isConsumable = true, effect = player.createHealthPotion(50) },
        { name = "Attack Up", description = "Increase attack by 4", price = 30, isConsumable = false, effect = player.createStatBoost("attack", "maxAttack", 4) },
        { name = "Defense Up", description = "Increase defense by 2", price = 30, isConsumable = false, effect = player.createStatBoost("defense", "maxDefense", 2) },
        { name = "Luck Up", description = "Increase luck by 3", price = 30, isConsumable = false, effect = player.createStatBoost("luck", "maxLuck", 3) },
        { name = "Hearty Meal", description = "Increase max health by 10 + health by 10", price = 40, isConsumable = false, effect = player.createMaxHealthBoost(10) },
        { name = "Oxygen Tank", description = "Increase max oxygen by 10 and refill oxygen", price = 20, isConsumable = false, effect = function() local increase = 10; player.data.maxOxygen = math.min(config.MAX_OXYGEN, player.data.maxOxygen + increase); player.data.oxygen = math.min(player.data.maxOxygen, player.data.oxygen + increase); if player.data.maxOxygen == config.MAX_OXYGEN then return true, "Oxygen capacity reached maximum of " .. config.MAX_OXYGEN .. "!" else return true, "Oxygen capacity and current oxygen increased by " .. increase .. "!" end end },
        { name = "Oxygen Regulator", description = "Reduce oxygen consumption by 10%", price = 40, isConsumable = false, effect = function() config.OXYGEN_DEPLETION_BASE = config.OXYGEN_DEPLETION_BASE * 0.9; return true, "Oxygen regulator improved! Oxygen depletes 10% slower." end },
        { name = "Stun Bomb", description = "Skip enemy's next attack", price = 35, isConsumable = true, effect = function() if gamestate.currentGameState == gamestate.GameState.COMBAT then combat.currentEnemy.stunned = true; return true, "You used a Stun Bomb! " .. combat.currentEnemy.name .. " is stunned!" end return false, "Cannot use Stun Bomb outside combat!" end },
        { name = "Strength Serum", description = "Double attack for next turn", price = 30, isConsumable = true, effect = function() if gamestate.currentGameState == gamestate.GameState.COMBAT then player.data.tempAttackBoost = player.data.attack; return true, "You used a Strength Serum! Attack doubled for next turn!" end return false, "Cannot use Strength Serum outside combat!" end },
        { name = "Bubble Shield", description = "Negate next enemy attack", price = 35, isConsumable = true, effect = function() if gamestate.currentGameState == gamestate.GameState.COMBAT then player.data.bubbleShield = true; return true, "You deployed a Bubble Shield! Next enemy attack negated!" end return false, "Cannot use Bubble Shield outside combat!" end },
        { name = "Depth Charge", description = "Deal 20 damage to enemy", price = 35, isConsumable = true, effect = function() if gamestate.currentGameState == gamestate.GameState.COMBAT then local damage = 20; combat.currentEnemy.health = math.max(0, combat.currentEnemy.health - damage); if combat.currentEnemy.health <= 0 then combat.defeatEnemy(); return true, "You used a Depth Charge and defeated the " .. combat.currentEnemy.name .. "!" end return true, "You used a Depth Charge and dealt " .. damage .. " damage!" end return false, "Cannot use Depth Charge outside combat!" end },
        { name = "Wallet", description = "Increase max pearl cap by 500", price = 150, isConsumable = false, effect = function() local capIncrease = 500; player.data.maxCurrency = player.data.maxCurrency + capIncrease; return true, "Max pearl cap increased by " .. capIncrease .. " with the Wallet!" end }
    }
    if not shop.hasGeneratedItems then
        shop.generateShopItems()
        shop.hasGeneratedItems = true
    end
end

function shop.generateShopItems()
    local availableItems = {}
    for i = 1, #shop.shopItems do
        table.insert(availableItems, i)
    end
    shop.shopInventory = {}
    for i = 1, math.min(6, #availableItems) do
        local index = math.random(#availableItems)
        table.insert(shop.shopInventory, shop.shopItems[availableItems[index]])
        table.remove(availableItems, index)
    end
    combat.addToCombatLog("Shop inventory generated!")
end

function shop.rerollShop()
    if player.data.currency >= 50 then
        player.data.currency = player.data.currency - 50
        shop.generateShopItems()
        combat.addToCombatLog("Shop inventory rerolled for 50 " .. config.CURRENCY_NAME .. "!")
    else
        combat.addToCombatLog("Need 50 " .. config.CURRENCY_NAME .. " to reroll the shop!")
    end
end

function shop.buyItem(index)
    local item = shop.shopInventory[index]
    if not item then return end
    if player.data.currency >= item.price then
        player.data.currency = player.data.currency - item.price
        if item.isConsumable then
            if #player.data.inventory < player.data.maxInventory then
                table.insert(player.data.inventory, item)
                combat.addToCombatLog("You bought " .. item.name .. " and added it to your inventory!")
            else
                player.data.currency = player.data.currency + item.price
                combat.addToCombatLog("Inventory full! Cannot buy " .. item.name .. "! Max " .. player.data.maxInventory .. " items!")
            end
        else
            local success, message = item.effect()
            if success and message then
                combat.addToCombatLog(message)
            end
            combat.addToCombatLog("You bought " .. item.name .. "!")
        end
    else
        combat.addToCombatLog("Not enough " .. config.CURRENCY_NAME .. " to buy " .. item.name .. "!")
    end
end

function shop.mousepressed(x, y, button)
    if button ~= 1 or gamestate.currentGameState ~= gamestate.GameState.SHOP then return end

    local itemsPerRow = 3
    local itemWidth = 200
    local itemHeight = 120
    local startX = (config.GAME_WIDTH - (itemWidth * itemsPerRow + 20 * (itemsPerRow - 1))) / 2 + 10
    local startY = config.GAME_HEIGHT - 370

    -- Shop items
    for i, _ in ipairs(shop.shopInventory) do
        local row = math.floor((i - 1) / itemsPerRow)
        local col = (i - 1) % itemsPerRow
        local ix = startX + col * (itemWidth + 20)
        local iy = startY + row * (itemHeight + 20)
        if x >= ix and x <= ix + itemWidth and y >= iy and y <= iy + itemHeight then
            shop.buyItem(i)
            return
        end
    end

    -- Reroll button
    local rerollButtonX = config.GAME_WIDTH / 2 - 75
    local rerollButtonY = config.GAME_HEIGHT - 100
    local rerollButtonWidth = 150
    local rerollButtonHeight = 40
    if x >= rerollButtonX and x <= rerollButtonX + rerollButtonWidth and y >= rerollButtonY and y <= rerollButtonY + rerollButtonHeight then
        shop.rerollShop()
        return
    end
end

return shop