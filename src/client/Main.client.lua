local Workspace = game:GetService("Workspace")

local cyclist = Workspace:WaitForChild("BleCyclist")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyclistHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Name = "PowerReadout"
label.AnchorPoint = Vector2.new(0, 0)
label.Position = UDim2.fromOffset(20, 20)
label.Size = UDim2.fromOffset(320, 92)
label.BackgroundTransparency = 0.18
label.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
label.BorderSizePixel = 0
label.Font = Enum.Font.GothamMedium
label.TextColor3 = Color3.fromRGB(245, 247, 250)
label.TextSize = 18
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.Parent = screenGui

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.Parent = label

local function updateReadout()
	local powerWatts = cyclist:GetAttribute("PowerWatts") or 0
	local speed = cyclist:GetAttribute("SpeedStudsPerSecond") or 0
	local bridgeConnected = cyclist:GetAttribute("BridgeConnected")
	local status = cyclist:GetAttribute("BridgeStatus") or "waiting"
	local bridgeLabel = if bridgeConnected then "connected" else "fallback"

	label.Text = `Power: {powerWatts} W\nSpeed: {speed} studs/s\nBridge: {bridgeLabel} - {status}`
end

updateReadout()
cyclist.AttributeChanged:Connect(updateReadout)
