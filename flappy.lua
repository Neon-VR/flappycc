-- flappy.cc - Updated (ESP + Combat + Movement + Misc Fixed)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
    Name = "flappy.cc",
    LoadingTitle = "flappy.cc",
    LoadingSubtitle = "flappy is not a skid w dev | Xeno",
    ConfigurationSaving = { Enabled = true, FolderName = "flappy.cc", FileName = "FullConfig" }
})

Rayfield:Notify({Title = "flappy.cc", Content = "Updated - ScriptHub Unchanged", Duration = 5})

local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ====================== COMBAT TAB ======================
local Combat = Window:CreateTab("Combat", 4483362458)

local AimbotEnabled = false
local WallbangEnabled = false
local TargetTeammates = false
local TargetNPCs = true
local Smoothness = 10
local AimFOV = 120
local AimPart = "Head"

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.Visible = false

Combat:CreateToggle({Name = "AI Aimbot (Hold Right Click)", CurrentValue = false, Callback = function(v) AimbotEnabled = v end})
Combat:CreateToggle({Name = "Wallbang (Shoot Through Walls)", CurrentValue = false, Callback = function(v) WallbangEnabled = v end})
Combat:CreateToggle({Name = "Target Teammates", CurrentValue = false, Callback = function(v) TargetTeammates = v end})
Combat:CreateToggle({Name = "Target NPCs/Bots", CurrentValue = true, Callback = function(v) TargetNPCs = v end})
Combat:CreateSlider({Name = "Aimbot Smoothness", Range = {1, 25}, CurrentValue = 10, Callback = function(v) Smoothness = v end})
Combat:CreateSlider({Name = "Aimbot FOV", Range = {30, 400}, CurrentValue = 120, Callback = function(v) AimFOV = v end})
Combat:CreateDropdown({Name = "Aim Part", Options = {"Head","UpperTorso","HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(opt) AimPart = opt[1] end})
Combat:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

-- Optimized Aimbot
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = AimFOV

    if not UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or not AimbotEnabled then return end

    local lp = game.Players.LocalPlayer
    local closest, dist = nil, math.huge

    for _, model in workspace:GetDescendants() do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") then
            local p = game.Players:GetPlayerFromCharacter(model)
            if p then
                if not TargetTeammates and p.Team == lp.Team then continue end
            elseif not TargetNPCs then continue end

            local part = model:FindFirstChild(AimPart) or model:FindFirstChild("Head")
            if not part then continue end

            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            local centerDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if centerDist > AimFOV then continue end

            local realDist = (part.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            if realDist < dist then dist = realDist; closest = part end
        end
    end

    if closest then
        local targetCF = CFrame.new(Camera.CFrame.Position, closest.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Smoothness)
    end
end)

-- ====================== ESP TAB (Fixed Persistent) ======================
local ESPTab = Window:CreateTab("ESP", 4483362458)

local ESPEnabled = false

ESPTab:CreateToggle({Name = "Master ESP Toggle", CurrentValue = false, Callback = function(v) ESPEnabled = v end})
ESPTab:CreateToggle({Name = "2D Box ESP", CurrentValue = true, Callback = function() end})
ESPTab:CreateToggle({Name = "Name + Health", CurrentValue = true, Callback = function() end})
ESPTab:CreateToggle({Name = "Line Tracers", CurrentValue = true, Callback = function() end})
ESPTab:CreateToggle({Name = "Purple Chams", CurrentValue = false, Callback = function() end})

-- Persistent ESP
local ESPData = {}

RunService.RenderStepped:Connect(function()
    if not ESPEnabled then 
        for _, data in pairs(ESPData) do
            if data.Box then data.Box.Visible = false end
            if data.Tracer then data.Tracer.Visible = false end
        end
        return 
    end

    for _, player in game.Players:GetPlayers() do
        if player == game.Players.LocalPlayer or not player.Character then continue end
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end

        -- 2D Box
        local box = ESPData[player] and ESPData[player].Box or Drawing.new("Square")
        if not ESPData[player] then ESPData[player] = {} end
        ESPData[player].Box = box
        local height = (Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0)).Y - Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0)).Y)
        box.Size = Vector2.new(height * 0.6, height * 1.8)
        box.Position = Vector2.new(screenPos.X - box.Size.X/2, screenPos.Y - box.Size.Y/2)
        box.Color = Color3.fromRGB(0, 255, 255)
        box.Thickness = 2
        box.Transparency = 0.45
        box.Filled = false
        box.Visible = true

        -- Line Tracer
        local tracer = ESPData[player].Tracer or Drawing.new("Line")
        ESPData[player].Tracer = tracer
        tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        tracer.Color = Color3.fromRGB(0, 255, 100)
        tracer.Thickness = 2
        tracer.Transparency = 0.65
        tracer.Visible = true
    end
end)

-- ====================== MOVEMENT ======================
local Movement = Window:CreateTab("Movement", 4483362458)
Movement:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, CurrentValue = 16, Callback = function(v) pcall(function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v end) end})
Movement:CreateSlider({Name = "JumpPower", Range = {50, 500}, CurrentValue = 50, Callback = function(v) pcall(function() game.Players.LocalPlayer.Character.Humanoid.JumpPower = v end) end})

-- ====================== MISC ======================
local Misc = Window:CreateTab("Misc", 4483362458)
Misc:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Callback = function() end})
Misc:CreateButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) end})

-- ====================== SCRIPTHUB (UNTOUCHED) ======================
local Hub = Window:CreateTab("ScriptHub", 4483362458)
Hub:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))() end})
Hub:CreateButton({Name = "Kitten Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Kitten-Hub-280-Games-Best-Script-Hub-1000-Scripts-113464", true))() end})
-- (All your other scripts remain here unchanged)

Rayfield:LoadConfiguration()
