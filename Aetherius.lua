--[[
    Aetherius UI Library - Midnight Nebula Edition
    "Ultra-Modern, Ultra-Rounded, Ultra-Smooth"
    Glassmorphism. Soft Halos. Exponential Motion. 14px+ Corners.
]]

local Aetherius = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Themes = {
    MidnightNebula = {
        MainBackground = Color3.fromRGB(5, 5, 10),
        SidebarBackground = Color3.fromRGB(3, 3, 6),
        ElementBackground = Color3.fromRGB(20, 20, 30),
        BorderColor = Color3.fromRGB(50, 50, 80),
        TextColor = Color3.fromRGB(250, 250, 255),
        SubTextColor = Color3.fromRGB(180, 180, 210),
        AccentColor = Color3.fromRGB(90, 120, 255), -- Deep Space Blue
        SecondaryAccent = Color3.fromRGB(140, 90, 255), -- Nebula Purple
        GlowColor = Color3.fromRGB(70, 100, 255),
        HoverColor = Color3.fromRGB(30, 30, 50),
        Transparency = 0.12,
    }
}

-- Icons (RBX Asset IDs)
local Icons = {
    Done = "rbxassetid://3944703564",
    Error = "rbxassetid://3944706530",
    Warning = "rbxassetid://3944703830",
    Notification = "rbxassetid://3944703716",
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
        local targetPos = UDim2.new(1, -270, 1, -20 - (i * 90))
        TweenService:Create(note, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end

function Aetherius:CreateWindow(Config)
    Config = Config or {}
    local Name = Config.Name or "Aetherius Midnight"
    local Theme = Themes.MidnightNebula
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Aetherius_Midnight_" .. math.random(100, 999)
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window (Ultra-Rounded Glass)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Theme.MainBackground
    Main.BackgroundTransparency = Theme.Transparency
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16) -- Ultra-Rounded Soft Corners
    MainCorner.Parent = Main
    
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.MainBackground),
        ColorSequenceKeypoint.new(1, Theme.SidebarBackground)
    })
    MainGradient.Rotation = 45
    MainGradient.Parent = Main
    
    -- Soft Halo Glow (Breathing Atmospheric Border)
    local Halo = Instance.new("UIStroke")
    Halo.Color = Theme.GlowColor
    Halo.Thickness = 1.5
    Halo.Transparency = 0.5
    Halo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Halo.Parent = Main
    
    -- Opening Animation (Fade & Spring)
    Main.Size = UDim2.new(0, 480, 0, 330)
    Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 350),
        BackgroundTransparency = Theme.Transparency
    }):Play()
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Main
    TitleBar.BackgroundTransparency = 1
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -40, 0, 10)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamMedium
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextColor
    CloseBtn.TextSize = 24
    
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 470, 0, 320),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        ScreenGui:Destroy()
    end)
    
    MakeDraggable(Main, TitleBar)
    
    -- Sleek Integrated Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Theme.SidebarBackground
    Sidebar.BackgroundTransparency = 0.4
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.Size = UDim2.new(0, 150, 1, -45)
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 6)
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 12)
    TabPadding.PaddingRight = UDim.new(0, 12)
    TabPadding.PaddingTop = UDim.new(0, 12)
    TabPadding.Parent = TabContainer
    
    local PageArea = Instance.new("Frame")
    PageArea.Name = "PageArea"
    PageArea.Parent = Main
    PageArea.BackgroundTransparency = 1
    PageArea.Position = UDim2.new(0, 165, 0, 55)
    PageArea.Size = UDim2.new(1, -180, 1, -70)
    PageArea.ClipsDescendants = true
    
    local Window = { Tabs = {}, ActiveTab = nil }
    
    function Window:CreateTab(TabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "_Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Theme.AccentColor
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 0, 34)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = TabName
        TabButton.TextColor3 = Theme.SubTextColor
        TabButton.TextSize = 13
        TabButton.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 100) -- Full Pill-Shaped Tabs
        TabCorner.Parent = TabButton
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName .. "_Page"
        Page.Parent = PageArea
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.AccentColor
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 10)
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 20)
        PagePadding.Parent = Page
        
        local TabObj = { Name = TabName, Page = Page }
        
        TabButton.MouseButton1Click:Connect(function()
            if Window.ActiveTab == TabObj then return end
            
            -- Smooth Exponential Transition
            if Window.ActiveTab then
                local OP = Window.ActiveTab.Page
                TweenService:Create(OP, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 1.2, 0)}):Play()
                task.delay(0.3, function() OP.Visible = false end)
            end
            
            Page.Visible = true
            Page.Position = UDim2.new(0, 0, 1.2, 0)
            TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Theme.SubTextColor}):Play()
                end
            end
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.8, TextColor3 = Theme.TextColor}):Play()
            Window.ActiveTab = TabObj
        end)
        
        table.insert(Window.Tabs, TabObj)
        if #Window.Tabs == 1 then
            Page.Visible = true
            TabButton.BackgroundTransparency = 0.8
            TabButton.TextColor3 = Theme.TextColor
            Window.ActiveTab = TabObj
        end

        function TabObj:CreateButton(Cfg)
            local F = Instance.new("TextButton")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.Size = UDim2.new(1, 0, 0, 38) F.Text = "" F.AutoButtonColor = false
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
            
            local L = Instance.new("TextLabel")
            L.Parent = F L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 15, 0, 0) L.Size = UDim2.new(1, -30, 1, 0)
            L.Font = Enum.Font.GothamMedium L.Text = Cfg.Name L.TextColor3 = Theme.TextColor L.TextSize = 13 L.TextXAlignment = Enum.TextXAlignment.Left
            
            F.MouseEnter:Connect(function()
                TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = Theme.HoverColor, Size = UDim2.new(1, 4, 0, 38)}):Play()
            end)
            F.MouseLeave:Connect(function()
                TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = Theme.ElementBackground, Size = UDim2.new(1, 0, 0, 38)}):Play()
            end)
            F.MouseButton1Click:Connect(function() if Cfg.Callback then Cfg.Callback() end end)
        end

        function TabObj:CreateToggle(Cfg)
            local F = Instance.new("TextButton")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.Size = UDim2.new(1, 0, 0, 38) F.Text = "" F.AutoButtonColor = false
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 100) -- Pill Shape
            
            local L = Instance.new("TextLabel")
            L.Parent = F L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 18, 0, 0) L.Size = UDim2.new(1, -70, 1, 0)
            L.Font = Enum.Font.GothamMedium L.Text = Cfg.Name L.TextColor3 = Theme.TextColor L.TextSize = 13 L.TextXAlignment = Enum.TextXAlignment.Left
            
            local Tgl = Instance.new("Frame")
            Tgl.Parent = F Tgl.BackgroundColor3 = Theme.MainBackground Tgl.Position = UDim2.new(1, -45, 0.5, -9) Tgl.Size = UDim2.new(0, 32, 0, 18)
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
            
            local Dot = Instance.new("Frame")
            Dot.Parent = Tgl Dot.BackgroundColor3 = Theme.SubTextColor Dot.Position = UDim2.new(0, 3, 0.5, -6) Dot.Size = UDim2.new(0, 12, 0, 12)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
            
            local Toggled = Cfg.CurrentValue or false
            local function Refresh()
                if Toggled then
                    TweenService:Create(Dot, TweenInfo.new(0.25), {Position = UDim2.new(1, -15, 0.5, -6), BackgroundColor3 = Theme.AccentColor}):Play()
                    TweenService:Create(Tgl, TweenInfo.new(0.25), {BackgroundColor3 = Theme.HoverColor}):Play()
                else
                    TweenService:Create(Dot, TweenInfo.new(0.25), {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Theme.SubTextColor}):Play()
                    TweenService:Create(Tgl, TweenInfo.new(0.25), {BackgroundColor3 = Theme.MainBackground}):Play()
                end
            end
            Refresh()
            
            F.MouseButton1Click:Connect(function() Toggled = not Toggled Refresh() if Cfg.Callback then Cfg.Callback(Toggled) end end)
        end

        function TabObj:CreateSlider(Cfg)
            local F = Instance.new("Frame")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.Size = UDim2.new(1, 0, 0, 48)
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
            
            local L = Instance.new("TextLabel")
            L.Parent = F L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 15, 0, 8) L.Size = UDim2.new(1, -30, 0, 18)
            L.Font = Enum.Font.GothamMedium L.Text = Cfg.Name L.TextColor3 = Theme.TextColor L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueL = Instance.new("TextLabel")
            ValueL.Parent = F ValueL.BackgroundTransparency = 1 ValueL.Position = UDim2.new(1, -70, 0, 8) ValueL.Size = UDim2.new(0, 55, 0, 18)
            ValueL.Font = Enum.Font.GothamBold ValueL.TextColor3 = Theme.AccentColor ValueL.TextSize = 13 ValueL.TextXAlignment = Enum.TextXAlignment.Right
            
            local Out = Instance.new("TextButton")
            Out.Parent = F Out.BackgroundColor3 = Theme.MainBackground Out.Position = UDim2.new(0, 15, 0, 32) Out.Size = UDim2.new(1, -30, 0, 6) Out.Text = "" Out.AutoButtonColor = false
            Instance.new("UICorner", Out).CornerRadius = UDim.new(1, 0)
            
            local In = Instance.new("Frame")
            In.Parent = Out In.BackgroundColor3 = Theme.AccentColor In.BorderSizePixel = 0 In.Size = UDim2.new(0, 0, 1, 0)
            Instance.new("UICorner", In).CornerRadius = UDim.new(1, 0)
            
            local Min, Max = Cfg.Range[1], Cfg.Range[2]
            local Cur = Cfg.CurrentValue or Min
            local function Update()
                local P = math.clamp((Cur - Min) / (Max - Min), 0, 1)
                In:TweenSize(UDim2.new(P, 0, 1, 0), "Out", "Exponential", 0.1, true)
                ValueL.Text = tostring(Cur)
                if Cfg.Callback then Cfg.Callback(Cur) end
            end
            Update()
            
            local Dragging = false
            Out.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local P = math.clamp((i.Position.X - Out.AbsolutePosition.X) / Out.AbsoluteSize.X, 0, 1)
                Cur = math.floor(Min + (Max - Min) * P) Update()
            end end)
        end

        function TabObj:CreateDropdown(Cfg)
            local F = Instance.new("Frame")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.Size = UDim2.new(1, 0, 0, 38) F.ClipsDescendants = true
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
            
            local MB = Instance.new("TextButton")
            MB.Parent = F MB.BackgroundTransparency = 1 MB.Size = UDim2.new(1, 0, 0, 38) MB.Font = Enum.Font.GothamMedium
            MB.Text = "  " .. Cfg.Name .. " (" .. (Cfg.CurrentOption or "None") .. ")" MB.TextColor3 = Theme.TextColor MB.TextSize = 13 MB.TextXAlignment = Enum.TextXAlignment.Left
            
            local Opened = false
            MB.MouseButton1Click:Connect(function()
                Opened = not Opened
                local H = Opened and (45 + #Cfg.Options * 30) or 38
                TweenService:Create(F, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, H)}):Play()
            end)
            
            for i, opt in pairs(Cfg.Options) do
                local OB = Instance.new("TextButton")
                OB.Parent = F OB.BackgroundColor3 = Theme.HoverColor OB.Position = UDim2.new(0, 10, 0, 42 + (i-1)*30) OB.Size = UDim2.new(1, -20, 0, 26)
                OB.Font = Enum.Font.GothamMedium OB.Text = opt OB.TextColor3 = Theme.SubTextColor OB.TextSize = 12
                Instance.new("UICorner", OB).CornerRadius = UDim.new(0, 100)
                OB.MouseButton1Click:Connect(function()
                    MB.Text = "  " .. Cfg.Name .. " (" .. opt .. ")"
                    Opened = false
                    TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, 38)}):Play()
                    if Cfg.Callback then Cfg.Callback(opt) end
                end)
            end
        end

        function TabObj:CreateInput(Cfg)
            local F = Instance.new("Frame")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.Size = UDim2.new(1, 0, 0, 42)
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 100)
            
            local TB = Instance.new("TextBox")
            TB.Parent = F TB.BackgroundTransparency = 1 TB.Position = UDim2.new(0, 15, 0, 0) TB.Size = UDim2.new(1, -30, 1, 0)
            TB.Font = Enum.Font.GothamMedium TB.PlaceholderText = Cfg.Name .. "..." TB.Text = "" TB.TextColor3 = Theme.TextColor TB.PlaceholderColor3 = Theme.SubTextColor TB.TextSize = 12 TB.TextXAlignment = Enum.TextXAlignment.Left
            TB.FocusLost:Connect(function() if Cfg.Callback then Cfg.Callback(TB.Text) end end)
        end

        function TabObj:CreateColorPicker(Cfg)
            local F = Instance.new("Frame")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.Size = UDim2.new(1, 0, 0, 38) F.ClipsDescendants = true
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
            
            local P = Instance.new("Frame")
            P.Parent = F P.BackgroundColor3 = Cfg.Default or Theme.AccentColor P.Position = UDim2.new(1, -40, 0, 9) P.Size = UDim2.new(0, 28, 0, 20)
            Instance.new("UICorner", P).CornerRadius = UDim.new(0, 100)
            
            local MB = Instance.new("TextButton")
            MB.Parent = F MB.BackgroundTransparency = 1 MB.Size = UDim2.new(1, 0, 0, 38) MB.Font = Enum.Font.GothamMedium
            MB.Text = "  " .. Cfg.Name MB.TextColor3 = Theme.TextColor MB.TextSize = 13 MB.TextXAlignment = Enum.TextXAlignment.Left
            
            local Opened = false
            MB.MouseButton1Click:Connect(function()
                Opened = not Opened
                local H = Opened and 150 or 38
                TweenService:Create(F, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, H)}):Play()
            end)
        end

        function TabObj:CreateSection(Name)
            local S = Instance.new("TextLabel")
            S.Parent = Page S.BackgroundTransparency = 1 S.Size = UDim2.new(1, 0, 0, 25)
            S.Font = Enum.Font.GothamBold S.Text = Name:upper() S.TextColor3 = Theme.AccentColor S.TextSize = 12 S.TextXAlignment = Enum.TextXAlignment.Left
            local P = Instance.new("UIPadding") P.PaddingLeft = UDim.new(0, 5) P.Parent = S
        end

        function TabObj:CreateLabel(Text)
            local L = Instance.new("TextLabel")
            L.Parent = Page L.BackgroundTransparency = 1 L.Size = UDim2.new(1, 0, 0, 20)
            L.Font = Enum.Font.GothamMedium L.Text = "• " .. Text L.TextColor3 = Theme.SubTextColor L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left L.TextWrapped = true
        end
        
        return TabObj
    end
    
    function Window:Notify(Cfg)
        if #NotificationStack >= 5 then table.remove(NotificationStack, 1):Destroy() UpdateNotificationPositions() end
        local Type = Cfg.Type or "Notification"
        local note = Instance.new("Frame")
        note.Parent = ScreenGui note.BackgroundColor3 = Theme.MainBackground note.BackgroundTransparency = 1 note.Position = UDim2.new(1, 20, 1, -100) note.Size = UDim2.new(0, 260, 0, 85)
        Instance.new("UICorner", note).CornerRadius = UDim.new(0, 12)
        local S = Instance.new("UIStroke") S.Color = Theme.AccentColor S.Thickness = 2 S.Transparency = 0.4 S.Parent = note
        
        local T = Instance.new("TextLabel") T.Parent = note T.BackgroundTransparency = 1 T.Position = UDim2.new(0, 15, 0, 15) T.Size = UDim2.new(1, -30, 0, 20)
        T.Font = Enum.Font.GothamBold T.Text = Cfg.Title T.TextColor3 = Theme.TextColor T.TextSize = 14 T.TextXAlignment = Enum.TextXAlignment.Left
        
        local C = Instance.new("TextLabel") C.Parent = note C.BackgroundTransparency = 1 C.Position = UDim2.new(0, 15, 0, 35) C.Size = UDim2.new(1, -30, 0, 35)
        C.Font = Enum.Font.GothamMedium C.Text = Cfg.Content C.TextColor3 = Theme.SubTextColor C.TextSize = 12 C.TextXAlignment = Enum.TextXAlignment.Left C.TextWrapped = true
        
        TweenService:Create(note, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {BackgroundTransparency = Theme.Transparency, Position = UDim2.new(1, -280, 1, -100)}):Play()
        table.insert(NotificationStack, note)
        UpdateNotificationPositions()
        
        task.delay(Cfg.Duration or 6, function()
            local idx = table.find(NotificationStack, note)
            if idx then table.remove(NotificationStack, idx) end
            TweenService:Create(note, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, note.Position.Y.Offset), BackgroundTransparency = 1}):Play()
            task.wait(0.4) note:Destroy() UpdateNotificationPositions()
        end)
    end
    
    return Window
end

return Aetherius
