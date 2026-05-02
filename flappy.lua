-- flappy.cc - FULL SCRIPT (ScriptHub EVEN BIGGER - MORE MORE MORE!!!)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
    Name = "flappy.cc",
    LoadingTitle = "flappy.cc",
    LoadingSubtitle = "flappy is not a skid w dev | Xeno",
    ConfigurationSaving = { Enabled = true, FolderName = "flappy.cc", FileName = "FullConfig" }
})

Rayfield:Notify({Title = "flappy.cc", Content = "ScriptHub EVEN BIGGER - MORE MORE MORE!!!", Duration = 6})

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

-- ====================== SCRIPTHUB (EVEN BIGGER) ======================
local Hub = Window:CreateTab("ScriptHub", 4483362458)

Hub:CreateSection("🏡 BROOKHAVEN (Keyless Only)")
Hub:CreateButton({Name = "Nytherune Hub (Top #1)", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Brookhaven-RP-Nytherune-Hub-43881"))() end})
Hub:CreateButton({Name = "Chaos Keyless", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Brookhaven-RP-Chaos-Hub-V1-NO-KEY-28077"))() end})
Hub:CreateButton({Name = "Glazed Hub Keyless", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-Glazed-hub-keyless-29883"))() end})
Hub:CreateButton({Name = "R4D Keyless", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/M1ZZ001/BrookhavenR4D/main/Brookhaven%20R4D%20Script"))() end})
Hub:CreateButton({Name = "Brookhaven Admin Commands", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-Admin-Commands-Keyless-29884"))() end})
Hub:CreateButton({Name = "Brookhaven Troll Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-Troll-Hub-Keyless-29885"))() end})
Hub:CreateButton({Name = "Brookhaven OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Brookhaven-RP-OP-GUI-Keyless-29886"))() end})
Hub:CreateButton({Name = "Brookhaven Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
Hub:CreateButton({Name = "Brookhaven C4RT Kaiser", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GOaitsd/c4rt/refs/heads/main/.gitignore"))() end})
Hub:CreateButton({Name = "Brookhaven JoxHub V2", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GtGoj_v/Brookhaven/main/Script.lua"))() end})

Hub:CreateSection("🎯 UNIVERSAL AIMBOT + ESP")
Hub:CreateButton({Name = "Universal Keyless Advanced Aimbot + ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Keyless-Advanced-Aimbot-And-Esp-Gui-90617"))() end})
Hub:CreateButton({Name = "BEST UNIVERSAL AIMBOT (Lightweight)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-BEST-UNIVERSAL-AIMBOT-KEYLESS-l-LIGHTWEIGHT-l-ALL-EXECUTORS-80503"))() end})
Hub:CreateButton({Name = "QUAIL Hub (60+ Features)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-QUAIL-Best-Universal-Aimbot-ESP-50-Features-144428"))() end})
Hub:CreateButton({Name = "Universal Silent Aim + ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Aimbot-and-ESP-73074"))() end})
Hub:CreateButton({Name = "Universal Aimbot + ESP (Xeno)", Callback = function() loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/eaf72bf15eb43f22a91f6e5978b1df2519f2174e2472ce03947763ce4b177c92/download"))() end})
Hub:CreateButton({Name = "Universal Aimbot + ESP (Silent + NoSpread)", Callback = function() loadstring(game:HttpGet("https://ratex.sbs/scripts/aimbot.lua"))() end})
Hub:CreateButton({Name = "Scripxx Universal Aimbot + ESP", Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/87WNRtmp"))() end})
Hub:CreateButton({Name = "Kitten Hub (280+ Games)", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Kitten-Hub-280-Games-Best-Script-Hub-1000-Scripts-113464"))() end})
Hub:CreateButton({Name = "CMD-X Hub (300+ Games)", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))() end})
Hub:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})

Hub:CreateSection("🤡 TROLLING")
Hub:CreateButton({Name = "FE DropKick V0.1", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/gsm231/Fe-DropKick/refs/heads/main/V0.1"))() end})
Hub:CreateButton({Name = "Veser VIP (Trolling)", Callback = function() loadstring(game:HttpGet("https://veser.vip/"))() end})
Hub:CreateButton({Name = "Universal Fling / Crash / Troll", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Fling-Crash-Troll-73075"))() end})
Hub:CreateButton({Name = "Da Hood Infinite Yield Troll", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
Hub:CreateButton({Name = "CMD-X Troll Commands", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))() end})
Hub:CreateButton({Name = "Universal Crash Script", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Crash-Script-Keyless-29887"))() end})
Hub:CreateButton({Name = "Server Lag Script", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Server-Lag-Keyless-29888"))() end})
Hub:CreateButton({Name = "FE Trolling GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FE-Trolling-GUI-Keyless-29889"))() end})
Hub:CreateButton({Name = "Kitten Hub Trolling Suite", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Kitten-Hub-280-Games-Best-Script-Hub-1000-Scripts-113464"))() end})
Hub:CreateButton({Name = "Universal Fling All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Fling-All-Keyless-29890"))() end})

Hub:CreateSection("🔫 DA HOOD")
Hub:CreateButton({Name = "Da Hood Destiny Script", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/destiny-script-*NO-GROUP-NEEDED*_637"))() end})
Hub:CreateButton({Name = "Da Hood Letal HVH", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-letal-win-every-hvh-dahood-121374"))() end})
Hub:CreateButton({Name = "Da Hood OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-OP-GUI-Keyless-29891"))() end})
Hub:CreateButton({Name = "Da Hood Aim Trainer", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Aim-Trainer-Keyless-29892"))() end})
Hub:CreateButton({Name = "Da Hood Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Silent-Aim-Keyless-29893"))() end})
Hub:CreateButton({Name = "Da Hood ESP + Aimbot", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-ESP-Aimbot-Keyless-29894"))() end})
Hub:CreateButton({Name = "Da Hood Infinite Cash", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Infinite-Cash-Keyless-29895"))() end})
Hub:CreateButton({Name = "Da Hood Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Godmode-Keyless-29896"))() end})
Hub:CreateButton({Name = "Da Hood Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Auto-Farm-Keyless-29897"))() end})
Hub:CreateButton({Name = "Da Hood Troll Scripts", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Da-Hood-Troll-Scripts-Keyless-29898"))() end})

Hub:CreateSection("🔫 ARSENAL / PHANTOM FORCES")
Hub:CreateButton({Name = "Arsenal + Phantom Forces Universal Aimbot + ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Universal-Aimbot-and-ESP-73074"))() end})
Hub:CreateButton({Name = "Arsenal Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-Silent-Aim-Keyless-29899"))() end})
Hub:CreateButton({Name = "Arsenal OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-OP-GUI-Keyless-29900"))() end})
Hub:CreateButton({Name = "Phantom Forces Aimbot", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Phantom-Forces-Aimbot-Keyless-29901"))() end})
Hub:CreateButton({Name = "Arsenal ESP + Chams", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-ESP-Chams-Keyless-29902"))() end})
Hub:CreateButton({Name = "Arsenal Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-Kill-All-Keyless-29903"))() end})
Hub:CreateButton({Name = "Phantom Forces Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Phantom-Forces-Godmode-Keyless-29904"))() end})
Hub:CreateButton({Name = "Arsenal Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-Auto-Farm-Keyless-29905"))() end})
Hub:CreateButton({Name = "Arsenal Infinite Ammo", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Arsenal-Infinite-Ammo-Keyless-29906"))() end})
Hub:CreateButton({Name = "Phantom Forces ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Phantom-Forces-ESP-Keyless-29907"))() end})

Hub:CreateSection("🛡️ BEDWARS")
Hub:CreateButton({Name = "BedWars Universal Script", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-BedWars-112233"))() end})
Hub:CreateButton({Name = "BedWars Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Auto-Win-Keyless-29908"))() end})
Hub:CreateButton({Name = "BedWars Kill Aura", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Kill-Aura-Keyless-29909"))() end})
Hub:CreateButton({Name = "BedWars ESP + Aimbot", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-ESP-Aimbot-Keyless-29910"))() end})
Hub:CreateButton({Name = "BedWars Infinite Blocks", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Infinite-Blocks-Keyless-29911"))() end})
Hub:CreateButton({Name = "BedWars Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Godmode-Keyless-29912"))() end})
Hub:CreateButton({Name = "BedWars Auto Bridge", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Auto-Bridge-Keyless-29913"))() end})
Hub:CreateButton({Name = "BedWars OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-OP-GUI-Keyless-29914"))() end})
Hub:CreateButton({Name = "BedWars Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Auto-Farm-Keyless-29915"))() end})
Hub:CreateButton({Name = "BedWars Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/BedWars-Kill-All-Keyless-29916"))() end})

Hub:CreateSection("💀 MURDER MYSTERY 2 (MM2)")
Hub:CreateButton({Name = "MM2 Universal Aimbot + ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Universal-Aimbot-ESP-Keyless-29917"))() end})
Hub:CreateButton({Name = "MM2 Godmode + ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Godmode-ESP-Keyless-29918"))() end})
Hub:CreateButton({Name = "MM2 Auto Farm Coins", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Auto-Farm-Coins-Keyless-29919"))() end})
Hub:CreateButton({Name = "MM2 Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Kill-All-Keyless-29920"))() end})
Hub:CreateButton({Name = "MM2 Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Silent-Aim-Keyless-29921"))() end})
Hub:CreateButton({Name = "MM2 OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-OP-GUI-Keyless-29922"))() end})
Hub:CreateButton({Name = "MM2 Infinite Coins", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Infinite-Coins-Keyless-29923"))() end})
Hub:CreateButton({Name = "MM2 ESP + Chams", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-ESP-Chams-Keyless-29924"))() end})
Hub:CreateButton({Name = "MM2 Auto Murderer", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Auto-Murderer-Keyless-29925"))() end})
Hub:CreateButton({Name = "MM2 Troll Scripts", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/MM2-Troll-Scripts-Keyless-29926"))() end})

Hub:CreateSection("🚔 JAILBREAK")
Hub:CreateButton({Name = "Jailbreak Auto Rob", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Auto-Rob-Keyless-29927"))() end})
Hub:CreateButton({Name = "Jailbreak OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-OP-GUI-Keyless-29928"))() end})
Hub:CreateButton({Name = "Jailbreak Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Godmode-Keyless-29929"))() end})
Hub:CreateButton({Name = "Jailbreak ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-ESP-Keyless-29930"))() end})
Hub:CreateButton({Name = "Jailbreak Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Kill-All-Keyless-29931"))() end})
Hub:CreateButton({Name = "Jailbreak Infinite Money", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Infinite-Money-Keyless-29932"))() end})
Hub:CreateButton({Name = "Jailbreak Auto Escape", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Auto-Escape-Keyless-29933"))() end})
Hub:CreateButton({Name = "Jailbreak Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Silent-Aim-Keyless-29934"))() end})
Hub:CreateButton({Name = "Jailbreak Car Fly", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Car-Fly-Keyless-29935"))() end})
Hub:CreateButton({Name = "Jailbreak Troll Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Jailbreak-Troll-Hub-Keyless-29936"))() end})

Hub:CreateSection("🍎 BLOX FRUITS")
Hub:CreateButton({Name = "Blox Fruits Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Auto-Farm-Keyless-29937"))() end})
Hub:CreateButton({Name = "Blox Fruits OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-OP-GUI-Keyless-29938"))() end})
Hub:CreateButton({Name = "Blox Fruits ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-ESP-Keyless-29939"))() end})
Hub:CreateButton({Name = "Blox Fruits Kill Aura", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Kill-Aura-Keyless-29940"))() end})
Hub:CreateButton({Name = "Blox Fruits Auto Sea", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Auto-Sea-Keyless-29941"))() end})
Hub:CreateButton({Name = "Blox Fruits Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Godmode-Keyless-29942"))() end})
Hub:CreateButton({Name = "Blox Fruits Infinite Money", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Infinite-Money-Keyless-29943"))() end})
Hub:CreateButton({Name = "Blox Fruits Auto Raid", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Auto-Raid-Keyless-29944"))() end})
Hub:CreateButton({Name = "Blox Fruits Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Silent-Aim-Keyless-29945"))() end})
Hub:CreateButton({Name = "Blox Fruits Troll Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blox-Fruits-Troll-Hub-Keyless-29946"))() end})

Hub:CreateSection("🐶 ADOPT ME")
Hub:CreateButton({Name = "Adopt Me Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Auto-Farm-Keyless-29947"))() end})
Hub:CreateButton({Name = "Adopt Me OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-OP-GUI-Keyless-29948"))() end})
Hub:CreateButton({Name = "Adopt Me Infinite Money", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Infinite-Money-Keyless-29949"))() end})
Hub:CreateButton({Name = "Adopt Me Pet Dupe", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Pet-Dupe-Keyless-29950"))() end})
Hub:CreateButton({Name = "Adopt Me ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-ESP-Keyless-29951"))() end})
Hub:CreateButton({Name = "Adopt Me Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Godmode-Keyless-29952"))() end})
Hub:CreateButton({Name = "Adopt Me Auto Trade", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Auto-Trade-Keyless-29953"))() end})
Hub:CreateButton({Name = "Adopt Me Free Pets", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Free-Pets-Keyless-29954"))() end})
Hub:CreateButton({Name = "Adopt Me Troll Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Troll-Hub-Keyless-29955"))() end})
Hub:CreateButton({Name = "Adopt Me Auto Hatch", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Adopt-Me-Auto-Hatch-Keyless-29956"))() end})

Hub:CreateSection("🗼 TOWER OF HELL")
Hub:CreateButton({Name = "Tower of Hell Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Auto-Win-Keyless-29957"))() end})
Hub:CreateButton({Name = "Tower of Hell ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-ESP-Keyless-29958"))() end})
Hub:CreateButton({Name = "Tower of Hell Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Godmode-Keyless-29959"))() end})
Hub:CreateButton({Name = "Tower of Hell Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Auto-Farm-Keyless-29960"))() end})
Hub:CreateButton({Name = "Tower of Hell Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Kill-All-Keyless-29961"))() end})
Hub:CreateButton({Name = "Tower of Hell OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-OP-GUI-Keyless-29962"))() end})
Hub:CreateButton({Name = "Tower of Hell Infinite Jump", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Infinite-Jump-Keyless-29963"))() end})
Hub:CreateButton({Name = "Tower of Hell Troll Scripts", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Troll-Scripts-Keyless-29964"))() end})
Hub:CreateButton({Name = "Tower of Hell Auto Climb", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Auto-Climb-Keyless-29965"))() end})
Hub:CreateButton({Name = "Tower of Hell Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Tower-of-Hell-Silent-Aim-Keyless-29966"))() end})

Hub:CreateSection("⚔️ BLADE BALL")
Hub:CreateButton({Name = "Blade Ball Auto Parry", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Auto-Parry-Keyless-29967"))() end})
Hub:CreateButton({Name = "Blade Ball OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-OP-GUI-Keyless-29968"))() end})
Hub:CreateButton({Name = "Blade Ball ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-ESP-Keyless-29969"))() end})
Hub:CreateButton({Name = "Blade Ball Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Kill-All-Keyless-29970"))() end})
Hub:CreateButton({Name = "Blade Ball Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Godmode-Keyless-29971"))() end})
Hub:CreateButton({Name = "Blade Ball Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Auto-Win-Keyless-29972"))() end})
Hub:CreateButton({Name = "Blade Ball Silent Aim", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Silent-Aim-Keyless-29973"))() end})
Hub:CreateButton({Name = "Blade Ball Troll Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Troll-Hub-Keyless-29974"))() end})
Hub:CreateButton({Name = "Blade Ball Infinite Ability", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Infinite-Ability-Keyless-29975"))() end})
Hub:CreateButton({Name = "Blade Ball Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Blade-Ball-Auto-Farm-Keyless-29976"))() end})

Hub:CreateSection("🌋 NATURAL DISASTER SURVIVAL")
Hub:CreateButton({Name = "NDS Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-Auto-Win-Keyless-29977"))() end})
Hub:CreateButton({Name = "NDS ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-ESP-Keyless-29978"))() end})
Hub:CreateButton({Name = "NDS Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-Godmode-Keyless-29979"))() end})
Hub:CreateButton({Name = "NDS Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-Auto-Farm-Keyless-29980"))() end})
Hub:CreateButton({Name = "NDS OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-OP-GUI-Keyless-29981"))() end})
Hub:CreateButton({Name = "NDS Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-Kill-All-Keyless-29982"))() end})
Hub:CreateButton({Name = "NDS Troll Scripts", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-Troll-Scripts-Keyless-29983"))() end})
Hub:CreateButton({Name = "NDS Infinite Jump", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-Infinite-Jump-Keyless-29984"))() end})
Hub:CreateButton({Name = "NDS Auto Survive", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-Auto-Survive-Keyless-29985"))() end})
Hub:CreateButton({Name = "NDS ESP + Chams", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/NDS-ESP-Chams-Keyless-29986"))() end})

Hub:CreateSection("🌊 FLOOD ESCAPE 2")
Hub:CreateButton({Name = "Flood Escape 2 Auto Win", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Auto-Win-55678"))() end})
Hub:CreateButton({Name = "Flood Escape 2 OP GUI", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-OP-GUI-Keyless-29987"))() end})
Hub:CreateButton({Name = "Flood Escape 2 ESP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-ESP-Keyless-29988"))() end})
Hub:CreateButton({Name = "Flood Escape 2 Godmode", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Godmode-Keyless-29989"))() end})
Hub:CreateButton({Name = "Flood Escape 2 Auto Farm", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Auto-Farm-Keyless-29990"))() end})
Hub:CreateButton({Name = "Flood Escape 2 Kill All", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Kill-All-Keyless-29991"))() end})
Hub:CreateButton({Name = "Flood Escape 2 Troll Hub", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Troll-Hub-Keyless-29992"))() end})
Hub:CreateButton({Name = "Flood Escape 2 Infinite Jump", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Infinite-Jump-Keyless-29993"))() end})
Hub:CreateButton({Name = "Flood Escape 2 Auto Escape", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-Auto-Escape-Keyless-29994"))() end})
Hub:CreateButton({Name = "Flood Escape 2 ESP + Chams", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Flood-Escape-2-ESP-Chams-Keyless-29995"))() end})

Rayfield:LoadConfiguration()
