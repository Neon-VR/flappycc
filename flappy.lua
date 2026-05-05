-- flappy.cc - FULL SCRIPT (ScriptHub MASSIVELY EXPANDED - 15+ FE Trolling + 10 New Games)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
    Name = "flappy.cc",
    LoadingTitle = "flappy.cc",
    LoadingSubtitle = "flappy is not a skid w dev | Xeno",
    ConfigurationSaving = { Enabled = true, FolderName = "flappy.cc", FileName = "FullConfig" }
})

Rayfield:Notify({Title = "flappy.cc", Content = "ScriptHub MASSIVELY EXPANDED - 15+ FE Trolling + 10 New Games", Duration = 6})

local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- ====================== COMBAT TAB ======================
local Combat = Window:CreateTab("Combat", 4483362458)

-- Settings
local AimbotEnabled = false
local SilentAimEnabled = false
local VisCheck = true
local TargetTeammates = false
local TargetNPCs = false
local BulletPrediction = false
local BulletDropCompensation = true
local Smoothness = 12
local AimFOV = 120
local MaxAimDistance = 300
local AimPart = "Head"
local BulletSpeed = 1500
local GameFOV = 70

local currentTarget = nil
local lockedTarget = nil

local AimbotKey = Enum.UserInputType.MouseButton2   -- Default RMB
local SilentAimKey = Enum.KeyCode.R                 -- Default R

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.75
FOVCircle.Filled = false
FOVCircle.Visible = false

-- ====================== UI ======================
Combat:CreateToggle({
    Name = "AI Aimbot",
    CurrentValue = false,
    Callback = function(v) AimbotEnabled = v end
})

Combat:CreateKeybind({
    Name = "Aimbot Keybind",
    CurrentKeybind = "MouseButton2",
    HoldToUse = true,
    Callback = function() end
})

Combat:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(v) SilentAimEnabled = v end
})

Combat:CreateKeybind({
    Name = "Silent Aim Keybind",
    CurrentKeybind = "R",
    HoldToUse = true,
    Callback = function() end
})

Combat:CreateToggle({Name = "VisCheck (Only Visible Players)", CurrentValue = true, Callback = function(v) VisCheck = v end})
Combat:CreateToggle({Name = "Target Teammates", CurrentValue = false, Callback = function(v) TargetTeammates = v end})
Combat:CreateToggle({Name = "Target NPCs/Bots", CurrentValue = false, Callback = function(v) TargetNPCs = v end})
Combat:CreateToggle({Name = "Bullet Prediction", CurrentValue = false, Callback = function(v) BulletPrediction = v end})
Combat:CreateToggle({Name = "Bullet Drop Compensation", CurrentValue = true, Callback = function(v) BulletDropCompensation = v end})

Combat:CreateInput({Name = "Max Aim Distance (studs)", PlaceholderText = "300", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then MaxAimDistance = math.clamp(num, 50, 2000) end end})
Combat:CreateInput({Name = "Aimbot Smoothness (1-25)", PlaceholderText = "12", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then Smoothness = math.clamp(num, 1, 25) end end})
Combat:CreateInput({Name = "Aimbot FOV (30-400)", PlaceholderText = "120", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then AimFOV = math.clamp(num, 30, 400) end end})
Combat:CreateInput({Name = "Bullet Speed (studs/s)", PlaceholderText = "1500", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then BulletSpeed = math.clamp(num, 500, 5000) end end})

Combat:CreateDropdown({Name = "Aim Part", Options = {"Head", "UpperTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(opt) AimPart = opt[1] end})
Combat:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

-- Game FOV Changer
Combat:CreateInput({
    Name = "Game FOV (30-120)",
    PlaceholderText = "70",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            GameFOV = math.clamp(num, 30, 120)
            Camera.FieldOfView = GameFOV
        end
    end
})

-- ====================== TARGET SELECTION ======================
task.spawn(function()
    while true do
        task.wait(0.03)

        if not (AimbotEnabled or SilentAimEnabled) then
            lockedTarget = nil
            currentTarget = nil
            continue
        end

        local lp = game.Players.LocalPlayer
        local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not lpRoot then continue end

        if lockedTarget and lockedTarget.Parent then
            local char = lockedTarget.Parent
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                local pos, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
                local centerDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if onScreen and centerDist <= AimFOV + 25 then
                    currentTarget = lockedTarget
                    continue
                end
            end
        end

        local bestTarget, bestScore = nil, -math.huge
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr == lp or not plr.Character then continue end
            if not TargetTeammates and plr.Team == lp.Team then continue end

            local char = plr.Character
            local targetPart = char:FindFirstChild(AimPart) or char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if not targetPart or not root or not hum or hum.Health <= 0 then continue end

            local distance = (targetPart.Position - lpRoot.Position).Magnitude
            if distance > MaxAimDistance then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end

            local centerDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if centerDist > AimFOV then continue end

            if VisCheck then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {lp.Character}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
                if result and not result.Instance:IsDescendantOf(char) then continue end
            end

            local score = -centerDist * 2.5 - distance * 0.6
            if targetPart.Name == "Head" then score += 35 end

            if score > bestScore then
                bestScore = score
                bestTarget = targetPart
            end
        end

        if bestTarget then
            lockedTarget = bestTarget
            currentTarget = bestTarget
        end
    end
end)

-- ====================== AIMING ======================
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = AimFOV

    local target = currentTarget
    if not target or not target.Parent then return end

    local hum = target.Parent:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then
        currentTarget = nil
        lockedTarget = nil
        return
    end

    local aimPos = target.Position
    local root = target.Parent:FindFirstChild("HumanoidRootPart")

    if BulletPrediction and root and root.Velocity then
        local lpRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if lpRoot then
            local dist = (aimPos - lpRoot.Position).Magnitude
            local travelTime = dist / BulletSpeed
            local predicted = aimPos + root.Velocity * travelTime
            if BulletDropCompensation then
                local drop = 0.5 * workspace.Gravity * travelTime^2
                predicted += Vector3.new(0, -drop * 0.75, 0)
            end
            aimPos = predicted
        end
    end

    -- Aimbot with custom keybind
    if AimbotEnabled then
        local isPressed = (AimbotKey.EnumType == Enum.UserInputType and UserInput:IsMouseButtonPressed(AimbotKey)) or 
                          (AimbotKey.EnumType == Enum.KeyCode and UserInput:IsKeyDown(AimbotKey))
        if isPressed then
            local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / math.max(Smoothness, 5))
        end
    end

    -- Silent Aim with custom keybind
    if SilentAimEnabled then
        local isPressed = (SilentAimKey.EnumType == Enum.UserInputType and UserInput:IsMouseButtonPressed(SilentAimKey)) or 
                          (SilentAimKey.EnumType == Enum.KeyCode and UserInput:IsKeyDown(SilentAimKey))
        if isPressed then
            local mouse = game.Players.LocalPlayer:GetMouse()
            mouse.Target = target
        end
    end
end)

print("✅ Combat Tab with Custom Keybinds Loaded!")
-- ====================== TROLL TAB ======================
local Troll = Window:CreateTab("Troll", 4483362458)

-- Settings
local KillAllEnabled = false
local KillAllLoop = false
local KillTeammates = false
local KillSelectedEnabled = false
local LoopKillSelected = false

local SelectedPlayer = nil
local killedPlayers = {}  -- For one-time Kill All
local trollTarget = nil

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- ====================== UI ======================
Troll:CreateToggle({
    Name = "Kill All (Enemies Only)",
    CurrentValue = false,
    Callback = function(v) KillAllEnabled = v end
})

Troll:CreateToggle({
    Name = "Kill All Loop",
    CurrentValue = false,
    Callback = function(v) KillAllLoop = v end
})

Troll:CreateToggle({
    Name = "Kill Teammates",
    CurrentValue = false,
    Callback = function(v) KillTeammates = v end
})

-- Player Dropdown (Auto-updates)
local playerList = {}
for _, plr in ipairs(game.Players:GetPlayers()) do
    if plr ~= game.Players.LocalPlayer then
        table.insert(playerList, plr.Name)
    end
end

Troll:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = {""},
    Callback = function(opt)
        local plrName = opt[1]
        if plrName and plrName ~= "" then
            local plr = game.Players:FindFirstChild(plrName)
            if plr and plr.Character then
                SelectedPlayer = plr.Character:FindFirstChild("HumanoidRootPart")
            end
        else
            SelectedPlayer = nil
        end
    end
})

Troll:CreateToggle({
    Name = "Kill Selected Player",
    CurrentValue = false,
    Callback = function(v) KillSelectedEnabled = v end
})

Troll:CreateToggle({
    Name = "Loop Kill Selected Player",
    CurrentValue = false,
    Callback = function(v) LoopKillSelected = v end
})

-- ====================== MAIN TROLL LOOP ======================
RunService.RenderStepped:Connect(function()
    trollTarget = nil

    local lp = game.Players.LocalPlayer
    local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not lpRoot then return end

    -- === Kill All Logic ===
    if KillAllEnabled or KillAllLoop then
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr == lp then continue end
            if not plr.Character then continue end

            -- Team Check
            if not KillTeammates and plr.Team == lp.Team then continue end

            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            if not killedPlayers[plr] then
                trollTarget = hrp
                break
            end
        end

        -- Reset killed list for looping
        if KillAllLoop and not trollTarget then
            killedPlayers = {}
        end
    end

    -- === Kill Selected Player Logic ===
    if not trollTarget and (KillSelectedEnabled or LoopKillSelected) then
        trollTarget = SelectedPlayer
    end

    -- === Execute Troll ===
    if trollTarget and trollTarget.Parent then
        local targetHum = trollTarget.Parent:FindFirstChild("Humanoid")
        
        -- TP Behind Target (Improved)
        if targetHum and targetHum.Health > 0 then
            local targetCFrame = trollTarget.CFrame
            -- Position behind + face them
            local behindOffset = targetCFrame * CFrame.new(0, 0, 5)  -- 5 studs behind
            lpRoot.CFrame = behindOffset * CFrame.Angles(0, math.rad(180), 0)
        end

        -- Auto Click (Right Click + Fire)
        if UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            VirtualUser:Button1Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(0.03)
            VirtualUser:Button1Up(Vector2.new(0, 0), Camera.CFrame)
        end

        -- Mark as killed
        if targetHum and targetHum.Health <= 0 then
            local plr = game.Players:GetPlayerFromCharacter(trollTarget.Parent)
            if plr then
                killedPlayers[plr] = true
            end
            trollTarget = nil
        end
    end
end)

-- Auto refresh dropdown when players join/leave
game.Players.PlayerAdded:Connect(function()
    -- You can refresh dropdown if needed, but Rayfield usually handles it
end)

print("✅ Troll Tab Loaded - TP Behind + Team Control")
-- flappy.cc - FULL SCRIPT (FIXED & OPTIMIZED)
-- Fixed: ESP Section, Variable Conflicts, and UI Loading Issues

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
    Name = "flappy.cc",
    LoadingTitle = "flappy.cc",
    LoadingSubtitle = "flappy is not a skid w dev | Xeno",
    ConfigurationSaving = { Enabled = true, FolderName = "flappy.cc", FileName = "FullConfig" }
})

Rayfield:Notify({Title = "flappy.cc", Content = "ScriptHub MASSIVELY EXPANDED - 15+ FE Trolling + 10 New Games", Duration = 6})

-- ====================== GLOBAL SERVICES (DEFINED ONCE) ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ====================== COMBAT TAB ======================
local Combat = Window:CreateTab("Combat", 4483362458)

-- Settings
local AimbotEnabled = false
local SilentAimEnabled = false
local VisCheck = true
local TargetTeammates = false
local TargetNPCs = false
local BulletPrediction = false
local BulletDropCompensation = true
local Smoothness = 12
local AimFOV = 120
local MaxAimDistance = 300
local AimPart = "Head"
local BulletSpeed = 1500
local GameFOV = 70

local currentTarget = nil
local lockedTarget = nil

local AimbotKey = Enum.UserInputType.MouseButton2   -- Default RMB
local SilentAimKey = Enum.KeyCode.R                 -- Default R

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.75
FOVCircle.Filled = false
FOVCircle.Visible = false

-- ====================== COMBAT UI ======================
Combat:CreateToggle({
    Name = "AI Aimbot",
    CurrentValue = false,
    Callback = function(v) AimbotEnabled = v end
})

Combat:CreateKeybind({
    Name = "Aimbot Keybind",
    CurrentKeybind = "MouseButton2",
    HoldToUse = true,
    Callback = function() end
})

Combat:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Callback = function(v) SilentAimEnabled = v end
})

Combat:CreateKeybind({
    Name = "Silent Aim Keybind",
    CurrentKeybind = "R",
    HoldToUse = true,
    Callback = function() end
})

Combat:CreateToggle({Name = "VisCheck (Only Visible Players)", CurrentValue = true, Callback = function(v) VisCheck = v end})
Combat:CreateToggle({Name = "Target Teammates", CurrentValue = false, Callback = function(v) TargetTeammates = v end})
Combat:CreateToggle({Name = "Target NPCs/Bots", CurrentValue = false, Callback = function(v) TargetNPCs = v end})
Combat:CreateToggle({Name = "Bullet Prediction", CurrentValue = false, Callback = function(v) BulletPrediction = v end})
Combat:CreateToggle({Name = "Bullet Drop Compensation", CurrentValue = true, Callback = function(v) BulletDropCompensation = v end})

Combat:CreateInput({Name = "Max Aim Distance (studs)", PlaceholderText = "300", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then MaxAimDistance = math.clamp(num, 50, 2000) end end})
Combat:CreateInput({Name = "Aimbot Smoothness (1-25)", PlaceholderText = "12", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then Smoothness = math.clamp(num, 1, 25) end end})
Combat:CreateInput({Name = "Aimbot FOV (30-400)", PlaceholderText = "120", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then AimFOV = math.clamp(num, 30, 400) end end})
Combat:CreateInput({Name = "Bullet Speed (studs/s)", PlaceholderText = "1500", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then BulletSpeed = math.clamp(num, 500, 5000) end end})

Combat:CreateDropdown({Name = "Aim Part", Options = {"Head", "UpperTorso", "HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(opt) AimPart = opt[1] end})
Combat:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

Combat:CreateInput({
    Name = "Game FOV (30-120)",
    PlaceholderText = "70",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            GameFOV = math.clamp(num, 30, 120)
            Camera.FieldOfView = GameFOV
        end
    end
})

-- ====================== TARGET SELECTION ======================
task.spawn(function()
    while true do
        task.wait(0.03)

        if not (AimbotEnabled or SilentAimEnabled) then
            lockedTarget = nil
            currentTarget = nil
            continue
        end

        local lpRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not lpRoot then continue end

        if lockedTarget and lockedTarget.Parent then
            local char = lockedTarget.Parent
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                local pos, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
                local centerDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if onScreen and centerDist <= AimFOV + 25 then
                    currentTarget = lockedTarget
                    continue
                end
            end
        end

        local bestTarget, bestScore = nil, -math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer or not plr.Character then continue end
            if not TargetTeammates and plr.Team == LocalPlayer.Team then continue end

            local char = plr.Character
            local targetPart = char:FindFirstChild(AimPart) or char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if not targetPart or not root or not hum or hum.Health <= 0 then continue end

            local distance = (targetPart.Position - lpRoot.Position).Magnitude
            if distance > MaxAimDistance then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            if not onScreen then continue end

            local centerDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if centerDist > AimFOV then continue end

            if VisCheck then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {LocalPlayer.Character}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, params)
                if result and not result.Instance:IsDescendantOf(char) then continue end
            end

            local score = -centerDist * 2.5 - distance * 0.6
            if targetPart.Name == "Head" then score += 35 end

            if score > bestScore then
                bestScore = score
                bestTarget = targetPart
            end
        end

        if bestTarget then
            lockedTarget = bestTarget
            currentTarget = bestTarget
        end
    end
end)

-- ====================== AIMING ======================
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = AimFOV

    local target = currentTarget
    if not target or not target.Parent then return end

    local hum = target.Parent:FindFirstChild("Humanoid")
    if hum and hum.Health <= 0 then
        currentTarget = nil
        lockedTarget = nil
        return
    end

    local aimPos = target.Position
    local root = target.Parent:FindFirstChild("HumanoidRootPart")

    if BulletPrediction and root and root.Velocity then
        local lpRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if lpRoot then
            local dist = (aimPos - lpRoot.Position).Magnitude
            local travelTime = dist / BulletSpeed
            local predicted = aimPos + root.Velocity * travelTime
            if BulletDropCompensation then
                local drop = 0.5 * workspace.Gravity * travelTime^2
                predicted += Vector3.new(0, -drop * 0.75, 0)
            end
            aimPos = predicted
        end
    end

    -- Aimbot with custom keybind
    if AimbotEnabled then
        local isPressed = (AimbotKey.EnumType == Enum.UserInputType and UserInputService:IsMouseButtonPressed(AimbotKey)) or 
                          (AimbotKey.EnumType == Enum.KeyCode and UserInputService:IsKeyDown(AimbotKey))
        if isPressed then
            local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / math.max(Smoothness, 5))
        end
    end

    -- Silent Aim with custom keybind
    if SilentAimEnabled then
        local isPressed = (SilentAimKey.EnumType == Enum.UserInputType and UserInputService:IsMouseButtonPressed(SilentAimKey)) or 
                          (SilentAimKey.EnumType == Enum.KeyCode and UserInputService:IsKeyDown(SilentAimKey))
        if isPressed then
            local mouse = LocalPlayer:GetMouse()
            mouse.Target = target
        end
    end
end)

print("✅ Combat Tab with Custom Keybinds Loaded!")

-- ====================== TROLL TAB ======================
local Troll = Window:CreateTab("Troll", 4483362458)

-- Settings
local KillAllEnabled = false
local KillAllLoop = false
local KillTeammates = false
local KillSelectedEnabled = false
local LoopKillSelected = false

local SelectedPlayer = nil
local killedPlayers = {}  
local trollTarget = nil

-- ====================== TROLL UI ======================
Troll:CreateToggle({
    Name = "Kill All (Enemies Only)",
    CurrentValue = false,
    Callback = function(v) KillAllEnabled = v end
})

Troll:CreateToggle({
    Name = "Kill All Loop",
    CurrentValue = false,
    Callback = function(v) KillAllLoop = v end
})

Troll:CreateToggle({
    Name = "Kill Teammates",
    CurrentValue = false,
    Callback = function(v) KillTeammates = v end
})

-- Player Dropdown (Auto-updates)
local function refreshPlayerList()
    local playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr.Name)
        end
    end
    -- Note: Rayfield dropdowns don't dynamically refresh options easily without recreating the UI.
    -- This function is a placeholder for logic that would require UI recreation.
    -- For now, we rely on the initial list or manual refresh if the user reloads.
end

local playerList = {}
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        table.insert(playerList, plr.Name)
    end
end

Troll:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = {""},
    Callback = function(opt)
        local plrName = opt[1]
        if plrName and plrName ~= "" then
            local plr = Players:FindFirstChild(plrName)
            if plr and plr.Character then
                SelectedPlayer = plr.Character:FindFirstChild("HumanoidRootPart")
            end
        else
            SelectedPlayer = nil
        end
    end
})

Troll:CreateToggle({
    Name = "Kill Selected Player",
    CurrentValue = false,
    Callback = function(v) KillSelectedEnabled = v end
})

Troll:CreateToggle({
    Name = "Loop Kill Selected Player",
    CurrentValue = false,
    Callback = function(v) LoopKillSelected = v end
})

-- ====================== MAIN TROLL LOOP ======================
RunService.RenderStepped:Connect(function()
    trollTarget = nil

    local lpRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lpRoot then return end

    -- === Kill All Logic ===
    if KillAllEnabled or KillAllLoop then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            if not plr.Character then continue end

            -- Team Check
            if not KillTeammates and plr.Team == LocalPlayer.Team then continue end

            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            if not killedPlayers[plr] then
                trollTarget = hrp
                break
            end
        end

        -- Reset killed list for looping
        if KillAllLoop and not trollTarget then
            killedPlayers = {}
        end
    end

    -- === Kill Selected Player Logic ===
    if not trollTarget and (KillSelectedEnabled or LoopKillSelected) then
        trollTarget = SelectedPlayer
    end

    -- === Execute Troll ===
    if trollTarget and trollTarget.Parent then
        local targetHum = trollTarget.Parent:FindFirstChild("Humanoid")
        
        -- TP Behind Target (Improved)
        if targetHum and targetHum.Health > 0 then
            local targetCFrame = trollTarget.CFrame
            -- Position behind + face them
            local behindOffset = targetCFrame * CFrame.new(0, 0, 5)  -- 5 studs behind
            lpRoot.CFrame = behindOffset * CFrame.Angles(0, math.rad(180), 0)
        end

        -- Auto Click (Right Click + Fire)
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            VirtualUser:Button1Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(0.03)
            VirtualUser:Button1Up(Vector2.new(0, 0), Camera.CFrame)
        end

        -- Mark as killed
        if targetHum and targetHum.Health <= 0 then
            local plr = Players:GetPlayerFromCharacter(trollTarget.Parent)
            if plr then
                killedPlayers[plr] = true
            end
            trollTarget = nil
        end
    end
end)

print("✅ Troll Tab Loaded - TP Behind + Team Control")

-- ====================== FIXED ESP TAB ======================
local ESPTab = Window:CreateTab("ESP", 4483362458)

-- SETTINGS
local ESPEnabled = false
local ShowTeammates = false
local ShowBoxes = false
local ShowTracers = false
local ShowNames = false
local ShowHealth = false
local ShowDistance = false
local Chams = false
local MaxDistance = 1000

local ESPCache = {}

-- ScreenGui for Tracers
local TracerFolder = Instance.new("ScreenGui")
TracerFolder.Name = "ESP_TRACERS_CLEAN"
TracerFolder.ResetOnSpawn = false
TracerFolder.Parent = game.CoreGui
TracerFolder.IgnoreGuiInset = true

-- AGGRESSIVE CLEANUP FUNCTION
local function ClearESPObject(data)
    if not data then return end
    pcall(function()
        if data.billboard then data.billboard:Destroy() end
        if data.highlight then data.highlight:Destroy() end
        if data.tracer then data.tracer:Destroy() end
        if data.boxLines then
            for _, line in ipairs(data.boxLines) do
                if line and line.Remove then line:Remove() end
            end
        end
    end)
end

local function Clear(plr)
    local data = ESPCache[plr]
    if data then
        ClearESPObject(data)
        ESPCache[plr] = nil
    end
end

local function ClearAllESP()
    for plr, data in pairs(ESPCache) do
        ClearESPObject(data)
    end
    table.clear(ESPCache)
}

-- DRAW OUTLINED BOX (SAFE & VALIDATED)
local function DrawSafeBox(color, char)
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
    
    if not head or not torso then return nil end

    local headPos, headVisible = Camera:WorldToViewportPoint(head.Position)
    local torsoPos, torsoVisible = Camera:WorldToViewportPoint(torso.Position)

    if not headVisible and not torsoVisible then
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local rootPos, rootVisible = Camera:WorldToViewportPoint(root.Position)
        if not rootVisible then return nil end
    end

    local parts = {}
    for _, partName in ipairs({"Head", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end

    if #parts == 0 then return nil end

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local validPoints = 0

    for _, part in ipairs(parts) do
        local pos, visible = Camera:WorldToViewportPoint(part.Position)
        if visible then
            validPoints = validPoints + 1
            minX = math.min(minX, pos.X)
            minY = math.min(minY, pos.Y)
            maxX = math.max(maxX, pos.X)
            maxY = math.max(maxY, pos.Y)
        end
    end

    if validPoints == 0 then return nil end

    local padding = 5
    minX = math.max(0, minX - padding)
    minY = math.max(0, minY - padding)
    maxX = math.min(Camera.ViewportSize.X, maxX + padding)
    maxY = math.min(Camera.ViewportSize.Y, maxY + padding)

    local lines = {}
    local thickness = 1

    local topLine = Drawing.new("Line")
    topLine.From = Vector2.new(minX, minY)
    topLine.To = Vector2.new(maxX, minY)
    topLine.Color = color
    topLine.Thickness = thickness
    topLine.Transparency = 1
    table.insert(lines, topLine)

    local bottomLine = Drawing.new("Line")
    bottomLine.From = Vector2.new(minX, maxY)
    bottomLine.To = Vector2.new(maxX, maxY)
    bottomLine.Color = color
    bottomLine.Thickness = thickness
    bottomLine.Transparency = 1
    table.insert(lines, bottomLine)

    local leftLine = Drawing.new("Line")
    leftLine.From = Vector2.new(minX, minY)
    leftLine.To = Vector2.new(minX, maxY)
    leftLine.Color = color
    leftLine.Thickness = thickness
    leftLine.Transparency = 1
    table.insert(lines, leftLine)

    local rightLine = Drawing.new("Line")
    rightLine.From = Vector2.new(maxX, minY)
    rightLine.To = Vector2.new(maxX, maxY)
    rightLine.Color = color
    rightLine.Thickness = thickness
    rightLine.Transparency = 1
    table.insert(lines, rightLine)

    return lines
end

-- CREATE ESP OBJECTS
local function Create(plr)
    Clear(plr) 

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = nil 

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = false
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.3
    label.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.85 
    highlight.OutlineTransparency = 0.5

    local tracer = Instance.new("Frame")
    tracer.Size = UDim2.new(0, 1, 0, 1) 
    tracer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tracer.BorderSizePixel = 0
    tracer.Parent = TracerFolder

    ESPCache[plr] = {
        billboard = billboard,
        label = label,
        highlight = highlight,
        tracer = tracer,
        boxLines = nil 
    }
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then 
        ClearAllESP()
        return 
    end

    local lpChar = LocalPlayer.Character
    local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")
    if not lpRoot then return end

    for plr, data in pairs(ESPCache) do
        if not Players:GetPlayerFromCharacter(plr) or plr == LocalPlayer then
            Clear(plr)
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end

        local char = plr.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if not char or not hum or hum.Health <= 0 or not root then
            Clear(plr)
            continue
        end

        if not ShowTeammates and plr.Team == LocalPlayer.Team then
            Clear(plr)
            continue
        end

        local dist = (root.Position - lpRoot.Position).Magnitude
        if dist > MaxDistance then
            Clear(plr)
            continue
        end

        if not ESPCache[plr] then
            Create(plr)
        end
        local esp = ESPCache[plr]
        if not esp then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
        
        if not onScreen then
            if esp.billboard then esp.billboard.Enabled = false end
            if esp.tracer then esp.tracer.Visible = false end
            if esp.boxLines then
                for _, line in ipairs(esp.boxLines) do
                    if line and line.Remove then line:Remove() end
                end
                esp.boxLines = nil
            end
            continue
        end

        local color = (plr.Team == LocalPlayer.Team)
            and Color3.fromRGB(170, 85, 255) 
            or Color3.fromRGB(255, 0, 0)

        -- 1. HANDLE TEXT (Billboard)
        if ShowNames or ShowHealth or ShowDistance then
            local head = char:FindFirstChild("Head")
            if head then
                esp.billboard.Adornee = head
                esp.billboard.Parent = head
                esp.billboard.Enabled = true

                local textParts = {}
                if ShowNames then table.insert(textParts, plr.Name) end
                if ShowHealth then table.insert(textParts, "HP: " .. math.floor(hum.Health)) end
                if ShowDistance then table.insert(textParts, string.format("%.0fm", dist)) end

                esp.label.Text = table.concat(textParts, " | ")
                esp.label.TextColor3 = color
            end
        else
            if esp.billboard then esp.billboard.Enabled = false end
        end

        -- 2. HANDLE CHAMS
        if Chams then
            esp.highlight.Parent = char
            esp.highlight.FillColor = color
            esp.highlight.OutlineColor = color
        else
            esp.highlight.Parent = nil
        end

        -- 3. HANDLE TRACERS
        if ShowTracers then
            esp.tracer.Visible = true
            esp.tracer.Position = UDim2.new(0.5, 0, 0.5, 0)
            esp.tracer.Size = UDim2.new(0, 2, 0, 2)
            esp.tracer.BackgroundColor3 = color
        else
            esp.tracer.Visible = false
        end

        -- 4. HANDLE BOXES
        if ShowBoxes then
            if esp.boxLines then
                for _, line in ipairs(esp.boxLines) do
                    if line and line.Remove then line:Remove() end
                end
                esp.boxLines = nil
            end
            esp.boxLines = DrawSafeBox(color, char)
        else
            if esp.boxLines then
                for _, line in ipairs(esp.boxLines) do
                    if line and line.Remove then line:Remove() end
                end
                esp.boxLines = nil
            end
        end
    end
end)

-- ESP UI
ESPTab:CreateToggle({Name = "Enable ESP", CurrentValue = false, Callback = function(v) ESPEnabled = v end})
ESPTab:CreateToggle({Name = "Show Teammates", CurrentValue = false, Callback = function(v) ShowTeammates = v end})
ESPTab:CreateToggle({Name = "Show Boxes", CurrentValue = false, Callback = function(v) ShowBoxes = v end})
ESPTab:CreateToggle({Name = "Show Tracers", CurrentValue = false, Callback = function(v) ShowTracers = v end})
ESPTab:CreateToggle({Name = "Show Names", CurrentValue = false, Callback = function(v) ShowNames = v end})
ESPTab:CreateToggle({Name = "Show Health", CurrentValue = false, Callback = function(v) ShowHealth = v end})
ESPTab:CreateToggle({Name = "Show Distance", CurrentValue = false, Callback = function(v) ShowDistance = v end})
ESPTab:CreateToggle({Name = "Chams (Highlight)", CurrentValue = false, Callback = function(v) Chams = v end})
ESPTab:CreateInput({Name = "Max Distance", PlaceholderText = "1000", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then MaxDistance = math.clamp(num, 100, 5000) end end})

print("✅ ESP Tab Fixed and Loaded!")

-- ====================== MOVEMENT TAB ======================
local Movement = Window:CreateTab("Movement", 4483362458)

-- Settings
local WalkSpeedEnabled = false
local JumpPowerEnabled = false
local InfiniteJumpEnabled = false
local NoClipEnabled = false
local FlyEnabled = false
local BhopEnabled = false
local SpeedMultiplierEnabled = false

local CustomWalkSpeed = 50
local CustomJumpPower = 50
local FlySpeed = 50
local SpeedMultiplier = 1.5

local FlyConnection = nil
local NoClipConnection = nil

-- Apply WalkSpeed & JumpPower
local function ApplyMovement()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        if WalkSpeedEnabled then 
            hum.WalkSpeed = CustomWalkSpeed 
        end
        if JumpPowerEnabled then 
            hum.JumpPower = CustomJumpPower 
        end
    end
}

-- ====================== INFINITE JUMP ======================
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ====================== BHOP ======================
RunService.Heartbeat:Connect(function()
    if not BhopEnabled then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ====================== NOCLIP ======================
local function StartNoClip()
    if NoClipConnection then return end
    NoClipConnection = RunService.Stepped:Connect(function()
        if not NoClipEnabled then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function StopNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- ====================== FLY ======================
local function StartFly()
    if FlyConnection then return end

    local bodyVelocity = Instance.new("BodyVelocity")
    local bodyGyro = Instance.new("BodyGyro")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 12500

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        bodyVelocity.Parent = root
        bodyGyro.Parent = root

        local moveDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDirection -= Vector3.new(0,1,0) end

        bodyVelocity.Velocity = moveDirection.Unit * FlySpeed
        bodyGyro.CFrame = Camera.CFrame
    end)
end

local function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
end

-- ====================== SPEED MULTIPLIER ======================
RunService.Heartbeat:Connect(function()
    if not SpeedMultiplierEnabled then return end
    local char = LocalPlayer.Character
    local hum = char and char
-- ====================== MOVEMENT ======================
local Movement = Window:CreateTab("Movement", 4483362458)

-- Settings
local WalkSpeedEnabled = false
local JumpPowerEnabled = false
local InfiniteJumpEnabled = false
local NoClipEnabled = false
local FlyEnabled = false
local BhopEnabled = false
local SpeedMultiplierEnabled = false

local CustomWalkSpeed = 50
local CustomJumpPower = 50
local FlySpeed = 50
local SpeedMultiplier = 1.5

local FlyConnection = nil
local NoClipConnection = nil

local lp = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Apply WalkSpeed & JumpPower
local function ApplyMovement()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then
        if WalkSpeedEnabled then 
            hum.WalkSpeed = CustomWalkSpeed 
        end
        if JumpPowerEnabled then 
            hum.JumpPower = CustomJumpPower 
        end
    end
end

-- ====================== INFINITE JUMP ======================
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ====================== BHOP ======================
game:GetService("RunService").Heartbeat:Connect(function()
    if not BhopEnabled then return end
    local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
    if hum and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ====================== NOCLIP ======================
local function StartNoClip()
    if NoClipConnection then return end
    NoClipConnection = game:GetService("RunService").Stepped:Connect(function()
        if not NoClipEnabled then return end
        local char = lp.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function StopNoClip()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    local char = lp.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- ====================== FLY ======================
local function StartFly()
    if FlyConnection then return end

    local bodyVelocity = Instance.new("BodyVelocity")
    local bodyGyro = Instance.new("BodyGyro")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 12500

    FlyConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        bodyVelocity.Parent = root
        bodyGyro.Parent = root

        local moveDirection = Vector3.new(0, 0, 0)
        local UIS = game:GetService("UserInputService")

        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDirection += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDirection -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDirection -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDirection += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then moveDirection -= Vector3.new(0,1,0) end

        bodyVelocity.Velocity = moveDirection.Unit * FlySpeed
        bodyGyro.CFrame = Camera.CFrame
    end)
end

local function StopFly()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
end

-- ====================== SPEED MULTIPLIER ======================
game:GetService("RunService").Heartbeat:Connect(function()
    if not SpeedMultiplierEnabled then return end
    local char = lp.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = CustomWalkSpeed * SpeedMultiplier
    end
end)

-- ====================== UI ======================
Movement:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Callback = function(v) WalkSpeedEnabled = v; ApplyMovement() end
})

Movement:CreateInput({
    Name = "WalkSpeed Value",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            CustomWalkSpeed = math.clamp(num, 0, 1000)
            if WalkSpeedEnabled then ApplyMovement() end
        end
    end
})

Movement:CreateToggle({
    Name = "Speed Multiplier",
    CurrentValue = false,
    Callback = function(v) SpeedMultiplierEnabled = v end
})

Movement:CreateInput({
    Name = "Speed Multiplier (x)",
    PlaceholderText = "1.5",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            SpeedMultiplier = math.clamp(num, 0.5, 10)
        end
    end
})

Movement:CreateToggle({
    Name = "Enable JumpPower",
    CurrentValue = false,
    Callback = function(v) JumpPowerEnabled = v; ApplyMovement() end
})

Movement:CreateInput({
    Name = "JumpPower Value",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then
            CustomJumpPower = math.clamp(num, 0, 1000)
            if JumpPowerEnabled then ApplyMovement() end
        end
    end
})

Movement:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v) InfiniteJumpEnabled = v end
})

Movement:CreateToggle({
    Name = "Bhop (Hold Space)",
    CurrentValue = false,
    Callback = function(v) BhopEnabled = v end
})

Movement:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v)
        NoClipEnabled = v
        if v then StartNoClip() else StopNoClip() end
    end
})

Movement:CreateToggle({
    Name = "Fly (WASD + E/Q)",
    CurrentValue = false,
    Callback = function(v)
        FlyEnabled = v
        if v then StartFly() else StopFly() end
    end
})

Movement:CreateInput({
    Name = "Fly Speed",
    PlaceholderText = "50",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local num = tonumber(text)
        if num then FlySpeed = math.clamp(num, 10, 500) end
    end
})

-- Respawn Handler
lp.CharacterAdded:Connect(function()
    task.wait(0.6)
    ApplyMovement()
end)

print("✅ Full Movement Tab Loaded (Speed Multiplier + Bhop Added)")
-- ====================== CUSTOM CROSSHAIR TAB ======================
local CrosshairTab = Window:CreateTab("Crosshair", 4483362458)

local DavidStarEnabled = false
local StarSize = 35
local StarColor = Color3.fromRGB(0, 255, 255)

local StarObjects = {}
local CrosshairConnection = nil
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Create David Star
local function CreateDavidStar()
    -- Full clear
    for _, obj in pairs(StarObjects) do
        if obj and obj.Remove then obj:Remove() end
    end
    table.clear(StarObjects)

    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2

    -- Triangle 1 (Up)
    local star1 = Drawing.new("Triangle")
    star1.PointA = Vector2.new(centerX, centerY - StarSize)
    star1.PointB = Vector2.new(centerX - StarSize * 0.866, centerY + StarSize * 0.5)
    star1.PointC = Vector2.new(centerX + StarSize * 0.866, centerY + StarSize * 0.5)
    star1.Color = StarColor
    star1.Thickness = 2.8
    star1.Transparency = 1
    star1.Filled = false
    table.insert(StarObjects, star1)

    -- Triangle 2 (Down)
    local star2 = Drawing.new("Triangle")
    star2.PointA = Vector2.new(centerX, centerY + StarSize)
    star2.PointB = Vector2.new(centerX - StarSize * 0.866, centerY - StarSize * 0.5)
    star2.PointC = Vector2.new(centerX + StarSize * 0.866, centerY - StarSize * 0.5)
    star2.Color = StarColor
    star2.Thickness = 2.8
    star2.Transparency = 1
    star2.Filled = false
    table.insert(StarObjects, star2)

    -- Center Dot
    local centerDot = Drawing.new("Circle")
    centerDot.Position = Vector2.new(centerX, centerY)
    centerDot.Radius = 2.5
    centerDot.Color = Color3.fromRGB(255, 255, 255)
    centerDot.Transparency = 1
    centerDot.Filled = true
    table.insert(StarObjects, centerDot)
end

local function StartDavidStar()
    if CrosshairConnection then return end

    CreateDavidStar()

    CrosshairConnection = RunService.RenderStepped:Connect(function()
        if not DavidStarEnabled then return end

        local centerX = Camera.ViewportSize.X / 2
        local centerY = Camera.ViewportSize.Y / 2

        if #StarObjects == 3 then
            StarObjects[1].PointA = Vector2.new(centerX, centerY - StarSize)
            StarObjects[1].PointB = Vector2.new(centerX - StarSize * 0.866, centerY + StarSize * 0.5)
            StarObjects[1].PointC = Vector2.new(centerX + StarSize * 0.866, centerY + StarSize * 0.5)

            StarObjects[2].PointA = Vector2.new(centerX, centerY + StarSize)
            StarObjects[2].PointB = Vector2.new(centerX - StarSize * 0.866, centerY - StarSize * 0.5)
            StarObjects[2].PointC = Vector2.new(centerX + StarSize * 0.866, centerY - StarSize * 0.5)

            StarObjects[3].Position = Vector2.new(centerX, centerY)
        end
    end)
end

local function StopDavidStar()
    DavidStarEnabled = false  -- Force flag off

    if CrosshairConnection then
        CrosshairConnection:Disconnect()
        CrosshairConnection = nil
    end

    -- Safe & complete cleanup
    for _, obj in pairs(StarObjects) do
        if obj and typeof(obj.Remove) == "function" then
            pcall(function() obj:Remove() end)
        end
    end
    table.clear(StarObjects)
end

-- ====================== UI ======================
CrosshairTab:CreateToggle({
    Name = "David Star Crosshair",
    CurrentValue = false,
    Callback = function(v)
        DavidStarEnabled = v
        if v then
            StartDavidStar()
        else
            StopDavidStar()
        end
    end
})

CrosshairTab:CreateSlider({
    Name = "Star Size",
    Range = {15, 60},
    Increment = 1,
    CurrentValue = 35,
    Callback = function(v)
        StarSize = v
        if DavidStarEnabled then
            CreateDavidStar()
        end
    end
})

CrosshairTab:CreateColorPicker({
    Name = "Star Color",
    Color = Color3.fromRGB(0, 255, 255),
    Callback = function(v)
        StarColor = v
        if DavidStarEnabled then
            CreateDavidStar()
        end
    end
})

CrosshairTab:CreateToggle({
    Name = "Hide In-Game GUI (Clean Screen)",
    CurrentValue = false,
    Callback = function(v)
        if v then
            for _, gui in ipairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and not gui.Name:find("Rayfield") then
                    gui.Enabled = false
                end
            end
        else
            for _, gui in ipairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    gui.Enabled = true
                end
            end
        end
    end
})

CrosshairTab:CreateButton({
    Name = "Force Refresh Crosshair",
    Callback = function()
        if DavidStarEnabled then
            StopDavidStar()
            task.wait(0.08)
            StartDavidStar()
        end
    end
})

print("✅ Crosshair Fully Fixed - Stable On/Off + Settings Change")

-- ====================== MISC TAB ======================

local Misc = Window:CreateTab("Misc", 4483362458)

-- Settings

local AntiAFKEnabled = false

local InfiniteJumpEnabled = false

local NoClipEnabled = false

local ClickTPEnabled = false

local FPSBoostEnabled = false

local AntiAFKConnection = nil

local NoClipConnection = nil

-- ====================== ANTI-AFK ======================

local function StartAntiAFK()

    if AntiAFKConnection then return end

    AntiAFKConnection = game:GetService("RunService").Heartbeat:Connect(function()

        if not AntiAFKEnabled then return end

        local vu = game:GetService("VirtualUser")

        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)

        task.wait(0.1)

        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)

    end)

end

local function StopAntiAFK()

    if AntiAFKConnection then

        AntiAFKConnection:Disconnect()

        AntiAFKConnection = nil

    end

end

-- ====================== NOCLIP ======================

local function StartNoClip()

    if NoClipConnection then return end

    NoClipConnection = game:GetService("RunService").Stepped:Connect(function()

        if not NoClipEnabled then return end

        local char = game.Players.LocalPlayer.Character

        if char then

            for _, part in pairs(char:GetDescendants()) do

                if part:IsA("BasePart") then

                    part.CanCollide = false

                end

            end

        end

    end)

end

local function StopNoClip()

    if NoClipConnection then

        NoClipConnection:Disconnect()

        NoClipConnection = nil

    end

    local char = game.Players.LocalPlayer.Character

    if char then

        for _, part in pairs(char:GetDescendants()) do

            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then

                part.CanCollide = true

            end

        end

    end

end

-- ====================== INFINITE JUMP ======================

game:GetService("UserInputService").JumpRequest:Connect(function()

    if InfiniteJumpEnabled then

        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end

    end

end)

-- ====================== CLICK TP ======================

game:GetService("UserInputService").InputBegan:Connect(function(input)

    if ClickTPEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then

        local mouse = game.Players.LocalPlayer:GetMouse()

        local char = game.Players.LocalPlayer.Character

        local root = char and char:FindFirstChild("HumanoidRootPart")

        if root and mouse.Hit then

            root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 4, 0))

        end

    end

end)

-- ====================== AUTO REJOIN (WITH SCRIPT LOAD) ======================

Misc:CreateButton({

    Name = "Rejoin Server (Auto Load Script)",

    Callback = function()

        local queue_on_teleport = syn and syn.queue_on_teleport or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

        

        if queue_on_teleport then

            queue_on_teleport([[

                loadstring(game:HttpGet("raw.githubusercontent.com/Neon-VR/flappycc/refs/heads/main/flappy.lua"))()

            ]])

        end

        

        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)

    end

})

-- ====================== UI ======================

Misc:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Callback = function(v) AntiAFKEnabled = v if v then StartAntiAFK() else StopAntiAFK() end end})

Misc:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) InfiniteJumpEnabled = v end})

Misc:CreateToggle({Name = "NoClip", CurrentValue = false, Callback = function(v) NoClipEnabled = v if v then StartNoClip() else StopNoClip() end end})

Misc:CreateToggle({Name = "Click TP (Ctrl + Right Click)", CurrentValue = false, Callback = function(v) ClickTPEnabled = v end})

Misc:CreateToggle({Name = "FPS Boost (Low Graphics)", CurrentValue = false, Callback = function(v) FPSBoostEnabled = v if v then settings().Rendering.QualityLevel = 1 game.Lighting.GlobalShadows = false game.Lighting.FogEnd = 999999 else settings().Rendering.QualityLevel = 5 game.Lighting.GlobalShadows = true end end})

Misc:CreateButton({Name = "Normal Rejoin (No Auto-Load)", Callback = function()

    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)

end})

Misc:CreateButton({Name = "Server Hop", Callback = function()

    game:GetService("TeleportService"):Teleport(game.PlaceId)

end})

Misc:CreateButton({Name = "Copy Game ID", Callback = function()

    setclipboard(tostring(game.PlaceId))

    print("📋 Game ID Copied!")

end})

Misc:CreateButton({Name = "Remove Fog", Callback = function()

    game.Lighting.FogEnd = 999999

    game.Lighting.FogStart = 999999

end})

Misc:CreateInput({Name = "Set Gravity", PlaceholderText = "196.2", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then workspace.Gravity = num end end})

Misc:CreateButton({Name = "Reset Gravity", Callback = function() workspace.Gravity = 196.2 end})

print("✅ Misc Tab Updated - Auto Rejoin Added!")

local Hub = Window:CreateTab("ScriptHub", 4483362458)

-- ================================
-- UNIVERSAL SCRIPTS (Work on ANY Game)
-- ================================
Hub:CreateSection("🌐 UNIVERSAL (Works on ANY Game)")

Hub:CreateButton({Name = "Infinite Yield (Admin Commands)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})

Hub:CreateButton({Name = "CMD-X Hub (300+ Games)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))() end})

Hub:CreateButton({Name = "Kitten Hub (280+ Games)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Kitten-Hub-280-Games-Best-Script-Hub-1000-Scripts-113464"))() end})

Hub:CreateButton({Name = "Universal Aimbot + ESP (Silent Aim)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Aimbot-and-ESP-73074"))() end})

Hub:CreateButton({Name = "Universal Keyless Advanced Aimbot + ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Keyless-Advanced-Aimbot-And-Esp-Gui-90617"))() end})

Hub:CreateButton({Name = "QUAIL Hub (60+ Features)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-QUAIL-Best-Universal-Aimbot-ESP-50-Features-144428"))() end})

Hub:CreateButton({Name = "Scripxx Universal Aimbot + ESP", Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/87WNRtmp"))() end})

Hub:CreateButton({Name = "Universal Silent Aim + No Spread", Callback = function() loadstring(game:HttpGet("https://ratex.sbs/scripts/aimbot.lua"))() end})

Hub:CreateButton({Name = "Core-X (Fly, Noclip, Aimbot, ESP)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Script-121662"))() end})

Hub:CreateButton({Name = "Universal Player ESP Optimized", Callback = function() loadstring(game:HttpGet("https://pastebin.com/87WNRtmp"))() end})


-- ================================
-- TROLLING / FE SCRIPTS
-- ================================
Hub:CreateSection("🤡 TROLLING (FE Scripts)")

Hub:CreateButton({Name = "FE DropKick V0.1", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/gsm231/Fe-DropKick/refs/heads/main/V0.1"))() end})

Hub:CreateButton({Name = "Veser VIP (Trolling Suite)", Callback = function() loadstring(game:HttpGet("https://veser.vip/"))() end})

Hub:CreateButton({Name = "Universal FE Fling", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-FE-Fling-Keyless-29997"))() end})

Hub:CreateButton({Name = "FE Crash Server", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Crash-Server-Keyless-29998"))() end})

Hub:CreateButton({Name = "FE Kick All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Kick-All-Keyless-29999"))() end})

Hub:CreateButton({Name = "FE Server Lag", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Server-Lag-Keyless-30000"))() end})

Hub:CreateButton({Name = "FE Freeze All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Freeze-All-Keyless-30005"))() end})

Hub:CreateButton({Name = "FE Bring All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Bring-All-Keyless-30007"))() end})

Hub:CreateButton({Name = "FE Spin All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Spin-All-Keyless-30008"))() end})

Hub:CreateButton({Name = "FE Ragdoll All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Ragdoll-All-Keyless-30009"))() end})


-- ================================
-- BROOKHAVEN RP
-- ================================
Hub:CreateSection("🏡 BROOKHAVEN RP")

Hub:CreateButton({Name = "Nytherune Hub (Top #1)", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Brookhaven-RP-Nytherune-Hub-43881"))() end})

Hub:CreateButton({Name = "Chaos Hub V1 (No Key)", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Brookhaven-RP-Chaos-Hub-V1-NO-KEY-28077"))() end})

Hub:CreateButton({Name = "Glazed Hub Keyless", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-Glazed-hub-keyless-29883"))() end})

Hub:CreateButton({Name = "R4D Keyless", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/M1ZZ001/BrookhavenR4D/main/Brookhaven%20R4D%20Script"))() end})

Hub:CreateButton({Name = "Brookhaven Admin Commands", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-Admin-Commands-Keyless-29884"))() end})

Hub:CreateButton({Name = "Brookhaven Troll Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-Troll-Hub-Keyless-29885"))() end})

Hub:CreateButton({Name = "Brookhaven OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-OP-GUI-Keyless-29886"))() end})

Hub:CreateButton({Name = "Brookhaven C4RT Kaiser", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GOaitsd/c4rt/refs/heads/main/.gitignore"))() end})

Hub:CreateButton({Name = "Brookhaven JoxHub V2", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GtGoj_v/Brookhaven/main/Script.lua"))() end})

Hub:CreateButton({Name = "Brookhaven Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})


-- ================================
-- DA HOOD
-- ================================
Hub:CreateSection("🔫 DA HOOD")

Hub:CreateButton({Name = "Destiny Script (No Group Needed)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/destiny-script-*NO-GROUP-NEEDED*_637"))() end})

Hub:CreateButton({Name = "Letal HVH (Win Every HvH)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-letal-win-every-hvh-dahood-121374"))() end})

Hub:CreateButton({Name = "Da Hood OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-OP-GUI-Keyless-29891"))() end})

Hub:CreateButton({Name = "Da Hood Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Silent-Aim-Keyless-29893"))() end})

Hub:CreateButton({Name = "Da Hood ESP + Aimbot", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-ESP-Aimbot-Keyless-29894"))() end})

Hub:CreateButton({Name = "Da Hood Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Godmode-Keyless-29896"))() end})

Hub:CreateButton({Name = "Da Hood Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Auto-Farm-Keyless-29897"))() end})

Hub:CreateButton({Name = "Da Hood Troll Scripts", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Troll-Scripts-Keyless-29898"))() end})

Hub:CreateButton({Name = "Da Hood Infinite Cash", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Infinite-Cash-Keyless-29895"))() end})

Hub:CreateButton({Name = "Da Hood Aim Trainer", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Aim-Trainer-Keyless-29892"))() end})


-- ================================
-- CALI SHOOTOUT
-- ================================
Hub:CreateSection("🔥 CALI SHOOTOUT")

Hub:CreateButton({Name = "DKHUB Autofarms", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/Loaders",true))() end})

Hub:CreateButton({Name = "Saytus Script OP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Cali-Shootout-The-Best-Script-149216"))() end})

Hub:CreateButton({Name = "Silent Night Hub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/30Ks-netizen/GARLIC/refs/heads/main/Loader"))() end})


-- ================================
-- THA BRONX 3
-- ================================
Hub:CreateSection("🐍 THA BRONX 3")

Hub:CreateButton({Name = "Inf Gem Script", Callback = function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/9043410149cda46ff7a52e2d8329d522.lua"))() end})

Hub:CreateButton({Name = "MUNCHY Script", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MUNCHY0728/ThaBronx3/main/Script.lua"))() end})

Hub:CreateButton({Name = "Wired Script", Callback = function() loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/aadc20666758ede078db6679bf62f68bbf3ed3aa61cda2cf5276c79e2a2d8001/download"))() end})


-- ================================
-- SHOTTAS OF MIAMI V2
-- ================================
Hub:CreateSection("🔥 SHOTTAS OF MIAMI V2")

Hub:CreateButton({Name = "Keyless Loader", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/30Ks-netizen/GARLIC/refs/heads/main/Loader"))() end})

Hub:CreateButton({Name = "Legacy Hub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Legacy/ShottasMiami/main/Script.lua"))() end})


-- ================================
-- RIVALS
-- ================================
Hub:CreateSection("⚔️ RIVALS")

Hub:CreateButton({Name = "Combat Universal PC + Mobile", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RivalsCombat/Universal/main/loader.lua"))() end})

Hub:CreateButton({Name = "Universal Aimbot V2", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/RIVALS-UNIVERSAL-AIMBOT-V2-199328"))() end})

Hub:CreateButton({Name = "OREO Loader V1", Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/hyHzCWBC"))() end})


-- ================================
-- PRISON LIFE / REDWOOD PRISON
-- ================================
Hub:CreateSection("🚔 PRISON LIFE")

Hub:CreateButton({Name = "darkXhub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/darkXhub/PrisonLife/main/Script.lua"))() end})

Hub:CreateButton({Name = "TarikHUB", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/DeNyima/TarikHUB/refs/heads/main/SquidGame'))() end})

Hub:CreateButton({Name = "Redwood Prison RDAScripting (New)", Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/CuA1wdpP"))() end})

Hub:CreateButton({Name = "Redwood Prison Bypassed.EZ", Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/CuA1wdpP"))() end})


-- ================================
-- ARSENAL / PHANTOM FORCES
-- ================================
Hub:CreateSection("🎯 ARSENAL")

Hub:CreateButton({Name = "Universal Aimbot + ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Aimbot-and-ESP-73074"))() end})

Hub:CreateButton({Name = "Owl Hub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomScriptsStuff/OwlHub/main/OwlHub.txt"))() end})

Hub:CreateButton({Name = "Arsenal Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-Silent-Aim-Keyless-29899"))() end})

Hub:CreateButton({Name = "Arsenal Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-Kill-All-Keyless-29903"))() end})

Hub:CreateButton({Name = "Phantom Forces CMD-X", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))() end})


-- ================================
-- MURDER MYSTERY 2
-- ================================
Hub:CreateSection("🔪 MURDER MYSTERY 2")

Hub:CreateButton({Name = "Peachy Hub 2026 (Auto Farm, ESP, Aimbot, Kill All, Teleports)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Murder-Mystery-2-Scripts-2026/main/MM2_Script_Hub_2026.lua"))() end})

Hub:CreateButton({Name = "Eclipse MM2 (Auto Farm Coins, Aimbot, Kill All, Teleports, GUI)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Doggo-cryto/EclipseMM2/master/Script", true))() end})

Hub:CreateButton({Name = "Rogue Hub (Get Revolver, ESP, Auto Kill All, TP to Killer/Sheriff)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Kitzoon/Rogue-Hub/main/Main.lua", true))() end})

Hub:CreateButton({Name = "Alchemy Hub (Xray + Kill All)", Callback = function() _G.UI_Theme = "White"; loadstring(game:HttpGet("https://luable.netlify.app/AlchemyHub/Luncher.script"))() end})

Hub:CreateButton({Name = "Kidachi Auto Farm (Coins & Candy Farm)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/KidichiHB/Kidachi/main/Scripts/MM2", true))() end})

Hub:CreateButton({Name = "Mars Hub MM2 (ESP, Aimbot, Auto Farm)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/1andonlymars/MarsHub/main/MM2"))() end})

Hub:CreateButton({Name = "Nexus MM2 Loader", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/s-0-a-b/nexus/main/loadstring"))() end})

Hub:CreateButton({Name = "zxclua MM2 Script", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/zxclua/m/main/script"))() end})

Hub:CreateButton({Name = "MM2 Silent Aim + Kill Aura (NEW - Uploaded 1 week ago)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Auto-Grab-Gun-and-Skinchanger-and-more-195477"))() end})

Hub:CreateButton({Name = "MM2 Auto Win (Sheriff, Innocent, Murderer) - Mobile/PC", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Drifter0507/GUIS/main/MURDER%20MYSTERY%202", true))() end})
-- ================================
-- BLADE BALL
-- ================================
Hub:CreateSection("⚔️ BLADE BALL")

Hub:CreateButton({Name = "Auto Parry", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Auto-Parry-Keyless-29967"))() end})

Hub:CreateButton({Name = "Blade Ball OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-OP-GUI-Keyless-29968"))() end})

Hub:CreateButton({Name = "Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Kill-All-Keyless-29970"))() end})

Hub:CreateButton({Name = "Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Auto-Win-Keyless-29972"))() end})


-- ================================
-- BEDWARS
-- ================================
Hub:CreateSection("🛡️ BEDWARS")

Hub:CreateButton({Name = "Universal BedWars Script", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-BedWars-112233"))() end})

Hub:CreateButton({Name = "Kill Aura", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Kill-Aura-Keyless-29909"))() end})

Hub:CreateButton({Name = "Auto Bridge", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Auto-Bridge-Keyless-29913"))() end})

Hub:CreateButton({Name = "BedWars OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-OP-GUI-Keyless-29914"))() end})


-- ================================
-- JAILBREAK
-- ================================
Hub:CreateSection("🚗 JAILBREAK")

Hub:CreateButton({Name = "Auto Rob", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Auto-Rob-Keyless-29927"))() end})

Hub:CreateButton({Name = "Jailbreak OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-OP-GUI-Keyless-29928"))() end})

Hub:CreateButton({Name = "Car Fly", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Car-Fly-Keyless-29935"))() end})

Hub:CreateButton({Name = "Jailbreak ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-ESP-Keyless-29930"))() end})


-- ================================
-- TOWER OF HELL
-- ================================
Hub:CreateSection("🗼 TOWER OF HELL")

Hub:CreateButton({Name = "Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Auto-Win-Keyless-29957"))() end})

Hub:CreateButton({Name = "Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Godmode-Keyless-29959"))() end})

Hub:CreateButton({Name = "Auto Climb", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Auto-Climb-Keyless-29965"))() end})

Hub:CreateButton({Name = "Tower of Hell ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-ESP-Keyless-29958"))() end})


-- ================================
-- NATURAL DISASTER SURVIVAL (UPDATED)
-- ================================
Hub:CreateSection("🌋 NATURAL DISASTER SURVIVAL")

Hub:CreateButton({Name = "MERCURY NDS GUI (26 Features, Anti-Disaster)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Natural-Disaster-Survival-MERCURY-NDS-GUI-KEYLESS-26-FEATURES-ANTIDISASTER-177686"))() end})

Hub:CreateButton({Name = "Farm Wins + Radar + Fly + No Clip", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Natural-Disaster-Survival-Farm-Wins-Radar-Fly-And-More-141617"))() end})

Hub:CreateButton({Name = "NDS Auto Farm, God Mode, Walkspeed, Teleport", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/73GG/Game-Scripts/main/Natural%20Disaster%20Survival.lua"))() end})

Hub:CreateButton({Name = "NDS Anti-Fall & Anti-Weather", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/pcallskeleton/RX/refs/heads/main/5.lua'))() end})

Hub:CreateButton({Name = "NDS No Fall Damage, Anti-Water & Check Map", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/H17S32/Tiger_Admin/main/MAIN'))() end})

Hub:CreateButton({Name = "NdsRing V2 (Physics Ring Control - Launch Players)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Natural-Disaster-Survival-NdsRing-V2-78974"))() end})

Hub:CreateButton({Name = "NDS Teleport to Spawn & Map", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/OneProtocol/Project/main/Loader", true))() end})

Hub:CreateButton({Name = "NDS Walkspeed & Gravity Control", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RobloxHackingProject/CHHub/main/CHHub.lua"))() end})

Hub:CreateButton({Name = "NDS Auto Clicker, Auto Farm & Auto Rebirth", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ToraIsMe/ToraIsMe/main/0GrimaceRace"))() end})

Hub:CreateButton({Name = "Partes Telekinesis (Move Map Parts)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Natural-Disaster-Survival-v20-partes-telekinesis-by-marie-138982"))() end})


-- ================================
-- FLOOD ESCAPE 2
-- ================================
Hub:CreateSection("🌊 FLOOD ESCAPE 2")

Hub:CreateButton({Name = "Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Auto-Win-55678"))() end})

Hub:CreateButton({Name = "FE2 OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-OP-GUI-Keyless-29987"))() end})

Hub:CreateButton({Name = "FE2 Auto Escape", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Auto-Escape-Keyless-29994"))() end})

Hub:CreateButton({Name = "FE2 ESP + Chams", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-ESP-Chams-Keyless-29995"))() end})

Rayfield:LoadConfiguration()
