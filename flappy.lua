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

local trollTarget = nil

RunService.RenderStepped:Connect(function()
    if KillAllEnabled or KillAllLoop then
        if not trollTarget or not trollTarget.Parent then
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not killedPlayers[plr] then
                    trollTarget = plr.Character.HumanoidRootPart
                    break
                end
            end
            if not trollTarget then
                if KillAllLoop then killedPlayers = {} else trollTarget = nil end
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
            lpRoot.CFrame = trollTarget.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(180), 0)
        end

        if UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
            task.wait(0.05)
            VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
        end

        local hum = trollTarget.Parent:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then
            local plr = game.Players:GetPlayerFromCharacter(trollTarget.Parent)
            if plr then killedPlayers[plr] = true end
            trollTarget = nil
        end
    end
end)

-- ====================== ESP TAB ======================
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

-- ====================== MOVEMENT ======================
local Movement = Window:CreateTab("Movement", 4483362458)
Movement:CreateInput({Name = "WalkSpeed (0-1000)", PlaceholderText = "16", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then num = math.clamp(num, 0, 1000) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = num end end end})
Movement:CreateInput({Name = "JumpPower (0-1000)", PlaceholderText = "50", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then num = math.clamp(num, 0, 1000) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = num end end end})

-- ====================== MISC ======================
local Misc = Window:CreateTab("Misc", 4483362458)
Misc:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Callback = function() end})
Misc:CreateButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) end})

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
