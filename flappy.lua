-- flappy.cc - Full Script with Key System
local requiredKey = "flappy>othermenus"

-- Key System
local enteredKey = ""

local KeyWindow = Rayfield:CreateWindow({
    Name = "flappy.cc Key System",
    LoadingTitle = "flappy.cc",
    LoadingSubtitle = "Enter Key to Continue",
    ConfigurationSaving = { Enabled = false }
})

KeyWindow:CreateInput({
    Name = "Enter Key",
    PlaceholderText = "flappy>othermenus",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        enteredKey = text
    end
})

KeyWindow:CreateButton({
    Name = "Submit Key",
    Callback = function()
        if enteredKey == requiredKey then
            Rayfield:Notify({Title = "Key Accepted ✅", Content = "Loading full menu...", Duration = 3})
            task.wait(1)
            loadFullMenu()
        else
            Rayfield:Notify({Title = "Invalid Key", Content = "Please try again or get the key", Duration = 5})
        end
    end
})

KeyWindow:CreateButton({
    Name = "Get Key (Copy Discord Invite)",
    Callback = function()
        setclipboard("https://discord.gg/ekCQpygWrJ")
        Rayfield:Notify({Title = "Copied!", Content = "Discord invite copied to clipboard", Duration = 5})
    end
})

-- ==================== FULL MENU ====================
function loadFullMenu()
    local Window = Rayfield:CreateWindow({
        Name = "flappy.cc",
        LoadingTitle = "flappy.cc",
        LoadingSubtitle = "flappy is not a skid w dev | Xeno",
        ConfigurationSaving = { Enabled = true, FolderName = "flappy.cc", FileName = "FullConfig" }
    })

    Rayfield:Notify({Title = "flappy.cc", Content = "Full Menu Loaded", Duration = 5})

    local Camera = workspace.CurrentCamera
    local UserInput = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    -- Combat Tab
    local Combat = Window:CreateTab("Combat", 4483362458)

    local AimbotEnabled = false
    local WallbangEnabled = false
    local VisCheck = true
    local TargetTeammates = false
    local TargetNPCs = true
    local Smoothness = 12
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
    Combat:CreateToggle({Name = "VisCheck (Only Visible Players)", CurrentValue = true, Callback = function(v) VisCheck = v end})
    Combat:CreateToggle({Name = "Target Teammates", CurrentValue = false, Callback = function(v) TargetTeammates = v end})
    Combat:CreateToggle({Name = "Target NPCs/Bots", CurrentValue = true, Callback = function(v) TargetNPCs = v end})
    Combat:CreateSlider({Name = "Aimbot Smoothness", Range = {1, 25}, CurrentValue = 12, Callback = function(v) Smoothness = v end})
    Combat:CreateSlider({Name = "Aimbot FOV", Range = {30, 400}, CurrentValue = 120, Callback = function(v) AimFOV = v end})
    Combat:CreateDropdown({Name = "Aim Part", Options = {"Head","UpperTorso","HumanoidRootPart"}, CurrentOption = {"Head"}, Callback = function(opt) AimPart = opt[1] end})
    Combat:CreateToggle({Name = "Show FOV Circle", CurrentValue = false, Callback = function(v) FOVCircle.Visible = v end})

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

                if VisCheck then
                    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {lp.Character})
                    if hit and not hit:IsDescendantOf(model) then continue end
                end

                local realDist = (part.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if realDist < dist then dist = realDist; closest = part end
            end
        end

        if closest then
            local targetCF = CFrame.new(Camera.CFrame.Position, closest.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Smoothness)
        end
    end)

    -- ESP Tab
    local ESPTab = Window:CreateTab("ESP", 4483362458)

    local ESPEnabled = false

    ESPTab:CreateToggle({Name = "Master ESP Toggle", CurrentValue = false, Callback = function(v) ESPEnabled = v end})
    ESPTab:CreateToggle({Name = "2D Box ESP", CurrentValue = true, Callback = function() end})
    ESPTab:CreateToggle({Name = "Name + Health + Distance", CurrentValue = true, Callback = function() end})
    ESPTab:CreateToggle({Name = "Line Tracers", CurrentValue = true, Callback = function() end})
    ESPTab:CreateToggle({Name = "Cyan Chams", CurrentValue = false, Callback = function() end})

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
            tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            tracer.To = Vector2.new(screenPos.X, screenPos.Y)
            tracer.Color = Color3.fromRGB(0, 255, 100)
            tracer.Thickness = 2
            tracer.Transparency = 0.65
            tracer.Visible = true

            local head = char:FindFirstChild("Head")
            if head then
                local distance = math.floor((root.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                local bg = head:FindFirstChild("flappyESP") or Instance.new("BillboardGui")
                bg.Name = "flappyESP"
                bg.Adornee = head
                bg.Size = UDim2.new(0, 220, 0, 60)
                bg.StudsOffset = Vector3.new(0, 3.5, 0)
                bg.AlwaysOnTop = true
                local txt = bg:FindFirstChild("Text") or Instance.new("TextLabel")
                txt.Text = player.Name .. "\n[" .. math.floor(char.Humanoid.Health) .. "]" .. "\n" .. distance .. " studs"
                txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                txt.TextStrokeTransparency = 0
                txt.TextScaled = true
                txt.BackgroundTransparency = 1
                txt.Parent = bg
                bg.Parent = head
            end
        end
    end)

    -- Movement Tab
    local Movement = Window:CreateTab("Movement", 4483362458)
    Movement:CreateInput({Name = "WalkSpeed (0-1000)", PlaceholderText = "16", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then num = math.clamp(num, 0, 1000) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = num end end end})
    Movement:CreateInput({Name = "JumpPower (0-1000)", PlaceholderText = "50", RemoveTextAfterFocusLost = false, Callback = function(text) local num = tonumber(text) if num then num = math.clamp(num, 0, 1000) local char = game.Players.LocalPlayer.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = num end end end})

    -- Misc Tab
    local Misc = Window:CreateTab("Misc", 4483362458)
    Misc:CreateToggle({Name = "Anti-AFK", CurrentValue = false, Callback = function() end})
    Misc:CreateButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) end})

    -- ScriptHub Tab
    local Hub = Window:CreateTab("ScriptHub", 4483362458)

    Hub:CreateSection("🎯 UNIVERSAL AIMBOT + ESP")
    Hub:CreateButton({Name = "Universal Aimbot and ESP", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/zysws/scripts/main/universal-aimbot.luau", true))() end})
    Hub:CreateButton({Name = "Universal Aimbot and ESP (Xeno)", Callback = function() loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/eaf72bf15eb43f22a91f6e5978b1df2519f2174e2472ce03947763ce4b177c92/download", true))() end})
    Hub:CreateButton({Name = "Universal Aimbot + ESP (Silent + NoSpread)", Callback = function() loadstring(game:HttpGet("https://ratex.sbs/scripts/aimbot.lua", true))() end})

    Hub:CreateSection("⚔️ RIVALS")
    Hub:CreateButton({Name = "RIVALS Combat Universal", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/RivalsCombat/Universal/main/loader.lua", true))() end})
    Hub:CreateButton({Name = "RIVALS Combat V2", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/RIVALS-UNIVERSAL-AIMBOT-V2-199328", true))() end})

    Hub:CreateSection("🔫 CALI SHOOTOUT")
    Hub:CreateButton({Name = "Cali Shootout DKHUB", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/Loaders",true))() end})
    Hub:CreateButton({Name = "Cali Shootout Saytus OP", Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/Cali-Shootout-The-Best-Script-149216", true))() end})
    Hub:CreateButton({Name = "Cali Shootout Silent Night", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/30Ks-netizen/GARLIC/refs/heads/main/Loader", true))() end})

    Hub:CreateSection("🐍 THA BRONX 3")
    Hub:CreateButton({Name = "Tha Bronx 3 Inf Gem", Callback = function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/9043410149cda46ff7a52e2d8329d522.lua", true))() end})
    Hub:CreateButton({Name = "Tha Bronx 3 MUNCHY", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/MUNCHY0728/ThaBronx3/main/Script.lua", true))() end})

    Hub:CreateSection("🔥 SHOTTAS OF MIAMI")
    Hub:CreateButton({Name = "Shottas of Miami V2", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/30Ks-netizen/GARLIC/refs/heads/main/Loader", true))() end})

    Hub:CreateSection("🏡 BROOKHAVEN / PRISON")
    Hub:CreateButton({Name = "Brookhaven JoxHub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/GtGoj_v/Brookhaven/main/Script.lua", true))() end})
    Hub:CreateButton({Name = "Prison Life darkXhub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/darkXhub/PrisonLife/main/Script.lua", true))() end})
    Hub:CreateButton({Name = "Redwood Prison", Callback = function() loadstring(game:HttpGet("https://pastebin.com/raw/CuA1wdpP", true))() end})

    Hub:CreateSection("🤡 TROLLING / ADMIN")
    Hub:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true))() end})
    Hub:CreateButton({Name = "CMD-X Hub", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", true))() end})

    Rayfield:LoadConfiguration()
end
