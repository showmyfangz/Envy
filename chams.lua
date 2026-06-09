-- Envy | Chams Module (Single Box)
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function shouldApplyChams(character)
    if not character then return false end
    if not getgenv().Envy.Esp.Chams.Enabled then return false end
    local player = Players:GetPlayerFromCharacter(character)
    if not player or player == LocalPlayer then return false end
    local tc = getgenv().Envy.Silent.Globals.TeamCheck
    if tc and player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then return false end
    return true
end

local function createChams(character)
    -- Clean up existing
    local existing = character:FindFirstChild("EnvyBoxChams")
    if existing then existing:Destroy() end

    if not shouldApplyChams(character) then return end

    local cs     = getgenv().Envy.Esp.Chams
    local folder = Instance.new("Folder")
    folder.Name   = "EnvyBoxChams"
    folder.Parent = character

    -- Single SelectionBox covering the whole character model
    local box = Instance.new("SelectionBox")
    box.Adornee        = character          -- wraps the entire model
    box.Color3         = cs.ChamsColor
    box.SurfaceColor3  = cs.ChamsColor
    box.SurfaceTransparency = cs.Transparency
    box.LineThickness  = 0.05              -- adjust to taste
    box.Parent         = folder
end

local function refreshAllChams()
    for _, p in next, Players:GetPlayers() do
        if p ~= LocalPlayer and p.Character then createChams(p.Character) end
    end
end

local function setupChams(player)
    if player == LocalPlayer then return end
    if player.Character then createChams(player.Character) end
    player.CharacterAdded:Connect(createChams)
    player:GetPropertyChangedSignal("Team"):Connect(function()
        if player.Character then createChams(player.Character) end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do setupChams(p) end
Players.PlayerAdded:Connect(setupChams)
LocalPlayer:GetPropertyChangedSignal("Team"):Connect(refreshAllChams)
Players.PlayerRemoving:Connect(function(p)
    if p.Character then
        local f = p.Character:FindFirstChild("EnvyBoxChams")
        if f then f:Destroy() end
    end
end)

print("Envy | Chams loaded")
