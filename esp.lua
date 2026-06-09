-- Envy | ESP Module
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer

local huge   = math.huge
local mmax   = math.max
local mfloor = math.floor
local mclamp = math.clamp
local v2new  = Vector2.new
local v3new  = Vector3.new
local c3new  = Color3.new
local BLACK  = c3new(0, 0, 0)

local CORNER_OFFSETS = {
    v3new( 1,  1,  1), v3new(-1,  1,  1),
    v3new( 1, -1,  1), v3new( 1,  1, -1),
    v3new(-1, -1,  1), v3new( 1, -1, -1),
    v3new(-1,  1, -1), v3new(-1, -1, -1),
}

local ESP_Cache = {}

-- ScreenGui for BillboardGui-style Text labels (uses Roblox fonts)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "EnvyFlagsGui"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = game:GetService("CoreGui")

local FLAG_FONT     = Enum.Font.SciFi
local FLAG_TEXTSIZE = 13
local FLAG_PADDING  = 4  -- px gap between box right edge and flags

local function GetHealthPercent(player, humanoid)
    if game.PlaceId == 286090429 then
        local ok, v = pcall(function()
            return player.NRPBS.Health.Value / player.NRPBS.MaxHealth.Value
        end)
        return ok and mclamp(v, 0, 1) or 0
    end
    return mclamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
end

local function NewSquare(color, zindex, filled)
    local s = Drawing.new("Square")
    s.Visible      = false
    s.Color        = color
    s.Thickness    = 1
    s.Filled       = filled or false
    s.ZIndex       = zindex
    s.Transparency = 1
    return s
end

-- Creates a single TextLabel for one flag line
local function NewFlagLabel()
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.TextTransparency       = 0
    lbl.Font                   = FLAG_FONT
    lbl.TextSize               = FLAG_TEXTSIZE
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.TextYAlignment         = Enum.TextYAlignment.Top
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3       = BLACK
    lbl.Visible                = false
    lbl.Size                   = UDim2.new(0, 120, 0, FLAG_TEXTSIZE + 2)
    lbl.Parent                 = ScreenGui
    return lbl
end

local function CreateESP(Player)
    if Player == LocalPlayer then return end
    ESP_Cache[Player] = {
        Main           = NewSquare(getgenv().Envy.Esp.Box.BoxColor, 3),
        Outline1       = NewSquare(BLACK, 2),
        Outline2       = NewSquare(BLACK, 4),
        HealthBG       = NewSquare(BLACK, 3, true),
        HealthBar      = NewSquare(getgenv().Envy.Esp.Health.HealthColor, 4, true),
        HealthOutline1 = NewSquare(BLACK, 2),
        -- Flag labels (pre-allocate 3: Idle/Walking/Jumping max 2 shown but 3 slots safe)
        FlagLabels     = { NewFlagLabel(), NewFlagLabel(), NewFlagLabel() },
    }
    Player.CharacterAdded:Connect(function(c) c:WaitForChild("HumanoidRootPart", 5) end)
end

local function RemoveESP(Player)
    local d = ESP_Cache[Player]
    if d then
        for _, lbl in next, d.FlagLabels do lbl:Destroy() end
        for k, o in next, d do
            if k ~= "FlagLabels" then o:Remove() end
        end
        ESP_Cache[Player] = nil
    end
end

local function DestroyAllESP()
    for _, d in next, ESP_Cache do
        for _, lbl in next, d.FlagLabels do lbl:Destroy() end
        for k, o in next, d do
            if k ~= "FlagLabels" then o:Remove() end
        end
    end
    ESP_Cache = {}
end

local function HideFlags(labels)
    for _, lbl in next, labels do
        lbl.Visible = false
    end
end

local function Hide(d)
    d.Main.Visible           = false
    d.Outline1.Visible       = false
    d.Outline2.Visible       = false
    d.HealthBG.Visible       = false
    d.HealthBar.Visible      = false
    d.HealthOutline1.Visible = false
    HideFlags(d.FlagLabels)
end

-- Returns list of active flag strings for a humanoid
local function GetFlags(humanoid)
    local flags = {}
    local moveDir = humanoid.MoveDirection
    local isMoving = moveDir.Magnitude > 0.1

    if humanoid.FloorMaterial == Enum.Material.Air then
        table.insert(flags, "Jumping")
    end

    if isMoving then
        table.insert(flags, "Walking")
    end

    if #flags == 0 then
        table.insert(flags, "Idle")
    end

    return flags
end

local function UpdateESP()
    local Envy          = getgenv().Envy
    local espBox        = Envy.Esp.Box
    local espHealth     = Envy.Esp.Health
    local espFlags      = Envy.Esp.Flags
    local teamCheck     = Envy.Silent.Globals.TeamCheck
    local localTeam     = LocalPlayer.Team
    local boxEnabled    = espBox.Enabled
    local healthEnabled = espHealth.Enabled
    local flagsEnabled  = espFlags.Enabled
    local flagColor     = espFlags.Color
    local boxColor      = espBox.BoxColor
    local healthColor   = espHealth.HealthColor

    for Player, D in next, ESP_Cache do
        if teamCheck and Player.Team and localTeam and Player.Team == localTeam then
            Hide(D); continue
        end

        local Char = Player.Character
        if not Char then Hide(D); continue end

        local Hum = Char:FindFirstChildOfClass("Humanoid")
        if not Hum or Hum.Health <= 0 then Hide(D); continue end

        local Root = Char:FindFirstChild("HumanoidRootPart")
        if not Root then Hide(D); continue end

        local MinX, MinY =  huge,  huge
        local MaxX, MaxY = -huge, -huge
        local Found = false

        for _, Part in next, Char:GetChildren() do
            if Part:IsA("BasePart") then
                local S  = Part.Size
                local CF = Part.CFrame
                local hx, hy, hz = S.X * 0.5, S.Y * 0.5, S.Z * 0.5

                for i = 1, 8 do
                    local off = CORNER_OFFSETS[i]
                    local Vec, On = Camera:WorldToViewportPoint(
                        CF * v3new(off.X * hx, off.Y * hy, off.Z * hz)
                    )
                    if On then
                        Found = true
                        if Vec.X < MinX then MinX = Vec.X end
                        if Vec.Y < MinY then MinY = Vec.Y end
                        if Vec.X > MaxX then MaxX = Vec.X end
                        if Vec.Y > MaxY then MaxY = Vec.Y end
                    end
                end
            end
        end

        if not Found then Hide(D); continue end

        local PX = mfloor(MinX)
        local PY = mfloor(MinY)
        local SW = mfloor(MaxX - MinX)
        local SH = mfloor(MaxY - MinY)

        -- Box
        if boxEnabled then
            D.Main.Color    = boxColor
            D.Main.Position = v2new(PX, PY)
            D.Main.Size     = v2new(SW, SH)
            D.Main.Visible  = true

            D.Outline1.Position = v2new(PX - 1, PY - 1)
            D.Outline1.Size     = v2new(SW + 2, SH + 2)
            D.Outline1.Visible  = true

            D.Outline2.Position = v2new(PX + 1, PY + 1)
            D.Outline2.Size     = v2new(SW - 2, SH - 2)
            D.Outline2.Visible  = true
        else
            D.Main.Visible     = false
            D.Outline1.Visible = false
            D.Outline2.Visible = false
        end

        -- Health bar
        if healthEnabled then
            local BW = 2
            local BX = PX - 5
            local BY = PY
            local hp = GetHealthPercent(Player, Hum)
            local fh = mmax(1, mfloor(SH * hp))

            D.HealthOutline1.Position = v2new(BX - 1, BY - 1)
            D.HealthOutline1.Size     = v2new(BW + 2, SH + 2)
            D.HealthOutline1.Visible  = true

            D.HealthBG.Position = v2new(BX, BY)
            D.HealthBG.Size     = v2new(BW, SH)
            D.HealthBG.Visible  = true

            D.HealthBar.Color    = healthColor
            D.HealthBar.Position = v2new(BX, BY + (SH - fh))
            D.HealthBar.Size     = v2new(BW, fh)
            D.HealthBar.Visible  = true
        else
            D.HealthBG.Visible       = false
            D.HealthBar.Visible      = false
            D.HealthOutline1.Visible = false
        end

        -- Flags (right side of box, starting at top, stacked downward)
        if flagsEnabled then
            local flags = GetFlags(Hum)
            local labelX = PX + SW + FLAG_PADDING  -- right of box + gap
            local labelY = PY                       -- starts at top of box, never goes below

            for i, lbl in next, D.FlagLabels do
                local flag = flags[i]
                if flag then
                    lbl.Position  = UDim2.new(0, labelX, 0, labelY + (i - 1) * (FLAG_TEXTSIZE + 2))
                    lbl.Text      = flag
                    lbl.TextColor3 = flagColor
                    lbl.Visible   = true
                else
                    lbl.Visible = false
                end
            end
        else
            HideFlags(D.FlagLabels)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.X then DestroyAllESP() end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
RunService.RenderStepped:Connect(UpdateESP)

for _, v in ipairs(Players:GetPlayers()) do CreateESP(v) end

print("Envy | ESP loaded")
