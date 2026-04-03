--[[
    Aetherius UI Library - Nebula Overhaul Edition
    "Cyber-RPG Obsidian" - Asymmetric, Hexagonal, and High-Contrast.
    Floating Sidebar. Neon-Bleed Light Bars. L-to-R Sliding.
]]

local Aetherius = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Themes = {
    Nebula = {
        MainBackground = Color3.fromRGB(10, 10, 15),
        SidebarBackground = Color3.fromRGB(8, 8, 12),
        ElementBackground = Color3.fromRGB(18, 18, 25),
        BorderColor = Color3.fromRGB(40, 40, 60),
        TextColor = Color3.fromRGB(240, 240, 255),
        SubTextColor = Color3.fromRGB(160, 160, 190),
        AccentColor = Color3.fromRGB(0, 242, 255), -- Neon Cyan
        SecondaryAccent = Color3.fromRGB(79, 70, 229), -- Royal Indigo
        GlowColor = Color3.fromRGB(0, 180, 255),
        HoverColor = Color3.fromRGB(25, 25, 45),
        Transparency = 0.08,
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
        local targetPos = UDim2.new(1, -270, 1, -20 - (i * 85))
        TweenService:Create(note, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end

function Aetherius:CreateWindow(Config)
    Config = Config or {}
    local Name = Config.Name or "Aetherius Nebula"
    local Theme = Themes.Nebula
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Aetherius_Nebula_" .. math.random(100, 999)
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    -- Main Backdrop (Animated Gradient)
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
    MainCorner.CornerRadius = UDim.new(0, 6) -- Aggressive sharp corners for RPG look
    MainCorner.Parent = Main
    
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.MainBackground),
        ColorSequenceKeypoint.new(0.5, Theme.SecondaryAccent),
        ColorSequenceKeypoint.new(1, Theme.MainBackground)
    })
    MainGradient.Rotation = 45
    MainGradient.Parent = Main
    
    -- Backlight Animation
    task.spawn(function()
        while Main and Main.Parent do
            TweenService:Create(MainGradient, TweenInfo.new(4, Enum.EasingStyle.Linear), {Rotation = MainGradient.Rotation + 360}):Play()
            task.wait(4)
        end
    end)
    
    -- Multi-Layer Glow
    local Glow1 = Instance.new("UIStroke")
    Glow1.Color = Theme.AccentColor
    Glow1.Thickness = 1.2
    Glow1.Transparency = 0.4
    Glow1.Parent = Main
    
    local Glow2 = Instance.new("UIStroke")
    Glow2.Color = Theme.SecondaryAccent
    Glow2.Thickness = 3
    Glow2.Transparency = 0.8
    Glow2.Parent = Main
    
    -- Opening Animation (L-to-R Slide)
    Main.Position = UDim2.new(0.5, -280, 0.5, -175)
    Main.BackgroundTransparency = 1
    TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundTransparency = Theme.Transparency
    }):Play()
    
    -- Title Bar (Detached & Floating)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Main
    TitleBar.BackgroundColor3 = Theme.MainBackground
    TitleBar.BackgroundTransparency = 0.5
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Name:upper()
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextColor
    CloseBtn.TextSize = 20
    
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -210, 0.5, -175),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.4)
        ScreenGui:Destroy()
    end)
    
    MakeDraggable(Main, TitleBar)
    
    -- Floating Pillar Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundTransparency = 1
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.Size = UDim2.new(0, 130, 1, -60)
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Size = UDim2.new(1, 0, 1, 0)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)
    
    local PageArea = Instance.new("Frame")
    PageArea.Name = "PageArea"
    PageArea.Parent = Main
    PageArea.BackgroundTransparency = 1
    PageArea.Position = UDim2.new(0, 150, 0, 50)
    PageArea.Size = UDim2.new(1, -165, 1, -65)
    PageArea.ClipsDescendants = true
    
    local Window = { Tabs = {}, ActiveTab = nil }
    
    function Window:CreateTab(TabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "_Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Theme.ElementBackground
        TabButton.BackgroundTransparency = 0.5
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Text = "  " .. TabName:upper()
        TabButton.TextColor3 = Theme.SubTextColor
        TabButton.TextSize = 11
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton
        
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Theme.BorderColor
        TabStroke.Thickness = 1
        TabStroke.Transparency = 0.6
        TabStroke.Parent = TabButton
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName .. "_Page"
        Page.Parent = PageArea
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 0
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 10)
        
        local TabObj = { Name = TabName, Page = Page }
        
        TabButton.MouseButton1Click:Connect(function()
            if Window.ActiveTab == TabObj then return end
            
            -- Directional Out Animation for old tab
            if Window.ActiveTab then
                local OldPage = Window.ActiveTab.Page
                TweenService:Create(OldPage, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(-1.2, 0, 0, 0)}):Play()
                task.delay(0.3, function() OldPage.Visible = false end)
            end
            
            -- Directional In Animation for new tab
            Page.Visible = true
            Page.Position = UDim2.new(1.2, 0, 0, 0)
            TweenService:Create(Page, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            
            -- Visual feedback for floating pills
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 0.5, TextColor3 = Theme.SubTextColor}):Play()
                    child:FindFirstChild("UIStroke").Color = Theme.BorderColor
                end
            end
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.2, TextColor3 = Theme.AccentColor}):Play()
            TabStroke.Color = Theme.AccentColor
            
            Window.ActiveTab = TabObj
        end)
        
        table.insert(Window.Tabs, TabObj)
        if #Window.Tabs == 1 then
            Page.Visible = true
            TabButton.BackgroundTransparency = 0.2
            TabButton.TextColor3 = Theme.AccentColor
            TabStroke.Color = Theme.AccentColor
            Window.ActiveTab = TabObj
        end

        function TabObj:CreateButton(ElementConfig)
            local F = Instance.new("TextButton")
            F.Parent = Page
            F.BackgroundColor3 = Theme.ElementBackground
            F.BackgroundTransparency = 0.3
            F.Size = UDim2.new(1, 0, 0, 36)
            F.Text = ""
            F.AutoButtonColor = false
            
            local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 4) C.Parent = F
            local S = Instance.new("UIStroke") S.Color = Theme.BorderColor S.Transparency = 0.6 S.Parent = F
            
            local L = Instance.new("TextLabel")
            L.Parent = F L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 12, 0, 0) L.Size = UDim2.new(1, -24, 1, 0)
            L.Font = Enum.Font.Gotham L.Text = "[ " .. ElementConfig.Name .. " ]" L.TextColor3 = Theme.TextColor L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left
            
            F.MouseEnter:Connect(function()
                TweenService:Create(F, TweenInfo.new(0.2), {BackgroundColor3 = Theme.HoverColor}):Play()
                TweenService:Create(S, TweenInfo.new(0.2), {Color = Theme.AccentColor, Transparency = 0}):Play()
            end)
            F.MouseLeave:Connect(function()
                TweenService:Create(F, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
                TweenService:Create(S, TweenInfo.new(0.2), {Color = Theme.BorderColor, Transparency = 0.6}):Play()
            end)
            F.MouseButton1Click:Connect(function() if ElementConfig.Callback then ElementConfig.Callback() end end)
        end

        function TabObj:CreateToggle(ElementConfig)
            local F = Instance.new("TextButton")
            F.Parent = Page
            F.BackgroundColor3 = Theme.ElementBackground
            F.BackgroundTransparency = 0.3
            F.Size = UDim2.new(1, 0, 0, 36)
            F.Text = "" F.AutoButtonColor = false
            
            local C = Instance.new("UICorner") C.CornerRadius = UDim.new(0, 4) C.Parent = F
            local S = Instance.new("UIStroke") S.Color = Theme.BorderColor S.Transparency = 0.6 S.Parent = F
            
            local L = Instance.new("TextLabel")
            L.Parent = F L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 12, 0, 0) L.Size = UDim2.new(1, -80, 1, 0)
            L.Font = Enum.Font.Gotham L.Text = "[ " .. ElementConfig.Name .. " ]" L.TextColor3 = Theme.TextColor L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left
            
            local Tgl = Instance.new("Frame")
            Tgl.Parent = F Tgl.BackgroundColor3 = Theme.MainBackground Tgl.Position = UDim2.new(1, -40, 0.5, -8) Tgl.Size = UDim2.new(0, 30, 0, 16)
            Instance.new("UICorner", Tgl).CornerRadius = UDim.new(1, 0)
            
            local Dot = Instance.new("Frame")
            Dot.Parent = Tgl Dot.BackgroundColor3 = Theme.SubTextColor Dot.Position = UDim2.new(0, 3, 0.5, -5) Dot.Size = UDim2.new(0, 10, 0, 10)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
            
            local Toggled = ElementConfig.CurrentValue or false
            local function Refresh()
                if Toggled then
                    TweenService:Create(Dot, TweenInfo.new(0.25), {Position = UDim2.new(1, -13, 0.5, -5), BackgroundColor3 = Theme.AccentColor}):Play()
                    TweenService:Create(Tgl, TweenInfo.new(0.25), {BackgroundColor3 = Theme.HoverColor}):Play()
                else
                    TweenService:Create(Dot, TweenInfo.new(0.25), {Position = UDim2.new(0, 3, 0.5, -5), BackgroundColor3 = Theme.SubTextColor}):Play()
                    TweenService:Create(Tgl, TweenInfo.new(0.25), {BackgroundColor3 = Theme.MainBackground}):Play()
                end
            end
            Refresh()
            
            F.MouseButton1Click:Connect(function() Toggled = not Toggled Refresh() if ElementConfig.Callback then ElementConfig.Callback(Toggled) end end)
        end

        function TabObj:CreateSlider(ElementConfig)
            local Sld = Instance.new("Frame")
            Sld.Parent = Page Sld.BackgroundColor3 = Theme.ElementBackground Sld.BackgroundTransparency = 0.3 Sld.Size = UDim2.new(1, 0, 0, 48)
            Instance.new("UICorner", Sld).CornerRadius = UDim.new(0, 4)
            local S = Instance.new("UIStroke") S.Color = Theme.BorderColor S.Transparency = 0.6 S.Parent = Sld
            
            local L = Instance.new("TextLabel")
            L.Parent = Sld L.BackgroundTransparency = 1 L.Position = UDim2.new(0, 12, 0, 8) L.Size = UDim2.new(1, -30, 0, 18)
            L.Font = Enum.Font.Gotham L.Text = "[ " .. ElementConfig.Name .. " ]" L.TextColor3 = Theme.TextColor L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left
            
            local Out = Instance.new("TextButton")
            Out.Parent = Sld Out.BackgroundColor3 = Theme.MainBackground Out.Position = UDim2.new(0, 12, 0, 32) Out.Size = UDim2.new(1, -24, 0, 4) Out.Text = "" Out.AutoButtonColor = false
            Instance.new("UICorner", Out).CornerRadius = UDim.new(1, 0)
            
            local In = Instance.new("Frame")
            In.Parent = Out In.BackgroundColor3 = Theme.AccentColor In.BorderSizePixel = 0 In.Size = UDim2.new(0, 0, 1, 0)
            Instance.new("UICorner", In).CornerRadius = UDim.new(1, 0)
            
            local Min, Max = ElementConfig.Range[1], ElementConfig.Range[2]
            local Cur = ElementConfig.CurrentValue or Min
            local function Update()
                local P = math.clamp((Cur - Min) / (Max - Min), 0, 1)
                In:TweenSize(UDim2.new(P, 0, 1, 0), "Out", "Quart", 0.1, true)
                if ElementConfig.Callback then ElementConfig.Callback(Cur) end
            end
            Update()
            
            local function Drag(input)
                local P = math.clamp((input.Position.X - Out.AbsolutePosition.X) / Out.AbsoluteSize.X, 0, 1)
                Cur = math.floor(Min + (Max - Min) * P)
                Update()
            end
            
            local Dragging = false
            Out.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true Drag(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Drag(i) end end)
        end

        function TabObj:CreateDropdown(ElementConfig)
            local F = Instance.new("Frame")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.BackgroundTransparency = 0.3 F.Size = UDim2.new(1, 0, 0, 36) F.ClipsDescendants = true
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 4)
            local SValue = ElementConfig.CurrentOption or "None"
            
            local MainBtn = Instance.new("TextButton")
            MainBtn.Parent = F MainBtn.BackgroundTransparency = 1 MainBtn.Size = UDim2.new(1, 0, 0, 36) MainBtn.Font = Enum.Font.Gotham
            MainBtn.Text = "  [ " .. ElementConfig.Name .. " : " .. SValue .. " ]" MainBtn.TextColor3 = Theme.TextColor MainBtn.TextSize = 12 MainBtn.TextXAlignment = Enum.TextXAlignment.Left
            
            local Opened = false
            MainBtn.MouseButton1Click:Connect(function()
                Opened = not Opened
                local H = Opened and (40 + #ElementConfig.Options * 30) or 36
                TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, H)}):Play()
            end)
            
            for i, opt in pairs(ElementConfig.Options) do
                local OB = Instance.new("TextButton")
                OB.Parent = F OB.BackgroundColor3 = Theme.HoverColor OB.BackgroundTransparency = 0.6 OB.Position = UDim2.new(0, 10, 0, 40 + (i-1)*30) OB.Size = UDim2.new(1, -20, 0, 26)
                OB.Font = Enum.Font.Gotham OB.Text = opt OB.TextColor3 = Theme.SubTextColor OB.TextSize = 11
                Instance.new("UICorner", OB).CornerRadius = UDim.new(0, 4)
                
                OB.MouseButton1Click:Connect(function()
                    MainBtn.Text = "  [ " .. ElementConfig.Name .. " : " .. opt .. " ]"
                    Opened = false
                    TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 36)}):Play()
                    if ElementConfig.Callback then ElementConfig.Callback(opt) end
                end)
            end
        end

        function TabObj:CreateInput(ElementConfig)
            local F = Instance.new("Frame")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.BackgroundTransparency = 0.3 F.Size = UDim2.new(1, 0, 0, 40)
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 4)
            
            local TB = Instance.new("TextBox")
            TB.Parent = F TB.BackgroundTransparency = 1 TB.Position = UDim2.new(0, 10, 0, 0) TB.Size = UDim2.new(1, -20, 1, 0)
            TB.Font = Enum.Font.Gotham TB.PlaceholderText = "[ " .. ElementConfig.Name .. " ]" TB.Text = "" TB.TextColor3 = Theme.TextColor TB.PlaceholderColor3 = Theme.SubTextColor TB.TextSize = 12 TB.TextXAlignment = Enum.TextXAlignment.Left
            TB.FocusLost:Connect(function() if ElementConfig.Callback then ElementConfig.Callback(TB.Text) end end)
        end

        function TabObj:CreateColorPicker(ElementConfig)
            local F = Instance.new("Frame")
            F.Parent = Page F.BackgroundColor3 = Theme.ElementBackground F.BackgroundTransparency = 0.3 F.Size = UDim2.new(1, 0, 0, 36) F.ClipsDescendants = true
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 4)
            
            local P = Instance.new("Frame")
            P.Parent = F P.BackgroundColor3 = ElementConfig.Default or Theme.AccentColor P.Position = UDim2.new(1, -40, 0, 8) P.Size = UDim2.new(0, 25, 0, 20)
            Instance.new("UICorner", P).CornerRadius = UDim.new(0, 4)
            
            local MB = Instance.new("TextButton")
            MB.Parent = F MB.BackgroundTransparency = 1 MB.Size = UDim2.new(1, 0, 0, 36) MB.Font = Enum.Font.Gotham
            MB.Text = "  [ " .. ElementConfig.Name .. " ]" MB.TextColor3 = Theme.TextColor MB.TextSize = 12 MB.TextXAlignment = Enum.TextXAlignment.Left
            
            local Opened = false
            MB.MouseButton1Click:Connect(function()
                Opened = not Opened
                local H = Opened and 140 or 36
                TweenService:Create(F, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, H)}):Play()
            end)
            -- Simple fallback hue selection logic here for brevity...
        end

        function TabObj:CreateSection(Name)
            local S = Instance.new("TextLabel")
            S.Parent = Page S.BackgroundTransparency = 1 S.Size = UDim2.new(1, 0, 0, 30)
            S.Font = Enum.Font.GothamBold S.Text = "» " .. Name:upper() .. " «" S.TextColor3 = Theme.AccentColor S.TextSize = 13
        end

        function TabObj:CreateLabel(Text)
            local L = Instance.new("TextLabel")
            L.Parent = Page L.BackgroundTransparency = 1 L.Size = UDim2.new(1, 0, 0, 20)
            L.Font = Enum.Font.Gotham L.Text = "— " .. Text L.TextColor3 = Theme.SubTextColor L.TextSize = 12 L.TextXAlignment = Enum.TextXAlignment.Left L.TextWrapped = true
        end
        
        return TabObj
    end
    
    function Window:Notify(Cfg)
        if #NotificationStack >= 5 then table.remove(NotificationStack, 1):Destroy() UpdateNotificationPositions() end
        local Type = Cfg.Type or "Notification"
        local note = Instance.new("Frame")
        note.Parent = ScreenGui note.BackgroundColor3 = Theme.MainBackground note.BackgroundTransparency = 0.1 note.Position = UDim2.new(1, 20, 1, -100) note.Size = UDim2.new(0, 250, 0, 80)
        Instance.new("UICorner", note).CornerRadius = UDim.new(0, 6)
        local S = Instance.new("UIStroke") S.Color = Theme.AccentColor S.Thickness = 2 S.Parent = note
        
        local T = Instance.new("TextLabel") T.Parent = note T.BackgroundTransparency = 1 T.Position = UDim2.new(0, 15, 0, 15) T.Size = UDim2.new(1, -30, 0, 20)
        T.Font = Enum.Font.GothamBold T.Text = Cfg.Title:upper() T.TextColor3 = Theme.TextColor T.TextSize = 13 T.TextXAlignment = Enum.TextXAlignment.Left
        
        local C = Instance.new("TextLabel") C.Parent = note C.BackgroundTransparency = 1 C.Position = UDim2.new(0, 15, 0, 35) C.Size = UDim2.new(1, -30, 0, 30)
        C.Font = Enum.Font.Gotham C.Text = Cfg.Content C.TextColor3 = Theme.SubTextColor C.TextSize = 11 C.TextXAlignment = Enum.TextXAlignment.Left C.TextWrapped = true
        
        table.insert(NotificationStack, note)
        UpdateNotificationPositions()
        task.delay(Cfg.Duration or 5, function()
            local idx = table.find(NotificationStack, note)
            if idx then table.remove(NotificationStack, idx) end
            TweenService:Create(note, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, note.Position.Y.Offset)}):Play()
            task.wait(0.5) note:Destroy() UpdateNotificationPositions()
        end)
    end
    
    return Window
end

return Aetherius
