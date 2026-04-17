-- ==========================================
-- Test V574
-- ==========================================

local version = "2.1.9"

repeat task.wait() until game:IsLoaded()

local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(67)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

if setfpscap then
    setfpscap(1000000)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Anti AFK & FPS Unlocked!",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Anti AFK Enabled & FPS Unlocked!")
else
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "dsc.gg/dyhub",
        Text = "Anti AFK Enabled (FPS Unlock Not Supported)",
        Duration = 2,
        Button1 = "Okay"
    })
    warn("Anti AFK Enabled but setfpscap is missing.")
end


local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================== SERVICES ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ===================== SETTINGS =====================
local MAX_DISTANCE = 677

local Settings = {
    Ranges = {
        PullAttack = 30,
        BasicAttack = 30
    },
    Auto = {
	    Parry = false,
        Escape = false,
        Shaking = false,
        Barricade = false,
        Generator = false,
		GeneratorInstance  = false,
        KillAll = false,
        AC = true
    },
    Misc = {
        Fullbright = false,
        NoFog = false
    },
    Setting = {
        Delay = 6,
		ProximityPrompt = false,
        Highlight = true,
        Name = true,
        Distance = true,
        Health = true,
        Class = false
    },
    ESP = {
        Survivor = false,
        Killer = false,
        Lobby = false,
        Generator = false,
        FuseBox = false,
        Trap = false,
        Minion = false,
        Axe = false,
        Batteries = false
    }
}

-- ====================== VERSION CHECK ======================
local FreeVersion = "Free Version"
local PremiumVersion = "Premium Version"

local function checkVersion(playerName)
    local url = "https://raw.githubusercontent.com/mabdu21/2askdkn21h3u21ddaa/refs/heads/main/Main/Premium/listpremium.lua"
    local success, response = pcall(function() return game:HttpGet(url) end)
    if not success then return FreeVersion end

    local func, err = loadstring(response)
    if func then
        local premiumData = func()
        return premiumData[playerName] and PremiumVersion or FreeVersion
    end
    return FreeVersion
end

local userversion = checkVersion(LocalPlayer.Name)

-- ====================== WINDOW SETUP ======================
local Window = WindUI:CreateWindow({
    Title = "DYHUB",
    IconThemed = true,
    Icon = "rbxassetid://104487529937663",
    Author = "Bite by Night | " .. userversion,
    Folder = "DYHUB_BBN",
    Size = UDim2.fromOffset(580, 430),
    Transparent = true,
    Theme = "Dark",
    BackgroundImageTransparency = 0.8,
    HasOutline = false,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = { Enabled = true, Anonymous = false },
})

Window:EditOpenButton({
    Title = "DYHUB - Open",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 255, 255)),
    Draggable = true,
})

Window:SetToggleKey(Enum.KeyCode.K)

pcall(function()
    Window:Tag({ Title = version, Color = Color3.fromHex("#30ff6a") })
end)

local InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
local MainDivider1 = Window:Divider()
local Auto = Window:Tab({ Title = "Survivor", Icon = "user-check" })
local Killer = Window:Tab({ Title = "Killer", Icon = "swords" })
local MainDivider = Window:Divider()
local Main = Window:Tab({ Title = "Main", Icon = "rocket" })
--local Aimbot = Window:Tab({ Title = "Aimbot", Icon = "target" })
local EspTab = Window:Tab({ Title = "Esp", Icon = "eye" })
Window:SelectTab(1)

-- ====================== AUTO GENERATOR ======================
task.spawn(function()
    local hasStarted = false

    while true do
        task.wait(0.2)

        if Settings.Auto.Generator then
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            local gen = gui and gui:FindFirstChild("Gen")

            if gen then
                if not hasStarted then
                    hasStarted = true
                    task.wait(Settings.Setting.Delay)
                end

                pcall(function()
                    local args = {
                        [1] = {
                            ["Wires"] = true,
                            ["Switches"] = true,
                            ["Lever"] = true
                        }
                    }
                    gen.GeneratorMain.Event:FireServer(unpack(args))
                end)

                task.wait(Settings.Setting.Delay)
            else
                hasStarted = false
            end
        end
    end
end)

task.spawn(function()
    local hasStarted = false

    while true do
        task.wait(0.1)

        if Settings.Auto.GeneratorInstance then
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            local gen = gui and gui:FindFirstChild("Gen")

            if gen then
                if not hasStarted then
                    hasStarted = true
                    task.wait(0.1)
                end

                pcall(function()
                    local args = {
                        [1] = {
                            ["Wires"] = true,
                            ["Switches"] = true,
                            ["Lever"] = true
                        }
                    }
                    gen.GeneratorMain.Event:FireServer(unpack(args))
                end)

                task.wait(Settings.Setting.Delay)
            else
                hasStarted = false
            end
        end
    end
end)

-- ====================== ESP CORE ======================
local highlights = {}
local billboards = {}
local connections = {}

local function removeESP(obj)
    if highlights[obj] then highlights[obj]:Destroy() highlights[obj] = nil end
    if billboards[obj] then billboards[obj]:Destroy() billboards[obj] = nil end
    if connections[obj] then connections[obj]:Disconnect() connections[obj] = nil end
end

local function addESP(obj, color, role)
    if not obj or obj == LocalPlayer.Character then return end

    -- ✅ รองรับ MeshPart
    local part
    if obj:IsA("BasePart") then
        part = obj
    else
        part = obj:FindFirstChild("Head") 
            or obj:FindFirstChild("HumanoidRootPart") 
            or obj:FindFirstChildWhichIsA("BasePart", true)
    end

    if not part then return end

    -- 🔥 ลบ Highlight เก่าของ object นี้ก่อน (สำคัญมาก)
    for _,v in pairs(obj:GetDescendants()) do
        if v:IsA("Highlight") then
            v:Destroy()
        end
    end

    -- กันซ้ำเฉพาะ ESP เรา
    if highlights[obj] then return end

    -- ================= Highlight =================
    if Settings.Setting.Highlight then
        local h = Instance.new("Highlight")
        h.FillTransparency = 1
        h.OutlineColor = color
        h.Adornee = obj
        h.Parent = CoreGui
        highlights[obj] = h
    end

    -- ================= Billboard =================
    local gui = Instance.new("BillboardGui")
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0.25
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.Parent = gui

    gui.Parent = part
    billboards[obj] = gui

    connections[obj] = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then removeESP(obj) return end
        
        local roleCheck = role:gsub(" ", "")

        if roleCheck == "Survivor" and not Settings.ESP.Survivor then removeESP(obj) return end
        if roleCheck == "Killer" and not Settings.ESP.Killer then removeESP(obj) return end
        if roleCheck == "Lobby" and not Settings.ESP.Lobby then removeESP(obj) return end
        if roleCheck == "Generators" and not Settings.ESP.Generator then removeESP(obj) return end
        if roleCheck == "FuseBoxes" and not Settings.ESP.FuseBox then removeESP(obj) return end
        if roleCheck == "Batteries" and not Settings.ESP.Batteries then removeESP(obj) return end
        if roleCheck == "Trap" and not Settings.ESP.Trap then removeESP(obj) return end
        if roleCheck == "Minion" and not Settings.ESP.Minion then removeESP(obj) return end
        if roleCheck == "Axe" and not Settings.ESP.Axe then removeESP(obj) return end

        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local dist = (root.Position - part.Position).Magnitude
        if dist > MAX_DISTANCE then removeESP(obj) return end

        local text = ""

        if obj:FindFirstChild("Humanoid") then
            local charAttr = obj:GetAttribute("Character")
            local class = charAttr and tostring(charAttr):gsub("^Survivor%-", "") or "Unknown"
            
            if Settings.Setting.Name and Settings.Setting.Class then
                text = obj.Name .. " | " .. class
            elseif Settings.Setting.Name then
                text = obj.Name
            elseif Settings.Setting.Class then
                text = class
            end

            if Settings.Setting.Health then 
                text = text .. "\n" .. math.floor(obj.Humanoid.Health) .. " HP"
            end
        else
            text = role or "Object"
        end

        if Settings.Setting.Distance then 
            text = text .. "\n" .. math.floor(dist) .. " MM" 
        end
        
        label.Text = text
    end)
end

-- ================= COLORS =================
local COLORS = {
    Survivor = Color3.fromRGB(0, 170, 255),
    Killer = Color3.fromRGB(255, 0, 0),
    Lobby = Color3.fromRGB(255, 255, 255),
    Trap = Color3.fromRGB(255, 65, 65),
    Generators = Color3.fromRGB(255, 255, 0),
    FuseBoxes = Color3.fromRGB(0, 255, 255),
    Minion = Color3.fromRGB(120, 6, 6),
    Axe = Color3.fromRGB(165, 42, 42),
    Batteries = Color3.fromRGB(0, 255, 0)
}

local function scan()
    local playerFolder = workspace:FindFirstChild("PLAYERS")
    if playerFolder then
        for _,folder in pairs(playerFolder:GetChildren()) do
            for _,model in pairs(folder:GetChildren()) do
                if model:IsA("Model") and model ~= LocalPlayer.Character then
                    if folder.Name == "ALIVE" and Settings.ESP.Survivor then addESP(model, COLORS.Survivor, "Survivor")
                    elseif folder.Name == "KILLER" and Settings.ESP.Killer then addESP(model, COLORS.Killer, "Killer")
                    elseif folder.Name == "LOBBY" and Settings.ESP.Lobby then addESP(model, COLORS.Lobby, "Lobby")
                    end
                end
            end
        end
    end

    local maps = workspace:FindFirstChild("MAPS")
    if maps then
        for _,map in pairs(maps:GetChildren()) do

            local function checkObj(fName, setVal)
                local f = map:FindFirstChild(fName)
                if f and setVal then
                    for _,o in pairs(f:GetChildren()) do
                        addESP(o, COLORS[fName] or Color3.new(1,1,1), fName)
                    end
                end
            end
            
            checkObj("Generators", Settings.ESP.Generator)
            checkObj("FuseBoxes", Settings.ESP.FuseBox)

            -- 🔥 Battery FIX
            if Settings.ESP.Batteries then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _, o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Battery" then
                            addESP(o, COLORS.Batteries, "Batteries")
                        end
                    end
                end
            end

            if Settings.ESP.Minion then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _, o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Minion" then
                            addESP(o, COLORS.Minion, "Minion")
                        end
                    end
                end
            end

            if Settings.ESP.Axe then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _, o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Axe" then
                            addESP(o, COLORS.Axe, "Axe")
                        end
                    end
                end
            end

            if Settings.ESP.Trap then
                local ignoreFolder = workspace:FindFirstChild("IGNORE")
                if ignoreFolder then
                    for _,o in pairs(ignoreFolder:GetChildren()) do
                        if o.Name == "Trap" then
                            addESP(o, COLORS.Trap, "Trap")
                        end
                    end
                end

                local trapFolder = workspace:FindFirstChild("Trap")
                if trapFolder then
                    for _,o in pairs(trapFolder:GetChildren()) do
                        addESP(o, COLORS.Trap, "Trap")
                    end
                end
            end
        end
    end
end

local function clearAllESP()
    for obj, _ in pairs(highlights) do removeESP(obj) end
end

task.spawn(function()
    while true do
        task.wait(1)
        scan()
    end
end)

-- ====================== KILLER ======================
Killer:Section({ Title = "Combat", Icon = "swords" })
-- Toggle
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game.Players
local LocalPlayer = Players.LocalPlayer

Killer:Toggle({
    Title = "Auto Kill All (Not Legit)",
    Desc = "Automatically teleport to kill survivor all",
    Value = false,
    Callback = function(v)
        Settings.Auto.KillAll = v
        
        if tpConn then 
            tpConn:Disconnect() 
            tpConn = nil 
        end

        if Settings.Auto.KillAll then
            tpConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end

                local closestPlayer = nil
                local shortestDistance = math.huge

                for _, target in ipairs(workspace.PLAYERS.ALIVE:GetChildren()) do
                    local tRoot = target:FindFirstChild("HumanoidRootPart")
                    local tHum = target:FindFirstChild("Humanoid")
                    
                    if tRoot and tHum and tHum.Health > 0 and target ~= char then
                        local distance = (root.Position - tRoot.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = target
                        end
                    end
                end

                if closestPlayer then
                    local tRoot = closestPlayer:FindFirstChild("HumanoidRootPart")
                    root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)

                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end)
        end
    end
})

-- ====================== GUI TABS ======================
Main:Section({ Title = "Anti Cheat", Icon = "cpu" })
-- Toggle
Main:Toggle({
    Title = "Bypass Anti Cheat",
    Desc = "Automatically clean Anti Cheat",
    Value = Settings.Auto.AC,
    Callback = function(v)
        Settings.Auto.AC = v
    end
})

local ProximityCache = {}

local function SetPrompt(v)
    if v:IsA("ProximityPrompt") then
        ProximityCache[v] = v.HoldDuration
        v.HoldDuration = 0.5
    end
end

local function ResetPrompt()
    for v, old in pairs(ProximityCache) do
        if v and v.Parent then
            v.HoldDuration = old
        end
    end
    table.clear(ProximityCache)
end

Main:Section({ Title = "Main Miscellaneous", Icon = "crown" })

Main:Toggle({
    Title = "Proximity Prompt (Instant)",
    Desc = "Set Hold Duration to 0.5 sec",
    Value = false,
    Callback = function(state)
        Settings.Setting.ProximityPrompt = state

        if state then
            -- Apply กับของที่มีอยู่แล้ว
            for _, v in ipairs(W:GetDescendants()) do
                SetPrompt(v)
            end

            -- Apply กับของใหม่
            ProximityConnection = W.DescendantAdded:Connect(SetPrompt)
        else
            -- Reset กลับ
            if ProximityConnection then
                ProximityConnection:Disconnect()
            end
            ResetPrompt()
        end
    end
})

-- ================= BYPASS ANTI CHEAT =================
task.spawn(function()
    local mt = getrawmetatable(game)
    if not mt then return end

    setreadonly(mt, false)

    local oldNamecall = mt.__namecall
    local oldKick

    -- hook Kick (กัน Local Kick เท่านั้น)
    oldKick = hookfunction(game.Players.LocalPlayer.Kick, function(...)
        if Settings.Auto.AC then
            warn("[AC] Blocked Kick attempt")
            return
        end
        return oldKick(...)
    end)

    -- keywords ขั้นสูง
    local blacklist = {"anti","cheat","kick","ban","detect","flag","log","report","ac","secure","check","verify","validation","validate","scan","monitor","watch","track","guard","shield","protection","protect","security","safety","integrity","auth","authentication","authorize","logger","logging","logdata","webhook","discordhook","httplog","remotelog","hook","hooklog","hookdata","hookevent","hookcheat","logcheat","cheatlog","reporter","reportlog","ticket","tickets","supportticket","mod","moderation","adminlog","stafflog","analytics","metrics","metriclog","tracker","tracking","tracklog","eventlog","datalog","datatrack","flagged","flaglog","detectlog","detectionlog","http","https","requestlog","postlog","apilog","api","endpoint","database","db","datastore","storelog","save","savelog","audit","auditlog","journal","history","historylog","monitorlog","watchlog","suspicious","exploit","tamper","abuse","violation","illegal","servercheck","clientcheck","sanity","heartbeat","pingcheck","sync","hidden","core","internal","system","service","handler","manager","controller","module","main","init","acb","anticheat","acsys","sec","prot","guarded"}

    local function isSuspicious(remote, method, args)
        local name = tostring(remote):lower()

        -- เช็คชื่อ
        for _, v in ipairs(blacklist) do
            if name:find(v) then
                return true
            end
        end

        -- เช็ค argument (บางเกมส่ง string มาตรวจ)
        for _, v in ipairs(args) do
            if typeof(v) == "string" then
                local l = v:lower()
                for _, b in ipairs(blacklist) do
                    if l:find(b) then
                        return true
                    end
                end
            end
        end

        return false
    end

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if Settings.Auto.AC then
            if method == "FireServer" or method == "InvokeServer" then
                if isSuspicious(self, method, args) then
                    warn("[AC] Blocked Remote:", self)
                    return nil
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end)

-- =================== FULL BRIGHTNESS =============
Main:Section({ Title = "Miscellaneous", Icon = "grid-2x2" })

local lighting = game:GetService("Lighting")
local oldLighting = {}

Main:Toggle({
    Title = "Full Bright",
	Desc = "SO BRIGHTNESS MY EYEEEEEEEE",
    Value = Settings.Misc.Fullbright,
    Callback = function(v)
        Settings.Misc.Fullbright = v
        if v then
            oldLighting.Brightness = lighting.Brightness
            oldLighting.ClockTime = lighting.ClockTime
            oldLighting.GlobalShadows = lighting.GlobalShadows
            oldLighting.Ambient = lighting.Ambient
            
            lighting.Brightness = 5
            lighting.ClockTime = 14
            lighting.GlobalShadows = false
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
        else
            if oldLighting.Brightness ~= nil then
                lighting.Brightness = oldLighting.Brightness
                lighting.ClockTime = oldLighting.ClockTime
                lighting.GlobalShadows = oldLighting.GlobalShadows
                lighting.Ambient = oldLighting.Ambient
            end
        end
    end
})

Main:Toggle({
    Title = "No Fog",
	Desc = "MY EYE SO CLEAN NGL",
    Value = Settings.Misc.NoFog,
    Callback = function(v)
        Settings.Misc.NoFog = v
        if v then
            oldLighting.Density = lighting.Atmosphere.Density
            oldLighting.FogStart = lighting.FogStart
            oldLighting.FogEnd = lighting.FogEnd
            
            lighting.FogStart = 0
            lighting.FogEnd = 9e9
            lighting.Atmosphere.Density = 0
        else
            if oldLighting.FogEnd ~= nil then
                lighting.Atmosphere.Density = oldLighting.Density
                lighting.FogStart = oldLighting.FogStart
                lighting.FogEnd = oldLighting.FogEnd
            end
        end
    end
})

-- Main Tab
Auto:Section({ Title = "Auto Fixing", Icon = "zap" })

Auto:Slider({
    Title = "Auto Generator Delay",
    Desc = "Delay between each fix",
    Value = {Min = 1, Max = 20, Default = 6},
    Callback = function(v) Settings.Setting.Delay = v end
})

Auto:Toggle({
    Title = "Auto Generator",
    Desc = "Automatically fixing Generator",
    Value = false,
    Callback = function(v) Settings.Auto.Generator = v end
})

Auto:Toggle({
    Title = "Auto Generator (Instant)",
    Desc = "Automatically fixing Generator",
    Value = false,
    Callback = function(v) Settings.Auto.GeneratorInstance = v end
})

Auto:Section({ Title = "Auto Objective", Icon = "door-closed" })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local dotConn = nil

Auto:Toggle({
    Title = "Auto Barricade",
    Desc = "Automatically perfect Barricade",
    Value = false,
    Callback = function(v)
        Settings.Auto.Barricade = v

        local gui = LocalPlayer:WaitForChild("PlayerGui")

        if v then
            -- ป้องกันซ้อน
            if dotConn then dotConn:Disconnect() end

            dotConn = RunService.RenderStepped:Connect(function()
                pcall(function()

                    -- วนหา Dot ทุกตัว (กันมีหลายอัน)
                    for _, dot in ipairs(gui:GetChildren()) do
                        if dot.Name == "Dot" and dot:IsA("ScreenGui") then

                            -- ❌ ถ้าไม่เปิด = ลบทิ้งทันที
                            if not dot.Enabled then
                                dot:Destroy()
                                continue
                            end

                            local container = dot:FindFirstChild("Container")
                            local frame = container and container:FindFirstChild("Frame")

                            if frame and frame:IsA("GuiObject") then
                                -- 🎯 ล็อคกลางจอ (Perfect)
                                frame.AnchorPoint = Vector2.new(0.5, 0.5)
                                frame.Position = UDim2.new(0.5, 0, 0.5, 0)
                            end
                        end
                    end

                end)
            end)

        else
            -- ปิดระบบ
            if dotConn then
                dotConn:Disconnect()
                dotConn = nil
            end
        end
    end
})
--[[
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==================== CORE LOGIC FUNCTIONS ====================
local function GetTarget(folderName, maxDist, ignoreName)
    local closest = nil
    local shortestDist = maxDist
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local playersFolder = workspace:FindFirstChild("PLAYERS")
    if not playersFolder then return nil end
    local targetFolder = playersFolder:FindFirstChild(folderName)
    if not targetFolder then return nil end

    for _, target in ipairs(targetFolder:GetChildren()) do
        if target:IsA("Model") and target.Name ~= ignoreName then
            local root = target:FindFirstChild("HumanoidRootPart")
            local hum = target:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = target
                end
            end
        end
    end
    return closest
end

local function CheckVisibility(target, wallCheck)
    if not wallCheck then return true end
    if not target or not target:FindFirstChild("HumanoidRootPart") then return false end
    
    local char = LocalPlayer.Character
    local rayParam = RaycastParams.new()
    rayParam.FilterDescendantsInstances = {char, target}
    rayParam.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(char.HumanoidRootPart.Position, (target.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Unit * 500, rayParam)
    return result == nil
end

-- ==================== TAER AIMBOT OBJECT ====================
local TazerAimbot = {
    Enabled = false, Prediction = 2, Walls = true, MaxDistance = 1000,
    IdleAnimationId = "138208219199182", ShotAnimationId = "130467442785091",
    WalkAnimations = {["127042414505048"]=true,["79148485942313"]=true,["113176542209969"]=true,["111983226830519"]=true,["133180895948563"]=true,["120326377077980"]=true,["83351889483571"]=true,["136548794483974"]=true}
}

function TazerAimbot.IsHolding()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    for _, track in pairs(hum:GetPlayingAnimationTracks()) do
        local id = tostring(track.Animation.AnimationId):match("%d+")
        if id == TazerAimbot.IdleAnimationId or TazerAimbot.WalkAnimations[id] then return true end
    end
    return false
end

function TazerAimbot.Update()
    if not TazerAimbot.Enabled or not TazerAimbot.IsHolding() then return end
    local target = GetTarget("KILLER", TazerAimbot.MaxDistance, "")
    if target and CheckVisibility(target, TazerAimbot.Walls) then
        local pos = target.HumanoidRootPart.Position + (target.HumanoidRootPart.Velocity * (TazerAimbot.Prediction / 10))
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, pos)
    end
end

-- ==================== AXE AIMBOT OBJECT ====================
local AxeAimbot = {
    Enabled = false, Prediction = 2, Walls = true, MaxDistance = 1000,
    IdleAnimationId = "77150341615948", ThrowAnimationId = "119495869953586",
    WalkAnimations = {["118509706908978"]=true,["114261887795674"]=true,["138068581032578"]=true,["115567619906878"]=true,["87240234350251"]=true,["129887420610542"]=true,["89108444403670"]=true,["126261863915299"]=true}
}

function AxeAimbot.IsHolding()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    for _, track in pairs(hum:GetPlayingAnimationTracks()) do
        local id = tostring(track.Animation.AnimationId):match("%d+")
        if id == AxeAimbot.IdleAnimationId or AxeAimbot.WalkAnimations[id] then return true end
    end
    return false
end

function AxeAimbot.Update()
    if not AxeAimbot.Enabled or not AxeAimbot.IsHolding() then return end
    local target = GetTarget("ALIVE", AxeAimbot.MaxDistance, LocalPlayer.Name)
    if target and CheckVisibility(target, AxeAimbot.Walls) then
        local pos = target.HumanoidRootPart.Position + (target.HumanoidRootPart.Velocity * (AxeAimbot.Prediction / 10))
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, pos)
    end
end

-- ==================== CONNECTION ====================
RunService.RenderStepped:Connect(function()
    if TazerAimbot.Enabled then TazerAimbot.Update() end
    if AxeAimbot.Enabled then AxeAimbot.Update() end
end)

-- ==================== UI ====================

Aimbot:Section({ Title = "Aimbot Axe (Not Fighter)", Icon = "axe" })

Aimbot:Slider({

    Title = "Prediction",

    Desc = "Prediction strength",

    Value = { Min = 0, Max = 10, Default = 2 },

    Callback = function(v)

        AxeAimbot.SetPrediction(v)

    end

})



Aimbot:Slider({

    Title = "Max Distance",

    Desc = "Maximum aim distance",

    Value = { Min = 100, Max = 2000, Default = 1000 },

    Callback = function(v)

        AxeAimbot.SetMaxDistance(v)

    end

})



Aimbot:Toggle({

    Title = "Wall Check",

    Desc = "Disable to aim through walls",

    Value = true,

    Callback = function(v)

        AxeAimbot.SetWalls(v)

    end

})



Aimbot:Toggle({

    Title = "Enable Aimbot (Axe)",

    Desc = "Automatically locks aim onto the Killer",

    Value = false,

    Callback = function(v)

        if v then

            AxeAimbot.Start()

        else

            AxeAimbot.Stop()

        end

    end

})



-- ==================== UI ====================

Aimbot:Section({ Title = "Aimbot Taser", Icon = "zap" })

Aimbot:Slider({

    Title = "Prediction",

    Desc = "Prediction strength",

    Value = { Min = 0, Max = 10, Default = 2 },

    Callback = function(v)

        TazerAimbot.SetPrediction(v)

    end

})



Aimbot:Slider({

    Title = "Max Distance",

    Desc = "Maximum aim distance",

    Value = { Min = 100, Max = 2000, Default = 1000 },

    Callback = function(v)

        TazerAimbot.SetMaxDistance(v)

    end

})



Aimbot:Toggle({

    Title = "Wall Check",

    Desc = "Disable to ignore walls (through walls)",

    Value = true,

    Callback = function(v)

        TazerAimbot.SetWalls(v)

    end

})



Aimbot:Toggle({

    Title = "Enable Aimbot (Taser)",

    Desc = "Automatically locks aim onto the Killer",

    Value = false,

    Callback = function(v)

        if v then

            TazerAimbot.Start()

        else

            TazerAimbot.Stop()

        end

    end

})
--]]
local AutoBlock = {
    Enabled = false,
    Connection = nil,

    MinDistance = 20,
    ThrowDistance = 80,

    Cooldown = 0.25,
    PredictionDelay = 0.08, -- 🔥 delay ก่อน block (ปรับได้)

    CurrentKiller = nil,
    KillerHRP = nil,

    SoundHooks = {},
    ActiveSounds = {},
    SoundCooldowns = {},
    AnimCooldowns = {},

    LastBlockTime = 0,

    ThrowAnimations = {
        ["133752270724243"] = true
    },

    ChargeAnimations = {
        ["89272231996541"] = true,
        ["71147082224885"] = true
    },

    AttackSounds = {
        ["120953752337955"] = true,
        ["98744302864116"] = true,
        ["110440119952050"] = true,
        ["115508938791896"] = true,
        ["91318511389137"] = true,
        ["113286736276764"] = true
    }
}

--// ================= UTILS =================

function AutoBlock.GetHRP(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

function AutoBlock.IsFacing(killerHRP, myHRP)
    local look = killerHRP.CFrame.LookVector
    local dir = (myHRP.Position - killerHRP.Position).Unit
    return look:Dot(dir) > 0.65 -- 🔥 ปรับ FOV ฉลาดขึ้น
end

function AutoBlock.Distance(a, b)
    return (a.Position - b.Position).Magnitude
end

--// ================= BLOCK =================

function AutoBlock.ExecuteBlock()
    local now = tick()
    if now - AutoBlock.LastBlockTime < AutoBlock.Cooldown then return end
    AutoBlock.LastBlockTime = now

    task.delay(AutoBlock.PredictionDelay, function()
        local RS = game:GetService("ReplicatedStorage")
        local r = RS:FindFirstChild("Modules")
        if r then
            r = r:FindFirstChild("Warp")
            if r then
                r = r:FindFirstChild("Index")
                if r then
                    r = r:FindFirstChild("Event")
                    if r then
                        r = r:FindFirstChild("Reliable")
                        if r then
                            r:FireServer(
                                buffer.fromstring("\7"),
                                buffer.fromstring("\254\1\0\254\2\0\6\7Ability\1\2")
                            )
                        end
                    end
                end
            end
        end
    end)
end

--// ================= SOUND =================

function AutoBlock.ExtractId(sound)
    local s = tostring(sound.SoundId)
    return s:match("%d+")
end

function AutoBlock.HookSound(sound)
    if AutoBlock.SoundHooks[sound] then return end

    local function trigger()
        local id = AutoBlock.ExtractId(sound)
        if not id or not AutoBlock.AttackSounds[id] then return end
        AutoBlock.ActiveSounds[sound] = tick()
    end

    local c1 = sound.Played:Connect(trigger)
    local c2 = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if sound.IsPlaying then trigger() end
    end)

    local c3 = sound.Destroying:Connect(function()
        if c1 then c1:Disconnect() end
        if c2 then c2:Disconnect() end
        if c3 then c3:Disconnect() end

        AutoBlock.SoundHooks[sound] = nil
        AutoBlock.ActiveSounds[sound] = nil
    end)

    AutoBlock.SoundHooks[sound] = {c1, c2, c3}
end

function AutoBlock.HookKiller(character)
    local hrp = AutoBlock.GetHRP(character)
    if not hrp then return end

    for _, v in ipairs(hrp:GetChildren()) do
        if v:IsA("Sound") then
            AutoBlock.HookSound(v)
        end
    end

    hrp.ChildAdded:Connect(function(v)
        if v:IsA("Sound") then
            AutoBlock.HookSound(v)
        end
    end)
end

--// ================= KILLER =================

function AutoBlock.UpdateKiller()
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return end

    local killer = players:FindFirstChild("KILLER")
    if not killer then return end

    for _, v in ipairs(killer:GetChildren()) do
        if v:IsA("Model") then
            local hrp = AutoBlock.GetHRP(v)
            if hrp then
                AutoBlock.CurrentKiller = v
                AutoBlock.KillerHRP = hrp
                AutoBlock.HookKiller(v)
                return
            end
        end
    end
end

--// ================= ANIMATION =================

function AutoBlock.CheckAnimation(myHRP)
    local killer = AutoBlock.CurrentKiller
    local hrp = AutoBlock.KillerHRP
    if not killer or not hrp then return end

    local dist = AutoBlock.Distance(hrp, myHRP)
    local hum = killer:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    for _, track in pairs(hum:GetPlayingAnimationTracks()) do
        if track.IsPlaying and track.Animation then
            local id = track.Animation.AnimationId:match("%d+")
            if not id then continue end

            if AutoBlock.ThrowAnimations[id] and dist <= AutoBlock.ThrowDistance then
                if AutoBlock.IsFacing(hrp, myHRP) then
                    AutoBlock.ExecuteBlock()
                    return true
                end
            end

            if AutoBlock.ChargeAnimations[id] and dist <= AutoBlock.MinDistance then
                if AutoBlock.IsFacing(hrp, myHRP) then
                    AutoBlock.ExecuteBlock()
                    return true
                end
            end
        end
    end
end

--// ================= SOUND CHECK =================

function AutoBlock.CheckSound(myHRP)
    local hrp = AutoBlock.KillerHRP
    if not hrp then return end

    local dist = AutoBlock.Distance(hrp, myHRP)

    for sound, t in pairs(AutoBlock.ActiveSounds) do
        if tick() - t > 1 then
            AutoBlock.ActiveSounds[sound] = nil
            continue
        end

        if dist <= AutoBlock.MinDistance and AutoBlock.IsFacing(hrp, myHRP) then
            AutoBlock.ExecuteBlock()
            return true
        end
    end
end

--// ================= MAIN =================

function AutoBlock.Start()
    AutoBlock.Enabled = true
    AutoBlock.UpdateKiller()

    if AutoBlock.Connection then
        AutoBlock.Connection:Disconnect()
    end

    AutoBlock.Connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not AutoBlock.Enabled then return end
        if not Player.Character then return end

        if GetPlayerStyle and GetPlayerStyle() ~= "fighter" then return end

        local myHRP = AutoBlock.GetHRP(Player.Character)
        if not myHRP then return end

        if not AutoBlock.CurrentKiller then
            AutoBlock.UpdateKiller()
            return
        end

        if AutoBlock.CheckAnimation(myHRP) then return end
        if AutoBlock.CheckSound(myHRP) then return end
    end)
end

function AutoBlock.Stop()
    AutoBlock.Enabled = false

    if AutoBlock.Connection then
        AutoBlock.Connection:Disconnect()
        AutoBlock.Connection = nil
    end

    for _, conns in pairs(AutoBlock.SoundHooks) do
        for _, c in pairs(conns) do
            if c then c:Disconnect() end
        end
    end

    AutoBlock.SoundHooks = {}
    AutoBlock.ActiveSounds = {}
end

Auto:Section({ Title = "Auto Parry", Icon = "swords" })

--// ================= UI =================

Auto:Slider({
    Title = "Block Attack Range",
    Desc = "Distance for normal attacks",
    Value = { Min = 5, Max = 40, Default = 20 },
    Callback = function(v)
        Settings.Auto.Parry = v
        AutoBlock.SetMinDistance = v
        AutoBlock.MinDistance = v
    end
})

Auto:Slider({
    Title = "Block Throw Range",
    Desc = "Distance for throw attacks",
    Value = { Min = 20, Max = 120, Default = 80 },
    Callback = function(v)
        AutoBlock.ThrowDistance = v
    end
})

--[[
Auto:Slider({
    Title = "Prediction Delay",
    Desc = "Block before hit (lower = faster)",
    Value = { Min = 0, Max = 0.2, Default = 0.08 },
    Callback = function(v)
        AutoBlock.PredictionDelay = v
    end
}) 
]]

Auto:Toggle({
    Title = "Auto Block",
    Desc = "Automatically block attacks",
    Value = false,
    Callback = function(v)
        if v then
            AutoBlock.Start()
        else
            AutoBlock.Stop()
        end
    end
})


--[[
local attackAnimIds = {
    "rbxassetid://70869035406359",
    "rbxassetid://106673226682917",
    "rbxassetid://112503015929213",
    "rbxassetid://120428956410756",
    "rbxassetid://102810363618918",
    "rbxassetid://133752270724243",
    "rbxassetid://71147082224885"
}

local parryConnection = nil

local function isAttackAnimation(track)
    if not track or not track.Animation then return false end
    local id = track.Animation.AnimationId
    for _, aid in ipairs(attackAnimIds) do
        if id == aid then return true end
    end
    return false
end

local function getParryRange(track)
    if track and track.Animation.AnimationId == "rbxassetid://133752270724243" then
        return Settings.Ranges.PullAttack or 50
    end
    return Settings.Ranges.BasicAttack or 30
end

Auto:Slider({
    Title = "Main Attacks Range",
    Desc = "Range for main attacks",
    Value = { Min = 10, Max = 50, Default = 30 },
    Callback = function(v)
        Settings.Ranges.BasicAttack = v
    end
})

Auto:Slider({
    Title = "Ennard Pull Attack Range",
    Desc = "Range for pull attack",
    Value = { Min = 10, Max = 75, Default = 50 },
    Callback = function(v)
        Settings.Ranges.PullAttack = v
    end
})

Auto:Toggle({
    Title = "Auto Parry",
    Desc = "Automatically Attempts To Parry Killer Attacks.",
    Value = false,
    Callback = function(v)
        Settings.Auto.AutoParry = v
        if Settings.Auto.AutoParry then
            --ShowNotification("Auto Parry", "Enabled.", 2)
            parryConnection = RunService.Heartbeat:Connect(function()
                if not Settings.Auto.AutoParry then return end
                local lp = Player
                local char = lp.Character
                if not char then return end
                local myRoot = char:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr == lp then continue end
                    local pchar = plr.Character
                    if not pchar then continue end
                    local attackerRoot = pchar:FindFirstChild("HumanoidRootPart")
                    if not attackerRoot then continue end
                    local diff = attackerRoot.Position - myRoot.Position
                    local range = getParryRange(nil)
                    if diff:Dot(diff) > range * range then continue end
                    local hum = pchar:FindFirstChildOfClass("Humanoid")
                    if not hum then continue end
                    local animator = hum:FindFirstChildOfClass("Animator")
                    if not animator then continue end
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if track.IsPlaying and isAttackAnimation(track) then
                            local actualRange = getParryRange(track)
                            if diff:Dot(diff) > actualRange * actualRange then continue end
                            local directionToMe = diff.Unit
                            if attackerRoot.CFrame.LookVector:Dot(directionToMe) < 0.5 then
                                continue
                            end
                            local args = {
                                buffer.fromstring("\a"),
                                buffer.fromstring("\254\001\000\254\002\000\006\aAbility\001\002")
                            }
                            ReplicatedStorage:WaitForChild("Modules")
                                :WaitForChild("Warp"):WaitForChild("Index")
                                :WaitForChild("Event"):WaitForChild("Reliable"):FireServer(unpack(args))
                            break
                        end
                    end
                end
            end)
        else
            --ShowNotification("Auto Parry", "Disabled.", 2)
            if parryConnection then
                parryConnection:Disconnect()
                parryConnection = nil
            end
        end
    end
})
--]]

--// Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// UI Section (make sure Auto exists)
Auto:Section({ Title = "Infinite Stats", Icon = "user" })

--// Shared function
local function IsPlayerInGame()
    local playersFolder = workspace:FindFirstChild("PLAYERS")
    if not playersFolder then return false end

    local alive = playersFolder:FindFirstChild("ALIVE")
    if alive and alive:FindFirstChild(Player.Name) then
        return true
    end

    local killer = playersFolder:FindFirstChild("KILLER")
    if killer and killer:FindFirstChild(Player.Name) then
        return true
    end

    return false
end

--// Movement handler (prevents conflict)
local function HandleMovement(character, isMobile)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if isMobile then
        if humanoid.MoveDirection.Magnitude > 0 then
            humanoid.WalkSpeed = 24
        else
            humanoid.WalkSpeed = 12
        end
    else
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            humanoid.WalkSpeed = 25
        else
            humanoid.WalkSpeed = 12
        end
    end
end

--// Infinity Stamina
local InfinityStamina = {
    Enabled = false,
    Connection = nil,
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
}

function InfinityStamina.Start()
    InfinityStamina.Enabled = true

    if InfinityStamina.Connection then
        InfinityStamina.Connection:Disconnect()
    end

    InfinityStamina.Connection = RunService.Heartbeat:Connect(function()
        if not InfinityStamina.Enabled then return end
        if not Player.Character then return end
        if not IsPlayerInGame() then return end

        -- Set stamina (only works if game uses attributes)
        Player.Character:SetAttribute("Stamina", 100)

        -- Movement
        HandleMovement(Player.Character, InfinityStamina.IsMobile)
    end)
end

function InfinityStamina.Stop()
    InfinityStamina.Enabled = false

    if InfinityStamina.Connection then
        InfinityStamina.Connection:Disconnect()
        InfinityStamina.Connection = nil
    end

    if Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 12
        end
    end
end

--// Infinity Dodges
local InfinityDodges = {
    Enabled = false,
    Connection = nil,
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
}

function InfinityDodges.Start()
    InfinityDodges.Enabled = true

    if InfinityDodges.Connection then
        InfinityDodges.Connection:Disconnect()
    end

    InfinityDodges.Connection = RunService.Heartbeat:Connect(function()
        if not InfinityDodges.Enabled then return end
        if not Player.Character then return end
        if not IsPlayerInGame() then return end

        -- Set dodges (only works if game uses attributes)
        Player.Character:SetAttribute("Dodges", 100)

        -- Movement (shared to avoid conflict)
        HandleMovement(Player.Character, InfinityDodges.IsMobile)
    end)
end

function InfinityDodges.Stop()
    InfinityDodges.Enabled = false

    if InfinityDodges.Connection then
        InfinityDodges.Connection:Disconnect()
        InfinityDodges.Connection = nil
    end

    if Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 12
        end
    end
end

Auto:Toggle({
    Title = "Infinite Stamina",
    Desc = "Set stamina to Infinite",
    Value = false,
    Callback = function(v)
        if v then
            InfinityStamina.Start()
        else
            InfinityStamina.Stop()
        end
    end
})

--// UI Toggles
Auto:Toggle({
    Title = "Infinite Dodges",
    Desc = "Set Dodges to Infinite (Visual)",
    Value = false,
    Callback = function(v)
        if v then
            InfinityDodges.Start()
        else
            InfinityDodges.Stop()
        end
    end
})

Auto:Section({ Title = "Auto Miscellaneous", Icon = "crown" })

local AntiTrap = {
    Enabled = false,
    BlockParts = {},
    Connections = {}
}

function AntiTrap.IsPlayerAlive()
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return false end
    
    local alive = players:FindFirstChild("ALIVE")
    if alive and alive:FindFirstChild(Player.Name) then
        return true
    end
    
    return false
end

function AntiTrap.AddBlockPart(trap)
    if not AntiTrap.IsPlayerAlive() then return end
    if AntiTrap.BlockParts[trap] then return end
    
    local cylinders = {}
    for _, child in ipairs(trap:GetDescendants()) do
        if child:IsA("BasePart") and child.Name:match("Cylinder") then
            table.insert(cylinders, child)
        end
    end
    
    if #cylinders == 0 then return end
    
    local centerPos = Vector3.new(0, 0, 0)
    local minY = math.huge
    for _, cyl in ipairs(cylinders) do
        centerPos = centerPos + cyl.Position
        minY = math.min(minY, cyl.Position.Y)
    end
    centerPos = centerPos / #cylinders
    
    local blockPart = Instance.new("Part")
    blockPart.Name = "AntiTrapBlock"
    blockPart.Size = Vector3.new(10, 6, 10)
    blockPart.Position = Vector3.new(centerPos.X, minY + 3, centerPos.Z)
    blockPart.Anchored = true
    blockPart.CanCollide = true
    blockPart.Transparency = 1
    blockPart.Parent = workspace
    
    AntiTrap.BlockParts[trap] = blockPart
end

function AntiTrap.RemoveBlockPart(trap)
    local blockPart = AntiTrap.BlockParts[trap]
    if blockPart then
        blockPart:Destroy()
        AntiTrap.BlockParts[trap] = nil
    end
end

function AntiTrap.Start()
    AntiTrap.Enabled = true
    
    local ignore = workspace:FindFirstChild("IGNORE")
    
    if ignore then
        for _, obj in ipairs(ignore:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:match("Cylinder%.%d+") then
                local trapModel = obj.Parent
                if trapModel and trapModel:IsA("Model") and not AntiTrap.BlockParts[trapModel] then
                    AntiTrap.AddBlockPart(trapModel)
                end
            end
        end
    end
    
    local addConn = workspace.DescendantAdded:Connect(function(v)
        if v:IsA("BasePart") and v.Name:match("Cylinder%.%d+") and AntiTrap.Enabled then
            if v:IsDescendantOf(workspace:FindFirstChild("IGNORE")) then
                local trapModel = v.Parent
                if trapModel and trapModel:IsA("Model") and not AntiTrap.BlockParts[trapModel] then
                    task.wait(0.2)
                    AntiTrap.AddBlockPart(trapModel)
                end
            end
        end
    end)
    
    local removeConn = workspace.DescendantRemoving:Connect(function(v)
        if AntiTrap.BlockParts[v] then
            AntiTrap.RemoveBlockPart(v)
        end
    end)
    
    local playerCheckConn = RunService.Heartbeat:Connect(function()
        if not AntiTrap.Enabled then return end
        
        if not AntiTrap.IsPlayerAlive() then
            for trap, blockPart in pairs(AntiTrap.BlockParts) do
                blockPart:Destroy()
            end
            AntiTrap.BlockParts = {}
        end
    end)
    
    table.insert(AntiTrap.Connections, addConn)
    table.insert(AntiTrap.Connections, removeConn)
    table.insert(AntiTrap.Connections, playerCheckConn)
end

function AntiTrap.Stop()
    AntiTrap.Enabled = false
    
    for trap, blockPart in pairs(AntiTrap.BlockParts) do
        blockPart:Destroy()
    end
    AntiTrap.BlockParts = {}
    
    for _, conn in ipairs(AntiTrap.Connections) do
        conn:Disconnect()
    end
    AntiTrap.Connections = {}
end

Auto:Toggle({
    Title = "Anti Trap (Springtrap)",
    Desc = "Blocks trap cylinders automatically",
    Value = false,
    Callback = function(v)
        if v then
            AntiTrap.Start()
        else
            AntiTrap.Stop()
        end
    end
})
-- Toggle
local shakingLoop
local guiConnection

local AutoShake = {
    Enabled = false,
    Connection = nil,
    ShakeConnection = nil,
    ShakeTime = 0,
    ShakeSpeed = 55,
    ShakeIntensityX = 0.15,
    ShakeIntensityY = 0.35
}

function AutoShake.Start()
    AutoShake.Enabled = true
    
    if AutoShake.Connection then
        AutoShake.Connection:Disconnect()
    end
    
    AutoShake.Connection = RunService.Heartbeat:Connect(function()
        if not AutoShake.Enabled then return end
        
        local playerGui = Player:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        local wireyesUI = playerGui:FindFirstChild("WireyesUI")
        
        if wireyesUI and not AutoShake.ShakeConnection then
            AutoShake.ShakeTime = 0
            
            AutoShake.ShakeConnection = RunService.RenderStepped:Connect(function(dt)
                if not AutoShake.Enabled or not wireyesUI or not wireyesUI.Parent then
                    if AutoShake.ShakeConnection then
                        AutoShake.ShakeConnection:Disconnect()
                        AutoShake.ShakeConnection = nil
                    end
                    return
                end
                
                AutoShake.ShakeTime = AutoShake.ShakeTime + dt
                
                local randomFactor = (math.random() - 0.5) * 0.3
                local shakeX = (math.sin(AutoShake.ShakeTime * AutoShake.ShakeSpeed) + randomFactor) * AutoShake.ShakeIntensityX
                local shakeY = (math.sin(AutoShake.ShakeTime * AutoShake.ShakeSpeed * 0.8) + randomFactor * 1.5) * AutoShake.ShakeIntensityY
                
                local rotationShake = (math.sin(AutoShake.ShakeTime * AutoShake.ShakeSpeed * 1.3) + randomFactor) * 0.05
                
                local camera = workspace.CurrentCamera
                camera.CFrame = camera.CFrame * CFrame.new(shakeX, shakeY, 0) * CFrame.Angles(0, rotationShake, 0)
            end)
        elseif not wireyesUI and AutoShake.ShakeConnection then
            AutoShake.ShakeConnection:Disconnect()
            AutoShake.ShakeConnection = nil
            AutoShake.ShakeTime = 0
        end
    end)
end

function AutoShake.Stop()
    AutoShake.Enabled = false
    
    if AutoShake.Connection then
        AutoShake.Connection:Disconnect()
        AutoShake.Connection = nil
    end
    
    if AutoShake.ShakeConnection then
        AutoShake.ShakeConnection:Disconnect()
        AutoShake.ShakeConnection = nil
    end
    
    AutoShake.ShakeTime = 0
end

Auto:Toggle({
    Title = "Auto Shaking (Legit, Minion)",
    Desc = "Automatically Shaking to get the minion out of your face",
    Value = false,
    Callback = function(v)
        if v then
            AutoShake.Start()
        else
            AutoShake.Stop()
        end
    end
})

Auto:Toggle({
    Title = "Auto Shaking (Not Legit, Minion)",
    Desc = "Automatically Shaking to get the minion out of your face",
    Value = false,
    Callback = function(v)
        Settings.Auto.Shaking = v
        
        local player = game:GetService("Players").LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")

        if v then
            if shakingLoop then return end
            
            -- 🔥 ดัก GUI โผล่
            guiConnection = playerGui.ChildAdded:Connect(function(child)
                if child.Name == "WireyesUI" then
                    local remote = child:WaitForChild("WireyesClient", 2)
                    if remote and remote:FindFirstChild("WireyesEvent") then
                        remote.WireyesEvent:FireServer(
                            "TakeOff",
                            1775926755.247102
                        )
                    end
                end
            end)

            -- 🔁 Loop ปกติ (กันพลาด)
            shakingLoop = task.spawn(function()
                while Settings.Auto.Shake do
                    local gui = playerGui:FindFirstChild("WireyesUI")
                    
                    if gui then
                        local remote = gui:FindFirstChild("WireyesClient")
                        if remote and remote:FindFirstChild("WireyesEvent") then
                            remote.WireyesEvent:FireServer(
                                "TakeOff",
                                1775926755.247102
                            )
                        end
                    end

                    task.wait(0.3)
                end
                
                shakingLoop = nil
            end)

        else
            -- ❌ ปิดระบบ
            if guiConnection then
                guiConnection:Disconnect()
                guiConnection = nil
            end
        end
    end
})

Auto:Toggle({
    Title = "Auto Escape (Not Legit)",
    Desc = "Automatically teleport to Escape",
    Value = false,
    Callback = function(v) 
        Settings.Auto.Escape = v
        
        if v then
            task.spawn(function()
                local player = game:GetService("Players").LocalPlayer
                local teleported = false

                while Settings.Auto.Escape do
                    task.wait(1.25) -- เช็คทุกๆ 0.5 วินาทีก็พอ ไม่ต้องทุกเฟรม

                    if teleported then continue end

                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")

                    -- ตรวจสอบเงื่อนไขการหลบหนี
                    local canEscape = workspace.GAME:FindFirstChild("CAN_ESCAPE")
                    if not root or not (canEscape and canEscape.Value) then continue end
                    if char.Parent ~= workspace.PLAYERS.ALIVE then continue end

                    local map = workspace.MAPS:FindFirstChild("GAME MAP")
                    local escapes = map and map:FindFirstChild("Escapes")

                    if escapes then
                        for _, part in pairs(escapes:GetChildren()) do
                            local highlight = part:FindFirstChildOfClass("Highlight")
                            
                            -- เช็คว่าทางออกเปิดใช้งานหรือยัง
                            if part:IsA("BasePart") and part:GetAttribute("Enabled") and (highlight and highlight.Enabled) then
                                teleported = true

                                -- เริ่มกระบวนการวาร์ป
                                root.Anchored = true
                                -- ยกตัวขึ้นเล็กน้อยเพื่อป้องกันการติดพื้น (+3 studs)
                                char:SetPrimaryPartCFrame(part.CFrame * CFrame.new(0, 3, 0))

                                task.wait(1) -- รอให้ Server รับข้อมูลตำแหน่งใหม่
                                if root then root.Anchored = false end

                                -- คูลดาวน์ 10 วินาทีป้องกันการวาร์ปซ้ำซ้อน
                                task.delay(10, function()
                                    teleported = false
                                end)
                                
                                break 
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ESP Tab
EspTab:Section({ Title = "Player ESP", Icon = "user" })

EspTab:Toggle({
    Title = "Survivor",
    Desc = "Displays ESP for survivors",
    Value = false,
    Callback = function(v)
        Settings.ESP.Survivor = v
        if not v then clearAllESP() end
    end
})

EspTab:Toggle({
    Title = "Killer",
    Desc = "Displays ESP for killers",
    Value = false,
    Callback = function(v)
        Settings.ESP.Killer = v
        if not v then clearAllESP() end
    end
})

EspTab:Toggle({
    Title = "Lobby",
    Desc = "Displays ESP for players in the lobby",
    Value = false,
    Callback = function(v)
        Settings.ESP.Lobby = v
        if not v then clearAllESP() end
    end
})


EspTab:Section({ Title = "Hazard ESP", Icon = "sword" })

EspTab:Toggle({
    Title = "Axe (Springtrap)",
    Desc = "Displays ESP for Axe hazards in Springtrap encounters",
    Value = false,
    Callback = function(v)
        Settings.ESP.Axe = v
        if not v then clearAllESP() end
    end
})

EspTab:Toggle({
    Title = "Trap (Springtrap)",
    Desc = "Displays ESP for traps placed by Springtrap",
    Value = false,
    Callback = function(v)
        Settings.ESP.Trap = v
        if not v then clearAllESP() end
    end
})

EspTab:Toggle({
    Title = "Minion (Doppelganger)",
    Desc = "Displays ESP for Doppelganger minions",
    Value = false,
    Callback = function(v)
        Settings.ESP.Minion = v
        if not v then clearAllESP() end
    end
})


EspTab:Section({ Title = "Object ESP", Icon = "package" })

EspTab:Toggle({
    Title = "Generator",
    Desc = "Displays ESP for generators",
    Value = false,
    Callback = function(v)
        Settings.ESP.Generator = v
        if not v then clearAllESP() end
    end
})

EspTab:Toggle({
    Title = "FuseBox",
    Desc = "Displays ESP for fuse boxes",
    Value = false,
    Callback = function(v)
        Settings.ESP.FuseBox = v
        if not v then clearAllESP() end
    end
})

EspTab:Toggle({
    Title = "Batteries",
    Desc = "Displays ESP for battery items",
    Value = false,
    Callback = function(v)
        Settings.ESP.Batteries = v
        if not v then clearAllESP() end
    end
})


EspTab:Section({ Title = "Setting ESP", Icon = "settings" })

EspTab:Toggle({
    Title = "Show Name",
    Desc = "Displays entity names in ESP",
    Value = true,
    Callback = function(v)
        Settings.Setting.Name = v
    end
})

EspTab:Toggle({
    Title = "Show Class",
    Desc = "Displays entity class information",
    Value = false,
    Callback = function(v)
        Settings.Setting.Class = v
    end
})

EspTab:Toggle({
    Title = "Show Health",
    Desc = "Displays health information of entities",
    Value = true,
    Callback = function(v)
        Settings.Setting.Health = v
    end
})

EspTab:Toggle({
    Title = "Show Distance",
    Desc = "Displays distance to entities",
    Value = true,
    Callback = function(v)
        Settings.Setting.Distance = v
    end
})

EspTab:Toggle({
    Title = "Show Highlights",
    Desc = "Enables visual highlight overlay for entities",
    Value = true,
    Callback = function(v)
        Settings.Setting.Highlight = v
        if not v then clearAllESP() end
    end
})

-- Information Tab
if not ui then ui = {} end
if not ui.Creator then ui.Creator = {} end
InfoTab:Divider()
InfoTab:Section({ Title = "Lasted Update", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()

InfoTab:Paragraph({
    Title = "Update: 04/18/2026 | Time: 02:33",
    Desc = "- [ Fixed ] Esp Core \n- [ Added ] Anti Trap \n- [ Added ] Auto Parry \n- [ Added ] PXPrompt Instant \n- [ Added ] Auto Shaking NL/L \n- [ Added ] Auto Generator Instant \n- [ Added ] Infinite Stamina/Dodges \n- [ Reworked ] Auto Escape",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
})

InfoTab:Divider()
InfoTab:Section({ Title = "Discord Server", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()

ui.Creator.Request = function(requestData)
    local HttpService = game:GetService("HttpService")
    local success, result = pcall(function()
        if HttpService.RequestAsync then
            local response = HttpService:RequestAsync({
                Url = requestData.Url,
                Method = requestData.Method or "GET",
                Headers = requestData.Headers or {}
            })
            return { Body = response.Body, StatusCode = response.StatusCode, Success = response.Success }
        else
            local body = HttpService:GetAsync(requestData.Url)
            return { Body = body, StatusCode = 200, Success = true }
        end
    end)
    return success and result or error("HTTP Request failed")
end

local InviteCode = "jWNDPNMmyB"
local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local function LoadDiscordInfo()
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({
            Url = DiscordAPI,
            Method = "GET",
            Headers = { ["User-Agent"] = "RobloxBot/1.0", ["Accept"] = "application/json" }
        }).Body)
    end)

    if success and result and result.guild then
        local DiscordInfo = InfoTab:Paragraph({
            Title = result.guild.name,
            Desc = ' <font color="#52525b">●</font> Member Count : ' .. tostring(result.approximate_member_count) ..
                '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(result.approximate_presence_count),
            Image = "https://cdn.discordapp.com/icons/" .. result.guild.id .. "/" .. result.guild.icon .. ".png?size=1024",
            ImageSize = 42,
        })

        InfoTab:Button({
            Title = "Update Info",
            Callback = function()
                local updated, updatedResult = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(ui.Creator.Request({ Url = DiscordAPI, Method = "GET" }).Body)
                end)
                if updated and updatedResult.guild then
                    DiscordInfo:SetDesc(' <font color="#52525b">●</font> Member Count : ' .. tostring(updatedResult.approximate_member_count) .. '\n <font color="#16a34a">●</font> Online Count : ' .. tostring(updatedResult.approximate_presence_count))
                end
            end
        })

        InfoTab:Button({
            Title = "Copy Discord Invite",
            Callback = function() setclipboard("https://discord.gg/" .. InviteCode) end
        })
    end
end

LoadDiscordInfo()

InfoTab:Divider()
InfoTab:Section({ Title = "DYHUB Information", TextXAlignment = "Center", TextSize = 17 })
InfoTab:Divider()

InfoTab:Paragraph({
    Title = "Main Owner",
    Desc = "@dyumraisgoodguy#8888",
    Image = "rbxassetid://119789418015420",
    ImageSize = 30,
})

InfoTab:Paragraph({
    Title = "Social",
    Desc = "Copy link social media for follow!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = {{
        Icon = "copy",
        Title = "Copy Link",
        Callback = function() setclipboard("https://guns.lol/DYHUB") end,
    }}
})

InfoTab:Paragraph({
    Title = "Discord",
    Desc = "Join our discord for more scripts!",
    Image = "rbxassetid://104487529937663",
    ImageSize = 30,
    Buttons = {{
        Icon = "copy",
        Title = "Copy Link",
        Callback = function() setclipboard("https://discord.gg/jWNDPNMmyB") end,
    }}
})
