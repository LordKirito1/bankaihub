-- ==============================================================================
-- CARGADOR DE LIBRERÍA DE INTERFAZ (SOLARA COMPATIBLE)
-- ==============================================================================
local Library = nil

-- Intentamos cargar Oxide/Sena Library de forma aislada
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LSSOPS/OpenSource/main/SenaHub_Steal_An_Egg!.lua"))()
end)

-- Si la librería quedó registrada en el entorno global, la tomamos
if type(_G.Library) == "table" then
    Library = _G.Library
elseif type(getgenv) == "function" and type(getgenv().Library) == "table" then
    Library = getgenv().Library
elseif type(result) == "table" and type(result.CreateWindow) == "function" then
    Library = result
end

-- Fallback de seguridad si la librería no devolvió la tabla esperada
if not Library or type(Library.CreateWindow) ~= "function" then
    warn("BANKAI HUB: No se pudo instanciar la librería principal.")
    return
end

-- ==============================================================================
-- INICIALIZACIÓN DE BANKAI HUB
-- ==============================================================================
do
    local prev = _G.BANKAIHUB_StealAnEgg
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end
local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.BANKAIHUB_StealAnEgg = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end

local Window = Library:CreateWindow({
    Name = "BANKAI HUB | Solara Edition",
    LoadingAnimation = true,
    LoadingText = "BANKAI HUB",
    LoadingDuration = 2.0,
})

-- ==============================================================================
-- SERVICES & LOCALS
-- ==============================================================================
local Players             = game:GetService("Players")
local RS                  = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local Workspace           = game:GetService("Workspace")
local Lighting            = game:GetService("Lighting")
local VirtualUser         = game:GetService("VirtualUser")

local LP          = Players.LocalPlayer
local function GetCamera()
    return Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
end

local function Notify(title, content, kind, dur)
    pcall(function()
        Window:Notify({ Title = title, Content = content, Type = kind or "Info", Duration = dur or 2.5 })
    end)
end

local function safeCallback(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            pcall(Notify, "BANKAI HUB", "Error: " .. tostring(err), "Error", 4)
        end
    end
end

-- ==============================================================================
-- MOVEMENT & PLAYER MODIFIERS
-- ==============================================================================
local walkSpeedEnabled = false
local walkSpeedVal     = 24
local jumpPowerEnabled = false
local jumpPowerVal     = 60
local flying           = false
local flySpeed         = 60

local function findHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function findHRP()
    local ch = LP.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart"))
end

local function ApplyWalkSpeed(v)
    walkSpeedVal = v
    local hum = findHum()
    if hum and walkSpeedEnabled then hum.WalkSpeed = v end
end

local function ApplyJumpPower(v)
    jumpPowerVal = v
    local hum = findHum()
    if hum and jumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end

track(RunService.Stepped:Connect(function()
    if HUB.dead then return end
    local hum = findHum()
    if hum then
        if walkSpeedEnabled then hum.WalkSpeed = walkSpeedVal end
        if jumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = jumpPowerVal end
    end
end))

-- ==============================================================================
-- UI CREATION - BANKAI HUB
-- ==============================================================================
local EggsTab     = Window:AddTab({ Name = "Huevos", Subtitle = "Robar, eclosionar y plantar", Icon = "crown" })
local CombatTab   = Window:AddTab({ Name = "Combate", Subtitle = "Defensa y utilidades", Icon = "combat" })
local PlayerTab   = Window:AddTab({ Name = "Jugador", Subtitle = "Movimiento y ajustes", Icon = "player" })

-- TAB 1: HUEVOS
local StealSub = EggsTab:AddSubTab("Auto Robo")

StealSub:AddToggle({
    Name = "Auto Robo de Huevos", Default = false, Flag = "steal_auto",
    Callback = safeCallback(function(v)
        Notify("Auto Robo", v and "Activado" or "Desactivado", v and "Success" or "Error")
    end)
})

-- TAB 2: COMBATE
local GuardSub = CombatTab:AddSubTab("Defensa")

GuardSub:AddToggle({
    Name = "Anti-Ragdoll", Default = true, Flag = "anti_ragdoll",
    Callback = function(v) end
})

-- TAB 3: JUGADOR
local MoveSub = PlayerTab:AddSubTab("Movimiento")

MoveSub:AddToggle({
    Name = "Activar WalkSpeed Personalizada", Default = false, Flag = "speed_enabled",
    Callback = safeCallback(function(v)
        walkSpeedEnabled = v
        if not v then
            local hum = findHum()
            if hum then hum.WalkSpeed = 16 end
        end
        Notify("WalkSpeed", v and "Activada" or "Desactivada", v and "Success" or "Error")
    end)
})
MoveSub:AddSlider({
    Name = "Valor de WalkSpeed", Min = 16, Max = 500, Default = 24, Suffix = " studs/s", Flag = "speed_val",
    Callback = function(v) ApplyWalkSpeed(v) end
})

-- CLEANUP
HUB.Unload = function()
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    pcall(function() Window:Destroy() end)
    _G.BANKAIHUB_StealAnEgg = nil
end

Notify("BANKAI HUB", "¡Script cargado con éxito en Solara!", "Success", 3.5)
