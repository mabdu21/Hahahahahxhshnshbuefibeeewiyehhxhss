

local ConfigSystem = {}
local configs = {}
local configFolderName = "DYHUBLIB"
local currentConfigName = "default"
local UIScale = 1.15 
local isLoadingConfig = false 

local function saveConfig(configName)
    configName = configName or currentConfigName
    if not writefile then return false end
    
    local success, result = pcall(function()
        local folderPath = configFolderName
        if not isfolder(folderPath) then
            makefolder(folderPath)
        end
        
        local configPath = folderPath .. "/" .. configName .. ".json"
        local configData = {
            version = 1,
            timestamp = os.time(),
            elements = configs[configName] or {}
        }
        
        writefile(configPath, game:GetService("HttpService"):JSONEncode(configData))
    end)
    
    return success
end

local function loadConfig(configName)
    configName = configName or currentConfigName
    if not readfile then 
        warn("[Config] readfile not available")
        return false 
    end
    
    local success, result = pcall(function()
        local folderPath = configFolderName
        local configPath = folderPath .. "/" .. configName .. ".json"
        
        if not isfile(configPath) then
            warn("[Config] File not found: " .. configPath)
            return false
        end
        
        local fileContent = readfile(configPath)
        local configData = game:GetService("HttpService"):JSONDecode(fileContent)
        configs[configName] = configData.elements or {}
        currentConfigName = configName
        
        
        local count = 0
        for _ in pairs(configs[configName]) do count = count + 1 end
        warn("[Config] Loaded config '" .. configName .. "' with " .. count .. " elements")
        for key, value in pairs(configs[configName]) do
            warn("[Config]   " .. tostring(key) .. " = " .. tostring(value))
        end
        
        return true
    end)
    
    if not success then
        warn("[Config] Error loading config: " .. tostring(result))
    end
    
    return success and result
end


local applyConfig = nil

local function deleteConfig(configName)
    if not delfile then return false end
    
    local success, result = pcall(function()
        local configPath = configFolderName .. "/" .. configName .. ".json"
        if isfile(configPath) then
            delfile(configPath)
            configs[configName] = nil
            return true
        end
        return false
    end)
    
    return success and result
end

local function getConfigValue(path, defaultValue)
    local config = configs[currentConfigName] or {}
    if config[path] ~= nil then
        warn("[Config] getConfigValue('" .. path .. "') = " .. tostring(config[path]) .. " (from config)")
        return config[path]
    end
    warn("[Config] getConfigValue('" .. path .. "') = " .. tostring(defaultValue) .. " (default, config=" .. currentConfigName .. ")")
    return defaultValue
end

local function setConfigValue(path, value)
    if not configs[currentConfigName] then
        configs[currentConfigName] = {}
    end
    configs[currentConfigName][path] = value
    saveConfig(currentConfigName)
end

local function listConfigs()
    if not listfiles then return {} end
    
    local configList = {}
    local success, files = pcall(function()
        return listfiles(configFolderName)
    end)
    
    if success then
        for _, file in pairs(files) do
            if file:sub(-5) == ".json" then
                local configName = file:match(".*[/\\](.+)%.json")
                if configName then
                    table.insert(configList, configName)
                end
            end
        end
    end
    
    return configList
end


ConfigSystem.save = saveConfig
ConfigSystem.load = loadConfig
ConfigSystem.delete = deleteConfig

ConfigSystem.getValue = getConfigValue
ConfigSystem.setValue = setConfigValue
ConfigSystem.list = listConfigs
ConfigSystem.setCurrentConfig = function(name) currentConfigName = name end
ConfigSystem.getCurrentConfig = function() return currentConfigName end


ConfigSystem.saveConfig = saveConfig
ConfigSystem.loadConfig = loadConfig
ConfigSystem.deleteConfig = deleteConfig
ConfigSystem.getConfigValue = getConfigValue
ConfigSystem.setConfigValue = setConfigValue
ConfigSystem.listConfigs = listConfigs

local Settings = {
    Accent = Color3.fromHex("#A6BAFF"),
    Font = Enum.Font.SourceSans,
    IsBackgroundTransparent = true,
    Rounded = false,
    Dim = false,
    
    ItemColor = Color3.fromRGB(30, 30, 30),
    BorderColor = Color3.fromRGB(45, 45, 45),
    MinSize = Vector2.new(math.floor(300 * UIScale), math.floor(400 * UIScale)),
    MaxSize = Vector2.new(math.floor(800 * UIScale), math.floor(750 * UIScale))
}


local Menu = {}
local Tabs = {}
local Items = {}
local EventObjects = {} 
local Notifications = {}


local onConfigLoadedCallback = nil
applyConfig = function()
    
    
    local config = configs[currentConfigName]
    if not config then return false end
    
    
    isLoadingConfig = true
    
    for _, item in pairs(Items) do
        if item.Tab and item.Container and item.Name then
            local configKey = item.Tab .. "_" .. item.Container .. "_" .. item.Name
            local savedValue = config[configKey]
            if savedValue ~= nil then
                if item.SetValue then
                    pcall(function()
                        item:SetValue(savedValue)
                        if item.Callback then
                            item.Callback(savedValue)
                        end
                    end)
                end
            end
        end
    end
    
    
    isLoadingConfig = false
    
    
    if onConfigLoadedCallback then
        pcall(onConfigLoadedCallback)
    end
    
    return true
end
ConfigSystem.apply = applyConfig
ConfigSystem.isLoading = function() return isLoadingConfig end
ConfigSystem.onConfigLoaded = function(callback) onConfigLoadedCallback = callback end

local Scaling = {True = false, Origin = nil, Size = nil}
local Dragging = {Gui = nil, True = false}
local Draggables = {}
local ToolTip = {Enabled = false, Content = "", Item = nil}

local HotkeyRemoveKey = Enum.KeyCode.LeftControl
local Selected = {
    Frame = nil,
    Item = nil,
    Offset = UDim2.new(),
    Follow = false
}
local SelectedTab
local SelectedTabLines = {}


local wait = task.wait
local delay = task.delay
local spawn = task.spawn
local protect_gui = function(Gui, Parent)
    if gethui and syn and syn.protect_gui then 
        Gui.Parent = gethui() 
    elseif not gethui and syn and syn.protect_gui then 
        syn.protect_gui(Gui)
        Gui.Parent = Parent 
    else 
        Gui.Parent = Parent 
    end
end


local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")


local isMobile = UserInput.TouchEnabled


local __Menu = {}
setmetatable(Menu, {
    __index = function(self, Key) return __Menu[Key] end,
    __newindex = function(self, Key, Value)
        __Menu[Key] = Value
        
        if Key == "Hue" or Key == "ScreenSize" then return end

        for _, Object in pairs(EventObjects) do Object:Update() end
        for _, Notification in pairs(Notifications) do Notification:Update() end
    end
})


Menu.Accent = Settings.Accent
Menu.Font = Settings.Font
Menu.IsBackgroundTransparent = Settings.IsBackgroundTransparent
Menu.Rounded = Settings.IsRounded
Menu.Dim = Settings.IsDim
Menu.ItemColor = Settings.ItemColor
Menu.BorderColor = Settings.BorderColor
Menu.MinSize = Settings.MinSize
Menu.MaxSize = Settings.MaxSize

Menu.Hue = 0
Menu.IsVisible = false
Menu.ScreenSize = Vector2.new()


local function AddEventListener(self: GuiObject, Update: any)
    table.insert(EventObjects, {
        self = self,
        Update = Update
    })
end


local function CreateCorner(Parent: Instance, Pixels: number): UICorner
    local UICorner = Instance.new("UICorner")
    UICorner.Name = "Corner"
    UICorner.Parent = Parent
    return UICorner
end


local function CreateStroke(Parent: Instance, Color: Color3, Thickness: number, Transparency: number): UIStroke
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Name = "Stroke"
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.LineJoinMode = Enum.LineJoinMode.Miter
    UIStroke.Color = Color or Color3.new()
    UIStroke.Thickness = Thickness or 1
    UIStroke.Transparency = Transparency or 0
    UIStroke.Enabled = true
    UIStroke.Parent = Parent
    return UIStroke
end 


local function CreateLine(Parent: Instance, Size: UDim2, Position: UDim2, Color: Color3): Frame
    local Line = Instance.new("Frame")
    Line.Name = "Line"
    Line.BackgroundColor3 = typeof(Color) == "Color3" and Color or Menu.Accent
    Line.BorderSizePixel = 0
    Line.Size = Size or UDim2.new(1, 0, 0, 1)
    Line.Position = Position or UDim2.new()
    Line.Parent = Parent

    if Line.BackgroundColor3 == Menu.Accent then
        AddEventListener(Line, function() Line.BackgroundColor3 = Menu.Accent end)
    end

    return Line
end


local function CreateLabel(Parent: Instance, Name: string, Text: string, Size: UDim2, Position: UDim2): TextLabel
    local Label = Instance.new("TextLabel")
    Label.Name = Name
    Label.BackgroundTransparency = 1
    Label.Size = Size or UDim2.new(1, 0, 0, math.floor(17 * UIScale))
    Label.Position = Position or UDim2.new()
    Label.Font = Enum.Font.SourceSans
    Label.Text = Text or ""
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = math.floor(14 * UIScale)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Parent
    return Label
end


local function UpdateSelected(Frame: Instance, Item: Item, Offset: UDim2)
    local Selected_Frame = Selected.Frame
    if Selected_Frame then
        Selected_Frame.Visible = false
        Selected_Frame.Parent = nil
    end

    Selected = {}

    if Frame then
        if Selected_Frame == Frame then return end
        Selected = {
            Frame = Frame,
            Item = Item,
            Offset = Offset
        }

        Frame.ZIndex = 3
        Frame.Visible = true
        Frame.Parent = Menu.Screen
    end
end


local function SetDraggable(self: GuiObject)
    table.insert(Draggables, self)
    local DragOrigin
    local GuiOrigin
    local TouchId = nil

    self.InputBegan:Connect(function(Input: InputObject, Process: boolean)
        
        if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
            for _, v in ipairs(Draggables) do
                v.ZIndex = 1
            end
            self.ZIndex = 2

            Dragging = {Gui = self, True = true}
            DragOrigin = Vector2.new(Input.Position.X, Input.Position.Y)
            GuiOrigin = self.Position
        end
        
        if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.Touch) then
            for _, v in ipairs(Draggables) do
                v.ZIndex = 1
            end
            self.ZIndex = 2

            Dragging = {Gui = self, True = true}
            DragOrigin = Vector2.new(Input.Position.X, Input.Position.Y)
            GuiOrigin = self.Position
            TouchId = Input
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    if Dragging.Gui == self then
                        Dragging = {Gui = nil, True = false}
                        TouchId = nil
                    end
                end
            end)
        end
    end)

    UserInput.InputChanged:Connect(function(Input: InputObject, Process: boolean)
        if Dragging.Gui ~= self then return end
        
        
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            if not (UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
                Dragging = {Gui = nil, True = false}
                return
            end
        
        elseif Input.UserInputType == Enum.UserInputType.Touch then
            if TouchId == nil then return end
        else
            return
        end
        
        local Delta = Vector2.new(Input.Position.X, Input.Position.Y) - DragOrigin
        local ScreenSize = Menu.ScreenSize
        local GuiSize = self.AbsoluteSize
        local Anchor = self.AnchorPoint

        local ScaleX = (ScreenSize.X * GuiOrigin.X.Scale)
        local ScaleY = (ScreenSize.Y * GuiOrigin.Y.Scale)
        
        
        local minX = GuiSize.X * Anchor.X
        local minY = GuiSize.Y * Anchor.Y
        local maxX = ScreenSize.X - GuiSize.X * (1 - Anchor.X)
        local maxY = ScreenSize.Y - GuiSize.Y * (1 - Anchor.Y)
        
        local OffsetX = math.clamp(GuiOrigin.X.Offset + Delta.X + ScaleX, minX, maxX)
        local OffsetY = math.clamp(GuiOrigin.Y.Offset + Delta.Y + ScaleY, minY, maxY)
        
        local Position = UDim2.fromOffset(OffsetX, OffsetY)
        self.Position = Position
    end)
end


Menu.Screen = Instance.new("ScreenGui")
Menu.Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protect_gui(Menu.Screen, CoreGui)
Menu.ScreenSize = Menu.Screen.AbsoluteSize


local Menu_Frame = Instance.new("Frame")
local MenuScaler_Button = Instance.new("TextButton")
local Title_Label = Instance.new("TextLabel")
local Icon_Image = Instance.new("ImageLabel")
local TabHandler_Frame = Instance.new("Frame")
local TabIndex_Frame = Instance.new("Frame")
local Tabs_Frame = Instance.new("Frame")

local Notifications_Frame = Instance.new("Frame")
local MenuDim_Frame = Instance.new("Frame")
local ToolTip_Label = Instance.new("TextLabel")
local Modal = Instance.new("TextButton")

Menu_Frame.Name = "Menu"
Menu_Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Menu_Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
Menu_Frame.BorderMode = Enum.BorderMode.Inset

Menu_Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Menu_Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Menu_Frame.Size = UDim2.new(0, math.floor(500 * UIScale), 0, math.floor(550 * UIScale))
Menu_Frame.Visible = false
Menu_Frame.Parent = Menu.Screen
CreateStroke(Menu_Frame, Color3.new(), 2)
CreateLine(Menu_Frame, UDim2.new(1, -8, 0, 1), UDim2.new(0, 4, 0, 15))
SetDraggable(Menu_Frame)


local MenuUIScale = Instance.new("UIScale")
MenuUIScale.Scale = isMobile and 0.70 or 1 
MenuUIScale.Parent = Menu_Frame

MenuScaler_Button.Name = "MenuScaler"
MenuScaler_Button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MenuScaler_Button.BorderColor3 = Color3.fromRGB(40, 40, 40)
MenuScaler_Button.BorderSizePixel = 0
MenuScaler_Button.Position = UDim2.new(1, -15, 1, -15)
MenuScaler_Button.Size = UDim2.fromOffset(15, 15)
MenuScaler_Button.Font = Enum.Font.SourceSans
MenuScaler_Button.Text = ""
MenuScaler_Button.TextColor3 = Color3.new(1, 1, 1)
MenuScaler_Button.TextSize = 14
MenuScaler_Button.AutoButtonColor = false
MenuScaler_Button.Parent = Menu_Frame
MenuScaler_Button.InputBegan:Connect(function(Input, Process)
    if Process then return end
    if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        UpdateSelected()
        Scaling = {
            True = true,
            Origin = Vector2.new(Input.Position.X, Input.Position.Y),
            Size = Menu_Frame.AbsoluteSize - Vector2.new(0, 36)
        }
    end
end)
MenuScaler_Button.InputEnded:Connect(function(Input, Process)
    if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
        UpdateSelected()
        Scaling = {
            True = false,
            Origin = nil,
            Size = nil
        }
    end
end)


Icon_Image.Name = "Icon"
Icon_Image.BackgroundTransparency = 1
Icon_Image.Position = UDim2.new(0, 5, 0, 0)
Icon_Image.Size = UDim2.fromOffset(15, 15)
Icon_Image.Image = "rbxassetid://0"
Icon_Image.Visible = false
Icon_Image.Parent = Menu_Frame

Title_Label.Name = "Title"
Title_Label.BackgroundTransparency = 1
Title_Label.Position = UDim2.new(0, math.floor(5 * UIScale), 0, 0)
Title_Label.Size = UDim2.new(1, math.floor(-10 * UIScale), 0, math.floor(17 * UIScale))
Title_Label.Font = Enum.Font.SourceSans
Title_Label.Text = ""
Title_Label.TextColor3 = Color3.new(1, 1, 1)
Title_Label.TextSize = math.floor(14 * UIScale)
Title_Label.TextXAlignment = Enum.TextXAlignment.Left
Title_Label.RichText = true
Title_Label.Parent = Menu_Frame

TabHandler_Frame.Name = "TabHandler"
TabHandler_Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TabHandler_Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
TabHandler_Frame.BorderMode = Enum.BorderMode.Inset
TabHandler_Frame.Position = UDim2.new(0, 4, 0, 19)
TabHandler_Frame.Size = UDim2.new(1, -8, 1, -25)
TabHandler_Frame.Parent = Menu_Frame
CreateStroke(TabHandler_Frame, Color3.new(), 2)

TabIndex_Frame.Name = "TabIndex"
TabIndex_Frame.BackgroundTransparency = 1
TabIndex_Frame.Position = UDim2.new(0, 1, 0, 1)
TabIndex_Frame.Size = UDim2.new(1, -2, 0, 20)
TabIndex_Frame.Parent = TabHandler_Frame

Tabs_Frame.Name = "Tabs"
Tabs_Frame.BackgroundTransparency = 1
Tabs_Frame.Position = UDim2.new(0, 1, 0, 26)
Tabs_Frame.Size = UDim2.new(1, -2, 1, -25)
Tabs_Frame.Active = false 
Tabs_Frame.Parent = TabHandler_Frame

Notifications_Frame.Name = "Notifications"
Notifications_Frame.BackgroundTransparency = 1
Notifications_Frame.Size = UDim2.new(1, 0, 1, 36)
Notifications_Frame.Position = UDim2.fromOffset(0, -36)
Notifications_Frame.ZIndex = 5
Notifications_Frame.Parent = Menu.Screen

ToolTip_Label.Name = "ToolTip"
ToolTip_Label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToolTip_Label.BorderColor3 = Menu.BorderColor
ToolTip_Label.BorderMode = Enum.BorderMode.Inset
ToolTip_Label.AutomaticSize = Enum.AutomaticSize.XY
ToolTip_Label.Size = UDim2.fromOffset(0, 0, 0, 15)
ToolTip_Label.Text = ""
ToolTip_Label.TextSize = 14
ToolTip_Label.Font = Enum.Font.SourceSans
ToolTip_Label.TextColor3 = Color3.new(1, 1, 1)
ToolTip_Label.ZIndex = 5
ToolTip_Label.Visible = false
ToolTip_Label.Parent = Menu.Screen
CreateStroke(ToolTip_Label, Color3.new(), 1)
AddEventListener(ToolTip_Label, function()
    ToolTip_Label.BorderColor3 = Menu.BorderColor
end)

Modal.Name = "Modal"
Modal.BackgroundTransparency = 1
Modal.Modal = true
Modal.Text = ""
Modal.Parent = Menu_Frame



SelectedTabLines.Left = CreateLine(nil, UDim2.new(0, 1, 1, 0), UDim2.new(), Color3.new())
SelectedTabLines.Right = CreateLine(nil, UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0), Color3.new())
SelectedTabLines.Bottom = CreateLine(TabIndex_Frame, UDim2.new(), UDim2.new(0, 0, 1, 0), Color3.new())
SelectedTabLines.Bottom2 = CreateLine(TabIndex_Frame, UDim2.new(), UDim2.new(), Color3.new())


local function GetDictionaryLength(Dictionary: table)
    local Length = 0
    for _ in pairs(Dictionary) do
        Length += 1
    end
    return Length
end


local function UpdateSelectedTabLines(Tab: Tab)
    if not Tab then return end

    if (Tab.Button.AbsolutePosition.X > Tab.self.AbsolutePosition.X) then
        SelectedTabLines.Left.Visible = true
    else
        SelectedTabLines.Left.Visible = false
    end

    if (Tab.Button.AbsolutePosition.X + Tab.Button.AbsoluteSize.X < Tab.self.AbsolutePosition.X + Tab.self.AbsoluteSize.X) then
        SelectedTabLines.Right.Visible = true
    else
        SelectedTabLines.Right.Visible = false
    end

    
    SelectedTabLines.Left.Parent = Tab.Button
    SelectedTabLines.Right.Parent = Tab.Button

    local FRAME_POSITION = Tab.self.AbsolutePosition
    local BUTTON_POSITION = Tab.Button.AbsolutePosition
    local BUTTON_SIZE = Tab.Button.AbsoluteSize
    local LENGTH = BUTTON_POSITION.X - FRAME_POSITION.X
    local OFFSET = (BUTTON_POSITION.X + BUTTON_SIZE.X) - FRAME_POSITION.X

    SelectedTabLines.Bottom.Size = UDim2.new(0, LENGTH + 1, 0, 1)
    SelectedTabLines.Bottom2.Size = UDim2.new(1, -OFFSET, 0, 1)
    SelectedTabLines.Bottom2.Position = UDim2.new(0, OFFSET, 1, 0)
end


local function UpdateTabs()
    for _, Tab in pairs(Tabs) do
        Tab.Button.Size = UDim2.new(1 / GetDictionaryLength(Tabs), 0, 1, 0)
        Tab.Button.Position = UDim2.new((1 / GetDictionaryLength(Tabs)) * (Tab.Index - 1), 0, 0, 0)
    end
    UpdateSelectedTabLines(SelectedTab)
end


local function GetTab(Tab_Name: string): Tab
    assert(Tab_Name, "NO TAB_NAME GIVEN")
    return Tabs[Tab_Name]
end


local function ChangeTab(Tab_Name: string)
    assert(Tabs[Tab_Name], "Tab \"" .. tostring(Tab_Name) .. "\" does not exist!")
    for _, Tab in pairs(Tabs) do
        Tab.self.Visible = false
        Tab.Button.BackgroundColor3 = Menu.ItemColor
        Tab.Button.TextColor3 = Color3.fromRGB(205, 205, 205)
    end
    local Tab = GetTab(Tab_Name)
    Tab.self.Visible = true
    Tab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Tab.Button.TextColor3 = Color3.new(1, 1, 1)

    SelectedTab = Tab
    UpdateSelected()
    UpdateSelectedTabLines(Tab)
end


local function GetContainer(Tab_Name: string, Container_Name: string): Container
    assert(Tab_Name, "NO TAB_NAME GIVEN")
    assert(Container_Name, "NO CONTAINER NAME GIVEN")
    return GetTab(Tab_Name)[Container_Name]
end


local function CheckItemIndex(Item_Index: number, Method: string)
    assert(typeof(Item_Index) == "number", "invalid argument #1 to '" .. Method .. "' (number expected, got " .. typeof(Item_Index) .. ")")
    assert(Item_Index <= #Items and Item_Index > 0, "invalid argument #1 to '" .. Method .. "' (index out of range")
end


function Menu:GetItem(Index: number): Item
    CheckItemIndex(Index, "GetItem")
    return Items[Index]
end


function Menu:FindItem(Tab_Name: string, Container_Name: string, Class_Name: string, Name: string): Item
    local Result
    for Index, Item in ipairs(Items) do
        if Item.Tab == Tab_Name and Item.Container == Container_Name then
            if Item.Name == Name and (Item.Class == Class_Name) then
                Result = Index
                break
            end
        end
    end

    if Result then
        return Menu:GetItem(Result)
    else
        return error("Item " .. tostring(Name) .. " was not found")
    end
end


function Menu:SetTitle(Name: string)
    Title_Label.Text = tostring(Name)
end


function Menu:SetIcon(Icon: string)
    if typeof(Icon) == "string" or typeof(Icon) == "number" then
        Title_Label.Position = UDim2.fromOffset(20, 0)
        Title_Label.Size = UDim2.new(1, -40, 0, 15)
        Icon_Image.Image = "rbxassetid://" .. string.gsub(tostring(Icon), "rbxassetid://", "")
        Icon_Image.Visible = true
    else
        Title_Label.Position = UDim2.fromOffset(5, 0)
        Title_Label.Size = UDim2.new(1, -10, 0, 15)
        Icon_Image.Image = ""
        Icon_Image.Visible = false
    end
end


function Menu:SetSize(Size: Vector2)
    local Size = typeof(Size) == "Vector2" and Size or typeof(Size) == "UDim2" and Vector2.new(Size.X, Size.Y) or Menu.MinSize
    local X = Size.X
    local Y = Size.Y

    if (X > Menu.MinSize.X and X < Menu.MaxSize.X) then
        X = math.clamp(X, Menu.MinSize.X, Menu.MaxSize.X)
    end
    if (Y > Menu.MinSize.Y and Y < Menu.MaxSize.Y) then
        Y = math.clamp(Y, Menu.MinSize.Y, Menu.MaxSize.Y)
    end

    Menu_Frame.Size = UDim2.fromOffset(X, Y)
    UpdateTabs()
end


local onVisibilityChangedCallbacks = {}

function Menu:SetVisible(Visible: boolean)
    local IsVisible = typeof(Visible) == "boolean" and Visible
    Menu_Frame.Visible = IsVisible
    Menu.IsVisible = IsVisible
    if IsVisible == false then
        UpdateSelected()
    end
    
    for _, callback in pairs(onVisibilityChangedCallbacks) do
        pcall(callback, IsVisible)
    end
end

function Menu:OnVisibilityChanged(callback)
    table.insert(onVisibilityChangedCallbacks, callback)
end


function Menu:SetTab(Tab_Name: string)
    ChangeTab(Tab_Name)
end

function Menu:SetUIScale(scale: number)
    
    local scaleValue = math.clamp(scale, 50, 200) / 100
    MenuUIScale.Scale = scaleValue
    Menu.CurrentUIScale = scale
end

function Menu:GetUIScale(): number
    return Menu.CurrentUIScale or (isMobile and 70 or 100)
end


function Menu:SetToolTip(Enabled: boolean, Content: string, Item: Instance)
    ToolTip = {
        Enabled = Enabled,
        Content = Content,
        Item = Item
    }

    ToolTip_Label.Visible = Enabled
end


function Menu.Line(Parent: Instance, Size: UDim2, Position: UDim2): Line
    local Line = {self = CreateLine(Parent, Size, Position)}
    Line.Class = "Line"
    return Line
end


function Menu.Tab(Tab_Name: string): Tab
    assert(Tab_Name and typeof(Tab_Name) == "string", "TAB_NAME REQUIRED")
    if Tabs[Tab_Name] then return error("TAB_NAME '" .. tostring(Tab_Name) .. "' ALREADY EXISTS") end
    local Frame = Instance.new("Frame")
    local Button = Instance.new("TextButton")

    local Tab = {self = Frame, Button = Button}
    Tab.Class = "Tab"
    Tab.Index = GetDictionaryLength(Tabs) + 1


    local function CreateSide(Side: string)
        local Frame = Instance.new("ScrollingFrame")
        local ListLayout = Instance.new("UIListLayout")

        Frame.Name = Side
        Frame.Active = true
        Frame.BackgroundTransparency = 1
        Frame.BorderSizePixel = 0
        Frame.Size = Side == "Middle" and UDim2.new(1, -10, 1, -10) or UDim2.new(0.5, -10, 1, -10)
        Frame.Position = (Side == "Left" and UDim2.fromOffset(5, 5)) or (Side == "Right" and UDim2.new(0.5, 5, 0, 5) or Side == "Middle" and UDim2.fromOffset(5, 5))
        Frame.CanvasSize = UDim2.new(0, 0, 0, -10)
        Frame.ScrollBarThickness = isMobile and 6 or 2 
        Frame.ScrollBarImageColor3 = Menu.Accent
        Frame.ScrollingEnabled = true
        Frame.ScrollingDirection = Enum.ScrollingDirection.Y
        Frame.ElasticBehavior = Enum.ElasticBehavior.Always
        Frame.Parent = Tab.self
        AddEventListener(Frame, function()
            Frame.ScrollBarImageColor3 = Menu.Accent
        end)
        Frame:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateSelected)

        ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 10)
        ListLayout.Parent = Frame
    end


    Button.Name = "Button"
    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.SourceSans
    Button.Text = Tab_Name
    Button.TextColor3 = Color3.fromRGB(205, 205, 205)
    Button.TextSize = math.floor(14 * UIScale)
    Button.Parent = TabIndex_Frame
    AddEventListener(Button, function()
        if Button.TextColor3 == Color3.fromRGB(205, 205, 205) then
            Button.BackgroundColor3 = Menu.ItemColor
        end
        Button.BackgroundColor3 = Menu.ItemColor
        Button.BorderColor3 = Menu.BorderColor
    end)
    Button.MouseButton1Click:Connect(function()
        ChangeTab(Tab_Name)
    end)
    
    Frame.Name = Tab_Name .. "Tab"
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.Visible = false
    Frame.Parent = Tabs_Frame

    CreateSide("Middle")
    CreateSide("Left")
    CreateSide("Right")

    Tabs[Tab_Name] = Tab

    
    if Tab.Index == 1 then
        ChangeTab(Tab_Name)
    end
    UpdateTabs()
    return Tab
end


function Menu.Container(Tab_Name: string, Container_Name: string, Side: string): Container
    local Tab = GetTab(Tab_Name)
    assert(typeof(Tab_Name) == "string", "TAB_NAME REQUIRED")
    if Tab[Container_Name] then return error("CONTAINER_NAME '" .. tostring(Container_Name) .. "' ALREADY EXISTS") end
    local Side = Side or "Left"

    local Frame = Instance.new("Frame")
    local Label = CreateLabel(Frame, "Title", Container_Name, UDim2.fromOffset(math.floor(206 * UIScale), math.floor(17 * UIScale)),  UDim2.fromOffset(math.floor(5 * UIScale), 0))
    local Line = CreateLine(Frame, UDim2.new(1, math.floor(-10 * UIScale), 0, 1), UDim2.fromOffset(math.floor(5 * UIScale), math.floor(17 * UIScale)))

    local Container = {self = Frame, Height = 0}
    Container.Class = "Container"
    Container.Visible = true

    function Container:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function Container:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if self.Visible == Visible then return end
        
        Frame.Visible = Visible
        self.Visible = Visible
        self:UpdateSize(Visible and 25 or -25, Frame)
    end

    function Container:UpdateSize(Height: float, Item: GuiObject)
        self.Height += Height
        Frame.Size += UDim2.fromOffset(0, Height)
        Tab.self[Side].CanvasSize += UDim2.fromOffset(0, Height)

        if Item then
            local ItemY = Item.AbsolutePosition.Y
            if math.sign(Height) == 1 then
                ItemY -= 1
            end

            for _, item in ipairs(Frame:GetChildren()) do
                if (item == Label or item == Line or item == Stroke or Item == item) then continue end 
                local item_y = item.AbsolutePosition.Y
                if item_y > ItemY then
                    item.Position += UDim2.fromOffset(0, Height)
                end
            end
        end
    end

    function Container:GetHeight(): number
        return self.Height
    end


    Frame.Name = "Container"
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderColor3 = Color3.new()
    Frame.BorderMode = Enum.BorderMode.Inset
    Frame.Size = UDim2.new(1, -6, 0, 0)
    Frame.Active = false 
    Frame.Parent = Tab.self[Side]

    Container:UpdateSize(math.floor(28 * UIScale))
    Tab.self[Side].CanvasSize += UDim2.fromOffset(0, math.floor(10 * UIScale))
    Tab[Container_Name] = Container
    return Container
end


function Menu.Label(Tab_Name: string, Container_Name: string, Name: string, ToolTip: string): Label
    local Container = GetContainer(Tab_Name, Container_Name)
    local GuiLabel = CreateLabel(Container.self, "Label", Name, nil, UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight()))

    GuiLabel.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, GuiLabel)
        end
    end)
    GuiLabel.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)

    local Label = {self = Label}
    Label.Name = Name
    Label.Class = "Label"
    Label.Index = #Items + 1
    Label.Tab = Tab_Name
    Label.Container = Container_Name

    function Label:SetLabel(Name: string)
        GuiLabel.Text = tostring(Name)
    end

    function Label:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if GuiLabel.Visible == Visible then return end
        
        GuiLabel.Visible = Visible
        Container:UpdateSize(Visible and 20 or -20, GuiLabel)
    end

    Container:UpdateSize(math.floor(22 * UIScale))
    table.insert(Items, Label)
    return Label
end


function Menu.Button(Tab_Name: string, Container_Name: string, Name: string, Callback: any, ToolTip: string): Button
    local Container = GetContainer(Tab_Name, Container_Name)
    local GuiButton = Instance.new("TextButton")

    local Button = {self = GuiButton}
    Button.Name = Name
    Button.Class = "Button"
    Button.Tab = Tab_Name
    Button.Container = Container_Name
    Button.Index = #Items + 1
    Button.Callback = typeof(Callback) == "function" and Callback or function() end
    
    local scaledHeight = math.floor(20 * UIScale)

    
    function Button:SetLabel(Name: string)
        GuiButton.Text = tostring(Name)
    end

    function Button:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if GuiButton.Visible == Visible then return end
        
        GuiButton.Visible = Visible
        Container:UpdateSize(Visible and 25 or -25, GuiButton)
    end


    GuiButton.Name = "Button"
    GuiButton.BackgroundColor3 = Menu.ItemColor
    GuiButton.BorderColor3 = Menu.BorderColor
    GuiButton.BorderMode = Enum.BorderMode.Inset
    GuiButton.Position = UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight())
    GuiButton.Size = UDim2.new(1, math.floor(-50 * UIScale), 0, scaledHeight)
    GuiButton.Font = Enum.Font.SourceSansSemibold
    GuiButton.Text = Name
    GuiButton.TextColor3 = Color3.new(1, 1, 1)
    GuiButton.TextSize = math.floor(14 * UIScale)
    GuiButton.TextTruncate = Enum.TextTruncate.AtEnd
    GuiButton.Parent = Container.self
    CreateStroke(GuiButton, Color3.new(), 1)
    AddEventListener(GuiButton, function()
        GuiButton.BackgroundColor3 = Menu.ItemColor
        GuiButton.BorderColor3 = Menu.BorderColor
    end)
    GuiButton.MouseButton1Click:Connect(function()
        Button.Callback()
    end)
    GuiButton.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, GuiButton)
        end
    end)
    GuiButton.MouseLeave:Connect(function()
        Menu:SetToolTip(false)
    end)

    Container:UpdateSize(math.floor(28 * UIScale))
    table.insert(Items, Button)
    return Button
end


function Menu.TextBox(Tab_Name: string, Container_Name: string, Name: string, Value: string, Callback: any, ToolTip: string): TextBox
    local Container = GetContainer(Tab_Name, Container_Name)
    local Label = CreateLabel(Container.self, "TextBox", Name, nil, UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight()))
    local GuiTextBox = Instance.new("TextBox")

    local configKey = Tab_Name .. "_" .. Container_Name .. "_" .. Name .. "_textbox"
    
    local TextBox = {self = GuiTextBox}
    TextBox.Name = Name
    TextBox.Class = "TextBox"
    TextBox.Tab = Tab_Name
    TextBox.Container = Container_Name
    TextBox.Index = #Items + 1
    TextBox.Value = getConfigValue(configKey, typeof(Value) == "string" and Value or "")
    TextBox.Callback = typeof(Callback) == "function" and Callback or function() end


    function TextBox:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function TextBox:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Label.Visible == Visible then return end
        
        Label.Visible = Visible
        Container:UpdateSize(Visible and 45 or -45, Label)
    end

    function TextBox:GetValue(): string
        return self.Value
    end

    function TextBox:SetValue(Value: string)
        self.Value = tostring(Value)
        GuiTextBox.Text = self.Value
    end


    GuiTextBox.Name = "TextBox"
    GuiTextBox.BackgroundColor3 = Menu.ItemColor
    GuiTextBox.BorderColor3 = Menu.BorderColor
    GuiTextBox.BorderMode = Enum.BorderMode.Inset
    GuiTextBox.Position = UDim2.fromOffset(0, 20)
    GuiTextBox.Size = UDim2.new(1, -50, 0, 20)
    GuiTextBox.Font = Enum.Font.SourceSansSemibold
    GuiTextBox.Text = TextBox.Value
    GuiTextBox.TextColor3 = Color3.new(1, 1, 1)
    GuiTextBox.TextSize = 14
    GuiTextBox.ClearTextOnFocus = false
    GuiTextBox.ClipsDescendants = true
    GuiTextBox.Parent = Label
    CreateStroke(GuiTextBox, Color3.new(), 1)
    AddEventListener(GuiTextBox, function()
        GuiTextBox.BackgroundColor3 = Menu.ItemColor
        GuiTextBox.BorderColor3 = Menu.BorderColor
    end)
    GuiTextBox.FocusLost:Connect(function()
        TextBox.Value = GuiTextBox.Text
        TextBox.Callback(GuiTextBox.Text)
        setConfigValue(configKey, GuiTextBox.Text)
    end)
    GuiTextBox.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, GuiTextBox)
        end
    end)
    GuiTextBox.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)

    Container:UpdateSize(math.floor(50 * UIScale))
    table.insert(Items, TextBox)
    return TextBox
end


function Menu.CheckBox(Tab_Name: string, Container_Name: string, Name: string, Boolean: boolean, Callback: any, ToolTip: string): CheckBox
    local Container = GetContainer(Tab_Name, Container_Name)
    local Label = CreateLabel(Container.self, "CheckBox", Name, nil, UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight()))
    local Button = Instance.new("TextButton")
    
    local configKey = Tab_Name .. "_" .. Container_Name .. "_" .. Name
    
    local CheckBox = {self = Label}
    CheckBox.Name = Name
    CheckBox.Class = "CheckBox"
    CheckBox.Tab = Tab_Name
    CheckBox.Container = Container_Name
    CheckBox.Index = #Items + 1
    CheckBox.Value = getConfigValue(configKey, typeof(Boolean) == "boolean" and Boolean or false)
    CheckBox.Callback = typeof(Callback) == "function" and Callback or function() end
    CheckBox._initialized = false


    function CheckBox:Update(Value: boolean, skipSave: boolean)
        if typeof(Value) == "boolean" then
            self.Value = Value
        end
        Button.BackgroundColor3 = self.Value and Menu.Accent or Menu.ItemColor
        if not skipSave and self._initialized then
            setConfigValue(configKey, self.Value)
        end
    end

    function CheckBox:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function CheckBox:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Label.Visible == Visible then return end
        
        Label.Visible = Visible
        Container:UpdateSize(Visible and 20 or -20, Label)
    end

    function CheckBox:GetValue(): boolean
        return self.Value
    end

    function CheckBox:SetValue(Value: boolean)
        self:Update(Value)
    end


    Label.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, Label)
        end
    end)
    Label.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)

    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderColor3 = Color3.new()
    Button.Position = UDim2.fromOffset(math.floor(-14 * UIScale), math.floor(4 * UIScale))
    Button.Size = UDim2.fromOffset(math.floor(10 * UIScale), math.floor(10 * UIScale))
    Button.Text = ""
    Button.Parent = Label
    AddEventListener(Button, function()
        Button.BackgroundColor3 = CheckBox.Value and Menu.Accent or Menu.ItemColor
    end)
    Button.MouseButton1Click:Connect(function()
        CheckBox:Update(not CheckBox.Value)
        CheckBox.Callback(CheckBox.Value)
    end)
    
    
    local HitArea = Instance.new("TextButton")
    HitArea.Name = "HitArea"
    HitArea.Size = UDim2.new(1, 20, 1, 6)
    HitArea.Position = UDim2.fromOffset(-18, -3)
    HitArea.BackgroundTransparency = 1
    HitArea.Text = ""
    HitArea.ZIndex = 0
    HitArea.Parent = Label
    HitArea.MouseButton1Click:Connect(function()
        CheckBox:Update(not CheckBox.Value)
        CheckBox.Callback(CheckBox.Value)
    end)

    CheckBox:Update(CheckBox.Value, true) 
    CheckBox._initialized = true
    if CheckBox.Value then CheckBox.Callback(CheckBox.Value) end
    Container:UpdateSize(math.floor(20 * UIScale))
    table.insert(Items, CheckBox)
    return CheckBox
end


function Menu.Hotkey(Tab_Name: string, Container_Name: string, Name: string, Key:EnumItem, Callback: any, ToolTip: string): Hotkey
    local Container = GetContainer(Tab_Name, Container_Name)
    local Label = CreateLabel(Container.self, "Hotkey", Name, nil, UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight()))
    local Button = Instance.new("TextButton")
    local Selected_Hotkey = Instance.new("Frame")
    local HotkeyToggle = Instance.new("TextButton")
    local HotkeyHold = Instance.new("TextButton")

    local configKey = Tab_Name .. "_" .. Container_Name .. "_" .. Name .. "_hotkey"
    local savedHotkey = getConfigValue(configKey, nil)
    
    local Hotkey = {self = Label}
    Hotkey.Name = Name
    Hotkey.Class = "Hotkey"
    Hotkey.Tab = Tab_Name
    Hotkey.Container = Container_Name
    Hotkey.Index = #Items + 1
    
    if savedHotkey then
        local keyEnum = Enum.KeyCode:GetEnumItems()
        for _, k in ipairs(keyEnum) do
            if k.Name == savedHotkey.key then
                Hotkey.Key = k
                break
            end
        end
        if not Hotkey.Key then
            local inputEnum = Enum.UserInputType:GetEnumItems()
            for _, k in ipairs(inputEnum) do
                if k.Name == savedHotkey.key then
                    Hotkey.Key = k
                    break
                end
            end
        end
        Hotkey.Mode = savedHotkey.mode or "Toggle"
    else
        Hotkey.Key = typeof(Key) == "EnumItem" and Key or nil
        Hotkey.Mode = "Toggle"
    end
    
    Hotkey.Callback = typeof(Callback) == "function" and Callback or function() end
    Hotkey.Editing = false


    function Hotkey:Update(Input: EnumItem, Mode: string, skipSave: boolean)
        Button.Text = Input and string.format("[%s]", Input.Name) or "[None]"

        self.Key = Input
        self.Mode = Mode or "Toggle"
        self.Editing = false
        if not skipSave then
            setConfigValue(configKey, {key = Input and Input.Name or nil, mode = self.Mode})
        end
    end

    function Hotkey:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function Hotkey:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Label.Visible == Visible then return end
        
        Label.Visible = Visible
        Container:UpdateSize(Visible and 20 or -20, Label)
    end

    function Hotkey:GetValue(): EnumItem
        return self.Key, self.Mode
    end

    function Hotkey:SetValue(Key: EnumItem, Mode: string)
        self:Update(Key, Mode)
    end


    Label.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, Label)
        end
    end)
    Label.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)

    Button.Name = "Hotkey"
    Button.BackgroundTransparency = 1
    Button.Position = UDim2.new(1, -100, 0, 4)
    Button.Size = UDim2.fromOffset(75, 8)
    Button.Font = Enum.Font.SourceSans
    Button.Text = Hotkey.Key and "[" .. Hotkey.Key.Name .. "]" or "[None]"
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 12
    Button.TextXAlignment = Enum.TextXAlignment.Right
    Button.Parent = Label

    Selected_Hotkey.Name = "Selected_Hotkey"
    Selected_Hotkey.Visible = false
    Selected_Hotkey.BackgroundColor3 = Menu.ItemColor
    Selected_Hotkey.BorderColor3 = Menu.BorderColor
    Selected_Hotkey.Position = UDim2.fromOffset(200, 100)
    Selected_Hotkey.Size = UDim2.fromOffset(100, 30)
    Selected_Hotkey.Parent = nil
    CreateStroke(Selected_Hotkey, Color3.new(), 1)
    AddEventListener(Selected_Hotkey, function()
        Selected_Hotkey.BackgroundColor3 = Menu.ItemColor
        Selected_Hotkey.BorderColor3 = Menu.BorderColor
    end)

    HotkeyToggle.Parent = Selected_Hotkey
    HotkeyToggle.BackgroundColor3 = Menu.ItemColor
    HotkeyToggle.BorderColor3 = Color3.new()
    HotkeyToggle.BorderSizePixel = 0
    HotkeyToggle.Position = UDim2.new()
    HotkeyToggle.Size = UDim2.new(1, 0, 0, 13)
    HotkeyToggle.Font = Enum.Font.SourceSans
    HotkeyToggle.Text = "Toggle"
    HotkeyToggle.TextColor3 = Menu.Accent
    HotkeyToggle.TextSize = 14
    AddEventListener(HotkeyToggle, function()
        HotkeyToggle.BackgroundColor3 = Menu.ItemColor
        if Hotkey.Mode == "Toggle" then
            HotkeyToggle.TextColor3 = Menu.Accent
        end
    end)
    HotkeyToggle.MouseButton1Click:Connect(function()
        Hotkey:Update(Hotkey.Key, "Toggle")
        HotkeyToggle.TextColor3 = Menu.Accent
        HotkeyHold.TextColor3 = Color3.new(1, 1, 1)
        UpdateSelected()
        Hotkey.Callback(Hotkey.Key, Hotkey.Mode)
    end)

    HotkeyHold.Parent = Selected_Hotkey
    HotkeyHold.BackgroundColor3 = Menu.ItemColor
    HotkeyHold.BorderColor3 = Color3.new()
    HotkeyHold.BorderSizePixel = 0
    HotkeyHold.Position = UDim2.new(0, 0, 0, 15)
    HotkeyHold.Size = UDim2.new(1, 0, 0, 13)
    HotkeyHold.Font = Enum.Font.SourceSans
    HotkeyHold.Text = "Hold"
    HotkeyHold.TextColor3 = Color3.new(1, 1, 1)
    HotkeyHold.TextSize = 14
    AddEventListener(HotkeyHold, function()
        HotkeyHold.BackgroundColor3 = Menu.ItemColor
        if Hotkey.Mode == "Hold" then
            HotkeyHold.TextColor3 = Menu.Accent
        end
    end)
    HotkeyHold.MouseButton1Click:Connect(function()
        Hotkey:Update(Hotkey.Key, "Hold")
        HotkeyHold.TextColor3 = Menu.Accent
        HotkeyToggle.TextColor3 = Color3.new(1, 1, 1)
        UpdateSelected()
        Hotkey.Callback(Hotkey.Key, Hotkey.Mode)
    end)

    Button.MouseButton1Click:Connect(function()
        Button.Text = "..."
        Hotkey.Editing = true
        if UserInput:IsKeyDown(HotkeyRemoveKey) and Key ~= HotkeyRemoveKey then
            Hotkey:Update()
            Hotkey.Callback(nil, Hotkey.Mode)
        end
    end)
    Button.MouseButton2Click:Connect(function()
        UpdateSelected(Selected_Hotkey, Button, UDim2.fromOffset(100, 0))
    end)

    UserInput.InputBegan:Connect(function(Input)
        if Hotkey.Editing then
            local Key = Input.KeyCode
            if Key == Enum.KeyCode.Unknown then
                local InputType = Input.UserInputType
                
                if InputType == Enum.UserInputType.Touch then
                    return
                end
                Hotkey:Update(InputType)
                Hotkey.Callback(InputType, Hotkey.Mode)
            else
                Hotkey:Update(Key)
                Hotkey.Callback(Key, Hotkey.Mode)
            end
        end
    end)

    Container:UpdateSize(math.floor(22 * UIScale))
    table.insert(Items, Hotkey)
    
    
    if Hotkey.Key then
        task.defer(function()
            Hotkey.Callback(Hotkey.Key, Hotkey.Mode)
        end)
    end
    
    return Hotkey
end


function Menu.Slider(Tab_Name: string, Container_Name: string, Name: string, Min: number, Max: number, Value: number, Unit: string, Scale: number, Callback: any, ToolTip: string): Slider
    local Container = GetContainer(Tab_Name, Container_Name)
    local Label = CreateLabel(Container.self, "Slider", Name, UDim2.new(1, math.floor(-10 * UIScale), 0, math.floor(17 * UIScale)), UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight()))
    local Button = Instance.new("TextButton")
    local ValueBar = Instance.new("TextLabel")
    local ValueBox = Instance.new("TextBox")
    local ValueLabel = Instance.new("TextLabel")

    local configKey = Tab_Name .. "_" .. Container_Name .. "_" .. Name .. "_slider"
    local sliderHeight = isMobile and math.floor(12 * UIScale) or math.floor(6 * UIScale) 
    
    local Slider = {}
    Slider.Name = Name
    Slider.Class = "Slider"
    Slider.Tab = Tab_Name
    Slider.Container = Container_Name
    Slider.Index = #Items + 1
    Slider.Min = typeof(Min) == "number" and math.clamp(Min, Min, Max) or 0
    Slider.Max = typeof(Max) == "number" and Max or 100
    Slider.Value = getConfigValue(configKey, typeof(Value) == "number" and Value or 100)
    Slider.Unit = typeof(Unit) == "string" and Unit or ""
    Slider.Scale = typeof(Scale) == "number" and Scale or 0
    Slider.Callback = typeof(Callback) == "function" and Callback or function() end


    local function UpdateSlider(Percentage: number, skipSave)
        local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
        local Value = Slider.Min + ((Slider.Max - Slider.Min) * Percentage)
        local Scale = (10 ^ Slider.Scale)
        Slider.Value = math.round(Value * Scale) / Scale

        ValueBar.Size = UDim2.new(Percentage, 0, 1, 0) 
        ValueBox.Text = "[" .. Slider.Value .. "]"
        ValueLabel.Text = Slider.Value .. Slider.Unit
        if not skipSave then
            setConfigValue(configKey, Slider.Value)
        end
    end


    function Slider:Update(Percentage: number)
        UpdateSlider(Percentage)
    end

    function Slider:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function Slider:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Label.Visible == Visible then return end
        
        Label.Visible = Visible
        Container:UpdateSize(Visible and 30 or -30, Label)
    end

    function Slider:GetValue(): number
        return self.Value
    end

    function Slider:SetValue(Value: number, skipSave)
        self.Value = typeof(Value) == "number" and math.clamp(Value, self.Min, self.Max) or self.Min
        local Percentage = (self.Value - self.Min) / (self.Max - self.Min)
        UpdateSlider(Percentage, skipSave)
    end

    Slider.self = Label

    Label.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, Label)
        end
    end)
    Label.MouseLeave:Connect(function()
        Menu:SetToolTip(false)
    end)

    Button.Name = "Slider"
    Button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Button.BorderColor3 = Color3.new()
    Button.Position = UDim2.fromOffset(0, math.floor(22 * UIScale))
    Button.Size = UDim2.new(1, math.floor(-40 * UIScale), 0, sliderHeight)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Label

    ValueBar.Name = "ValueBar"
    ValueBar.BackgroundColor3 = Menu.Accent
    ValueBar.BorderSizePixel = 0
    ValueBar.Size = UDim2.fromScale(1, 1)
    ValueBar.Text = ""
    ValueBar.Parent = Button
    AddEventListener(ValueBar, function()
        ValueBar.BackgroundColor3 = Menu.Accent
    end)
    
    ValueBox.Name = "ValueBox"
    ValueBox.BackgroundTransparency = 1
    ValueBox.Position = UDim2.new(1, -65, 0, 5)
    ValueBox.Size = UDim2.fromOffset(50, 10)
    ValueBox.Font = Enum.Font.SourceSans
    ValueBox.Text = ""
    ValueBox.TextColor3 = Color3.new(1, 1, 1)
    ValueBox.TextSize = 12
    ValueBox.TextXAlignment = Enum.TextXAlignment.Right
    ValueBox.ClipsDescendants = true
    ValueBox.Parent = Label
    ValueBox.FocusLost:Connect(function()
        Slider.Value = tonumber(ValueBox.Text) or 0
        local Percentage = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
        Slider:Update(Percentage)
        Slider.Callback(Slider.Value)
    end)

    ValueLabel.Name = "ValueLabel"
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, 0, 0, 2)
    ValueLabel.Size = UDim2.new(0, 0, 1, 0)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.Text = ""
    ValueLabel.TextColor3 = Color3.new(1, 1, 1)
    ValueLabel.TextSize = 14
    ValueLabel.Parent = ValueBar

    local sliderTouchId = nil
    
    Button.InputBegan:Connect(function(Input: InputObject, Process: boolean)
        if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = {Gui = Button, True = true}
            if Input.UserInputType == Enum.UserInputType.Touch then
                sliderTouchId = Input
            end
            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
            local Percentage = (InputPosition - Button.AbsolutePosition) / Button.AbsoluteSize
            Slider:Update(Percentage.X)
            Slider.Callback(Slider.Value)
            
            
            if Input.UserInputType == Enum.UserInputType.Touch then
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        if Dragging.Gui == Button then
                            Dragging = {Gui = nil, True = false}
                            sliderTouchId = nil
                        end
                    end
                end)
            end
        end
    end)

    UserInput.InputChanged:Connect(function(Input: InputObject, Process: boolean)
        if Dragging.Gui ~= Button then return end
        
        
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            if not (UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
                Dragging = {Gui = nil, True = false}
                return
            end
            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
            local Percentage = (InputPosition - Button.AbsolutePosition) / Button.AbsoluteSize
            Slider:Update(Percentage.X)
            Slider.Callback(Slider.Value)
        
        elseif Input.UserInputType == Enum.UserInputType.Touch and sliderTouchId then
            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
            local Percentage = (InputPosition - Button.AbsolutePosition) / Button.AbsoluteSize
            Slider:Update(Percentage.X)
            Slider.Callback(Slider.Value)
        end
    end)


    Slider:SetValue(Slider.Value, true)
    Slider.Callback(Slider.Value)
    Container:UpdateSize(math.floor(35 * UIScale))
    table.insert(Items, Slider)
    return Slider
end


function Menu.ColorPicker(Tab_Name: string, Container_Name: string, Name: string, Color: Color3, Alpha: number, Callback: any, ToolTip: string): ColorPicker
    local Container = GetContainer(Tab_Name, Container_Name)
    local Label = CreateLabel(Container.self, "ColorPicker", Name, UDim2.new(1, -10, 0, 15), UDim2.fromOffset(20, Container:GetHeight()))
    local Button = Instance.new("TextButton")
    local Selected_ColorPicker = Instance.new("Frame")
    local HexBox = Instance.new("TextBox")
    local Saturation = Instance.new("ImageButton")
    local Alpha = Instance.new("ImageButton")
    local Hue = Instance.new("ImageButton")
    local SaturationCursor = Instance.new("Frame")
    local AlphaCursor = Instance.new("Frame")
    local HueCursor = Instance.new("Frame")
    local CopyButton = Instance.new("TextButton") 
    local PasteButton = Instance.new("TextButton") 
    local AlphaColorGradient = Instance.new("UIGradient")

    local ColorPicker = {self = Label}
    ColorPicker.Name = Name
    ColorPicker.Tab = Tab_Name
    ColorPicker.Class = "ColorPicker"
    ColorPicker.Container = Container_Name
    ColorPicker.Index = #Items + 1
    ColorPicker.Color = typeof(Color) == "Color3" and Color or Color3.new(1, 1, 1)
    ColorPicker.Saturation = {0, 0} 
    ColorPicker.Alpha = typeof(Alpha) == "number" and Alpha or 0
    ColorPicker.Hue = 0
    ColorPicker.Callback = typeof(Callback) == "function" and Callback or function() end


    local function UpdateColor()
        ColorPicker.Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2])

        HexBox.Text = "#" .. string.upper(ColorPicker.Color:ToHex()) .. string.upper(string.format("%X", ColorPicker.Alpha * 255))
        Button.BackgroundColor3 = ColorPicker.Color
        Saturation.BackgroundColor3 = ColorPicker.Color
        AlphaColorGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, ColorPicker.Color)}

        SaturationCursor.Position = UDim2.fromScale(math.clamp(ColorPicker.Saturation[1], 0, 0.95), math.clamp(1 - ColorPicker.Saturation[2], 0, 0.95))
        AlphaCursor.Position = UDim2.fromScale(0, math.clamp(ColorPicker.Alpha, 0, 0.98))
        HueCursor.Position = UDim2.fromScale(0, math.clamp(ColorPicker.Hue, 0, 0.98))

        ColorPicker.Callback(ColorPicker.Color, ColorPicker.Alpha)
    end


    function ColorPicker:Update()
        UpdateColor()
    end

    function ColorPicker:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function ColorPicker:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Label.Visible == Visible then return end
        
        Label.Visible = Visible
        Container:UpdateSize(Visible and 20 or -20, Label)
    end

    function ColorPicker:SetValue(Color: Color3, Alpha: number)
        self.Color, self.Alpha = typeof(Color) == "Color3" and Color or Color3.new(), typeof(Alpha) == "number" and Alpha or 0
        self.Hue, self.Saturation[1], self.Saturation[2] = self.Color:ToHSV()
        self:Update()
    end

    function ColorPicker:GetValue(): Color3
        return self.Color, self.Alpha
    end


    Label.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, Label)
        end
    end)
    Label.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)

    Button.Name = "ColorPicker"
    Button.BackgroundColor3 = ColorPicker.Color
    Button.BorderColor3 = Color3.new()
    Button.Position = UDim2.new(1, -35, 0, 4)
    Button.Size = UDim2.fromOffset(20, 8)
    Button.Font = Enum.Font.SourceSans
    Button.Text = ""
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 12
    Button.Parent = Label
    Button.MouseButton1Click:Connect(function()
        UpdateSelected(Selected_ColorPicker, Button, UDim2.fromOffset(20, 20))
    end)

    Selected_ColorPicker.Name = "Selected_ColorPicker"
    Selected_ColorPicker.Visible = false
    Selected_ColorPicker.BackgroundColor3 = Menu.ItemColor
    Selected_ColorPicker.BorderColor3 = Menu.BorderColor
    Selected_ColorPicker.BorderMode = Enum.BorderMode.Inset
    Selected_ColorPicker.Position = UDim2.new(0, 200, 0, 170)
    Selected_ColorPicker.Size = UDim2.new(0, 190, 0, 180)
    Selected_ColorPicker.Parent = nil
    CreateStroke(Selected_ColorPicker, Color3.new(), 1)
    AddEventListener(Selected_ColorPicker, function()
        Selected_ColorPicker.BackgroundColor3 = Menu.ItemColor
        Selected_ColorPicker.BorderColor3 = Menu.BorderColor
    end)

    HexBox.Name = "Hex"
    HexBox.BackgroundColor3 = Menu.ItemColor
    HexBox.BorderColor3 = Menu.BorderColor
    HexBox.BorderMode = Enum.BorderMode.Inset
    HexBox.Size = UDim2.new(1, -10, 0, 20)
    HexBox.Position = UDim2.fromOffset(5, 150)
    HexBox.Text = "#" .. string.upper(ColorPicker.Color:ToHex())
    HexBox.Font = Enum.Font.SourceSansSemibold
    HexBox.TextSize = 14
    HexBox.TextColor3 = Color3.new(1, 1, 1)
    HexBox.ClearTextOnFocus = false
    HexBox.ClipsDescendants = true
    HexBox.Parent = Selected_ColorPicker
    CreateStroke(HexBox, Color3.new(), 1)
    HexBox.FocusLost:Connect(function()
        pcall(function()
            local Color, Alpha = string.sub(HexBox.Text, 1, 7), string.sub(HexBox.Text, 8, #HexBox.Text)
            ColorPicker.Color = Color3.fromHex(Color)
            ColorPicker.Alpha = tonumber(Alpha, 16) / 255
            ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2] = ColorPicker.Color:ToHSV()
            ColorPicker:Update()
        end)
    end)
    AddEventListener(HexBox, function()
        HexBox.BackgroundColor3 = Menu.ItemColor
        HexBox.BorderColor3 = Menu.BorderColor
    end)

    Saturation.Name = "Saturation"
    Saturation.BackgroundColor3 = ColorPicker.Color
    Saturation.BorderColor3 = Menu.BorderColor
    Saturation.Position = UDim2.new(0, 4, 0, 4)
    Saturation.Size = UDim2.new(0, 150, 0, 140)
    Saturation.Image = "rbxassetid://8180999986"
    Saturation.ImageColor3 = Color3.new()
    Saturation.AutoButtonColor = false
    Saturation.Parent = Selected_ColorPicker
    CreateStroke(Saturation, Color3.new(), 1)
    AddEventListener(Saturation, function()
        Saturation.BorderColor3 = Menu.BorderColor
    end)
    
    Alpha.Name = "Alpha"
    Alpha.BorderColor3 = Menu.BorderColor
    Alpha.Position = UDim2.new(0, 175, 0, 4)
    Alpha.Size = UDim2.new(0, 10, 0, 140)
    Alpha.Image = "rbxassetid://9090739505"
    Alpha.ScaleType = Enum.ScaleType.Crop
    Alpha.AutoButtonColor = false
    Alpha.Parent = Selected_ColorPicker
    CreateStroke(Alpha, Color3.new(), 1)
    AddEventListener(Alpha, function()
        Alpha.BorderColor3 = Menu.BorderColor
    end)

    Hue.Name = "Hue"
    Hue.BackgroundColor3 = Color3.new(1, 1, 1)
    Hue.BorderColor3 = Menu.BorderColor
    Hue.Position = UDim2.new(0, 160, 0, 4)
    Hue.Size = UDim2.new(0, 10, 0, 140)
    Hue.Image = "rbxassetid://8180989234"
    Hue.ScaleType = Enum.ScaleType.Crop
    Hue.AutoButtonColor = false
    Hue.Parent = Selected_ColorPicker
    CreateStroke(Hue, Color3.new(), 1)
    AddEventListener(Hue, function()
        Hue.BorderColor3 = Menu.BorderColor
    end)

    SaturationCursor.Name = "Cursor"
    SaturationCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    SaturationCursor.BorderColor3 = Color3.new()
    SaturationCursor.Size = UDim2.fromOffset(5, 5)
    SaturationCursor.Parent = Saturation

    AlphaCursor.Name = "Cursor"
    AlphaCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    AlphaCursor.BorderColor3 = Color3.new()
    AlphaCursor.Size = UDim2.new(1, 0, 0, 2)
    AlphaCursor.Parent = Alpha

    HueCursor.Name = "Cursor"
    HueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    HueCursor.BorderColor3 = Color3.new()
    HueCursor.Size = UDim2.new(1, 0, 0, 2)
    HueCursor.Parent = Hue

    AlphaColorGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, ColorPicker.Color)}
    AlphaColorGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.20), NumberSequenceKeypoint.new(1, 0.2)}
    AlphaColorGradient.Offset = Vector2.new(0, -0.1)
    AlphaColorGradient.Rotation = -90
    AlphaColorGradient.Parent = Alpha

    local function UpdateSaturation(PercentageX: number, PercentageY: number)
        local PercentageX = typeof(PercentageX == "number") and math.clamp(PercentageX, 0, 1) or 0
        local PercentageY = typeof(PercentageY == "number") and math.clamp(PercentageY, 0, 1) or 0
        ColorPicker.Saturation[1] = PercentageX
        ColorPicker.Saturation[2] = 1 - PercentageY
        ColorPicker:Update()
    end

    local function UpdateAlpha(Percentage: number)
        local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
        ColorPicker.Alpha = Percentage
        ColorPicker:Update()
    end

    local function UpdateHue(Percentage: number)
        local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
        ColorPicker.Hue = Percentage
        ColorPicker:Update()
    end

    Saturation.InputBegan:Connect(function(Input: InputObject, Process: boolean)
        if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
            Dragging = {Gui = Saturation, True = true}
            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
            local Percentage = (InputPosition - Saturation.AbsolutePosition) / Saturation.AbsoluteSize
            UpdateSaturation(Percentage.X, Percentage.Y)
        end
    end)

    Alpha.InputBegan:Connect(function(Input: InputObject, Process: boolean)
        if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
            Dragging = {Gui = Alpha, True = true}
            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
            local Percentage = (InputPosition - Alpha.AbsolutePosition) / Alpha.AbsoluteSize
            UpdateAlpha(Percentage.Y)
        end
    end)

    Hue.InputBegan:Connect(function(Input: InputObject, Process: boolean)
        if (not Dragging.Gui and not Dragging.True) and (Input.UserInputType == Enum.UserInputType.MouseButton1) then
            Dragging = {Gui = Hue, True = true}
            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
            local Percentage = (InputPosition - Hue.AbsolutePosition) / Hue.AbsoluteSize
            UpdateHue(Percentage.Y)
        end
    end)

    UserInput.InputChanged:Connect(function(Input: InputObject, Process: boolean)
        if (Dragging.Gui ~= Saturation and Dragging.Gui ~= Alpha and Dragging.Gui ~= Hue) then return end
        if not (UserInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) then
            Dragging = {Gui = nil, True = false}
            return
        end

        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
        if (Input.UserInputType == Enum.UserInputType.MouseMovement) then
            if Dragging.Gui == Saturation then
                local Percentage = (InputPosition - Saturation.AbsolutePosition) / Saturation.AbsoluteSize
                UpdateSaturation(Percentage.X, Percentage.Y)
            end
            if Dragging.Gui == Alpha then
                local Percentage = (InputPosition - Alpha.AbsolutePosition) / Alpha.AbsoluteSize
                UpdateAlpha(Percentage.Y)
            end
            if Dragging.Gui == Hue then
                local Percentage = (InputPosition - Hue.AbsolutePosition) / Hue.AbsoluteSize
                UpdateHue(Percentage.Y)
            end
        end
    end)
    
    
    ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2] = ColorPicker.Color:ToHSV()
    ColorPicker:Update()
    Container:UpdateSize(math.floor(22 * UIScale))
    table.insert(Items, ColorPicker)
    return ColorPicker
end


function Menu.ComboBox(Tab_Name: string, Container_Name: string, Name: string, Value: string, Value_Items: table, Callback: any, ToolTip: string): ComboBox
    local Container = GetContainer(Tab_Name, Container_Name)
    local Label = CreateLabel(Container.self, "ComboBox", Name, UDim2.new(1, math.floor(-10 * UIScale), 0, math.floor(17 * UIScale)), UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight()))
    local Button = Instance.new("TextButton")
    local Symbol = Instance.new("TextLabel")
    local List = Instance.new("ScrollingFrame")
    local ListLayout = Instance.new("UIListLayout")

    local configKey = Tab_Name .. "_" .. Container_Name .. "_" .. Name .. "_combo"
    
    local ComboBox = {}
    ComboBox.Name = Name
    ComboBox.Class = "ComboBox"
    ComboBox.Tab = Tab_Name
    ComboBox.Container = Container_Name
    ComboBox.Index = #Items + 1
    ComboBox.Callback = typeof(Callback) == "function" and Callback or function() end
    ComboBox.Value = getConfigValue(configKey, typeof(Value) == "string" and Value or "")
    ComboBox.Items = typeof(Value_Items) == "table" and Value_Items or {}

    local function UpdateValue(Value: string, skipSave)
        ComboBox.Value = tostring(Value)
        Button.Text = ComboBox.Value or "[...]"
        if not skipSave then
            setConfigValue(configKey, ComboBox.Value)
        end
    end

    local ItemObjects = {}
    local function AddItem(Name: string)
        local Button = Instance.new("TextButton")
        Button.BackgroundColor3 = Menu.ItemColor
        Button.BorderColor3 = Color3.new()
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 15)
        Button.Font = Enum.Font.SourceSans
        Button.Text = tostring(Name)
        Button.TextColor3 = ComboBox.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
        Button.TextSize = 14
        Button.TextTruncate = Enum.TextTruncate.AtEnd
        Button.Parent = List
        Button.MouseButton1Click:Connect(function()
            for _, v in ipairs(List:GetChildren()) do
                if v:IsA("GuiButton") then
                    if v == Button then continue end
                    v.TextColor3 = Color3.new(1, 1, 1)
                end
            end
            Button.TextColor3 = Menu.Accent
            UpdateValue(Button.Text)
            UpdateSelected()
            ComboBox.Callback(ComboBox.Value)
        end)
        AddEventListener(Button, function()
            Button.BackgroundColor3 = Menu.ItemColor
            if ComboBox.Value == Button.Text then
                Button.TextColor3 = Menu.Accent
            else
                Button.TextColor3 = Color3.new(1, 1, 1)
            end
        end)
        
        if #ComboBox.Items >= 6 then
            List.CanvasSize += UDim2.fromOffset(0, 15)
        end
        table.insert(ItemObjects, Button)
    end


    function ComboBox:Update(Value: string, Items: any)
        UpdateValue(Value)
        if typeof(Items) == "table" then
            for _, Button in ipairs(ItemObjects) do
                Button:Destroy()
            end
            table.clear(ItemObjects)

            List.CanvasSize = UDim2.new()
            List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(#self.Items * 15, 15, 90))
            for _, Item in ipairs(self.Items) do
                AddItem(tostring(Item))
            end
        else
            for _, Button in ipairs(ItemObjects) do
                Button.TextColor3 = self.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
            end
        end
    end

    function ComboBox:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function ComboBox:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Label.Visible == Visible then return end
        
        Label.Visible = Visible
        Container:UpdateSize(Visible and 40 or -40, Label)
    end

    function ComboBox:GetValue(): table
        return self.Value
    end

    function ComboBox:SetValue(Value: string, Items: any)
        if typeof(Items) == "table" then
            self.Items = Items
        end
        self:Update(Value, self.Items)
    end


    Label.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, Label)
        end
    end)
    Label.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)

    Button.Name = "Button"
    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderColor3 = Color3.new()
    Button.Position = UDim2.new(0, 0, 0, 20)
    Button.Size = UDim2.new(1, -40, 0, 15)
    Button.Font = Enum.Font.SourceSans
    Button.Text = ComboBox.Value
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.TextTruncate = Enum.TextTruncate.AtEnd
    Button.Parent = Label
    Button.MouseButton1Click:Connect(function()
        UpdateSelected(List, Button, UDim2.fromOffset(0, 15))
        List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(#ComboBox.Items * 15, 15, 90))
    end)
    AddEventListener(Button, function()
        Button.BackgroundColor3 = Menu.ItemColor
    end)

    Symbol.Name = "Symbol"
    Symbol.Parent = Button
    Symbol.BackgroundColor3 = Color3.new(1, 1, 1)
    Symbol.BackgroundTransparency = 1
    Symbol.Position = UDim2.new(1, -10, 0, 0)
    Symbol.Size = UDim2.new(0, 5, 1, 0)
    Symbol.Font = Enum.Font.SourceSans
    Symbol.Text = "-"
    Symbol.TextColor3 = Color3.new(1, 1, 1)
    Symbol.TextSize = 14

    List.Visible = false
    List.BackgroundColor3 = Menu.ItemColor
    List.BorderColor3 = Menu.BorderColor
    List.BorderMode = Enum.BorderMode.Inset
    List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(#ComboBox.Items * 15, 15, 90))
    List.Position = UDim2.fromOffset(20, 30)
    List.CanvasSize = UDim2.new()
    List.ScrollBarThickness = 4
    List.ScrollBarImageColor3 = Menu.Accent
    List.Parent = Label
    CreateStroke(List, Color3.new(), 1)
    AddEventListener(List, function()
        List.BackgroundColor3 = Menu.ItemColor
        List.BorderColor3 = Menu.BorderColor
        List.ScrollBarImageColor3 = Menu.Accent
    end)

    ListLayout.Parent = List

    ComboBox:Update(ComboBox.Value, ComboBox.Items)
    if ComboBox.Value and ComboBox.Value ~= "" then ComboBox.Callback(ComboBox.Value) end
    Container:UpdateSize(math.floor(45 * UIScale))
    table.insert(Items, ComboBox)
    return ComboBox
end


function Menu.MultiSelect(Tab_Name: string, Container_Name: string, Name: string, Value_Items: table, Callback: any, ToolTip: string): MultiSelect
    local Container = GetContainer(Tab_Name, Container_Name)
    local Label = CreateLabel(Container.self, "MultiSelect", Name, UDim2.new(1, math.floor(-10 * UIScale), 0, math.floor(17 * UIScale)), UDim2.fromOffset(math.floor(20 * UIScale), Container:GetHeight()))
    local Button = Instance.new("TextButton")
    local Symbol = Instance.new("TextLabel")
    local List = Instance.new("ScrollingFrame")
    local ListLayout = Instance.new("UIListLayout")

    local configKey = Tab_Name .. "_" .. Container_Name .. "_" .. Name .. "_multi"
    
    local MultiSelect = {self = Label}
    MultiSelect.Name = Name
    MultiSelect.Class = "MultiSelect"
    MultiSelect.Tab = Tab_Name
    MultiSelect.Container = Container_Name
    MultiSelect.Index = #Items + 1
    MultiSelect.Callback = typeof(Callback) == "function" and Callback or function() end
    
    local savedItems = getConfigValue(configKey, nil)
    if savedItems then
        MultiSelect.Items = savedItems
    else
        MultiSelect.Items = typeof(Value_Items) == "table" and Value_Items or {}
    end
    MultiSelect.Value = {}


    local function GetSelectedItems(): table
        local Selected = {}
        for k, v in pairs(MultiSelect.Items) do
            if v == true then table.insert(Selected, k) end
        end
        return Selected
    end

    local function UpdateValue(skipSave)
        MultiSelect.Value = GetSelectedItems()
        Button.Text = #MultiSelect.Value > 0 and table.concat(MultiSelect.Value, ", ") or "[...]"
        if not skipSave then
            setConfigValue(configKey, MultiSelect.Items)
        end
    end

    local ItemObjects = {}
    local function AddItem(Name: string, Checked: boolean)
        local Button = Instance.new("TextButton")
        Button.BackgroundColor3 = Menu.ItemColor
        Button.BorderColor3 = Color3.new()
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 15)
        Button.Font = Enum.Font.SourceSans
        Button.Text = Name
        Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
        Button.TextSize = 14
        Button.Parent = List
        Button.TextTruncate = Enum.TextTruncate.AtEnd
        Button.MouseButton1Click:Connect(function()
            MultiSelect.Items[Name] = not MultiSelect.Items[Name]
            Button.TextColor3 = MultiSelect.Items[Name] and Menu.Accent or Color3.new(1, 1, 1)
            UpdateValue()
            MultiSelect.Callback(MultiSelect.Items) 
        end)
        AddEventListener(Button, function()
            Button.BackgroundColor3 = Menu.ItemColor
            Button.TextColor3 = table.find(GetSelectedItems(), Button.Text) and Menu.Accent or Color3.new(1, 1, 1)
        end)

        if GetDictionaryLength(MultiSelect.Items) >= 6 then
            List.CanvasSize += UDim2.fromOffset(0, 15)
        end
        table.insert(ItemObjects, Button)
    end


    function MultiSelect:Update(Value: any)
        if typeof(Value) == "table" then
            self.Items = Value
            UpdateValue()

            for _, Button in ipairs(ItemObjects) do
                Button:Destroy()
            end
            table.clear(ItemObjects)

            List.CanvasSize = UDim2.new()
            List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(GetDictionaryLength(self.Items) * 15, 15, 90))
            for Name, Checked in pairs(self.Items) do
                AddItem(tostring(Name), Checked)
            end
        else
            local Selected = GetSelectedItems()
            for _, Button in ipairs(ItemObjects) do
                local Checked = table.find(Selected, Button.Text)
                Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
            end
        end
    end

    function MultiSelect:SetLabel(Name: string)
        Label.Text = tostring(Name)
    end

    function MultiSelect:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if Label.Visible == Visible then return end
        
        Label.Visible = Visible
        Container:UpdateSize(Visible and 40 or -40, Label)
    end

    function MultiSelect:GetValue(): table
        return self.Items
    end

    function MultiSelect:SetValue(Value: any)
        self:Update(Value)
    end


    Label.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, Label)
        end
    end)
    Label.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)

    Button.BackgroundColor3 = Menu.ItemColor
    Button.BorderColor3 = Color3.new()
    Button.Position = UDim2.new(0, 0, 0, 20)
    Button.Size = UDim2.new(1, -40, 0, 15)
    Button.Font = Enum.Font.SourceSans
    Button.Text = "[...]"
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 14
    Button.TextTruncate = Enum.TextTruncate.AtEnd
    Button.Parent = Label
    Button.MouseButton1Click:Connect(function()
        UpdateSelected(List, Button, UDim2.fromOffset(0, 15))
        List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(GetDictionaryLength(MultiSelect.Items) * 15, 15, 90))
    end)
    AddEventListener(Button, function()
        Button.BackgroundColor3 = Menu.ItemColor
    end)

    Symbol.Name = "Symbol"
    Symbol.BackgroundTransparency = 1
    Symbol.Position = UDim2.new(1, -10, 0, 0)
    Symbol.Size = UDim2.new(0, 5, 1, 0)
    Symbol.Font = Enum.Font.SourceSans
    Symbol.Text = "-"
    Symbol.TextColor3 = Color3.new(1, 1, 1)
    Symbol.TextSize = 14
    Symbol.Parent = Button

    List.Visible = false
    List.BackgroundColor3 = Menu.ItemColor
    List.BorderColor3 = Menu.BorderColor
    List.BorderMode = Enum.BorderMode.Inset
    List.Size = UDim2.fromOffset(Button.AbsoluteSize.X, math.clamp(GetDictionaryLength(MultiSelect.Items) * 15, 15, 90))
    List.Position = UDim2.fromOffset(20, 30)
    List.CanvasSize = UDim2.new()
    List.ScrollBarThickness = 4
    List.ScrollBarImageColor3 = Menu.Accent
    List.Parent = Label
    CreateStroke(List, Color3.new(), 1)
    AddEventListener(List, function()
        List.BackgroundColor3 = Menu.ItemColor
        List.BorderColor3 = Menu.BorderColor
        List.ScrollBarImageColor3 = Menu.Accent
    end)

    ListLayout.Parent = List

    MultiSelect:Update(MultiSelect.Items)
    if #MultiSelect.Value > 0 then MultiSelect.Callback(MultiSelect.Items) end
    Container:UpdateSize(math.floor(45 * UIScale))
    table.insert(Items, MultiSelect)
    return MultiSelect
end


function Menu.ListBox(Tab_Name: string, Container_Name: string, Name: string, Multi: boolean, Value_Items: table, Callback: any, ToolTip: string): ListBox
    local Container = GetContainer(Tab_Name, Container_Name)
    local List = Instance.new("ScrollingFrame")
    local ListLayout = Instance.new("UIListLayout")

    local ListBox = {self = Label}
    ListBox.Name = Name
    ListBox.Class = "ListBox"
    ListBox.Tab = Tab_Name
    ListBox.Container = Container_Name
    ListBox.Index = #Items + 1
    ListBox.Method = Multi and "Multi" or "Default"
    ListBox.Items = typeof(Value_Items) == "table" and Value_Items or {}
    ListBox.Value = {}
    ListBox.Callback = typeof(Callback) == "function" and Callback or function() end

    local ItemObjects = {}

    local function GetSelectedItems(): table
        local Selected = {}
        for k, v in pairs(ListBox.Items) do
            if v == true then table.insert(Selected, k) end
        end
        return Selected
    end

    local function UpdateValue(Value: any)
        if ListBox.Method == "Default" then
            ListBox.Value = tostring(Value)
        else
            ListBox.Value = GetSelectedItems()
        end
    end

    local function AddItem(Name: string, Checked: boolean)
        local Button = Instance.new("TextButton")
        Button.BackgroundColor3 = Menu.ItemColor
        Button.BorderColor3 = Color3.new()
        Button.BorderSizePixel = 0
        Button.Size = UDim2.new(1, 0, 0, 15)
        Button.Font = Enum.Font.SourceSans
        Button.Text = Name
        Button.TextSize = 14
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.TextTruncate = Enum.TextTruncate.AtEnd
        Button.Parent = List
        if ListBox.Method == "Default" then
            Button.TextColor3 = ListBox.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
            Button.MouseButton1Click:Connect(function()
                for _, v in ipairs(List:GetChildren()) do
                    if v:IsA("GuiButton") then
                        if v == Button then continue end
                        v.TextColor3 = Color3.new(1, 1, 1)
                    end
                end
                Button.TextColor3 = Menu.Accent
                UpdateValue(Button.Text)
                UpdateSelected()
                ListBox.Callback(ListBox.Value)
            end)
            AddEventListener(Button, function()
                Button.BackgroundColor3 = Menu.ItemColor
                if ListBox.Value == Button.Text then
                    Button.TextColor3 = Menu.Accent
                else
                    Button.TextColor3 = Color3.new(1, 1, 1)
                end
            end)
            
            if #ListBox.Items >= 6 then
                List.CanvasSize += UDim2.fromOffset(0, 15)
            end
        else
            Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
            Button.MouseButton1Click:Connect(function()
                ListBox.Items[Name] = not ListBox.Items[Name]
                Button.TextColor3 = ListBox.Items[Name] and Menu.Accent or Color3.new(1, 1, 1)
                UpdateValue()
                UpdateSelected()
                ListBox.Callback(ListBox.Value)
            end)
            AddEventListener(Button, function()
                Button.BackgroundColor3 = Menu.ItemColor
                if table.find(ListBox.Value, Name) then
                    Button.TextColor3 = Menu.Accent
                else
                    Button.TextColor3 = Color3.new(1, 1, 1)
                end
            end)
            
            if GetDictionaryLength(ListBox.Items) >= 10 then
                List.CanvasSize += UDim2.fromOffset(0, 15)
            end
        end
        table.insert(ItemObjects, Button)
    end


    function ListBox:Update(Value: string, Items: any)
        if self.Method == "Default" then
            UpdateValue(Value)
        end
        if typeof(Items) == "table" then
            if self.Method == "Multi" then
                self.Items = Value
                UpdateValue()
            end
            for _, Button in ipairs(ItemObjects) do
                Button:Destroy()
            end
            table.clear(ItemObjects)

            List.CanvasSize = UDim2.new()
            List.Size = UDim2.new(1, -50, 0, 150)
            if self.Method == "Default" then
                for _, Item in ipairs(self.Items) do
                    AddItem(tostring(Item))
                end
            else
                for Name, Checked in pairs(self.Items) do
                    AddItem(tostring(Name), Checked)
                end
            end
        else
            if self.Method == "Default" then
                for _, Button in ipairs(ItemObjects) do
                    Button.TextColor3 = self.Value == Button.Text and Menu.Accent or Color3.new(1, 1, 1)
                end
            else
                local Selected = GetSelectedItems()
                for _, Button in ipairs(ItemObjects) do
                    local Checked = table.find(Selected, Button.Text)
                    Button.TextColor3 = Checked and Menu.Accent or Color3.new(1, 1, 1)
                end
            end
        end
    end

    function ListBox:SetVisible(Visible: boolean)
        if typeof(Visible) ~= "boolean" then return end
        if List.Visible == Visible then return end
        
        List.Visible = Visible
        Container:UpdateSize(Visible and 155 or -155, List)
    end

    function ListBox:SetValue(Value: string, Items: any)
        if self.Method == "Default" then
            if typeof(Items) == "table" then
                self.Items = Items
            end
            self:Update(Value, self.Items)
        else
            self:Update(Value)
        end
    end

    function ListBox:GetValue(): table
        return self.Value
    end


    List.Name = "List"
    List.Active = true
    List.BackgroundColor3 = Menu.ItemColor
    List.BorderColor3 = Color3.new()
    List.Position = UDim2.fromOffset(20, Container:GetHeight())
    List.Size = UDim2.new(1, -50, 0, 150)
    List.CanvasSize = UDim2.new()
    List.ScrollBarThickness = 4
    List.ScrollBarImageColor3 = Menu.Accent
    List.Parent = Container.self
    List.MouseEnter:Connect(function()
        if ToolTip then
            Menu:SetToolTip(true, ToolTip, List)
        end
    end)
    List.MouseLeave:Connect(function()
        if ToolTip then
            Menu:SetToolTip(false)
        end
    end)
    CreateStroke(List, Color3.new(), 1)
    AddEventListener(List, function()
        List.BackgroundColor3 = Menu.ItemColor
        List.ScrollBarImageColor3 = Menu.Accent
    end)

    ListLayout.Parent = List

    if ListBox.Method == "Default" then
        ListBox:Update(ListBox.Value, ListBox.Items)
    else
        ListBox:Update(ListBox.Items)
    end
    Container:UpdateSize(math.floor(160 * UIScale))
    table.insert(Items, ListBox)
    return ListBox
end


function Menu.Notify(Content: string, Delay: number)
    
    if isLoadingConfig then return end
    
    assert(typeof(Content) == "string", "missing argument #1, (string expected got " .. typeof(Content) .. ")")
    local Delay = typeof(Delay) == "number" and Delay or 3

    local Text = Instance.new("TextLabel")
    local Notification = {
        self = Text,
        Class = "Notification"
    }

    Text.Name = "Notification"
    Text.BackgroundTransparency = 1
    Text.Position = UDim2.new(0.5, math.floor(-100 * UIScale), 1, math.floor(-150 * UIScale) - (GetDictionaryLength(Notifications) * math.floor(17 * UIScale)))
    Text.Size = UDim2.new(0, 0, 0, math.floor(17 * UIScale))
    Text.Text = Content
    Text.Font = Enum.Font.SourceSans
    Text.TextSize = math.floor(17 * UIScale)
    Text.TextColor3 = Color3.new(1, 1, 1)
    Text.TextStrokeTransparency = 0.2
    Text.TextTransparency = 1
    Text.RichText = true
    Text.ZIndex = 4
    Text.Parent = Notifications_Frame

    local function CustomTweenOffset(Offset: number)
        spawn(function()
            local Steps = 33
            for i = 1, Steps do
                Text.Position += UDim2.fromOffset(Offset / Steps, 0)
                RunService.RenderStepped:Wait()
            end
        end)
    end

    function Notification:Update()
        
    end

    function Notification:Destroy()
        Notifications[self] = nil
        Text:Destroy()

        local Index = 1
        for _, v in pairs(Notifications) do
            local self = v.self
            self.Position += UDim2.fromOffset(0, 15)
            Index += 1
        end
    end

    Notifications[Notification] = Notification
    
    local TweenIn  = TweenService:Create(Text, TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {TextTransparency = 0})
    local TweenOut = TweenService:Create(Text, TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {TextTransparency = 1})
    
    TweenIn:Play()
    CustomTweenOffset(100)
    
    TweenIn.Completed:Connect(function()
        delay(Delay, function()
            TweenOut:Play()
            CustomTweenOffset(100)

            TweenOut.Completed:Connect(function()
                Notification:Destroy()
            end)
        end)
    end)
end


function Menu.Prompt(Message: string, Callback: any, ...)
    do
        local Prompt = Menu.Screen:FindFirstChild("Prompt")
        if Prompt then Prompt:Destroy() end
    end

    local Prompt = Instance.new("Frame")
    local Title = Instance.new("TextLabel")

    local Height = -20
    local function CreateButton(Text, Callback, ...)
        local Arguments = {...}

        local Callback = typeof(Callback) == "function" and Callback or function() end
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.BorderSizePixel = 0
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.Size = UDim2.fromOffset(100, 20)
        Button.Position = UDim2.new(0.5, -50, 0.5, Height)
        Button.Text = Text
        Button.TextStrokeTransparency = 0.8
        Button.TextSize = 14
        Button.Font = Enum.Font.SourceSans
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.Parent = Prompt
        Button.MouseButton1Click:Connect(function() Prompt:Destroy() Callback(unpack(Arguments)) end)
        CreateStroke(Button, Color3.new(), 1)
        Height += 25
    end

    CreateButton("OK", Callback, ...)
    CreateButton("Cancel", function() Prompt:Destroy() end)


    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 15)
    Title.Position = UDim2.new(0, 0, 0.5, -100)
    Title.Text = Message
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSans
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Parent = Prompt

    Prompt.Name = "Prompt"
    Prompt.BackgroundTransparency = 0.5
    Prompt.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Prompt.BorderSizePixel = 0
    Prompt.Size = UDim2.new(1, 0, 1, 36)
    Prompt.Position = UDim2.fromOffset(0, -36)
    Prompt.Parent = Menu.Screen
end


function Menu.Spectators(): Spectators
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local List = Instance.new("Frame")
    local ListLayout = Instance.new("UIListLayout")
    local Spectators = {self = Frame}
    Spectators.List = {}
    Menu.Spectators = Spectators


    Frame.Name = "Spectators"
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderMode = Enum.BorderMode.Inset
    Frame.Size = UDim2.fromOffset(250, 50)
    Frame.Position = UDim2.fromOffset(Menu.ScreenSize.X - Frame.Size.X.Offset, -36)
    Frame.Visible = false
    Frame.Parent = Menu.Screen
    CreateStroke(Frame, Color3.new(), 1)
    CreateLine(Frame, UDim2.new(0, 240, 0, 1), UDim2.new(0, 5, 0, 20))
    SetDraggable(Frame)
    
    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.Size = UDim2.new(0, 240, 0, 15)
    Title.Font = Enum.Font.SourceSansSemibold
    Title.Text = "Spectators"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 14
    Title.Parent = Frame

    List.Name = "List"
    List.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    List.BorderColor3 = Color3.fromRGB(40, 40, 40)
    List.BorderMode = Enum.BorderMode.Inset
    List.Position = UDim2.new(0, 4, 0, 30)
    List.Size = UDim2.new(0, 240, 0, 10)
    List.Parent = Frame

    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = List


    local function UpdateFrameSize()
        local Height = ListLayout.AbsoluteContentSize.Y + 5
        Spectators.self:TweenSize(UDim2.fromOffset(250, math.clamp(Height + 50, 50, 5000)), nil, nil, 0.3, true)
        Spectators.self.List:TweenSize(UDim2.fromOffset(240, math.clamp(Height, 10, 5000)), nil, nil, 0.3, true)
    end


    function Spectators.Add(Name: string, Icon: string)
        Spectators.Remove(Name)
        local Object = Instance.new("Frame")
        local NameLabel = Instance.new("TextLabel")
        local IconImage = Instance.new("ImageLabel")
        local Spectator = {self = Object}

        Object.Name = "Object"
        Object.BackgroundTransparency = 1
        Object.Position = UDim2.new(0, 5, 0, 30)
        Object.Size = UDim2.new(0, 240, 0, 15)
        Object.Parent = List

        NameLabel.Name = "Name"
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0, 20, 0, 0)
        NameLabel.Size = UDim2.new(0, 230, 1, 0)
        NameLabel.Font = Enum.Font.SourceSans
        NameLabel.Text = tostring(Name)
        NameLabel.TextColor3 = Color3.new(1, 1, 1)
        NameLabel.TextSize = 14
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Object

        IconImage.Name = "Icon"
        IconImage.BackgroundTransparency = 1
        IconImage.Image = Icon or ""
        IconImage.Size = UDim2.new(0, 15, 0, 15)
        IconImage.Position = UDim2.new(0, 2, 0, 0)
        IconImage.Parent = Object

        Spectators.List[Name] = Spectator
        UpdateFrameSize()
    end


    function Spectators.Remove(Name: string)
        if Spectators.List[Name] then
            Spectators.List[Name].self:Destroy()
            Spectators.List[Name] = nil
        end
        UpdateFrameSize()
    end


    function Spectators:SetVisible(Visible: boolean)
        self.self.Visible = Visible
    end


    return Spectators
end


function Menu.Keybinds(): Keybinds
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local List = Instance.new("Frame")
    local ListLayout = Instance.new("UIListLayout")
    local Keybinds = {self = Frame}
    Keybinds.List = {}
    Menu.Keybinds = Keybinds


    Frame.Name = "Keybinds"
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderMode = Enum.BorderMode.Inset
    Frame.Size = UDim2.fromOffset(250, 45)
    Frame.Position = UDim2.fromOffset(Menu.ScreenSize.X - Frame.Size.X.Offset - 10, 40)
    Frame.Visible = false
    Frame.Parent = Menu.Screen
    CreateStroke(Frame, Color3.new(), 1)
    CreateLine(Frame, UDim2.new(0, 240, 0, 1), UDim2.new(0, 5, 0, 20))
    SetDraggable(Frame)

    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.Size = UDim2.new(0, 240, 0, 15)
    Title.Font = Enum.Font.SourceSansSemibold
    Title.Text = "Keybinds"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 14
    Title.Parent = Frame

    List.Name = "List"
    List.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    List.BorderColor3 = Color3.fromRGB(40, 40, 40)
    List.BorderMode = Enum.BorderMode.Inset
    List.Position = UDim2.new(0, 4, 0, 30)
    List.Size = UDim2.new(0, 240, 0, 10)
    List.Parent = Frame

    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.Parent = List

    local function UpdateFrameSize()
        local contentHeight = 0
        for _, child in pairs(List:GetChildren()) do
            if child:IsA("Frame") then
                contentHeight = contentHeight + child.Size.Y.Offset + 3
            end
        end
        if contentHeight > 0 then contentHeight = contentHeight + 2 end
        local newListHeight = math.max(10, contentHeight)
        local newFrameHeight = newListHeight + 40
        Frame.Size = UDim2.fromOffset(250, newFrameHeight)
        List.Size = UDim2.fromOffset(240, newListHeight)
    end

    function Keybinds.Add(Name: string, State: string): Keybind
        Keybinds.Remove(Name)
        local Object = Instance.new("Frame")
        local NameLabel = Instance.new("TextLabel")
        local StateLabel = Instance.new("TextLabel")
        local Keybind = {self = Object}

        Object.Name = "Object"
        Object.BackgroundTransparency = 1
        Object.Position = UDim2.new(0, 5, 0, 30)
        Object.Size = UDim2.new(0, 230, 0, 15)
        Object.Parent = List

        NameLabel.Name = "Indicator"
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0, 5, 0, 0)
        NameLabel.Size = UDim2.new(0, 180, 1, 0)
        NameLabel.Font = Enum.Font.SourceSans
        NameLabel.Text = Name
        NameLabel.TextColor3 = Color3.new(1, 1, 1)
        NameLabel.TextSize = 14
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Object

        StateLabel.Name = "State"
        StateLabel.BackgroundTransparency = 1
        StateLabel.Position = UDim2.new(0, 190, 0, 0)
        StateLabel.Size = UDim2.new(0, 40, 1, 0)
        StateLabel.Font = Enum.Font.SourceSans
        StateLabel.Text = "[" .. tostring(State) .. "]"
        StateLabel.TextColor3 = Color3.new(1, 1, 1)
        StateLabel.TextSize = 14
        StateLabel.TextXAlignment = Enum.TextXAlignment.Right
        StateLabel.Parent = Object

        
        function Keybind:Update(State: string)
            StateLabel.Text = "[" .. tostring(State) .. "]"
        end

        function Keybind:SetVisible(Visible: boolean)
            if typeof(Visible) ~= "boolean" then return end
            if Object.Visible == Visible then return end
        
            Object.Visible = Visible
            UpdateFrameSize()
        end

        
        Keybinds.List[Name] = Keybind
        UpdateFrameSize()

        return Keybind
    end

    function Keybinds.Remove(Name: string)
        if Keybinds.List[Name] then
            Keybinds.List[Name].self:Destroy()
            Keybinds.List[Name] = nil
        end
        UpdateFrameSize()
    end

    function Keybinds:SetVisible(Visible: boolean)
        self.self.Visible = Visible
    end

    return Keybinds
end


function Menu.Indicators(): Indicators
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local List = Instance.new("Frame")
    local ListLayout = Instance.new("UIListLayout")

    local Indicators = {self = Frame}
    Indicators.List = {}
    Menu.Indicators = Indicators

    Frame.Name = "Indicators"
    Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderMode = Enum.BorderMode.Inset
    Frame.Size = UDim2.fromOffset(250, 45)
    Frame.Position = UDim2.fromOffset(Menu.ScreenSize.X - Frame.Size.X.Offset, -36)
    Frame.Visible = false
    Frame.Parent = Menu.Screen
    CreateStroke(Frame, Color3.new(), 1)
    CreateLine(Frame, UDim2.new(0, 240, 0, 1), UDim2.new(0, 5, 0, 20))
    SetDraggable(Frame)

    Title.Name = "Title"
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.Size = UDim2.new(0, 240, 0, 15)
    Title.Font = Enum.Font.SourceSansSemibold
    Title.Text = "Indicators"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 14
    Title.Parent = Frame

    List.Name = "List"
    List.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    List.BorderColor3 = Color3.fromRGB(40, 40, 40)
    List.BorderMode = Enum.BorderMode.Inset
    List.Position = UDim2.new(0, 4, 0, 30)
    List.Size = UDim2.new(0, 240, 0, 10)
    List.Parent = Frame

    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.Parent = List

    local function UpdateFrameSize()
        local Height = ListLayout.AbsoluteContentSize.Y + 5
        Indicators.self:TweenSize(UDim2.fromOffset(250, math.clamp(Height + 45, 45, 5000)), nil, nil, 0.3, true)
        Indicators.self.List:TweenSize(UDim2.fromOffset(240, math.clamp(Height, 10, 5000)), nil, nil, 0.3, true)
    end

    function Indicators.Add(Name: string, Type: string, Value: string, ...): Indicator
        Indicators.Remove(Name)
        local Object = Instance.new("Frame")
        local NameLabel = Instance.new("TextLabel")
        local StateLabel = Instance.new("TextLabel")

        local Indicator = {self = Object}
        Indicator.Type = Type
        Indicator.Value = Value

        Object.Name = "Object"
        Object.BackgroundTransparency = 1
        Object.Size = UDim2.new(0, 230, 0, 30)
        Object.Parent = Indicators.self.List
        
        NameLabel.Name = "Indicator"
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0, 5, 0, 0)
        NameLabel.Size = UDim2.new(0, 130, 0, 15)
        NameLabel.Font = Enum.Font.SourceSans
        NameLabel.Text = Name
        NameLabel.TextColor3 = Color3.new(1, 1, 1)
        NameLabel.TextSize = 14
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = Indicator.self
    
        StateLabel.Name = "State"
        StateLabel.BackgroundTransparency = 1
        StateLabel.Position = UDim2.new(0, 180, 0, 0)
        StateLabel.Size = UDim2.new(0, 40, 0, 15)
        StateLabel.Font = Enum.Font.SourceSans
        StateLabel.Text = "[" .. tostring(Value) .. "]"
        StateLabel.TextColor3 = Color3.new(1, 1, 1)
        StateLabel.TextSize = 14
        StateLabel.TextXAlignment = Enum.TextXAlignment.Right
        StateLabel.Parent = Indicator.self


        if Type == "Bar" then
            local ObjectBase = Instance.new("Frame")
            local ValueLabel = Instance.new("TextLabel")

            ObjectBase.Name = "Bar"
            ObjectBase.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            ObjectBase.BorderColor3 = Color3.new()
            ObjectBase.Position = UDim2.new(0, 0, 0, 20)
            ObjectBase.Size = UDim2.new(0, 220, 0, 5)
            ObjectBase.Parent = Indicator.self
    
            ValueLabel.Name = "Value"
            ValueLabel.BorderSizePixel = 0
            ValueLabel.BackgroundColor3 = Menu.Accent
            ValueLabel.Text = ""
            ValueLabel.Parent = ObjectBase
            AddEventListener(ValueLabel, function()
                ValueLabel.BackgroundColor3 = Menu.Accent
            end)
        else
            Object.Size = UDim2.new(0, 230, 0, 15)
        end


        function Indicator:Update(Value: string, ...)
            if Indicators.List[Name] then
                if Type == "Text" then
                    self.Value = Value
                    Object.State.Text = Value
                elseif Type == "Bar" then
                    local Min, Max = select(1, ...)
                    self.Min = typeof(Min) == "number" and Min or self.Min
                    self.Max = typeof(Max) == "number" and Max or self.Max

                    local Scale = (self.Value - self.Min) / (self.Max - self.Min)
                    Object.State.Text = "[" .. tostring(self.Value) .. "]"
                    Object.Bar.Value.Size = UDim2.new(math.clamp(Scale, 0, 1), 0, 0, 5)
                end
                self.Value = Value
            end
        end


        function Indicator:SetVisible(Visible: boolean)
            if typeof(Visible) ~= "boolean" then return end
            if Object.Visible == Visible then return end
            
            Object.Visible = Visible
            UpdateFrameSize()
        end

        
        Indicator:Update(Indicator.Value, ...)
        Indicators.List[Name] = Indicator
        UpdateFrameSize()
        return Indicator
    end


    function Indicators.Remove(Name: string)
        if Indicators.List[Name] then
            Indicators.List[Name].self:Destroy()
            Indicators.List[Name] = nil
        end
        UpdateFrameSize()
    end


    function Indicators:SetVisible(Visible: boolean)
        self.self.Visible = Visible
    end


    return Indicators
end


function Menu.Watermark(): Watermark
    local Watermark = {}
    Watermark.Frame = Instance.new("Frame")
    Watermark.Title = Instance.new("TextLabel")
    Menu.Watermark = Watermark

    Watermark.Frame.Name = "Watermark"
    Watermark.Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Watermark.Frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    Watermark.Frame.BorderMode = Enum.BorderMode.Inset
    Watermark.Frame.Size = UDim2.fromOffset(250, 20)
    Watermark.Frame.Position = UDim2.fromOffset(Menu.ScreenSize.X - Watermark.Frame.Size.X.Offset - 10, 10)
    Watermark.Frame.Visible = false
    Watermark.Frame.Parent = Menu.Screen
    CreateStroke(Watermark.Frame, Color3.new(), 1)
    CreateLine(Watermark.Frame, UDim2.new(0, 245, 0, 1), UDim2.new(0, 2, 0, 15))
    SetDraggable(Watermark.Frame)

    Watermark.Title.Name = "Title"
    Watermark.Title.BackgroundTransparency = 1
    Watermark.Title.Position = UDim2.new(0, 5, 0, -1)
    Watermark.Title.Size = UDim2.new(0, 240, 0, 15)
    Watermark.Title.Font = Enum.Font.SourceSansSemibold
    Watermark.Title.Text = ""
    Watermark.Title.TextColor3 = Color3.new(1, 1, 1)
    Watermark.Title.TextSize = 14
    Watermark.Title.RichText = true
    Watermark.Title.Parent = Watermark.Frame

    function Watermark:Update(Text: string)
        self.Title.Text = tostring(Text)
    end

    function Watermark:SetVisible(Visible: boolean)
        self.Frame.Visible = Visible
    end

    return Watermark
end


function Menu:Init()
    
    loadConfig("default")
    
    
    task.delay(0.5, function()
        Menu.Notify("<font color='##A6BAFF'>[ DYHUB ]</font> — Loaded Successfully | Config Auto-Save Enabled", 5)
    end)
    
    UserInput.InputBegan:Connect(function(Input: InputObject, Process: boolean) end)
    UserInput.InputEnded:Connect(function(Input: InputObject)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
            Dragging = {Gui = nil, True = false}
        end
    end)
    RunService.RenderStepped:Connect(function(Step: number)
        local Menu_Frame = Menu.Screen.Menu
        Menu_Frame.Position = UDim2.fromOffset(
            math.clamp(Menu_Frame.AbsolutePosition.X,   0, math.clamp(Menu.ScreenSize.X - Menu_Frame.AbsoluteSize.X, 0, Menu.ScreenSize.X    )),
            math.clamp(Menu_Frame.AbsolutePosition.Y, -36, math.clamp(Menu.ScreenSize.Y - Menu_Frame.AbsoluteSize.Y, 0, Menu.ScreenSize.Y - 36))
        )
        local Selected_Frame = Selected.Frame
        local Selected_Item = Selected.Item
        if (Selected_Frame and Selected_Item) then
            local Offset = Selected.Offset or UDim2.fromOffset()
            
            local itemPos = Selected_Item.AbsolutePosition
            local itemSize = Selected_Item.AbsoluteSize
            
            local Position = UDim2.fromOffset(itemPos.X, itemPos.Y + itemSize.Y)
            Selected_Frame.Position = Position
        end
    
        if Scaling.True then
            MenuScaler_Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            local Origin = Scaling.Origin
            local Size = Scaling.Size
    
            if Origin and Size then
                local Location = UserInput:GetMouseLocation()
                local NewSize = Location + (Size - Origin)
    
                Menu:SetSize(Vector2.new(
                    math.clamp(NewSize.X, Menu.MinSize.X, Menu.MaxSize.X),
                    math.clamp(NewSize.Y, Menu.MinSize.Y, Menu.MaxSize.Y)
                ))
            end
        else
            MenuScaler_Button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        end
    
        Menu.Hue += math.clamp(Step / 100, 0, 1)
        if Menu.Hue >= 1 then Menu.Hue = 0 end
    
        if ToolTip.Enabled == true then
            ToolTip_Label.Text = ToolTip.Content
            ToolTip_Label.Position = UDim2.fromOffset(ToolTip.Item.AbsolutePosition.X, ToolTip.Item.AbsolutePosition.Y + 25)
        end
    end)
    Menu.Screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        Menu.ScreenSize = Menu.Screen.AbsoluteSize
    end)
end


Menu.Config = ConfigSystem
Menu.UIScale = UIScale




local DYHUBLIB = {}

function DYHUBLIB:CreateWindow(options)
    options = options or {}
    local name = options.Name or "DYHUB"
    local loadingTitle = options.LoadingTitle or "Loading..."
    local loadingSubtitle = options.LoadingSubtitle or ""
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    
    
    if options.ConfigurationSaving then
        if options.ConfigurationSaving.FolderName then
            configFolderName = options.ConfigurationSaving.FolderName
        end
        if options.ConfigurationSaving.FileName then
            currentConfigName = options.ConfigurationSaving.FileName
        end
    end
    
    Menu:Init()
    Menu:SetTitle(name)
    Menu:SetVisible(true)
    
    if options.Icon then
        Menu:SetIcon(options.Icon)
    end
    
    local Window = {}
    Window._tabs = {}
    
    function Window:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon
        
        local tab = Menu.Tab(tabName)
        
        local Tab = {}
        Tab._name = tabName
        Tab._containers = {}
        Tab._currentContainer = nil
        
        function Tab:CreateSection(sectionName)
            sectionName = sectionName or "Section"
            local container = Menu.Container(tabName, sectionName, "Middle")
            Tab._currentContainer = sectionName
            table.insert(Tab._containers, sectionName)
            return container
        end
        
        function Tab:CreateToggle(toggleOptions)
            toggleOptions = toggleOptions or {}
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local name = toggleOptions.Name or "Toggle"
            local currentValue = toggleOptions.CurrentValue or false
            local callback = toggleOptions.Callback or function() end
            local tooltip = toggleOptions.ToolTip
            
            local index = Menu.CheckBox(tabName, containerName, name, currentValue, callback, tooltip)
            
            local Toggle = {}
            Toggle._index = index
            
            function Toggle:Set(value)
                local item = Menu:GetItem(index)
                if item then
                    item:SetValue(value)
                    callback(value)
                end
            end
            
            function Toggle:Get()
                local item = Menu:GetItem(index)
                return item and item:GetValue() or false
            end
            
            return Toggle
        end
        
        function Tab:CreateSlider(sliderOptions)
            sliderOptions = sliderOptions or {}
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local name = sliderOptions.Name or "Slider"
            local min = sliderOptions.Range and sliderOptions.Range[1] or 0
            local max = sliderOptions.Range and sliderOptions.Range[2] or 100
            local currentValue = sliderOptions.CurrentValue or min
            local increment = sliderOptions.Increment or 1
            local suffix = sliderOptions.Suffix or ""
            local callback = sliderOptions.Callback or function() end
            local tooltip = sliderOptions.ToolTip
            
            local scale = 0
            if increment < 1 then
                scale = #tostring(increment):match("%.(%d+)") or 0
            end
            
            local index = Menu.Slider(tabName, containerName, name, min, max, currentValue, suffix, scale, callback, tooltip)
            
            local Slider = {}
            Slider._index = index
            
            function Slider:Set(value)
                local item = Menu:GetItem(index)
                if item then
                    item:SetValue(value)
                    callback(value)
                end
            end
            
            function Slider:Get()
                local item = Menu:GetItem(index)
                return item and item:GetValue() or 0
            end
            
            return Slider
        end
        
        function Tab:CreateDropdown(dropdownOptions)
            dropdownOptions = dropdownOptions or {}
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local name = dropdownOptions.Name or "Dropdown"
            local items = dropdownOptions.Options or {}
            local currentValue = dropdownOptions.CurrentOption or (items[1] or "")
            local callback = dropdownOptions.Callback or function() end
            local tooltip = dropdownOptions.ToolTip
            
            local index = Menu.ComboBox(tabName, containerName, name, currentValue, items, callback, tooltip)
            
            local Dropdown = {}
            Dropdown._index = index
            
            function Dropdown:Set(value)
                local item = Menu:GetItem(index)
                if item then
                    item:SetValue(value)
                    callback(value)
                end
            end
            
            function Dropdown:Get()
                local item = Menu:GetItem(index)
                return item and item:GetValue() or ""
            end
            
            function Dropdown:Refresh(newOptions, keepCurrent)
                local item = Menu:GetItem(index)
                if item then
                    local current = keepCurrent and item:GetValue() or newOptions[1]
                    item:SetValue(current, newOptions)
                end
            end
            
            return Dropdown
        end
        
        function Tab:CreateButton(buttonOptions)
            buttonOptions = buttonOptions or {}
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local name = buttonOptions.Name or "Button"
            local callback = buttonOptions.Callback or function() end
            local tooltip = buttonOptions.ToolTip
            
            local index = Menu.Button(tabName, containerName, name, callback, tooltip)
            
            return {_index = index}
        end
        
        function Tab:CreateInput(inputOptions)
            inputOptions = inputOptions or {}
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local name = inputOptions.Name or "Input"
            local placeholder = inputOptions.PlaceholderText or ""
            local currentValue = inputOptions.CurrentValue or ""
            local callback = inputOptions.Callback or function() end
            local tooltip = inputOptions.ToolTip
            
            local index = Menu.TextBox(tabName, containerName, name, currentValue, callback, tooltip)
            
            local Input = {}
            Input._index = index
            
            function Input:Set(value)
                local item = Menu:GetItem(index)
                if item then
                    item:SetValue(value)
                end
            end
            
            function Input:Get()
                local item = Menu:GetItem(index)
                return item and item:GetValue() or ""
            end
            
            return Input
        end
        
        function Tab:CreateKeybind(keybindOptions)
            keybindOptions = keybindOptions or {}
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local name = keybindOptions.Name or "Keybind"
            local currentKey = keybindOptions.CurrentKeybind
            local callback = keybindOptions.Callback or function() end
            local tooltip = keybindOptions.ToolTip
            
            local index = Menu.Hotkey(tabName, containerName, name, currentKey, callback, tooltip)
            
            local Keybind = {}
            Keybind._index = index
            
            function Keybind:Set(key, mode)
                local item = Menu:GetItem(index)
                if item then
                    item:SetValue(key, mode)
                end
            end
            
            function Keybind:Get()
                local item = Menu:GetItem(index)
                return item and item:GetValue() or nil
            end
            
            return Keybind
        end
        
        function Tab:CreateColorPicker(colorOptions)
            colorOptions = colorOptions or {}
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local name = colorOptions.Name or "Color Picker"
            local currentColor = colorOptions.Color or Color3.new(1, 1, 1)
            local callback = colorOptions.Callback or function() end
            local tooltip = colorOptions.ToolTip
            
            local index = Menu.ColorPicker(tabName, containerName, name, currentColor, 0, callback, tooltip)
            
            local ColorPicker = {}
            ColorPicker._index = index
            
            function ColorPicker:Set(color, alpha)
                local item = Menu:GetItem(index)
                if item then
                    item:SetValue(color, alpha or 0)
                end
            end
            
            function ColorPicker:Get()
                local item = Menu:GetItem(index)
                return item and item:GetValue() or Color3.new(1, 1, 1)
            end
            
            return ColorPicker
        end
        
        function Tab:CreateLabel(text)
            local containerName = Tab._currentContainer or "Main"
            
            if not Tab._currentContainer then
                Tab:CreateSection("Main")
            end
            
            local index = Menu.Label(tabName, containerName, text or "Label")
            return {_index = index}
        end
        
        Window._tabs[tabName] = Tab
        return Tab
    end
    
    function Window:Notify(options)
        options = options or {}
        local title = options.Title or "Notification"
        local content = options.Content or ""
        local duration = options.Duration or 3
        
        local text = "<font color='##A6BAFF'>[" .. title .. "]</font> " .. content
        Menu.Notify(text, duration)
    end
    
    function Window:SetVisible(visible)
        Menu:SetVisible(visible)
    end
    
    function Window:Toggle()
        Menu:SetVisible(not Menu.IsVisible)
    end
    
    function Window:Destroy()
        if Menu.Screen then
            Menu.Screen:Destroy()
        end
    end
    
    return Window
end


DYHUBLIB.Notify = function(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 3
    
    local text = "<font color='##A6BAFF'>[" .. title .. "]</font> " .. content
    Menu.Notify(text, duration)
end


Menu.Easy = DYHUBLIB


local MobileButton = nil

if isMobile then
    
    MobileButton = Instance.new("Frame")
    MobileButton.Name = "MobileToggleButton"
    MobileButton.Size = UDim2.fromOffset(55, 55)
    MobileButton.Position = UDim2.fromOffset(15, 100)
    MobileButton.BackgroundColor3 = Menu.Accent
    MobileButton.BackgroundTransparency = 0.15
    MobileButton.BorderSizePixel = 0
    MobileButton.ZIndex = 100
    MobileButton.Active = true
    MobileButton.Parent = Menu.Screen
    
    local MobileCorner = Instance.new("UICorner")
    MobileCorner.CornerRadius = UDim.new(0, 12)
    MobileCorner.Parent = MobileButton
    
    local MobileStroke = Instance.new("UIStroke")
    MobileStroke.Color = Color3.new(1, 1, 1)
    MobileStroke.Thickness = 2
    MobileStroke.Transparency = 0.4
    MobileStroke.Parent = MobileButton
    
    local MobileIcon = Instance.new("ImageLabel")
    MobileIcon.Size = UDim2.new(1, 0, 1, 0)
    MobileIcon.BackgroundTransparency = 1
    MobileIcon.Image = "rbxassetid://104487529937663"
    MobileIcon.ScaleType = Enum.ScaleType.Fit
    MobileIcon.Parent = MobileButton 
    
    local MobileInteract = Instance.new("TextButton")
    MobileInteract.Size = UDim2.new(1, 0, 1, 0)
    MobileInteract.BackgroundTransparency = 1
    MobileInteract.Text = ""
    MobileInteract.ZIndex = 101
    MobileInteract.Parent = MobileButton
    
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    local wasDragged = false
    local dragThreshold = 8
    
    
    local function clampButtonPosition(x, y)
        local screenSize = Menu.Screen.AbsoluteSize
        local btnSize = MobileButton.AbsoluteSize
        local clampedX = math.clamp(x, 5, screenSize.X - btnSize.X - 5)
        local clampedY = math.clamp(y, 5, screenSize.Y - btnSize.Y - 5)
        return clampedX, clampedY
    end
    
    MobileInteract.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            ragged = false
            dragStart = Vector2.new(input.Position.X, input.Position.Y)
            startPos = MobileButton.Position
        end
    end)
    
    MobileInteract.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isDragging and not wasDragged then
                
                Menu:SetVisible(not Menu.IsVisible)
            end
            isDragging = false
            wasDragged = false
        end
    end)
    
    UserInput.InputChanged:Connect(function(input)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local currentPos = Vector2.new(input.Position.X, input.Position.Y)
            local delta = currentPos - dragStart
            local distance = delta.Magnitude
            
            if distance > dragThreshold then
                wasDragged = true
                local newX = startPos.X.Offset + delta.X
                local newY = startPos.Y.Offset + delta.Y
                local clampedX, clampedY = clampButtonPosition(newX, newY)
                MobileButton.Position = UDim2.fromOffset(clampedX, clampedY)
            end
        end
    end)
    
    
    Menu:OnVisibilityChanged(function(visible)
        if visible then
            MobileIcon.Image = "rbxassetid://104487529937663" -- จะใส่เป็นอีกไอคอน (เช่นปุ่มปิด) ก็เปลี่ยน id ตรงนี้
            TweenService:Create(MobileButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.35}):Play()
        else
            MobileIcon.Image = "rbxassetid://104487529937663"
            TweenService:Create(MobileButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
        end
    end)
    
    
    AddEventListener(MobileButton, function()
        MobileButton.BackgroundColor3 = Menu.Accent
    end)
end

Menu.IsMobile = isMobile
Menu.MobileButton = MobileButton

return Menu
