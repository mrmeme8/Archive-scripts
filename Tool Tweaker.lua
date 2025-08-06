--[[
Tool Tweaks 3.2 - Simplified by Gemini

Features:
- Minimizable UI: Toggles between the full panel and a small, draggable cube.
- Direct Value Input: Click a value box, type a number, and press Enter to set it.
- Simplified single-panel UI with tabs for Position and Rotation.
- Draggable relative sliders for smooth, continuous adjustments.
- "Pressure-sensitive" buttons: Hold to continuously apply changes.
- Clean, modern, and simplified visual design.
- Added a "Freeze Camera" button to lock the camera's position for precise adjustments.
- Re-execution Support: The script now checks for and removes old UI instances when re-executed.

Credits:
- MrMeme: UI suggestions
- Chat dev: Original Position and Rotation code
- (G): UI Redesign, slider code, freeze button code, and overall bug fixes/refinements
- Chillz for inspiring me to make this script heres his youtube: https://youtube.com/@chillz_azy?si=egYV43D2nSNe9k2r
]]

local player = game:GetService("Players").LocalPlayer

-- Check for and destroy existing UI to prevent duplicates
local existingGui = player.PlayerGui:FindFirstChild("ToolTweaks")
if existingGui then
    existingGui:Destroy()
end

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ToolTweaks"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

-- Helper module for shared functions
local CenterModule = {}

function CenterModule:GetCurrentTool()
    local character = player.Character
    if not character then return nil end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool and tool:IsA("Tool") and tool.Grip then
        return tool
    end
    return nil
end

-- Global flag to prevent dragging the main frame when a slider is active
local isSliderDragging = false
local activeSliderThumb = nil -- New variable to track the currently active slider

function CenterModule:EnableDragFrame(frame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        -- Only allow dragging if a slider isn't currently being dragged
        if not isSliderDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
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

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

end

-- Main UI Creation
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 280)
mainFrame.Position = UDim2.new(0.02, 0, 0.03, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(120, 120, 120)
mainFrame.Parent = gui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 6)

-- Enable dragging for the main UI panel
CenterModule:EnableDragFrame(mainFrame)

-- Minimized Cube (Changed to TextButton to be clickable)
local minimizedCube = Instance.new("TextButton")
minimizedCube.Name = "MinimizedCube"
minimizedCube.Size = UDim2.new(0, 40, 0, 40)
minimizedCube.Position = mainFrame.Position
minimizedCube.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
minimizedCube.BorderSizePixel = 1
minimizedCube.BorderColor3 = Color3.fromRGB(150, 170, 210)
minimizedCube.Visible = false
minimizedCube.Text = "" -- No text on the button itself
minimizedCube.AutoButtonColor = false
minimizedCube.Parent = gui
local cubeCorner = Instance.new("UICorner", minimizedCube)
cubeCorner.CornerRadius = UDim.new(0, 4)
CenterModule:EnableDragFrame(minimizedCube)

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner", header)
headerCorner.CornerRadius = UDim.new(0, 6)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -30, 1, 0)
title.Text = "Tool Tweaker"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.BackgroundTransparency = 1
title.Parent = header

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 1, 0)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.Text = "—" -- Em dash for minimize
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 16
minimizeButton.TextColor3 = Color3.fromRGB(240, 240, 240)
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundTransparency = 0.85
minimizeButton.Parent = header

-- Minimize/Maximize Logic
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

-- Tab Buttons
local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(1, 0, 0, 30)
tabsContainer.Position = UDim2.new(0, 0, 0, 30)
tabsContainer.BackgroundTransparency = 1
tabsContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout", tabsContainer)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)

local posButton = Instance.new("TextButton")
posButton.Name = "PositionTab"
posButton.Size = UDim2.new(0, 100, 0, 25)
posButton.Text = "Position"
posButton.Font = Enum.Font.SourceSansBold
posButton.TextSize = 14
posButton.TextColor3 = Color3.fromRGB(255, 255, 255)
posButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
posButton.Parent = tabsContainer
local posCorner = Instance.new("UICorner", posButton)
posCorner.CornerRadius = UDim.new(0, 4)

local rotButton = Instance.new("TextButton")
rotButton.Name = "RotationTab"
rotButton.Size = UDim2.new(0, 100, 0, 25)
rotButton.Text = "Rotation"
rotButton.Font = Enum.Font.SourceSansBold
rotButton.TextSize = 14
rotButton.TextColor3 = Color3.fromRGB(200, 200, 200)
rotButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
rotButton.Parent = tabsContainer
local rotCorner = Instance.new("UICorner", rotButton)
rotCorner.CornerRadius = UDim.new(0, 4)

-- Content Pages
local pages = Instance.new("Frame")
pages.Name = "Pages"
pages.Size = UDim2.new(1, -10, 1, -100)
pages.Position = UDim2.new(0, 5, 0, 65)
pages.BackgroundTransparency = 1
pages.Parent = mainFrame

local posPage = Instance.new("Frame")
posPage.Name = "PositionPage"
posPage.Size = UDim2.new(1, 0, 1, 0)
posPage.BackgroundTransparency = 1
posPage.Parent = pages
local posPageLayout = Instance.new("UIListLayout", posPage)
posPageLayout.Padding = UDim.new(0, 8)
posPageLayout.SortOrder = Enum.SortOrder.LayoutOrder

local rotPage = Instance.new("Frame")
rotPage.Name = "RotationPage"
rotPage.Size = UDim2.new(1, 0, 1, 0)
rotPage.BackgroundTransparency = 1
rotPage.Visible = false
rotPage.Parent = pages
local rotPageLayout = Instance.new("UIListLayout", rotPage)
rotPageLayout.Padding = UDim.new(0, 8)
rotPageLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Global Increment/Sensitivity Input
local incrementInput = Instance.new("TextBox")
incrementInput.Name = "IncrementInput"
incrementInput.Size = UDim2.new(1, -10, 0, 30)
incrementInput.Position = UDim2.new(0, 5, 1, -35)
incrementInput.Font = Enum.Font.SourceSans
incrementInput.Text = "0.1"
incrementInput.PlaceholderText = "Increment Value"
incrementInput.TextSize = 14
incrementInput.TextColor3 = Color3.fromRGB(240, 240, 240)
incrementInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
incrementInput.Parent = mainFrame
local incCorner = Instance.new("UICorner", incrementInput)
incCorner.CornerRadius = UDim.new(0, 4)

-- Tab Switching Logic
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

-- Tweening Service
local TweenService = game:GetService("TweenService")
local function tweenGrip(tool, newGrip)
    if not tool then return end
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(tool, tweenInfo, {Grip = newGrip})
    tween:Play()
end

-- All sliders table to manage visibility
local allSliders = {}

-- Control Row Creation Function
local function createControlRow(parent, axis, axisColor)
    local row = Instance.new("Frame")
    row.Name = axis .. "Row"
    row.Size = UDim2.new(1, 0, 0, 50)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local rowLayout = Instance.new("UIListLayout", row)
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.Padding = UDim.new(0, 5)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 25, 0, 25)
    label.Text = axis
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextColor3 = axisColor
    label.BackgroundTransparency = 1

    local minusButton = Instance.new("TextButton", row)
    minusButton.Name = "Minus"
    minusButton.Size = UDim2.new(0, 25, 0, 25)
    minusButton.Text = "-"
    minusButton.Font = Enum.Font.SourceSansBold
    minusButton.TextSize = 20
    minusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    plusButton.Size = UDim2.new(0, 25, 0, 25)
    plusButton.Text = "+"
    plusButton.Font = Enum.Font.SourceSansBold
    plusButton.TextSize = 20
    plusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    local pB_c = Instance.new("UICorner", plusButton)
    pB_c.CornerRadius = UDim.new(0, 4)

    -- Slider
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

    -- Add the slider to the global table
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

-- Setup Logic for Controls
local function setupControls(controls, axis, isRotation)
    local runService = game:GetService("RunService")

    -- Pressure sensitive buttons
    local function setupPressureButton(button, direction)
        local isPressed = false
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isPressed = true
                task.spawn(function()
                    while isPressed do
                        local tool = CenterModule:GetCurrentTool()
                        if tool then
                            local increment = tonumber(incrementInput.Text) or (isRotation and 1 or 0.1)
                            local change = direction * increment
                            local newGrip
                            if isRotation then
                                local rot = Vector3.new(
                                    axis == "X" and change or 0,
                                    axis == "Y" and change or 0,
                                    axis == "Z" and change or 0
                                )
                                newGrip = tool.Grip * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
                            else
                                local pos = Vector3.new(
                                    axis == "X" and change or 0,
                                    axis == "Y" and change or 0,
                                    axis == "Z" and change or 0
                                )
                                newGrip = tool.Grip * CFrame.new(pos)
                            end
                            tweenGrip(tool, newGrip)
                        end
                        runService.Heartbeat:Wait()
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

    -- Direct value input on Enter
    controls.Input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local tool = CenterModule:GetCurrentTool()
            if tool then
                local value = tonumber(controls.Input.Text)
                if value == nil then return end -- Ignore if not a valid number

                local pos, rotX, rotY, rotZ = tool.Grip.Position, tool.Grip:ToEulerAnglesXYZ()

                local newGrip
                if isRotation then
                    newGrip = CFrame.new(pos) * CFrame.Angles(
                        axis == "X" and math.rad(value) or rotX,
                        axis == "Y" and math.rad(value) or rotY,
                        axis == "Z" and math.rad(value) or rotZ
                    )
                else
                     local rotCFrame = tool.Grip - pos
                     newGrip = CFrame.new(
                        axis == "X" and value or pos.X,
                        axis == "Y" and value or pos.Y,
                        axis == "Z" and value or pos.Z
                    ) * rotCFrame
                end
                tweenGrip(tool, newGrip)
            end
        end
    end)

    -- Draggable slider
    local thumb = controls.SliderThumb
    local track = controls.SliderTrack

    local dragStartPos = nil
    local dragConnection, inputChangedConnection = nil, nil
    local runServiceConnection = nil

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not isSliderDragging then
                isSliderDragging = true
                activeSliderThumb = thumb
                dragStartPos = input.Position.X

                -- Disable input for all other sliders
                for _, slider in pairs(allSliders) do
                    if slider.Thumb ~= activeSliderThumb then
                        slider.Thumb.Active = false
                    end
                end

                local dragConnection = game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if isSliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                         local tool = CenterModule:GetCurrentTool()
                         if tool then
                            local mouseDeltaX = input.Position.X - dragStartPos
                            -- Calculate the new thumb position based on the drag
                            local newThumbX = math.clamp(0.5 + mouseDeltaX / track.AbsoluteSize.X, 0, 1)
                            thumb.Position = UDim2.new(newThumbX, -9, 0.5, -9)

                            -- Calculate the change rate based on how far the thumb is from the center
                            local changeRate = (newThumbX - 0.5) * 2
                            local increment = tonumber(incrementInput.Text) or (isRotation and 1 or 0.1)

                            -- Continuous update loop
                            if not runServiceConnection then
                                runServiceConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
                                    local tool = CenterModule:GetCurrentTool()
                                    if tool and isSliderDragging then
                                        local totalChange = changeRate * increment * 10 * dt  -- Multiply by dt for frame-rate independence and 10 for a faster rate
                                        local newGrip

                                        if isRotation then
                                            local rot = Vector3.new(
                                                axis == "X" and totalChange or 0,
                                                axis == "Y" and totalChange or 0,
                                                axis == "Z" and totalChange or 0
                                            )
                                            newGrip = tool.Grip * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))
                                        else
                                            local pos = Vector3.new(
                                                axis == "X" and totalChange or 0,
                                                axis == "Y" and totalChange or 0,
                                                axis == "Z" and totalChange or 0
                                            )
                                            newGrip = tool.Grip * CFrame.new(pos)
                                        end
                                        tweenGrip(tool, newGrip)
                                    end
                                end)
                            end
                         end
                    end
                end)

                inputChangedConnection = game:GetService("UserInputService").InputEnded:Connect(function(input)
                     if isSliderDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        isSliderDragging = false
                        activeSliderThumb = nil
                        
                        -- Re-enable input for all sliders
                        for _, slider in pairs(allSliders) do
                            slider.Thumb.Active = true
                        end
                        
                        -- Disconnect the continuous update loop
                        if runServiceConnection then
                            runServiceConnection:Disconnect()
                            runServiceConnection = nil
                        end

                        -- Animate thumb back to center
                        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
                        local tween = TweenService:Create(thumb, tweenInfo, {Position = UDim2.new(0.5, -9, 0.5, -9)})
                        tween:Play()

                        if dragConnection then dragConnection:Disconnect() end
                        if inputChangedConnection then inputChangedConnection:Disconnect() end
                    end
                end)
            end
        end
    end)
end


-- Create and setup all control rows
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

-- Live update of value text boxes from tool grip
game:GetService("RunService").RenderStepped:Connect(function()
    local tool = CenterModule:GetCurrentTool()
    if tool and mainFrame.Visible then
        local pos = tool.Grip.Position
        local rotX, rotY, rotZ = tool.Grip:ToEulerAnglesXYZ()

        -- Update Position page if visible and inputs are not focused
        if posPage.Visible then
            if not posControls.X.Input:IsFocused() then posControls.X.Input.Text = string.format("%.2f", pos.X) end
            if not posControls.Y.Input:IsFocused() then posControls.Y.Input.Text = string.format("%.2f", pos.Y) end
            if not posControls.Z.Input:IsFocused() then posControls.Z.Input.Text = string.format("%.2f", pos.Z) end
        -- Update Rotation page if visible and inputs are not focused
        elseif rotPage.Visible then
            if not rotControls.X.Input:IsFocused() then rotControls.X.Input.Text = string.format("%.1f", math.deg(rotX)) end
            if not rotControls.Y.Input:IsFocused() then rotControls.Y.Input.Text = string.format("%.1f", math.deg(rotY)) end
            if not rotControls.Z.Input:IsFocused() then rotControls.Z.Input.Text = string.format("%.1f", math.deg(rotZ)) end
        end
    end
end)

--- Freeze Button
local player = game:GetService("Players").LocalPlayer
local camera = workspace.CurrentCamera

local freezeButton = Instance.new("TextButton")
freezeButton.Name = "FreezeCameraButton"
freezeButton.Size = UDim2.new(0, 100, 0, 25)
freezeButton.Text = "Freeze Camera"
freezeButton.Font = Enum.Font.SourceSansBold
freezeButton.TextSize = 14
freezeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
freezeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
freezeButton.LayoutOrder = 3 -- Position after the other tabs
freezeButton.Parent = tabsContainer
local freezeCorner = Instance.new("UICorner", freezeButton)
freezeCorner.CornerRadius = UDim.new(0, 4)

-- state
local frozen = false
local camPart = nil
local conn

local function freezeCamera()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    camPart = Instance.new("Part")
    camPart.Name = "ClientCameraPart"
    camPart.Anchored = true
    camPart.CanCollide = false
    camPart.Transparency = 1 -- Hide the part
    camPart.Size = Vector3.new(1,1,1)
    camPart.CFrame = camera.CFrame
    camPart.Parent = workspace

    camera.CameraType = Enum.CameraType.Scriptable

    -- lock CFrame every frame
    conn = game:GetService("RunService").RenderStepped:Connect(function()
        if camPart then
            camera.CFrame = camPart.CFrame
        end
    end)
end

local function restoreCamera()
    if conn then conn:Disconnect() conn = nil end
    if camPart then camPart:Destroy() camPart = nil end
    camera.CameraType = Enum.CameraType.Custom
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject = hum end
end

freezeButton.MouseButton1Click:Connect(function()
    if not frozen then
        freezeCamera()
        freezeButton.Text = "Unfreeze Camera"
        freezeButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50) -- Change color to indicate it's active
        freezeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        restoreCamera()
        freezeButton.Text = "Freeze Camera"
        freezeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55) -- Restore color
        freezeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    frozen = not frozen
end)
