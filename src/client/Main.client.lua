local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local rideDirection = Vector3.new(1, 0, 0)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PowerHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Name = "PowerReadout"
label.AnchorPoint = Vector2.new(0, 0)
label.Position = UDim2.fromOffset(20, 20)
label.Size = UDim2.fromOffset(360, 122)
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
	local powerWatts = localPlayer:GetAttribute("PowerWatts") or 0
	local speed = localPlayer:GetAttribute("SpeedStudsPerSecond") or 0
	local distance = localPlayer:GetAttribute("DistanceStuds") or 0
	local bridgeConnected = localPlayer:GetAttribute("BridgeConnected")
	local status = localPlayer:GetAttribute("BridgeStatus") or "waiting"
	local bridgeLabel = if bridgeConnected then "connected" else "fallback"

	label.Text =
		`POWER RIDER\nPower: {powerWatts} W\nSpeed: {speed} studs/s\nDistance: {distance} studs\nBridge: {bridgeLabel} - {status}`
end

updateReadout()
localPlayer.AttributeChanged:Connect(updateReadout)

RunService:BindToRenderStep("PowerRideMovement", Enum.RenderPriority.Input.Value + 1, function()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	humanoid:Move(rideDirection, false)
end)
