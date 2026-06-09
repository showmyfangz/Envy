-- Envy | Misc Module
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function applyMisc()
    local M = getgenv().Envy.Misc

    for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
        if v.Name == "FireRate" and M.FireRate then
            v.Value = 0.05
        end
        if v.Name == "RecoilControl" and M.NoRecoil then
            v.Value = 0
        end
        if v.Name == "ReloadTime" and M.NoReload then
            v.Value = 1
        end
        if v.Name == "MaxSpread" and M.NoSpread then
            v.Value = 0
        end
        if v.Name == "Auto" and M.FullAuto then
            v.Value = true
        end
    end
end

applyMisc()

-- Re-apply on character respawn (weapon values reset on respawn in Arsenal)
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5) -- slight delay so weapons are loaded
    applyMisc()
end)

print("Envy | Misc loaded")
