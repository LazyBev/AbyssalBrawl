-- main.lua
local config = require("config")
local gamestate = require("gamestate")
local player = require("player")
local combat = require("combat")
local ui = require("ui")
local shop = require("shop")
local inventory = require("inventory")
local render = require("render")
local enemies = require("enemies")
local shaders = require("shaders")
local gameover = require("gameover")

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Abyssal Brawl")

    -- Initialize shaders
    for _, shader in pairs(shaders) do
        if shader:hasUniform("iTime") then
            shader:send("iTime", 0.0)
        end
        if shader:hasUniform("resolution") then
            shader:send("resolution", {config.GAME_WIDTH, config.GAME_HEIGHT})
        end
        if shader:hasUniform("time") then
            shader:send("time", 0.0)
        end
    end

    -- Create canvas for CRT effect
    canvas = love.graphics.newCanvas(config.GAME_WIDTH, config.GAME_HEIGHT)
    canvas:setFilter("nearest", "nearest")

    -- Initialize game state
    gamestate.initialize()
    player.initialize()
    shop.initialize()
    ui.initialize()
end

function love.update(dt)
    ui.updateButtons(dt)
    if gamestate.isGameplayState() then
        player.data.timeAlive = player.data.timeAlive + dt
    end
    if gamestate.currentGameState ~= gamestate.GameState.PAUSE then
        gamestate.gameTime = gamestate.gameTime + dt
        for _, shader in pairs(shaders) do
            if shader:hasUniform("iTime") then
                shader:send("iTime", gamestate.gameTime)
            end
            if shader:hasUniform("time") then
                shader:send("time", gamestate.gameTime)
            end
        end
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    render.draw()

    love.graphics.setCanvas()
    love.graphics.setShader(shaders.crt)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()
end

function love.mousepressed(x, y, button)
    ui.mousepressed(x, y, button)
    shop.mousepressed(x, y, button)
    inventory.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    ui.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    ui.mousemoved(x, y, dx, dy)
end

function love.keypressed(key)
    if key == "escape" then
        if gamestate.currentGameState == gamestate.GameState.COMBAT then
            gamestate.currentGameState = gamestate.GameState.PAUSE
        elseif gamestate.currentGameState == gamestate.GameState.PAUSE then
            gamestate.currentGameState = gamestate.GameState.COMBAT
        end
    elseif key == "r" and gamestate.currentGameState == gamestate.GameState.COMBAT then
        combat.runFromCombat()
    end
end