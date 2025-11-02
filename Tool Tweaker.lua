local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existingGui = playerGui:FindFirstChild("ToolTweaks")
if existingGui then
    existingGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ToolTweaks"
gui.Parent = playerGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local CenterModule = {}

function CenterModule:GetCurrentTool()
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:IsA("Tool") and tool.Grip then
        return tool
    end
    return nil
end

local rotationTracker = { X = 0, Y = 0, Z = 0 }

local function syncRotationWithTool(tool)
    if not tool or not tool.Grip then return end
    local ok, rx, ry, rz = pcall(function() return tool.Grip:ToEulerAnglesXYZ() end)
    if ok and rx and ry and rz then
        rotationTracker.X = math.deg(rx)
        rotationTracker.Y = math.deg(ry)
        rotationTracker.Z = math.deg(rz)
    end
end

local isSliderDragging = false
local activeSliderThumb = nil

function CenterModule:EnableDragFrame(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        if not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if isSliderDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function tweenGrip(tool, newGrip)
    if not tool then return end
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear)
    pcall(function()
        TweenService:Create(tool, tweenInfo, {Grip = newGrip}):Play()
    end)

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid and tool and tool.Parent == char then
        if not getgenv()._lastForceEquip or tick() - getgenv()._lastForceEquip > 0.03 then
            getgenv()._lastForceEquip = tick()
            pcall(function() humanoid:EquipTool(tool) end)
        end
    end
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 320)
mainFrame.Position = UDim2.new(0.02, 0, 0.03, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(120, 120, 120)
mainFrame.Parent = gui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 6)
CenterModule:EnableDragFrame(mainFrame)

local minimizedCube = Instance.new("TextButton")
minimizedCube.Name = "MinimizedCube"
minimizedCube.Size = UDim2.new(0, 40, 0, 40)
minimizedCube.Position = mainFrame.Position
minimizedCube.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
minimizedCube.BorderSizePixel = 1
minimizedCube.BorderColor3 = Color3.fromRGB(150, 170, 210)
minimizedCube.Visible = false
minimizedCube.Text = ""
minimizedCube.AutoButtonColor = false
minimizedCube.Parent = gui
local cubeCorner = Instance.new("UICorner", minimizedCube)
cubeCorner.CornerRadius = UDim.new(0, 4)
CenterModule:EnableDragFrame(minimizedCube)

local header = Instance.new("Frame", mainFrame)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 30)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel", header)
title.Name = "Title"
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "Tool Tweaks"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.BackgroundTransparency = 1

local minimizeButton = Instance.new("TextButton", header)
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 1, 0)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.Text = "—"
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 16
minimizeButton.TextColor3 = Color3.fromRGB(240, 240, 240)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundTransparency = 0.85

minimizeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minimizedCube.Position = mainFrame.Position
    minimizedCube.Visible = true
end)

minimizedCube.MouseButton1Click:Connect(function()
    minimizedCube.Visible = false
    mainFrame.Position = minimizedCube.Position
    mainFrame.Visible = true
end)

local tabsContainer = Instance.new("Frame", mainFrame)
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(1, 0, 0, 30)
tabsContainer.Position = UDim2.new(0, 0, 0, 30)
tabsContainer.BackgroundTransparency = 1

local tabLayout = Instance.new("UIListLayout", tabsContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)

local posButton = Instance.new("TextButton", tabsContainer)
posButton.Name = "PositionTab"
posButton.Size = UDim2.new(0, 100, 0, 25)
posButton.Text = "Position"
posButton.Font = Enum.Font.SourceSansBold
posButton.TextSize = 14
posButton.TextColor3 = Color3.fromRGB(255, 255, 255)
posButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
local posCorner = Instance.new("UICorner", posButton)
posCorner.CornerRadius = UDim.new(0, 4)

local rotButton = Instance.new("TextButton", tabsContainer)
rotButton.Name = "RotationTab"
rotButton.Size = UDim2.new(0, 100, 0, 25)
rotButton.Text = "Rotation"
rotButton.Font = Enum.Font.SourceSansBold
rotButton.TextSize = 14
rotButton.TextColor3 = Color3.fromRGB(200, 200, 200)
rotButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
local rotCorner = Instance.new("UICorner", rotButton)
rotCorner.CornerRadius = UDim.new(0, 4)

local freezeButton = Instance.new("TextButton", tabsContainer)
freezeButton.Name = "FreezeCameraButton"
freezeButton.Size = UDim2.new(0, 110, 0, 25)
freezeButton.Text = "Freeze Camera"
freezeButton.Font = Enum.Font.SourceSansBold
freezeButton.TextSize = 14
freezeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
freezeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
local freezeCorner = Instance.new("UICorner", freezeButton)
freezeCorner.CornerRadius = UDim.new(0, 4)

local pages = Instance.new("Frame", mainFrame)
pages.Name = "Pages"
pages.Size = UDim2.new(1, -10, 1, -110)
pages.Position = UDim2.new(0, 5, 0, 65)
pages.BackgroundTransparency = 1

local posPage = Instance.new("Frame", pages)
posPage.Name = "PositionPage"
posPage.Size = UDim2.new(1, 0, 1, 0)
posPage.BackgroundTransparency = 1
local posPageLayout = Instance.new("UIListLayout", posPage)
posPageLayout.Padding = UDim.new(0, 8)
posPageLayout.SortOrder = Enum.SortOrder.LayoutOrder

local rotPage = Instance.new("Frame", pages)
rotPage.Name = "RotationPage"
rotPage.Size = UDim2.new(1, 0, 1, 0)
rotPage.BackgroundTransparency = 1
rotPage.Visible = false
local rotPageLayout = Instance.new("UIListLayout", rotPage)
rotPageLayout.Padding = UDim.new(0, 8)
rotPageLayout.SortOrder = Enum.SortOrder.LayoutOrder

local incrementInput = Instance.new("TextBox", mainFrame)
incrementInput.Name = "IncrementInput"
incrementInput.Size = UDim2.new(1, -10, 0, 30)
incrementInput.Position = UDim2.new(0, 5, 1, -35)
incrementInput.Font = Enum.Font.SourceSans
incrementInput.Text = "0.1"
incrementInput.PlaceholderText = "Increment Value"
incrementInput.TextSize = 14
incrementInput.TextColor3 = Color3.fromRGB(240, 240, 240)
incrementInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
local incCorner = Instance.new("UICorner", incrementInput)
incCorner.CornerRadius = UDim.new(0, 4)

posButton.MouseButton1Click:Connect(function()
    posPage.Visible = true
    rotPage.Visible = false
    posButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    posButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    rotButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    rotButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    incrementInput.Text = "0.1"
end)

rotButton.MouseButton1Click:Connect(function()
    posPage.Visible = false
    rotPage.Visible = true
    rotButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    rotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    posButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    posButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    incrementInput.Text = "1"
end)

local allSliders = {}
local function createControlRow(parent, axis, axisColor)
    local row = Instance.new("Frame", parent)
    row.Name = axis .. "Row"
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundTransparency = 1

    local rowLayout = Instance.new("UIListLayout", row)
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.Padding = UDim.new(0, 6)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 25, 0, 25)
    label.Text = axis
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextColor3 = axisColor
    label.BackgroundTransparency = 1

    local minusButton = Instance.new("TextButton", row)
    minusButton.Name = "Minus"
    minusButton.Size = UDim2.new(0, 28, 0, 28)
    minusButton.Text = "-"
    minusButton.Font = Enum.Font.SourceSansBold
    minusButton.TextSize = 20
    minusButton.TextColor3 = Color3.fromRGB(255,255,255)
    minusButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    local mB_c = Instance.new("UICorner", minusButton)
    mB_c.CornerRadius = UDim.new(0, 4)

    local valueInput = Instance.new("TextBox", row)
    valueInput.Name = "Value"
    valueInput.Size = UDim2.new(0, 60, 0, 25)
    valueInput.Text = "0"
    valueInput.Font = Enum.Font.SourceSans
    valueInput.TextSize = 14
    valueInput.TextColor3 = Color3.fromRGB(240, 240, 240)
    valueInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    local vI_c = Instance.new("UICorner", valueInput)
    vI_c.CornerRadius = UDim.new(0, 4)

    local plusButton = Instance.new("TextButton", row)
    plusButton.Name = "Plus"
    plusButton.Size = UDim2.new(0, 28, 0, 28)
    plusButton.Text = "+"
    plusButton.Font = Enum.Font.SourceSansBold
    plusButton.TextSize = 20
    plusButton.TextColor3 = Color3.fromRGB(255,255,255)
    plusButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    local pB_c = Instance.new("UICorner", plusButton)
    pB_c.CornerRadius = UDim.new(0, 4)

    local sliderTrack = Instance.new("Frame", row)
    sliderTrack.Name = "SliderTrack"
    sliderTrack.Size = UDim2.new(1, -160, 0, 10)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    local sT_c = Instance.new("UICorner", sliderTrack)
    sT_c.CornerRadius = UDim.new(0, 5)

    local sliderThumb = Instance.new("Frame", sliderTrack)
    sliderThumb.Name = "SliderThumb"
    sliderThumb.Size = UDim2.new(0, 18, 0, 18)
    sliderThumb.Position = UDim2.new(0.5, -9, 0.5, -9)
    sliderThumb.BackgroundColor3 = axisColor
    sliderThumb.BorderSizePixel = 2
    sliderThumb.BorderColor3 = Color3.fromRGB(255,255,255)
    local sTh_c = Instance.new("UICorner", sliderThumb)
    sTh_c.CornerRadius = UDim.new(1, 0)

    table.insert(allSliders, {
        Thumb = sliderThumb,
        Track = sliderTrack
    })

    return {
        Minus = minusButton,
        Plus = plusButton,
        Input = valueInput,
        SliderTrack = sliderTrack,
        SliderThumb = sliderThumb
    }
end

local function setupControls(controls, axis, isRotation)
    local function applyChange(tool, change)
        if not tool or not tool.Grip then return end
        local newGrip
        if isRotation then
            rotationTracker[axis] = rotationTracker[axis] + change
            newGrip = CFrame.new(tool.Grip.Position) *
                CFrame.fromEulerAnglesXYZ(
                    math.rad(rotationTracker.X),
                    math.rad(rotationTracker.Y),
                    math.rad(rotationTracker.Z)
                )
        else
            local pos = Vector3.new(
                axis == "X" and change or 0,
                axis == "Y" and change or 0,
                axis == "Z" and change or 0
            )
            local rx, ry, rz = tool.Grip:ToEulerAnglesXYZ()
            newGrip = CFrame.new(tool.Grip.Position + pos) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
        end
        tweenGrip(tool, newGrip)
    end

    local function setupPressureButton(button, direction)
        local isPressed = false
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPressed = true
                task.spawn(function()
                    while isPressed do
                        local tool = CenterModule:GetCurrentTool()
                        if tool then
                            local increment = math.abs(tonumber(incrementInput.Text) or (isRotation and 1 or 0.1))
                            applyChange(tool, direction * increment)
                        end
                        RunService.Heartbeat:Wait()
                    end
                end)
            end
        end)
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPressed = false
            end
        end)
    end

    setupPressureButton(controls.Plus, 1)
    setupPressureButton(controls.Minus, -1)

    controls.Input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local tool = CenterModule:GetCurrentTool()
            if not tool or not tool.Grip then return end
            local value = tonumber(controls.Input.Text)
            if value == nil then return end

            local pos = tool.Grip.Position
            local rx, ry, rz = tool.Grip:ToEulerAnglesXYZ()

            if isRotation then
                rotationTracker[axis] = value
                local newGrip = CFrame.new(pos) * CFrame.fromEulerAnglesXYZ(
                    math.rad(rotationTracker.X),
                    math.rad(rotationTracker.Y),
                    math.rad(rotationTracker.Z)
                )
                tweenGrip(tool, newGrip)
            else
                local newGrip = CFrame.new(
                    axis == "X" and value or pos.X,
                    axis == "Y" and value or pos.Y,
                    axis == "Z" and value or pos.Z
                ) * CFrame.fromEulerAnglesXYZ(rx, ry, rz)
                tweenGrip(tool, newGrip)
            end
        end
    end)

    local thumb = controls.SliderThumb
    local track = controls.SliderTrack
    local dragConnection = nil
    local runServiceConnection = nil
    local endConnection = nil

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not isSliderDragging then
                isSliderDragging = true
                activeSliderThumb = thumb

                for _, slider in pairs(allSliders) do
                    if slider.Thumb ~= activeSliderThumb then
                        slider.Thumb.Active = false
                    end
                end

                dragConnection = UserInputService.InputChanged:Connect(function(inputChanged)
                    if isSliderDragging and (inputChanged.UserInputType == Enum.UserInputType.MouseMovement or inputChanged.UserInputType == Enum.UserInputType.Touch) then
                        local mouseX = inputChanged.Position.X
                        local trackX = track.AbsolutePosition.X
                        local trackWidth = track.AbsoluteSize.X
                        local newThumbX = math.clamp(mouseX - trackX, 0, trackWidth)
                        thumb.Position = UDim2.new(0, newThumbX - 9, 0.5, -9)
                    end
                end)

                runServiceConnection = RunService.Heartbeat:Connect(function(dt)
                    local tool = CenterModule:GetCurrentTool()
                    if tool and isSliderDragging then
                        local mouseX = UserInputService:GetMouseLocation().X
                        local trackX = track.AbsolutePosition.X
                        local trackWidth = track.AbsoluteSize.X
                        local relativeMouseX = mouseX - trackX
                        local normalizedPos = math.clamp(relativeMouseX / math.max(trackWidth, 1), 0, 1)
                        local changeRate = (normalizedPos - 0.5) * 2
                        local increment = math.abs(tonumber(incrementInput.Text) or (isRotation and 1 or 0.1))
                        local totalChange = changeRate * increment * 10 * dt
                        applyChange(tool, totalChange)
                    end
                end)

                endConnection = UserInputService.InputEnded:Connect(function(inputEnded)
                    if isSliderDragging and activeSliderThumb == thumb and (inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch) then
                        isSliderDragging = false
                        activeSliderThumb = nil

                        for _, slider in pairs(allSliders) do
                            slider.Thumb.Active = true
                        end

                        if runServiceConnection then
                            runServiceConnection:Disconnect()
                            runServiceConnection = nil
                        end
                        if dragConnection then
                            dragConnection:Disconnect()
                            dragConnection = nil
                        end
                        if endConnection then
                            endConnection:Disconnect()
                            endConnection = nil
                        end

                        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                        local thumbTween = TweenService:Create(thumb, tweenInfo, {Position = UDim2.new(0.5, -9, 0.5, -9)})
                        thumbTween:Play()
                    end
                end)
            end
        end
    end)
end

local posControls = {
    X = createControlRow(posPage, "X", Color3.fromRGB(255, 75, 75)),
    Y = createControlRow(posPage, "Y", Color3.fromRGB(75, 255, 75)),
    Z = createControlRow(posPage, "Z", Color3.fromRGB(75, 75, 255))
}

local rotControls = {
    X = createControlRow(rotPage, "X", Color3.fromRGB(255, 75, 75)),
    Y = createControlRow(rotPage, "Y", Color3.fromRGB(75, 255, 75)),
    Z = createControlRow(rotPage, "Z", Color3.fromRGB(75, 75, 255))
}

setupControls(posControls.X, "X", false)
setupControls(posControls.Y, "Y", false)
setupControls(posControls.Z, "Z", false)

setupControls(rotControls.X, "X", true)
setupControls(rotControls.Y, "Y", true)
setupControls(rotControls.Z, "Z", true)

local camera = workspace.CurrentCamera
local frozen = false
local camPart = nil
local camConn = nil

local function freezeCamera()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    camPart = Instance.new("Part")
    camPart.Name = "ClientCameraPart"
    camPart.Anchored = true
    camPart.CanCollide = false
    camPart.Transparency = 1
    camPart.Size = Vector3.new(1,1,1)
    camPart.CFrame = camera.CFrame
    camPart.Parent = workspace

    camera.CameraType = Enum.CameraType.Scriptable

    camConn = RunService.RenderStepped:Connect(function()
        if camPart then
            camera.CFrame = camPart.CFrame
        end
    end)
end

local function restoreCamera()
    if camConn then camConn:Disconnect() camConn = nil end
    if camPart then camPart:Destroy() camPart = nil end
    camera.CameraType = Enum.CameraType.Custom
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject = hum end
end

freezeButton.MouseButton1Click:Connect(function()
    if not frozen then
        freezeCamera()
        freezeButton.Text = "Unfreeze Camera"
        freezeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        freezeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        restoreCamera()
        freezeButton.Text = "Freeze Camera"
        freezeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        freezeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    frozen = not frozen
end)

local currentToolRef = nil
RunService.RenderStepped:Connect(function()
    local tool = CenterModule:GetCurrentTool()
    if tool ~= currentToolRef then
        currentToolRef = tool
        if tool then
            syncRotationWithTool(tool)
        end
    end

    if tool and mainFrame.Visible then
        local pos = tool.Grip.Position
        local rotX, rotY, rotZ = tool.Grip:ToEulerAnglesXYZ()

        if posPage.Visible then
            if not posControls.X.Input:IsFocused() then posControls.X.Input.Text = string.format("%.2f", pos.X) end
            if not posControls.Y.Input:IsFocused() then posControls.Y.Input.Text = string.format("%.2f", pos.Y) end
            if not posControls.Z.Input:IsFocused() then posControls.Z.Input.Text = string.format("%.2f", pos.Z) end
        elseif rotPage.Visible then
            if not rotControls.X.Input:IsFocused() then rotControls.X.Input.Text = string.format("%.1f", rotationTracker.X) end
            if not rotControls.Y.Input:IsFocused() then rotControls.Y.Input.Text = string.format("%.1f", rotationTracker.Y) end
            if not rotControls.Z.Input:IsFocused() then rotControls.Z.Input.Text = string.format("%.1f", rotationTracker.Z) end
        end
    end
end)
