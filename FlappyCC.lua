-- flappy.cc Key System
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nfpw/Simple-KeySystem-Roblox/refs/heads/main/Library.lua"))()

local KeyWindow = Library:CreateWindow("Key System", UDim2.fromOffset(300, 180))

local KeyBox = KeyWindow:AddTextBox("Enter Key...", UDim2.new(0.1, 0, 0.15, 0))
local RememberToggle = KeyWindow:AddToggle("Remember Key", UDim2.new(0.1, 0, 0.36, 0), false)

local KeyPath = "DisabledHubConfigs/Key"
local FileName = "SavedKey.lua"
local SavedKey = Library:LoadKey(KeyPath, FileName)
if SavedKey then
    KeyBox.Text = SavedKey
    RememberToggle.SetState(true)
end

KeyWindow:AddButton("Submit", UDim2.new(0.1, 0, 0.65, 0), function()
    if KeyBox.Text == "flappy>othermenus" then
        if RememberToggle.GetState() then
            Library:SaveKey(KeyPath, FileName, KeyBox.Text)
        end
        KeyWindow:Close()
        
        -- Loads your full flappy.cc script from GitHub
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Neon-VR/flappycc/refs/heads/main/flappy.lua"))()
    else
        game.Players.LocalPlayer:Kick("Invalid Key")
    end
end)

KeyWindow:AddButton("Get Key", UDim2.new(0.55, 0, 0.65, 0), function()
    if setclipboard then
        setclipboard("https://discord.gg/ekCQpygWrJ")
        print("✅ Discord invite copied to clipboard!")
    end
end)
