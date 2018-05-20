require("button")

function InitMenu(startGameCallback)
    local newMenu = {}
    newMenu.Buttons = {}
    newMenu.Buttons[1] = CreateButton("Start", 350, 150, 100, 50)
    
    SetCallback(newMenu.Buttons[1], startGameCallback, nil)

    newMenu.Draw = DrawMenu
    newMenu.Update = UpdateMenu
    return newMenu
end

function DrawMenu(myMenu)
    for i = 1, table.getn(myMenu.Buttons) do
        DrawButton(myMenu.Buttons[i])
    end
end

function UpdateMenu(myMenu)
    for i = 1, table.getn(myMenu.Buttons) do
        UpdateButton(myMenu.Buttons[i])
    end
end