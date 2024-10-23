

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService") -- Import UserInputService
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CamlockState = false
local Prediction = 0.1678963
local XPrediction = 0.176073
local YPrediction = 0.167092
local Smoothness = 0.03 -- Adjust this value for smoother or faster camera movement
local Locked = false
getgenv().Key = "q"

function FindNearestEnemy()
    local ClosestDistance, ClosestPlayer = math.huge, nil
    local CenterPosition =
        Vector2.new(
        game:GetService("GuiService"):GetScreenResolution().X / 2,
        game:GetService("GuiService"):GetScreenResolution().Y / 2
    )

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") and Character.Humanoid.Health > 0 then
                local Position, IsVisibleOnViewport =
                    workspace.CurrentCamera:WorldToViewportPoint(Character.HumanoidRootPart.Position)

                if IsVisibleOnViewport then
                    local Distance = (CenterPosition - Vector2.new(Position.X, Position.Y)).Magnitude
                    if Distance < ClosestDistance then
                        ClosestPlayer = Character.HumanoidRootPart
                        ClosestDistance = Distance
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

local enemy = nil

-- Function to smoothly aim the camera at the nearest enemy's HumanoidRootPart with prediction values
RunService.Heartbeat:Connect(function()
    if CamlockState then
        if enemy then
            local camera = workspace.CurrentCamera
            local targetPosition = enemy.Position
            targetPosition = Vector3.new(targetPosition.X + XPrediction, targetPosition.Y + YPrediction, targetPosition.Z)

            -- Interpolate between the current camera position and the target position
            local currentPosition = camera.CFrame.Position
            local newPosition = currentPosition:Lerp(targetPosition, Smoothness)

            camera.CFrame = CFrame.new(newPosition, targetPosition)
        end
    end
end)

Mouse.KeyDown:Connect(function(k)
    if k == getgenv().Key then
        Locked = not Locked
        if Locked then
            enemy = FindNearestEnemy()
            CamlockState = true
        else
            if enemy ~= nil then
                enemy = nil
                CamlockState = false
            end
        end
    end
end)

-- Check if the GUI already exists and remove it if it does
local existingGui = game.CoreGui:FindFirstChild("BlackGuy")
if existingGui then
    existingGui:Destroy()
end

local BladLock = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextButton = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")

-- Properties:
BladLock.Name = "BlackGuy"
BladLock.Parent = game.CoreGui
BladLock.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = BladLock
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Background color is black
Frame.BackgroundTransparency = 0.5 -- Set initial transparency to 50%
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.5, -40, 0, 10) -- Centered at the top
Frame.Size = UDim2.new(0, 80, 0, 70)

-- Variables to control dragging
local dragging = false
local dragStart = nil
local startPos = nil

-- Function to start dragging
local function startDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = Frame.Position
end

-- Function to stop dragging
local function stopDrag()
    dragging = false
end

-- Connect input events for mouse and touch
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                stopDrag()
            end
        end)
    end
end)

-- Handle dragging for mouse
RunService.RenderStepped:Connect(function()
    if dragging then
        local delta = Mouse.X - dragStart.X
        local deltaY = Mouse.Y - dragStart.Y
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta, startPos.Y.Scale, startPos.Y.Offset + deltaY)
    end
end)

-- Handle dragging for mobile touch input
UserInputService.TouchMoved:Connect(function(touch)
    if dragging then
        local delta = touch.Position.X - dragStart.X
        local deltaY = touch.Position.Y - dragStart.Y
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta, startPos.Y.Scale, startPos.Y.Offset + deltaY)
    end
end)

UICorner.Parent = Frame

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BackgroundTransparency = 0.5 -- Keep button background transparent
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.0792079195, 0, 0.18571429, 0)
TextButton.Size = UDim2.new(0, 70, 0, 50)
TextButton.Font = Enum.Font.SourceSansSemibold
TextButton.Text = "Camlock: Off" -- Initial text
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.TextWrapped = true

TextButton.MouseButton1Click:Connect(function()
    Locked = not Locked
    if Locked then
        CamlockState = true
        enemy = FindNearestEnemy()
        TextButton.Text = "Camlock: On"  -- Change the text to "On"
        Frame.BackgroundTransparency = 0 -- Make the frame fully opaque when locked
        game.StarterGui:SetCore("SendNotification", {
            Title = "FluxusZ Camlock",
            Text = "Locking To"
        })
    else
        CamlockState = false
        enemy = nil
        TextButton.Text = "Camlock: Off" -- Change the text to "Off"
        Frame.BackgroundTransparency = 0.5 -- Make the frame semi-transparent when unlocked
        game.StarterGui:SetCore("SendNotification", {
            Title = "FluxusZ Camlock",
            Text = "Unlocked"
        })
    end
end)

UICorner_2.Parent = TextButton
Frame.Active = true
Frame.Draggable = true -- Ensure GUI is draggable

-- Function to copy Discord link to clipboard
local function copyDiscordLink()
    setclipboard("https://discord.gg/fluxusz") -- Copy the link to the clipboard
end

-- Function to send a single notification when the script is executed
local function sendWelcomeNotification()
    game.StarterGui:SetCore("SendNotification", {
        Title = "FluxusZ CamLock",
        Text = "Thanks for using.",
        Duration = 5,
        Button1 = "OK",
    })
end

-- Call the notification function
sendWelcomeNotification()
