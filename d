---- Made by giga nigga Ryoichi and if you are reading this you like fat dick
----
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HS = game:GetService("HttpService")
local RS = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")


local UI = {}

UI.Theme = {
	Accent = Color3.fromRGB(170,0,255),
	Card = Color3.fromRGB(50,50,50),
	Hover = Color3.fromRGB(70,70,70),
	Text = Color3.new(1,1,1)
}

function UI.Tween(obj,time,props)
	TS:Create(obj,TweenInfo.new(time,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end

function UI.CreateCard(parent,height)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,200,0,height or 28)
	frame.BackgroundColor3 = UI.Theme.Card
	frame.Parent = parent
	Instance.new("UICorner",frame)

	frame.MouseEnter:Connect(function()
		UI.Tween(frame,0.15,{BackgroundColor3 = UI.Theme.Hover})
	end)

	frame.MouseLeave:Connect(function()
		UI.Tween(frame,0.15,{BackgroundColor3 = UI.Theme.Card})
	end)

	return frame
end

local function makeBarInteractable(targets, bar, updateFromPercent)
	local dragging = false
	local trackedTargets = {}

	local hitbox = bar:FindFirstChild("InputHitbox")
	if not hitbox then
		hitbox = Instance.new("TextButton")
		hitbox.Name = "InputHitbox"
		hitbox.BackgroundTransparency = 1
		hitbox.Text = ""
		hitbox.AutoButtonColor = false
		hitbox.Size = UDim2.new(1,0,0,20)
		hitbox.AnchorPoint = Vector2.new(0,0.5)
		hitbox.Position = UDim2.new(0,0,0.5,0)
		hitbox.ZIndex = math.max(bar.ZIndex + 3, 10)
		hitbox.Parent = bar
	end

	local function applyFromPosition(position)
		local percent = math.clamp(
			(position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1),
			0,1
		)
		updateFromPercent(percent)
	end

	local function beginDrag(input)
		dragging = true
		applyFromPosition(input.Position)
	end

	table.insert(trackedTargets, hitbox)
	for _,target in ipairs(targets) do
		table.insert(trackedTargets, target)
	end

	for _,target in ipairs(trackedTargets) do
		if target and target:IsA("GuiObject") then
			target.Active = true
			target.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					beginDrag(input)
				end
			end)

			target.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
		end
	end

	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			applyFromPosition(input.Position)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function bindAimStyleToggle(frame, toggleCallback)
	if not frame or frame:FindFirstChild("AimToggleOverlay") then return end

	local overlay = Instance.new("TextButton")
	overlay.Name = "AimToggleOverlay"
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.Size = UDim2.new(1,0,1,0)
	overlay.ZIndex = math.max(frame.ZIndex + 4, 10)
	overlay.Parent = frame

	overlay.MouseButton1Click:Connect(function()
		toggleCallback()
	end)
end


function UI.CreateDropdown(parent,title)

	local open = false
	local headerHeight = 28

	local frame = UI.CreateCard(parent,headerHeight)
	frame.ClipsDescendants = true
	frame.AutomaticSize = Enum.AutomaticSize.Y

	local frameLayout = Instance.new("UIListLayout")
	frameLayout.Padding = UDim.new(0,4)
	frameLayout.SortOrder = Enum.SortOrder.LayoutOrder
	frameLayout.Parent = frame

	local button = Instance.new("TextButton")
	button.Name = title.."Button"
	button.Size = UDim2.new(1,0,0,headerHeight)
	button.BackgroundTransparency = 1
	button.Text = title.." ▶"
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.TextColor3 = UI.Theme.Text
	button.LayoutOrder = 1
	button.Parent = frame

	local container = Instance.new("Frame")
	container.Name = title.."Container"
	container.Size = UDim2.new(1,0,0,0)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.Visible = false
	container.LayoutOrder = 2
	container.AutomaticSize = Enum.AutomaticSize.None
	container.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = container

	local function syncOpenHeight()
		if open then
			container.AutomaticSize = Enum.AutomaticSize.None
			container.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y)
			container.AutomaticSize = Enum.AutomaticSize.Y
		end
	end

	local function setOpenState(state)
		open = state
		button.Text = title..(open and " ▼" or " ▶")
		if open then
			container.Visible = true
			syncOpenHeight()
		else
			container.AutomaticSize = Enum.AutomaticSize.None
			container.Size = UDim2.new(1,0,0,0)
			container.Visible = false
		end
	end

	button.MouseButton1Click:Connect(function()
		setOpenState(not open)
	end)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		task.defer(syncOpenHeight)
	end)

	container.ChildAdded:Connect(function(child)
		if child ~= layout then
			task.defer(syncOpenHeight)
		end
	end)

	container.ChildRemoved:Connect(function()
		task.defer(syncOpenHeight)
	end)

	setOpenState(false)

	return container

end



local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local configFile = "ryoichi_config.json"
local config = {}
if isfile(configFile) then
    config = HS:JSONDecode(readfile(configFile))
end
local function SaveConfig()
    writefile(configFile, HS:JSONEncode(config))
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Ryoichiware"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 999999 -- makes it draw above almost everything
gui.Parent = PlayerGui

-- BLUR EFFECT
local loaderBlur = Lighting:FindFirstChildOfClass("BlurEffect")
if not loaderBlur then
    loaderBlur = Instance.new("BlurEffect")
    loaderBlur.Size = 0
    loaderBlur.Parent = Lighting
else
    loaderBlur.Size = 0
end

-- WINDOW
local window = Instance.new("Frame")
window.Size = UDim2.new(0,620,0,405)
window.Position = UDim2.new(0,300,0,200)
window.BackgroundColor3 = Color3.fromRGB(28,28,34)
window.BackgroundTransparency = 0.2
window.ZIndex = 1
window.Visible = false
window.Parent = gui
Instance.new("UICorner", window)

local loadingOverlay = Instance.new("Frame")
loadingOverlay.Name = "LoadingOverlay"
loadingOverlay.Size = UDim2.new(1,0,1,0)
loadingOverlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
loadingOverlay.BackgroundTransparency = 0.35
loadingOverlay.BorderSizePixel = 0
loadingOverlay.ZIndex = 3000
loadingOverlay.Parent = gui

local loadingBlocker = Instance.new("TextButton")
loadingBlocker.Name = "InputBlocker"
loadingBlocker.Size = UDim2.new(1,0,1,0)
loadingBlocker.BackgroundTransparency = 1
loadingBlocker.Text = ""
loadingBlocker.AutoButtonColor = false
loadingBlocker.ZIndex = 3001
loadingBlocker.Parent = loadingOverlay

local loadingPanel = Instance.new("Frame")
loadingPanel.Name = "LoadingPanel"
loadingPanel.AnchorPoint = Vector2.new(0.5,0.5)
loadingPanel.Position = UDim2.new(0.5,0,0.5,0)
loadingPanel.Size = UDim2.new(0,430,0,138)
loadingPanel.BackgroundColor3 = Color3.fromRGB(18,18,22)
loadingPanel.BorderSizePixel = 0
loadingPanel.ZIndex = 3002
loadingPanel.Parent = loadingOverlay
Instance.new("UICorner", loadingPanel).CornerRadius = UDim.new(0,10)

local loadingStroke = Instance.new("UIStroke")
loadingStroke.Color = Color3.fromRGB(48,48,56)
loadingStroke.Thickness = 1
loadingStroke.Transparency = 0.15
loadingStroke.Parent = loadingPanel

local loadingTitle = Instance.new("TextLabel")
loadingTitle.BackgroundTransparency = 1
loadingTitle.Position = UDim2.new(0,18,0,16)
loadingTitle.Size = UDim2.new(1,-36,0,22)
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.Text = "Ryoichiware.exe"
loadingTitle.TextColor3 = Color3.new(1,1,1)
loadingTitle.TextSize = 14
loadingTitle.TextXAlignment = Enum.TextXAlignment.Left
loadingTitle.ZIndex = 3003
loadingTitle.Parent = loadingPanel

local loadingSubtitle = Instance.new("TextLabel")
loadingSubtitle.BackgroundTransparency = 1
loadingSubtitle.Position = UDim2.new(0,18,0,40)
loadingSubtitle.Size = UDim2.new(1,-36,0,26)
loadingSubtitle.Font = Enum.Font.Gotham
loadingSubtitle.Text = "initializing modules..."
loadingSubtitle.TextColor3 = Color3.fromRGB(140,140,150)
loadingSubtitle.TextSize = 10
loadingSubtitle.TextXAlignment = Enum.TextXAlignment.Left
loadingSubtitle.TextYAlignment = Enum.TextYAlignment.Top
loadingSubtitle.ZIndex = 3003
loadingSubtitle.Parent = loadingPanel

local loadingBarBack = Instance.new("Frame")
loadingBarBack.BackgroundColor3 = Color3.fromRGB(28,28,34)
loadingBarBack.BorderSizePixel = 0
loadingBarBack.Position = UDim2.new(0,18,1,-24)
loadingBarBack.Size = UDim2.new(1,-36,0,8)
loadingBarBack.ZIndex = 3003
loadingBarBack.Parent = loadingPanel
Instance.new("UICorner", loadingBarBack).CornerRadius = UDim.new(1,0)

local loadingBarFill = Instance.new("Frame")
loadingBarFill.BackgroundColor3 = UI.Theme.Accent
loadingBarFill.BorderSizePixel = 0
loadingBarFill.Size = UDim2.new(0,0,1,0)
loadingBarFill.ZIndex = 3004
loadingBarFill.Parent = loadingBarBack
Instance.new("UICorner", loadingBarFill).CornerRadius = UDim.new(1,0)

local loadingBarGlow = Instance.new("Frame")
loadingBarGlow.BackgroundColor3 = UI.Theme.Accent
loadingBarGlow.BackgroundTransparency = 0.7
loadingBarGlow.BorderSizePixel = 0
loadingBarGlow.AnchorPoint = Vector2.new(1,0.5)
loadingBarGlow.Position = UDim2.new(0,0,0.5,0)
loadingBarGlow.Size = UDim2.new(0,24,0,14)
loadingBarGlow.ZIndex = 3005
loadingBarGlow.Parent = loadingBarFill
Instance.new("UICorner", loadingBarGlow).CornerRadius = UDim.new(1,0)

local loadingPercent = Instance.new("TextLabel")
loadingPercent.BackgroundTransparency = 1
loadingPercent.AnchorPoint = Vector2.new(1,1)
loadingPercent.Position = UDim2.new(1,-18,1,-26)
loadingPercent.Size = UDim2.new(0,52,0,16)
loadingPercent.Font = Enum.Font.GothamBold
loadingPercent.Text = "0%"
loadingPercent.TextColor3 = Color3.fromRGB(200,200,205)
loadingPercent.TextSize = 10
loadingPercent.TextXAlignment = Enum.TextXAlignment.Right
loadingPercent.ZIndex = 3004
loadingPercent.Parent = loadingPanel



local function playIntroLoader()
	if loaderBlur then
		loaderBlur.Size = 14

	end

	local duration = 3
	local startTime = tick()
	local connection

	connection = RS.RenderStepped:Connect(function()
		local alpha = math.clamp((tick() - startTime) / duration, 0, 1)
		local eased = 1 - (1 - alpha) ^ 3
		loadingBarFill.Size = UDim2.new(eased,0,1,0)
		loadingBarGlow.Position = UDim2.new(1,0,0.5,0)
		loadingPercent.Text = tostring(math.floor(eased * 100 + 0.5)).."%"
		loadingPanel.Position = UDim2.new(0.5,0,0.5,math.sin(alpha * math.pi * 2) * 2)

		if alpha >= 1 then
			connection:Disconnect()
			loadingPercent.Text = "100%"
			if loaderBlur then
				pcall(function()
					loaderBlur.Size = 0
					loaderBlur.Enabled = false
					loaderBlur:Destroy()
				end)
				loaderBlur = nil
			end
			window.Visible = true
				if uiBlur then
					uiBlur.Enabled = true
					uiBlur.Size = 0
					TS:Create(uiBlur, TweenInfo.new(0.2), {Size = 8}):Play()
				end

			local fadeInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TS:Create(loadingOverlay, fadeInfo, {BackgroundTransparency = 1}):Play()
			TS:Create(loadingPanel, fadeInfo, {BackgroundTransparency = 1, Size = UDim2.new(0,446,0,138)}):Play()
			TS:Create(loadingStroke, fadeInfo, {Transparency = 1}):Play()
			TS:Create(loadingTitle, fadeInfo, {TextTransparency = 1}):Play()
			TS:Create(loadingSubtitle, fadeInfo, {TextTransparency = 1}):Play()
			TS:Create(loadingBarBack, fadeInfo, {BackgroundTransparency = 1}):Play()
			TS:Create(loadingBarFill, fadeInfo, {BackgroundTransparency = 1}):Play()
			TS:Create(loadingBarGlow, fadeInfo, {BackgroundTransparency = 1}):Play()
			TS:Create(loadingPercent, fadeInfo, {TextTransparency = 1}):Play()

			task.delay(0.2, function()
				if loadingOverlay then
					loadingOverlay:Destroy()
				end
			end)
		end
	end)
end

playIntroLoader()


local customCursor = Instance.new("Frame")
customCursor.Size = UDim2.new(0,8,0,8)
customCursor.BackgroundColor3 = Color3.fromRGB(170,0,255)
customCursor.BorderSizePixel = 0
customCursor.Visible = false
customCursor.ZIndex = 2000
customCursor.Parent = gui

Instance.new("UICorner",customCursor)

local cursorStroke = Instance.new("UIStroke")
cursorStroke.Color = Color3.fromRGB(255,200,255)
cursorStroke.Thickness = 1
cursorStroke.Parent = customCursor
local glow = Instance.new("Frame")
glow.Size = UDim2.new(0,16,0,16)
glow.Position = UDim2.new(0,-4,0,-4)
glow.BackgroundColor3 = Color3.fromRGB(170,0,255)
glow.BackgroundTransparency = 0.8
glow.BorderSizePixel = 0
glow.ZIndex = 1999
glow.Parent = customCursor
Instance.new("UICorner",glow)


 =====================
-- PULSING WINDOW OUTLINE
-- =====================

local windowStroke = Instance.new("UIStroke")
windowStroke.Thickness = 2
windowStroke.Color = Color3.fromRGB(200,120,255)
windowStroke.Transparency = 0.4
windowStroke.Parent = window

-- animate outline pulse
task.spawn(function()
	local step = 0
	while gui.Parent do
		step += 0.03
		
		local glow = (math.sin(step*2) + 1) / 2
		
		windowStroke.Transparency = 0.35 + (0.25 * (1 - glow))
		windowStroke.Thickness = 2 + (glow * 1.2)
		
		task.wait(0.03)
	end
end)
	
local heartContainer = Instance.new("Frame")
heartContainer.Size = UDim2.new(1,0,1,0)
heartContainer.BackgroundTransparency = 1
heartContainer.ClipsDescendants = true
heartContainer.ZIndex = -1
heartContainer.Parent = window
for _,v in pairs(window:GetDescendants()) do
	if v:IsA("GuiObject") then
		v.ZIndex = 5
	end
end

local function createHeart()

	local size = math.random(14,26)

	local heart = Instance.new("ImageLabel")
	heart.Size = UDim2.new(0,size,0,size)
	heart.BackgroundTransparency = 1
	heart.Image = "rbxassetid://6031094678"
	heart.ImageColor3 = Color3.fromRGB(210,120,255)
	heart.ImageTransparency = 0.2
	heart.Rotation = math.random(-20,20)
	heart.ZIndex = 0
	heart.Parent = heartContainer

	-- RANDOM SIDE SPAWN
	local side = math.random(1,4)

	if side == 1 then -- bottom
		heart.Position = UDim2.new(math.random(),0,1,0)
	elseif side == 2 then -- top
		heart.Position = UDim2.new(math.random(),0,-0.1,0)
	elseif side == 3 then -- left
		heart.Position = UDim2.new(-0.1,0,math.random(),0)
	else -- right
		heart.Position = UDim2.new(1,0,math.random(),0)
	end

	-- FLOAT TARGET
	local targetPos = UDim2.new(
		math.random(),
		0,
		math.random(-0.2,1),
		0
	)

	-- FLOAT
	local floatTween = TS:Create(
		heart,
		TweenInfo.new(math.random(6,10), Enum.EasingStyle.Sine),
		{
			Position = targetPos,
			ImageTransparency = 1
		}
	)

	-- ROTATE
	local rotateTween = TS:Create(
		heart,
		TweenInfo.new(math.random(4,7), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
		{Rotation = heart.Rotation + math.random(60,120)}
	)

	-- PULSE
	local pulseTween = TS:Create(
		heart,
		TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Size = UDim2.new(0,size+4,0,size+4)}
	)

	floatTween:Play()
	rotateTween:Play()
	pulseTween:Play()

	floatTween.Completed:Connect(function()
		heart:Destroy()
	end)
end

-- SPAWN  LOOP
task.spawn(function()
	while gui.Parent do
		createHeart()
		task.wait(0.45)
	end
end)-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,32)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Ryoichiware.exe"
title.TextColor3 = Color3.fromRGB(170,0,255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = window

-- SUBTLE ANIMATED TITLE GLOW

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 1.5 -- thinner stroke for subtlety
titleStroke.Color = Color3.fromRGB(200, 120, 255) -- softer glow color
titleStroke.Transparency = 0.6 -- start more transparent
titleStroke.Parent = title

-- Animate the glow subtly
task.spawn(function()
	local step = 0
	while gui.Parent do
		step = step + 0.03
		local glowIntensity = (math.sin(step*2) + 1)/2 -- 0 to 1
		titleStroke.Transparency = 0.55 + 0.15 * (1 - glowIntensity) -- smaller transparency change
		title.TextColor3 = Color3.fromRGB(170 + math.floor(20 * glowIntensity), 0, 255) -- smaller color pulse
		task.wait(0.03)
	end
end)-- CONNECTION STORAGE
local connections = {}

-- CLOSE BUTTON
local close = Instance.new("TextButton")
close.Size = UDim2.new(0,20,0,20)
close.Position = UDim2.new(1,-25,0,5)
close.Text = "X"
close.BackgroundTransparency = 1
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 18
close.Font = Enum.Font.GothamBold
close.Parent = window
close.MouseButton1Click:Connect(function()
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
    if loaderBlur then TS:Create(loaderBlur, TweenInfo.new(0.25), {Size = 0}):Play() end
    gui:Destroy()
end)

-- DRAG WINDOW
do
    local dragging, dragStart, startPos = false, nil, nil
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    table.insert(connections, UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

-- RESIZE
do
    local resize = Instance.new("Frame")
    resize.Size = UDim2.new(0,16,0,16)
    resize.Position = UDim2.new(1,-16,1,-16)
    resize.BackgroundColor3 = Color3.fromRGB(170,0,255)
    resize.Parent = window
    Instance.new("UICorner", resize)
    local resizing, startSize, startMouse
    resize.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            startSize = window.Size
            startMouse = input.Position
        end
    end)
    resize.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    table.insert(connections, UIS.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            window.Size = UDim2.new(
                0, math.clamp(startSize.X.Offset + delta.X, 320, 900),
                0, math.clamp(startSize.Y.Offset + delta.Y, 220, 700)
            )
        end
    end))
end

-- TAB SYSTEM
local tabButtonFrame = Instance.new("Frame")
tabButtonFrame.Size = UDim2.new(1,-20,0,30)
tabButtonFrame.Position = UDim2.new(0,10,0,35)
tabButtonFrame.BackgroundTransparency = 1
tabButtonFrame.Parent = window

local indicator = Instance.new("Frame")
indicator.Size = UDim2.new(0,100,0,3)
indicator.Position = UDim2.new(0,0,1,-3)
indicator.BackgroundColor3 = Color3.fromRGB(170,0,255)
indicator.Parent = tabButtonFrame

local tabs = {"Main","Misc"}
local tabContents = {}
local tabButtons = {}
local activeTab

local function SwitchTab(tabName)
    if activeTab == tabName then return end
    for name,frame in pairs(tabContents) do
        frame.Visible = false
    end
    activeTab = tabName
    tabContents[tabName].Visible = true
    local btn = tabButtons[tabName]
    TS:Create(indicator, TweenInfo.new(0.2), {
        Position = UDim2.new(0,btn.Position.X.Offset,1,-3),
        Size = UDim2.new(0,btn.AbsoluteSize.X,0,3)
    }):Play()
end

for i,tabName in ipairs(tabs) do
    local content = Instance.new("ScrollingFrame")
    content.Name = tabName
    content.Size = UDim2.new(1,-20,1,-70)
    content.Position = UDim2.new(0,10,0,70)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 6
    content.Visible = false
    content.Parent = window
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new(0,0,0,0)
    tabContents[tabName] = content

    local btn = Instance.new("TextButton")
    btn.Name = tabName
    btn.Text = tabName
    btn.Size = UDim2.new(0,100,1,0)
    btn.Position = UDim2.new(0,(i-1)*105,0,0)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.fromRGB(170,0,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = tabButtonFrame
    Instance.new("UICorner",btn)
    btn.MouseButton1Click:Connect(function()
        SwitchTab(tabName)
    end)
    tabButtons[tabName] = btn
end
SwitchTab("Main")


-- MAIN TAB FLY UI

local mainParent = tabContents["Main"]


-- 2 COLUMN LAYOUT


local columns = Instance.new("Frame")
columns.Size = UDim2.new(1,0,0,0)
columns.BackgroundTransparency = 1
columns.Parent = mainParent

-- LEFT SIDE
local leftColumn = Instance.new("Frame")
leftColumn.Name = "LeftColumn"
leftColumn.Size = UDim2.new(0,210,0,0)
leftColumn.Position = UDim2.new(0,0,0,0)
leftColumn.BackgroundTransparency = 1
leftColumn.AutomaticSize = Enum.AutomaticSize.Y
leftColumn.Parent = columns


-- FLY DROPDOWN


local flyContainer = UI.CreateDropdown(leftColumn,"Fly")
flyContainer.LayoutOrder = 221

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0,8)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Parent = leftColumn

-- RIGHT SIDE
local rightColumn = Instance.new("Frame")
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0,210,0,0)
rightColumn.Position = UDim2.new(0,220,0,0)
rightColumn.BackgroundTransparency = 1
rightColumn.AutomaticSize = Enum.AutomaticSize.Y
rightColumn.Parent = columns

local rightLayout = Instance.new("UIListLayout")
rightLayout.Padding = UDim.new(0,8)
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Parent = rightColumn

local function refreshColumns()
    local leftHeight = leftLayout.AbsoluteContentSize.Y
    local rightHeight = rightLayout.AbsoluteContentSize.Y
    columns.Size = UDim2.new(1,0,0,math.max(leftHeight, rightHeight))
end

leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshColumns)
rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshColumns)
task.defer(refreshColumns)
RS.Heartbeat:Connect(function()
	refreshColumns()
end)

-- FLY VARIABLES
local flyEnabled = false
local flying = false
local flyKey = Enum.KeyCode.F
local waitingForFlyKey = false
local speed = 80
local keys = {W=false,A=false,S=false,D=false,Space=false,LeftShift=false}
local bodyVelocity
-- VELOCITY FLY ENGINE
local function startFly()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if not bodyVelocity then
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = hrp
	end
end

local function stopFly()
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
end

RS.RenderStepped:Connect(function()
	if not flyEnabled or not flying or not bodyVelocity then return end
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local cam = workspace.CurrentCamera
	local moveDir = Vector3.zero
	if keys.W then moveDir += cam.CFrame.LookVector end
	if keys.S then moveDir -= cam.CFrame.LookVector end
	if keys.A then moveDir -= cam.CFrame.RightVector end
	if keys.D then moveDir += cam.CFrame.RightVector end
	if keys.Space then moveDir += Vector3.new(0,1,0) end
	if keys.LeftShift then moveDir -= Vector3.new(0,1,0) end
	if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
	bodyVelocity.Velocity = moveDir * speed
end)

-- INPUT HANDLING
table.insert(connections, UIS.InputBegan:Connect(function(input,gpe)
	if gpe then return end
	if input.KeyCode ~= Enum.KeyCode.Unknown and keys[input.KeyCode.Name] ~= nil then
		keys[input.KeyCode.Name] = true
	end
end))

table.insert(connections, UIS.InputEnded:Connect(function(input)
	if keys[input.KeyCode.Name] ~= nil then
		keys[input.KeyCode.Name] = false
	end
end))

local function flyInputNameAndEnum(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then return "LMB", Enum.UserInputType.MouseButton1 end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then return "RMB", Enum.UserInputType.MouseButton2 end
	if input.UserInputType == Enum.UserInputType.MouseButton3 then return "MMB", Enum.UserInputType.MouseButton3 end
	if tostring(input.UserInputType):find("MouseButton4") then return "MB4", input.UserInputType end
	if tostring(input.UserInputType):find("MouseButton5") then return "MB5", input.UserInputType end
	if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then return input.KeyCode.Name, input.KeyCode end
	return nil, nil
end

local function flyInputMatches(binding, input)
	if typeof(binding) == "EnumItem" and binding.EnumType == Enum.UserInputType then
		return input.UserInputType == binding
	end
	return input.KeyCode == binding
end

if _G.__RYO_FLY_INPUT_CONNECTION then
	pcall(function() _G.__RYO_FLY_INPUT_CONNECTION:Disconnect() end)
end
_G.__RYO_FLY_INPUT_CONNECTION = UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if waitingForFlyKey then
		local name, enumValue = flyInputNameAndEnum(input)
		if enumValue then
			flyKey = enumValue
			waitingForFlyKey = false
			if keyBindButton then
				keyBindButton.Text = name
				keyBindButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
			end
		end
		return
	end

	if flyEnabled and flyInputMatches(flyKey, input) then
		flying = not flying
		if flying then startFly() else stopFly() end
	end
end)
table.insert(connections, _G.__RYO_FLY_INPUT_CONNECTION)

-- (UI: Fly Toggle / Keybind / Slider / Noclip / Fake Name / Hide User / Server Hop stays exactly your original)
-- 
-- FLY LEVER
-- 

local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0,200,0,28)
flyFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
flyFrame.Parent = flyContainer
Instance.new("UICorner", flyFrame)

local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0,120,1,0)
flyLabel.Position = UDim2.new(0,8,0,0)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "Fly"
flyLabel.Font = Enum.Font.Gotham
flyLabel.TextSize = 14
flyLabel.TextColor3 = Color3.new(1,1,1)
flyLabel.TextXAlignment = Enum.TextXAlignment.Left
flyLabel.Parent = flyFrame


local flySwitch = Instance.new("Frame")
flySwitch.Size = UDim2.new(0,34,0,16)
flySwitch.Position = UDim2.new(1,-42,0.5,-8)
flySwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
flySwitch.Parent = flyFrame
Instance.new("UICorner",flySwitch)

local flyKnob = Instance.new("Frame")
flyKnob.Size = UDim2.new(0,14,0,14)
flyKnob.Position = UDim2.new(0,1,0.5,-7)
flyKnob.BackgroundColor3 = Color3.new(1,1,1)
flyKnob.Parent = flySwitch
Instance.new("UICorner",flyKnob)

local function toggleFly()
	flyEnabled = not flyEnabled
	if not flyEnabled then
		flying = false
		stopFly()
	end

	TS:Create(flyKnob,TweenInfo.new(0.25),
	{Position = flyEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,1,0.5,-7)}):Play()

	TS:Create(flySwitch,TweenInfo.new(0.25),
	{BackgroundColor3 = flyEnabled and Color3.fromRGB(170,0,255) or Color3.fromRGB(80,80,80)}):Play()
end

bindAimStyleToggle(flyFrame, toggleFly)

--
-- FLY KEYBIND
--

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0,200,0,28)
keyFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
keyFrame.Parent = flyContainer
Instance.new("UICorner", keyFrame)

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0,120,1,0)
keyLabel.Position = UDim2.new(0,8,0,0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Fly Key"
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 14
keyLabel.TextColor3 = Color3.new(1,1,1)
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = keyFrame

keyBindButton = Instance.new("TextButton")
keyBindButton.Size = UDim2.new(0,60,0,18)
keyBindButton.Position = UDim2.new(1,-70,0.5,-9)
keyBindButton.BackgroundColor3 = Color3.fromRGB(80,80,80)
keyBindButton.Text = flyKey.Name
keyBindButton.TextColor3 = Color3.new(1,1,1)
keyBindButton.Font = Enum.Font.Gotham
keyBindButton.TextSize = 13
keyBindButton.Parent = keyFrame
Instance.new("UICorner", keyBindButton)

keyBindButton.MouseButton1Click:Connect(function()
	waitingForFlyKey = true
	keyBindButton.Text = "PRESS KEY"
	keyBindButton.BackgroundColor3 = Color3.fromRGB(170,0,255)
end)

--
-- FLY SPEED SLIDER
--

local speedFrame = UI.CreateCard(flyContainer,36)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1,0,0,14)
speedLabel.Position = UDim2.new(0,8,0,2)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Fly Speed: "..speed
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1,-16,0,6)
sliderBar.Position = UDim2.new(0,8,0,22)
sliderBar.BackgroundColor3 = Color3.fromRGB(70,70,70)
sliderBar.Parent = speedFrame
Instance.new("UICorner",sliderBar)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(speed/300,0,1,0)
sliderFill.BackgroundColor3 = UI.Theme.Accent
sliderFill.Parent = sliderBar
Instance.new("UICorner",sliderFill)

makeBarInteractable({sliderBar, sliderFill}, sliderBar, function(percent)
	speed = math.floor(percent * 300)
	sliderFill.Size = UDim2.new(percent,0,1,0)
	speedLabel.Text = "Fly Speed: "..speed
end)-- All lever frames, sliders, buttons, labels remain unchanged
-- 
-- ESP DROPDOWN
--

local espContainer = UI.CreateDropdown(leftColumn,"ESP")
espContainer.LayoutOrder = 220


--
-- COMBINED NAME + HEALTH ESP
--

local function removeCombinedESP(character)
	if not character then return end
	local head = character:FindFirstChild("Head")
	if head then
		local gui = head:FindFirstChild("PlayerESP")
		if gui then
			gui:Destroy()
		end
	end
end

local function addCombinedESP(plr)
	if plr == player then return end

	local function apply(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local head = character:WaitForChild("Head",5)

		if not humanoid or not head then return end
		if head:FindFirstChild("PlayerESP") then return end

		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PlayerESP"
		billboard.Size = UDim2.new(0,140,0,32)
		billboard.StudsOffset = Vector3.new(0,3,0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Parent = billboard

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1,0,0,16)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.new(1,1,1)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = 16
		nameLabel.Text = plr.DisplayName
		nameLabel.Parent = billboard

		local healthLabel = Instance.new("TextLabel")
		healthLabel.Size = UDim2.new(1,0,0,14)
		healthLabel.BackgroundTransparency = 1
		healthLabel.TextColor3 = Color3.fromRGB(0,255,0)
		healthLabel.TextStrokeTransparency = 0
		healthLabel.Font = Enum.Font.SourceSansBold
		healthLabel.TextSize = 14
		healthLabel.Parent = billboard

		local function updateHealth()
			healthLabel.Text = tostring(math.floor(humanoid.Health))
		end

		updateHealth()
		humanoid.HealthChanged:Connect(updateHealth)
	end

	if plr.Character then
		apply(plr.Character)
	end

	plr.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		apply(char)
	end)
end

local function updateCombinedESP()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			if nameESPEnabled or healthESPEnabled then
				addCombinedESP(plr)
			else
				removeCombinedESP(plr.Character)
			end
		end
	end
end

--
-- CHAMS TOGGLE
--

local chamsEnabled = false
local chamsColor = Color3.fromRGB(60,170,255)

local function applyChams(character)
	if not chamsEnabled then return end
	if not character then return end

	local playerCheck = Players:GetPlayerFromCharacter(character)
	if playerCheck == player then return end

	if character:FindFirstChild("ChamsHighlight") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ChamsHighlight"
	highlight.FillColor = chamsColor
	highlight.OutlineColor = Color3.new(1,1,1)
	highlight.FillTransparency = 0.5
	highlight.Parent = character
end

local function removeChams(character)
	if character and character:FindFirstChild("ChamsHighlight") then
		character.ChamsHighlight:Destroy()
	end
end

local function updateChams()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			if chamsEnabled then
				applyChams(plr.Character)
			else
				removeChams(plr.Character)
			end
		end
	end
end

local function setupPlayerChams(plr)

	plr.CharacterAdded:Connect(function(char)

		-- wait for character parts to load
		local hrp = char:WaitForChild("HumanoidRootPart",5)
		if not hrp then return end

		if chamsEnabled then
			applyChams(char)
		end

	end)

end

-- run for players already in server
for _,plr in ipairs(Players:GetPlayers()) do
	if plr ~= player then
		setupPlayerChams(plr)
	end
end

-- run for players who join later
Players.PlayerAdded:Connect(setupPlayerChams)

-- UI

local chamsFrame = Instance.new("Frame")
chamsFrame.Size = UDim2.new(0,200,0,28)
chamsFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
chamsFrame.Parent = espContainer
Instance.new("UICorner", chamsFrame)

local chamsLabel = Instance.new("TextLabel")
chamsLabel.Size = UDim2.new(0,120,1,0)
chamsLabel.Position = UDim2.new(0,8,0,0)
chamsLabel.BackgroundTransparency = 1
chamsLabel.Text = "Chams"
chamsLabel.Font = Enum.Font.Gotham
chamsLabel.TextSize = 14
chamsLabel.TextColor3 = Color3.new(1,1,1)
chamsLabel.TextXAlignment = Enum.TextXAlignment.Left
chamsLabel.Parent = chamsFrame

local chamsSwitch = Instance.new("Frame")
chamsSwitch.Size = UDim2.new(0,34,0,16)
chamsSwitch.Position = UDim2.new(1,-42,0.5,-8)
chamsSwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
chamsSwitch.Parent = chamsFrame
Instance.new("UICorner",chamsSwitch)

local chamsKnob = Instance.new("Frame")
chamsKnob.Size = UDim2.new(0,14,0,14)
chamsKnob.Position = UDim2.new(0,1,0.5,-7)
chamsKnob.BackgroundColor3 = Color3.new(1,1,1)
chamsKnob.Parent = chamsSwitch
Instance.new("UICorner",chamsKnob)

local function toggleChams()

	chamsEnabled = not chamsEnabled
	updateChams()

	TS:Create(chamsKnob,TweenInfo.new(0.25),
	{Position = chamsEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,1,0.5,-7)}):Play()

	TS:Create(chamsSwitch,TweenInfo.new(0.25),
	{BackgroundColor3 = chamsEnabled and Color3.fromRGB(170,0,255) or Color3.fromRGB(80,80,80)}):Play()

end
bindAimStyleToggle(chamsFrame, toggleChams)
-- 
-- HEALTH ESP
--

local healthESPEnabled = false

local function removeHealthESP(character)
	if not character then return end
	local head = character:FindFirstChild("Head")
	if head then
		local gui = head:FindFirstChild("HealthESP")
		if gui then
			gui:Destroy()
		end
	end
end

local function addHealthESP(playerTarget)
	if playerTarget == player then return end

	local function apply(character)
		if not healthESPEnabled then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local head = character:WaitForChild("Head",5)
		if not humanoid or not head then return end

		if head:FindFirstChild("HealthESP") then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "HealthESP"
		billboard.Size = UDim2.new(0,120,0,16)
		billboard.StudsOffset = Vector3.new(0,3.8,0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(0,255,0)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 14
		label.Parent = billboard

		local function update()
			label.Text = tostring(math.floor(humanoid.Health))
		end

		update()
		humanoid.HealthChanged:Connect(update)
	end

	if playerTarget.Character then
		apply(playerTarget.Character)
	end

	playerTarget.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		apply(char)
	end)
end

local function updateHealthESP()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			if healthESPEnabled then
				addHealthESP(plr)
			else
				removeHealthESP(plr.Character)
			end
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if healthESPEnabled then
			addHealthESP(plr)
		end
	end)
end)

-- UI

local healthFrame = Instance.new("Frame")
healthFrame.Size = UDim2.new(0,200,0,28)
healthFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
healthFrame.Parent = espContainer
Instance.new("UICorner", healthFrame)

local healthLabel = Instance.new("TextLabel")
healthLabel.Size = UDim2.new(0,120,1,0)
healthLabel.Position = UDim2.new(0,8,0,0)
healthLabel.BackgroundTransparency = 1
healthLabel.Text = "Health ESP"
healthLabel.Font = Enum.Font.Gotham
healthLabel.TextSize = 14
healthLabel.TextColor3 = Color3.new(1,1,1)
healthLabel.TextXAlignment = Enum.TextXAlignment.Left
healthLabel.Parent = healthFrame

local healthSwitch = Instance.new("Frame")
healthSwitch.Size = UDim2.new(0,34,0,16)
healthSwitch.Position = UDim2.new(1,-42,0.5,-8)
healthSwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
healthSwitch.Parent = healthFrame
Instance.new("UICorner",healthSwitch)

local healthKnob = Instance.new("Frame")
healthKnob.Size = UDim2.new(0,14,0,14)
healthKnob.Position = UDim2.new(0,1,0.5,-7)
healthKnob.BackgroundColor3 = Color3.new(1,1,1)
healthKnob.Parent = healthSwitch
Instance.new("UICorner",healthKnob)

local function toggleHealthESP()
	healthESPEnabled = not healthESPEnabled

	updateHealthESP()

	TS:Create(healthKnob,TweenInfo.new(0.25),
	{Position = healthESPEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,1,0.5,-7)}):Play()

	TS:Create(healthSwitch,TweenInfo.new(0.25),
	{BackgroundColor3 = healthESPEnabled and Color3.fromRGB(170,0,255) or Color3.fromRGB(80,80,80)}):Play()
end

bindAimStyleToggle(healthFrame, toggleHealthESP)
-- 
-- NAME ESP
-- 

local nameESPEnabled = false

local function removeNameESP(character)
	if not character then return end
	local head = character:FindFirstChild("Head")
	if head then
		local gui = head:FindFirstChild("NameESP")
		if gui then
			gui:Destroy()
		end
	end
end

local function addNameESP(playerTarget)
	if playerTarget == player then return end

	local function apply(character)
		if not nameESPEnabled then return end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local head = character:WaitForChild("Head",5)
		if not head then return end

		if humanoid then
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		if head:FindFirstChild("NameESP") then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "NameESP"
		billboard.Size = UDim2.new(0,140,0,20)
		billboard.StudsOffset = Vector3.new(0,2.9,0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1,1,1)
		label.TextStrokeTransparency = 0
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = 16
		label.Text = playerTarget.DisplayName
		label.Parent = billboard
	end

	if playerTarget.Character then
		apply(playerTarget.Character)
	end

	playerTarget.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		apply(char)
	end)
end

local function updateNameESP()
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			if nameESPEnabled then
				addNameESP(plr)
			else
				removeNameESP(plr.Character)
			end
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if nameESPEnabled then
			addNameESP(plr)
		end
	end)
end)

-- UI

local nameFrame = Instance.new("Frame")
nameFrame.Size = UDim2.new(0,200,0,28)
nameFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
nameFrame.Parent = espContainer
Instance.new("UICorner", nameFrame)

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0,120,1,0)
nameLabel.Position = UDim2.new(0,8,0,0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Name ESP"
nameLabel.Font = Enum.Font.Gotham
nameLabel.TextSize = 14
nameLabel.TextColor3 = Color3.new(1,1,1)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = nameFrame

local nameSwitch = Instance.new("Frame")
nameSwitch.Size = UDim2.new(0,34,0,16)
nameSwitch.Position = UDim2.new(1,-42,0.5,-8)
nameSwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
nameSwitch.Parent = nameFrame
Instance.new("UICorner",nameSwitch)

local nameKnob = Instance.new("Frame")
nameKnob.Size = UDim2.new(0,14,0,14)
nameKnob.Position = UDim2.new(0,1,0.5,-7)
nameKnob.BackgroundColor3 = Color3.new(1,1,1)
nameKnob.Parent = nameSwitch
Instance.new("UICorner",nameKnob)

local function toggleNameESP()
	nameESPEnabled = not nameESPEnabled

	updateNameESP()

	TS:Create(nameKnob,TweenInfo.new(0.25),
	{Position = nameESPEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,1,0.5,-7)}):Play()

	TS:Create(nameSwitch,TweenInfo.new(0.25),
	{BackgroundColor3 = nameESPEnabled and Color3.fromRGB(170,0,255) or Color3.fromRGB(80,80,80)}):Play()
end

bindAimStyleToggle(nameFrame, toggleNameESP)
--
-- AIM DROPDOWN
-- 
local memoryAimEnabled = false
local aimKey = Enum.KeyCode.E
local aimPart = "Head"

local aimContainer = UI.CreateDropdown(rightColumn,"Aim")
-- FOV VARIABLES (must exist before target finder)
local fovCircleEnabled = false
local fovValue = 120
-- TARGET LOCK VARIABLES
local lockedTarget = nil
local lastLockTime = 0
local lockDuration = 0.35

--
-- TARGET FINDER (FOV SYSTEM)
--

local function getClosestPlayer()

	local closest = nil
	local shortest = math.huge

	local mousePos = UIS:GetMouseLocation()

	local currentTime = tick()

-- keep target briefly but allow switching if someone closer appears
if lockedTarget and lockedTarget.Parent then
	local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(lockedTarget.Position)

	if visible then
		local dist = (Vector2.new(screenPos.X,screenPos.Y) - mousePos).Magnitude
		
		-- keep current target only if still near crosshair
		if dist < fovValue * 0.6 then
			return lockedTarget
		end
	end
end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player and plr.Character and plr.Character:FindFirstChild(aimPart) then

			local part = plr.Character[aimPart]

			local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(part.Position)

			if visible then

				local distance = (Vector2.new(screenPos.X,screenPos.Y) - mousePos).Magnitude

				-- FOV CHECK
				if fovCircleEnabled and distance > fovValue then
					continue
				end

				if distance < shortest then
	            shortest = distance
	            closest = part
				lockedTarget = part
	            lastLockTime = tick()
                end

			end

		end

	end

	return closest

end

-- 
-- MOUSE AIM TOGGLE
--

local mouseAimEnabled = false

local mouseAimFrame = UI.CreateCard(aimContainer,28)

local mouseAimLabel = Instance.new("TextLabel")
mouseAimLabel.Size = UDim2.new(0.7,0,1,0)
mouseAimLabel.Position = UDim2.new(0,8,0,0)
mouseAimLabel.BackgroundTransparency = 1
mouseAimLabel.Text = "Mouse Aim"
mouseAimLabel.Font = Enum.Font.Gotham
mouseAimLabel.TextSize = 14
mouseAimLabel.TextColor3 = Color3.new(1,1,1)
mouseAimLabel.TextXAlignment = Enum.TextXAlignment.Left
mouseAimLabel.Parent = mouseAimFrame

local mouseSwitch = Instance.new("Frame")
mouseSwitch.Size = UDim2.new(0,34,0,16)
mouseSwitch.Position = UDim2.new(1,-42,0.5,-8)
mouseSwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
mouseSwitch.Parent = mouseAimFrame
Instance.new("UICorner",mouseSwitch)

local mouseKnob = Instance.new("Frame")
mouseKnob.Size = UDim2.new(0,14,0,14)
mouseKnob.Position = UDim2.new(0,1,0.5,-7)
mouseKnob.BackgroundColor3 = Color3.new(1,1,1)
mouseKnob.Parent = mouseSwitch
Instance.new("UICorner",mouseKnob)

local function toggleMouseAim()

	mouseAimEnabled = not mouseAimEnabled

	TS:Create(mouseKnob,TweenInfo.new(0.25),{
		Position = mouseAimEnabled and UDim2.new(1,-17,0.5,-7)
		or UDim2.new(0,1,0.5,-7)
	}):Play()

	TS:Create(mouseSwitch,TweenInfo.new(0.25),{
		BackgroundColor3 = mouseAimEnabled and Color3.fromRGB(170,0,255)
		or Color3.fromRGB(80,80,80)
	}):Play()

end

mouseAimFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		toggleMouseAim()
	end
end)

-- 
-- MEMORY AIM TOGGLE
-- 


local memoryAimFrame = UI.CreateCard(aimContainer,28)

local memoryAimLabel = Instance.new("TextLabel")
memoryAimLabel.Size = UDim2.new(0.7,0,1,0)
memoryAimLabel.Position = UDim2.new(0,8,0,0)
memoryAimLabel.BackgroundTransparency = 1
memoryAimLabel.Text = "Memory Aim"
memoryAimLabel.Font = Enum.Font.Gotham
memoryAimLabel.TextSize = 14
memoryAimLabel.TextColor3 = Color3.new(1,1,1)
memoryAimLabel.TextXAlignment = Enum.TextXAlignment.Left
memoryAimLabel.Parent = memoryAimFrame

local memorySwitch = Instance.new("Frame")
memorySwitch.Size = UDim2.new(0,34,0,16)
memorySwitch.Position = UDim2.new(1,-42,0.5,-8)
memorySwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
memorySwitch.Parent = memoryAimFrame
Instance.new("UICorner",memorySwitch)

local memoryKnob = Instance.new("Frame")
memoryKnob.Size = UDim2.new(0,14,0,14)
memoryKnob.Position = UDim2.new(0,1,0.5,-7)
memoryKnob.BackgroundColor3 = Color3.new(1,1,1)
memoryKnob.Parent = memorySwitch
Instance.new("UICorner",memoryKnob)

local function toggleMemoryAim()

	memoryAimEnabled = not memoryAimEnabled

	TS:Create(memoryKnob,TweenInfo.new(0.25),{
		Position = memoryAimEnabled and UDim2.new(1,-17,0.5,-7)
		or UDim2.new(0,1,0.5,-7)
	}):Play()

	TS:Create(memorySwitch,TweenInfo.new(0.25),{
		BackgroundColor3 = memoryAimEnabled and Color3.fromRGB(170,0,255)
		or Color3.fromRGB(80,80,80)
	}):Play()

end

memoryAimFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		toggleMemoryAim()
	end
end)
-- 
-- FOV CIRCLE TOGGLE
--


local fovToggleFrame = UI.CreateCard(aimContainer,28)

local fovToggleLabel = Instance.new("TextLabel")
fovToggleLabel.Size = UDim2.new(0.7,0,1,0)
fovToggleLabel.Position = UDim2.new(0,8,0,0)
fovToggleLabel.BackgroundTransparency = 1
fovToggleLabel.Text = "FOV Circle"
fovToggleLabel.Font = Enum.Font.Gotham
fovToggleLabel.TextSize = 14
fovToggleLabel.TextColor3 = Color3.new(1,1,1)
fovToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
fovToggleLabel.Parent = fovToggleFrame

local fovSwitch = Instance.new("Frame")
fovSwitch.Size = UDim2.new(0,34,0,16)
fovSwitch.Position = UDim2.new(1,-42,0.5,-8)
fovSwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
fovSwitch.Parent = fovToggleFrame
Instance.new("UICorner",fovSwitch)

local fovKnob = Instance.new("Frame")
fovKnob.Size = UDim2.new(0,14,0,14)
fovKnob.Position = UDim2.new(0,1,0.5,-7)
fovKnob.BackgroundColor3 = Color3.new(1,1,1)
fovKnob.Parent = fovSwitch
Instance.new("UICorner",fovKnob)

local function toggleFovCircle()

	fovCircleEnabled = not fovCircleEnabled

	TS:Create(fovKnob,TweenInfo.new(0.25),{
		Position = fovCircleEnabled and UDim2.new(1,-17,0.5,-7)
		or UDim2.new(0,1,0.5,-7)
	}):Play()

	TS:Create(fovSwitch,TweenInfo.new(0.25),{
		BackgroundColor3 = fovCircleEnabled and Color3.fromRGB(170,0,255)
		or Color3.fromRGB(80,80,80)
	}):Play()

end

fovToggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		toggleFovCircle()
	end
end)
-- 
-- FOV SLIDER
-- 

local fovFrame = UI.CreateCard(aimContainer,36)

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1,0,0,14)
fovLabel.Position = UDim2.new(0,8,0,2)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: "..fovValue
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextSize = 13
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = fovFrame

local fovBar = Instance.new("Frame")
fovBar.Size = UDim2.new(1,-16,0,6)
fovBar.Position = UDim2.new(0,8,0,22)
fovBar.BackgroundColor3 = Color3.fromRGB(70,70,70)
fovBar.Parent = fovFrame
Instance.new("UICorner",fovBar)

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(fovValue/360,0,1,0)
fovFill.BackgroundColor3 = UI.Theme.Accent
fovFill.Parent = fovBar
Instance.new("UICorner",fovFill)

makeBarInteractable({fovBar, fovFill}, fovBar, function(percent)
	fovValue = math.floor(percent * 360)
	fovFill.Size = UDim2.new(percent,0,1,0)
	fovLabel.Text = "FOV: "..fovValue
end)
--
-- FOV CIRCLE
-- 

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = fovValue
fovCircle.Thickness = 2
fovCircle.NumSides = 80
fovCircle.Color = Color3.fromRGB(170,0,255)
fovCircle.Filled = false
fovCircle.Transparency = 0.8

RS.RenderStepped:Connect(function()

	if not fovCircleEnabled then
		fovCircle.Visible = false
		return
	end

	fovCircle.Visible = true

	local mousePos = UIS:GetMouseLocation()

	fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
	fovCircle.Radius = fovValue

end)
-- 
-- AIM SMOOTHNESS SLIDER
-- 

local smoothValue = 5

local smoothFrame = UI.CreateCard(aimContainer,36)

local smoothLabel = Instance.new("TextLabel")
smoothLabel.Size = UDim2.new(1,0,0,14)
smoothLabel.Position = UDim2.new(0,8,0,2)
smoothLabel.BackgroundTransparency = 1
smoothLabel.Text = "Smoothness: "..smoothValue
-- 
-- MEMORY AIM SYSTEM
--

RS.RenderStepped:Connect(function()

	if not memoryAimEnabled then return end
	if (typeof(aimKey) == "EnumItem" and aimKey.EnumType == Enum.UserInputType and not aimMouseHeld) or (typeof(aimKey) ~= "EnumItem" or aimKey.EnumType ~= Enum.UserInputType) and not UIS:IsKeyDown(aimKey) then return end


	local target = getClosestPlayer()
	if not target then return end

	local cam = workspace.CurrentCamera

	local targetCF = CFrame.new(cam.CFrame.Position, target.Position)

	cam.CFrame = cam.CFrame:Lerp(
		targetCF,
		math.clamp((smoothValue or 5) / 20, 0.01, 1)
	)

end)

local mouseAimStrength = 0.1
--
-- MOUSE AIM SYSTEM (KEYBIND + FOV)
--

RS.RenderStepped:Connect(function()

    if not mouseAimEnabled then return end
    if (typeof(aimKey) == "EnumItem" and aimKey.EnumType == Enum.UserInputType and not aimMouseHeld) or (typeof(aimKey) ~= "EnumItem" or aimKey.EnumType ~= Enum.UserInputType) and not UIS:IsKeyDown(aimKey) then return end

    local target = getClosestPlayer()
    if not target then return end

    local mouse = UIS:GetMouseLocation()
    local cam = workspace.CurrentCamera
    local screenPos = cam:WorldToViewportPoint(target.Position)

local dx = screenPos.X - mouse.X
local dy = screenPos.Y - mouse.Y
local distance = math.sqrt(dx*dx + dy*dy)

-- deadzone to stop jitter
if distance < 1.5 then return end

-- smooth factor from slider
local smooth = math.clamp(smoothValue / 20, 0.05, 1)

-- stronger movement when far, smoother when close
local moveX = dx * smooth * 0.35
local moveY = dy * smooth * 0.35

-- clamp large jumps
moveX = math.clamp(moveX, -50, 50)
moveY = math.clamp(moveY, -50, 50)

if mousemoverel then
	mousemoverel(moveX, moveY)
end

end)

smoothLabel.Font = Enum.Font.Gotham
smoothLabel.TextSize = 13
smoothLabel.TextColor3 = Color3.new(1,1,1)
smoothLabel.TextXAlignment = Enum.TextXAlignment.Left
smoothLabel.Parent = smoothFrame

local smoothBar = Instance.new("Frame")
smoothBar.Size = UDim2.new(1,-16,0,6)
smoothBar.Position = UDim2.new(0,8,0,22)
smoothBar.BackgroundColor3 = Color3.fromRGB(70,70,70)
smoothBar.Parent = smoothFrame
Instance.new("UICorner",smoothBar)

local smoothFill = Instance.new("Frame")
smoothFill.Size = UDim2.new(smoothValue/20,0,1,0)
smoothFill.BackgroundColor3 = UI.Theme.Accent
smoothFill.Parent = smoothBar
Instance.new("UICorner",smoothFill)

makeBarInteractable({smoothBar, smoothFill}, smoothBar, function(percent)
	smoothValue = math.floor(percent * 20)
	smoothFill.Size = UDim2.new(percent,0,1,0)
	smoothLabel.Text = "Smoothness: "..smoothValue
end)
-- 
-- AIM KEYBIND
-- 
local waitingForKey = false

local function getBindingDisplayName(binding)
	if typeof(binding) == "EnumItem" and binding.EnumType == Enum.UserInputType then
		if binding == Enum.UserInputType.MouseButton1 then return "LMB" end
		if binding == Enum.UserInputType.MouseButton2 then return "RMB" end
		if binding == Enum.UserInputType.MouseButton3 then return "MMB" end
		local bindingText = tostring(binding)
		if bindingText:find("MouseButton4") then return "MB4" end
		if bindingText:find("MouseButton5") then return "MB5" end
		return binding.Name
	end
	return binding.Name
end

local aimKeyFrame = UI.CreateCard(aimContainer,28)
aimKeyFrame.Active = true

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1,0,1,0)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Aim Key: "..getBindingDisplayName(aimKey)
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 14
keyLabel.TextColor3 = Color3.new(1,1,1)
keyLabel.Parent = aimKeyFrame

local aimKeyOverlay = Instance.new("TextButton")
aimKeyOverlay.Name = "AimKeyOverlay"
aimKeyOverlay.Size = UDim2.new(1,0,1,0)
aimKeyOverlay.BackgroundTransparency = 1
aimKeyOverlay.Text = ""
aimKeyOverlay.AutoButtonColor = false
aimKeyOverlay.Parent = aimKeyFrame

aimKeyOverlay.MouseButton1Click:Connect(function()
	waitingForKey = true
	keyLabel.Text = "Aim Key: Press a key..."
end)
--
-- AIM PART SELECT
-- 

local aimParts = {"Head","HumanoidRootPart","UpperTorso"}
local partIndex = 1

local partFrame = UI.CreateCard(aimContainer,28)

local partLabel = Instance.new("TextLabel")
partLabel.Size = UDim2.new(1,0,1,0)
partLabel.BackgroundTransparency = 1
partLabel.Text = "Aim Part: "..aimParts[partIndex]
partLabel.Font = Enum.Font.Gotham
partLabel.TextSize = 14
partLabel.TextColor3 = Color3.new(1,1,1)
partLabel.Parent = partFrame

partFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		
		partIndex += 1
		if partIndex > #aimParts then
			partIndex = 1
		end
		
		aimPart = aimParts[partIndex]
		partLabel.Text = "Aim Part: "..aimPart
		
	end
end)
-- 
-- MISC TAB
--

local miscParent = tabContents["Misc"]


-- 
-- XRAY UI
-- 

local xrayEnabled = false
local xrayStrength = 65
local xrayTouchedParts = {}
local xrayAddedConnection
local xrayCharacterConnections = {}

local function clearXrayOnPart(part)
	if part and part:IsA("BasePart") then
		part.LocalTransparencyModifier = 0
		xrayTouchedParts[part] = nil
	end
end

local function isHumanoidModel(model)
	return model and model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function shouldXrayPart(part)
	if not part or not part:IsA("BasePart") then return false end
	if player.Character and part:IsDescendantOf(player.Character) then return false end

	local ancestor = part.Parent
	while ancestor do
		if isHumanoidModel(ancestor) then
			return false
		end
		ancestor = ancestor.Parent
	end

	return true
end

local function applyXrayToPart(part)
	if xrayEnabled and shouldXrayPart(part) then
		part.LocalTransparencyModifier = math.clamp(xrayStrength / 100, 0, 0.95)
		xrayTouchedParts[part] = true
	end
end

local function refreshXray()
	for part in pairs(xrayTouchedParts) do
		clearXrayOnPart(part)
	end

	if not xrayEnabled then return end

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			applyXrayToPart(obj)
		end
	end
end

local function connectCharacterXrayCleanup(character)
	if not character then return end
	for _, conn in ipairs(xrayCharacterConnections) do
		if conn and conn.Disconnect then
			conn:Disconnect()
		end
	end
	table.clear(xrayCharacterConnections)

	table.insert(xrayCharacterConnections, character.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") then
			obj.LocalTransparencyModifier = 0
			xrayTouchedParts[obj] = nil
		end
	end))

	table.insert(xrayCharacterConnections, character.DescendantRemoving:Connect(function(obj)
		if obj:IsA("BasePart") then
			xrayTouchedParts[obj] = nil
		end
	end))
end

if player.Character then
	connectCharacterXrayCleanup(player.Character)
end

table.insert(connections, player.CharacterAdded:Connect(function(character)
	connectCharacterXrayCleanup(character)
	task.defer(refreshXray)
end))

if xrayAddedConnection then
	xrayAddedConnection:Disconnect()
end
xrayAddedConnection = workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") then
		applyXrayToPart(obj)
	end
end)
table.insert(connections, xrayAddedConnection)

local xrayFrame = Instance.new("Frame")
xrayFrame.Size = UDim2.new(0,200,0,28)
xrayFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
xrayFrame.Parent = miscParent
Instance.new("UICorner", xrayFrame)

local xrayLabel = Instance.new("TextLabel")
xrayLabel.Size = UDim2.new(0,120,1,0)
xrayLabel.Position = UDim2.new(0,8,0,0)
xrayLabel.BackgroundTransparency = 1
xrayLabel.Text = "Xray"
xrayLabel.Font = Enum.Font.Gotham
xrayLabel.TextSize = 14
xrayLabel.TextColor3 = Color3.new(1,1,1)
xrayLabel.TextXAlignment = Enum.TextXAlignment.Left
xrayLabel.Parent = xrayFrame

local xraySwitch = Instance.new("Frame")
xraySwitch.Size = UDim2.new(0,34,0,16)
xraySwitch.Position = UDim2.new(1,-42,0.5,-8)
xraySwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
xraySwitch.Parent = xrayFrame
Instance.new("UICorner", xraySwitch)

local xrayKnob = Instance.new("Frame")
xrayKnob.Size = UDim2.new(0,14,0,14)
xrayKnob.Position = UDim2.new(0,1,0.5,-7)
xrayKnob.BackgroundColor3 = Color3.new(1,1,1)
xrayKnob.Parent = xraySwitch
Instance.new("UICorner", xrayKnob)

local function toggleXray()
	xrayEnabled = not xrayEnabled

	TS:Create(xrayKnob, TweenInfo.new(0.25),
	{Position = xrayEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,1,0.5,-7)}):Play()

	TS:Create(xraySwitch, TweenInfo.new(0.25),
	{BackgroundColor3 = xrayEnabled and Color3.fromRGB(170,0,255) or Color3.fromRGB(80,80,80)}):Play()

	refreshXray()
end

bindAimStyleToggle(xrayFrame, toggleXray)

local xraySpeedFrame = UI.CreateCard(miscParent,36)

local xraySpeedLabel = Instance.new("TextLabel")
xraySpeedLabel.Size = UDim2.new(1,0,0,14)
xraySpeedLabel.Position = UDim2.new(0,8,0,2)
xraySpeedLabel.BackgroundTransparency = 1
xraySpeedLabel.Text = "Xray Strength: "..xrayStrength
xraySpeedLabel.Font = Enum.Font.Gotham
xraySpeedLabel.TextSize = 13
xraySpeedLabel.TextColor3 = Color3.new(1,1,1)
xraySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
xraySpeedLabel.Parent = xraySpeedFrame

local xraySliderBar = Instance.new("Frame")
xraySliderBar.Size = UDim2.new(1,-16,0,6)
xraySliderBar.Position = UDim2.new(0,8,0,22)
xraySliderBar.BackgroundColor3 = Color3.fromRGB(70,70,70)
xraySliderBar.Parent = xraySpeedFrame
Instance.new("UICorner", xraySliderBar)

local xraySliderFill = Instance.new("Frame")
xraySliderFill.Size = UDim2.new(xrayStrength/100,0,1,0)
xraySliderFill.BackgroundColor3 = UI.Theme.Accent
xraySliderFill.Parent = xraySliderBar
Instance.new("UICorner", xraySliderFill)

makeBarInteractable({xraySliderBar, xraySliderFill}, xraySliderBar, function(percent)
	xrayStrength = math.floor(percent * 100)
	xraySliderFill.Size = UDim2.new(percent,0,1,0)
	xraySpeedLabel.Text = "Xray Strength: "..xrayStrength
	if xrayEnabled then
		refreshXray()
	end
end)

-- =====================
-- NOCLIP TOGGLE
-- =====================

local noclipEnabled = false

local noclipFrame = Instance.new("Frame")
noclipFrame.Size = UDim2.new(0,200,0,28)
noclipFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
noclipFrame.Parent = miscParent
Instance.new("UICorner", noclipFrame)

local noclipLabel = Instance.new("TextLabel")
noclipLabel.Size = UDim2.new(0,120,1,0)
noclipLabel.Position = UDim2.new(0,8,0,0)
noclipLabel.BackgroundTransparency = 1
noclipLabel.Text = "Noclip"
noclipLabel.Font = Enum.Font.Gotham
noclipLabel.TextSize = 14
noclipLabel.TextColor3 = Color3.new(1,1,1)
noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
noclipLabel.Parent = noclipFrame

local noclipSwitch = Instance.new("Frame")
noclipSwitch.Size = UDim2.new(0,34,0,16)
noclipSwitch.Position = UDim2.new(1,-42,0.5,-8)
noclipSwitch.BackgroundColor3 = Color3.fromRGB(80,80,80)
noclipSwitch.Parent = noclipFrame
Instance.new("UICorner",noclipSwitch)

local noclipKnob = Instance.new("Frame")
noclipKnob.Size = UDim2.new(0,14,0,14)
noclipKnob.Position = UDim2.new(0,1,0.5,-7)
noclipKnob.BackgroundColor3 = Color3.new(1,1,1)
noclipKnob.Parent = noclipSwitch
Instance.new("UICorner",noclipKnob)

local function toggleNoclip()
	noclipEnabled = not noclipEnabled

	TS:Create(noclipKnob,TweenInfo.new(0.25),
	{Position = noclipEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,1,0.5,-7)}):Play()

	TS:Create(noclipSwitch,TweenInfo.new(0.25),
	{BackgroundColor3 = noclipEnabled and Color3.fromRGB(170,0,255) or Color3.fromRGB(80,80,80)}):Play()
end

bindAimStyleToggle(noclipFrame, toggleNoclip)

RS.Stepped:Connect(function()
	if noclipEnabled then
		local char = player.Character
		if char then
			for _,v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
	end
end)
-- =====================
-- FAKE NAME + HIDE USER
-- =====================

local fakeName = "???"
local hideState = false
local hideConnection = nil
local panel = miscParent -- FIX: use the misc tab as parent

-- Fake Name TextBox
local textBoxFrame = Instance.new("Frame")
textBoxFrame.Size = UDim2.new(0,200,0,28)
textBoxFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
textBoxFrame.Parent = panel
Instance.new("UICorner", textBoxFrame)

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0,80,1,0)
label.Position = UDim2.new(0,8,0,0)
label.BackgroundTransparency = 1
label.Text = "Fake Name"
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.TextColor3 = Color3.new(1,1,1)
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = textBoxFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0,100,0,20)
inputBox.Position = UDim2.new(1,-110,0.5,-10)
inputBox.BackgroundColor3 = Color3.fromRGB(80,80,80)
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
inputBox.PlaceholderText = "???"
inputBox.ClearTextOnFocus = false
inputBox.Parent = textBoxFrame
Instance.new("UICorner",inputBox)

inputBox:GetPropertyChangedSignal("Text"):Connect(function()
    fakeName = inputBox.Text ~= "" and inputBox.Text or "???"
end)

-- Hide User Toggle
local hideFrame2 = Instance.new("Frame")
hideFrame2.Size = UDim2.new(0,200,0,28)
hideFrame2.BackgroundColor3 = Color3.fromRGB(50,50,50)
hideFrame2.Parent = panel
Instance.new("UICorner", hideFrame2)

local hideLabel2 = Instance.new("TextLabel")
hideLabel2.Size = UDim2.new(0,100,1,0)
hideLabel2.Position = UDim2.new(0,8,0,0)
hideLabel2.BackgroundTransparency = 1
hideLabel2.Text = "Hide User"
hideLabel2.Font = Enum.Font.Gotham
hideLabel2.TextSize = 14
hideLabel2.TextColor3 = Color3.new(1,1,1)
hideLabel2.TextXAlignment = Enum.TextXAlignment.Left
hideLabel2.Parent = hideFrame2

local switch = Instance.new("Frame")
switch.Size = UDim2.new(0,34,0,16)
switch.Position = UDim2.new(1,-42,0.5,-8)
switch.BackgroundColor3 = Color3.fromRGB(80,80,80)
switch.Parent = hideFrame2
Instance.new("UICorner",switch)

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0,14,0,14)
knob.Position = UDim2.new(0,1,0.5,-7)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = switch
Instance.new("UICorner",knob)

local function toggleHideUser()
    hideState = not hideState

    TS:Create(knob,TweenInfo.new(0.25),
        {Position = hideState and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,1,0.5,-7)}):Play()

    TS:Create(switch,TweenInfo.new(0.25),
        {BackgroundColor3 = hideState and Color3.fromRGB(170,0,255) or Color3.fromRGB(80,80,80)}):Play()

    if hideState then
        hideConnection = RS.RenderStepped:Connect(function()
            for _,v in pairs(CoreGui:GetDescendants()) do
                pcall(function()
                    if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                        if v.Text then
                            v.Text = v.Text:gsub(player.Name,fakeName)
                            v.Text = v.Text:gsub(player.DisplayName,fakeName)
                        end
                    end
                end)
            end
        end)
        table.insert(connections, hideConnection)
    else
        if hideConnection then
            hideConnection:Disconnect()
            hideConnection = nil
        end
    end
end

bindAimStyleToggle(hideFrame2, toggleHideUser)


-- =====================
-- SERVER HOP
-- =====================

local hopFrame = Instance.new("Frame")
hopFrame.Size = UDim2.new(0,200,0,28)
hopFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
hopFrame.Parent = miscParent
Instance.new("UICorner", hopFrame)

local hopButton = Instance.new("TextButton")
hopButton.Size = UDim2.new(1,0,1,0)
hopButton.BackgroundTransparency = 1
hopButton.Text = "Server Hop"
hopButton.Font = Enum.Font.Gotham
hopButton.TextSize = 14
hopButton.TextColor3 = Color3.new(1,1,1)
hopButton.Parent = hopFrame

hopButton.MouseButton1Click:Connect(function()
	local place = game.PlaceId
	TeleportService:Teleport(place, player)
end)

-- =====================
-- RIGHT SHIFT UI TOGGLE
-- =====================

local uiVisible = true

local function toggleUI()

	uiVisible = not uiVisible
	
	window.Visible = uiVisible
	
	if loaderBlur then
		loaderBlur.Size = uiVisible and 6 or 0
	end

	if uiVisible then
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = true
	else
		UIS.MouseIconEnabled = true
	end

end

-- keep mouse visible without overriding normal camera behavior
RS.RenderStepped:Connect(function()
	UIS.MouseIconEnabled = true
end)
-- legacy hardcoded RightShift toggle removed; a single rebindable listener is installed later

-- =====================================================
-- RYOICHIWARE UI ENHANCEMENT PACK (SAFE VERSION)
-- Adds:
-- animated tab underline glow
-- smoother dropdown animation
-- neon slider trails
-- glowing toggle knobs
-- =====================================================

task.spawn(function()

    local TS = game:GetService("TweenService")

    task.wait(1)

    -- ==============================
    -- GLOWING TOGGLE KNOBS
    -- ==============================
    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("Frame") and string.find(v.Name,"Knob") then
            if not v:FindFirstChild("UIStroke") then
                local glow = Instance.new("UIStroke")
                glow.Color = UI.Theme.Accent
                glow.Thickness = 1.5
                glow.Transparency = 0.35
                glow.Parent = v
            end
        end
    end

    -- ==============================
    -- NEON SLIDER TRAILS
    -- ==============================
    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("Frame") and string.find(v.Name,"Fill") then
            if not v:FindFirstChild("SliderGlow") then
                local glow = Instance.new("UIStroke")
                glow.Name = "SliderGlow"
                glow.Color = UI.Theme.Accent
                glow.Thickness = 1
                glow.Transparency = 0.4
                glow.Parent = v

                local grad = Instance.new("UIGradient")
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,UI.Theme.Accent),
                    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
                })
                grad.Rotation = 0
                grad.Parent = v
            end
        end
    end

    -- ==============================
    -- GLASS STYLE PANELS
    -- ==============================
    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("Frame") and v.BackgroundTransparency < 1 then
            if not v:FindFirstChild("GlassStroke") then
                local stroke = Instance.new("UIStroke")
                stroke.Name = "GlassStroke"
                stroke.Color = UI.Theme.Accent
                stroke.Transparency = 0.8
                stroke.Thickness = 1
                stroke.Parent = v
            end
        end
    end

    -- ==============================
    -- TAB UNDERLINE PULSE
    -- ==============================
    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("Frame") and v.BackgroundColor3 == UI.Theme.Accent and v.Size.Y.Offset <= 4 then
            task.spawn(function()
                local t = 0
                while v.Parent do
                    t += 0.04
                    local glow = (math.sin(t*2)+1)/2
                    v.BackgroundTransparency = 0.1 + (0.4*(1-glow))
                    task.wait(0.03)
                end
            end)
        end
    end

end)


-- =====================================================
-- RYOICHIWARE VISUAL POLISH PACK
-- Soft purple window lighting
-- cleaner outlines
-- nicer text rendering
-- =====================================================

task.spawn(function()

    task.wait(1)

    local TS = game:GetService("TweenService")

    -- ======================================
    -- SOFT PURPLE WINDOW GLOW
    -- ======================================
    if window and not window:FindFirstChild("WindowGlow") then

        local glow = Instance.new("Frame")
        glow.Name = "WindowGlow"
        glow.Size = UDim2.new(1,20,1,20)
        glow.Position = UDim2.new(0,-10,0,-10)
        glow.BackgroundColor3 = UI.Theme.Accent
        glow.BackgroundTransparency = 0.85
        glow.ZIndex = window.ZIndex - 1
        glow.Parent = window

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,12)
        corner.Parent = glow

        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,UI.Theme.Accent),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
        })
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.8),
            NumberSequenceKeypoint.new(1,1)
        })
        grad.Parent = glow

    end

    -- ======================================
    -- CLEANER OUTLINES
    -- ======================================
    for _,v in pairs(gui:GetDescendants()) do

        if v:IsA("UIStroke") then
            v.Thickness = 1
            v.Transparency = 0.6
        end

    end

    -- ======================================
    -- BETTER TEXT STYLE
    -- ======================================
    for _,v in pairs(gui:GetDescendants()) do

        if v:IsA("TextLabel") or v:IsA("TextButton") then

            v.TextStrokeTransparency = 0.7
            v.TextStrokeColor3 = Color3.fromRGB(0,0,0)

            if not v:FindFirstChild("TextGlow") then
                local stroke = Instance.new("UIStroke")
                stroke.Name = "TextGlow"
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                stroke.Color = UI.Theme.Accent
                stroke.Thickness = 0.5
                stroke.Transparency = 0.7
                stroke.Parent = v
            end

        end

    end

    -- ======================================
    -- SUBTLE WINDOW PULSE LIGHT
    -- ======================================
    task.spawn(function()

        local t = 0

        while gui.Parent do

            t += 0.03

            local glow = (math.sin(t*2)+1)/2

            if window:FindFirstChildOfClass("UIStroke") then
                window:FindFirstChildOfClass("UIStroke").Transparency = 0.35 + (0.25*(1-glow))
            end

            task.wait(0.03)

        end

    end)

end)



-- =====================================================
-- RYOICHIWARE BACKGROUND + OUTLINE POLISH PATCH
-- Soft background gradient
-- dimmer outlines
-- smoother panel look
-- =====================================================

task.spawn(function()

    task.wait(1)

    -- softer outlines
    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("UIStroke") then
            v.Thickness = 1
            v.Transparency = 0.75
        end
    end

    -- nicer background panels
    for _,v in pairs(gui:GetDescendants()) do
        if v:IsA("Frame") and v.BackgroundTransparency < 1 then

            if not v:FindFirstChild("SoftGradient") then
                local grad = Instance.new("UIGradient")
                grad.Name = "SoftGradient"
                grad.Rotation = 90
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(40,40,50)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(28,28,34))
                })
                grad.Parent = v
            end

        end
    end

    -- window glow softer
    if window and window:FindFirstChild("WindowGlow") then
        window.WindowGlow.BackgroundTransparency = 0.9
    end

end)



-- =====================================================
-- TAB COLOR FIX + ABOUT TAB + RUNTIME TIMER + FOOTER
-- =====================================================

task.spawn(function()
    task.wait(1)

    -- improve tab readability
    if tabButtons then
        for name,btn in pairs(tabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
            btn.TextColor3 = UI.Theme.Accent
            btn.TextStrokeTransparency = 0.8

            btn.MouseEnter:Connect(function()
                TS:Create(btn,TweenInfo.new(0.15),{
                    BackgroundColor3 = Color3.fromRGB(60,60,75)
                }):Play()
            end)

            btn.MouseLeave:Connect(function()
                TS:Create(btn,TweenInfo.new(0.15),{
                    BackgroundColor3 = Color3.fromRGB(45,45,55)
                }):Play()
            end)
        end
    end

    -- =====================
    -- CREATE ABOUT TAB
    -- =====================
    if window and tabButtonFrame then

        local aboutContent = Instance.new("ScrollingFrame")
        aboutContent.Name = "About"
        aboutContent.Size = UDim2.new(1,-20,1,-70)
        aboutContent.Position = UDim2.new(0,10,0,70)
        aboutContent.BackgroundTransparency = 1
        aboutContent.ScrollBarThickness = 6
        aboutContent.Visible = false
        aboutContent.Parent = window

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = aboutContent
        aboutContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        aboutContent.CanvasSize = UDim2.new(0,0,0,0)

        if tabContents then
            tabContents["About"] = aboutContent
        end

        -- older top About tab button removed; keep About content for the newer tab system

        -- =====================
        -- TIMER LABEL
        -- =====================

        local startTime = tick()

        local timerFrame = UI.CreateCard(aboutContent,28)

        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(1,0,1,0)
        timerLabel.BackgroundTransparency = 1
        timerLabel.Text = "UI Runtime: 0s"
        timerLabel.Font = Enum.Font.Gotham
        timerLabel.TextSize = 14
        timerLabel.TextColor3 = UI.Theme.Text
        timerLabel.Parent = timerFrame

        RS.RenderStepped:Connect(function()
            local runtime = math.floor(tick() - startTime)
            timerLabel.Text = "UI Runtime: "..runtime.."s"
        end)

        -- info text
        local infoFrame = UI.CreateCard(aboutContent,28)

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1,0,1,0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "Ryoichiware UI System"
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 14
        infoLabel.TextColor3 = UI.Theme.Text
        infoLabel.Parent = infoFrame

    end

    -- =====================
    -- FOOTER TEXT
    -- =====================

    if window and not window:FindFirstChild("RyoichiFooter") then

        local footer = Instance.new("TextLabel")
        footer.Name = "RyoichiFooter"
        footer.Size = UDim2.new(1,0,0,16)
        footer.Position = UDim2.new(0,0,1,-18)
        footer.BackgroundTransparency = 1
        footer.Text = "Made by Ryoichi"
        footer.Font = Enum.Font.Gotham
        footer.TextSize = 11
        footer.TextColor3 = Color3.fromRGB(180,180,180)
        footer.TextXAlignment = Enum.TextXAlignment.Center
        footer.Parent = window

    end

end)


-- =====================================================

-- REBUILT MERGE PATCH (SAFE FRONT LAYER)
-- Recreates the previously promised additions without reintroducing the old
-- duplicate tab / dropdown stack issues.
-- =====================================================

task.spawn(function()
    task.wait(0.2)

    local LogService = game:GetService("LogService")
    local MarketplaceService = game:GetService("MarketplaceService")

    local TAB_ORDER = {"Main", "Misc", "Players", "About"}
    local TAB_ICONS = {
        Main = utf8.char(0x25C8),
        Misc = utf8.char(0x2699),
        Players = utf8.char(0x263B),
        About = utf8.char(0x24D8),
    }

    local COLORS = {
        Tab = Color3.fromRGB(35,31,48),
        TabActive = Color3.fromRGB(62,53,88),
        TabStroke = Color3.fromRGB(112,94,154),
        TabStrokeActive = Color3.fromRGB(186,146,255),
        Card = Color3.fromRGB(31,28,43),
        Card2 = Color3.fromRGB(39,35,54),
        Soft = Color3.fromRGB(46,41,63),
        Text = Color3.fromRGB(242,238,255),
        Sub = Color3.fromRGB(186,177,214),
        Accent = Color3.fromRGB(182,92,255),
        AccentBright = Color3.fromRGB(226,200,255),
        Off = Color3.fromRGB(84,80,98),
        White = Color3.fromRGB(246,246,250),
    }

    local selectedPlayer = nil
    local spectatingPlayer = nil
    local playerSearchBox = nil
    local consoleScroll = nil
    local consoleSearch = nil
    local consoleEntries = {}
    local uiToggleKey = Enum.KeyCode.RightShift
    local waitingForUiToggleKey = false
    local uiToggleLabel = nil

    local function makeCorner(obj, radius)
        local c = obj:FindFirstChildOfClass("UICorner")
        if not c then
            c = Instance.new("UICorner")
            c.Parent = obj
        end
        c.CornerRadius = radius or UDim.new(0, 8)
        return c
    end

    local function makeStroke(obj, color, transparency, thickness)
        local s = obj:FindFirstChildOfClass("UIStroke")
        if not s then
            s = Instance.new("UIStroke")
            s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            s.Parent = obj
        end
        s.Color = color or COLORS.TabStroke
        s.Transparency = transparency == nil and 0.18 or transparency
        s.Thickness = thickness or 1
        return s
    end

    local function safeTween(obj, time, props)
        local tw = TS:Create(obj, TweenInfo.new(time or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        tw:Play()
        return tw
    end

    local function styleButton(btn, active)
        btn.AutoButtonColor = false
        btn.BackgroundColor3 = active and COLORS.TabActive or COLORS.Tab
        btn.TextColor3 = COLORS.Text
        btn.Font = active and Enum.Font.GothamBold or Enum.Font.GothamMedium
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.TextXAlignment = Enum.TextXAlignment.Left
        makeCorner(btn, UDim.new(0, 10))
        makeStroke(btn, active and COLORS.TabStrokeActive or COLORS.TabStroke, active and 0.04 or 0.18, 1)
        local pad = btn:FindFirstChild("StablePad")
        if not pad then
            pad = Instance.new("UIPadding")
            pad.Name = "StablePad"
            pad.PaddingLeft = UDim.new(0, 12)
            btn.Parent = btn.Parent
            pad.Parent = btn
        end
    end

    local function hideOldTabButtons()
        if not tabButtonFrame then return end
        for _, child in ipairs(tabButtonFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = false
                child.Active = false
            end
        end
    end

    local function ensureTab(name)
        if tabContents[name] then return tabContents[name] end
        local content = Instance.new("ScrollingFrame")
        content.Name = name
        content.Size = UDim2.new(1,-160,1,-84)
        content.Position = UDim2.new(0,146,0,72)
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.ScrollBarThickness = 5
        content.Visible = false
        content.Active = true
        content.ScrollingEnabled = true
        content.CanvasSize = UDim2.new(0,0,0,0)
        content.AutomaticCanvasSize = Enum.AutomaticSize.None
        content.Parent = window

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0,8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = content

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 12)
        end)

        tabContents[name] = content
        return content
    end

    local playersTab = ensureTab("Players")
    local aboutTab = tabContents["About"] or ensureTab("About")

    local frontRail = window:FindFirstChild("FrontTabRail")
    if not frontRail then
        frontRail = Instance.new("Frame")
        frontRail.Name = "FrontTabRail"
        frontRail.BackgroundTransparency = 1
        frontRail.BorderSizePixel = 0
        frontRail.ZIndex = 700
        frontRail.Parent = window
    end

    local function setPageGeometry()
        frontRail.Size = UDim2.new(0,118,1,-100)
        frontRail.Position = UDim2.new(0,12,0,72)
        for _, name in ipairs(TAB_ORDER) do
            local page = tabContents[name]
            if page then
                page.Position = UDim2.new(0,146,0,72)
                page.Size = UDim2.new(1,-160,1,-84)
                page.ScrollBarThickness = 5
                page.BackgroundTransparency = 1
                page.BorderSizePixel = 0
            end
        end
    end

    local function refreshRail()
        hideOldTabButtons()
        setPageGeometry()
        for i, name in ipairs(TAB_ORDER) do
            local btn = frontRail:FindFirstChild("Btn_" .. name)
            if not btn then
                btn = Instance.new("TextButton")
                btn.Name = "Btn_" .. name
                btn.Size = UDim2.new(1,0,0,34)
                btn.Position = UDim2.new(0,0,0,(i-1)*40)
                btn.ZIndex = 701
                btn.Parent = frontRail
                btn.MouseButton1Click:Connect(function()
                    activeTab = name
                    for pageName, frame in pairs(tabContents) do
                        if frame then
                            frame.Visible = (pageName == name)
                            frame.Active = (pageName == name)
                        end
                    end
                    refreshRail()
                end)
            end
            btn.Position = UDim2.new(0,0,0,(i-1)*40)
            btn.Text = "  " .. (TAB_ICONS[name] or "•") .. "  " .. name
            styleButton(btn, activeTab == name)
            btn.Visible = true
            btn.Active = true
        end
        if indicator then
            indicator.Visible = false
            indicator.Size = UDim2.new(0,0,0,0)
            indicator.BackgroundTransparency = 1
        end
    end

    -- Force pages to behave as single visible layer
    local function showOnly(tabName)
        activeTab = tabName
        for name, frame in pairs(tabContents) do
            if frame then
                frame.Visible = (name == tabName)
                frame.Active = (name == tabName)
            end
        end
        refreshRail()
    end

    -- Fix about label if older patch renamed it weirdly
    if tabButtons["About"] then
        tabButtons["About"].Text = "About"
    end

    -- Remove greyer hover flashes on existing controls
    for _, obj in ipairs(window:GetDescendants()) do
        if obj:IsA("TextButton") then
            obj.AutoButtonColor = false
        end
    end

    -- Thinner, brighter slider outlines
    local function brightenSlider(bar, knob)
        if not bar then return end
        makeStroke(bar, COLORS.AccentBright, 0.22, 0.75)
        if knob then
            local s = knob:FindFirstChildOfClass("UIStroke")
            if s then s:Destroy() end
        end
    end
    brightenSlider(sliderBar, sliderKnob)
    brightenSlider(fovBar, fovSliderKnob)
    brightenSlider(smoothBar, smoothKnob)

    -- Remove weird knob outlines/glow if present
    local function stripKnob(obj)
        if not obj or not obj:IsA("GuiObject") then return end
        local lname = string.lower(obj.Name or "")
        if lname:find("knob") or lname:find("thumb") or lname:find("circle") then
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("UIStroke") then child:Destroy() end
                if child:IsA("Frame") and string.lower(child.Name or ""):find("glow") then
                    child:Destroy()
                end
            end
            obj.BorderSizePixel = 0
        end
    end
    for _, obj in ipairs(window:GetDescendants()) do
        stripKnob(obj)
    end

    -- Force FOV off by default everywhere
    fovCircleEnabled = false
    if fovCircle then pcall(function() fovCircle.Visible = false end) end
    if fovSwitch then fovSwitch.BackgroundColor3 = COLORS.Off end
    if fovKnob then fovKnob.Position = UDim2.new(0,1,0.5,-7) end

    -- Improved Aim Part area: hide old cycle row and replace with one dropdown once
    if partFrame then
        partFrame.Visible = false
        partFrame.Size = UDim2.new(1,0,0,0)
    end
    local aimPartsExtended = {
        "Head","HumanoidRootPart","UpperTorso","LowerTorso","Torso",
        "LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm",
        "LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftFoot","RightFoot"
    }
    local existingAimPartDropdown = aimContainer and aimContainer:FindFirstChild("SafeAimPartDropdown")
    if aimContainer and not existingAimPartDropdown then
        local dropHolder = UI.CreateDropdown(aimContainer, "Aim Part")
        dropHolder.Name = "SafeAimPartDropdown"
        local parentFrame = dropHolder.Parent
        if parentFrame then
            parentFrame.LayoutOrder = 1000
            parentFrame.BackgroundColor3 = COLORS.Card2
            local hdr = parentFrame:FindFirstChildWhichIsA("TextButton")
            if hdr then
                hdr.AutoButtonColor = false
            end
        end
        local selectedRows = {}
        local function updateRows(selectedName)
            for partName, row in pairs(selectedRows) do
                row.BackgroundColor3 = (partName == selectedName) and COLORS.TabActive or COLORS.Card
            end
            local hdr = parentFrame and parentFrame:FindFirstChildWhichIsA("TextButton")
            if hdr then
                local isOpen = dropHolder.Visible and dropHolder.Size.Y.Offset > 0
                hdr.Text = "Aim Part: " .. tostring(selectedName) .. (isOpen and " ▼" or " ▶")
            end
        end
        for _, partName in ipairs(aimPartsExtended) do
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1,0,0,28)
            row.BackgroundColor3 = COLORS.Card
            row.BorderSizePixel = 0
            row.Text = partName
            row.TextColor3 = COLORS.Text
            row.Font = Enum.Font.Gotham
            row.TextSize = 14
            row.AutoButtonColor = false
            row.Parent = dropHolder
            makeCorner(row, UDim.new(0,8))
            makeStroke(row, COLORS.TabStroke, 0.2, 1)
            selectedRows[partName] = row
            row.MouseButton1Click:Connect(function()
                aimPart = partName
                updateRows(partName)
            end)
        end
        updateRows(aimPart or "Head")
    end

    -- Players tab two-column layout
    local host = playersTab:FindFirstChild("PlayersHost")
    if not host then
        host = Instance.new("Frame")
        host.Name = "PlayersHost"
        host.BackgroundTransparency = 1
        host.Size = UDim2.new(1,0,0,0)
        host.Parent = playersTab
    end

    local function ensureColumn(parent, name)
        local col = parent:FindFirstChild(name)
        if not col then
            col = Instance.new("Frame")
            col.Name = name
            col.BackgroundTransparency = 1
            col.Parent = parent
            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0,8)
            layout.Parent = col
        end
        return col, col:FindFirstChildOfClass("UIListLayout")
    end

    local leftCol, leftLayout2 = ensureColumn(host, "LeftColumn")
    local rightCol, rightLayout2 = ensureColumn(host, "RightColumn")

    local function fullWidth(obj)
        if obj and obj:IsA("GuiObject") then
            obj.Size = UDim2.new(1,0,0,obj.Size.Y.Offset > 0 and obj.Size.Y.Offset or math.max(28,obj.AbsoluteSize.Y))
        end
    end

    local lastPlayerColumnWidth = nil
    local relayoutPlayersQueued = false

    local function applyPlayerColumnWidths(colWidth)
        if lastPlayerColumnWidth == colWidth then return end
        lastPlayerColumnWidth = colWidth
        for _, col in ipairs({leftCol, rightCol}) do
            for _, child in ipairs(col:GetChildren()) do
                if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    fullWidth(child)
                end
            end
        end
    end

    local function relayoutPlayers()
        local width = math.max(playersTab.AbsoluteSize.X, 320)
        local gap = 10
        local colWidth = math.floor((width - gap) / 2)
        leftCol.Position = UDim2.new(0,0,0,0)
        leftCol.Size = UDim2.new(0,colWidth,0,leftLayout2.AbsoluteContentSize.Y)
        rightCol.Position = UDim2.new(0,colWidth + gap,0,0)
        rightCol.Size = UDim2.new(0,colWidth,0,rightLayout2.AbsoluteContentSize.Y)
        applyPlayerColumnWidths(colWidth)
        local total = math.max(leftLayout2.AbsoluteContentSize.Y, rightLayout2.AbsoluteContentSize.Y)
        host.Size = UDim2.new(1,0,0,total)
        playersTab.CanvasSize = UDim2.new(0,0,0,total + 12)
    end

    local function queueRelayoutPlayers()
        if relayoutPlayersQueued then return end
        relayoutPlayersQueued = true
        task.defer(function()
            relayoutPlayersQueued = false
            relayoutPlayers()
        end)
    end

    leftLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(queueRelayoutPlayers)
    rightLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(queueRelayoutPlayers)

    local infoCard = rightCol:FindFirstChild("PlayersInfoCard")
    if not infoCard then
        infoCard = Instance.new("Frame")
        infoCard.Name = "PlayersInfoCard"
        infoCard.Size = UDim2.new(1,0,0,74)
        infoCard.BackgroundColor3 = COLORS.Card2
        infoCard.BorderSizePixel = 0
        infoCard.LayoutOrder = 0
        infoCard.Parent = rightCol
        makeCorner(infoCard, UDim.new(0,8))
        makeStroke(infoCard, COLORS.TabStroke, 0.18, 1)

        local ttl = Instance.new("TextLabel")
        ttl.BackgroundTransparency = 1
        ttl.Position = UDim2.new(0,10,0,8)
        ttl.Size = UDim2.new(1,-20,0,20)
        ttl.Text = "Players"
        ttl.TextXAlignment = Enum.TextXAlignment.Left
        ttl.TextColor3 = COLORS.Text
        ttl.Font = Enum.Font.GothamBold
        ttl.TextSize = 15
        ttl.Parent = infoCard

        local body = Instance.new("TextLabel")
        body.BackgroundTransparency = 1
        body.Position = UDim2.new(0,10,0,30)
        body.Size = UDim2.new(1,-20,0,32)
        body.TextWrapped = true
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.Text = "Live server list and selected-player actions."
        body.TextColor3 = COLORS.Sub
        body.Font = Enum.Font.Gotham
        body.TextSize = 12
        body.Parent = infoCard
    end

    local gameCard = rightCol:FindFirstChild("ExtraStat_Game")
    if not gameCard then
        gameCard = Instance.new("Frame")
        gameCard.Name = "ExtraStat_Game"
        gameCard.Size = UDim2.new(1,0,0,34)
        gameCard.BackgroundColor3 = COLORS.Card2
        gameCard.BorderSizePixel = 0
        gameCard.LayoutOrder = 1
        gameCard.Parent = rightCol
        makeCorner(gameCard, UDim.new(0,8))
        makeStroke(gameCard, COLORS.TabStroke, 0.18, 1)
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1,-16,1,0)
        lbl.Position = UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = "Game: Loading..."
        lbl.TextColor3 = COLORS.Text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = gameCard
    end

    local countCard = rightCol:FindFirstChild("ExtraStat_Players")
    if not countCard then
        countCard = Instance.new("Frame")
        countCard.Name = "ExtraStat_Players"
        countCard.Size = UDim2.new(1,0,0,34)
        countCard.BackgroundColor3 = COLORS.Card2
        countCard.BorderSizePixel = 0
        countCard.LayoutOrder = 2
        countCard.Parent = rightCol
        makeCorner(countCard, UDim.new(0,8))
        makeStroke(countCard, COLORS.TabStroke, 0.18, 1)
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Size = UDim2.new(1,-16,1,0)
        lbl.Position = UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = "Players: 0"
        lbl.TextColor3 = COLORS.Text
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = countCard
    end

    local actionCard = rightCol:FindFirstChild("PlayerActionCard")
    if not actionCard then
        actionCard = Instance.new("Frame")
        actionCard.Name = "PlayerActionCard"
        actionCard.Size = UDim2.new(1,0,0,164)
        actionCard.BackgroundColor3 = COLORS.Card2
        actionCard.BorderSizePixel = 0
        actionCard.LayoutOrder = 3
        actionCard.Parent = rightCol
        makeCorner(actionCard, UDim.new(0,8))
        makeStroke(actionCard, COLORS.TabStroke, 0.18, 1)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Name = "Title"
        titleLbl.Size = UDim2.new(1,-20,0,18)
        titleLbl.Position = UDim2.new(0,10,0,8)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = "Selected Player"
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextColor3 = COLORS.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 14
        titleLbl.Parent = actionCard

        local picked = Instance.new("TextLabel")
        picked.Name = "Picked"
        picked.Size = UDim2.new(1,-20,0,18)
        picked.Position = UDim2.new(0,10,0,32)
        picked.BackgroundTransparency = 1
        picked.Text = "None selected"
        picked.TextXAlignment = Enum.TextXAlignment.Left
        picked.TextColor3 = COLORS.Text
        picked.Font = Enum.Font.GothamMedium
        picked.TextSize = 13
        picked.Parent = actionCard

        local pickedUser = Instance.new("TextLabel")
        pickedUser.Name = "PickedUser"
        pickedUser.Size = UDim2.new(1,-20,0,16)
        pickedUser.Position = UDim2.new(0,10,0,50)
        pickedUser.BackgroundTransparency = 1
        pickedUser.Text = ""
        pickedUser.TextXAlignment = Enum.TextXAlignment.Left
        pickedUser.TextColor3 = COLORS.Sub
        pickedUser.Font = Enum.Font.Gotham
        pickedUser.TextSize = 11
        pickedUser.Parent = actionCard

        local note = Instance.new("TextLabel")
        note.Name = "Note"
        note.Size = UDim2.new(1,-20,0,20)
        note.Position = UDim2.new(0,10,0,72)
        note.BackgroundTransparency = 1
        note.Text = ""
        note.TextWrapped = true
        note.TextXAlignment = Enum.TextXAlignment.Left
        note.TextYAlignment = Enum.TextYAlignment.Top
        note.TextColor3 = COLORS.Sub
        note.Font = Enum.Font.Gotham
        note.TextSize = 12
        note.Parent = actionCard

        local teleportBtn = Instance.new("TextButton")
        teleportBtn.Name = "TeleportButton"
        teleportBtn.Size = UDim2.new(0.5,-15,0,28)
        teleportBtn.Position = UDim2.new(0,10,0,104)
        teleportBtn.BackgroundColor3 = COLORS.Soft
        teleportBtn.BorderSizePixel = 0
        teleportBtn.Text = "Teleport"
        teleportBtn.TextColor3 = COLORS.Text
        teleportBtn.Font = Enum.Font.GothamMedium
        teleportBtn.TextSize = 13
        teleportBtn.AutoButtonColor = false
        teleportBtn.Parent = actionCard
        makeCorner(teleportBtn, UDim.new(0,8))
        makeStroke(teleportBtn, COLORS.TabStrokeActive, 0.12, 1)

        local spectateBtn = Instance.new("TextButton")
        spectateBtn.Name = "SpectateButton"
        spectateBtn.Size = UDim2.new(0.5,-15,0,28)
        spectateBtn.Position = UDim2.new(0.5,5,0,104)
        spectateBtn.BackgroundColor3 = COLORS.Accent
        spectateBtn.BorderSizePixel = 0
        spectateBtn.Text = "Spectate"
        spectateBtn.TextColor3 = COLORS.Text
        spectateBtn.Font = Enum.Font.GothamMedium
        spectateBtn.TextSize = 13
        spectateBtn.AutoButtonColor = false
        spectateBtn.Parent = actionCard
        makeCorner(spectateBtn, UDim.new(0,8))
        makeStroke(spectateBtn, COLORS.TabStrokeActive, 0.12, 1)

        teleportBtn.MouseButton1Click:Connect(function()
            if not selectedPlayer or selectedPlayer == player then return end
            local myChar = player.Character
            local targetChar = selectedPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if myRoot and targetRoot then
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
            end
        end)

        spectateBtn.MouseButton1Click:Connect(function()
            local cam = workspace.CurrentCamera
            if spectatingPlayer and spectatingPlayer == selectedPlayer then
                spectatingPlayer = nil
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    cam.CameraType = Enum.CameraType.Custom
                    cam.CameraSubject = hum
                end
                spectateBtn.Text = "Spectate"
                return
            end
            if not selectedPlayer then return end
            local hum = selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                cam.CameraType = Enum.CameraType.Custom
                cam.CameraSubject = hum
                spectatingPlayer = selectedPlayer
                spectateBtn.Text = "Unspectate"
            end
        end)
    end

    local listCard = leftCol:FindFirstChild("ServerPlayersCard")
    if not listCard then
        listCard = Instance.new("Frame")
        listCard.Name = "ServerPlayersCard"
        listCard.Size = UDim2.new(1,0,0,280)
        listCard.BackgroundColor3 = COLORS.Card2
        listCard.BorderSizePixel = 0
        listCard.LayoutOrder = 0
        listCard.Parent = leftCol
        makeCorner(listCard, UDim.new(0,8))
        makeStroke(listCard, COLORS.TabStroke, 0.18, 1)

        local header = Instance.new("TextLabel")
        header.Name = "Header"
        header.Size = UDim2.new(1,-16,0,22)
        header.Position = UDim2.new(0,8,0,8)
        header.BackgroundTransparency = 1
        header.Text = "Server Players"
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.TextColor3 = COLORS.Text
        header.Font = Enum.Font.GothamBold
        header.TextSize = 14
        header.Parent = listCard

        local sub = Instance.new("TextLabel")
        sub.Name = "Sub"
        sub.Size = UDim2.new(1,-16,0,16)
        sub.Position = UDim2.new(0,8,0,28)
        sub.BackgroundTransparency = 1
        sub.Text = "Live list with search"
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.TextColor3 = COLORS.Sub
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 12
        sub.Parent = listCard

        playerSearchBox = Instance.new("TextBox")
        playerSearchBox.Name = "PlayerSearchBox"
        playerSearchBox.Size = UDim2.new(1,-12,0,26)
        playerSearchBox.Position = UDim2.new(0,6,0,50)
        playerSearchBox.BackgroundColor3 = COLORS.Card
        playerSearchBox.BorderSizePixel = 0
        playerSearchBox.TextColor3 = COLORS.Text
        playerSearchBox.PlaceholderColor3 = COLORS.Sub
        playerSearchBox.PlaceholderText = "Search"
        playerSearchBox.Text = ""
        playerSearchBox.ClearTextOnFocus = false
        playerSearchBox.Font = Enum.Font.Gotham
        playerSearchBox.TextSize = 12
        playerSearchBox.Parent = listCard
        makeCorner(playerSearchBox, UDim.new(0,8))
        makeStroke(playerSearchBox, COLORS.TabStroke, 0.18, 1)

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "PlayerList"
        scroll.Size = UDim2.new(1,-12,1,-88)
        scroll.Position = UDim2.new(0,6,0,82)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 5
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.Parent = listCard

        local layout = Instance.new("UIListLayout")
        layout.Name = "PlayerListLayout"
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0,6)
        layout.Parent = scroll

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0,2)
        pad.PaddingBottom = UDim.new(0,2)
        pad.PaddingLeft = UDim.new(0,2)
        pad.PaddingRight = UDim.new(0,2)
        pad.Parent = scroll

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
        end)
    else
        playerSearchBox = listCard:FindFirstChild("PlayerSearchBox")
    end

    local playerList = listCard and listCard:FindFirstChild("PlayerList")
    local playerListLayout = playerList and playerList:FindFirstChild("PlayerListLayout")

    local function updateSelectedCard()
        local picked = actionCard:FindFirstChild("Picked")
        local pickedUser = actionCard:FindFirstChild("PickedUser")
        local note = actionCard:FindFirstChild("Note")
        local spectateBtn = actionCard:FindFirstChild("SpectateButton")
        if selectedPlayer then
            if picked then picked.Text = selectedPlayer.DisplayName end
            if pickedUser then pickedUser.Text = "@" .. selectedPlayer.Name end
            if note then note.Text = "Player selected from the live server list." end
            if spectateBtn then
                spectateBtn.Text = (spectatingPlayer == selectedPlayer) and "Unspectate" or "Spectate"
            end
        else
            if picked then picked.Text = "None selected" end
            if pickedUser then pickedUser.Text = "" end
            if note then note.Text = "" end
            if spectateBtn then spectateBtn.Text = "Spectate" end
        end
    end

    local function setThumb(imageLabel, userId)
        task.spawn(function()
            local ok, content = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and imageLabel and imageLabel.Parent then
                imageLabel.Image = content
            end
        end)
    end

    local function rebuildPlayerList()
        if not playerList then return end
        for _, child in ipairs(playerList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        local playersNow = Players:GetPlayers()
        table.sort(playersNow, function(a, b)
            if a == player then return true end
            if b == player then return false end
            return string.lower(a.DisplayName) < string.lower(b.DisplayName)
        end)

        local sub = listCard and listCard:FindFirstChild("Sub")
        if sub then
            sub.Text = tostring(#playersNow) .. " players online"
        end
        local countLabel = countCard and countCard:FindFirstChild("Label")
        if countLabel then
            countLabel.Text = "Players: " .. tostring(#playersNow) .. " / " .. tostring(Players.MaxPlayers)
        end

        for _, plr in ipairs(playersNow) do
            local row = Instance.new("Frame")
            row.Name = "Player_" .. tostring(plr.UserId)
            row.Size = UDim2.new(1,-4,0,42)
            row.BackgroundColor3 = (selectedPlayer == plr) and COLORS.TabActive or COLORS.Card
            row.BorderSizePixel = 0
            row.Parent = playerList
            makeCorner(row, UDim.new(0,8))
            makeStroke(row, (selectedPlayer == plr) and COLORS.TabStrokeActive or COLORS.TabStroke, (selectedPlayer == plr) and 0.06 or 0.2, 1)
            row:SetAttribute("PlayerName", plr.Name)

            local thumb = Instance.new("ImageLabel")
            thumb.Name = "Thumb"
            thumb.Size = UDim2.new(0,28,0,28)
            thumb.Position = UDim2.new(0,8,0.5,-14)
            thumb.BackgroundColor3 = COLORS.Soft
            thumb.BorderSizePixel = 0
            thumb.Parent = row
            makeCorner(thumb, UDim.new(1,0))
            setThumb(thumb, plr.UserId)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Name = "Name"
            nameLbl.Size = UDim2.new(1,-92,0,16)
            nameLbl.Position = UDim2.new(0,44,0,6)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = plr.DisplayName
            nameLbl.TextColor3 = COLORS.Text
            nameLbl.Font = Enum.Font.GothamMedium
            nameLbl.TextSize = 13
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.Parent = row

            local userLbl = Instance.new("TextLabel")
            userLbl.Name = "User"
            userLbl.Size = UDim2.new(1,-92,0,14)
            userLbl.Position = UDim2.new(0,44,0,22)
            userLbl.BackgroundTransparency = 1
            userLbl.Text = "@" .. plr.Name
            userLbl.TextColor3 = COLORS.Sub
            userLbl.Font = Enum.Font.Gotham
            userLbl.TextSize = 11
            userLbl.TextXAlignment = Enum.TextXAlignment.Left
            userLbl.TextTruncate = Enum.TextTruncate.AtEnd
            userLbl.Parent = row

            local badge = Instance.new("TextLabel")
            badge.Name = "Badge"
            badge.Size = UDim2.new(0,42,0,18)
            badge.Position = UDim2.new(1,-50,0.5,-9)
            badge.BackgroundColor3 = (plr == player) and COLORS.Accent or COLORS.Soft
            badge.BorderSizePixel = 0
            badge.Text = (plr == player) and "YOU" or "USER"
            badge.TextColor3 = COLORS.Text
            badge.Font = Enum.Font.GothamBold
            badge.TextSize = 10
            badge.Parent = row
            makeCorner(badge, UDim.new(1,0))

            local overlay = Instance.new("TextButton")
            overlay.Name = "SelectionOverlay"
            overlay.Size = UDim2.new(1,0,1,0)
            overlay.BackgroundTransparency = 1
            overlay.Text = ""
            overlay.AutoButtonColor = false
            overlay.ZIndex = 10
            overlay.Parent = row
            overlay.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                updateSelectedCard()
                rebuildPlayerList()
            end)
        end

        if playerSearchBox then
            local query = string.lower(playerSearchBox.Text or "")
            for _, row in ipairs(playerList:GetChildren()) do
                if row:IsA("Frame") and row.Name:match("^Player_") then
                    local n = row:FindFirstChild("Name")
                    local u = row:FindFirstChild("User")
                    local hay = string.lower((n and n.Text or "") .. " " .. (u and u.Text or ""))
                    row.Visible = (query == "" or hay:find(query, 1, true) ~= nil)
                end
            end
        end
        relayoutPlayers()
    end

    if playerSearchBox and not playerSearchBox:FindFirstChild("Bound") then
        local tag = Instance.new("BoolValue")
        tag.Name = "Bound"
        tag.Parent = playerSearchBox
        playerSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            rebuildPlayerList()
        end)
    end

    rebuildPlayerList()
    Players.PlayerAdded:Connect(rebuildPlayerList)
    Players.PlayerRemoving:Connect(function(plr)
        if selectedPlayer == plr then selectedPlayer = nil end
        if spectatingPlayer == plr then
            spectatingPlayer = nil
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
                workspace.CurrentCamera.CameraSubject = hum
            end
        end
        rebuildPlayerList()
        updateSelectedCard()
    end)

    -- Game name stat
    task.spawn(function()
        local placeText = "Unknown Place"
        pcall(function()
            placeText = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)
        local lbl = gameCard and gameCard:FindFirstChild("Label")
        if lbl then lbl.Text = "Game: " .. tostring(placeText) end
    end)

    -- About tab console
    local aboutHost = aboutTab:FindFirstChild("TwoColumnHost")
    local aboutLeft, aboutRight
    if not aboutHost then
        aboutHost = Instance.new("Frame")
        aboutHost.Name = "TwoColumnHost"
        aboutHost.BackgroundTransparency = 1
        aboutHost.Size = UDim2.new(1,0,0,0)
        aboutHost.Parent = aboutTab
        aboutLeft, _ = ensureColumn(aboutHost, "LeftColumn")
        aboutRight, _ = ensureColumn(aboutHost, "RightColumn")
    else
        aboutLeft = aboutHost:FindFirstChild("LeftColumn") or ensureColumn(aboutHost, "LeftColumn")
        aboutRight = aboutHost:FindFirstChild("RightColumn") or ensureColumn(aboutHost, "RightColumn")
    end
    if typeof(aboutLeft) == "table" then aboutLeft = aboutLeft[1] end
    if typeof(aboutRight) == "table" then aboutRight = aboutRight[1] end

    local consoleCard = aboutRight and aboutRight:FindFirstChild("DevConsoleCard")
    if not consoleCard and aboutRight then
        consoleCard = Instance.new("Frame")
        consoleCard.Name = "DevConsoleCard"
        consoleCard.Size = UDim2.new(1,0,0,254)
        consoleCard.BackgroundColor3 = COLORS.Card2
        consoleCard.BorderSizePixel = 0
        consoleCard.LayoutOrder = 999
        consoleCard.Parent = aboutRight
        makeCorner(consoleCard, UDim.new(0,8))
        makeStroke(consoleCard, COLORS.TabStroke, 0.18, 1)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Name = "Title"
        titleLbl.Size = UDim2.new(1,-96,0,18)
        titleLbl.Position = UDim2.new(0,10,0,8)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = "Developer Console"
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.TextColor3 = COLORS.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 14
        titleLbl.Parent = consoleCard

        local openBtn = Instance.new("TextButton")
        openBtn.Name = "OpenButton"
        openBtn.Size = UDim2.new(0,72,0,24)
        openBtn.Position = UDim2.new(1,-82,0,6)
        openBtn.BackgroundColor3 = COLORS.Soft
        openBtn.BorderSizePixel = 0
        openBtn.Text = "Open"
        openBtn.TextColor3 = COLORS.Text
        openBtn.Font = Enum.Font.GothamMedium
        openBtn.TextSize = 12
        openBtn.AutoButtonColor = false
        openBtn.Parent = consoleCard
        makeCorner(openBtn, UDim.new(0,8))
        makeStroke(openBtn, COLORS.TabStrokeActive, 0.12, 1)

        consoleSearch = Instance.new("TextBox")
        consoleSearch.Name = "ConsoleSearch"
        consoleSearch.Size = UDim2.new(1,-20,0,26)
        consoleSearch.Position = UDim2.new(0,10,0,38)
        consoleSearch.BackgroundColor3 = COLORS.Card
        consoleSearch.BorderSizePixel = 0
        consoleSearch.TextColor3 = COLORS.Text
        consoleSearch.PlaceholderColor3 = COLORS.Sub
        consoleSearch.PlaceholderText = "Search console"
        consoleSearch.ClearTextOnFocus = false
        consoleSearch.Text = ""
        consoleSearch.Font = Enum.Font.Gotham
        consoleSearch.TextSize = 12
        consoleSearch.Visible = false
        consoleSearch.Parent = consoleCard
        makeCorner(consoleSearch, UDim.new(0,8))
        makeStroke(consoleSearch, COLORS.TabStroke, 0.18, 1)

        consoleScroll = Instance.new("ScrollingFrame")
        consoleScroll.Name = "ConsoleScroll"
        consoleScroll.Size = UDim2.new(1,-20,1,-74)
        consoleScroll.Position = UDim2.new(0,10,0,70)
        consoleScroll.BackgroundColor3 = COLORS.Card
        consoleScroll.BorderSizePixel = 0
        consoleScroll.ScrollBarThickness = 5
        consoleScroll.CanvasSize = UDim2.new(0,0,0,0)
        consoleScroll.Visible = false
        consoleScroll.Parent = consoleCard
        makeCorner(consoleScroll, UDim.new(0,8))
        makeStroke(consoleScroll, COLORS.TabStroke, 0.18, 1)

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0,4)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = consoleScroll
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0,6)
        pad.PaddingBottom = UDim.new(0,6)
        pad.PaddingLeft = UDim.new(0,6)
        pad.PaddingRight = UDim.new(0,6)
        pad.Parent = consoleScroll

        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            consoleScroll.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 12)
        end)

        local function addConsoleEntry(text, messageType)
            if #consoleEntries >= 140 then
                local old = table.remove(consoleEntries, 1)
                if old and old.Parent then old:Destroy() end
            end
            local row = Instance.new("TextLabel")
            row.Size = UDim2.new(1,0,0,18)
            row.BackgroundTransparency = 1
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.TextTruncate = Enum.TextTruncate.AtEnd
            row.Font = Enum.Font.Code
            row.TextSize = 12
            row.Text = tostring(text)
            row.TextColor3 = (messageType == Enum.MessageType.MessageWarning and Color3.fromRGB(255,214,135))
                or (messageType == Enum.MessageType.MessageError and Color3.fromRGB(255,145,145))
                or Color3.fromRGB(224,224,236)
            row.Parent = consoleScroll
            table.insert(consoleEntries, row)
        end

        pcall(function()
            for _, item in ipairs(LogService:GetLogHistory()) do
                addConsoleEntry(item.message, item.messageType)
            end
        end)
        LogService.MessageOut:Connect(function(message, messageType)
            addConsoleEntry(message, messageType)
        end)

        consoleSearch:GetPropertyChangedSignal("Text"):Connect(function()
            local q = string.lower(consoleSearch.Text or "")
            for _, row in ipairs(consoleEntries) do
                local txt = string.lower(row.Text or "")
                row.Visible = (q == "" or txt:find(q, 1, true) ~= nil)
            end
        end)

        openBtn.MouseButton1Click:Connect(function()
            local open = not consoleScroll.Visible
            consoleScroll.Visible = open
            consoleSearch.Visible = open
            openBtn.Text = open and "Close" or "Open"
        end)
    end

    -- Local time bottom-left
    local timeLabel = window:FindFirstChild("LocalTimeLabel")
    if not timeLabel then
        timeLabel = Instance.new("TextLabel")
        timeLabel.Name = "LocalTimeLabel"
        timeLabel.BackgroundTransparency = 1
        timeLabel.Size = UDim2.new(0,115,0,18)
        timeLabel.Position = UDim2.new(0,8,1,-18)
        timeLabel.TextXAlignment = Enum.TextXAlignment.Left
        timeLabel.TextColor3 = Color3.fromRGB(214,208,234)
        timeLabel.Font = Enum.Font.GothamMedium
        timeLabel.TextSize = 12
        timeLabel.Parent = window
        RS.RenderStepped:Connect(function()
            if timeLabel and timeLabel.Parent then
                timeLabel.Text = os.date("%I:%M %p")
            end
        end)
    end

    -- Better key detection for fly / aim / ui toggle, including mouse buttons
    local function keyNameOfInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then return "LMB", Enum.UserInputType.MouseButton1 end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then return "RMB", Enum.UserInputType.MouseButton2 end
        if input.UserInputType == Enum.UserInputType.MouseButton3 then return "MMB", Enum.UserInputType.MouseButton3 end
        if tostring(input.UserInputType):find("MouseButton4") then return "MB4", input.UserInputType end
        if tostring(input.UserInputType):find("MouseButton5") then return "MB5", input.UserInputType end
        if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then return input.KeyCode.Name, input.KeyCode end
        return nil, nil
    end

    local function inputMatches(binding, input)
        if typeof(binding) == "EnumItem" and binding.EnumType == Enum.UserInputType then
            return input.UserInputType == binding
        end
        return input.KeyCode == binding
    end

    if _G.__RYO_SAFE_KEYPATCH_BEGAN then
        pcall(function() _G.__RYO_SAFE_KEYPATCH_BEGAN:Disconnect() end)
        _G.__RYO_SAFE_KEYPATCH_BEGAN = nil
    end
    if _G.__RYO_SAFE_KEYPATCH_ENDED then
        pcall(function() _G.__RYO_SAFE_KEYPATCH_ENDED:Disconnect() end)
        _G.__RYO_SAFE_KEYPATCH_ENDED = nil
    end
    _G.__RYO_SAFE_KEYPATCH = true

    _G.__RYO_SAFE_KEYPATCH_BEGAN = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        if waitingForKey then
            local name, enumValue = keyNameOfInput(input)
            if enumValue then
                aimKey = enumValue
                waitingForKey = false
                local lbl = aimKeyFrame and aimKeyFrame:FindFirstChildWhichIsA("TextLabel")
                if lbl then lbl.Text = "Aim Key: " .. getBindingDisplayName(aimKey) end
            end
            return
        end

        if waitingForUiToggleKey then
            local name, enumValue = keyNameOfInput(input)
            if enumValue then
                uiToggleKey = enumValue
                waitingForUiToggleKey = false
                if uiToggleLabel then uiToggleLabel.Text = "UI Toggle Key: " .. tostring(name) end
            end
            return
        end

        if inputMatches(uiToggleKey, input) then
            toggleUI()
            return
        end
        if typeof(aimKey) == "EnumItem" and aimKey.EnumType == Enum.UserInputType and inputMatches(aimKey, input) then
            aimMouseHeld = true
        end
    end)

    _G.__RYO_SAFE_KEYPATCH_ENDED = UIS.InputEnded:Connect(function(input)
        if typeof(aimKey) == "EnumItem" and aimKey.EnumType == Enum.UserInputType and inputMatches(aimKey, input) then
            aimMouseHeld = false
        end
    end)

    -- UI toggle bind row in Misc
    local uiToggleFrame = miscParent:FindFirstChild("UIToggleKeyFrame")
    if not uiToggleFrame then
        uiToggleFrame = Instance.new("Frame")
        uiToggleFrame.Name = "UIToggleKeyFrame"
        uiToggleFrame.Size = UDim2.new(0,200,0,28)
        uiToggleFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        uiToggleFrame.Parent = miscParent
        makeCorner(uiToggleFrame, UDim.new(0,8))

        uiToggleLabel = Instance.new("TextLabel")
        uiToggleLabel.Size = UDim2.new(1,-16,1,0)
        uiToggleLabel.Position = UDim2.new(0,8,0,0)
        uiToggleLabel.BackgroundTransparency = 1
        uiToggleLabel.Text = "UI Toggle Key: RightShift"
        uiToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        uiToggleLabel.TextColor3 = COLORS.Text
        uiToggleLabel.Font = Enum.Font.Gotham
        uiToggleLabel.TextSize = 14
        uiToggleLabel.Parent = uiToggleFrame

        local overlay = Instance.new("TextButton")
        overlay.Size = UDim2.new(1,0,1,0)
        overlay.BackgroundTransparency = 1
        overlay.Text = ""
        overlay.AutoButtonColor = false
        overlay.Parent = uiToggleFrame
        overlay.MouseButton1Click:Connect(function()
            waitingForUiToggleKey = true
            if uiToggleLabel then uiToggleLabel.Text = "UI Toggle Key: Press a key..." end
        end)
    else
        uiToggleLabel = uiToggleFrame:FindFirstChildWhichIsA("TextLabel")
    end
 local killBrickFrame = miscParent:FindFirstChild("KillBrickFrame")
    if not killBrickFrame then
        killBrickFrame = Instance.new("Frame")
        killBrickFrame.Name = "KillBrickFrame"
        killBrickFrame.Size = UDim2.new(0,200,0,34)
        killBrickFrame.BackgroundColor3 = COLORS.Card2
        killBrickFrame.BorderSizePixel = 0
        killBrickFrame.Parent = miscParent
        makeCorner(killBrickFrame, UDim.new(0,8))
        makeStroke(killBrickFrame, COLORS.TabStroke, 0.18, 1)

        local killBtn = Instance.new("TextButton")
        killBtn.Name = "KillBrickButton"
        killBtn.Size = UDim2.new(1,0,1,0)
        killBtn.BackgroundTransparency = 1
        killBtn.Text = "Remove Kill Bricks"
        killBtn.TextColor3 = COLORS.Text
        killBtn.Font = Enum.Font.GothamMedium
        killBtn.TextSize = 13
        killBtn.AutoButtonColor = false
        killBtn.Parent = killBrickFrame
        killBtn.MouseButton1Click:Connect(function()
            local removed = 0

            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local nameLower = string.lower(obj.Name)
                    local materialName = string.lower(tostring(obj.Material))
                    local isHazard =
                        nameLower:find("kill") or
                        nameLower:find("lava") or
                        nameLower:find("death") or
                        nameLower:find("acid") or
                        nameLower:find("void") or
                        nameLower:find("damage") or
                        materialName:find("neon")

                    if isHazard then
                        pcall(function() obj.CanTouch = false end)
                        pcall(function() obj.CanCollide = false end)
                        pcall(function() obj.CanQuery = false end)
                        pcall(function() obj.Transparency = 1 end)
                        pcall(function() obj.LocalTransparencyModifier = 1 end)

                        for _, child in ipairs(obj:GetDescendants()) do
                            if child:IsA("TouchTransmitter") then
                                pcall(function() child:Destroy() end)
                            elseif child:IsA("Script") or child:IsA("LocalScript") then
                                local childName = string.lower(child.Name)
                                if childName:find("kill") or childName:find("damage") or childName:find("death") then
                                    pcall(function() child.Disabled = true end)
                                end
                            end
                        end

                        removed += 1
                    end
                end
            end

            killBtn.Text = removed > 0 and ("Removed Kill Bricks (" .. tostring(removed) .. ")") or "No Kill Bricks Found"
            task.delay(1.5, function()
                if killBtn and killBtn.Parent then
                    killBtn.Text = "Remove Kill Bricks"
                end
            end)
        end)
    end
    -- RightShift no longer hardcodes toggle if user changed the binding
    -- (legacy listener still exists, so explicitly neutralize by mirroring intent)
    if uiToggleKey ~= Enum.KeyCode.RightShift then
        -- nothing else needed; new binder handles the active key and the user can change back
    end

    -- Smooth dropdown behavior: disable duplicates and keep one overlay per dropdown
    local function isDropdownFrame(frame)
        if not frame or not frame:IsA("Frame") then return false end
        local hasButton, hasContainer = false, false
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextButton") and child.Name:find("Button") then hasButton = true end
            if child:IsA("Frame") and child.Name:find("Container") then hasContainer = true end
        end
        return hasButton and hasContainer
    end

    local function baseDropdownTitle(frame)
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextButton") and child.Name:find("Button") then
                local t = tostring(child.Text or "")
                t = t:gsub("%s*[▼▶].*$", "")
                t = t:gsub(":%s*.*$", "")
                t = t:gsub("^%s+", ""):gsub("%s+$", "")
                if t ~= "" then return t end
            end
        end
        return frame.Name:gsub("Button", "")
    end

    local dropdownGroups = {}
    for _, obj in ipairs(window:GetDescendants()) do
        if isDropdownFrame(obj) then
            local title = baseDropdownTitle(obj)
            dropdownGroups[title] = dropdownGroups[title] or {}
            table.insert(dropdownGroups[title], obj)
        end
    end
    for title, list in pairs(dropdownGroups) do
        if #list > 1 then
            table.sort(list, function(a,b) return #a:GetDescendants() > #b:GetDescendants() end)
            local keep = list[1]
            for _, frame in ipairs(list) do
                if frame ~= keep and (title == "Aim" or title == "ESP") then
                    frame.Visible = false
                    frame.Active = false
                    frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 0)
                end
            end
        end
    end

    local function bindSmoothDropdown(frame)
        if not isDropdownFrame(frame) or frame:FindFirstChild("SafeSmoothOverlay") then return end
        local header, container
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("TextButton") and child.Name:find("Button") then header = child end
            if child:IsA("Frame") and child.Name:find("Container") then container = child end
        end
        if not (header and container) then return end
        header.Visible = false
        local overlay = Instance.new("TextButton")
        overlay.Name = "SafeSmoothOverlay"
        overlay.Size = UDim2.new(1,0,0,28)
        overlay.BackgroundTransparency = 1
        overlay.TextColor3 = COLORS.Text
        overlay.TextXAlignment = Enum.TextXAlignment.Left
        overlay.Font = Enum.Font.Gotham
        overlay.TextSize = 14
        overlay.AutoButtonColor = false
        overlay.Parent = frame
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0,10)
        pad.PaddingRight = UDim.new(0,10)
        pad.Parent = overlay

        local layout = container:FindFirstChildOfClass("UIListLayout")
        local open = false
        local function apply(state, instant)
            open = state
            local h = state and (layout and layout.AbsoluteContentSize.Y or 0) or 0
            overlay.Text = baseDropdownTitle(frame) .. (state and " ▼" or " ▶")
            if state then container.Visible = true end
            if instant then
                container.Size = UDim2.new(1,0,0,h)
                frame.Size = UDim2.new(1,0,0,28 + (state and (h + 4) or 0))
                if not state then container.Visible = false end
                return
            end
            safeTween(container, 0.18, {Size = UDim2.new(1,0,0,h)})
            local tw = safeTween(frame, 0.18, {Size = UDim2.new(1,0,0,28 + (state and (h + 4) or 0))})
            if not state and tw then
                tw.Completed:Connect(function()
                    if not open and container then container.Visible = false end
                end)
            end
        end
        overlay.MouseButton1Click:Connect(function()
            apply(not open, false)
        end)
        if layout then
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then apply(true, true) end
            end)
        end
        apply(false, true)
    end
    for _, obj in ipairs(window:GetDescendants()) do
        if obj:IsA("Frame") then bindSmoothDropdown(obj) end
    end

    -- Better About layout sizing
    local function relayoutAbout()
        if not aboutTab then return end
        setPageGeometry()
        local h = aboutHost
        if not h then return end
        local l = h:FindFirstChild("LeftColumn")
        local r = h:FindFirstChild("RightColumn")
        local ll = l and l:FindFirstChildOfClass("UIListLayout")
        local rl = r and r:FindFirstChildOfClass("UIListLayout")
        if not (l and r and ll and rl) then return end
        local width = math.max(aboutTab.AbsoluteSize.X, 320)
        local gap = 10
        local colWidth = math.floor((width - gap) / 2)
        l.Position = UDim2.new(0,0,0,0)
        l.Size = UDim2.new(0,colWidth,0,ll.AbsoluteContentSize.Y)
        r.Position = UDim2.new(0,colWidth+gap,0,0)
        r.Size = UDim2.new(0,colWidth,0,rl.AbsoluteContentSize.Y)
        for _, col in ipairs({l,r}) do
            for _, child in ipairs(col:GetChildren()) do
                if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    fullWidth(child)
                end
            end
        end
        local total = math.max(ll.AbsoluteContentSize.Y, rl.AbsoluteContentSize.Y)
        h.Size = UDim2.new(1,0,0,total)
        aboutTab.CanvasSize = UDim2.new(0,0,0,total + 12)
    end

    if window and not window:FindFirstChild("SafeMergedResizeTag") then
        local tag = Instance.new("BoolValue")
        tag.Name = "SafeMergedResizeTag"
        tag.Parent = window
        local queued = false
        window:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            if queued then return end
            queued = true
            task.delay(0.04, function()
                queued = false
                refreshRail()
                relayoutPlayers()
                relayoutAbout()
            end)
        end)
    end

    refreshRail()
    relayoutPlayers()
    relayoutAbout()
    updateSelectedCard()
    showOnly(activeTab or "Main")
end)
