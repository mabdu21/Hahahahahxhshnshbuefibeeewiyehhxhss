repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
task.wait(3)

local FLOAT_HEIGHT = 4
local SPEED = 34
getgenv().money_random = 0
getgenv().Farmnow = ""
local SplashModule = require(game.ReplicatedStorage.Modules.Game.SplashScreen)
local isFirstRun = SplashModule.in_loading_screen.get()  -- เก็บไว้ก่อน เพราะบล็อกล่างจะ set(false) ทิ้ง
if isFirstRun then
    workspace:SetAttribute("SkipCreator", true)  -- <- แก้ Workspace -> workspace
    set_thread_identity(2)
    SplashModule.in_loading_screen.set(false)
    set_thread_identity(8)

    local splashGui = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SplashScreenGui")
    if splashGui then splashGui:Destroy() end

    local SoundService = game:GetService("SoundService")
    for _, s in ipairs(SoundService:GetChildren()) do
        if s:IsA("Sound") and s.SoundId == "rbxassetid://113169105768074" then
            local tween = game:GetService("TweenService"):Create(s, TweenInfo.new(1), { Volume = 0 })
            tween:Play()
            tween.Completed:Wait()
            s:Stop()
        end
    end
    task.wait(3)
end

local Player = game.Players.LocalPlayer
local FolderName = "NextPlayFF"
local FileName = FolderName .. "/" .. Player.Name .. "_StorageFram.json"

local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local plr = game.Players.LocalPlayer
local Char = plr.Character or plr.CharacterAdded:Wait()
local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Request = (syn and syn.request) or request or (http and http.request) or http_request
local PlaceID = game.PlaceId
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

local Jobs = {"Shelf Stocker", "Swiper"}
local AvailableJobs = {unpack(Jobs)}
local StorageFram = {}

if not isfolder(FolderName) then
    makefolder(FolderName)
end


local NetCore = require(ReplicatedStorage.Modules.Core.Net)
local Authenticate = debug.getupvalue(NetCore.get, 1)
local function Get(...)
    Authenticate.func += 1
    return game:GetService("ReplicatedStorage").Remotes.Get:InvokeServer(Authenticate.func, ...)
end

local Send = function(...)
	Authenticate.event += 1;
	game:GetService("ReplicatedStorage").Remotes.Send:FireServer(Authenticate.event, ...)
end
local function getTotalMoney()
    local hand = DataCore.money.hand or 0
    local bank = DataCore.money.bank or 0
    return hand + bank
end
local money_hand = DataCore.money.hand or 0
local money_bank = DataCore.money.bank or 0
local money = money_hand + money_bank or 0


local function getOwnedCars()
    local result = {}
    if not (DataCore.items and DataCore.items.car) then
        return result
    end
    for carName, carData in pairs(DataCore.items.car) do
        if type(carData) == "table" and next(carData) ~= nil then
            table.insert(result, carName)
        end
    end
    return result
end

local function CheckHackTool()
    local items = DataCore.items and DataCore.items.misc
    if not items then
        return false
    end
    local targetTools = {
        ["HackToolBasic"] = true,
        ["HackToolPro"] = true,
        ["HackToolUltimate"] = true,
        ["HackToolQuantum"] = true
    }
    for toolName, toolList in pairs(items) do
        if targetTools[toolName] then
            for _, itemData in pairs(toolList) do
                if itemData.guid and itemData.guid ~= "" then
                    return true
                end
            end
        end
    end
    return false
end

local CONST1 = 1.1040895136738123
local CONST2 = 0.10408951367381225

local function level_to_xp(level)
	local expTerm = 2 ^ (level / 7)
	local xp = 0.125 * (level ^ 2 - level + 600 * ((expTerm - CONST1) / CONST2))
	return math.floor(xp + 0.5)
end

local function xp_to_level(targetXP)
	local low, high = 0, 100
	while low <= high do
		local mid = math.floor((low + high) / 2)
		local midXP = level_to_xp(mid)
		if midXP <= targetXP then
			low = mid + 1
		else
			high = mid - 1
		end
	end
	return high
end

local xp_cook = DataCore.xp["cook"]
local level_cook = xp_cook and xp_to_level(xp_cook) or 0
if level_cook < 30 then
    table.insert(Jobs, "Cook")
end


task.spawn(function()
    local xp_swiper = DataCore.xp["atm_hacker"]
    local level_swiper = xp_swiper and xp_to_level(xp_swiper) or 0
    local hackToolCount = 2

    if level_swiper < 50 then
        hackToolCount = 2
    else
        hackToolCount = 5
    end
    local xp_cook = DataCore.xp["cook"]
    local level_cook = xp_cook and xp_to_level(xp_cook) or 0
    local usecar = "Bike"

    if level_cook < 30 then
        usecar = "Bike"
    else 
        usecar = "Car"
    end

    local firstJob = ""
    if isFirstRun then
        firstJob = Jobs[math.random(1, #Jobs)]
        getgenv().Farmnow = firstJob
    end

    getgenv().HermanosDevSetting = {
        Farming = {
            Job = firstJob,
            Skillet = "Smart Select",
            BuySkillet = true,
            PaddleMode = "Nearest",
            Mop = "Smart Select",
            BuyMop = true,
            HackTools = "Smart Select",
            HackToolsQuantity = hackToolCount,
            Rod = "Smart Select",
            Bait = "Smart Select",
            BaitQuantity = 10,
            FishAmount = 10,
            IncludeFarming = true,
            VehicleType = usecar,
            VehicleSpeed = 52,
            AutoFarm = true,
            AfkChecker = true,
            CashDeposit = 200,
            AutoDeposit = true
        },
        General = {
            HideName = true,
            AntiRagdoll = true,
            AntiKill = true,
            AutoRespawn = true,
        },
    }

    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/28d9e130cb0559d30e2c20b5c851b7ef.lua"))()
end)

local function getJobIdFromAPI()
    local API_URL = "http://110.164.203.137:2699/getjobid"
    if PlaceID ~= 104715542330896 then
        return nil
    end
    local ok, res = pcall(function()
        return Request({
            Url = API_URL,
            Method = "GET",
            Headers = {
                ["Accept"] = "application/json"
            }
        })
    end)
    if not ok or not res then
        warn("Request failed")
        return nil
    end
    if tonumber(res.StatusCode) ~= 200 then
        warn("API error:", res.StatusCode, res.Body)
        return nil
    end
    local data
    local decodeOk, decodeErr = pcall(function()
        data = HttpService:JSONDecode(res.Body)
    end)
    if not decodeOk then
        warn("JSON decode failed:", decodeErr)
        return nil
    end
    if data.status ~= "ok" or not data.jobid then
        warn("Invalid API response:", res.Body)
        return nil
    end
    return data.jobid
end

local function SaveProgress()
    local Data = {
        Available = AvailableJobs,
        History = StorageFram
    }
    writefile(FileName, HttpService:JSONEncode(Data))
end

local function LoadProgress()
    if isfile(FileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(FileName))
        end)
        if success and result then
            AvailableJobs = result.Available or AvailableJobs
            StorageFram = result.History or StorageFram
            print("--- Loaded existing progress from JSON ---")
        end
    end
end

local function getFishCount()
    local fishItems = DataCore.items.fish
    local totalCount = 0
    for _, category in pairs(fishItems) do
        for _ in pairs(category) do
            totalCount = totalCount + 1
        end
    end
    return totalCount
end

task.spawn(function()
    local API_URL = "http://110.164.203.137:2699/player"
    while true do
        local bank = 0
        local hand = 0
        if DataCore and DataCore.money then
            bank = tonumber(DataCore.money.bank) or 0
            hand = tonumber(DataCore.money.hand) or 0
        end

        local payload = {
            username  = plr.Name,
            moneybank = bank,
            moneyhand = hand,
            car       = getOwnedCars(),
            jobid     = tostring(game.JobId),
            placeid   = tostring(game.PlaceId),
            time      = os.time()
        }
        local body = HttpService:JSONEncode(payload)
        local ok, res = pcall(function()
            return Request({
                Url = API_URL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = body
            })
        end)
        if ok and res and tonumber(res.StatusCode) == 200 then
            print("Status Updated API:", payload.username)
        else
            local code = (res and res.StatusCode) and tostring(res.StatusCode) or "NO_STATUS"
            local msg  = (res and res.Body) and tostring(res.Body) or "REQUEST_FAILED"
            warn(("Failed Update API | %s | %s"):format(code, msg))
        end
        task.wait(10)
    end
end)


task.spawn(function() 
	task.wait(20)
    local BASE = "http://110.164.203.137:2699/check-duplicate-jobid/"
    if PlaceID ~= 104715542330896 then
        return nil
    end

    while true do
        local username = plr.Name
        local url = BASE .. HttpService:UrlEncode(username) .. "?threshold=3"

        local ok, res = pcall(function()
            return Request({
                Url = url,
                Method = "GET",
                Headers = { ["Accept"] = "application/json" }
            })
        end)
        if ok and res and tonumber(res.StatusCode) == 200 then
            local body = res.Body or "{}"
            local data = {}
            pcall(function()
                data = HttpService:JSONDecode(body)
            end)

            print(("check_duplicate_jobid OK | %s | count=%s | need_new=%s"):format(
                username,
                tostring(data.count),
                tostring(data.need_new_jobid)
            ))
            if data.need_new_jobid and data.new_jobid then
                print("NEW JOBID:", data.new_jobid)
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, data.new_jobid, game.Players.LocalPlayer)
            end
        else
            local code = (res and res.StatusCode) and tostring(res.StatusCode) or "NO_STATUS"
            local msg  = (res and res.Body) and tostring(res.Body) or "REQUEST_FAILED"
            warn(("Failed check_duplicate_jobid | %s | %s"):format(code, msg))
        end
        task.wait(10)
    end
end)

task.spawn(function()
    while true do 
        setfpscap(10)
        task.wait(5)
    end
end)


LoadProgress()

task.spawn(function()
    print("Start")
    local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)
    local lastMoney = DataCore.money.hand
    local lastChangeTime = os.time()
    local kickThreshold = 5 * 60
    while true do
        task.wait(1)
        local currentMoney = DataCore.money.hand
        if currentMoney ~= lastMoney then
            lastMoney = currentMoney
            lastChangeTime = os.time()
        else
            if os.time() - lastChangeTime >= kickThreshold then
                local Players = game:GetService("Players")
                local player = Players.LocalPlayer or Players:GetPlayerFromCharacter(script.Parent)
                if player then
                    local jobid = getJobIdFromAPI()
                    if jobid then
                        print("NEW JOBID:", jobid)
                        local TeleportService = game:GetService("TeleportService")
                        TeleportService:TeleportToPlaceInstance(PlaceID, jobid, game.Players.LocalPlayer)
                    else
                        warn("No jobid received")
                        game:Shutdown()
                    end
                end
                break
            end
        end
    end
end)

task.spawn(function()
    local LIMIT_SECONDS = 90 * 60
    task.delay(LIMIT_SECONDS, function()
        if localPlayer and localPlayer.Parent then
            local jobid = getJobIdFromAPI()
            if jobid then
                print("NEW JOBID:", jobid)
                local TeleportService = game:GetService("TeleportService")
                TeleportService:TeleportToPlaceInstance(PlaceID, jobid, game.Players.LocalPlayer)
            else
                warn("No jobid received")
                game:Shutdown()
            end
        end
    end)
end)

task.spawn(function()
    repeat wait() until game:IsLoaded()
    repeat wait() until game.Players.LocalPlayer.Character
    local HttpService = game:GetService("HttpService")
    local Request = (syn and syn.request) or request or (http and http.request) or http_request
    local username = game.Players.LocalPlayer.Name
    local globalFunc = false
    local DataCore = require(game:GetService("ReplicatedStorage").Modules.Core.Data)

    game.StarterGui:SetCore("SendNotification", {
        Title = 'API SERVICES',
        Text = 'User : ' .. username,
        Duration = 25,
        Icon = 'rbxassetid://18976336309'
    })

    -- ผูก event ครั้งเดียว (เดิมถูกเรียกในลูปทุก 15 วิ ทำให้ connection รั่ว)
    local function setupErrorWatcher()
        local promptGui = game:GetService("CoreGui"):WaitForChild("RobloxPromptGui", 60)
        if not promptGui then return end
        local promptOverlay = promptGui:WaitForChild("promptOverlay", 60)
        if not promptOverlay then return end

        promptOverlay.ChildAdded:Connect(function(v)
            if v.Name == "ErrorPrompt" then
                pcall(function()
                    local errorFrame = v:WaitForChild("MessageArea"):WaitForChild("ErrorFrame")
                    local errorLabel = errorFrame:WaitForChild("ErrorMessage")
                    local line2 = errorLabel.Text:split("\n")[2]
                    local errorCode = line2 and tonumber(line2:match("%d+"))

                    if errorCode and errorCode ~= 772 and errorCode ~= 773 then
                        globalFunc = true
                    end
                end)
            end
        end)
    end

    local function updateStatus()
        local currentMoney = (DataCore.money and DataCore.money.bank) or 0
        local url  = "http://127.0.0.1:14781"
        local data = "username=" .. HttpService:UrlEncode(username)
                .. "&money=" .. tostring(currentMoney)
        if not Request then
            warn("HTTP request function not available")
            return
        end
        local requestData = {
            Url    = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded"
            },
            Body = data
        }
        local ok, response = pcall(function()
            return Request(requestData)
        end)
        if ok and response and response.StatusCode == 200 then
            print(("Status Updated API : %s | Money : %s"):format(username, currentMoney))
        else
            warn("Failed Update API " .. (response and response.StatusCode or "Request failed"))
        end
    end

    setupErrorWatcher()

    local Round = 0
    while true do
        print("Disconnected : ", globalFunc)
        print("API runs at : ", Round)
        if not globalFunc then
            updateStatus()
        end
        Round = Round + 1
        print("----------------------------------------")
        wait(15)
    end
end)

local function getGroundY(pos, character)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(
        pos + Vector3.new(0,10,0),
        Vector3.new(0,-50,0),
        params
    )
    if result then
        return result.Position.Y
    end
    return pos.Y
end

local function computePath(startPos, endPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = false,
        AgentCanClimb = false,
        AgentMaxSlope = 45,
    })

    path:ComputeAsync(startPos, endPos)
    return path
end

local function moveToSmooth(root, targetPos, speed)
    local startPos = root.Position
    local distance = (startPos - targetPos).Magnitude
    if distance < 0.1 then
        return true
    end
    local duration = distance / speed
    local elapsed = 0
    while elapsed < duration do
        local dt = RunService.Heartbeat:Wait()
        elapsed += dt
        local alpha = math.clamp(elapsed / duration, 0, 1)
        local expected = startPos:Lerp(targetPos, alpha)
        if (root.Position - expected).Magnitude > 12 then
            return false
        end

        root.CFrame = CFrame.new(expected)
    end

    root.CFrame = CFrame.new(targetPos)
    return true
end

local function tweenPathEased(targetPos)
    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    local path = computePath(root.Position, targetPos)
    if path.Status ~= Enum.PathStatus.Success then
        warn("Pathfinding failed")
        return
    end

    Send("set_sprinting_1", true)

    for _, waypoint in ipairs(path:GetWaypoints()) do
        if (root.Position - waypoint.Position).Magnitude < 3 then
            continue
        end

        local groundY = getGroundY(waypoint.Position, char)
        local floatPos = Vector3.new(
            waypoint.Position.X,
            groundY + FLOAT_HEIGHT,
            waypoint.Position.Z
        )

        local success = moveToSmooth(root, floatPos, SPEED)

        if not success then
            warn("Rubberband detected → recalculating path")
            return tweenPathEased(targetPos)
        end
    end
end

local function saveOrUpdateRollCost(rollCost)
    local player = Players.LocalPlayer
    local folder = "NP"

    if not isfolder(folder) then
        makefolder(folder)
    end
    local existingFile = nil
    for _, file in ipairs(listfiles(folder)) do
        if string.find(file, player.Name .. "_") and string.find(file, ".json") then
            existingFile = file
            break
        end
    end
    if existingFile then
        local data = HttpService:JSONDecode(readfile(existingFile))
        data.cost = rollCost
        writefile(existingFile, HttpService:JSONEncode(data))
        print("Updated:", existingFile)
    else
        local rd = math.random(1000,9999)
        local fileName = folder .. "/" .. player.Name .. "_" .. rd .. ".json"

        local data = {
            player = player.Name,
            cost = rollCost
        }
        writefile(fileName, HttpService:JSONEncode(data))
        print("Created:", fileName)
    end
end

local function getSavedRollCost()
    local player = Players.LocalPlayer
    local folder = "NP"

    if not isfolder(folder) then
        return 0
    end

    for _, file in ipairs(listfiles(folder)) do
        if string.find(file, player.Name .. "_") and string.find(file, ".json") then
            local data = HttpService:JSONDecode(readfile(file))
            return data.cost or 0
        end
    end

    return 0
end

local function checkHackableATMAtPosition(targetPos, tolerance)
    tolerance = tolerance or 2
    for _, atm in ipairs(workspace.Map.Props.ATMs:GetChildren()) do
        for _, child in ipairs(atm:GetChildren()) do
            local screen = child:FindFirstChild("Screen")
            if screen then
                local pos = child.Position
                if (pos - targetPos).Magnitude <= tolerance then
                    if screen.Enabled == false then
                        return true, child, "ready"
                    else
                        return false, child, "not_ready"
                    end
                end
            end
        end
    end
    return false, nil, "not_found"
end

local function Randomitem()
    local newpost = Vector3.new(-191.962753, 255.460556, -242.276764)
    tweenPathEased(newpost)
    task.wait(3)
    local money_hand = DataCore.money.hand
    local money_bank = DataCore.money.bank

    local plr = game.Players.LocalPlayer
    local Char = plr.Character or plr.CharacterAdded:Wait()
    local HumanoidRootPart = Char:WaitForChild("HumanoidRootPart")

    print((HumanoidRootPart.Position - newpost).Magnitude)
    print("ตำแหน่งปัจจุบัน:", HumanoidRootPart.Position)
    if (HumanoidRootPart.Position - newpost).Magnitude < 50 then
        while true do
            local postatm = Vector3.new(-198.492996, 258.570984, -249.722015) 
            local found, screen, status = checkHackableATMAtPosition(postatm,50)
            if found and status == "ready" then
                pcall(function()
                    return Get("transfer_funds", "bank", "hand", DataCore.money.bank or 0)
                end)
                local new_money_hand = DataCore.money.hand
                if new_money_hand > money_hand or money_bank == 0 then
                    Get("open_crate",workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("GunShopTile"):WaitForChild("PatriotWeapons"):WaitForChild("Interior"):WaitForChild("Crates"):WaitForChild("Weapon Crate"):WaitForChild("CrateOptions"):WaitForChild("Superior"),"money")
                    
                    while true do
                        local found2, screen2, status2 = checkHackableATMAtPosition(postatm,50)
                        if found2 and status2 == "ready" then
                            pcall(function()
                                return Get("transfer_funds", "hand", "bank", DataCore.money.hand or 0)
                            end)
                            break
                        end
                    end
                    local postout = Vector3.new(-187.8740997314453, 255.2150421142578, -137.7740936279297)
                    tweenPathEased(postout)

                    pcall(function()
                        getgenv().HermanosFarm.Farming.AutoFarm = true
                    end)
                    return
                else
                    print("โอนเงินล้มเหลว หรือไม่มีการเปลี่ยนแปลงจำนวนเงินในมือ")
                end
            else
                print("ยังไม่เจอ ATM ที่สามารถแฮกได้, สถานะ:", status)
            end
            task.wait(0.1)
        end
    else
        print("ไม่สามารถเดินไปยังตำแหน่ง newpost ได้")
        return
    end
end

task.spawn(function()
    repeat 
        wait(0.5) 
    until getgenv().HermanosFarm 
        and getgenv().HermanosFarm.Farming 
        and getgenv().HermanosFarm.Farming.Job ~= nil
    wait(20) 
    if game.PlaceId ~= 104715542330896 then
        getgenv().HermanosFarm.Farming.Job = "Shelf Stocker"
        task.wait(400)
        local jobid = getJobIdFromAPI()
        if jobid then
            print("NEW JOBID:", jobid)
            local TeleportService = game:GetService("TeleportService")
            TeleportService:TeleportToPlaceInstance(104715542330896, jobid, game.Players.LocalPlayer)
        else
            warn("No jobid received")
            game:Shutdown()
        end
        return
    end
    local xp_fishing = DataCore.xp["total_level"]
    local level_fishing = xp_fishing and xp_to_level(xp_fishing) or 0

    if getSavedRollCost() == 0 then
        if level_fishing < 25 then
            local rollCost = 4600
            saveOrUpdateRollCost(rollCost)
        else
            local rollCost = DataCore.money.bank + DataCore.money.hand + 5000
            saveOrUpdateRollCost(rollCost)
            getgenv().money_random = rollCost
        end
    end

    local firstLoop = true
    while true do
        local waitTime = math.random(360, 720)

        if #AvailableJobs == 0 then
            table.clear(StorageFram)
            AvailableJobs = {unpack(Jobs)}
            SaveProgress()
        end
        -- รอบแรก: ถ้ามี Job ที่สุ่มใส่ config ไปแล้ว ดึงตัวนั้นออกจาก AvailableJobs ตรงๆ ไม่สุ่มซ้ำ
        local preIndex = firstLoop and getgenv().Farmnow ~= "" and table.find(AvailableJobs, getgenv().Farmnow)
        firstLoop = false
        if preIndex then
            getgenv().Farmnow = table.remove(AvailableJobs, preIndex)
        else
            local randomIndex = math.random(1, #AvailableJobs)
            getgenv().Farmnow = table.remove(AvailableJobs, randomIndex)
        end
        table.insert(StorageFram, getgenv().Farmnow)
        SaveProgress()
        pcall(function()
            getgenv().HermanosFarm.Farming.IncludeFarming = true
        end)

        local xp_cook = DataCore.xp["cook"]
        local level_cook = xp_cook and xp_to_level(xp_cook) or 0
        if level_cook >= 30 then
            local index = table.find(Jobs, "Cook")
            if index then
                table.remove(Jobs, index)
            end
        end

        if getgenv().Farmnow == "Swiper" then
            pcall(function()
                getgenv().HermanosFarm.Farming.IncludeFarming = true
            end)

            Send("request_respawn")
            task.wait(2)
            pcall(function()
                getgenv().HermanosFarm.Farming.Job = getgenv().Farmnow
            end)
            local xp_swiper = DataCore.xp["atm_hacker"]
            local level_swiper = xp_swiper and xp_to_level(xp_swiper) or 0
            local hackToolCount = 2

            if level_swiper < 50 then
                hackToolCount = 2
            else
                hackToolCount = 5
            end
            pcall(function()
                getgenv().HermanosFarm.Farming.HackToolsQuantity = hackToolCount
            end)

            task.wait(waitTime)
            while CheckHackTool() do
                task.wait(2)
            end
        else
            pcall(function()
                getgenv().HermanosFarm.Farming.Job = getgenv().Farmnow
            end)
            task.wait(waitTime)
        end
    end
end)
