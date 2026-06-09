-- Envy | Silent Aim Module
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

local huge  = math.huge
local mrand = math.random
local v2new = Vector2.new
local v3new = Vector3.new
local cfnew = CFrame.new

local function get_random_point(part)
    if not part then return nil end
    local s = part.Size
    local h = s * 0.5
    return part.CFrame * v3new(
        mrand() * s.X - h.X,
        mrand() * s.Y - h.Y,
        mrand() * s.Z - h.Z
    )
end

local _rayparams = RaycastParams.new()
_rayparams.FilterType  = Enum.RaycastFilterType.Exclude
_rayparams.IgnoreWater = true

local function is_visible(target_part)
    if not getgenv().Envy.Silent.Globals.WallCheck then return true end
    local char = LocalPlayer.Character
    if char then _rayparams.FilterDescendantsInstances = {char} end
    local origin = Camera.CFrame.Position
    local result = workspace:Raycast(origin, target_part.Position - origin, _rayparams)
    return not result or result.Instance:IsDescendantOf(target_part.Parent)
end

local function has_forcefield(char)
    if not getgenv().Envy.Silent.Globals.ForceFieldCheck then return false end
    return char:FindFirstChildOfClass("ForceField") ~= nil
end

local function get_closest_players()
    local s = getgenv().Envy.Silent
    if not s.Enabled then return nil end

    local best_part  = nil
    local best_dist  = huge
    local mouse      = UserInputService:GetMouseLocation()
    local localTeam  = LocalPlayer.Team
    local fovSize    = s.Fov.FovSize
    local useFov     = s.Fov.UseFov
    local teamCheck  = s.Globals.TeamCheck
    local hitpart    = s.Hitpart.Hitpart
    local headChance = s.Hitpart.HeadHitChance * 0.01

    for _, plr in next, Players:GetPlayers() do
        if plr == LocalPlayer then continue end
        if teamCheck and plr.Team == localTeam then continue end

        local char = plr.Character
        if not char or has_forcefield(char) then continue end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local root = char:FindFirstChild(hitpart) or char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root and not head then continue end

        local target
        if root and is_visible(root) then
            target = root
        elseif head and is_visible(head) then
            target = head
        else
            continue
        end

        if head and head ~= target and mrand() < headChance then target = head end

        local aim = get_random_point(target) or target.Position
        local sp, on = Camera:WorldToViewportPoint(aim)
        if not on then continue end

        local dist = (v2new(sp.X, sp.Y) - mouse).Magnitude
        if useFov and dist > fovSize then continue end

        if dist < best_dist then
            best_dist = dist
            best_part = aim
        end
    end

    return best_part
end

local old_index; old_index = hookmetamethod(game, "__index", newcclosure(function(self, index)
    if self == Camera and index == "CoordinateFrame" then
        local source = debug.info(3, "s")
        local name   = debug.info(3, "n")
        if source and string.find(source, "First") and name ~= "RotCamera" then
            local info = debug.getinfo(3)
            if info and info.nups == 35 then
                local tp = get_closest_players()
                if tp then return cfnew(Camera.CFrame.Position, tp) end
            end
        end
    end
    return old_index(self, index)
end))

print("Envy | Silent Aim loaded")
