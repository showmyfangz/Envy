-- Envy | FOV + Crosshair Module
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local msin          = math.sin
local mcos          = math.cos
local mpi           = math.pi
local v2new         = Vector2.new
local BLACK         = Color3.new(0, 0, 0)
local TWO_PI_OVER_4 = (mpi * 2) / 4

local fov_outer = Drawing.new("Circle")
fov_outer.Thickness = 1; fov_outer.Transparency = 1; fov_outer.NumSides = 64
fov_outer.Filled = false; fov_outer.Color = BLACK; fov_outer.Visible = false

local fov_inner = Drawing.new("Circle")
fov_inner.Thickness = 1; fov_inner.Transparency = 1; fov_inner.NumSides = 64
fov_inner.Filled = false; fov_inner.Color = BLACK; fov_inner.Visible = false

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1; fov_circle.Transparency = 1; fov_circle.NumSides = 64
fov_circle.Filled = false; fov_circle.Visible = false

local fov_fill = Drawing.new("Circle")
fov_fill.Thickness = 0; fov_fill.Transparency = 0.3; fov_fill.NumSides = 64
fov_fill.Filled = true; fov_fill.Visible = false

local cross_center = Drawing.new("Circle")
cross_center.Radius = 1.5; cross_center.Thickness = 1
cross_center.Transparency = 1; cross_center.Filled = true; cross_center.Visible = false

local cross_outline = Drawing.new("Circle")
cross_outline.Radius = 2.5; cross_outline.Thickness = 1
cross_outline.Transparency = 1; cross_outline.Filled = false
cross_outline.Color = BLACK; cross_outline.Visible = false

local lines, line_outlines = {}, {}
for i = 1, 4 do
    local o = Drawing.new("Line")
    o.Thickness = 2.2; o.Transparency = 1; o.Color = BLACK; o.Visible = false
    line_outlines[i] = o
    local l = Drawing.new("Line")
    l.Thickness = 1.2; l.Transparency = 1
    l.Color = getgenv().Envy.Misc.CrossHair.Color; l.Visible = false
    lines[i] = l
end

local anim_time = 0

RunService.RenderStepped:Connect(function(dt)
    local mouse = UserInputService:GetMouseLocation()
    local Envy  = getgenv().Envy

    local sf           = Envy.Silent.Fov
    local sc           = sf.Customize
    local radius       = sf.FovSize
    local show_outline = sf.ShowFov and sc.FovOutline

    fov_outer.Radius  = radius + 1
    fov_inner.Radius  = radius - 1
    fov_circle.Radius = radius
    fov_fill.Radius   = radius

    fov_outer.Visible  = show_outline
    fov_inner.Visible  = show_outline
    fov_circle.Visible = sf.ShowFov
    fov_fill.Visible   = sf.ShowFov and sc.FillFov

    fov_outer.Position  = mouse
    fov_inner.Position  = mouse
    fov_circle.Position = mouse
    fov_fill.Position   = mouse
    fov_circle.Color    = sc.FovColor
    fov_fill.Color      = sc.FovFillColor

    local ch = Envy.Misc.CrossHair
    if ch.Enabled then
        anim_time = anim_time + dt

        cross_center.Position  = mouse
        cross_center.Color     = ch.Color
        cross_center.Visible   = true
        cross_outline.Position = mouse
        cross_outline.Visible  = true

        local spin  = anim_time * ch.Speed
        local pulse = 1 + msin(anim_time * 3) * ch.PulseStrength
        local len   = 13 * pulse
        local off   = 4.5

        for i = 1, 4 do
            local ang    = TWO_PI_OVER_4 * (i - 1) + spin
            local ca, sa = mcos(ang), msin(ang)
            local from   = v2new(mouse.X + ca * off,       mouse.Y + sa * off)
            local to     = v2new(mouse.X + ca * (off+len), mouse.Y + sa * (off+len))

            line_outlines[i].From = from; line_outlines[i].To = to; line_outlines[i].Visible = true
            lines[i].From = from; lines[i].To = to; lines[i].Color = ch.Color; lines[i].Visible = true
        end
    else
        cross_center.Visible  = false
        cross_outline.Visible = false
        for i = 1, 4 do lines[i].Visible = false; line_outlines[i].Visible = false end
    end
end)

print("Envy | FOV + Crosshair loaded")
