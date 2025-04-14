local config = require("config")
local gamestate = require("gamestate")
local player = require("player")
local enemies = require("enemies")

local combat = {
    currentEnemy = nil,
    combatLog = { maxSize = 5, entries = {}, head = 1 },
    TurnState = {
        PLAYER = "PLAYER_TURN",
        ENEMY = "ENEMY_TURN"
    },
    turnState = "PLAYER_TURN",
    statusEffects = { player = {}, enemy = {} }
}

-- Combat log management
function combat.addToCombatLog(text)
    combat.combatLog.entries[combat.combatLog.head] = text
    combat.combatLog.head = (combat.combatLog.head % combat.combatLog.maxSize) + 1
end

function combat.clearCombatLog()
    combat.combatLog.entries = {}
    combat.combatLog.head = 1
end

-- Enemy generation with abilities
function combat.generateRandomEncounter()
    local enemyOptions = {}
    for i = 1, #enemies.list do
        if enemies.list[i].type <= math.min(3, math.max(1, math.floor(gamestate.depthLevel / 5))) then
            table.insert(enemyOptions, enemies.list[i])
        end
    end
    local selectedEnemy = enemies.getRandomEnemy(gamestate.depthLevel)
    combat.currentEnemy = {
        name = selectedEnemy.name,
        health = selectedEnemy.baseHealth,
        maxHealth = selectedEnemy.baseHealth,
        attack = selectedEnemy.baseAttack,
        defense = selectedEnemy.baseDefense,
        currency = selectedEnemy.currency,
        baseColor = selectedEnemy.baseColor,
        animState = 0,
        ability = combat.getEnemyAbility(selectedEnemy.name)
    }
    combat.turnState = combat.TurnState.PLAYER
    combat.statusEffects = { player = {}, enemy = {} }
    gamestate.currentGameState = gamestate.GameState.COMBAT
    combat.addToCombatLog("A wild " .. combat.currentEnemy.name .. " appears!")
end

function combat.getEnemyAbility(enemyName)
    local ability = enemies.getAbility(enemyName)  -- Corrected to use enemyName
    return ability or { name = "Basic Attack", chance = 0, effect = nil, damage = 0, duration = 0 }
end

-- Status effects
function combat.applyStatusEffect(target, effect, duration, damage)
    combat.statusEffects[target][effect] = { duration = duration, damage = damage or 0 }
end

function combat.usePrimedItems()
    for i = #player.data.primedCombatItems, 1, -1 do
        local item = player.data.primedCombatItems[i]
        local success, message = item.effect()
        if success then
            if message then combat.addToCombatLog(message) end
            combat.addToCombatLog("Auto-used " .. item.name .. "!")
        elseif message then
            combat.addToCombatLog("Auto-failed " .. item.name .. ": " .. message)
        end
        table.remove(player.data.primedCombatItems, i)
    end
end

function combat.updateStatusEffects()
    if not combat.currentEnemy then return end
    for target, effects in pairs(combat.statusEffects) do
        for effect, data in pairs(effects) do
            if data.duration > 0 then
                data.duration = data.duration - 1
                if data.damage > 0 then
                    if target == "player" then
                        player.data.health = math.max(0, player.data.health - data.damage)
                        combat.addToCombatLog("You suffer " .. data.damage .. " damage from " .. effect .. "!")
                    else
                        combat.currentEnemy.health = math.max(0, combat.currentEnemy.health - data.damage)
                        combat.addToCombatLog(combat.currentEnemy.name .. " suffers " .. data.damage .. " damage from " .. effect .. "!")
                    end
                end
                if data.duration == 0 then
                    effects[effect] = nil
                    combat.addToCombatLog((target == "player" and "You" or combat.currentEnemy.name) .. " recover from " .. effect .. "!")
                end
            end
        end
    end
end

-- Enemy turn logic
function combat.enemyAttack()
    if not combat.currentEnemy then
        combat.addToCombatLog("No enemy to attack!")
        gamestate.currentGameState = gamestate.GameState.EXPLORE
        return
    end

    if combat.currentEnemy.stunned then
        combat.addToCombatLog(combat.currentEnemy.name .. " is stunned and cannot act!")
        combat.currentEnemy.stunned = false
        combat.currentEnemy.animState = 0
        return
    end

    combat.currentEnemy.animState = 1
    local critChance = 10 + combat.currentEnemy.attack * 0.5
    local isCrit = math.random(100) <= critChance
    local baseDamage = combat.currentEnemy.attack * (isCrit and 1.5 or 1) * (0.9 + math.random() * 0.2)
    local damage = math.max(0, baseDamage - (player.data.defense + (player.data.defenseBoost or 0)))

    if player.data.bubbleShield then
        combat.addToCombatLog("Your Bubble Shield absorbed the " .. combat.currentEnemy.name .. "'s attack!")
        player.data.bubbleShield = nil
    else
        player.data.health = math.max(0, player.data.health - damage)
        combat.addToCombatLog(combat.currentEnemy.name .. " " .. (isCrit and "critically " or "") .. "attacks for " .. math.floor(damage) .. " damage!")
    end

    if math.random() < combat.currentEnemy.ability.chance then
        local ability = combat.currentEnemy.ability
        combat.addToCombatLog(combat.currentEnemy.name .. " uses " .. ability.name .. "!")
        if ability.damage > 0 then
            player.data.health = math.max(0, player.data.health - ability.damage)
            combat.addToCombatLog("You take " .. ability.damage .. " additional damage!")
        end
        if ability.effect then
            combat.applyStatusEffect("player", ability.effect, ability.duration, ability.effect == "poison" and 2 or ability.effect == "bleed" and 3 or 0)
            combat.addToCombatLog("You are afflicted with " .. ability.effect .. "!")
        end
    end

    combat.checkPlayerStatus()
end

function combat.checkPlayerStatus()
    if not combat.currentEnemy then return end
    if player.data.health <= 0 then
        combat.addToCombatLog("You were vanquished by the " .. combat.currentEnemy.name .. "!")
        gamestate.currentGameState = gamestate.GameState.GAME_OVER
        combat.currentEnemy = nil
    elseif player.data.oxygen <= 0 then
        combat.addToCombatLog("You suffocated in the abyss!")
        gamestate.currentGameState = gamestate.GameState.GAME_OVER
        combat.currentEnemy = nil
    end
end

-- Oxygen and health management
function combat.consumeOxygen(actionCost)
    if not combat.currentEnemy then return end
    local oxygenCost = config.OXYGEN_DEPLETION_BASE * config.OXY_DEPL_MULT * (actionCost or 1)
    if gamestate.currentCombatState == gamestate.CombatState.REFILL_OXYGEN then
        if player.data.oxygen < config.MAX_OXYGEN or player.data.health < player.data.maxHealth then
            player.data.oxygen = math.min(config.MAX_OXYGEN, player.data.oxygen + 10)
            player.data.health = math.min(player.data.maxHealth, player.data.health + 2)
            combat.addToCombatLog("You replenish oxygen and heal slightly!")
        end
    else
        player.data.oxygen = math.max(0, player.data.oxygen - oxygenCost)
        combat.checkPlayerStatus()
    end
    gamestate.currentCombatState = nil
end

-- Chance calculations
function combat.calculateHitChance(baseLuck)
    return math.min(95, 75 + baseLuck * 2)
end

function combat.calculateCounterChance(baseLuck)
    return math.min(80, 50 + baseLuck * 2)
end

function combat.calculateRunChance(baseLuck)
    return math.min(90, 40 + baseLuck * 3)
end

-- Player actions
function combat.attackEnemy()
    if combat.turnState ~= combat.TurnState.PLAYER or not combat.currentEnemy then
        combat.addToCombatLog("No enemy to attack!")
        gamestate.currentGameState = gamestate.GameState.EXPLORE
        return
    end

    local attackBoost = player.data.tempAttackBoost or 0
    if attackBoost > 0 then
        player.data.tempAttackBoost = nil
        combat.addToCombatLog("Strength Serum boosts your attack this turn!")
    end

    local hitChance = combat.calculateHitChance(player.data.luck)
    local critChance = 10 + player.data.luck * 2
    if math.random(100) <= hitChance then
        local isCrit = math.random(100) <= critChance
        local damage = math.max(1, (player.data.attack + attackBoost) * (isCrit and 2 or 1) * (0.9 + math.random() * 0.2) - combat.currentEnemy.defense / 2)
        combat.currentEnemy.health = math.max(0, combat.currentEnemy.health - damage)
        combat.currentEnemy.animState = 2
        combat.addToCombatLog("You " .. (isCrit and "critically " or "") .. "strike the " .. combat.currentEnemy.name .. " for " .. math.floor(damage) .. " damage!")
        if combat.currentEnemy.health <= 0 then
            combat.defeatEnemy()
            return
        end
    else
        combat.addToCombatLog("Your attack misses the " .. combat.currentEnemy.name .. "!")
    end

    combat.consumeOxygen(1)
    combat.updateStatusEffects()
    combat.turnState = combat.TurnState.ENEMY
    combat.enemyAttack()
    combat.turnState = combat.TurnState.PLAYER
end

function combat.counterEnemy()
    if combat.turnState ~= combat.TurnState.PLAYER or not combat.currentEnemy then
        combat.addToCombatLog("No enemy to counter!")
        gamestate.currentGameState = gamestate.GameState.EXPLORE
        return
    end

    local counterChance = combat.calculateCounterChance(player.data.luck)
    if math.random(100) <= counterChance then
        local counterDamage = math.floor(player.data.attack * 1.5 * (0.9 + math.random() * 0.2))
        combat.currentEnemy.health = math.max(0, combat.currentEnemy.health - counterDamage)
        combat.currentEnemy.animState = 2
        combat.addToCombatLog("You counter the " .. combat.currentEnemy.name .. " for " .. counterDamage .. " damage!")
        if combat.currentEnemy.health <= 0 then
            combat.defeatEnemy()
            return
        end
        combat.currentEnemy.stunned = true
    else
        combat.addToCombatLog("Your counter fails!")
        combat.consumeOxygen(1.5)
    end

    combat.consumeOxygen(1.5)
    combat.updateStatusEffects()
    if combat.currentEnemy then
        combat.turnState = combat.TurnState.ENEMY
        combat.enemyAttack()
        combat.turnState = combat.TurnState.PLAYER
    end
end

function combat.defend()
    if combat.turnState ~= combat.TurnState.PLAYER or not combat.currentEnemy then
        combat.addToCombatLog("No enemy to defend against!")
        gamestate.currentGameState = gamestate.GameState.EXPLORE
        return
    end

    player.data.defenseBoost = player.data.defense * 0.5
    combat.addToCombatLog("You brace yourself, increasing your defense!")
    combat.consumeOxygen(0.5)
    combat.updateStatusEffects()
    combat.turnState = combat.TurnState.ENEMY
    combat.enemyAttack()
    player.data.defenseBoost = nil
    combat.turnState = combat.TurnState.PLAYER
end

function combat.defeatEnemy()
    if not combat.currentEnemy then return end
    combat.addToCombatLog("The " .. combat.currentEnemy.name .. " collapses into the depths!")
    local currencyGain = combat.currentEnemy.currency
    if player.data.currency + currencyGain > player.data.maxCurrency then
        combat.addToCombatLog("Currency capped at " .. player.data.maxCurrency .. "! Excess " .. config.CURRENCY_NAME .. " lost.")
        player.data.currency = player.data.maxCurrency
    else
        combat.addToCombatLog("You collect " .. currencyGain .. " " .. config.CURRENCY_NAME .. "!")
        player.data.currency = player.data.currency + currencyGain
        player.data.currencyCollected = player.data.currencyCollected + currencyGain
    end
    gamestate.currentGameState = gamestate.GameState.EXPLORE
    player.data.enemiesDefeated = player.data.enemiesDefeated + 1
    combat.currentEnemy = nil
end

function combat.runFromCombat()
    if combat.turnState ~= combat.TurnState.PLAYER or not combat.currentEnemy then
        combat.addToCombatLog("No enemy to flee from!")
        gamestate.currentGameState = gamestate.GameState.EXPLORE
        return
    end

    local runChance = combat.calculateRunChance(player.data.luck)
    if math.random(100) <= runChance then
        combat.addToCombatLog("You slip away from the " .. combat.currentEnemy.name .. "!")
        gamestate.currentGameState = gamestate.GameState.EXPLORE
        combat.currentEnemy = nil
    else
        combat.addToCombatLog("The " .. combat.currentEnemy.name .. " blocks your escape!")
        combat.consumeOxygen(1.2)
        combat.updateStatusEffects()
        combat.turnState = combat.TurnState.ENEMY
        combat.enemyAttack()
        combat.turnState = combat.TurnState.PLAYER
    end
end

return combat
