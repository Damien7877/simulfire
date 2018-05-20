-- Damien7877 
-- Simulation de feu de foret

require("game")
require("menu")
MapHeight = 23
MapWidth = 23
LastTime = love.timer.getTime() * 1000

MyGame = nil
MyMenu = nil

CurrentScene = nil

function love.load()
    math.randomseed(os.time())
    love.window.setMode(800,400)
    love.window.setTitle("Make me on fire")
    MyGame = InitGame(MapWidth, MapHeight, 16)
    MyMenu = InitMenu(CallbackStartGame)

    CurrentScene = MyMenu
end

function CallbackStartGame()
    CurrentScene = MyGame
end

function love.update()
    if love.keyboard.isDown("escape") then
        --reset and quit
        MyGame = InitGame(MapWidth, MapHeight, 16)
        CurrentScene = MyMenu
    end
    CurrentScene.Update(CurrentScene)
end


function love.draw()
    love.graphics.scale(1,1)
    CurrentScene.Draw(CurrentScene)
end