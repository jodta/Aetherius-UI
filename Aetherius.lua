--[[
    Aetherius UI Library - Rayfield Midnight Edition
    "Precision, Stealth, and Performance"
    A sleek, Rayfield-inspired UI with a high-fidelity Midnight theme.
]]

local Aetherius = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Main = Color3.fromRGB(15, 15, 18),
    Sidebar = Color3.fromRGB(10, 10, 12),
    Element = Color3.fromRGB(22, 22, 26),
    Section = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(60, 120, 255),
    Secondary = Color3.fromRGB(40, 40, 45),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(170, 170, 180),
    Border = Color3.fromRGB(35, 35, 40),
}

-- Private Helper: Draggability
local function MakeDraggable(Frame, DragPart)
    local Dragging, DragInput, DragStart, StartPos
    DragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true DragStart = input.Position StartPos = Frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    DragPart.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
    RunService.RenderStepped:Connect(function() if Dragging and DragInput then
        local Delta = DragInput.Position - DragStart
        Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end end)
end

-- Notification Manager
local NotificationStack = {}
local function UpdateNotificationPositions()
    for i, note in pairs(NotificationStack) do
        local targetPos = UDim2.new(1, -270, 1, -20 - (i * 85))
        TweenService:Create(note, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end

function Aetherius:CreateWindow(Config)
    Config = Config or {}
    local Name = Config.Name or "Aetherius UI"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Aetherius_" .. math.random(100, 999)
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window (Rayfield-like proportions)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -250, 0.5, -170)
    Main.Size = UDim2.new(0, 500, 0, 340)
    Main.ClipsDescendants = true
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)
    
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1.2
    
    -- Banner / Title
    local TopBar = Instance.new("Frame", Main)
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = Theme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 9)
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Font = Enum.Font.GothamMedium
    Title.Text = Name
    Title.TextColor3 = Theme.Text
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -35, 0, 8)
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Font = Enum.Font.GothamMedium
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.SubText
    CloseBtn.TextSize = 22
    
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    MakeDraggable(Main, TopBar)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name = "Sidebar"
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 140, 1, -40)
    
    local SidebarLine = Instance.new("Frame", Sidebar)
    SidebarLine.BackgroundColor3 = Theme.Border
    SidebarLine.BorderSizePixel = 0
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 10, 0, 10)
    TabContainer.Size = UDim2.new(1, -20, 1, -20)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 4)
    
    -- Content Area
    local ContentArea = Instance.new("Frame", Main)
    ContentArea.Name = "ContentArea"
    ContentArea.BackgroundTransparency = 1
    ContentArea.Position = UDim2.new(0, 150, 0, 50)
    ContentArea.Size = UDim2.new(1, -160, 1, -60)
    
    local Window = { Tabs = {}, ActiveTab = nil }
    
    function Window:CreateTab(TabName)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Name = TabName .. "_Tab"
        TabBtn.BackgroundColor3 = Theme.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.Text = TabName
        TabBtn.TextColor3 = Theme.SubText
        TabBtn.TextSize = 13
        TabBtn.AutoButtonColor = false
        
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Name = TabName .. "_Page"
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 6)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        
        local TabObj = { Name = TabName, Page = Page }
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Theme.SubText}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85, TextColor3 = Theme.Text}):Play()
            Window.ActiveTab = TabObj
        end)
        
        TabObj.Btn = TabBtn
        table.insert(Window.Tabs, TabObj)
        
        if #Window.Tabs == 1 then
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0.85
            TabBtn.TextColor3 = Theme.Text
            Window.ActiveTab = TabObj
        end

        function TabObj:CreateButton(Cfg)
            local F = Instance.new("TextButton", Page)
            F.BackgroundColor3 = Theme.Element
            F.Size = UDim2.new(1, 0, 0, 36)
            F.Text = "" F.AutoButtonColor = false
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", F).Color = Theme.Border
            
            local L = Instance.new("TextLabel", F)
            L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 12, 0, 0) L.Size = UDim2.new(1, -24, 1, 0)
            L.Font = Enum.Font.Gotham L.Text = Cfg.Name L.TextColor3 = Theme.Text L.TextSize = 13 L.TextXAlignment = Enum.TextXAlignment.Left
            
            F.MouseEnter:Connect(function() TweenService:Create(F, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play() end)
            F.MouseLeave:Connect(function() TweenService:Create(F, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play() end)
            F.MouseButton1Click:Connect(function() if Cfg.Callback then Cfg.Callback() end end)
        end

        function TabObj:CreateToggle(Cfg)
            local F = Instance.new("TextButton", Page)
            F.BackgroundColor3 = Theme.Element
            F.Size = UDim2.new(1, 0, 0, 36)
            F.Text = "" F.AutoButtonColor = false
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", F).Color = Theme.Border
            
            local L = Instance.new("TextLabel", F)
            L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 12, 0, 0) L.Size = UDim2.new(1, -60, 1, 0)
            L.Font = Enum.Font.Gotham L.Text = Cfg.Name L.TextColor3 = Theme.Text L.TextSize = 13 L.TextXAlignment = Enum.TextXAlignment.Left
            
            local Tgl = Instance.new("Frame", F)
            Tgl.BackgroundColor3 = Theme.Main
            Tgl.Position = UDim2.new(1, -42, 0.5, -9)
            Tgl.Size = UDim2.new(0, 32, 0, 18)
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
            
            local Dot = Instance.new("Frame", Tgl)
            Dot.BackgroundColor3 = Theme.SubText
            Dot.Position = UDim2.new(0, 3, 0.5, -6)
            Dot.Size = UDim2.new(0, 12, 0, 12)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
            
            local Toggled = Cfg.CurrentValue or false
            local function Refresh()
                if Toggled then
                    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Theme.Accent}):Play()
                    TweenService:Create(Tgl, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
                else
                    TweenService:Create(Dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Theme.SubText}):Play()
                    TweenService:Create(Tgl, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Main}):Play()
                end
            end
            Refresh()
            F.MouseButton1Click:Connect(function() Toggled = not Toggled Refresh() if Cfg.Callback then Cfg.Callback(Toggled) end end)
        end

        function TabObj:CreateSlider(Cfg)
            local F = Instance.new("Frame", Page)
            F.BackgroundColor3 = Theme.Element F.Size = UDim2.new(1, 0, 0, 48)
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", F).Color = Theme.Border
            
            local L = Instance.new("TextLabel", F)
            L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 12, 0, 8) L.Size = UDim2.new(1, -30, 0, 18)
            L.Font = Enum.Font.Gotham L.Text = Cfg.Name L.TextColor3 = Theme.Text L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left
            
            local Out = Instance.new("TextButton", F)
            Out.BackgroundColor3 = Theme.Main Out.Position = UDim2.new(0, 12, 0, 32) Out.Size = UDim2.new(1, -24, 0, 6) Out.Text = "" Out.AutoButtonColor = false
            Instance.new("UICorner", Out).CornerRadius = UDim.new(1, 0)
            
            local In = Instance.new("Frame", Out)
            In.BackgroundColor3 = Theme.Accent In.BorderSizePixel = 0 In.Size = UDim2.new(0, 0, 1, 0)
            Instance.new("UICorner", In).CornerRadius = UDim.new(1, 0)
            
            local Min, Max = Cfg.Range[1], Cfg.Range[2]
            local Cur = Cfg.CurrentValue or Min
            local function Update()
                local P = math.clamp((Cur - Min) / (Max - Min), 0, 1)
                In:TweenSize(UDim2.new(P, 0, 1, 0), "Out", "Quart", 0.1, true)
                if Cfg.Callback then Cfg.Callback(Cur) end
            end
            Update()
            
            local function Drag(input)
                local P = math.clamp((input.Position.X - Out.AbsolutePosition.X) / Out.AbsoluteSize.X, 0, 1)
                Cur = math.floor(Min + (Max - Min) * P) Update()
            end
            
            local Dragging = false
            Out.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Drag(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Drag(i) end end)
        end

        function TabObj:CreateDropdown(Cfg)
            local F = Instance.new("Frame", Page)
            F.BackgroundColor3 = Theme.Element F.Size = UDim2.new(1, 0, 0, 36) F.ClipsDescendants = true
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", F).Color = Theme.Border
            
            local MB = Instance.new("TextButton", F)
            MB.BackgroundTransparency = 1 MB.Size = UDim2.new(1, 0, 0, 36) MB.Font = Enum.Font.Gotham
            MB.Text = "  " .. Cfg.Name .. " (" .. (Cfg.CurrentOption or "None") .. ")" MB.TextColor3 = Theme.Text MB.TextSize = 13 MB.TextXAlignment = Enum.TextXAlignment.Left
            
            local Opened = false
            MB.MouseButton1Click:Connect(function()
                Opened = not Opened
                local H = Opened and (40 + #Cfg.Options * 30) or 36
                TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, H)}):Play()
            end)
            
            for i, opt in pairs(Cfg.Options) do
                local OB = Instance.new("TextButton", F)
                OB.BackgroundColor3 = Theme.Sidebar OB.Position = UDim2.new(0, 5, 0, 40 + (i-1)*30) OB.Size = UDim2.new(1, -10, 0, 26)
                OB.Font = Enum.Font.Gotham OB.Text = opt OB.TextColor3 = Theme.SubText OB.TextSize = 12
                Instance.new("UICorner", OB).CornerRadius = UDim.new(0, 4)
                OB.MouseButton1Click:Connect(function()
                    MB.Text = "  " .. Cfg.Name .. " (" .. opt .. ")"
                    Opened = false
                    TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 36)}):Play()
                    if Cfg.Callback then Cfg.Callback(opt) end
                end)
            end
        end

        function TabObj:CreateInput(Cfg)
            local F = Instance.new("Frame", Page)
            F.BackgroundColor3 = Theme.Element F.Size = UDim2.new(1, 0, 0, 40)
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", F).Color = Theme.Border
            
            local TB = Instance.new("TextBox", F)
            TB.BackgroundTransparency = 1 TB.Position = UDim2.new(0, 12, 0, 0) TB.Size = UDim2.new(1, -24, 1, 0)
            TB.Font = Enum.Font.Gotham TB.PlaceholderText = Cfg.Name .. "..." TB.Text = "" TB.TextColor3 = Theme.Text TB.PlaceholderColor3 = Theme.SubText TB.TextSize = 12 TB.TextXAlignment = Enum.TextXAlignment.Left
            TB.FocusLost:Connect(function() if Cfg.Callback then Cfg.Callback(TB.Text) end end)
        end

        function TabObj:CreateColorPicker(Cfg)
            local F = Instance.new("Frame", Page)
            F.BackgroundColor3 = Theme.Element F.Size = UDim2.new(1, 0, 0, 36) F.ClipsDescendants = true
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", F).Color = Theme.Border
            
            local P = Instance.new("Frame", F)
            P.BackgroundColor3 = Cfg.Default or Theme.Accent P.Position = UDim2.new(1, -38, 0, 8) P.Size = UDim2.new(0, 30, 0, 20)
            Instance.new("UICorner", P).CornerRadius = UDim.new(0, 4)
            
            local MB = Instance.new("TextButton", F)
            MB.BackgroundTransparency = 1 MB.Size = UDim2.new(1, 0, 0, 36) MB.Font = Enum.Font.Gotham
            MB.Text = "  " .. Cfg.Name MB.TextColor3 = Theme.Text MB.TextSize = 13 MB.TextXAlignment = Enum.TextXAlignment.Left
            
            local Opened = false
            MB.MouseButton1Click:Connect(function()
                Opened = not Opened
                local H = Opened and 140 or 36
                TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, H)}):Play()
            end)
        end

        function TabObj:CreateSection(Name)
            local S = Instance.new("TextLabel", Page)
            S.BackgroundTransparency = 1 S.Size = UDim2.new(1, 0, 0, 30)
            S.Font = Enum.Font.GothamBold S.Text = Name S.TextColor3 = Theme.Accent S.TextSize = 12 S.TextXAlignment = Enum.TextXAlignment.Left
            local P = Instance.new("UIPadding", S) P.PaddingLeft = UDim.new(0, 5)
        end

        function TabObj:CreateLabel(Text)
            local L = Instance.new("TextLabel", Page)
            L.BackgroundTransparency = 1 L.Size = UDim2.new(1, 0, 0, 20)
            L.Font = Enum.Font.Gotham L.Text = Text L.TextColor3 = Theme.SubText L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left L.TextWrapped = true
        end
        
        return TabObj
    end
    
    function Window:Notify(Cfg)
        if #NotificationStack >= 5 then table.remove(NotificationStack, 1):Destroy() UpdateNotificationPositions() end
        local note = Instance.new("Frame", ScreenGui) note.BackgroundColor3 = Theme.Main note.Position = UDim2.new(1, 20, 1, -100) note.Size = UDim2.new(0, 260, 0, 80)
        Instance.new("UICorner", note).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", note).Color = Theme.Accent
        
        local T = Instance.new("TextLabel", note) T.BackgroundTransparency = 1 T.Position = UDim2.new(0, 15, 0, 10) T.Size = UDim2.new(1, -30, 0, 20)
        T.Font = Enum.Font.GothamBold T.Text = Cfg.Title T.TextColor3 = Theme.Text T.TextSize = 14 T.TextXAlignment = Enum.TextXAlignment.Left
        
        local C = Instance.new("TextLabel", note, T) C.BackgroundTransparency = 1 C.Position = UDim2.new(0, 0, 0, 25) C.Size = UDim2.new(1, 0, 0, 35)
        C.Font = Enum.Font.Gotham C.Text = Cfg.Content C.TextColor3 = Theme.SubText C.TextSize = 11 C.TextXAlignment = Enum.TextXAlignment.Left C.TextWrapped = true
        
        table.insert(NotificationStack, note) UpdateNotificationPositions()
        task.delay(Cfg.Duration or 5, function()
            local idx = table.find(NotificationStack, note)
            if idx then table.remove(NotificationStack, idx) end
            TweenService:Create(note, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, note.Position.Y.Offset)}):Play()
            task.wait(0.4) note:Destroy() UpdateNotificationPositions()
        end)
    end
    
    return Window
end

return Aetherius
