--button class
--little gui for this simulation

function CreateButton(text, x, y, width, height)

    local currentFont = love.graphics.getFont()
    local newButton = {}

    newButton.X = x
    newButton.Y = y
    newButton.Width = width
    newButton.Height = height
    SetButtonText(newButton, text)
    newButton.IsFocued = false
    newButton.MouseDown = false
    newButton.Callback = EmptyCallback
    newButton.CallbackObject = nil
    return newButton
end

function EmptyCallback()
end

function SetButtonText(button, text)
    local currentFont = love.graphics.getFont()
    button.Text = text
    local textWidth = currentFont:getWidth(text)
    button.TextPositionX = button.X + (button.Width / 2) - (textWidth / 2)
    button.TextPositionY = button.Y + button.Height / 2 - 5
end


function SetCallback(button, callback, object)
    button.Callback = callback
    button.CallbackObject = object
end

function UpdateButton(button)
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    button.IsFocued = x >=  button.X and 
    y >= button.Y and
    x <= button.X + button.Width and
    y <= button.Y + button.Height
    if button.IsFocued and love.mouse.isDown(1) then
        button.MouseDown = true
    end

    if button.IsFocued and not love.mouse.isDown(1) and button.MouseDown then

        button.Callback(button.CallbackObject)
        button.MouseDown = false
    end
end

function DrawButton(button)
    love.graphics.setColor(0,128,128)


    if button.IsFocued then
        love.graphics.setColor(0,255,255)
    end

    if button.MouseDown then
        love.graphics.setColor(0,64,64)
    end

    love.graphics.rectangle("fill", 
        button.X, 
        button.Y,
        button.Width,
        button.Height)

        love.graphics.setColor(0,0,0)



    love.graphics.print(button.Text, button.TextPositionX, button.TextPositionY)
end