--[[
    Aetherius UI Library
    "Midnight Theme" - Sleek, Modern, and Performance-driven.
    Inspired by Rayfield.
    
    Usage:
        local Aetherius = loadstring(game:HttpGet("https://raw.githubusercontent.com/jodta/Aetherius-UI/refs/heads/main/Aetherius.lua"))()
        local Window = Aetherius:CreateWindow({ Name = "My Script" })
        local Tab = Window:CreateTab("Main")
        Tab:CreateButton({ Name = "Click Me", Callback = function() print("clicked") end })
        Window:Notify({ Title = "Ready", Content = "Script loaded.", Type = "Done" })
]]

local Aetherius = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Themes = {
    Midnight = {
        MainBackground   = Color3.fromRGB(15, 15, 20),
        SidebarBackground = Color3.fromRGB(12, 12, 16),
        ElementBackground = Color3.fromRGB(25, 25, 30),
        BorderColor      = Color3.fromRGB(40, 40, 50),
        TextColor        = Color3.fromRGB(240, 240, 245),
        SubTextColor     = Color3.fromRGB(180, 180, 190),
        AccentColor      = Color3.fromRGB(80, 120, 255),
        HoverColor       = Color3.fromRGB(35, 35, 45),
        Transparency     = 0.15,
    }
}

-- Notification icons using known-valid rbxassetids
local Icons = {
    Done         = "rbxassetid://3944703564",
    Error        = "rbxassetid://3944706530",
    Warning      = "rbxassetid://3944703830",
    Notification = "rbxassetid://3944703716",
}

local NotifyColors = {
    Done         = Color3.fromRGB(100, 220, 100),
    Error        = Color3.fromRGB(255, 80,  80),
    Warning      = Color3.fromRGB(255, 200, 50),
    Notification = Color3.fromRGB(80,  120, 255),
}

-- Safe ScreenGui parent: tries CoreGui, falls back to PlayerGui
local function GetScreenGuiParent()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Draggability helper
local function MakeDraggable(Frame, DragPart)
    local dragging, dragInput, dragStart, startPos

    DragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = Frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    DragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════════════════════════════════════════
--  CreateWindow
-- ══════════════════════════════════════════
function Aetherius:CreateWindow(Config)
    Config = Config or {}
    local WindowName = Config.Name or "Aetherius UI"
    local Theme      = Themes.Midnight

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name          = "Aetherius_" .. tostring(math.random(1000, 9999))
    ScreenGui.ResetOnSpawn  = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent        = GetScreenGuiParent()

    -- Main frame
    local Main = Instance.new("Frame")
    Main.Name                = "Main"
    Main.Parent              = ScreenGui
    Main.BackgroundColor3    = Theme.MainBackground
    Main.BackgroundTransparency = Theme.Transparency
    Main.BorderSizePixel     = 0
    Main.Position            = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size                = UDim2.new(0, 500, 0, 350)
    Main.ClipsDescendants    = true

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color     = Theme.BorderColor
    MainStroke.Thickness = 1.2

    -- Title bar
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Name                = "TitleBar"
    TitleBar.BackgroundColor3    = Theme.SidebarBackground
    TitleBar.BackgroundTransparency = 0.6
    TitleBar.BorderSizePixel     = 0
    TitleBar.Size                = UDim2.new(1, 0, 0, 35)

    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size     = UDim2.new(1, -50, 1, 0)
    TitleLabel.Font     = Enum.Font.GothamMedium
    TitleLabel.Text     = WindowName
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.TextSize   = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimize button
    local MinBtn = Instance.new("TextButton", TitleBar)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Position  = UDim2.new(1, -55, 0, 5)
    MinBtn.Size      = UDim2.new(0, 22, 0, 22)
    MinBtn.Font      = Enum.Font.GothamBold
    MinBtn.Text      = "−"
    MinBtn.TextColor3 = Theme.SubTextColor
    MinBtn.TextSize  = 18

    -- Close button
    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position  = UDim2.new(1, -28, 0, 5)
    CloseBtn.Size      = UDim2.new(0, 22, 0, 22)
    CloseBtn.Font      = Enum.Font.GothamBold
    CloseBtn.Text      = "×"
    CloseBtn.TextColor3 = Theme.TextColor
    CloseBtn.TextSize  = 20

    local minimized = false
    local contentFrame -- forward ref; defined below

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    MakeDraggable(Main, TitleBar)

    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Name              = "Sidebar"
    Sidebar.BackgroundColor3  = Theme.SidebarBackground
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel   = 0
    Sidebar.Position          = UDim2.new(0, 0, 0, 35)
    Sidebar.Size              = UDim2.new(0, 140, 1, -35)

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Name                  = "TabContainer"
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel       = 0
    TabContainer.Position              = UDim2.new(0, 0, 0, 8)
    TabContainer.Size                  = UDim2.new(1, 0, 1, -16)
    TabContainer.CanvasSize            = UDim2.new(0, 0, 0, 0)
    TabContainer.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    TabContainer.ScrollBarThickness    = 0

    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding   = UDim.new(0, 4)

    local TabPadding = Instance.new("UIPadding", TabContainer)
    TabPadding.PaddingLeft  = UDim.new(0, 6)
    TabPadding.PaddingRight = UDim.new(0, 6)

    -- Page container
    local PageContainer = Instance.new("Frame", Main)
    PageContainer.Name                = "PageContainer"
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position            = UDim2.new(0, 148, 0, 43)
    PageContainer.Size                = UDim2.new(1, -158, 1, -53)

    -- Divider line between sidebar & content
    local Divider = Instance.new("Frame", Main)
    Divider.BackgroundColor3    = Theme.BorderColor
    Divider.BorderSizePixel     = 0
    Divider.Position            = UDim2.new(0, 140, 0, 35)
    Divider.Size                = UDim2.new(0, 1, 1, -35)

    -- Minimize behaviour
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 500, 0, 35) or UDim2.new(0, 500, 0, 350)
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)

    -- ══════════════════════════════════════
    --  Window object (returned to caller)
    -- ══════════════════════════════════════
    local Window = {
        Tabs      = {},
        ActiveTab = nil,
        ScreenGui = ScreenGui,
    }

    -- ── CreateTab ──────────────────────────
    function Window:CreateTab(TabName)
        local TabButton = Instance.new("TextButton", TabContainer)
        TabButton.Name                = TabName .. "_Tab"
        TabButton.BackgroundColor3    = Theme.ElementBackground
        TabButton.BackgroundTransparency = 1
        TabButton.Size                = UDim2.new(1, 0, 0, 30)
        TabButton.Font                = Enum.Font.Gotham
        TabButton.Text                = "  " .. TabName
        TabButton.TextColor3          = Theme.SubTextColor
        TabButton.TextSize            = 13
        TabButton.TextXAlignment      = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor     = false

        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 5)

        -- Tab page (scrolling)
        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Name                  = TabName .. "_Page"
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel        = 0
        Page.Size                   = UDim2.new(1, 0, 1, 0)
        Page.Visible                = false
        Page.ScrollBarThickness     = 2
        Page.ScrollBarImageColor3   = Theme.AccentColor
        Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y

        local PageList = Instance.new("UIListLayout", Page)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList.Padding   = UDim.new(0, 6)

        local PagePad = Instance.new("UIPadding", Page)
        PagePad.PaddingTop    = UDim.new(0, 4)
        PagePad.PaddingBottom = UDim.new(0, 8)

        -- Tab object
        local TabObj = {
            Name   = TabName,
            Page   = Page,
            Button = TabButton,
        }

        -- Switch tab
        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.25), {
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.SubTextColor,
                }):Play()
            end
            Page.Visible = true
            Window.ActiveTab = TabObj
            TweenService:Create(TabButton, TweenInfo.new(0.25), {
                BackgroundTransparency = 0.75,
                TextColor3 = Theme.TextColor,
            }):Play()
        end)

        table.insert(Window.Tabs, TabObj)

        -- Auto-select first tab
        if #Window.Tabs == 1 then
            Page.Visible                     = true
            TabButton.BackgroundTransparency  = 0.75
            TabButton.TextColor3              = Theme.TextColor
            Window.ActiveTab                  = TabObj
        end

        -- ── CreateButton ──────────────────
        function TabObj:CreateButton(cfg)
            cfg = cfg or {}
            local f = Instance.new("TextButton", Page)
            f.Name                = (cfg.Name or "Button") .. "_Btn"
            f.BackgroundColor3    = Theme.ElementBackground
            f.Size                = UDim2.new(1, 0, 0, 32)
            f.Text                = ""
            f.AutoButtonColor     = false
            f.BorderSizePixel     = 0
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Position  = UDim2.new(0, 12, 0, 0)
            lbl.Size      = UDim2.new(1, -24, 1, 0)
            lbl.Font      = Enum.Font.Gotham
            lbl.Text      = cfg.Name or "Button"
            lbl.TextColor3 = Theme.TextColor
            lbl.TextSize  = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            f.MouseEnter:Connect(function()
                TweenService:Create(f, TweenInfo.new(0.18), {BackgroundColor3 = Theme.HoverColor}):Play()
            end)
            f.MouseLeave:Connect(function()
                TweenService:Create(f, TweenInfo.new(0.18), {BackgroundColor3 = Theme.ElementBackground}):Play()
            end)
            f.MouseButton1Click:Connect(function()
                if cfg.Callback then cfg.Callback() end
            end)
        end

        -- ── CreateToggle ──────────────────
        function TabObj:CreateToggle(cfg)
            cfg = cfg or {}
            local f = Instance.new("TextButton", Page)
            f.Name                = (cfg.Name or "Toggle") .. "_Tgl"
            f.BackgroundColor3    = Theme.ElementBackground
            f.Size                = UDim2.new(1, 0, 0, 32)
            f.Text                = ""
            f.AutoButtonColor     = false
            f.BorderSizePixel     = 0
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Position  = UDim2.new(0, 12, 0, 0)
            lbl.Size      = UDim2.new(1, -52, 1, 0)
            lbl.Font      = Enum.Font.Gotham
            lbl.Text      = cfg.Name or "Toggle"
            lbl.TextColor3 = Theme.TextColor
            lbl.TextSize  = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local track = Instance.new("Frame", f)
            track.AnchorPoint      = Vector2.new(1, 0.5)
            track.BackgroundColor3 = Theme.MainBackground
            track.BorderSizePixel  = 0
            track.Position         = UDim2.new(1, -10, 0.5, 0)
            track.Size             = UDim2.new(0, 32, 0, 18)
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local dot = Instance.new("Frame", track)
            dot.AnchorPoint      = Vector2.new(0, 0.5)
            dot.BackgroundColor3 = Theme.SubTextColor
            dot.BorderSizePixel  = 0
            dot.Position         = UDim2.new(0, 3, 0.5, 0)
            dot.Size             = UDim2.new(0, 12, 0, 12)
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local toggled = (cfg.CurrentValue == true)

            local function refresh()
                if toggled then
                    TweenService:Create(dot,   TweenInfo.new(0.2), {Position = UDim2.new(1, -15, 0.5, 0), BackgroundColor3 = Theme.AccentColor}):Play()
                    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Theme.HoverColor}):Play()
                else
                    TweenService:Create(dot,   TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Theme.SubTextColor}):Play()
                    TweenService:Create(track, TweenInfo.new(0.2), {BackgroundColor3 = Theme.MainBackground}):Play()
                end
            end

            refresh()

            f.MouseButton1Click:Connect(function()
                toggled = not toggled
                refresh()
                if cfg.Callback then cfg.Callback(toggled) end
            end)
        end

        -- ── CreateSlider ──────────────────
        function TabObj:CreateSlider(cfg)
            cfg = cfg or {}
            local min = (cfg.Range and cfg.Range[1]) or 0
            local max = (cfg.Range and cfg.Range[2]) or 100
            local inc = cfg.Increment or 1
            local cur = cfg.CurrentValue or min

            local f = Instance.new("Frame", Page)
            f.Name             = (cfg.Name or "Slider") .. "_Sld"
            f.BackgroundColor3 = Theme.ElementBackground
            f.BorderSizePixel  = 0
            f.Size             = UDim2.new(1, 0, 0, 48)
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

            local nameLbl = Instance.new("TextLabel", f)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Position  = UDim2.new(0, 12, 0, 6)
            nameLbl.Size      = UDim2.new(1, -80, 0, 18)
            nameLbl.Font      = Enum.Font.Gotham
            nameLbl.Text      = cfg.Name or "Slider"
            nameLbl.TextColor3 = Theme.TextColor
            nameLbl.TextSize  = 13
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel", f)
            valLbl.BackgroundTransparency = 1
            valLbl.Position  = UDim2.new(1, -70, 0, 6)
            valLbl.Size      = UDim2.new(0, 58, 0, 18)
            valLbl.Font      = Enum.Font.GothamMedium
            valLbl.Text      = tostring(cur)
            valLbl.TextColor3 = Theme.AccentColor
            valLbl.TextSize  = 13
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            local track = Instance.new("TextButton", f)
            track.BackgroundColor3 = Theme.MainBackground
            track.BorderSizePixel  = 0
            track.Position = UDim2.new(0, 12, 0, 32)
            track.Size     = UDim2.new(1, -24, 0, 7)
            track.Text     = ""
            track.AutoButtonColor = false
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame", track)
            fill.BackgroundColor3 = Theme.AccentColor
            fill.BorderSizePixel  = 0
            fill.Size = UDim2.new(0, 0, 1, 0)
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local function setVal(v)
                v = math.clamp(math.round(v / inc) * inc, min, max)
                cur = v
                local pct = (cur - min) / (max - min)
                fill.Size    = UDim2.new(pct, 0, 1, 0)
                valLbl.Text   = tostring(cur)
            end

            setVal(cur) -- display initial position; no callback on init

            local function calcFromMouse(x)
                local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local newVal = min + (max - min) * pct
                local prev = cur
                setVal(newVal)
                if cur ~= prev and cfg.Callback then
                    cfg.Callback(cur)
                end
            end

            local dragging = false
            track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or
                   i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    calcFromMouse(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or
                   i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or
                                 i.UserInputType == Enum.UserInputType.Touch) then
                    calcFromMouse(i.Position.X)
                end
            end)
        end

        -- ── CreateDropdown ────────────────
        function TabObj:CreateDropdown(cfg)
            cfg = cfg or {}
            local options = cfg.Options or {}

            local wrapper = Instance.new("Frame", Page)
            wrapper.Name             = (cfg.Name or "Dropdown") .. "_Drop"
            wrapper.BackgroundTransparency = 1
            wrapper.BorderSizePixel  = 0
            wrapper.Size             = UDim2.new(1, 0, 0, 32)
            wrapper.ClipsDescendants = false

            local f = Instance.new("Frame", wrapper)
            f.BackgroundColor3 = Theme.ElementBackground
            f.BorderSizePixel  = 0
            f.Size             = UDim2.new(1, 0, 0, 32)
            f.ClipsDescendants = true
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

            local mainBtn = Instance.new("TextButton", f)
            mainBtn.BackgroundTransparency = 1
            mainBtn.Size   = UDim2.new(1, 0, 0, 32)
            mainBtn.Text   = ""
            mainBtn.ZIndex = 2

            local lbl = Instance.new("TextLabel", mainBtn)
            lbl.BackgroundTransparency = 1
            lbl.Position  = UDim2.new(0, 12, 0, 0)
            lbl.Size      = UDim2.new(1, -44, 1, 0)
            lbl.Font      = Enum.Font.Gotham
            lbl.Text      = (cfg.Name or "Dropdown") .. "  ▾"
            lbl.TextColor3 = Theme.TextColor
            lbl.TextSize  = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local selected = cfg.CurrentOption or (options[1] or "None")
            lbl.Text = (cfg.Name or "Dropdown") .. "  " .. selected .. "  ▾"

            local optHolder = Instance.new("Frame", f)
            optHolder.BackgroundTransparency = 1
            optHolder.BorderSizePixel = 0
            optHolder.Position = UDim2.new(0, 0, 0, 32)
            optHolder.Size     = UDim2.new(1, 0, 0, #options * 28)

            local ol = Instance.new("UIListLayout", optHolder)
            ol.SortOrder = Enum.SortOrder.LayoutOrder
            ol.Padding   = UDim.new(0, 2)

            local op = Instance.new("UIPadding", optHolder)
            op.PaddingLeft   = UDim.new(0, 4)
            op.PaddingRight  = UDim.new(0, 4)
            op.PaddingTop    = UDim.new(0, 4)

            for _, opt in ipairs(options) do
                local ob = Instance.new("TextButton", optHolder)
                ob.BackgroundColor3 = Theme.HoverColor
                ob.BorderSizePixel  = 0
                ob.Size             = UDim2.new(1, 0, 0, 24)
                ob.Font             = Enum.Font.Gotham
                ob.Text             = opt
                ob.TextColor3       = Theme.SubTextColor
                ob.TextSize         = 12
                ob.AutoButtonColor  = false
                Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)

                ob.MouseEnter:Connect(function()
                    TweenService:Create(ob, TweenInfo.new(0.15), {TextColor3 = Theme.TextColor}):Play()
                end)
                ob.MouseLeave:Connect(function()
                    TweenService:Create(ob, TweenInfo.new(0.15), {TextColor3 = Theme.SubTextColor}):Play()
                end)
                ob.MouseButton1Click:Connect(function()
                    selected = opt
                    lbl.Text = (cfg.Name or "Dropdown") .. "  " .. opt .. "  ▾"
                    -- close
                    local closedH = 32
                    TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, closedH)}):Play()
                    TweenService:Create(wrapper, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, closedH)}):Play()
                    f.ClipsDescendants = true
                    if cfg.Callback then cfg.Callback(opt) end
                end)
            end

            local opened = false
            mainBtn.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    local fullH = 32 + 4 + #options * 28
                    f.ClipsDescendants = false
                    TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, fullH)}):Play()
                    TweenService:Create(wrapper, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, fullH)}):Play()
                else
                    TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 32)}):Play()
                    TweenService:Create(wrapper, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 32)}):Play()
                    task.delay(0.25, function() f.ClipsDescendants = true end)
                end
            end)
        end

        -- ── CreateSection ─────────────────
        function TabObj:CreateSection(name)
            local f = Instance.new("Frame", Page)
            f.BackgroundTransparency = 1
            f.BorderSizePixel = 0
            f.Size = UDim2.new(1, 0, 0, 22)

            local line = Instance.new("Frame", f)
            line.BackgroundColor3    = Theme.BorderColor
            line.BorderSizePixel     = 0
            line.AnchorPoint         = Vector2.new(0, 0.5)
            line.Position            = UDim2.new(0, 0, 0.5, 0)
            line.Size                = UDim2.new(1, 0, 0, 1)

            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundColor3       = Theme.MainBackground
            lbl.BackgroundTransparency = Theme.Transparency
            lbl.BorderSizePixel        = 0
            lbl.AnchorPoint            = Vector2.new(0, 0.5)
            lbl.Position               = UDim2.new(0, 0, 0.5, 0)
            lbl.Size                   = UDim2.new(0, 0, 1, 0)
            lbl.AutomaticSize          = Enum.AutomaticSize.X
            lbl.Font                   = Enum.Font.GothamBold
            lbl.Text                   = "  " .. (name or ""):upper() .. "  "
            lbl.TextColor3             = Theme.AccentColor
            lbl.TextSize               = 10
        end

        -- ── CreateLabel ───────────────────
        function TabObj:CreateLabel(text)
            local f = Instance.new("Frame", Page)
            f.BackgroundTransparency = 1
            f.BorderSizePixel = 0
            f.Size = UDim2.new(1, 0, 0, 20)

            local lbl = Instance.new("TextLabel", f)
            lbl.BackgroundTransparency = 1
            lbl.Position  = UDim2.new(0, 12, 0, 0)
            lbl.Size      = UDim2.new(1, -24, 1, 0)
            lbl.Font      = Enum.Font.Gotham
            lbl.Text      = text or ""
            lbl.TextColor3 = Theme.SubTextColor
            lbl.TextSize  = 12
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end

        -- ── CreateParagraph ───────────────
        function TabObj:CreateParagraph(cfg)
            cfg = cfg or {}
            local f = Instance.new("Frame", Page)
            f.BackgroundColor3 = Theme.ElementBackground
            f.BorderSizePixel  = 0
            f.AutomaticSize    = Enum.AutomaticSize.Y
            f.Size             = UDim2.new(1, 0, 0, 0)
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

            local pad = Instance.new("UIPadding", f)
            pad.PaddingLeft   = UDim.new(0, 12)
            pad.PaddingRight  = UDim.new(0, 12)
            pad.PaddingTop    = UDim.new(0, 8)
            pad.PaddingBottom = UDim.new(0, 8)

            local ll = Instance.new("UIListLayout", f)
            ll.SortOrder = Enum.SortOrder.LayoutOrder
            ll.Padding   = UDim.new(0, 4)

            if cfg.Title and cfg.Title ~= "" then
                local t = Instance.new("TextLabel", f)
                t.BackgroundTransparency = 1
                t.AutomaticSize = Enum.AutomaticSize.Y
                t.Size          = UDim2.new(1, 0, 0, 0)
                t.Font          = Enum.Font.GothamBold
                t.Text          = cfg.Title
                t.TextColor3    = Theme.TextColor
                t.TextSize      = 13
                t.TextWrapped   = true
                t.TextXAlignment = Enum.TextXAlignment.Left
            end

            local c = Instance.new("TextLabel", f)
            c.BackgroundTransparency = 1
            c.AutomaticSize = Enum.AutomaticSize.Y
            c.Size          = UDim2.new(1, 0, 0, 0)
            c.Font          = Enum.Font.Gotham
            c.Text          = cfg.Content or ""
            c.TextColor3    = Theme.SubTextColor
            c.TextSize      = 12
            c.TextWrapped   = true
            c.TextXAlignment = Enum.TextXAlignment.Left
        end

        return TabObj
    end -- end Window:CreateTab

    -- ── Notify ────────────────────────────
    function Window:Notify(cfg)
        cfg = cfg or {}
        local nType    = cfg.Type     or "Notification"
        local title    = cfg.Title    or "System"
        local content  = cfg.Content  or ""
        local duration = cfg.Duration or 5
        local icon     = Icons[nType]     or Icons.Notification
        local iColor   = NotifyColors[nType] or NotifyColors.Notification

        local note = Instance.new("Frame", ScreenGui)
        note.BackgroundColor3    = Theme.MainBackground
        note.BackgroundTransparency = 0.05
        note.BorderSizePixel     = 0
        note.Position            = UDim2.new(1, 25, 1, -110)
        note.Size                = UDim2.new(0, 260, 0, 70)
        note.ZIndex              = 10
        Instance.new("UICorner", note).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", note)
        stroke.Color       = iColor
        stroke.Thickness   = 1.5
        stroke.Transparency = 0.4

        -- Coloured left accent bar
        local bar = Instance.new("Frame", note)
        bar.BackgroundColor3 = iColor
        bar.BorderSizePixel  = 0
        bar.Position         = UDim2.new(0, 0, 0, 0)
        bar.Size             = UDim2.new(0, 3, 1, 0)
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)

        local ico = Instance.new("ImageLabel", note)
        ico.BackgroundTransparency = 1
        ico.Position    = UDim2.new(0, 14, 0, 12)
        ico.Size        = UDim2.new(0, 20, 0, 20)
        ico.Image       = icon
        ico.ImageColor3 = iColor
        ico.ZIndex      = 11

        local titleLbl = Instance.new("TextLabel", note)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Position  = UDim2.new(0, 44, 0, 10)
        titleLbl.Size      = UDim2.new(1, -56, 0, 20)
        titleLbl.Font      = Enum.Font.GothamBold
        titleLbl.Text      = title
        titleLbl.TextColor3 = Theme.TextColor
        titleLbl.TextSize  = 13
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex    = 11

        local contentLbl = Instance.new("TextLabel", note)
        contentLbl.BackgroundTransparency = 1
        contentLbl.Position  = UDim2.new(0, 44, 0, 30)
        contentLbl.Size      = UDim2.new(1, -56, 0, 32)
        contentLbl.Font      = Enum.Font.Gotham
        contentLbl.Text      = content
        contentLbl.TextColor3 = Theme.SubTextColor
        contentLbl.TextSize  = 12
        contentLbl.TextWrapped = true
        contentLbl.TextXAlignment = Enum.TextXAlignment.Left
        contentLbl.TextYAlignment = Enum.TextYAlignment.Top
        contentLbl.ZIndex    = 11

        -- Slide in
        TweenService:Create(note, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -280, 1, -110)
        }):Play()

        task.delay(duration, function()
            if note and note.Parent then
                TweenService:Create(note, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(1, 25, 1, -110)
                }):Play()
                task.wait(0.5)
                if note and note.Parent then note:Destroy() end
            end
        end)
    end

    return Window
end -- end Aetherius:CreateWindow

return Aetherius
