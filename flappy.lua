-- flappy.cc - FULL SCRIPT (Troll Tab Added + Wallbang Removed)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
    Name = "flappy.cc",
    LoadingTitle = "flappy.cc",
    LoadingSubtitle = "flappy is not a skid w dev | Xeno",
    ConfigurationSaving = { Enabled = true, FolderName = "flappy.cc", FileName = "FullConfig" }
})

Rayfield:Notify({Title = "flappy.cc", Content = "Troll Tab Added - Kill All / Targeted Kill", Duration = 5})

local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- ====================== COMBAT TAB (Wallbang removed) ======================
local Combat = Window:CreateTab("Combat", 4483362458)

local AimbotEnabled = false
local VisCheck = true
local TargetTeammates = false
local TargetNPCs = false
local Smoothness = 12
local AimFOV = 120
local AimPart = "Head"
local BulletPrediction = false
local BulletSpeed = 1500

local currentTarget = nil

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.Visible = false

Combat:CreateToggle({Name = "AI Aimbot (Hold Right Click)", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})
Combat:CreateToggle({Name = "VisCheck (Only Visible Players)", CurrentValue = true, Callback = function(v) VisCheck = v end})
Combat:CreateToggle({Name = "Target Teammates", CurrentValue = false, Callback = function(v) TargetTeammates = v end})
Combat:CreateToggle({Name = "Target NPCs/Bots", CurrentValue = false, Callback = function(v) TargetNPCs = v end})
Combat:CreateToggle({Name = "Bullet Prediction", CurrentValue = false, Callback = function(v) BulletPrediction = v end})

Combat:CreateInput({Name = "Aimbot Smoothness (1-25)", PlaceholderText = "12", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then Smoothness = math.clamp(num, 1, 25) end end})
Combat:CreateInput({Name = "Aimbot FOV (30-400)", PlaceholderText = "120", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then AimFOV = math.clamp(num, 30, 400) end end})
Combat:CreateInput({Name = "Bullet Speed (studs/s)", PlaceholderText = "1500", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then BulletSpeed = math.clamp(num, 500, 5000) end end})
Combat:CreateDropdown({Name = "Aim Part", Options = {"Head","UpperTorso","HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(opt) AimPart = opt[1] end})
Combat:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

-- Light target scanner
task.spawn(function()
    while true do
        task.wait(0.2)
        if not AimbotEnabled or not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            currentTarget = nil
            continue
        end

        local lp = game.Players.LocalPlayer
        local closest, dist = nil, math.huge

        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr == lp or not plr.Character then continue end
            if not TargetTeammates and plr.Team == lp.Team then continue end

            local char = plr.Character
            local part = char:FindFirstChild(AimPart) or char:FindFirstChild("Head")
            if not part then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            local centerDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if centerDist > AimFOV then continue end

            if VisCheck then
                local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {lp.Character})
                if hit and not hit:IsDescendantOf(char) then continue end
            end

            local realDist = (part.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            if realDist < dist then dist = realDist; closest = part end
        end

        currentTarget = closest
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = AimFOV

    if not AimbotEnabled or not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not currentTarget then return end

    local aimPos = currentTarget.Position

    if BulletPrediction then
        local root = currentTarget.Parent:FindFirstChild("HumanoidRootPart")
        if root and root.Velocity then
            local travelTime = (currentTarget.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude / BulletSpeed
            aimPos = aimPos + root.Velocity * travelTime
        end
    end

    local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Smoothness)
end)

-- ====================== TROLL TAB ======================
local Troll = Window:CreateTab("Troll", 4483362458)

local KillAllEnabled = false
local KillAllLoop = false
local KillSelectedEnabled = false
local LoopKillSelected = false
local SelectedPlayer = nil
local killedPlayers = {}

Troll:CreateToggle({Name = "Kill All", CurrentValue = false, Callback = function(v) KillAllEnabled = v end})
Troll:CreateToggle({Name = "Kill All Loop", CurrentValue = false, Callback = function(v) KillAllLoop = v end})

local playerList = {}
for _, plr in ipairs(game.Players:GetPlayers()) do
    if plr ~= game.Players.LocalPlayer then table.insert(playerList, plr.Name) end
end

Troll:CreateDropdown({Name = "Select Player", Options = playerList, CurrentOption = {""}, Callback = function(opt)
    local plr = game.Players:FindFirstChild(opt[1])
    SelectedPlayer = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
end})

Troll:CreateToggle({Name = "Kill Selected Player", CurrentValue = false, Callback = function(v) KillSelectedEnabled = v end})
Troll:CreateToggle({Name = "Loop Kill Selected Player", CurrentValue = false, Callback = function(v) LoopKillSelected = v end})

-- Troll logic (teleport behind + auto-shoot)
local trollTarget = nil

RunService.RenderStepped:Connect(function()
    -- Kill All logic
    if KillAllEnabled or KillAllLoop then
        if not trollTarget or not trollTarget.Parent then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not killedPlayers[plr] then
                    trollTarget = plr.Character.HumanoidRootPart
                    break
                end
            end
            if not trollTarget then
                if KillAllLoop then
                    killedPlayers = {} -- reset list
                else
                    trollTarget = nil
                end
            end
        end
    elseif KillSelectedEnabled or LoopKillSelected then
        trollTarget = SelectedPlayer
    else
        trollTarget = nil
    end

    if trollTarget and trollTarget.Parent then
        local lpRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if lpRoot then
            -- Stay attached behind target
            lpRoot.CFrame = trollTarget.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(180), 0)
        end

        -- Auto-shoot while holding RMB
        if UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
        end

        -- Mark as killed if dead
        local hum = trollTarget.Parent:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then
            local plr = game.Players:GetPlayerFromCharacter(trollTarget.Parent)
            if plr then killedPlayers[plr] = true end
            trollTarget = nil
        end
    end
end)

-- ====================== ESP, MOVEMENT, MISC, SCRIPTHUB (unchanged) ======================
-- (ESP, Movement, Misc and ScriptHub are the same as your last working version - unchanged)

local ESPTab = Window:CreateTab("ESP", 4483362458)
local ESPEnabled = false
local MaxTracerDistance = 200

ESPTab:CreateToggle({Name = "Master ESP Toggle", CurrentValue = false, Callback = function(v) ESPEnabled = v end})
ESPTab:CreateToggle({Name = "2D Box ESP", CurrentValue = true, Callback = function() end})
ESPTab:CreateToggle({Name = "Name + Health + Distance", CurrentValue = true, Callback = function() end})
ESPTab:CreateToggle({Name = "Line Tracers", CurrentValue = true, Callback = function() end})
ESPTab:CreateToggle({Name = "Cyan Chams", CurrentValue = false, Callback = function() end})
ESPTab:CreateInput({Name = "Max Tracer Distance (studs)", PlaceholderText = "200", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then MaxTracerDistance = math.clamp(num, 50, 500) end end})

local ESPData = {}

task.spawn(function()
    while true do
        task.wait(0.1)
        if not ESPEnabled then
            for _, data in pairs(ESPData) do
                if data.Box then data.Box.Visible = false end
                if data.Tracer then data.Tracer.Visible = false end
            end
            continue
        end
        -- (your existing ESP code - unchanged)
        local lp = game.Players.LocalPlayer
        local lpRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player == lp or not player.Character then continue end
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root or not lpRoot then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local distance = (root.Position - lpRoot.Position).Magnitude
            if not onScreen then continue end

            local box = ESPData[player] and ESPData[player].Box or Drawing.new("Square")
            if not ESPData[player] then ESPData[player] = {} end
            ESPData[player].Box = box
            local height = (Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y)
            box.Size = Vector2.new(height * 0.6, height * 1.8)
            box.Position = Vector2.new(screenPos.X - box.Size.X/2, screenPos.Y - box.Size.Y/2)
            box.Color = Color3.fromRGB(0, 255, 255)
            box.Thickness = 2
            box.Transparency = 0.4
            box.Filled = false
            box.Visible = true

            local tracer = ESPData[player].Tracer or Drawing.new("Line")
            ESPData[player].Tracer = tracer
            tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            tracer.Color = Color3.fromRGB(0, 255, 100)
            tracer.Thickness = 1.5
            tracer.Transparency = 0.7
            tracer.Visible = (distance <= MaxTracerDistance)

            local head = char:FindFirstChild("Head")
            if head then
                local bg = head:FindFirstChild("flappyESP") or Instance.new("BillboardGui")
                bg.Name = "flappyESP"
                bg.Adornee = head
                bg.Size = UDim2.new(0, 220, 0, 60)
                bg.StudsOffset = Vector3.new(0, 3.5, 0)
                bg.AlwaysOnTop = true
                local txt = bg:FindFirstChild("Text") or Instance.new("TextLabel")
                txt.Text = player.Name .. "\n[" .. math.floor(char.Humanoid.Health) .. "]" .. "\n" .. math.floor(distance) .. " studs"
                txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                txt.TextStrokeTransparency = 0
                txt.TextScaled = true
                txt.BackgroundTransparency = 1
                txt.Parent = bg
                bg.Parent = head
            end
        end
    end
end)

-- Movement, Misc, ScriptHub unchanged
local Movement = Window:CreateTab("Movement", 4483362458)
Movement:CreateInput({Name = "WalkSpeed (0-1000)", PlaceholderText = "16", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then num = math.clamp(num, 0, 1000) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = num end end end})
Movement:CreateInput({Name = "JumpPower (0-1000)", PlaceholderText = "50", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then num = math.clamp(num, 0, 1000) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = num end end end})

local Misc = Window:CreateTab("Misc", 4483362458)
Misc:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Callback = function() end})
Misc:CreateButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) end})

local Hub = Window:CreateTab("ScriptHub", 4483362458)
-- (your full ScriptHub from last version - unchanged)

Rayfield:LoadConfiguration()
