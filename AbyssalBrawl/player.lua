-- player.lua
local config = require("config")
local gamestate = require("gamestate")

player = {
    data = {},

    initialize = function()
        player.data = {
            name = "Diver",
            maxHealth = 100,
            health = 100,
            maxAttack = 1000,
            attack = 10,
            maxDefense = 100,
            defense = 5,
            maxLuck = 50,
            luck = 5,
            maxCurrency = 1000,
            currency = 0,
            maxDepth = 1000,
            depth = 0,
            maxOxygen = 100,
            oxygen = 100,
            maxInventory = 10,
            inventory = {},
            primedCombatItems = {},
            enemiesDefeated = 0,
            itemsUsed = 0,
            currencyCollected = 0,
            timeAlive = 0
        }
    end,

    createStatBoost = function(stat, maxStat, amount)
        return function()
            local current, max = player.data[stat], player.data[maxStat]
            if current >= max then
                return false, stat .. " already at maximum " .. max .. "!"
            else
                player.data[stat] = math.min(max, current + amount)
                if player.data[stat] == max then
                    return true, stat .. " reached maximum of " .. max .. "!"
                end
                return true, nil
            end
        end
    end,

    createHealthPotion = function(amount)
        return function()
            local oldHealth = player.data.health
            if player.data.health >= player.data.maxHealth then
                return false, "Health already at maximum " .. player.data.maxHealth .. "!"
            else
                player.data.health = math.min(player.data.maxHealth, player.data.health + amount)
                if player.data.health == player.data.maxHealth then
                    return true, "Health restored to maximum of " .. player.data.maxHealth .. "!"
                else
                    return true, "Health increased by " .. amount .. " to " .. player.data.health .. "!"
                end
            end
        end
    end,

    createMaxHealthBoost = function(amount)
        return function()
            player.data.maxHealth = player.data.maxHealth + amount
            player.data.health = math.min(player.data.maxHealth, player.data.health + amount)
            return true, "Max health increased by " .. amount .. " and health increased by " .. amount .. "!"
        end
    end
}

return player