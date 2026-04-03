--[[
    Aetherius UI Library
    "Midnight Theme" - Sleek, Modern, and Performance-driven.
    Inspired by Rayfield.
]]

local Aetherius = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Themes = {
    Midnight = {
        MainBackground = Color3.fromRGB(15, 15, 20),
        SidebarBackground = Color3.fromRGB(12, 12, 16),
        ElementBackground = Color3.fromRGB(25, 25, 30),
        BorderColor = Color3.fromRGB(40, 40, 50),
        TextColor = Color3.fromRGB(240, 240, 245),
        SubTextColor = Color3.fromRGB(180, 180, 190),
        AccentColor = Color3.fromRGB(80, 120, 255),
        HoverColor = Color3.fromRGB(35, 35, 45),
        Transparency = 0.15
    }
}

-- Icons (RBX Asset IDs for Midnight Theme)
local Icons = {
    Done = "rbxassetid://3944703564", -- Check
    Error = "rbxassetid://3944706530", -- Close
    Warning = "rbxassetid://3944703830", -- Warning
    Notification = "rbxassetid://3944703716", -- Info
}

-- Private Helper: Draggability
local function MakeDraggable(Frame, DragPart)
    local Dragging, DragInput, DragStart, StartPos
    
    DragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    DragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if Dragging and DragInput then
            local Delta = DragInput.Position - DragStart
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

function Aetherius:CreateWindow(Config)
    Config = Config or {}
    local Name = Config.Name or "Aetherius UI"
    local Theme = Themes.Midnight -- Default to Midnight
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Aetherius_" .. math.random(100, 999)
    ScreenGui.Parent = CoreGui -- Change to game.Players.LocalPlayer.PlayerGui for studio testing if needed
    ScreenGui.ResetOnSpawn = false
    
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
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.BorderColor
    MainStroke.Thickness = 1.2
    MainStroke.Parent = Main
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Main
    TitleBar.BackgroundColor3 = Theme.SidebarBackground
    TitleBar.BackgroundTransparency = 1
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextColor
    CloseBtn.TextSize = 20
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MakeDraggable(Main, TitleBar)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Theme.SidebarBackground
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.Size = UDim2.new(0, 140, 1, -35)
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Parent = Main
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position = UDim2.new(0, 150, 0, 45)
    PageContainer.Size = UDim2.new(1, -160, 1, -55)
    
    local Window = {
        Tabs = {},
        ActiveTab = nil
    }
    
    function Window:CreateTab(TabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "_Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Theme.ElementBackground
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(0.9, 0, 0, 30)
        TabButton.Position = UDim2.new(0.05, 0, 0, 0)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = "  " .. TabName
        TabButton.TextColor3 = Theme.SubTextColor
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 4)
        TabCorner.Parent = TabButton
        
        local Page = Instance.new("ScrollingFrame")
        Page.Name = TabName .. "_Page"
        Page.Parent = PageContainer
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.AccentColor
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding = UDim.new(0, 8)
        
        local TabObj = {
            Name = TabName,
            Page = Page
        }
        
        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
            end
            Page.Visible = true
            -- Visual feedback for active tab
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextColor3 = Theme.SubTextColor}):Play()
                end
            end
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = Theme.Transparency, TextColor3 = Theme.TextColor}):Play()
        end)
        
        table.insert(Window.Tabs, TabObj)
        
        if #Window.Tabs == 1 then
            Page.Visible = true
            TabButton.BackgroundTransparency = Theme.Transparency
            TabButton.TextColor3 = Theme.TextColor
        end

        function TabObj:CreateButton(ElementConfig)
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Name = ElementConfig.Name .. "_Btn"
            BtnFrame.Parent = Page
            BtnFrame.BackgroundColor3 = Theme.ElementBackground
            BtnFrame.Size = UDim2.new(1, 0, 0, 32)
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = BtnFrame
            
            local Label = Instance.new("TextLabel")
            Label.Parent = BtnFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = ElementConfig.Name
            Label.TextColor3 = Theme.TextColor
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            BtnFrame.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.HoverColor}):Play()
            end)
            BtnFrame.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
            end)
            BtnFrame.MouseButton1Click:Connect(function()
                if ElementConfig.Callback then ElementConfig.Callback() end
            end)
        end

        function TabObj:CreateToggle(ElementConfig)
            local TglFrame = Instance.new("TextButton")
            TglFrame.Name = ElementConfig.Name .. "_Tgl"
            TglFrame.Parent = Page
            TglFrame.BackgroundColor3 = Theme.ElementBackground
            TglFrame.Size = UDim2.new(1, 0, 0, 32)
            TglFrame.Text = ""
            TglFrame.AutoButtonColor = false
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = TglFrame
            
            local Label = Instance.new("TextLabel")
            Label.Parent = TglFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = ElementConfig.Name
            Label.TextColor3 = Theme.TextColor
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local TglHolder = Instance.new("Frame")
            TglHolder.Parent = TglFrame
            TglHolder.BackgroundColor3 = Theme.MainBackground
            TglHolder.Position = UDim2.new(1, -40, 0, 7)
            TglHolder.Size = UDim2.new(0, 30, 0, 18)
            
            local HolderCorner = Instance.new("UICorner")
            HolderCorner.CornerRadius = UDim.new(1, 0)
            HolderCorner.Parent = TglHolder
            
            local TglDot = Instance.new("Frame")
            TglDot.Parent = TglHolder
            TglDot.BackgroundColor3 = Theme.SubTextColor
            TglDot.Position = UDim2.new(0, 3, 0, 3)
            TglDot.Size = UDim2.new(0, 12, 0, 12)
            
            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = TglDot
            
            local Toggled = ElementConfig.CurrentValue or false
            
            local function UpdateStyles()
                if Toggled then
                    TweenService:Create(TglDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -15, 0, 3), BackgroundColor3 = Theme.AccentColor}):Play()
                    TweenService:Create(TglHolder, TweenInfo.new(0.2), {BackgroundColor3 = Theme.HoverColor}):Play()
                else
                    TweenService:Create(TglDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0, 3), BackgroundColor3 = Theme.SubTextColor}):Play()
                    TweenService:Create(TglHolder, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainBackground}):Play()
                end
            end
            
            UpdateStyles()
            
            TglFrame.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                UpdateStyles()
                if ElementConfig.Callback then ElementConfig.Callback(Toggled) end
            end)
        end

        function TabObj:CreateSlider(ElementConfig)
            local SldFrame = Instance.new("Frame")
            SldFrame.Name = ElementConfig.Name .. "_Sld"
            SldFrame.Parent = Page
            SldFrame.BackgroundColor3 = Theme.ElementBackground
            SldFrame.Size = UDim2.new(1, 0, 0, 45)
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = SldFrame
            
            local Label = Instance.new("TextLabel")
            Label.Parent = SldFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 12, 0, 5)
            Label.Size = UDim2.new(1, -24, 0, 20)
            Label.Font = Enum.Font.Gotham
            Label.Text = ElementConfig.Name
            Label.TextColor3 = Theme.TextColor
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SldFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(1, -62, 0, 5)
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Font = Enum.Font.GothamMedium
            ValueLabel.Text = tostring(ElementConfig.CurrentValue)
            ValueLabel.TextColor3 = Theme.AccentColor
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local SliderOuter = Instance.new("TextButton")
            SliderOuter.Parent = SldFrame
            SliderOuter.BackgroundColor3 = Theme.MainBackground
            SliderOuter.Position = UDim2.new(0, 12, 0, 30)
            SliderOuter.Size = UDim2.new(1, -24, 0, 6)
            SliderOuter.Text = ""
            SliderOuter.AutoButtonColor = false
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(1, 0)
            SliderCorner.Parent = SliderOuter
            
            local SliderInner = Instance.new("Frame")
            SliderInner.Parent = SliderOuter
            SliderInner.BackgroundColor3 = Theme.AccentColor
            SliderInner.BorderSizePixel = 0
            SliderInner.Size = UDim2.new(0, 0, 1, 0)
            
            local SInnerCorner = Instance.new("UICorner")
            SInnerCorner.CornerRadius = UDim.new(1, 0)
            SInnerCorner.Parent = SliderInner
            
            local Min, Max = ElementConfig.Range[1], ElementConfig.Range[2]
            local Cur = ElementConfig.CurrentValue or Min
            
            local function UpdateSlider()
                local Perc = math.clamp((Cur - Min) / (Max - Min), 0, 1)
                SliderInner.Size = UDim2.new(Perc, 0, 1, 0)
                ValueLabel.Text = tostring(Cur)
                if ElementConfig.Callback then ElementConfig.Callback(Cur) end
            end
            
            UpdateSlider()
            
            local DraggingSlider = false
            SliderOuter.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    DraggingSlider = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    DraggingSlider = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if DraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local Size = math.clamp((input.Position.X - SliderOuter.AbsolutePosition.X) / SliderOuter.AbsoluteSize.X, 0, 1)
                    local NewValue = math.floor((Min + (Max - Min) * Size) / (ElementConfig.Increment or 1)) * (ElementConfig.Increment or 1)
                    if NewValue ~= Cur then
                        Cur = NewValue
                        UpdateSlider()
                    end
                end
            end)
        end

        function TabObj:CreateDropdown(ElementConfig)
            local DropFrame = Instance.new("Frame")
            DropFrame.Name = ElementConfig.Name .. "_Drop"
            DropFrame.Parent = Page
            DropFrame.BackgroundColor3 = Theme.ElementBackground
            DropFrame.Size = UDim2.new(1, 0, 0, 32)
            DropFrame.ClipsDescendants = true
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 6)
            Corner.Parent = DropFrame
            
            local MainBtn = Instance.new("TextButton")
            MainBtn.Parent = DropFrame
            MainBtn.BackgroundTransparency = 1
            MainBtn.Size = UDim2.new(1, 0, 0, 32)
            MainBtn.Text = ""
            
            local Label = Instance.new("TextLabel")
            Label.Parent = MainBtn
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = ElementConfig.Name .. " (" .. (ElementConfig.CurrentOption or "None") .. ")"
            Label.TextColor3 = Theme.TextColor
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local DropIcon = Instance.new("TextLabel")
            DropIcon.Parent = MainBtn
            DropIcon.BackgroundTransparency = 1
            DropIcon.Position = UDim2.new(1, -30, 0, 0)
            DropIcon.Size = UDim2.new(0, 20, 1, 0)
            DropIcon.Font = Enum.Font.Gotham
            DropIcon.Text = "▽"
            DropIcon.TextColor3 = Theme.SubTextColor
            DropIcon.TextSize = 12
            
            local OptionsHolder = Instance.new("Frame")
            OptionsHolder.Parent = DropFrame
            OptionsHolder.BackgroundTransparency = 1
            OptionsHolder.Position = UDim2.new(0, 5, 0, 35)
            OptionsHolder.Size = UDim2.new(1, -10, 0, #ElementConfig.Options * 25)
            
            local OptList = Instance.new("UIListLayout")
            OptList.Parent = OptionsHolder
            OptList.SortOrder = Enum.SortOrder.LayoutOrder
            OptList.Padding = UDim.new(0, 3)
            
            local Opened = false
            MainBtn.MouseButton1Click:Connect(function()
                Opened = not Opened
                local TargetHeight = Opened and (35 + #ElementConfig.Options * 28) or 32
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
            end)
            
            for _, opt in pairs(ElementConfig.Options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Parent = OptionsHolder
                OptBtn.BackgroundColor3 = Theme.MainBackground
                OptBtn.Size = UDim2.new(1, 0, 0, 25)
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.Text = opt
                OptBtn.TextColor3 = Theme.SubTextColor
                OptBtn.TextSize = 12
                OptBtn.AutoButtonColor = false
                
                local BC = Instance.new("UICorner")
                BC.CornerRadius = UDim.new(0, 4)
                BC.Parent = OptBtn
                
                OptBtn.MouseButton1Click:Connect(function()
                    Label.Text = ElementConfig.Name .. " (" .. opt .. ")"
                    Opened = false
                    TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 32)}):Play()
                    if ElementConfig.Callback then ElementConfig.Callback(opt) end
                end)
            end
        end

        function TabObj:CreateSection(Name)
            local SecFrame = Instance.new("Frame")
            SecFrame.Parent = Page
            SecFrame.BackgroundTransparency = 1
            SecFrame.Size = UDim2.new(1, 0, 0, 20)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = SecFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.Size = UDim2.new(1, -10, 1, 0)
            Label.Font = Enum.Font.GothamBold
            Label.Text = Name:upper()
            Label.TextColor3 = Theme.AccentColor
            Label.TextSize = 10
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function TabObj:CreateLabel(Text)
            local LblFrame = Instance.new("Frame")
            LblFrame.Parent = Page
            LblFrame.BackgroundTransparency = 1
            LblFrame.Size = UDim2.new(1, 0, 0, 18)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = LblFrame
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Font = Enum.Font.Gotham
            Label.Text = Text
            Label.TextColor3 = Theme.SubTextColor
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end
    
    function Window:Notify(NotifyConfig)
        local Type = NotifyConfig.Type or "Notification"
        local Title = NotifyConfig.Title or "System"
        local Content = NotifyConfig.Content or ""
        local Duration = NotifyConfig.Duration or 5
        local Icon = Icons[Type] or Icons.Notification
        
        local TypeColors = {
            Done = Color3.fromRGB(100, 255, 100),
            Error = Color3.fromRGB(255, 80, 80),
            Warning = Color3.fromRGB(255, 200, 50),
            Notification = Theme.AccentColor
        }
        local IconColor = TypeColors[Type] or TypeColors.Notification
        
        local Note = Instance.new("Frame")
        Note.Parent = ScreenGui
        Note.BackgroundColor3 = Theme.MainBackground
        Note.BackgroundTransparency = 0.05
        Note.Position = UDim2.new(1, 25, 1, -100)
        Note.Size = UDim2.new(0, 250, 0, 70)
        
        local NoteCorner = Instance.new("UICorner")
        NoteCorner.CornerRadius = UDim.new(0, 6)
        NoteCorner.Parent = Note
        
        local NoteStroke = Instance.new("UIStroke")
        NoteStroke.Color = IconColor
        NoteStroke.Thickness = 1.5
        NoteStroke.Transparency = 0.5
        NoteStroke.Parent = Note
        
        local NoteIcon = Instance.new("ImageLabel")
        NoteIcon.Parent = Note
        NoteIcon.BackgroundTransparency = 1
        NoteIcon.Position = UDim2.new(0, 12, 0, 12)
        NoteIcon.Size = UDim2.new(0, 20, 0, 20)
        NoteIcon.Image = Icon
        NoteIcon.ImageColor3 = IconColor
        
        local NoteTitle = Instance.new("TextLabel")
        NoteTitle.Parent = Note
        NoteTitle.BackgroundTransparency = 1
        NoteTitle.Position = UDim2.new(0, 42, 0, 12)
        NoteTitle.Size = UDim2.new(1, -52, 0, 20)
        NoteTitle.Font = Enum.Font.GothamBold
        NoteTitle.Text = Title
        NoteTitle.TextColor3 = Theme.TextColor
        NoteTitle.TextSize = 13
        NoteTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local NoteContent = Instance.new("TextLabel")
        NoteContent.Parent = Note
        NoteContent.BackgroundTransparency = 1
        NoteContent.Position = UDim2.new(0, 42, 0, 32)
        NoteContent.Size = UDim2.new(1, -52, 0, 30)
        NoteContent.Font = Enum.Font.Gotham
        NoteContent.Text = Content
        NoteContent.TextColor3 = Theme.SubTextColor
        NoteContent.TextSize = 12
        NoteContent.TextWrapped = true
        NoteContent.TextXAlignment = Enum.TextXAlignment.Left
        NoteContent.TextYAlignment = Enum.TextYAlignment.Top
        
        TweenService:Create(Note, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 1, -100)}):Play()
        
        task.delay(Duration, function()
            TweenService:Create(Note, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 25, 1, -100)}):Play()
            task.wait(0.6)
            Note:Destroy()
        end)
    end
    
    return Window
end

return Aetherius
