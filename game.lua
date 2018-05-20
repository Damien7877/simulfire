require("Map")
require("button")

MapParameters = 
{
    MinWind = 1,
    MaxWind = 3,
    ProbabilityRain = 1,
    ProbabilityFireWhenRain = 20,
    MinWindDirection = 1,
    MaxWindDirection = 15
}


function InitGame(mapWidth, mapHeight, tileSize)
    local game = {}

    local myMap = CreateMap(mapWidth,mapHeight, tileSize, 50, MapParameters)
    game.CurrentMap = myMap
    game.LastTimeWeather = love.timer.getTime() * 1000
    game.LastTime = love.timer.getTime() * 1000
    game.IsPressedF = false
    game.Ticks = 0
    game.Buttons = {}
    game.Buttons[1] = CreateButton("Start", 400, 100, 100, 50)
    game.Buttons[2] = CreateButton("Make fire", 510, 100, 100, 50)
    game.Buttons[3] = CreateButton("Reset", 400, 160, 100, 50)
    game.IsRunning = false
    SetCallback(game.Buttons[1], callbackStart, game)
    SetCallback(game.Buttons[2], callbackFire, game)
    SetCallback(game.Buttons[3], callbackReset, game)

    game.WindDirectionMap = {}
    game.WindDirectionMap[0] = "NONE"
    game.WindDirectionMap[1] = "NORTH"
    game.WindDirectionMap[2] = "SOUTH"
    game.WindDirectionMap[3] = "NORTH/SOUTH"
    game.WindDirectionMap[4] = "EAST"
    game.WindDirectionMap[5] = "NORTH/EAST"
    game.WindDirectionMap[6] = "SOUTH/EAST"
    game.WindDirectionMap[7] = "NORTH/SOUTH/EAST"
    game.WindDirectionMap[8] = "WEST"
    game.WindDirectionMap[9] = "NORTH/WEST"
    game.WindDirectionMap[10] = "SOUTH/WEST"
    game.WindDirectionMap[11] = "NORTH/SOUTH/WEST"
    game.WindDirectionMap[12] = "EAST/WEST"
    game.WindDirectionMap[13] = "NORTH/EAST/WEST"
    game.WindDirectionMap[14] = "SOUTH/EAST/WEST"
    game.WindDirectionMap[15] = "ROTATING"


    game.Draw = DrawGame
    game.Update = UpdateGame
    return game
end

function callbackStart(game)
    game.IsRunning = not game.IsRunning
    if game.IsRunning then
        SetButtonText(game.Buttons[3], "Stop")
    else
        SetButtonText(game.Buttons[3], "Start")
    end
end

function callbackReset(game)
    local myMap = CreateMap(game.CurrentMap.Width,game.CurrentMap.Height, game.CurrentMap.TileSize, 50, MapParameters)
    game.CurrentMap = myMap
    game.LastTimeWeather = love.timer.getTime() * 1000
    game.LastTime = love.timer.getTime() * 1000
    game.IsPressedF = false
    game.Ticks = 0
end

function callbackFire(game)
    if game.IsRunning then
        BurnRandomTreeOnMap(game.CurrentMap)
    end
end

function UpdateGame(myGame)
    if myGame.IsRunning then
        local currentTime = love.timer.getTime() * 1000
        if currentTime - myGame.LastTime > 1000 then
            UpdateMap(myGame.CurrentMap)
            myGame.LastTime = love.timer.getTime() * 1000
            myGame.Ticks = myGame.Ticks + 1
        end
        if currentTime - myGame.LastTimeWeather > 5000 then
            UpdateWeather(myGame.CurrentMap)
            myGame.LastTimeWeather = love.timer.getTime() * 1000
        end
    end
    for i = 1, table.getn(myGame.Buttons) do
        UpdateButton(myGame.Buttons[i])
    end
    
end

function DrawGame(myGame)

    DrawMap(myGame.CurrentMap)
    DrawInformations(myGame)

    for i = 1, table.getn(myGame.Buttons) do
        DrawButton(myGame.Buttons[i])
    end
    
end


function DrawInformations(myGame)
    love.graphics.setColor(255,255,255)
    love.graphics.print("Ticks = "..tostring(myGame.Ticks), 400, 0)
    love.graphics.print("Wind = "..tostring(myGame.CurrentMap.Wind), 400, 20)
    love.graphics.print("Wind Direction = "..tostring(myGame.WindDirectionMap[myGame.CurrentMap.WindDirection]),400,30)
    love.graphics.print("Is Raining? "..tostring(myGame.CurrentMap.IsRaining), 400, 40)
    love.graphics.print("Is Burning? "..tostring(IsThereABurningTreeOnMap(myGame.CurrentMap)),400,50)
    love.graphics.print("Number of trees = "..tostring(GetNumberOfTrees(myGame.CurrentMap)),400,60)
end

function DrawHelp()
end