-- map file
-- used to create map

MapState =  { NONE = 0, TREE = 1, BURNING_TREE = 2, BURNING_RED = 3,DEAD_TREE = 4 }

WindDirection = { NORTH = 1, SOUTH = 2, EAST = 4, WEST = 8}

MapColor = 
{ 
    [MapState.NONE] = { r = 167, g = 103, b = 38 },
    [MapState.TREE] = { r = 0, g = 255, b = 0 },
    [MapState.BURNING_TREE] = { r = 255, g = 128, b = 0 },
    [MapState.BURNING_RED] = { r = 255, g = 0, b = 0 },
    [MapState.DEAD_TREE] = { r = 128, g = 128, b = 128 }
}

function CreateMap(width, height, tilesize, treeProbability, mapParameters)
    local emptyMap = {}
     
    local l,c = 0,0

    emptyMap.CurrentMap = {}
    emptyMap.Width = width
    emptyMap.Height = height
    emptyMap.TileSize = tilesize
    emptyMap.IsBurning = false
    emptyMap.IsRaining = false

    emptyMap.MapParameters = mapParameters
    emptyMap.Wind = math.random(emptyMap.MapParameters.MinWind, emptyMap.MapParameters.MaxWind)
    emptyMap.WindDirection = math.random(1, 15)
    for l = 0, height do
        emptyMap.CurrentMap[l] = {}
        for c = 0, width do
            emptyMap.CurrentMap[l][c] = GetRandomMapState(treeProbability)
        end
    end
    return emptyMap
end

function CopyMap(myMap)
    local emptyMap = {}

    emptyMap.CurrentMap = {}
    emptyMap.Width = myMap.Width
    emptyMap.Height = myMap.Height
    emptyMap.TileSize = myMap.TileSize
    emptyMap.IsBurning = myMap.IsBurning
    emptyMap.IsRaining = myMap.IsRaining
    emptyMap.Wind = myMap.Wind
    emptyMap.WindDirection = myMap.WindDirection
    emptyMap.NbrBurningTree = myMap.NbrBurningTree
    emptyMap.MapParameters = myMap.MapParameters
    for l = 0, emptyMap.Height do
        emptyMap.CurrentMap[l] = {}
        for c = 0, emptyMap.Width do
            emptyMap.CurrentMap[l][c] = myMap.CurrentMap[l][c]
        end
    end
    return emptyMap
end

function GetRandomMapState(treeProbability)
    local value = math.random(0, 100)
    if value < treeProbability then
        return MapState.TREE
    else
        return MapState.NONE
    end 
end

function DrawMap(myMap)
    for l = 0, myMap.Height do
        for c = 0, myMap.Width do

            love.graphics.setColor(
            MapColor[myMap.CurrentMap[l][c]].r,
            MapColor[myMap.CurrentMap[l][c]].g,
            MapColor[myMap.CurrentMap[l][c]].b)

            love.graphics.rectangle("fill", 
            c * myMap.TileSize-1, 
            l * myMap.TileSize-1,
            myMap.TileSize-2,
            myMap.TileSize-2)
        end
    end
end

function UpdateWeather(myMap)
    myMap.IsRaining = math.random(0, 100) < myMap.MapParameters.ProbabilityRain
    myMap.Wind =  math.random(myMap.MapParameters.MinWind, myMap.MapParameters.MaxWind)
    myMap.WindDirection = math.random(myMap.MapParameters.MinWindDirection, myMap.MapParameters.MaxWindDirection)
end

function UpdateMap(myMap)
    local copyMap = CopyMap(myMap)
    for l = 0, myMap.Height do
        for c = 0, myMap.Width do
            
            myMap.CurrentMap[l][c] = CalculateNewState(copyMap.CurrentMap[l][c], IsThereABurningRedTreeNearBy(copyMap, l, c), myMap.IsRaining, myMap.MapParameters.ProbabilityFireWhenRain)
        end
    end
end

function CalculateNewState(lastState, isBurningTreeNearBy, isRaining, probabilityFireWhenRain)
    local newState = lastState
    if lastState == MapState.TREE then
        if isBurningTreeNearBy then
            local canBurn = true
            if isRaining then
                canBurn =  math.random(0, 100) < probabilityFireWhenRain 
            end
            if canBurn then
                newState = MapState.BURNING_TREE
            end
        end
    elseif lastState == MapState.BURNING_TREE then
        newState = MapState.BURNING_RED
    elseif lastState == MapState.BURNING_RED then
        newState = MapState.DEAD_TREE
    elseif lastState == MapState.DEAD_TREE then
        newState = MapState.NONE
    end
    return newState
end

function IsThereABurningRedTreeNearBy(myMap, l, c)
    local isWindNorth = bit.band(myMap.WindDirection, 1) == 1
    local isWindSouth = bit.band(myMap.WindDirection, 2) == 2
    local isWindEast = bit.band(myMap.WindDirection, 4) == 4
    local isWindWest = bit.band(myMap.WindDirection, 8) == 8

    local minLine = l
    local minColumn = c
    local maxLine = l
    local maxColumn = c

    local currentWind = myMap.Wind

    if isWindNorth then
        maxLine = math.min(l+currentWind, myMap.Height)
    end

    if isWindSouth then
        minLine = math.max(l-currentWind, 0)
        
    end

    if isWindWest then
        maxColumn = math.min(c+currentWind, myMap.Width)
    end

    if isWindEast then
        minColumn = math.max(c-currentWind, 0)
        
    end


    for lTest = minLine, maxLine  do
        for cTest = minColumn, maxColumn  do
            if myMap.CurrentMap[lTest][cTest] == MapState.BURNING_TREE then
                if math.random( 100 ) > 70 then
                    return true
                end
            end
            if myMap.CurrentMap[lTest][cTest] == MapState.BURNING_RED then
                return true
            end
        end
    end
    return false
end

function IsThereABurningTreeOnMap(myMap)
    for l = 0, myMap.Height do
        for c = 0, myMap.Width do
            if myMap.CurrentMap[l][c] == MapState.BURNING_TREE or
               myMap.CurrentMap[l][c] == MapState.BURNING_RED then
                return true
            end
        end
    end
    return false
end

function GetNumberOfTrees(myMap)
    local nbrTrees = 0
    for l = 0, myMap.Height do
        for c = 0, myMap.Width do
            if myMap.CurrentMap[l][c] == MapState.TREE then
                nbrTrees= nbrTrees  + 1
            end
        end
    end
    return nbrTrees
end


function GetListOfAllTreesOnMap(myMap)
    local trees = {}
    local index = 0
    for l = 0, myMap.Height do
        for c = 0, myMap.Width do
            if myMap.CurrentMap[l][c] == MapState.TREE then
                trees[index] = { l = l, c = c }
                index = index + 1
            end
        end
    end

    return trees
end

function BurnRandomTreeOnMap(myMap)
    local trees = GetListOfAllTreesOnMap(myMap)
    
    local position = trees[math.random(0, table.getn(trees) )]
    if position ~= nil then
        myMap.CurrentMap[position.l][position.c] = MapState.BURNING_TREE

        myMap.IsBurning = true
    end
end