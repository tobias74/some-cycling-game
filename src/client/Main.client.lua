local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local StadiumTrack = require(ReplicatedStorage.Shared.StadiumTrack)

local localPlayer = Players.LocalPlayer
local cameraCFrame: CFrame? = nil

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

local function updateRideAndCamera(deltaTime: number)
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not rootPart or not rootPart:IsA("BasePart") then
		return
	end

	local nearestDistance = StadiumTrack.getNearestDistance(rootPart.Position, GameConfig.Track)
	local centerlinePosition = StadiumTrack.getPositionAndTangent(nearestDistance, GameConfig.Track)
	local targetPosition, targetTangent = StadiumTrack.getPositionAndTangent(
		nearestDistance + GameConfig.Track.FollowLookAheadStuds,
		GameConfig.Track
	)
	local horizontalOffset = Vector3.new(
		centerlinePosition.X - rootPart.Position.X,
		0,
		centerlinePosition.Z - rootPart.Position.Z
	)

	if horizontalOffset.Magnitude > GameConfig.Track.MaxCenterlineDriftStuds then
		local correctedPosition =
			Vector3.new(centerlinePosition.X, rootPart.Position.Y, centerlinePosition.Z)

		rootPart.CFrame = CFrame.lookAt(correctedPosition, correctedPosition + targetTangent)
		rootPart.AssemblyLinearVelocity = Vector3.zero
	else
		local directionToTarget = Vector3.new(
			targetPosition.X - rootPart.Position.X,
			0,
			targetPosition.Z - rootPart.Position.Z
		)

		if directionToTarget.Magnitude > 0.001 then
			humanoid:Move(directionToTarget.Unit, false)
		end
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	currentCamera.CameraType = Enum.CameraType.Scriptable

	local focusPosition = rootPart.Position + Vector3.new(0, 2.5, 0)
	local desiredCameraPosition = focusPosition
		- rootPart.CFrame.LookVector * 14
		+ Vector3.new(0, 6, 0)
	local desiredCameraCFrame = CFrame.lookAt(desiredCameraPosition, focusPosition)
	local cameraAlpha = 1 - math.exp(-8 * deltaTime)

	cameraCFrame = if cameraCFrame
		then cameraCFrame:Lerp(desiredCameraCFrame, cameraAlpha)
		else desiredCameraCFrame
	currentCamera.CFrame = cameraCFrame
end

localPlayer.CharacterAdded:Connect(function()
	cameraCFrame = nil
end)

RunService:BindToRenderStep(
	"PowerRideTrackFollower",
	Enum.RenderPriority.Camera.Value + 1,
	updateRideAndCamera
)
