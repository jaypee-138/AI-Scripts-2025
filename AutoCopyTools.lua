local lp = game.Players.LocalPlayer

-- Settings
local AUTO_REFRESH_INTERVAL = 10 -- seconds
local TOOL_NAME_FILTER = {} -- Example: {"Katana", "Gun"} (leave empty to allow all)

-- Utility: Check if an object is a usable Tool
local function isTool(item)
    return item:IsA("Tool") or item:IsA("HopperBin")
end

-- Utility: Check if tool matches filter
local function isAllowedTool(toolName)
    if #TOOL_NAME_FILTER == 0 then return true end
    for _, allowedName in ipairs(TOOL_NAME_FILTER) do
        if string.lower(toolName) == string.lower(allowedName) then
            return true
        end
    end
    return false
end

-- UI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AutoCopyToolsGui"

local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Position = UDim2.new(0, 20, 0, 100)
Button.Text = "Copy Tools Now"
Button.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextScaled = true

local Notification = Instance.new("TextLabel", ScreenGui)
Notification.Size = UDim2.new(0, 200, 0, 30)
Notification.Position = UDim2.new(0, 20, 0, 160)
Notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Notification.TextColor3 = Color3.new(1, 1, 1)
Notification.TextScaled = true
Notification.Text = ""
Notification.BackgroundTransparency = 0.5

local function notify(text)
    Notification.Text = text
    -- Clear the message after 3 seconds
    task.delay(3, function()
        if Notification.Text == text then
            Notification.Text = ""
        end
    end)
end

-- Clone tools from other players
local function copyTools()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= lp then
            for _, container in pairs({player:FindFirstChild("Backpack"), player.Character}) do
                if container then
                    for _, tool in pairs(container:GetChildren()) do
                        if isTool(tool) and isAllowedTool(tool.Name) and not lp.Backpack:FindFirstChild(tool.Name) then
                            local cloned = tool:Clone()

                            -- Copy LocalScripts
                            for _, child in pairs(tool:GetDescendants()) do
                                if child:IsA("LocalScript") then
                                    local clonedScript = child:Clone()
                                    local parentObj = cloned:FindFirstChild(child.Parent.Name)
                                    clonedScript.Parent = parentObj or cloned
                                end
                            end

                            cloned.Parent = lp.Backpack
                            print("[AutoCopyTools] Cloned:", tool.Name)
                            notify("Cloned: " .. tool.Name)
                        end
                    end
                end
            end
        end
    end
end

-- Auto refresh loop
task.spawn(function()
    while true do
        pcall(copyTools)
        task.wait(AUTO_REFRESH_INTERVAL)
    end
end)

-- Button click triggers copy immediately
Button.MouseButton1Click:Connect(function()
    pcall(copyTools)
end)
