-- Envy | Chams Module
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local v3new       = Vector3.new

local BODY_PARTS = {
    "Head","UpperTorso","LowerTorso","Torso",
    "LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand",
    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot"
}

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
    if not shouldApplyChams(character) then
        local f = character:FindFirstChild("EnvyBoxChams")
        if f then f:Destroy() end
        return
    end
    local f = character:FindFirstChild("EnvyBoxChams")
    if f then f:Destroy() end

    local cs     = getgenv().Envy.Esp.Chams
    local folder = Instance.new("Folder")
    folder.Name   = "EnvyBoxChams"
    folder.Parent = character

    for _, name in next, BODY_PARTS do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            local b = Instance.new("BoxHandleAdornment")
            b.Adornee      = part
            b.Color3       = cs.ChamsColor
            b.Transparency = cs.Transparency
            b.Size         = part.Size + v3new(0.08, 0.08, 0.08)
            b.AlwaysOnTop  = true
            b.ZIndex       = 10
            b.Parent       = folder
        end
    end
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
