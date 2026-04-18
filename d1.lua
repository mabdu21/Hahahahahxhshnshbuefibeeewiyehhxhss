if _G.BBNScriptLoaded then
    warn("[BBN] Script was already executed!")
    return
end
_G.BBNScriptLoaded = true


local UI_URL = 'https://pastebin.com/raw/0NPu0sy6'
local Menu = loadstring(game:HttpGet(UI_URL))()


local ConfigWasLoaded = false
if Menu.Config and Menu.Config.setCurrentConfig then
    Menu.Config.setCurrentConfig("BBNDYHUB")
end
if Menu.Config and Menu.Config.loadConfig then
    ConfigWasLoaded = Menu.Config.loadConfig("BBNDYHUB")
    warn("[BBN] Config loaded: " .. tostring(ConfigWasLoaded))
else
    warn("[BBN] Config system not available in loaded UI version!")
end


local DefaultAccentColor = Color3.fromHex("#FF0000")
if ConfigWasLoaded and Menu.Config and Menu.Config.getConfigValue then
    local savedColorHex = Menu.Config.getConfigValue("UIColor")
    if savedColorHex and type(savedColorHex) == "string" then
        local success, color = pcall(function()
            return Color3.fromHex(savedColorHex)
        end)
        if success and color then
            Menu.Accent = color
        end
    end
end


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer


function SafeNotify(content, delay)
    if Menu.Config and Menu.Config.isLoading and Menu.Config.isLoading() then
        return
    end
    if Menu.Accent then
        local accentHex = "#" .. Menu.Accent:ToHex():upper()
        content = content:gsub("#FF0000", accentHex)
        content = content:gsub("#FF0000", accentHex)
    end
    Menu.Notify(content, delay)
end


local AutoGenerator = {
    Enabled = false,
    Delay = 5,
    Connection = nil,
    LastFireTime = 0
}

function AutoGenerator.Start()
    AutoGenerator.Enabled = true
    AutoGenerator.LastFireTime = 0
    SafeNotify("<font color='#FF0000'>[ Auto Generator ]</font> Enabled!", 2)
    
    if AutoGenerator.Connection then
        AutoGenerator.Connection:Disconnect()
    end
    
    AutoGenerator.Connection = RunService.RenderStepped:Connect(function()
        if not AutoGenerator.Enabled then return end
        
        local plr = Players.LocalPlayer
        if plr.PlayerGui:FindFirstChild("Gen") then
            local currentTime = tick()
            
            
            if AutoGenerator.LastFireTime == 0 then
                AutoGenerator.LastFireTime = currentTime
            end
            
            
            if currentTime - AutoGenerator.LastFireTime >= AutoGenerator.Delay then
                plr.PlayerGui.Gen.GeneratorMain.Event:FireServer(true)
                AutoGenerator.LastFireTime = currentTime
            end
        else
            
            AutoGenerator.LastFireTime = 0
        end
    end)
end

function AutoGenerator.Stop()
    AutoGenerator.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Auto Generator ]</font> Disabled!", 2)
    
    if AutoGenerator.Connection then
        AutoGenerator.Connection:Disconnect()
        AutoGenerator.Connection = nil
    end
end

function AutoGenerator.SetDelay(delay)
    AutoGenerator.Delay = delay
end


local AutoBarricade = {
    Enabled = false,
    Connection = nil
}

function AutoBarricade.Start()
    AutoBarricade.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Auto Barricade ]</font> Enabled!", 2)
    
    if AutoBarricade.Connection then
        AutoBarricade.Connection:Disconnect()
    end
    
    local player = Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui")
    
    AutoBarricade.Connection = RunService.RenderStepped:Connect(function()
        if not AutoBarricade.Enabled then return end
        
        local dot = gui:FindFirstChild("Dot")
        if dot and dot:IsA("ScreenGui") then
            local container = dot:FindFirstChild("Container")
            if container then
                local frame = container:FindFirstChild("Frame")
                if frame and frame:IsA("GuiObject") then
                    if not dot.Enabled then
                        dot:Destroy()
                        return
                    end
                    
                    frame.AnchorPoint = Vector2.new(0.5, 0.5)
                    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
                end
            end
        end
    end)
end

function AutoBarricade.Stop()
    AutoBarricade.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Auto Barricade ]</font> Disabled!", 2)
    
    if AutoBarricade.Connection then
        AutoBarricade.Connection:Disconnect()
        AutoBarricade.Connection = nil
    end
end


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
    SafeNotify("<font color='#FF0000'>[ Auto Shake ]</font> Enabled!", 2)
    
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
    SafeNotify("<font color='#FF0000'>[ Auto Shake ]</font> Disabled!", 2)
    
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
    SafeNotify("<font color='#FF0000'>[ Anti Springtrap Traps ]</font> Enabled!", 2)
    
    
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
            
            if v:IsDescendantOf(workspace.IGNORE) then
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
    SafeNotify("<font color='#FF0000'>[ Anti Springtrap Traps ]</font> Disabled!", 2)
    
    
    for trap, blockPart in pairs(AntiTrap.BlockParts) do
        blockPart:Destroy()
    end
    AntiTrap.BlockParts = {}
    
    
    for _, conn in ipairs(AntiTrap.Connections) do
        conn:Disconnect()
    end
    AntiTrap.Connections = {}
end


local KeybindTracker = {
    binds = {},
    ui = nil,
    styleRequirements = {
        ["Tazer Aimbot"] = "guard",
        ["Axe Aimbot"] = "springtrap",
        ["Mimic Grab"] = "mimic",
        ["Mimic Stab"] = "mimic",
        ["Swing Aimbot"] = "fighter",
        ["Ennard Grab"] = "ennard",
        ["Ennard Stab"] = "ennard",
        ["Auto Block"] = "fighter"
    },
    lastStyle = nil
}

function KeybindTracker.ShouldShowBind(name)
    local requiredStyle = KeybindTracker.styleRequirements[name]
    if not requiredStyle then return true end
    local currentStyle = GetPlayerStyle()
    return currentStyle == requiredStyle
end

function KeybindTracker.Update(name, enabled, keyGetter)
    if enabled then
        KeybindTracker.binds[name] = keyGetter
        if KeybindTracker.ui and KeybindTracker.ShouldShowBind(name) then
            local key = keyGetter and keyGetter() or nil
            if key then
                local keyName = tostring(key):gsub("Enum.KeyCode.", "")
                KeybindTracker.ui.Add(name, "[" .. keyName .. "]")
            end
        end
    else
        KeybindTracker.binds[name] = nil
        if KeybindTracker.ui then
            KeybindTracker.ui.Remove(name)
        end
    end
end

function KeybindTracker.RefreshAll()
    if not KeybindTracker.ui then return end
    for name, _ in pairs(KeybindTracker.binds) do
        KeybindTracker.ui.Remove(name)
    end
    for name, keyGetter in pairs(KeybindTracker.binds) do
        if KeybindTracker.ShouldShowBind(name) then
            local key = keyGetter and keyGetter() or nil
            if key then
                local keyName = tostring(key):gsub("Enum.KeyCode.", "")
                KeybindTracker.ui.Add(name, "[" .. keyName .. "]")
            end
        end
    end
end

function KeybindTracker.Refresh(name)
    if not KeybindTracker.ui then return end
    local keyGetter = KeybindTracker.binds[name]
    if keyGetter and KeybindTracker.ShouldShowBind(name) then
        local key = keyGetter()
        if key then
            local keyName = tostring(key):gsub("Enum.KeyCode.", "")
            KeybindTracker.ui.Add(name, "[" .. keyName .. "]")
        end
    else
        KeybindTracker.ui.Remove(name)
    end
end

function KeybindTracker.CheckStyleChange()
    local currentStyle = GetPlayerStyle()
    if currentStyle ~= KeybindTracker.lastStyle then
        KeybindTracker.lastStyle = currentStyle
        KeybindTracker.RefreshAll()
    end
end


local InfinityStamina = {
    Enabled = false,
    Connection = nil,
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
}

function InfinityStamina.IsInGame()
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return false end
    
    
    local alive = players:FindFirstChild("ALIVE")
    if alive and alive:FindFirstChild(Player.Name) then
        return true
    end
    
    
    local killer = players:FindFirstChild("KILLER")
    if killer and killer:FindFirstChild(Player.Name) then
        return true
    end
    
    return false
end

function InfinityStamina.Start()
    InfinityStamina.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Infinity Stamina ]</font> Enabled!", 2)
    
    if InfinityStamina.Connection then
        InfinityStamina.Connection:Disconnect()
    end
    
    
    InfinityStamina.Connection = RunService.Heartbeat:Connect(function()
        if not InfinityStamina.Enabled then return end
        if not Player.Character then return end
        
        if InfinityStamina.IsInGame() then
            
            Player.Character:SetAttribute("Stamina", 100)
            
            
            if InfinityStamina.IsMobile then
                
                local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    Player.Character:SetAttribute("WalkSpeed", 24)
                else
                    Player.Character:SetAttribute("WalkSpeed", 12)
                end
            else
                
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                    Player.Character:SetAttribute("WalkSpeed", 25)
                else
                    Player.Character:SetAttribute("WalkSpeed", 12)
                end
            end
        end
    end)
end

function InfinityStamina.Stop()
    InfinityStamina.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Infinity Stamina ]</font> Disabled!", 2)
    
    if InfinityStamina.Connection then
        InfinityStamina.Connection:Disconnect()
        InfinityStamina.Connection = nil
    end
    
    
    if Player.Character then
        Player.Character:SetAttribute("WalkSpeed", 12)
    end
end


local TazerAimbot = {
    Enabled = false,
    Prediction = 2,
    Walls = true,  
    Aiming = false,
    CurrentTarget = nil,
    AimConnection = nil,
    IdleAnimationId = "138208219199182",
    ShotAnimationId = "130467442785091",
    WalkAnimations = {
        ["127042414505048"] = true,
        ["79148485942313"] = true,
        ["113176542209969"] = true,
        ["111983226830519"] = true,
        ["133180895948563"] = true,
        ["120326377077980"] = true,
        ["83351889483571"] = true,
        ["136548794483974"] = true
    },
    MaxDistance = 1000,
    LastAnimationState = false,
    ShotFired = false,  
    KeybindActive = false,
    CurrentKey = Enum.KeyCode.X
}

function TazerAimbot.IsShotAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == TazerAimbot.ShotAnimationId then
                return true
            end
        end
    end
    
    return false
end

function TazerAimbot.IsAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            if animId == TazerAimbot.IdleAnimationId then
                return true
            end
            
            if TazerAimbot.WalkAnimations[animId] then
                return true
            end
        end
    end
    
    return false
end

function TazerAimbot.GetClosestKiller()
    local closestKiller = nil
    local shortestDistance = math.huge
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return nil end
    
    local killers = players:FindFirstChild("KILLER")
    if not killers then return nil end
    
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:IsA("Model") then
            local humanoid = killer:FindFirstChildOfClass("Humanoid")
            local rootPart = killer:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                if distance < TazerAimbot.MaxDistance and distance < shortestDistance then
                    shortestDistance = distance
                    closestKiller = killer
                end
            end
        end
    end
    
    return closestKiller
end

function TazerAimbot.IsTargetVisible(targetPart)
    if TazerAimbot.Walls then
        return true  
    end
    
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    
    local direction = (targetPart.Position - localRoot.Position)
    local ray = Ray.new(localRoot.Position, direction)
    
    local ignoreList = {Player.Character}
    if TazerAimbot.CurrentTarget then
        table.insert(ignoreList, TazerAimbot.CurrentTarget)
    end
    
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    
    if not hit then
        return true
    end
    
    if TazerAimbot.CurrentTarget and hit:IsDescendantOf(TazerAimbot.CurrentTarget) then
        return true
    end
    
    
    if hit.Transparency >= 0.9 or not hit.CanCollide then
        return true
    end
    
    return false
end

function TazerAimbot.AimTick()
    if not TazerAimbot.Aiming then return end
    
    if not TazerAimbot.CurrentTarget or not TazerAimbot.CurrentTarget.Parent then
        TazerAimbot.CurrentTarget = TazerAimbot.GetClosestKiller()
    end
    
    if TazerAimbot.CurrentTarget and TazerAimbot.CurrentTarget:FindFirstChild("HumanoidRootPart") then
        local targetPart = TazerAimbot.CurrentTarget.HumanoidRootPart
        
        
        if not TazerAimbot.IsTargetVisible(targetPart) then
            return  
        end
        
        local camera = workspace.CurrentCamera
        
        
        local targetPosition = targetPart.Position
        if TazerAimbot.Prediction > 0 then
            targetPosition = targetPosition + (targetPart.Velocity * (TazerAimbot.Prediction / 10))
        end
        
        
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

function TazerAimbot.StartAiming()
    if TazerAimbot.Aiming then return end
    
    TazerAimbot.Aiming = true
    TazerAimbot.CurrentTarget = TazerAimbot.GetClosestKiller()
end

function TazerAimbot.StopAiming()
    TazerAimbot.Aiming = false
    TazerAimbot.CurrentTarget = nil
end

function TazerAimbot.Update()
    if not TazerAimbot.Enabled or not TazerAimbot.KeybindActive then return end
    
    local isPlaying = TazerAimbot.IsAnimationPlaying()
    local isShotPlaying = TazerAimbot.IsShotAnimationPlaying()
    
    
    if isShotPlaying then
        TazerAimbot.ShotFired = true
        if TazerAimbot.Aiming then
            TazerAimbot.StopAiming()
        end
        TazerAimbot.LastAnimationState = false
        return
    end
    
    
    if TazerAimbot.ShotFired then
        if TazerAimbot.Aiming then
            TazerAimbot.StopAiming()
        end
        
        if not isPlaying then
            TazerAimbot.ShotFired = false
        end
        return
    end
    
    
    if isPlaying and not TazerAimbot.LastAnimationState then
        TazerAimbot.StartAiming()
    end
    
    
    if not isPlaying and TazerAimbot.LastAnimationState then
        TazerAimbot.StopAiming()
    end
    
    TazerAimbot.LastAnimationState = isPlaying
    
    
    TazerAimbot.AimTick()
end

function TazerAimbot.Start()
    TazerAimbot.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Tazer Aimbot ]</font> Enabled!", 2)
    
    if TazerAimbot.Connection then
        TazerAimbot.Connection:Disconnect()
    end
    
    TazerAimbot.Connection = RunService.RenderStepped:Connect(TazerAimbot.Update)
end

function TazerAimbot.Stop()
    TazerAimbot.Enabled = false
    TazerAimbot.KeybindActive = false
    TazerAimbot.StopAiming()
    SafeNotify("<font color='#FF0000'>[ Tazer Aimbot ]</font> Disabled!", 2)
    
    if TazerAimbot.Connection then
        TazerAimbot.Connection:Disconnect()
        TazerAimbot.Connection = nil
    end
end

function TazerAimbot.SetPrediction(value)
    TazerAimbot.Prediction = value
end

function TazerAimbot.SetWalls(value)
    TazerAimbot.Walls = value
end

function TazerAimbot.ToggleKeybind()
    TazerAimbot.KeybindActive = not TazerAimbot.KeybindActive
    
    if TazerAimbot.KeybindActive then
        if TazerAimbot.IsAnimationPlaying() then
            TazerAimbot.StartAiming()
            TazerAimbot.LastAnimationState = true
        end
    else
        if TazerAimbot.Aiming then
            TazerAimbot.StopAiming()
        end
        TazerAimbot.LastAnimationState = false
        TazerAimbot.ShotFired = false
    end
end


local AxeAimbot = {
    Enabled = false,
    Prediction = 2,
    Walls = true,
    Aiming = false,
    CurrentTarget = nil,
    AimConnection = nil,
    IdleAnimationId = "77150341615948",
    ThrowAnimationId = "119495869953586",
    WalkAnimations = {
        ["118509706908978"] = true,
        ["114261887795674"] = true,
        ["138068581032578"] = true,
        ["115567619906878"] = true,
        ["87240234350251"] = true,
        ["129887420610542"] = true,
        ["89108444403670"] = true,
        ["126261863915299"] = true
    },
    MaxDistance = 1000,
    LastAnimationState = false,
    ThrowFired = false,
    ThrowTime = 0,
    KeybindActive = false,
    CurrentKey = Enum.KeyCode.X
}

function AxeAimbot.IsThrowAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == AxeAimbot.ThrowAnimationId then
                return true
            end
        end
    end
    
    return false
end

function AxeAimbot.IsAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    local foundAnim = false
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            
            if not AxeAimbot._loggedAnims then AxeAimbot._loggedAnims = {} end
            if not AxeAimbot._loggedAnims[animId] then
                AxeAimbot._loggedAnims[animId] = true
            end
            
            
            if animId == AxeAimbot.IdleAnimationId then
                foundAnim = true
            end
            
            if AxeAimbot.WalkAnimations[animId] then
                foundAnim = true
            end
        end
    end
    
    return foundAnim
end

function AxeAimbot.GetClosestSurvivor()
    local closestSurvivor = nil
    local shortestDistance = math.huge
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return nil end
    
    local alive = players:FindFirstChild("ALIVE")
    if not alive then return nil end
    
    for _, survivor in ipairs(alive:GetChildren()) do
        if survivor:IsA("Model") and survivor.Name ~= Player.Name then
            local humanoid = survivor:FindFirstChildOfClass("Humanoid")
            local rootPart = survivor:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                if distance < AxeAimbot.MaxDistance and distance < shortestDistance then
                    shortestDistance = distance
                    closestSurvivor = survivor
                end
            end
        end
    end
    
    return closestSurvivor
end

function AxeAimbot.IsTargetVisible(targetPart)
    if AxeAimbot.Walls then
        return true
    end
    
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    local direction = (targetPart.Position - localRoot.Position)
    local ray = Ray.new(localRoot.Position, direction)
    
    local ignoreList = {Player.Character}
    if AxeAimbot.CurrentTarget then
        table.insert(ignoreList, AxeAimbot.CurrentTarget)
    end
    
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if not hit then
        return true
    end
    
    if AxeAimbot.CurrentTarget and hit:IsDescendantOf(AxeAimbot.CurrentTarget) then
        return true
    end
    
    if hit.Transparency >= 0.9 or not hit.CanCollide then
        return true
    end
    
    return false
end

function AxeAimbot.AimTick()
    if not AxeAimbot.Aiming then return end
    
    if not AxeAimbot.CurrentTarget or not AxeAimbot.CurrentTarget.Parent then
        AxeAimbot.CurrentTarget = AxeAimbot.GetClosestSurvivor()
    end
    
    if AxeAimbot.CurrentTarget and AxeAimbot.CurrentTarget:FindFirstChild("HumanoidRootPart") then
        local targetPart = AxeAimbot.CurrentTarget.HumanoidRootPart
        
        if not AxeAimbot.IsTargetVisible(targetPart) then
            return
        end
        
        local camera = workspace.CurrentCamera
        
        local targetPosition = targetPart.Position
        if AxeAimbot.Prediction > 0 then
            targetPosition = targetPosition + (targetPart.Velocity * (AxeAimbot.Prediction / 10))
        end
        
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

function AxeAimbot.StartAiming()
    if AxeAimbot.Aiming then return end
    
    AxeAimbot.Aiming = true
    AxeAimbot.CurrentTarget = AxeAimbot.GetClosestSurvivor()
end

function AxeAimbot.StopAiming()
    AxeAimbot.Aiming = false
    AxeAimbot.CurrentTarget = nil
end

function AxeAimbot.Update()
    if not AxeAimbot.Enabled or not AxeAimbot.KeybindActive then return end
    
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local isIdlePlaying = false
    local isWalkPlaying = false
    local isThrowPlaying = false
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            if animId == AxeAimbot.IdleAnimationId then
                isIdlePlaying = true
            elseif AxeAimbot.WalkAnimations[animId] then
                isWalkPlaying = true
            elseif animId == AxeAimbot.ThrowAnimationId then
                isThrowPlaying = true
            end
        end
    end
    
    
    if isThrowPlaying then
        AxeAimbot.AimTick()
        return
    end
    
    
    if isIdlePlaying and not AxeAimbot.Aiming then
        AxeAimbot.StartAiming()
        AxeAimbot.LastAnimationState = true
    end
    
    
    if isWalkPlaying and AxeAimbot.Aiming then
        AxeAimbot.LastAnimationState = true
    end
    
    
    if not isIdlePlaying and not isWalkPlaying and AxeAimbot.Aiming then
        AxeAimbot.StopAiming()
        AxeAimbot.LastAnimationState = false
    end
    
    AxeAimbot.AimTick()
end

function AxeAimbot.Start()
    AxeAimbot.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Axe Aimbot ]</font> Enabled!", 2)
    
    if AxeAimbot.Connection then
        AxeAimbot.Connection:Disconnect()
    end
    
    AxeAimbot.Connection = RunService.RenderStepped:Connect(AxeAimbot.Update)
end

function AxeAimbot.Stop()
    AxeAimbot.Enabled = false
    AxeAimbot.KeybindActive = false
    AxeAimbot.StopAiming()
    SafeNotify("<font color='#FF0000'>[ Axe Aimbot ]</font> Disabled!", 2)
    
    if AxeAimbot.Connection then
        AxeAimbot.Connection:Disconnect()
        AxeAimbot.Connection = nil
    end
end

function AxeAimbot.SetPrediction(value)
    AxeAimbot.Prediction = value
end

function AxeAimbot.SetWalls(value)
    AxeAimbot.Walls = value
end

function AxeAimbot.ToggleKeybind()
    AxeAimbot.KeybindActive = not AxeAimbot.KeybindActive
    
    if AxeAimbot.KeybindActive then
        if AxeAimbot.IsAnimationPlaying() then
            AxeAimbot.StartAiming()
            AxeAimbot.LastAnimationState = true
        end
    else
        if AxeAimbot.Aiming then
            AxeAimbot.StopAiming()
        end
        AxeAimbot.LastAnimationState = false
        AxeAimbot.ThrowFired = false
    end
end


local ChargeBoost = {
    Enabled = false,
    Speed = 6,
    Connection = nil,
    ChargeAnim1 = "89272231996541",
    ChargeAnim2 = "71147082224885",
    IsCharging = false
}

function ChargeBoost.IsChargingAnimation()
    if not Player.Character then return false, false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false, false end
    
    local anim1Playing = false
    local anim2Playing = false
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            if animId == ChargeBoost.ChargeAnim1 then
                anim1Playing = true
            elseif animId == ChargeBoost.ChargeAnim2 then
                anim2Playing = true
            end
        end
    end
    
    return anim1Playing, anim2Playing
end

function ChargeBoost.Start()
    ChargeBoost.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Charge Distance Increase ]</font> Enabled!", 2)
    
    if ChargeBoost.Connection then
        ChargeBoost.Connection:Disconnect()
    end
    
    ChargeBoost.Connection = RunService.RenderStepped:Connect(function(dt)
        if not ChargeBoost.Enabled then return end
        if not Player.Character then return end
        
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local anim1, anim2 = ChargeBoost.IsChargingAnimation()
        
        
        if anim1 or anim2 then
            ChargeBoost.IsCharging = true
        end
        
        
        if ChargeBoost.IsCharging and (anim1 or anim2) then
            
            local step = ChargeBoost.Speed * dt
            
            
            local look = hrp.CFrame.LookVector
            local dir = Vector3.new(look.X, 0, look.Z).Unit
            
            
            local newPos = hrp.Position + dir * step
            
            
            hrp.CFrame = CFrame.new(newPos.X, hrp.Position.Y, newPos.Z) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
        elseif ChargeBoost.IsCharging and not anim1 and not anim2 then
            
            ChargeBoost.IsCharging = false
        end
    end)
end

function ChargeBoost.Stop()
    ChargeBoost.Enabled = false
    ChargeBoost.IsCharging = false
    SafeNotify("<font color='#FF0000'>[ Charge Distance Increase ]</font> Disabled!", 2)
    
    if ChargeBoost.Connection then
        ChargeBoost.Connection:Disconnect()
        ChargeBoost.Connection = nil
    end
end

function ChargeBoost.SetSpeed(value)
    ChargeBoost.Speed = value
end


local GrabAimbot = {
    Enabled = false,
    Prediction = 2,
    Walls = true,
    Aiming = false,
    CurrentTarget = nil,
    AimConnection = nil,
    GrabAnimationId = "95722006705414",
    MaxDistance = 1000,
    KeybindActive = false,
    CurrentKey = Enum.KeyCode.X,
    GrabStartTime = 0,
    MaxGrabDuration = 0.7
}

function GrabAimbot.IsGrabAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == GrabAimbot.GrabAnimationId then
                return true
            end
        end
    end
    
    return false
end

function GrabAimbot.GetClosestSurvivor()
    local closestSurvivor = nil
    local shortestDistance = math.huge
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return nil end
    
    local alive = players:FindFirstChild("ALIVE")
    if not alive then return nil end
    
    for _, survivor in ipairs(alive:GetChildren()) do
        if survivor:IsA("Model") and survivor.Name ~= Player.Name then
            local humanoid = survivor:FindFirstChildOfClass("Humanoid")
            local rootPart = survivor:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                if distance < GrabAimbot.MaxDistance and distance < shortestDistance then
                    shortestDistance = distance
                    closestSurvivor = survivor
                end
            end
        end
    end
    
    return closestSurvivor
end

function GrabAimbot.IsTargetVisible(targetPart)
    if GrabAimbot.Walls then
        return true
    end
    
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    local direction = (targetPart.Position - localRoot.Position)
    local ray = Ray.new(localRoot.Position, direction)
    
    local ignoreList = {Player.Character}
    if GrabAimbot.CurrentTarget then
        table.insert(ignoreList, GrabAimbot.CurrentTarget)
    end
    
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if not hit then
        return true
    end
    
    if GrabAimbot.CurrentTarget and hit:IsDescendantOf(GrabAimbot.CurrentTarget) then
        return true
    end
    
    if hit.Transparency >= 0.9 or not hit.CanCollide then
        return true
    end
    
    return false
end

function GrabAimbot.AimTick()
    if not GrabAimbot.Aiming then return end
    
    
    if os.clock() - GrabAimbot.GrabStartTime > GrabAimbot.MaxGrabDuration then
        GrabAimbot.StopAiming()
        return
    end
    
    if not GrabAimbot.CurrentTarget or not GrabAimbot.CurrentTarget.Parent then
        GrabAimbot.CurrentTarget = GrabAimbot.GetClosestSurvivor()
    end
    
    if GrabAimbot.CurrentTarget and GrabAimbot.CurrentTarget:FindFirstChild("HumanoidRootPart") then
        local targetPart = GrabAimbot.CurrentTarget.HumanoidRootPart
        
        if not GrabAimbot.IsTargetVisible(targetPart) then
            return
        end
        
        local camera = workspace.CurrentCamera
        
        local targetPosition = targetPart.Position
        if GrabAimbot.Prediction > 0 then
            targetPosition = targetPosition + (targetPart.Velocity * (GrabAimbot.Prediction / 10))
        end
        
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

function GrabAimbot.StartAiming()
    if GrabAimbot.Aiming then return end
    
    GrabAimbot.Aiming = true
    GrabAimbot.GrabStartTime = os.clock()
    GrabAimbot.CurrentTarget = GrabAimbot.GetClosestSurvivor()
end

function GrabAimbot.StopAiming()
    GrabAimbot.Aiming = false
    GrabAimbot.CurrentTarget = nil
end

function GrabAimbot.Update()
    if not GrabAimbot.Enabled or not GrabAimbot.KeybindActive then return end
    
    local isGrabPlaying = GrabAimbot.IsGrabAnimationPlaying()
    
    
    if isGrabPlaying and not GrabAimbot.Aiming then
        GrabAimbot.StartAiming()
    end
    
    
    if not isGrabPlaying and GrabAimbot.Aiming then
        GrabAimbot.StopAiming()
    end
    
    GrabAimbot.AimTick()
end

function GrabAimbot.Start()
    GrabAimbot.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Grab Aimbot ]</font> Enabled!", 2)
    
    if GrabAimbot.Connection then
        GrabAimbot.Connection:Disconnect()
    end
    
    GrabAimbot.Connection = RunService.RenderStepped:Connect(GrabAimbot.Update)
end

function GrabAimbot.Stop()
    GrabAimbot.Enabled = false
    GrabAimbot.KeybindActive = false
    GrabAimbot.StopAiming()
    SafeNotify("<font color='#FF0000'>[ Grab Aimbot ]</font> Disabled!", 2)
    
    if GrabAimbot.Connection then
        GrabAimbot.Connection:Disconnect()
        GrabAimbot.Connection = nil
    end
end

function GrabAimbot.SetPrediction(value)
    GrabAimbot.Prediction = value
end

function GrabAimbot.SetWalls(value)
    GrabAimbot.Walls = value
end

function GrabAimbot.ToggleKeybind()
    GrabAimbot.KeybindActive = not GrabAimbot.KeybindActive
    
    if GrabAimbot.KeybindActive then
        if GrabAimbot.IsGrabAnimationPlaying() then
            GrabAimbot.StartAiming()
        end
    else
        if GrabAimbot.Aiming then
            GrabAimbot.StopAiming()
        end
    end
end


local GrabBoost = {
    Enabled = false,
    Speed = 6,
    Connection = nil,
    GrabAnimationId = "95722006705414",
    IsGrabbing = false,
    GrabStartTime = 0,
    MaxGrabDuration = 0.7
}

function GrabBoost.IsGrabAnimation()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            if animId == GrabBoost.GrabAnimationId then
                return true
            end
        end
    end
    
    return false
end

function GrabBoost.Start()
    GrabBoost.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Grab Distance Increase ]</font> Enabled!", 2)
    
    if GrabBoost.Connection then
        GrabBoost.Connection:Disconnect()
    end
    
    GrabBoost.Connection = RunService.RenderStepped:Connect(function(dt)
        if not GrabBoost.Enabled then return end
        if not Player.Character then return end
        
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local isGrabbing = GrabBoost.IsGrabAnimation()
        
        
        if isGrabbing and not GrabBoost.IsGrabbing then
            GrabBoost.IsGrabbing = true
            GrabBoost.GrabStartTime = os.clock()
        end
        
        
        if GrabBoost.IsGrabbing and (os.clock() - GrabBoost.GrabStartTime > GrabBoost.MaxGrabDuration) then
            GrabBoost.IsGrabbing = false
        end
        
        
        if GrabBoost.IsGrabbing and isGrabbing then
            
            local step = GrabBoost.Speed * dt
            
            
            local look = hrp.CFrame.LookVector
            local dir = Vector3.new(look.X, 0, look.Z).Unit
            
            
            local newPos = hrp.Position + dir * step
            
            
            hrp.CFrame = CFrame.new(newPos.X, hrp.Position.Y, newPos.Z) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
        elseif GrabBoost.IsGrabbing and not isGrabbing then
            
            GrabBoost.IsGrabbing = false
        end
    end)
end

function GrabBoost.Stop()
    GrabBoost.Enabled = false
    GrabBoost.IsGrabbing = false
    SafeNotify("<font color='#FF0000'>[ Grab Distance Increase ]</font> Disabled!", 2)
    
    if GrabBoost.Connection then
        GrabBoost.Connection:Disconnect()
        GrabBoost.Connection = nil
    end
end

function GrabBoost.SetSpeed(value)
    GrabBoost.Speed = value
end


local SwingAimbot = {
    Enabled = false,
    Prediction = 2,
    Walls = true,
    Aiming = false,
    CurrentTarget = nil,
    AimConnection = nil,
    SwingAnimationId = "86249888440012",
    MaxDistance = 1000,
    KeybindActive = false,
    CurrentKey = Enum.KeyCode.V
}

function SwingAimbot.IsSwingAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == SwingAimbot.SwingAnimationId then
                return true
            end
        end
    end
    
    return false
end

function SwingAimbot.GetClosestKiller()
    local closestKiller = nil
    local shortestDistance = math.huge
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return nil end
    
    local killers = players:FindFirstChild("KILLER")
    if not killers then return nil end
    
    for _, killer in ipairs(killers:GetChildren()) do
        if killer:IsA("Model") then
            local humanoid = killer:FindFirstChildOfClass("Humanoid")
            local rootPart = killer:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                if distance < SwingAimbot.MaxDistance and distance < shortestDistance then
                    shortestDistance = distance
                    closestKiller = killer
                end
            end
        end
    end
    
    return closestKiller
end

function SwingAimbot.IsTargetVisible(targetPart)
    if SwingAimbot.Walls then
        return true
    end
    
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    local direction = (targetPart.Position - localRoot.Position)
    local ray = Ray.new(localRoot.Position, direction)
    
    local ignoreList = {Player.Character}
    if SwingAimbot.CurrentTarget then
        table.insert(ignoreList, SwingAimbot.CurrentTarget)
    end
    
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if not hit then
        return true
    end
    
    if SwingAimbot.CurrentTarget and hit:IsDescendantOf(SwingAimbot.CurrentTarget) then
        return true
    end
    
    if hit.Transparency >= 0.9 or not hit.CanCollide then
        return true
    end
    
    return false
end

function SwingAimbot.AimTick()
    if not SwingAimbot.Aiming then return end
    
    if not SwingAimbot.CurrentTarget or not SwingAimbot.CurrentTarget.Parent then
        SwingAimbot.CurrentTarget = SwingAimbot.GetClosestKiller()
    end
    
    if SwingAimbot.CurrentTarget and SwingAimbot.CurrentTarget:FindFirstChild("HumanoidRootPart") then
        local targetPart = SwingAimbot.CurrentTarget.HumanoidRootPart
        
        if not SwingAimbot.IsTargetVisible(targetPart) then
            return
        end
        
        local camera = workspace.CurrentCamera
        
        local targetPosition = targetPart.Position
        if SwingAimbot.Prediction > 0 then
            targetPosition = targetPosition + (targetPart.Velocity * (SwingAimbot.Prediction / 10))
        end
        
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

function SwingAimbot.StartAiming()
    if SwingAimbot.Aiming then return end
    
    SwingAimbot.Aiming = true
    SwingAimbot.CurrentTarget = SwingAimbot.GetClosestKiller()
end

function SwingAimbot.StopAiming()
    SwingAimbot.Aiming = false
    SwingAimbot.CurrentTarget = nil
end

function SwingAimbot.Update()
    if not SwingAimbot.Enabled or not SwingAimbot.KeybindActive then return end
    
    local isSwingPlaying = SwingAimbot.IsSwingAnimationPlaying()
    
    
    if isSwingPlaying and not SwingAimbot.Aiming then
        SwingAimbot.StartAiming()
    end
    
    
    if not isSwingPlaying and SwingAimbot.Aiming then
        SwingAimbot.StopAiming()
    end
    
    SwingAimbot.AimTick()
end

function SwingAimbot.Start()
    SwingAimbot.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Swing Aimbot ]</font> Enabled!", 2)
    
    if SwingAimbot.Connection then
        SwingAimbot.Connection:Disconnect()
    end
    
    SwingAimbot.Connection = RunService.RenderStepped:Connect(SwingAimbot.Update)
end

function SwingAimbot.Stop()
    SwingAimbot.Enabled = false
    SwingAimbot.KeybindActive = false
    SwingAimbot.StopAiming()
    SafeNotify("<font color='#FF0000'>[ Swing Aimbot ]</font> Disabled!", 2)
    
    if SwingAimbot.Connection then
        SwingAimbot.Connection:Disconnect()
        SwingAimbot.Connection = nil
    end
end

function SwingAimbot.SetPrediction(value)
    SwingAimbot.Prediction = value
end

function SwingAimbot.SetWalls(value)
    SwingAimbot.Walls = value
end

function SwingAimbot.ToggleKeybind()
    SwingAimbot.KeybindActive = not SwingAimbot.KeybindActive
    
    if SwingAimbot.KeybindActive then
        if SwingAimbot.IsSwingAnimationPlaying() then
            SwingAimbot.StartAiming()
        end
    else
        if SwingAimbot.Aiming then
            SwingAimbot.StopAiming()
        end
    end
end


local SwingBoost = {
    Enabled = false,
    Speed = 6,
    Connection = nil,
    SwingAnimationId = "86249888440012",
    IsSwinging = false
}

function SwingBoost.IsSwingAnimation()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            if animId == SwingBoost.SwingAnimationId then
                return true
            end
        end
    end
    
    return false
end

function SwingBoost.Start()
    SwingBoost.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Swing Distance Increase ]</font> Enabled!", 2)
    
    if SwingBoost.Connection then
        SwingBoost.Connection:Disconnect()
    end
    
    SwingBoost.Connection = RunService.RenderStepped:Connect(function(dt)
        if not SwingBoost.Enabled then return end
        if not Player.Character then return end
        
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local isSwinging = SwingBoost.IsSwingAnimation()
        
        
        if isSwinging then
            SwingBoost.IsSwinging = true
        end
        
        
        if SwingBoost.IsSwinging and isSwinging then
            
            local step = SwingBoost.Speed * dt
            
            
            local look = hrp.CFrame.LookVector
            local dir = Vector3.new(look.X, 0, look.Z).Unit
            
            
            local newPos = hrp.Position + dir * step
            
            
            hrp.CFrame = CFrame.new(newPos.X, hrp.Position.Y, newPos.Z) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
        elseif SwingBoost.IsSwinging and not isSwinging then
            
            SwingBoost.IsSwinging = false
        end
    end)
end

function SwingBoost.Stop()
    SwingBoost.Enabled = false
    SwingBoost.IsSwinging = false
    SafeNotify("<font color='#FF0000'>[ Swing Distance Increase ]</font> Disabled!", 2)
    
    if SwingBoost.Connection then
        SwingBoost.Connection:Disconnect()
        SwingBoost.Connection = nil
    end
end

function SwingBoost.SetSpeed(value)
    SwingBoost.Speed = value
end


local HideBlockAnimation = {
    Enabled = false,
    Connection = nil,
    BlockAnimationId = "92429524316030",
    ReplaceAnimationId = "118085198496786",
    CurrentReplaceTrack = nil,
    LastAnimId = nil
}

function HideBlockAnimation.GetCurrentBlockAnimation()
    if not Player.Character then return nil end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == HideBlockAnimation.BlockAnimationId then
                return track
            end
        end
    end
    
    return nil
end

function HideBlockAnimation.StopReplaceAnimation()
    if HideBlockAnimation.CurrentReplaceTrack then
        HideBlockAnimation.CurrentReplaceTrack:Stop()
        HideBlockAnimation.CurrentReplaceTrack = nil
    end
end

function HideBlockAnimation.PlayReplaceAnimation()
    HideBlockAnimation.StopReplaceAnimation()
    
    if not Player.Character then return end
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local replaceAnim = Instance.new("Animation")
    replaceAnim.AnimationId = "rbxassetid://" .. HideBlockAnimation.ReplaceAnimationId
    HideBlockAnimation.CurrentReplaceTrack = humanoid:LoadAnimation(replaceAnim)
    HideBlockAnimation.CurrentReplaceTrack.Looped = false
    HideBlockAnimation.CurrentReplaceTrack:Play(0.1, 1, 1.0)
    HideBlockAnimation.CurrentReplaceTrack.Stopped:Connect(function()
        HideBlockAnimation.CurrentReplaceTrack = nil
    end)
end

function HideBlockAnimation.Start()
    HideBlockAnimation.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Hide Block Animation ]</font> Enabled!", 2)
    
    if HideBlockAnimation.Connection then
        HideBlockAnimation.Connection:Disconnect()
    end
    
    HideBlockAnimation.Connection = RunService.Heartbeat:Connect(function()
        if not HideBlockAnimation.Enabled then return end
        
        local blockTrack = HideBlockAnimation.GetCurrentBlockAnimation()
        
        if blockTrack and blockTrack ~= HideBlockAnimation.LastAnimId then
            
            blockTrack:Stop()
            
            HideBlockAnimation.PlayReplaceAnimation()
            HideBlockAnimation.LastAnimId = blockTrack
        end
        
        if not blockTrack and HideBlockAnimation.LastAnimId then
            HideBlockAnimation.LastAnimId = nil
        end
    end)
end

function HideBlockAnimation.Stop()
    HideBlockAnimation.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Hide Block Animation ]</font> Disabled!", 2)
    
    if HideBlockAnimation.Connection then
        HideBlockAnimation.Connection:Disconnect()
        HideBlockAnimation.Connection = nil
    end
    
    HideBlockAnimation.StopReplaceAnimation()
    HideBlockAnimation.LastAnimId = nil
end


local AutoBlock = {
    Enabled = false,
    Connection = nil,
    MinDistance = 20,
    ThrowDistance = 80,
    SoundHooks = {},
    SoundCooldowns = {},
    AnimCooldowns = {},
    Cooldown = 0.3,
    CurrentKey = Enum.KeyCode.X,
    ActiveSounds = {}, 
    
    
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

function AutoBlock.IsKillerLookingAtMe(killerHRP)
    local myChar = Player.Character
    if not myChar then return false end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not killerHRP then return false end
    
    local killerLookVector = killerHRP.CFrame.LookVector
    local toMeVector = (myHRP.Position - killerHRP.Position).Unit
    local dotProduct = killerLookVector:Dot(toMeVector)
    local angle = math.acos(math.clamp(dotProduct, -1, 1))
    
    return angle < math.rad(45)
end

function AutoBlock.ExecuteBlock()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Reliable = ReplicatedStorage:FindFirstChild("Modules")
    if Reliable then
        Reliable = Reliable:FindFirstChild("Warp")
        if Reliable then
            Reliable = Reliable:FindFirstChild("Index")
            if Reliable then
                Reliable = Reliable:FindFirstChild("Event")
                if Reliable then
                    Reliable = Reliable:FindFirstChild("Reliable")
                    if Reliable then
                        local arg1 = buffer.fromstring("\7")
                        local arg2 = buffer.fromstring("\254\1\0\254\2\0\6\7Ability\1\2")
                        Reliable:FireServer(arg1, arg2)
                    end
                end
            end
        end
    end
end

function AutoBlock.ExtractNumericSoundId(sound)
    if not sound.SoundId then return nil end
    local sid = tostring(sound.SoundId)
    local num = string.match(sid, "rbxassetid://(%d+)") or string.match(sid, "://(%d+)") or string.match(sid, "^(%d+)$")
    return num
end

function AutoBlock.GetSoundWorldPosition(sound)
    local parent = sound.Parent
    if not parent then return nil, nil end
    if parent:IsA("BasePart") then
        return parent.Position, parent
    end
    return nil, nil
end

function AutoBlock.GetCharacterFromDescendant(inst)
    if not inst then return nil end
    local model = inst:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid") and model
end

function AutoBlock.IsKiller(character)
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return false end
    
    local killer = players:FindFirstChild("KILLER")
    if not killer then return false end
    
    return killer:FindFirstChild(character.Name) ~= nil
end

function AutoBlock.AttemptBlockForSound(sound)
    if not AutoBlock.Enabled then return end
    
    
    if not GetPlayerStyle then return end
    local style = GetPlayerStyle()
    if style ~= "fighter" then return end
    
    local soundId = AutoBlock.ExtractNumericSoundId(sound)
    if not soundId then return end
    
    
    soundId = tostring(soundId)
    
    if not AutoBlock.AttackSounds[soundId] then return end
    
    
    AutoBlock.ActiveSounds[sound] = true
end

function AutoBlock.HookSound(sound)
    if not sound or not sound:IsA("Sound") or AutoBlock.SoundHooks[sound] then return end
    
    
    local success, playedConn = pcall(function()
        return sound.Played:Connect(function() 
            AutoBlock.AttemptBlockForSound(sound) 
        end)
    end)
    if not success then playedConn = nil end
    
    local propConn = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
    if sound.IsPlaying then 
        AutoBlock.AttemptBlockForSound(sound) 
    end
    end)
    
    local destroyConn = sound.Destroying:Connect(function()
        if playedConn then pcall(function() playedConn:Disconnect() end) end
        pcall(function() propConn:Disconnect() end)
        pcall(function() destroyConn:Disconnect() end)
        AutoBlock.SoundHooks[sound] = nil
        AutoBlock.SoundCooldowns[sound] = nil
    end)
    
    AutoBlock.SoundHooks[sound] = {playedConn = playedConn, propConn = propConn, destroyConn = destroyConn}
    if sound.IsPlaying then 
        AutoBlock.AttemptBlockForSound(sound) 
    end
end

function AutoBlock.HookCharacterSounds(character)
    if not AutoBlock.IsKiller(character) then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    
    for _, sound in ipairs(hrp:GetChildren()) do
        if sound:IsA("Sound") then
            AutoBlock.HookSound(sound)
        end
    end
    
    
    hrp.ChildAdded:Connect(function(child)
        if child:IsA("Sound") and AutoBlock.Enabled then
            AutoBlock.HookSound(child)
        end
    end)
end

function AutoBlock.InitializeSoundHooks()
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return end
    
    local killer = players:FindFirstChild("KILLER")
    if not killer then return end
    
    
    for _, killerModel in ipairs(killer:GetChildren()) do
        if killerModel:IsA("Model") then
            AutoBlock.HookCharacterSounds(killerModel)
        end
    end
    
    
    killer.ChildAdded:Connect(function(killerModel)
        if killerModel:IsA("Model") and AutoBlock.Enabled then
            AutoBlock.HookCharacterSounds(killerModel)
        end
    end)
end

function AutoBlock.CleanupSoundHooks()
    for sound, hooks in pairs(AutoBlock.SoundHooks) do
        if hooks then
            for _, conn in pairs(hooks) do
                if conn then
                    pcall(function() conn:Disconnect() end)
                end
            end
        end
    end
    AutoBlock.SoundHooks = {}
    AutoBlock.SoundCooldowns = {}
end

function AutoBlock.GetKiller()
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return nil end
    
    local killer = players:FindFirstChild("KILLER")
    if not killer then return nil end
    
    for _, killerModel in ipairs(killer:GetChildren()) do
        if killerModel:IsA("Model") and killerModel.Name ~= Player.Name then
            local humanoid = killerModel:FindFirstChildOfClass("Humanoid")
            local hrp = killerModel:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and hrp then
                return killerModel, hrp
            end
        end
    end
    
    return nil
end

function AutoBlock.CheckKillerAnimation(killerModel, killerHRP, distance)
    local humanoid = killerModel:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            
            if AutoBlock.ThrowAnimations[animId] and distance <= AutoBlock.ThrowDistance then
                if AutoBlock.IsKillerLookingAtMe(killerHRP) then
                    local now = tick()
                    if not AutoBlock.AnimCooldowns[animId] or (now - AutoBlock.AnimCooldowns[animId]) > AutoBlock.Cooldown then
                        AutoBlock.AnimCooldowns[animId] = now
                        return true
                    end
                end
            end
            
            
            if AutoBlock.ChargeAnimations[animId] and distance <= AutoBlock.MinDistance then
                if AutoBlock.IsKillerLookingAtMe(killerHRP) then
                    local now = tick()
                    if not AutoBlock.AnimCooldowns[animId] or (now - AutoBlock.AnimCooldowns[animId]) > AutoBlock.Cooldown then
                        AutoBlock.AnimCooldowns[animId] = now
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

function AutoBlock.Start()
    AutoBlock.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Auto Block ]</font> Enabled!", 2)
    
    
    AutoBlock.InitializeSoundHooks()
    
    if AutoBlock.Connection then
        AutoBlock.Connection:Disconnect()
    end
    
    AutoBlock.Connection = RunService.Heartbeat:Connect(function()
        if not AutoBlock.Enabled then return end
        if not Player.Character then return end
        
        
        if not GetPlayerStyle then return end
        local style = GetPlayerStyle()
        if style ~= "fighter" then return end
        
        local myHRP = Player.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        
        
        local players = workspace:FindFirstChild("PLAYERS")
        if players then
            local killer = players:FindFirstChild("KILLER")
            if killer and killer:GetChildren()[1] then
                local hasHooks = false
                for _ in pairs(AutoBlock.SoundHooks) do
                    hasHooks = true
                    break
                end
                if not hasHooks then
                    AutoBlock.InitializeSoundHooks()
                end
            end
        end
        
        local killerModel, killerHRP = AutoBlock.GetKiller()
        if not killerModel or not killerHRP then return end
        
        local distance = (killerHRP.Position - myHRP.Position).Magnitude
        
        
        if AutoBlock.CheckKillerAnimation(killerModel, killerHRP, distance) then
            AutoBlock.ExecuteBlock()
            return
        end
        
        
        local now = tick()
        for sound, _ in pairs(AutoBlock.ActiveSounds) do
            if sound and sound.Parent and sound.IsPlaying then
                
                if not AutoBlock.SoundCooldowns[sound] or (now - AutoBlock.SoundCooldowns[sound]) > AutoBlock.Cooldown then
                    
                    if distance <= AutoBlock.MinDistance then
                        
                        if AutoBlock.IsKillerLookingAtMe(killerHRP) then
                            AutoBlock.SoundCooldowns[sound] = now
                            AutoBlock.ExecuteBlock()
                            return
                        end
                    end
                end
            else
                
                AutoBlock.ActiveSounds[sound] = nil
            end
        end
    end)
end

function AutoBlock.Stop()
    AutoBlock.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Auto Block ]</font> Disabled!", 2)
    
    if AutoBlock.Connection then
        AutoBlock.Connection:Disconnect()
        AutoBlock.Connection = nil
    end
    
    AutoBlock.CleanupSoundHooks()
    AutoBlock.AnimCooldowns = {}
end

function AutoBlock.SetMinDistance(value)
    AutoBlock.MinDistance = value
end


local EnnardGrabAimbot = {
    Enabled = false,
    Prediction = 2,
    Walls = true,
    Aiming = false,
    CurrentTarget = nil,
    AimConnection = nil,
    GrabAnimationId = "133752270724243",
    MaxDistance = 1000,
    KeybindActive = false,
    CurrentKey = Enum.KeyCode.X
}

function EnnardGrabAimbot.IsGrabAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == EnnardGrabAimbot.GrabAnimationId then
                return true
            end
        end
    end
    
    return false
end

function EnnardGrabAimbot.GetClosestSurvivor()
    local closestSurvivor = nil
    local shortestDistance = math.huge
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return nil end
    
    local alive = players:FindFirstChild("ALIVE")
    if not alive then return nil end
    
    for _, survivor in ipairs(alive:GetChildren()) do
        if survivor:IsA("Model") and survivor.Name ~= Player.Name then
            local humanoid = survivor:FindFirstChildOfClass("Humanoid")
            local rootPart = survivor:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                if distance < EnnardGrabAimbot.MaxDistance and distance < shortestDistance then
                    shortestDistance = distance
                    closestSurvivor = survivor
                end
            end
        end
    end
    
    return closestSurvivor
end

function EnnardGrabAimbot.IsTargetVisible(targetPart)
    if EnnardGrabAimbot.Walls then
        return true
    end
    
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    local direction = (targetPart.Position - localRoot.Position)
    local ray = Ray.new(localRoot.Position, direction)
    
    local ignoreList = {Player.Character}
    if EnnardGrabAimbot.CurrentTarget then
        table.insert(ignoreList, EnnardGrabAimbot.CurrentTarget)
    end
    
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if not hit then
        return true
    end
    
    if EnnardGrabAimbot.CurrentTarget and hit:IsDescendantOf(EnnardGrabAimbot.CurrentTarget) then
        return true
    end
    
    if hit.Transparency >= 0.9 or not hit.CanCollide then
        return true
    end
    
    return false
end

function EnnardGrabAimbot.AimTick()
    if not EnnardGrabAimbot.Aiming then return end
    
    if not EnnardGrabAimbot.CurrentTarget or not EnnardGrabAimbot.CurrentTarget.Parent then
        EnnardGrabAimbot.CurrentTarget = EnnardGrabAimbot.GetClosestSurvivor()
    end
    
    if EnnardGrabAimbot.CurrentTarget and EnnardGrabAimbot.CurrentTarget:FindFirstChild("HumanoidRootPart") then
        local targetPart = EnnardGrabAimbot.CurrentTarget.HumanoidRootPart
        
        if not EnnardGrabAimbot.IsTargetVisible(targetPart) then
            return
        end
        
        local camera = workspace.CurrentCamera
        
        local targetPosition = targetPart.Position
        if EnnardGrabAimbot.Prediction > 0 then
            targetPosition = targetPosition + (targetPart.Velocity * (EnnardGrabAimbot.Prediction / 10))
        end
        
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

function EnnardGrabAimbot.StartAiming()
    if EnnardGrabAimbot.Aiming then return end
    
    EnnardGrabAimbot.Aiming = true
    EnnardGrabAimbot.CurrentTarget = EnnardGrabAimbot.GetClosestSurvivor()
end

function EnnardGrabAimbot.StopAiming()
    EnnardGrabAimbot.Aiming = false
    EnnardGrabAimbot.CurrentTarget = nil
end

function EnnardGrabAimbot.Update()
    if not EnnardGrabAimbot.Enabled or not EnnardGrabAimbot.KeybindActive then return end
    
    local isGrabPlaying = EnnardGrabAimbot.IsGrabAnimationPlaying()
    
    if isGrabPlaying and not EnnardGrabAimbot.Aiming then
        EnnardGrabAimbot.StartAiming()
    end
    
    if not isGrabPlaying and EnnardGrabAimbot.Aiming then
        EnnardGrabAimbot.StopAiming()
    end
    
    EnnardGrabAimbot.AimTick()
end

function EnnardGrabAimbot.Start()
    EnnardGrabAimbot.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Ennard Grab Aimbot ]</font> Enabled!", 2)
    
    if EnnardGrabAimbot.Connection then
        EnnardGrabAimbot.Connection:Disconnect()
    end
    
    EnnardGrabAimbot.Connection = RunService.RenderStepped:Connect(EnnardGrabAimbot.Update)
end

function EnnardGrabAimbot.Stop()
    EnnardGrabAimbot.Enabled = false
    EnnardGrabAimbot.KeybindActive = false
    EnnardGrabAimbot.StopAiming()
    SafeNotify("<font color='#FF0000'>[ Ennard Grab Aimbot ]</font> Disabled!", 2)
    
    if EnnardGrabAimbot.Connection then
        EnnardGrabAimbot.Connection:Disconnect()
        EnnardGrabAimbot.Connection = nil
    end
end

function EnnardGrabAimbot.SetPrediction(value)
    EnnardGrabAimbot.Prediction = value
end

function EnnardGrabAimbot.SetWalls(value)
    EnnardGrabAimbot.Walls = value
end


local EnnardStabAimbot = {
    Enabled = false,
    Prediction = 2,
    Walls = true,
    Aiming = false,
    CurrentTarget = nil,
    AimConnection = nil,
    StabAnimationId = "109788581549466",
    MaxDistance = 1000,
    KeybindActive = false,
    CurrentKey = Enum.KeyCode.X
}

function EnnardStabAimbot.IsStabAnimationPlaying()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            if animId == EnnardStabAimbot.StabAnimationId then
                return true
            end
        end
    end
    
    return false
end

function EnnardStabAimbot.GetClosestSurvivor()
    local closestSurvivor = nil
    local shortestDistance = math.huge
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local players = workspace:FindFirstChild("PLAYERS")
    if not players then return nil end
    
    local alive = players:FindFirstChild("ALIVE")
    if not alive then return nil end
    
    for _, survivor in ipairs(alive:GetChildren()) do
        if survivor:IsA("Model") and survivor.Name ~= Player.Name then
            local humanoid = survivor:FindFirstChildOfClass("Humanoid")
            local rootPart = survivor:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and rootPart then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                if distance < EnnardStabAimbot.MaxDistance and distance < shortestDistance then
                    shortestDistance = distance
                    closestSurvivor = survivor
                end
            end
        end
    end
    
    return closestSurvivor
end

function EnnardStabAimbot.IsTargetVisible(targetPart)
    if EnnardStabAimbot.Walls then
        return true
    end
    
    local localRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return false end
    
    local direction = (targetPart.Position - localRoot.Position)
    local ray = Ray.new(localRoot.Position, direction)
    
    local ignoreList = {Player.Character}
    if EnnardStabAimbot.CurrentTarget then
        table.insert(ignoreList, EnnardStabAimbot.CurrentTarget)
    end
    
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if not hit then
        return true
    end
    
    if EnnardStabAimbot.CurrentTarget and hit:IsDescendantOf(EnnardStabAimbot.CurrentTarget) then
        return true
    end
    
    if hit.Transparency >= 0.9 or not hit.CanCollide then
        return true
    end
    
    return false
end

function EnnardStabAimbot.AimTick()
    if not EnnardStabAimbot.Aiming then return end
    
    if not EnnardStabAimbot.CurrentTarget or not EnnardStabAimbot.CurrentTarget.Parent then
        EnnardStabAimbot.CurrentTarget = EnnardStabAimbot.GetClosestSurvivor()
    end
    
    if EnnardStabAimbot.CurrentTarget and EnnardStabAimbot.CurrentTarget:FindFirstChild("HumanoidRootPart") then
        local targetPart = EnnardStabAimbot.CurrentTarget.HumanoidRootPart
        
        if not EnnardStabAimbot.IsTargetVisible(targetPart) then
            return
        end
        
        local camera = workspace.CurrentCamera
        
        local targetPosition = targetPart.Position
        if EnnardStabAimbot.Prediction > 0 then
            targetPosition = targetPosition + (targetPart.Velocity * (EnnardStabAimbot.Prediction / 10))
        end
        
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

function EnnardStabAimbot.StartAiming()
    if EnnardStabAimbot.Aiming then return end
    
    EnnardStabAimbot.Aiming = true
    EnnardStabAimbot.CurrentTarget = EnnardStabAimbot.GetClosestSurvivor()
end

function EnnardStabAimbot.StopAiming()
    EnnardStabAimbot.Aiming = false
    EnnardStabAimbot.CurrentTarget = nil
end

function EnnardStabAimbot.Update()
    if not EnnardStabAimbot.Enabled or not EnnardStabAimbot.KeybindActive then return end
    
    local isStabPlaying = EnnardStabAimbot.IsStabAnimationPlaying()
    
    if isStabPlaying and not EnnardStabAimbot.Aiming then
        EnnardStabAimbot.StartAiming()
    end
    
    if not isStabPlaying and EnnardStabAimbot.Aiming then
        EnnardStabAimbot.StopAiming()
    end
    
    EnnardStabAimbot.AimTick()
end

function EnnardStabAimbot.Start()
    EnnardStabAimbot.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Ennard Stab Aimbot ]</font> Enabled!", 2)
    
    if EnnardStabAimbot.Connection then
        EnnardStabAimbot.Connection:Disconnect()
    end
    
    EnnardStabAimbot.Connection = RunService.RenderStepped:Connect(EnnardStabAimbot.Update)
end

function EnnardStabAimbot.Stop()
    EnnardStabAimbot.Enabled = false
    EnnardStabAimbot.KeybindActive = false
    EnnardStabAimbot.StopAiming()
    SafeNotify("<font color='#FF0000'>[ Ennard Stab Aimbot ]</font> Disabled!", 2)
    
    if EnnardStabAimbot.Connection then
        EnnardStabAimbot.Connection:Disconnect()
        EnnardStabAimbot.Connection = nil
    end
end

function EnnardStabAimbot.SetPrediction(value)
    EnnardStabAimbot.Prediction = value
end

function EnnardStabAimbot.SetWalls(value)
    EnnardStabAimbot.Walls = value
end


local EnnardStabBoost = {
    Enabled = false,
    Speed = 6,
    Connection = nil,
    StabAnimationId = "109788581549466",
    IsStabbing = false
}

function EnnardStabBoost.IsStabAnimation()
    if not Player.Character then return false end
    
    local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.IsPlaying then
            local animId = tostring(track.Animation.AnimationId):match("%d+")
            
            if animId == EnnardStabBoost.StabAnimationId then
                return true
            end
        end
    end
    
    return false
end

function EnnardStabBoost.Start()
    EnnardStabBoost.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Ennard Stab Distance Increase ]</font> Enabled!", 2)
    
    if EnnardStabBoost.Connection then
        EnnardStabBoost.Connection:Disconnect()
    end
    
    EnnardStabBoost.Connection = RunService.RenderStepped:Connect(function(dt)
        if not EnnardStabBoost.Enabled then return end
        if not Player.Character then return end
        
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local isStabbing = EnnardStabBoost.IsStabAnimation()
        
        if isStabbing and not EnnardStabBoost.IsStabbing then
            EnnardStabBoost.IsStabbing = true
        end
        
        if EnnardStabBoost.IsStabbing and isStabbing then
            local step = EnnardStabBoost.Speed * dt
            local look = hrp.CFrame.LookVector
            local dir = Vector3.new(look.X, 0, look.Z).Unit
            local newPos = hrp.Position + dir * step
            hrp.CFrame = CFrame.new(newPos.X, hrp.Position.Y, newPos.Z) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)
        elseif EnnardStabBoost.IsStabbing and not isStabbing then
            EnnardStabBoost.IsStabbing = false
        end
    end)
end

function EnnardStabBoost.Stop()
    EnnardStabBoost.Enabled = false
    EnnardStabBoost.IsStabbing = false
    SafeNotify("<font color='#FF0000'>[ Ennard Stab Distance Increase ]</font> Disabled!", 2)
    
    if EnnardStabBoost.Connection then
        EnnardStabBoost.Connection:Disconnect()
        EnnardStabBoost.Connection = nil
    end
end

function EnnardStabBoost.SetSpeed(value)
    EnnardStabBoost.Speed = value
end


local ESP = {
    Survivors = {Enabled = false, Cache = {}, Connections = {}},
    Killers = {Enabled = false, Cache = {}, Connections = {}},
    Generators = {Enabled = false, Cache = {}, Connections = {}},
    Traps = {Enabled = false, Cache = {}, Connections = {}},
    Batteries = {Enabled = false, Cache = {}, Connections = {}},
    Minions = {Enabled = false, Cache = {}, Connections = {}},
    UpdateInterval = 0.5,
    LastUpdate = 0,
    ShowHP = true,
    ShowStyle = true
}


ESP.SurvivorStyles = {
    ["EnergyDrink"] = "Customer",
    ["Medkit"] = "Medic",
    ["Axe"] = "Fighter",
    ["FAZ-TAZER"] = "Guard"
}


ESP.KillerStyles = {
    ["110703795984234"] = "Ennard",
    ["92516484310081"] = "Springtrap",
    ["137609355749227"] = "Springtrap",
    ["79588086477251"] = "Mimic",
    ["88983903450003"] = "Mimic"
}


function ESP.GetHPColor(health, maxHealth)
    local percent = (health / maxHealth) * 100
    if percent >= 65 then
        return Color3.fromRGB(0, 255, 100) 
    elseif percent >= 30 then
        return Color3.fromRGB(255, 255, 0) 
    else
        return Color3.fromRGB(255, 80, 80) 
    end
end


function ESP.GetSurvivorStyle(model)
    
    local assets = model:FindFirstChild("Assets")
    if assets then
        for itemName, styleName in pairs(ESP.SurvivorStyles) do
            local item = assets:FindFirstChild(itemName)
            if item then
                return styleName
            end
        end
    end
    
    
    for itemName, styleName in pairs(ESP.SurvivorStyles) do
        local item = model:FindFirstChild(itemName)
        if item then
            return styleName
        end
    end
    
    return "Unknown"
end


function ESP.GetKillerStyle(model)
    local phases = model:FindFirstChild("Phases")
    if not phases then 
        return "Unknown" 
    end
    
    local phase5 = phases:FindFirstChild("5")
    if not phase5 then 
        return "Unknown" 
    end
    
    
    if phase5:IsA("Sound") and phase5.SoundId ~= "" then
        local soundId = phase5.SoundId:match("%d+")
        if soundId then
            for id, styleName in pairs(ESP.KillerStyles) do
                if soundId == id then
                    return styleName
                end
            end
        end
    end
    
    
    for _, descendant in ipairs(phase5:GetDescendants()) do
        if descendant:IsA("Sound") and descendant.SoundId ~= "" then
            local soundId = descendant.SoundId:match("%d+")
            if soundId then
                for id, styleName in pairs(ESP.KillerStyles) do
                    if soundId == id then
                        return styleName
                    end
                end
            end
        end
    end
    
    return "Unknown"
end


function ESP.CreateHighlight(model, color)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = model
    return highlight
end


function ESP.CreateTextLabel(text, color)
    local textLabel = Drawing.new("Text")
    textLabel.Text = text
    textLabel.Size = 18
    textLabel.Center = true
    textLabel.Outline = true
    textLabel.Color = color
    textLabel.Visible = false
    return textLabel
end


function ESP.AddSurvivor(model)
    if ESP.Survivors.Cache[model] then return end
    
    
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") and child.Name ~= "BBN_Highlight" then
            child:Destroy()
        end
    end
    
    local highlight = ESP.CreateHighlight(model, Color3.fromRGB(0, 255, 100))
    highlight.Name = "BBN_Highlight"
    local nameLabel = ESP.CreateTextLabel(model.Name, Color3.fromRGB(255, 255, 255))
    local styleLabel = ESP.CreateTextLabel("Unknown", Color3.fromRGB(255, 255, 255))
    local hpLabel = ESP.CreateTextLabel("100 HP", Color3.fromRGB(0, 255, 100))
    
    ESP.Survivors.Cache[model] = {
        highlight = highlight,
        nameLabel = nameLabel,
        styleLabel = styleLabel,
        hpLabel = hpLabel,
        model = model,
        lastStyle = "Unknown"
    }
end

function ESP.RemoveSurvivor(model)
    local cache = ESP.Survivors.Cache[model]
    if cache then
        if cache.highlight then cache.highlight:Destroy() end
        if cache.nameLabel then cache.nameLabel.Visible = false cache.nameLabel:Remove() end
        if cache.styleLabel then cache.styleLabel.Visible = false cache.styleLabel:Remove() end
        if cache.hpLabel then cache.hpLabel.Visible = false cache.hpLabel:Remove() end
        ESP.Survivors.Cache[model] = nil
    end
end

function ESP.UpdateSurvivor(cache)
    if not cache.model or not cache.model.Parent then
        ESP.RemoveSurvivor(cache.model)
        return
    end
    
    
    for _, child in ipairs(cache.model:GetChildren()) do
        if child:IsA("Highlight") and child.Name ~= "BBN_Highlight" then
            child:Destroy()
        end
    end
    
    
    if not cache.highlight or not cache.highlight.Parent then
        cache.highlight = ESP.CreateHighlight(cache.model, Color3.fromRGB(0, 255, 100))
        cache.highlight.Name = "BBN_Highlight"
    end
    
    local head = cache.model:FindFirstChild("Head")
    local rootPart = cache.model:FindFirstChild("HumanoidRootPart")
    
    if not head or not rootPart then
        cache.nameLabel.Visible = false
        cache.styleLabel.Visible = false
        cache.hpLabel.Visible = false
        return
    end
    
    local camera = workspace.CurrentCamera
    local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
    
    if distance < 330 then
        
        if ESP.ShowHP then
            local humanoid = cache.model:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                cache.hpLabel.Text = health .. " HP"
                cache.hpLabel.Color = ESP.GetHPColor(health, maxHealth)
                
                local hpPos = head.Position + Vector3.new(0, 2.5, 0)
                local hpVector, hpOnScreen = camera:WorldToViewportPoint(hpPos)
                cache.hpLabel.Position = Vector2.new(hpVector.X, hpVector.Y)
                cache.hpLabel.Visible = hpOnScreen
            else
                cache.hpLabel.Visible = false
            end
        else
            cache.hpLabel.Visible = false
        end
        
        
        local namePos = head.Position + Vector3.new(0, 1.5, 0)
        local nameVector, nameOnScreen = camera:WorldToViewportPoint(namePos)
        
        if nameOnScreen then
            cache.nameLabel.Position = Vector2.new(nameVector.X, nameVector.Y)
            cache.nameLabel.Visible = true
            
            
            if ESP.ShowStyle then
                local currentTime = tick()
                if currentTime - ESP.LastUpdate >= ESP.UpdateInterval then
                    local style = ESP.GetSurvivorStyle(cache.model)
                    if style ~= cache.lastStyle then
                        cache.styleLabel.Text = style
                        cache.lastStyle = style
                    end
                end
                
                
                local stylePos = rootPart.Position + Vector3.new(0, -3.0, 0)
                local styleVector, styleOnScreen = camera:WorldToViewportPoint(stylePos)
                cache.styleLabel.Position = Vector2.new(styleVector.X, styleVector.Y)
                cache.styleLabel.Visible = styleOnScreen
            else
                cache.styleLabel.Visible = false
            end
        else
            cache.nameLabel.Visible = false
            cache.styleLabel.Visible = false
        end
    else
        cache.nameLabel.Visible = false
        cache.styleLabel.Visible = false
        cache.hpLabel.Visible = false
    end
end

function ESP.StartSurvivors()
    ESP.Survivors.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Survivor ESP ]</font> Enabled!", 2)
    
    local alive = workspace:FindFirstChild("PLAYERS")
    if alive then alive = alive:FindFirstChild("ALIVE") end
    if not alive then return end
    
    for _, v in ipairs(alive:GetChildren()) do
        if v:IsA("Model") then
            ESP.AddSurvivor(v)
        end
    end
    
    local addConn = alive.ChildAdded:Connect(function(v)
        if v:IsA("Model") and ESP.Survivors.Enabled then
            ESP.AddSurvivor(v)
        end
    end)
    
    local removeConn = alive.ChildRemoved:Connect(function(v)
        ESP.RemoveSurvivor(v)
    end)
    
    table.insert(ESP.Survivors.Connections, addConn)
    table.insert(ESP.Survivors.Connections, removeConn)
end

function ESP.StopSurvivors()
    ESP.Survivors.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Survivor ESP ]</font> Disabled!", 2)
    
    for model, cache in pairs(ESP.Survivors.Cache) do
        ESP.RemoveSurvivor(model)
    end
    
    for _, conn in ipairs(ESP.Survivors.Connections) do
        conn:Disconnect()
    end
    ESP.Survivors.Connections = {}
end


function ESP.AddKiller(model)
    if ESP.Killers.Cache[model] then return end
    
    
    local playerName = model.Name
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.DisplayName and humanoid.DisplayName ~= "" then
        playerName = humanoid.DisplayName
    end
    
    local highlight = ESP.CreateHighlight(model, Color3.fromRGB(255, 80, 80))
    local nameLabel = ESP.CreateTextLabel(playerName, Color3.fromRGB(255, 255, 255))
    local styleLabel = ESP.CreateTextLabel("Mimic", Color3.fromRGB(255, 80, 80))
    
    ESP.Killers.Cache[model] = {
        highlight = highlight,
        nameLabel = nameLabel,
        styleLabel = styleLabel,
        model = model,
        playerName = playerName,
        lastStyle = "Mimic"
    }
end

function ESP.RemoveKiller(model)
    local cache = ESP.Killers.Cache[model]
    if cache then
        if cache.highlight then cache.highlight:Destroy() end
        if cache.nameLabel then cache.nameLabel.Visible = false cache.nameLabel:Remove() end
        if cache.styleLabel then cache.styleLabel.Visible = false cache.styleLabel:Remove() end
        ESP.Killers.Cache[model] = nil
    end
end

function ESP.UpdateKiller(cache)
    if not cache.model or not cache.model.Parent then
        ESP.RemoveKiller(cache.model)
        return
    end
    
    local head = cache.model:FindFirstChild("Head")
    local rootPart = cache.model:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then
        rootPart = cache.model:FindFirstChild("Torso")
    end
    
    if not head then
        
        for _, part in ipairs(cache.model:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("head") then
                head = part
                break
            end
        end
    end
    
    
    if not head and rootPart then
        head = rootPart
    end
    
    if not head or not rootPart then
        cache.nameLabel.Visible = false
        cache.styleLabel.Visible = false
        return
    end
    
    local camera = workspace.CurrentCamera
    local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
    
    
    local namePos = head.Position + Vector3.new(0, 1.5, 0)
    local nameVector, nameOnScreen = camera:WorldToViewportPoint(namePos)
    
    if nameOnScreen and distance < 330 then
        cache.nameLabel.Position = Vector2.new(nameVector.X, nameVector.Y)
        cache.nameLabel.Visible = true
        
        
        if ESP.ShowStyle then
            local currentTime = tick()
            if currentTime - ESP.LastUpdate >= ESP.UpdateInterval then
                local style = ESP.GetKillerStyle(cache.model)
                if style ~= cache.lastStyle then
                    cache.styleLabel.Text = style
                    cache.lastStyle = style
                end
            end
            
            
            local stylePos = rootPart.Position + Vector3.new(0, -3.0, 0)
            local styleVector, styleOnScreen = camera:WorldToViewportPoint(stylePos)
            cache.styleLabel.Position = Vector2.new(styleVector.X, styleVector.Y)
            cache.styleLabel.Visible = styleOnScreen
        else
            cache.styleLabel.Visible = false
        end
    else
        cache.nameLabel.Visible = false
        cache.styleLabel.Visible = false
    end
end

function ESP.StartKillers()
    ESP.Killers.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Killer ESP ]</font> Enabled!", 2)
    
    local killers = workspace:FindFirstChild("PLAYERS")
    if killers then killers = killers:FindFirstChild("KILLER") end
    if not killers then return end
    
    for _, v in ipairs(killers:GetChildren()) do
        if v:IsA("Model") then
            ESP.AddKiller(v)
        end
    end
    
    local addConn = killers.ChildAdded:Connect(function(v)
        if v:IsA("Model") and ESP.Killers.Enabled then
            ESP.AddKiller(v)
        end
    end)
    
    local removeConn = killers.ChildRemoved:Connect(function(v)
        ESP.RemoveKiller(v)
    end)
    
    table.insert(ESP.Killers.Connections, addConn)
    table.insert(ESP.Killers.Connections, removeConn)
end

function ESP.StopKillers()
    ESP.Killers.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Killer ESP ]</font> Disabled!", 2)
    
    for model, cache in pairs(ESP.Killers.Cache) do
        ESP.RemoveKiller(model)
    end
    
    for _, conn in ipairs(ESP.Killers.Connections) do
        conn:Disconnect()
    end
    ESP.Killers.Connections = {}
end


function ESP.AddGenerator(model)
    if ESP.Generators.Cache[model] then return end
    
    local highlight = ESP.CreateHighlight(model, Color3.fromRGB(138, 43, 226))
    local textLabel = ESP.CreateTextLabel("Generator", Color3.fromRGB(138, 43, 226))
    
    ESP.Generators.Cache[model] = {
        highlight = highlight,
        textLabel = textLabel,
        model = model,
        isCompleted = false
    }
end

function ESP.RemoveGenerator(model)
    local cache = ESP.Generators.Cache[model]
    if cache then
        if cache.highlight then cache.highlight:Destroy() end
        if cache.textLabel then cache.textLabel.Visible = false cache.textLabel:Remove() end
        ESP.Generators.Cache[model] = nil
    end
end

function ESP.IsGeneratorCompleted(model)
    
    local progress = model:FindFirstChild("Progress")
    if not progress then return false end
    
    local holder = progress:FindFirstChild("Holder")
    if not holder then return false end
    
    local bar = holder:FindFirstChild("Bar")
    if not bar then return false end
    
    local fill = bar:FindFirstChild("Fill")
    if not fill then return false end
    
    local gradient = fill:FindFirstChild("UIGradient")
    if not gradient then return false end
    
    
    if gradient.Offset == Vector2.new(0.5, 0) then
        return true
    end
    
    return false
end

function ESP.UpdateGenerator(cache)
    if not cache.model or not cache.model.Parent then
        ESP.RemoveGenerator(cache.model)
        return
    end
    
    
    local isCompleted = ESP.IsGeneratorCompleted(cache.model)
    
    if isCompleted then
        
        cache.textLabel.Visible = false
        if cache.highlight then
            cache.highlight.Enabled = false
        end
        cache.isCompleted = true
        return
    end
    
    
    cache.isCompleted = false
    if cache.highlight then
        cache.highlight.Enabled = true
    end
    
    local primaryPart = cache.model.PrimaryPart or cache.model:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then
        cache.textLabel.Visible = false
        return
    end
    
    local camera = workspace.CurrentCamera
    local genPos, onScreen = camera:WorldToViewportPoint(primaryPart.Position + Vector3.new(0, 5, 0))
    
    if onScreen then
        cache.textLabel.Position = Vector2.new(genPos.X, genPos.Y)
        cache.textLabel.Visible = true
    else
        cache.textLabel.Visible = false
    end
end

function ESP.StartGenerators()
    ESP.Generators.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Generator ESP ]</font> Enabled!", 2)
    
    
    local maps = workspace:FindFirstChild("MAPS")
    if maps then
        local gameMap = maps:FindFirstChild("GAME MAP")
        if gameMap then
            local generators = gameMap:FindFirstChild("Generators")
            if generators then
                for _, v in ipairs(generators:GetChildren()) do
                    if v:IsA("Model") and v.Name == "Generator" then
                        ESP.AddGenerator(v)
                    end
                end
            end
        end
    end
    
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == "Generator" and not ESP.Generators.Cache[v] then
            ESP.AddGenerator(v)
        end
    end
    
    local addConn = workspace.DescendantAdded:Connect(function(v)
        if v:IsA("Model") and v.Name == "Generator" and ESP.Generators.Enabled then
            ESP.AddGenerator(v)
        end
    end)
    
    local removeConn = workspace.DescendantRemoving:Connect(function(v)
        if ESP.Generators.Cache[v] then
            ESP.RemoveGenerator(v)
        end
    end)
    
    table.insert(ESP.Generators.Connections, addConn)
    table.insert(ESP.Generators.Connections, removeConn)
end

function ESP.StopGenerators()
    ESP.Generators.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Generator ESP ]</font> Disabled!", 2)
    
    for model, cache in pairs(ESP.Generators.Cache) do
        ESP.RemoveGenerator(model)
    end
    
    for _, conn in ipairs(ESP.Generators.Connections) do
        conn:Disconnect()
    end
    ESP.Generators.Connections = {}
end


function ESP.AddTrap(model)
    if ESP.Traps.Cache[model] then return end
    
    local highlights = {}
    local trapParts = {
        "Cylinder.001", "Cylinder.002", "Cylinder.003", "Cylinder.004",
        "Cylinder.005", "Cylinder.006", "Cylinder.007", "Cylinder.008",
        "Cylinder.065", "Cylinder.082", "Cylinder.085"
    }
    
    
    for _, partName in ipairs(trapParts) do
        local part = model:FindFirstChild(partName)
        if part then
            local highlight = ESP.CreateHighlight(part, Color3.fromRGB(255, 80, 80))
            table.insert(highlights, highlight)
        end
    end
    
    local textLabel = ESP.CreateTextLabel("Trap", Color3.fromRGB(255, 80, 80))
    
    ESP.Traps.Cache[model] = {
        highlights = highlights,
        textLabel = textLabel,
        model = model
    }
end

function ESP.RemoveTrap(model)
    local cache = ESP.Traps.Cache[model]
    if cache then
        for _, highlight in ipairs(cache.highlights) do
            if highlight then highlight:Destroy() end
        end
        if cache.textLabel then cache.textLabel.Visible = false cache.textLabel:Remove() end
        ESP.Traps.Cache[model] = nil
    end
end

function ESP.UpdateTrap(cache)
    if not cache.model or not cache.model.Parent then
        ESP.RemoveTrap(cache.model)
        return
    end
    
    
    local referencePart = cache.model:FindFirstChild("Cylinder.001") or cache.model:FindFirstChildWhichIsA("BasePart")
    if not referencePart then
        cache.textLabel.Visible = false
        return
    end
    
    local camera = workspace.CurrentCamera
    local trapPos = referencePart.Position + Vector3.new(0, 5, 0)
    local screenPos, onScreen = camera:WorldToViewportPoint(trapPos)
    
    if onScreen then
        cache.textLabel.Position = Vector2.new(screenPos.X, screenPos.Y)
        cache.textLabel.Visible = true
    else
        cache.textLabel.Visible = false
    end
end

function ESP.StartTraps()
    ESP.Traps.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Trap ESP ]</font> Enabled!", 2)
    
    local ignore = workspace:FindFirstChild("IGNORE")
    if not ignore then return end
    
    
    for _, v in ipairs(ignore:GetChildren()) do
        if v:IsA("Model") and v.Name == "Trap" then
            ESP.AddTrap(v)
        end
    end
    
    local addConn = ignore.ChildAdded:Connect(function(v)
        if v:IsA("Model") and v.Name == "Trap" and ESP.Traps.Enabled then
            ESP.AddTrap(v)
        end
    end)
    
    local removeConn = ignore.ChildRemoved:Connect(function(v)
        if ESP.Traps.Cache[v] then
            ESP.RemoveTrap(v)
        end
    end)
    
    table.insert(ESP.Traps.Connections, addConn)
    table.insert(ESP.Traps.Connections, removeConn)
end

function ESP.StopTraps()
    ESP.Traps.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Trap ESP ]</font> Disabled!", 2)
    
    for model, cache in pairs(ESP.Traps.Cache) do
        ESP.RemoveTrap(model)
    end
    
    for _, conn in ipairs(ESP.Traps.Connections) do
        conn:Disconnect()
    end
    ESP.Traps.Connections = {}
end


function ESP.AddBattery(obj)
    if ESP.Batteries.Cache[obj] then return end
    
    local highlight = ESP.CreateHighlight(obj, Color3.fromRGB(138, 43, 226))
    local textLabel = ESP.CreateTextLabel("Battery", Color3.fromRGB(138, 43, 226))
    
    ESP.Batteries.Cache[obj] = {
        highlight = highlight,
        textLabel = textLabel,
        obj = obj
    }
end

function ESP.RemoveBattery(obj)
    local cache = ESP.Batteries.Cache[obj]
    if cache then
        if cache.highlight then cache.highlight:Destroy() end
        if cache.textLabel then cache.textLabel.Visible = false cache.textLabel:Remove() end
        ESP.Batteries.Cache[obj] = nil
    end
end

function ESP.UpdateBattery(cache)
    if not cache.obj or not cache.obj.Parent then
        ESP.RemoveBattery(cache.obj)
        return
    end
    
    local camera = workspace.CurrentCamera
    local batteryPos, onScreen = camera:WorldToViewportPoint(cache.obj.Position + Vector3.new(0, 3, 0))
    
    if onScreen then
        cache.textLabel.Position = Vector2.new(batteryPos.X, batteryPos.Y)
        cache.textLabel.Visible = true
    else
        cache.textLabel.Visible = false
    end
end

function ESP.StartBatteries()
    ESP.Batteries.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Battery ESP ]</font> Enabled!", 2)
    
    
    local checkConn = RunService.Heartbeat:Connect(function()
        if not ESP.Batteries.Enabled then return end
        
        local ignore = workspace:FindFirstChild("IGNORE")
        if ignore then
            for _, v in ipairs(ignore:GetChildren()) do
                if v:IsA("MeshPart") and v.Name == "Battery" and not ESP.Batteries.Cache[v] then
                    ESP.AddBattery(v)
                end
            end
        end
    end)
    
    local addConn = workspace.DescendantAdded:Connect(function(v)
        if v:IsA("MeshPart") and v.Name == "Battery" and ESP.Batteries.Enabled then
            if v.Parent and v.Parent.Name == "IGNORE" then
                ESP.AddBattery(v)
            end
        end
    end)
    
    local removeConn = workspace.DescendantRemoving:Connect(function(v)
        if ESP.Batteries.Cache[v] then
            ESP.RemoveBattery(v)
        end
    end)
    
    table.insert(ESP.Batteries.Connections, checkConn)
    table.insert(ESP.Batteries.Connections, addConn)
    table.insert(ESP.Batteries.Connections, removeConn)
end

function ESP.StopBatteries()
    ESP.Batteries.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Battery ESP ]</font> Disabled!", 2)
    
    for obj, cache in pairs(ESP.Batteries.Cache) do
        ESP.RemoveBattery(obj)
    end
    
    for _, conn in ipairs(ESP.Batteries.Connections) do
        conn:Disconnect()
    end
    ESP.Batteries.Connections = {}
end


function ESP.AddMinion(model)
    if ESP.Minions.Cache[model] then return end
    
    local rootPart = model:FindFirstChild("RootPart")
    if not rootPart then return end
    
    local highlight = ESP.CreateHighlight(rootPart, Color3.fromRGB(255, 80, 80))
    local textLabel = ESP.CreateTextLabel("Minion", Color3.fromRGB(255, 80, 80))
    
    ESP.Minions.Cache[model] = {
        highlight = highlight,
        textLabel = textLabel,
        model = model,
        rootPart = rootPart
    }
end

function ESP.RemoveMinion(model)
    local cache = ESP.Minions.Cache[model]
    if cache then
        if cache.highlight then cache.highlight:Destroy() end
        if cache.textLabel then cache.textLabel.Visible = false cache.textLabel:Remove() end
        ESP.Minions.Cache[model] = nil
    end
end

function ESP.UpdateMinion(cache)
    if not cache.model or not cache.model.Parent or not cache.rootPart or not cache.rootPart.Parent then
        ESP.RemoveMinion(cache.model)
        return
    end
    
    local camera = workspace.CurrentCamera
    local minionPos, onScreen = camera:WorldToViewportPoint(cache.rootPart.Position + Vector3.new(0, 4, 0))
    
    if onScreen then
        cache.textLabel.Position = Vector2.new(minionPos.X, minionPos.Y)
        cache.textLabel.Visible = true
    else
        cache.textLabel.Visible = false
    end
end

function ESP.StartMinions()
    ESP.Minions.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Minion ESP ]</font> Enabled!", 2)
    
    
    local ignore = workspace:FindFirstChild("IGNORE")
    if ignore then
        for _, v in ipairs(ignore:GetChildren()) do
            if v:IsA("Model") and v.Name == "Minion" and v:FindFirstChild("RootPart") then
                ESP.AddMinion(v)
            end
        end
    end
    
    local addConn = workspace.DescendantAdded:Connect(function(v)
        if v:IsA("Model") and v.Name == "Minion" and ESP.Minions.Enabled then
            local parent = v.Parent
            if parent and parent.Name == "IGNORE" then
                task.wait(0.1) 
                if v:FindFirstChild("RootPart") then
                    ESP.AddMinion(v)
                end
            end
        end
    end)
    
    local removeConn = workspace.DescendantRemoving:Connect(function(v)
        if ESP.Minions.Cache[v] then
            ESP.RemoveMinion(v)
        end
    end)
    
    table.insert(ESP.Minions.Connections, addConn)
    table.insert(ESP.Minions.Connections, removeConn)
end

function ESP.StopMinions()
    ESP.Minions.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Minion ESP ]</font> Disabled!", 2)
    
    for model, cache in pairs(ESP.Minions.Cache) do
        ESP.RemoveMinion(model)
    end
    
    for _, conn in ipairs(ESP.Minions.Connections) do
        conn:Disconnect()
    end
    ESP.Minions.Connections = {}
end


function ESP.RenderLoop()
    while true do
        local currentTime = tick()
        
        if ESP.Survivors.Enabled then
            for model, cache in pairs(ESP.Survivors.Cache) do
                ESP.UpdateSurvivor(cache)
            end
        end
        
        if ESP.Killers.Enabled then
            for model, cache in pairs(ESP.Killers.Cache) do
                ESP.UpdateKiller(cache)
            end
        end
        
        if ESP.Generators.Enabled then
            for model, cache in pairs(ESP.Generators.Cache) do
                ESP.UpdateGenerator(cache)
            end
        end
        
        if ESP.Traps.Enabled then
            for model, cache in pairs(ESP.Traps.Cache) do
                ESP.UpdateTrap(cache)
            end
        end
        
        if ESP.Batteries.Enabled then
            for model, cache in pairs(ESP.Batteries.Cache) do
                ESP.UpdateBattery(cache)
            end
        end
        
        if ESP.Minions.Enabled then
            for model, cache in pairs(ESP.Minions.Cache) do
                ESP.UpdateMinion(cache)
            end
        end
        
        
        if currentTime - ESP.LastUpdate >= ESP.UpdateInterval then
            ESP.LastUpdate = currentTime
        end
        
        task.wait()
    end
end


task.spawn(ESP.RenderLoop)


local Crosshair = {
    Enabled = false,
    Mode = "mouse",
    Width = 2,
    Length = 12,
    Radius = 6,
    Gap = 4,
    Color = Color3.fromRGB(166, 186, 255),
    Spin = false,
    SpinSpeed = 100,
    Resize = false,
    ResizeSpeed = 3,
    ResizeMin = 8,
    ResizeMax = 16,
    ShowText = true,
    drawings = {},
    connection = nil
}


if Menu.Accent and Menu.Accent ~= DefaultAccentColor then
    Crosshair.Color = Menu.Accent
end

function Crosshair.CreateDrawing(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props) do d[k] = v end
    return d
end

function Crosshair.Initialize()
    Crosshair.Destroy()
    Crosshair.drawings.lines = {}
    
    for i = 1, 4 do
        Crosshair.drawings.lines[i] = Crosshair.CreateDrawing("Line", {Visible = false, Thickness = Crosshair.Width, Color = Crosshair.Color})
    end
    
    Crosshair.drawings.dot = Crosshair.CreateDrawing("Circle", {Visible = false, Radius = 2, Color = Crosshair.Color, Filled = true, Thickness = 1})
    
    Crosshair.drawings.text = {
        Crosshair.CreateDrawing("Text", {Text = "Evo", Size = 14, Font = 0, Outline = true, Color = Color3.new(1, 1, 1), Visible = false, Center = true}),
        Crosshair.CreateDrawing("Text", {Text = "Hub", Size = 14, Font = 0, Outline = true, Color = Crosshair.Color, Visible = false, Center = true})
    }
    Crosshair.StartRender()
end

function Crosshair.StartRender()
    if Crosshair.connection then Crosshair.connection:Disconnect() end
    Crosshair.connection = RunService.RenderStepped:Connect(function()
        if not Crosshair.Enabled then
            for i = 1, 4 do if Crosshair.drawings.lines[i] then Crosshair.drawings.lines[i].Visible = false end end
            if Crosshair.drawings.dot then Crosshair.drawings.dot.Visible = false end
            if Crosshair.drawings.text then for _, t in ipairs(Crosshair.drawings.text) do t.Visible = false end end
            return
        end
        
        
        local pos
        if Crosshair.Mode == "center" then
            pos = workspace.CurrentCamera.ViewportSize / 2
        else
            pos = UserInputService:GetMouseLocation()
        end
        
        local length = Crosshair.Length
        local gap = Crosshair.Gap
        local spinOffset = 0
        
        if Crosshair.Spin then
            spinOffset = (tick() * Crosshair.SpinSpeed) % 360
        end
        if Crosshair.Resize then
            length = Crosshair.ResizeMin + math.abs(math.sin(tick() * Crosshair.ResizeSpeed)) * (Crosshair.ResizeMax - Crosshair.ResizeMin)
        end
        
        
        local directions = {
            {0, -1},  
            {0, 1},   
            {-1, 0},  
            {1, 0}    
        }
        
        for i = 1, 4 do
            local line = Crosshair.drawings.lines[i]
            if line then
                local dir = directions[i]
                local angle = math.rad(spinOffset)
                local dx, dy = dir[1], dir[2]
                
                if Crosshair.Spin then
                    local cos, sin = math.cos(angle), math.sin(angle)
                    local newDx = dx * cos - dy * sin
                    local newDy = dx * sin + dy * cos
                    dx, dy = newDx, newDy
                end
                
                local startX = pos.X + dx * gap
                local startY = pos.Y + dy * gap
                local endX = pos.X + dx * (gap + length)
                local endY = pos.Y + dy * (gap + length)
                
                line.From = Vector2.new(startX, startY)
                line.To = Vector2.new(endX, endY)
                line.Color = Crosshair.Color
                line.Thickness = Crosshair.Width
                line.Visible = true
            end
        end
        
        
        if Crosshair.drawings.dot then
            Crosshair.drawings.dot.Position = pos
            Crosshair.drawings.dot.Color = Crosshair.Color
            Crosshair.drawings.dot.Visible = true
        end
        
        
        if Crosshair.drawings.text and Crosshair.ShowText then
            local t1, t2 = Crosshair.drawings.text[1], Crosshair.drawings.text[2]
            local totalW = t1.TextBounds.X + t2.TextBounds.X
            local textY = pos.Y + gap + length + 12
            t1.Position = Vector2.new(pos.X - totalW/2 + t1.TextBounds.X/2, textY)
            t2.Position = Vector2.new(pos.X - totalW/2 + t1.TextBounds.X + t2.TextBounds.X/2, textY)
            t1.Visible = true
            t2.Visible = true
            t2.Color = Crosshair.Color
        elseif Crosshair.drawings.text then
            Crosshair.drawings.text[1].Visible = false
            Crosshair.drawings.text[2].Visible = false
        end
    end)
end

function Crosshair.Destroy()
    if Crosshair.connection then Crosshair.connection:Disconnect() Crosshair.connection = nil end
    if Crosshair.drawings.lines then for _, d in pairs(Crosshair.drawings.lines) do if d then d:Remove() end end end
    if Crosshair.drawings.dot then Crosshair.drawings.dot:Remove() end
    if Crosshair.drawings.text then for _, d in pairs(Crosshair.drawings.text) do if d then d:Remove() end end end
    Crosshair.drawings = {}
end

function Crosshair.Start()
    Crosshair.Enabled = true
    Crosshair.Initialize()
    SafeNotify("<font color='#FF0000'>[ Crosshair ]</font> Enabled!", 2)
end

function Crosshair.Stop()
    Crosshair.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Crosshair ]</font> Disabled!", 2)
end


Menu.Tab("Main")
Menu.Tab("Player")
Menu.Tab("Visuals")
Menu.Tab("Settings")


local FullBright = {
    Enabled = false,
    OldLighting = {},
    Connection = nil
}

function FullBright.Apply()
    local lighting = game:GetService("Lighting")
    lighting.Brightness = 5
    lighting.ClockTime = 14
    lighting.FogEnd = 100000
    lighting.GlobalShadows = false
    lighting.Ambient = Color3.fromRGB(255, 255, 255)
end

function FullBright.Start()
    FullBright.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Full Bright ]</font> Enabled!", 2)
    
    local lighting = game:GetService("Lighting")
    
    
    if not next(FullBright.OldLighting) then
        FullBright.OldLighting.Brightness = lighting.Brightness
        FullBright.OldLighting.ClockTime = lighting.ClockTime
        FullBright.OldLighting.FogEnd = lighting.FogEnd
        FullBright.OldLighting.GlobalShadows = lighting.GlobalShadows
        FullBright.OldLighting.Ambient = lighting.Ambient
    end
    
    
    FullBright.Apply()
    
    
    if FullBright.Connection then
        FullBright.Connection:Disconnect()
    end
    
    FullBright.Connection = RunService.Heartbeat:Connect(function()
        if not FullBright.Enabled then return end
        FullBright.Apply()
    end)
end

function FullBright.Stop()
    FullBright.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Full Bright ]</font> Disabled!", 2)
    
    if FullBright.Connection then
        FullBright.Connection:Disconnect()
        FullBright.Connection = nil
    end
    
    local lighting = game:GetService("Lighting")
    
    
    if next(FullBright.OldLighting) then
        lighting.Brightness = FullBright.OldLighting.Brightness
        lighting.ClockTime = FullBright.OldLighting.ClockTime
        lighting.FogEnd = FullBright.OldLighting.FogEnd
        lighting.GlobalShadows = FullBright.OldLighting.GlobalShadows
        lighting.Ambient = FullBright.OldLighting.Ambient
        FullBright.OldLighting = {}
    end
end


local InstantInteract = {
    Enabled = false,
    Connection = nil,
    HeartbeatConnection = nil,
    ProcessedPrompts = {} 
}

function InstantInteract.IsGeneratorPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return false end
    
    
    local parent = prompt.Parent
    if not parent or not parent.Name:match("^Point%d+$") then return false end
    
    local rootPart = parent.Parent
    if not rootPart or rootPart.Name ~= "RootPart" then return false end
    
    local generator = rootPart.Parent
    if not generator or generator.Name ~= "Generator" then return false end
    
    local generators = generator.Parent
    if not generators or generators.Name ~= "Generators" then return false end
    
    local gameMap = generators.Parent
    if not gameMap or gameMap.Name ~= "GAME MAP" then return false end
    
    local maps = gameMap.Parent
    if not maps or maps.Name ~= "MAPS" then return false end
    
    return maps.Parent == workspace
end

function InstantInteract.IsBatteryPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return false end
    
    
    local parent = prompt.Parent
    if not parent or parent.Name ~= "Attachment" then return false end
    
    local battery = parent.Parent
    if not battery or battery.Name ~= "Battery" then return false end
    
    local ignore = battery.Parent
    if not ignore or ignore.Name ~= "IGNORE" then return false end
    
    return ignore.Parent == workspace
end

function InstantInteract.ProcessPrompt(prompt)
    if not InstantInteract.IsGeneratorPrompt(prompt) and not InstantInteract.IsBatteryPrompt(prompt) then return end
    if InstantInteract.ProcessedPrompts[prompt] then return end
    
    
    InstantInteract.ProcessedPrompts[prompt] = prompt.HoldDuration
    prompt.HoldDuration = 0
end

function InstantInteract.Start()
    InstantInteract.Enabled = true
    SafeNotify("<font color='#FF0000'>[ Instant Interact ]</font> Enabled!", 2)
    
    
    local maps = workspace:FindFirstChild("MAPS")
    if maps then
        local gameMap = maps:FindFirstChild("GAME MAP")
        if gameMap then
            local generators = gameMap:FindFirstChild("Generators")
            if generators then
                for _, generator in ipairs(generators:GetChildren()) do
                    if generator.Name == "Generator" then
                        local rootPart = generator:FindFirstChild("RootPart")
                        if rootPart then
                            for _, point in ipairs(rootPart:GetChildren()) do
                                if point.Name:match("^Point%d+$") then
                                    for _, child in ipairs(point:GetChildren()) do
                                        if child:IsA("ProximityPrompt") then
                                            InstantInteract.ProcessPrompt(child)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    
    if InstantInteract.HeartbeatConnection then
        InstantInteract.HeartbeatConnection:Disconnect()
    end
    
    InstantInteract.HeartbeatConnection = RunService.Heartbeat:Connect(function()
        if not InstantInteract.Enabled then return end
        
        local ignore = workspace:FindFirstChild("IGNORE")
        if ignore then
            for _, battery in ipairs(ignore:GetChildren()) do
                if battery:IsA("MeshPart") and battery.Name == "Battery" then
                    
                    for _, descendant in ipairs(battery:GetDescendants()) do
                        if descendant:IsA("ProximityPrompt") then
                            InstantInteract.ProcessPrompt(descendant)
                        end
                    end
                end
            end
        end
    end)
    
    
    if InstantInteract.Connection then
        InstantInteract.Connection:Disconnect()
    end
    
    InstantInteract.Connection = workspace.DescendantAdded:Connect(function(descendant)
        if InstantInteract.Enabled and descendant:IsA("ProximityPrompt") then
            InstantInteract.ProcessPrompt(descendant)
        end
    end)
end

function InstantInteract.Stop()
    InstantInteract.Enabled = false
    SafeNotify("<font color='#FF0000'>[ Instant Interact ]</font> Disabled!", 2)
    
    if InstantInteract.Connection then
        InstantInteract.Connection:Disconnect()
        InstantInteract.Connection = nil
    end
    
    if InstantInteract.HeartbeatConnection then
        InstantInteract.HeartbeatConnection:Disconnect()
        InstantInteract.HeartbeatConnection = nil
    end
    
    
    for prompt, originalDuration in pairs(InstantInteract.ProcessedPrompts) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = originalDuration
        end
    end
    
    InstantInteract.ProcessedPrompts = {}
end


local UIState = {
    MenuVisible = true,
    ToggleGUIKey = Enum.KeyCode.K,
    WatermarkUI = nil,
    KeybindsUI = nil,
    ShowWatermark = not Menu.IsMobile,
    ShowKeybinds = not Menu.IsMobile
}


Menu.Container("Main", "Auto Generator", "Left")
Menu.Container("Main", "Auto Barricade", "Right")
Menu.Container("Main", "Auto Shake", "Left")
Menu.Container("Main", "Anti Trap", "Right")
Menu.Container("Main", "Full Bright", "Left")
Menu.Container("Main", "Instant Interact", "Right")


Menu.CheckBox("Main", "Auto Generator", "Auto Generator", false, function(enabled)
    if enabled then
        AutoGenerator.Start()
    else
        AutoGenerator.Stop()
    end
end, "Automatically does generator tasks")

Menu.Slider("Main", "Auto Generator", "Delay", 0.7, 7, 0.7, "sec", 1, function(value)
    AutoGenerator.SetDelay(value)
end, "Delay before sending event")


Menu.CheckBox("Main", "Auto Barricade", "Auto Barricade", false, function(enabled)
    if enabled then
        AutoBarricade.Start()
    else
        AutoBarricade.Stop()
    end
end, "Forces barricading dot in the middle")


Menu.CheckBox("Main", "Auto Shake", "Auto Shake", false, function(enabled)
    if enabled then
        AutoShake.Start()
    else
        AutoShake.Stop()
    end
end, "Automatically shakes camera when WireyesUI appears")


Menu.CheckBox("Main", "Anti Trap", "Anti Springtrap Traps", false, function(enabled)
    if enabled then
        AntiTrap.Start()
    else
        AntiTrap.Stop()
    end
end, "Blocks access to Springtrap traps with invisible walls")


Menu.CheckBox("Main", "Full Bright", "Full Bright", false, function(enabled)
    if enabled then
        FullBright.Start()
    else
        FullBright.Stop()
    end
end, "Removes darkness and fog")


Menu.CheckBox("Main", "Instant Interact", "Instant Interact", false, function(enabled)
    if enabled then
        InstantInteract.Start()
    else
        InstantInteract.Stop()
    end
end, "Sets all ProximityPrompt HoldDuration to 0")


Menu.Container("Player", "Security Guard", "Left")
Menu.Container("Player", "Springtrap", "Right")
Menu.Container("Player", "Mimic", "Left")
Menu.Container("Player", "Fighter", "Right")
Menu.Container("Player", "Ennard", "Left")
Menu.Container("Player", "Stamina", "Left")


UIState.TazerAimbotCheckBox = Menu.CheckBox("Player", "Security Guard", "Tazer Aimbot", false, function(enabled)
    if enabled then
        TazerAimbot.KeybindActive = true
        TazerAimbot.Start()
        KeybindTracker.Update("Tazer Aimbot", true, function() return TazerAimbot.CurrentKey end)
        
        if TazerAimbot.IsAnimationPlaying() then
            TazerAimbot.StartAiming()
            TazerAimbot.LastAnimationState = true
        end
    else
        TazerAimbot.KeybindActive = false
        TazerAimbot.Stop()
        KeybindTracker.Update("Tazer Aimbot", false)
    end
end, "Auto aim at killer when using tazer")

Menu.Hotkey("Player", "Security Guard", "Aimbot Keybind", Enum.KeyCode.X, function(key)
    TazerAimbot.CurrentKey = key
    KeybindTracker.Refresh("Tazer Aimbot")
end)

Menu.CheckBox("Player", "Security Guard", "Walls", true, function(enabled)
    TazerAimbot.SetWalls(enabled)
end, "Aim through walls")

Menu.Slider("Player", "Security Guard", "Prediction", 0, 10, 2, "studs", 1, function(value)
    TazerAimbot.SetPrediction(value)
end, "Predict target movement")


UIState.AxeAimbotCheckBox = Menu.CheckBox("Player", "Springtrap", "Axe Aimbot", false, function(enabled)
    if enabled then
        AxeAimbot.KeybindActive = true
        AxeAimbot.Start()
        KeybindTracker.Update("Axe Aimbot", true, function() return AxeAimbot.CurrentKey end)
        
        if AxeAimbot.IsAnimationPlaying() then
            AxeAimbot.StartAiming()
            AxeAimbot.LastAnimationState = true
        end
    else
        AxeAimbot.KeybindActive = false
        AxeAimbot.Stop()
        KeybindTracker.Update("Axe Aimbot", false)
    end
end, "Auto aim at survivors when using axe")

Menu.Hotkey("Player", "Springtrap", "Aimbot Keybind", Enum.KeyCode.X, function(key)
    AxeAimbot.CurrentKey = key
    KeybindTracker.Refresh("Axe Aimbot")
end)

Menu.CheckBox("Player", "Springtrap", "Walls", true, function(enabled)
    AxeAimbot.SetWalls(enabled)
end, "Aim through walls")

Menu.Slider("Player", "Springtrap", "Prediction", 0, 10, 2, "studs", 1, function(value)
    AxeAimbot.SetPrediction(value)
end, "Predict target movement")

Menu.CheckBox("Player", "Springtrap", "Charge Distance Increase", false, function(enabled)
    if enabled then
        ChargeBoost.Start()
    else
        ChargeBoost.Stop()
    end
end, "Increase charge attack distance")

Menu.Slider("Player", "Springtrap", "Charge Speed", 0, 10, 1, "studs/s", 1, function(value)
    ChargeBoost.SetSpeed(value * 6)
end, "Speed of charge boost")


UIState.GrabAimbotCheckBox = Menu.CheckBox("Player", "Mimic", "Grab Aimbot", false, function(enabled)
    if enabled then
        GrabAimbot.KeybindActive = true
        GrabAimbot.Start()
        KeybindTracker.Update("Mimic Grab", true, function() return GrabAimbot.CurrentKey end)
        
        if GrabAimbot.IsGrabAnimationPlaying() then
            GrabAimbot.StartAiming()
        end
    else
        GrabAimbot.KeybindActive = false
        GrabAimbot.Stop()
        KeybindTracker.Update("Mimic Grab", false)
    end
end, "Auto aim at survivors when grabbing")

Menu.Hotkey("Player", "Mimic", "Aimbot Keybind", Enum.KeyCode.X, function(key)
    GrabAimbot.CurrentKey = key
    KeybindTracker.Refresh("Mimic Grab")
end)

Menu.CheckBox("Player", "Mimic", "Walls", true, function(enabled)
    GrabAimbot.SetWalls(enabled)
end, "Aim through walls")

Menu.Slider("Player", "Mimic", "Prediction", 0, 10, 2, "studs", 1, function(value)
    GrabAimbot.SetPrediction(value)
end, "Predict target movement")

Menu.CheckBox("Player", "Mimic", "Grab Distance Increase", false, function(enabled)
    if enabled then
        GrabBoost.Start()
    else
        GrabBoost.Stop()
    end
end, "Increase grab attack distance")

Menu.Slider("Player", "Mimic", "Grab Speed", 0, 10, 1, "studs/s", 1, function(value)
    GrabBoost.SetSpeed(value * 6)
end, "Speed of grab boost")


UIState.SwingAimbotCheckBox = Menu.CheckBox("Player", "Fighter", "Swing Aimbot", false, function(enabled)
    if enabled then
        SwingAimbot.KeybindActive = true
        SwingAimbot.Start()
        KeybindTracker.Update("Swing Aimbot", true, function() return SwingAimbot.CurrentKey end)
        
        if SwingAimbot.IsSwingAnimationPlaying() then
            SwingAimbot.StartAiming()
        end
    else
        SwingAimbot.KeybindActive = false
        SwingAimbot.Stop()
        KeybindTracker.Update("Swing Aimbot", false)
    end
end, "Auto aim at killer when swinging axe")

Menu.Hotkey("Player", "Fighter", "Aimbot Keybind", Enum.KeyCode.V, function(key)
    SwingAimbot.CurrentKey = key
    KeybindTracker.Refresh("Swing Aimbot")
end)

Menu.CheckBox("Player", "Fighter", "Walls", true, function(enabled)
    SwingAimbot.SetWalls(enabled)
end, "Aim through walls")

Menu.Slider("Player", "Fighter", "Prediction", 0, 10, 2, "studs", 1, function(value)
    SwingAimbot.SetPrediction(value)
end, "Predict target movement")

Menu.CheckBox("Player", "Fighter", "Swing Distance Increase", false, function(enabled)
    if enabled then
        SwingBoost.Start()
    else
        SwingBoost.Stop()
    end
end, "Increase swing attack distance")

Menu.Slider("Player", "Fighter", "Swing Speed", 0, 10, 1, "studs/s", 1, function(value)
    SwingBoost.SetSpeed(value * 6)
end, "Speed of swing boost")

Menu.CheckBox("Player", "Fighter", "Hide Block Anim", false, function(enabled)
    if enabled then
        HideBlockAnimation.Start()
    else
        HideBlockAnimation.Stop()
    end
end, "Hides block animation and replaces it")

UIState.AutoBlockCheckBox = Menu.CheckBox("Player", "Fighter", "Auto Block", false, function(enabled)
    if enabled then
        AutoBlock.Start()
        KeybindTracker.Update("Auto Block", true, function() return AutoBlock.CurrentKey end)
    else
        AutoBlock.Stop()
        KeybindTracker.Update("Auto Block", false)
    end
end, "Automatically blocks killer attacks")

Menu.Hotkey("Player", "Fighter", "Auto Block Keybind", Enum.KeyCode.X, function(key)
    AutoBlock.CurrentKey = key
end)

Menu.Slider("Player", "Fighter", "Block Distance", 10, 20, 20, "studs", 1, function(value)
    AutoBlock.SetMinDistance(value)
end, "Minimum distance to block attacks")


UIState.EnnardGrabAimbotCheckBox = Menu.CheckBox("Player", "Ennard", "Grab Aimbot", false, function(enabled)
    if enabled then
        EnnardGrabAimbot.KeybindActive = true
        EnnardGrabAimbot.Start()
        KeybindTracker.Update("Ennard Grab", true, function() return EnnardGrabAimbot.CurrentKey end)
        if EnnardGrabAimbot.IsGrabAnimationPlaying() then
            EnnardGrabAimbot.StartAiming()
        end
    else
        EnnardGrabAimbot.KeybindActive = false
        EnnardGrabAimbot.Stop()
        KeybindTracker.Update("Ennard Grab", false)
    end
end, "Auto aim at survivors when grabbing")

Menu.Hotkey("Player", "Ennard", "Grab Keybind", Enum.KeyCode.X, function(key)
    EnnardGrabAimbot.CurrentKey = key
    KeybindTracker.Refresh("Ennard Grab")
end)

Menu.CheckBox("Player", "Ennard", "Walls", true, function(enabled)
    EnnardGrabAimbot.SetWalls(enabled)
end, "Aim through walls")

Menu.Slider("Player", "Ennard", "Grab Prediction", 0, 10, 2, "studs", 1, function(value)
    EnnardGrabAimbot.SetPrediction(value)
end, "Predict target movement")

UIState.EnnardStabAimbotCheckBox = Menu.CheckBox("Player", "Ennard", "Stab Aimbot", false, function(enabled)
    if enabled then
        EnnardStabAimbot.KeybindActive = true
        EnnardStabAimbot.Start()
        KeybindTracker.Update("Ennard Stab", true, function() return EnnardStabAimbot.CurrentKey end)
        if EnnardStabAimbot.IsStabAnimationPlaying() then
            EnnardStabAimbot.StartAiming()
        end
    else
        EnnardStabAimbot.KeybindActive = false
        EnnardStabAimbot.Stop()
        KeybindTracker.Update("Ennard Stab", false)
    end
end, "Auto aim at survivors when stabbing")

Menu.Hotkey("Player", "Ennard", "Stab Keybind", Enum.KeyCode.X, function(key)
    EnnardStabAimbot.CurrentKey = key
    KeybindTracker.Refresh("Ennard Stab")
end)

Menu.CheckBox("Player", "Ennard", "Walls", true, function(enabled)
    EnnardStabAimbot.SetWalls(enabled)
end, "Aim through walls")

Menu.Slider("Player", "Ennard", "Stab Prediction", 0, 10, 2, "studs", 1, function(value)
    EnnardStabAimbot.SetPrediction(value)
end, "Predict target movement")

Menu.CheckBox("Player", "Ennard", "Stab Distance Increase", false, function(enabled)
    if enabled then
        EnnardStabBoost.Start()
    else
        EnnardStabBoost.Stop()
    end
end, "Increase stab attack distance")

Menu.Slider("Player", "Ennard", "Stab Speed", 0, 10, 1, "studs/s", 1, function(value)
    EnnardStabBoost.SetSpeed(value * 6)
end, "Speed of stab boost")


Menu.CheckBox("Player", "Stamina", "Infinity Stamina", false, function(enabled)
    if enabled then
        InfinityStamina.Start()
    else
        InfinityStamina.Stop()
    end
end, "Infinite stamina (only in ALIVE)")


Menu.Container("Visuals", "ESP", "Left")
Menu.Container("Visuals", "UI Elements", "Right")


Menu.CheckBox("Visuals", "ESP", "Survivor ESP", false, function(v)
    if v then
        ESP.StartSurvivors()
    else
        ESP.StopSurvivors()
    end
end, "Highlight all survivors in green")

Menu.CheckBox("Visuals", "ESP", "Killer ESP", false, function(v)
    if v then
        ESP.StartKillers()
    else
        ESP.StopKillers()
    end
end, "Highlight the killer in red")

Menu.CheckBox("Visuals", "ESP", "Generator ESP", false, function(v)
    if v then
        ESP.StartGenerators()
    else
        ESP.StopGenerators()
    end
end, "Highlight all generators in purple")

Menu.CheckBox("Visuals", "ESP", "Battery ESP", false, function(v)
    if v then
        ESP.StartBatteries()
    else
        ESP.StopBatteries()
    end
end, "Highlight all batteries in purple")

Menu.CheckBox("Visuals", "ESP", "Minion ESP", false, function(v)
    if v then
        ESP.StartMinions()
    else
        ESP.StopMinions()
    end
end, "Highlight all minions in red")

Menu.CheckBox("Visuals", "ESP", "Trap ESP", false, function(v)
    if v then
        ESP.StartTraps()
    else
        ESP.StopTraps()
    end
end, "Highlight all traps in red")

Menu.CheckBox("Visuals", "ESP", "Show Style", true, function(v)
    ESP.ShowStyle = v
end, "Show player style at feet")

Menu.CheckBox("Visuals", "ESP", "Show HP", true, function(v)
    ESP.ShowHP = v
end, "Show player HP at feet")



Menu.CheckBox("Visuals", "UI Elements", "Show Watermark", not Menu.IsMobile, function(v)
    UIState.ShowWatermark = v
    if UIState.WatermarkUI then
        UIState.WatermarkUI:SetVisible(v)
    end
end)

Menu.CheckBox("Visuals", "UI Elements", "Show Keybinds", not Menu.IsMobile, function(v)
    UIState.ShowKeybinds = v
    if UIState.KeybindsUI then
        UIState.KeybindsUI:SetVisible(v)
    end
end)


Menu.Container("Visuals", "Crosshair", "Left")


Menu.CheckBox("Visuals", "Crosshair", "Crosshair", not Menu.IsMobile, function(v)
    if v then Crosshair.Start() else Crosshair.Stop() end
end)

Menu.CheckBox("Visuals", "Crosshair", "Show Text", true, function(v)
    Crosshair.ShowText = v
end)

Menu.CheckBox("Visuals", "Crosshair", "Spin", true, function(v)
    Crosshair.Spin = v
end)

Menu.CheckBox("Visuals", "Crosshair", "Resize", false, function(v)
    Crosshair.Resize = v
end)

Menu.Slider("Visuals", "Crosshair", "Length", 5, 25, 12, "px", 0, function(v)
    Crosshair.Length = v
end)

Menu.Slider("Visuals", "Crosshair", "Gap", 0, 15, 4, "px", 0, function(v)
    Crosshair.Gap = v
end)

Menu.Slider("Visuals", "Crosshair", "Width", 1, 5, 2, "px", 0, function(v)
    Crosshair.Width = v
end)


Menu.Container("Settings", "Menu", "Left")

Menu.Hotkey("Settings", "Menu", "Toggle GUI Keybind", Enum.KeyCode.K, function(key)
    UIState.ToggleGUIKey = key
end)


local DefaultAccentColor = Color3.fromHex("#FF0000")


local function LoadSavedUIColor()
    if Menu.Config and Menu.Config.getConfigValue then
        local savedColorHex = Menu.Config.getConfigValue("UIColor")
        if savedColorHex and type(savedColorHex) == "string" then
            local success, color = pcall(function()
                return Color3.fromHex(savedColorHex)
            end)
            if success and color then
                Menu.Accent = color
                Crosshair.Color = color
                return color
            end
        end
    end
    return DefaultAccentColor
end


local savedColor = LoadSavedUIColor()
local UIColorPicker = Menu.ColorPicker("Settings", "Menu", "UI Color", savedColor, 0, function(color)
    Menu.Accent = color
    Crosshair.Color = color
    
    if Menu.Config and Menu.Config.setConfigValue then
        Menu.Config.setConfigValue("UIColor", "#" .. color:ToHex():upper())
    end
end)


Menu.Button("Settings", "Menu", "Reset UI Color", function()
    Menu.Accent = DefaultAccentColor
    Crosshair.Color = DefaultAccentColor
    if UIColorPicker and UIColorPicker.SetValue then
        UIColorPicker:SetValue(DefaultAccentColor, 0)
    end
    
    if Menu.Config and Menu.Config.setConfigValue then
        Menu.Config.setConfigValue("UIColor", "#FF0000")
    end
    SafeNotify("<font color='#FF0000'>[ Settings ]</font> UI Color reset to default!", 2)
end)


local uiScaleOptions = {"50%", "70%", "75%", "100%", "115%", "150%", "200%"}
local defaultScale = Menu.IsMobile and "70%" or "100%"
local uiScaleDropdown = Menu.ComboBox("Settings", "Menu", "UI Scale", defaultScale, uiScaleOptions, function(value)
    local cleanValue = string.gsub(value, "%%", "")
    local scaleNum = tonumber(cleanValue)
    if scaleNum and Menu.SetUIScale then
        Menu:SetUIScale(scaleNum)
    end
end)


Menu.Button("Settings", "Menu", "Reset UI Scale", function()
    local defaultSize = Menu.IsMobile and 70 or 100
    if Menu.SetUIScale then
        Menu:SetUIScale(defaultSize)
    end
    if uiScaleDropdown and uiScaleDropdown.SetValue then
        uiScaleDropdown:SetValue(defaultSize .. "%")
    end
    SafeNotify("UI Scale reset to " .. defaultSize .. "%", 2)
end)


UIState.WatermarkUI = Menu.Watermark()
UIState.KeybindsUI = Menu.Keybinds()
KeybindTracker.ui = UIState.KeybindsUI


if Menu.Config and Menu.Config.onConfigLoaded then
    Menu.Config.onConfigLoaded(function()
        task.delay(0.5, function()
            
            if Menu.Config.getConfigValue then
                local savedColorHex = Menu.Config.getConfigValue("UIColor")
                if savedColorHex and type(savedColorHex) == "string" then
                    local success, color = pcall(function()
                        return Color3.fromHex(savedColorHex)
                    end)
                    if success and color then
                        Menu.Accent = color
                        Crosshair.Color = color
                        if UIColorPicker and UIColorPicker.SetValue then
                            UIColorPicker:SetValue(color, 0)
                        end
                    end
                end
            end
        end)
    end)
end


if ConfigWasLoaded and Menu.Config and Menu.Config.apply then
    Menu.Config.apply()
end


if UIState.WatermarkUI then UIState.WatermarkUI:SetVisible(UIState.ShowWatermark) end
if UIState.KeybindsUI then UIState.KeybindsUI:SetVisible(UIState.ShowKeybinds) end


if not Menu.IsMobile and not ConfigWasLoaded then
    Crosshair.ShowText = true
    Crosshair.Spin = true
    Crosshair.Length = 12
    Crosshair.Gap = 4
    Crosshair.Width = 2
    Crosshair.Start()
end


if UIState.WatermarkUI then
    spawn(function()
        local wmText = "DYHUB"
        local wmCharIndex = 0
        local wmIsDeleting = false
        while UIState.WatermarkUI do
            if not wmIsDeleting then
                if wmCharIndex < #wmText then
                    wmCharIndex = wmCharIndex + 1
                    pcall(function() UIState.WatermarkUI:Update(string.sub(wmText, 1, wmCharIndex)) end)
                    wait(0.05)
                else
                    wait(3)
                    wmIsDeleting = true
                end
            else
                if wmCharIndex > 0 then
                    wmCharIndex = wmCharIndex - 1
                    pcall(function() UIState.WatermarkUI:Update(string.sub(wmText, 1, wmCharIndex)) end)
                    wait(0.025)
                else
                    wmIsDeleting = false
                    wait(0.5)
                end
            end
        end
    end)
end


local titleText = "DYHUB | Bite By Night | by dyumra"
local animatedTitle = ""
local titleIndex = 1
local isDeleting = false

spawn(function()
    while true do
        if isDeleting then
            if #animatedTitle > 0 then
                animatedTitle = string.sub(animatedTitle, 1, -2)
            else
                isDeleting = false
                titleIndex = 1
            end
        else
            if titleIndex <= #titleText then
                animatedTitle = animatedTitle .. string.sub(titleText, titleIndex, titleIndex)
                titleIndex = titleIndex + 1
            else
                wait(2)
                isDeleting = true
            end
        end
        if Menu then pcall(function() Menu:SetTitle(animatedTitle) end) end
        wait(0.05)
    end
end)


Menu:SetVisible(true)





function GetPlayerStyle()
    
    local players = workspace:FindFirstChild("PLAYERS")
    if players then
        local killer = players:FindFirstChild("KILLER")
        if killer then
            local playerModel = killer:FindFirstChild(Player.Name)
            if playerModel then
                
                local phases = playerModel:FindFirstChild("Phases")
                if phases then
                    local phase5 = phases:FindFirstChild("5")
                    if phase5 and phase5:IsA("Sound") and phase5.SoundId ~= "" then
                        local soundId = phase5.SoundId:match("%d+")
                        if soundId == "92516484310081" or soundId == "137609355749227" then
                            return "springtrap"
                        elseif soundId == "110703795984234" then
                            return "ennard"
                        elseif soundId == "79588086477251" or soundId == "88983903450003" then
                            return "mimic"
                        end
                    end
                end
                return "killer"
            end
        end
        
        
        local alive = players:FindFirstChild("ALIVE")
        if alive then
            local playerModel = alive:FindFirstChild(Player.Name)
            if playerModel then
                
                local assets = playerModel:FindFirstChild("Assets")
                if assets or playerModel:FindFirstChild("FAZ-TAZER") or playerModel:FindFirstChild("Axe") then
                    if (assets and assets:FindFirstChild("EnergyDrink")) or playerModel:FindFirstChild("EnergyDrink") then
                        return "customer"
                    elseif (assets and assets:FindFirstChild("Medkit")) or playerModel:FindFirstChild("Medkit") then
                        return "medic"
                    elseif (assets and assets:FindFirstChild("Axe")) or playerModel:FindFirstChild("Axe") then
                        return "fighter"
                    elseif playerModel:FindFirstChild("FAZ-TAZER") then
                        return "guard"
                    end
                end
                return "survivor"
            end
        end
    end
    
    return nil
end


RunService.Heartbeat:Connect(function()
    KeybindTracker.CheckStyleChange()
end)


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    
    if input.KeyCode == UIState.ToggleGUIKey then
        UIState.MenuVisible = not UIState.MenuVisible
        Menu:SetVisible(UIState.MenuVisible)
        return
    end
    
    
    if input.KeyCode == TazerAimbot.CurrentKey then
        local style = GetPlayerStyle()
        if style == "guard" and UIState.TazerAimbotCheckBox then
            local newValue = not UIState.TazerAimbotCheckBox:GetValue()
            UIState.TazerAimbotCheckBox:SetValue(newValue)
            UIState.TazerAimbotCheckBox.Callback(newValue)
        end
    end
    
    
    if input.KeyCode == AxeAimbot.CurrentKey then
        local style = GetPlayerStyle()
        if style == "springtrap" and UIState.AxeAimbotCheckBox then
            local newValue = not UIState.AxeAimbotCheckBox:GetValue()
            UIState.AxeAimbotCheckBox:SetValue(newValue)
            UIState.AxeAimbotCheckBox.Callback(newValue)
        end
    end
    
    
    if input.KeyCode == GrabAimbot.CurrentKey then
        local style = GetPlayerStyle()
        if style == "mimic" and UIState.GrabAimbotCheckBox then
            local newValue = not UIState.GrabAimbotCheckBox:GetValue()
            UIState.GrabAimbotCheckBox:SetValue(newValue)
            UIState.GrabAimbotCheckBox.Callback(newValue)
        end
    end
    
    
    if input.KeyCode == SwingAimbot.CurrentKey then
        local style = GetPlayerStyle()
        if style == "fighter" and UIState.SwingAimbotCheckBox then
            local newValue = not UIState.SwingAimbotCheckBox:GetValue()
            UIState.SwingAimbotCheckBox:SetValue(newValue)
            UIState.SwingAimbotCheckBox.Callback(newValue)
        end
    end
    
    
    if input.KeyCode == EnnardGrabAimbot.CurrentKey then
        local style = GetPlayerStyle()
        if style == "ennard" and UIState.EnnardGrabAimbotCheckBox then
            local newValue = not UIState.EnnardGrabAimbotCheckBox:GetValue()
            UIState.EnnardGrabAimbotCheckBox:SetValue(newValue)
            UIState.EnnardGrabAimbotCheckBox.Callback(newValue)
        end
    end
    
    
    if input.KeyCode == EnnardStabAimbot.CurrentKey then
        local style = GetPlayerStyle()
        if style == "ennard" and UIState.EnnardStabAimbotCheckBox then
            local newValue = not UIState.EnnardStabAimbotCheckBox:GetValue()
            UIState.EnnardStabAimbotCheckBox:SetValue(newValue)
            UIState.EnnardStabAimbotCheckBox.Callback(newValue)
        end
    end
    
    
    if input.KeyCode == AutoBlock.CurrentKey then
        local style = GetPlayerStyle()
        if style == "fighter" and UIState.AutoBlockCheckBox then
            local newValue = not UIState.AutoBlockCheckBox:GetValue()
            UIState.AutoBlockCheckBox:SetValue(newValue)
            UIState.AutoBlockCheckBox.Callback(newValue)
        end
    end
end)

SafeNotify("<font color='#FF0000'>[ DYHUB ]</font> — Loaded Successfully | Config Auto-Save Enabled", 5)

warn("[BBN] Script loaded successfully!")
