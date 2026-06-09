-- Envy | Visuals Module (Fog + Ambient)
local RunService = game:GetService("RunService")
local Lighting   = game:GetService("Lighting")
local msin       = math.sin
local mpi        = math.pi

local function applyVisuals()
    local V = getgenv().Envy.Visuals

    if V.Fog.Enabled then
        Lighting.FogColor = V.Fog.Color
        Lighting.FogStart = V.Fog.Start
        Lighting.FogEnd   = V.Fog.FogEnd
    end

    if V.Ambient.Enabled then
        Lighting.Ambient        = V.Ambient.AmbientColor
        Lighting.OutdoorAmbient = V.Ambient.OutdoorAmbient
        Lighting.Brightness     = V.Ambient.Brightness
    end
end

applyVisuals()

local fogPulseTime = 0
RunService.Heartbeat:Connect(function(dt)
    local V = getgenv().Envy.Visuals
    if V.Fog.Enabled and V.Fog.Pulse.Enabled then
        fogPulseTime = fogPulseTime + dt
        local p     = V.Fog.Pulse
        local alpha = (msin((fogPulseTime / p.Speed) * mpi * 2) + 1) * 0.5
        Lighting.FogEnd = p.FogMin + (p.FogMax - p.FogMin) * alpha
    end
end)

print("Envy | Visuals loaded")
