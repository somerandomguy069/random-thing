local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

_G.RADIUS = 10
_G.ROTATION_SPEED = 10
_G.ATTRACTION = 1000

local function setCharGroup(char)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

setCharGroup(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(setCharGroup)

local MAX_DISTANCE = 2000
local RADIUS_STEP = 2
local SPEED_STEP = 2
local ATTRACTION_STEP = 200

local isToggled = false
local parts = {}
local mode = "MOUSE"
local BEAM_LENGTH = 20
local BEAM_STEP = 2

local function addPart(p)
	if p:IsA("BasePart") and not p.Anchored and p.Parent ~= LocalPlayer.Character then
		table.insert(parts, p)
	end
end

local function removePart(p)
	for i = #parts, 1, -1 do
		if parts[i] == p then
			table.remove(parts, i)
			break
		end
	end
end

for _, p in pairs(Workspace:GetDescendants()) do
	addPart(p)
end

Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpinControlGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = PlayerGui
local function showNotification(text, duration)
    duration = duration or 10

    local gui = Instance.new("ScreenGui")
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.9, -150, 0.1, 0) 
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = gui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Text = text  
    label.Parent = frame

    task.delay(duration, function()
        for i = 0, 1, 0.05 do
            frame.BackgroundTransparency = 0.5 + i * 0.5
            label.TextTransparency = i
            task.wait(0.03)
        end
        gui:Destroy()
    end)
end

showNotification("F/G for radius, Z/X for rotation speed, C/V for attraction, B/N for beam length, K/L for modes and P to hide GUIs")

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(0, 300, 0, 30)
creditLabel.Position = UDim2.new(0.5, -150, 0, -30)
creditLabel.BackgroundTransparency = 0.5
creditLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.SourceSansBold
creditLabel.Text = "MADE BY OBACON"
creditLabel.ZIndex = 50 
creditLabel.Parent = screenGui

local guiVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.P then
		guiVisible = not guiVisible
		screenGui.Enabled = guiVisible
	end
end)

local function createLabel(name, pos)
	local label = Instance.new("TextButton")
	label.Name = name
	label.Size = UDim2.new(0, 200, 0, 30)
	label.Position = pos
	label.BackgroundTransparency = 0.5
	label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.ZIndex = 10
	label.Text = name .. ": " .. tostring(_G[name])
	label.Parent = screenGui
	label.MouseButton1Click:Connect(function()
		inputDialog(name)
	end)
	return label
end

local startX = 0.5
local startY = 0
local radiusLabel = createLabel("RADIUS", UDim2.new(startX, -100, startY, 10))
local speedLabel = createLabel("ROTATION_SPEED", UDim2.new(startX, -100, startY, 50))
local attractionLabel = createLabel("ATTRACTION", UDim2.new(startX, -100, startY, 90))
local toggleLabel = createLabel("Status", UDim2.new(startX, -100, startY, 130))
local modeLabel = createLabel("Mode", UDim2.new(startX, -100, startY, 170))
local beamLabel = createLabel("BEAM_LENGTH", UDim2.new(startX, -100, startY, 210))

local function updateGUI()
	radiusLabel.Text = "RADIUS: " .. math.floor(_G.RADIUS)
	speedLabel.Text = "ROTATION_SPEED: " .. math.floor(_G.ROTATION_SPEED)
	attractionLabel.Text = "ATTRACTION: " .. math.floor(_G.ATTRACTION)
	toggleLabel.Text = "Status: " .. (isToggled and "ON" or "OFF")
	modeLabel.Text = "Mode: " .. mode
	beamLabel.Text = "BEAM_LENGTH: " .. math.floor(BEAM_LENGTH)
end

updateGUI()

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	local key = input.KeyCode

	if key == Enum.KeyCode.R then
		isToggled = not isToggled
		updateGUI()
	elseif key == Enum.KeyCode.K then
		local modes = {"MOUSE", "RING", "BEAM", "SWARM", "WAVE", "BLACKHOLE", "SPIRAL"}
		for i, v in ipairs(modes) do
			if mode == v then
				mode = i == 1 and modes[#modes] or modes[i - 1]
				break
			end
		end
		updateGUI()
	elseif key == Enum.KeyCode.L then
		local modes = {"MOUSE", "RING", "BEAM", "SWARM", "WAVE", "BLACKHOLE", "SPIRAL"}
		for i, v in ipairs(modes) do
			if mode == v then
				mode = i == #modes and modes[1] or modes[i + 1]
				break
			end
		end
		updateGUI()
	elseif key == Enum.KeyCode.F then
		_G.RADIUS = _G.RADIUS + RADIUS_STEP
		updateGUI()
	elseif key == Enum.KeyCode.G then
		_G.RADIUS = _G.RADIUS - RADIUS_STEP
		updateGUI()
	elseif key == Enum.KeyCode.Z then
		_G.ROTATION_SPEED = _G.ROTATION_SPEED + SPEED_STEP
		updateGUI()
	elseif key == Enum.KeyCode.X then
		_G.ROTATION_SPEED = _G.ROTATION_SPEED - SPEED_STEP
		updateGUI()
	elseif key == Enum.KeyCode.C then
		_G.ATTRACTION = _G.ATTRACTION + ATTRACTION_STEP
		updateGUI()
	elseif key == Enum.KeyCode.V then
		_G.ATTRACTION = _G.ATTRACTION - ATTRACTION_STEP
		updateGUI()
	elseif key == Enum.KeyCode.B then
		BEAM_LENGTH = math.min(500, BEAM_LENGTH + BEAM_STEP)
		updateGUI()
	elseif key == Enum.KeyCode.N then
		BEAM_LENGTH = math.max(2, BEAM_LENGTH - BEAM_STEP)
		updateGUI()
	end
end)

local angle = 0
RunService.Heartbeat:Connect(function(dt)
	if not isToggled then return end
	angle = angle + _G.ROTATION_SPEED * dt

	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local targetPos
	if mode == "MOUSE" or mode == "BLACKHOLE" or mode == "SWARM" or mode == "WAVE" or mode == "SPIRAL" then
		targetPos = Mouse.Hit.Position
	elseif mode == "RING" then
		targetPos = hrp.Position
	elseif mode == "BEAM" then
		targetPos = Mouse.Hit.Position
	end

	for i, part in pairs(parts) do
		if part and part.Parent and not part.Anchored then
			local distance = (part.Position - hrp.Position).Magnitude
			if distance <= MAX_DISTANCE then
				local finalTarget = targetPos

				if mode == "RING" then
					local spacing = 2 * math.pi / #parts
					local a = angle + i * spacing
					finalTarget = hrp.Position + Vector3.new(math.cos(a) * _G.RADIUS, 0, math.sin(a) * _G.RADIUS)
                elseif mode == "BEAM" then
	                local dir = (Mouse.Hit.Position - hrp.Position).Unit
	                local stepDistance = BEAM_LENGTH / #parts
	                finalTarget = hrp.Position + dir * (i * stepDistance)
                elseif mode == "SPIRAL" then
	                local dir = (Mouse.Hit.Position - hrp.Position).Unit
                 	local spiralLength = 100
                  	local spiralSpacing = 0.5
                	local forward = dir * ((i / #parts) * spiralLength)
	                local right = dir:Cross(Vector3.new(0,1,0)).Unit
                 	local up = right:Cross(dir).Unit
                	local angleOffset = angle + i * spiralSpacing
                 	local offset = right * math.cos(angleOffset) * _G.RADIUS + up * math.sin(angleOffset) * _G.RADIUS
                 	finalTarget = hrp.Position + forward + offset
				elseif mode == "WAVE" then
					local dir = (Mouse.Hit.Position - hrp.Position).Unit
					local offset = Vector3.new(0, math.sin(angle + i) * _G.RADIUS, 0)
					finalTarget = hrp.Position + dir * distance + offset
				elseif mode == "SWARM" then
					local dir = (Mouse.Hit.Position - hrp.Position).Unit
					local randomOffset = Vector3.new(math.random() * _G.RADIUS - _G.RADIUS/2, math.random() * _G.RADIUS - _G.RADIUS/2, math.random() * _G.RADIUS - _G.RADIUS/2)
					finalTarget = hrp.Position + dir * distance + randomOffset
				elseif mode == "BLACKHOLE" then
					local dir = (Mouse.Hit.Position - part.Position)
					local len = math.clamp(dir.Magnitude, 1, 2500)
					finalTarget = part.Position + dir.Unit * len * 1
				end

				local dirVec = (finalTarget - part.Position).Unit
				part.Velocity = dirVec * _G.ATTRACTION
			end
		end
	end
end)

local function inputDialog(name)
	local dialog = Instance.new("ScreenGui")
	dialog.Name = "InputDialog"
	dialog.ResetOnSpawn = false
	dialog.ZIndexBehavior = Enum.ZIndexBehavior.Global
	dialog.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 100)
	frame.Position = UDim2.new(0.5, -150, 0.5, 100)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.Parent = dialog

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 0, 30)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Text = "Enter new value for " .. name .. ":"
	textLabel.Parent = frame

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, 0, 0, 30)
	textBox.Position = UDim2.new(0, 0, 0, 30)
	textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textBox.TextScaled = true
	textBox.Font = Enum.Font.SourceSansBold
	textBox.Parent = frame

	local confirmButton = Instance.new("TextButton")
	confirmButton.Size = UDim2.new(0, 100, 0, 30)
	confirmButton.Position = UDim2.new(0.5, -50, 0, 70)
	confirmButton.BackgroundColor3 = Color3.fromRGB(0, 128, 0)
	confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	confirmButton.TextScaled = true
	confirmButton.Font = Enum.Font.SourceSansBold
	confirmButton.Text = "Confirm"
	confirmButton.Parent = frame

	local value
	confirmButton.MouseButton1Click:Connect(function()
		value = tonumber(textBox.Text)
		dialog:Destroy()
	end)

	while dialog.Parent do
		RunService.RenderStepped:Wait()
	end

	if value then
		_G[name] = value
		updateGUI()
	end
end

print("inputDialog function defined")
