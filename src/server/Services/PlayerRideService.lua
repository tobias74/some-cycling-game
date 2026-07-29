local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerMath = require(ReplicatedStorage.Shared.PowerMath)

local PlayerRideService = {}
PlayerRideService.__index = PlayerRideService

type PlayerState = {
	character: Model,
	lastPosition: Vector3,
	distanceStuds: number,
}

local TELEMETRY_INTERVAL_SECONDS = 0.1

local function roundToTenths(value: number): number
	return math.floor(value * 10 + 0.5) / 10
end

function PlayerRideService.new(config)
	local self = setmetatable({
		config = config,
		powerWatts = 0,
		speedStudsPerSecond = 0,
		bridgeConnected = false,
		bridgeStatus = "waiting for bridge",
		telemetryElapsed = 0,
		playerStates = {} :: { [Player]: PlayerState },
	}, PlayerRideService)

	RunService.Heartbeat:Connect(function(deltaTime)
		self:_update(deltaTime)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.playerStates[player] = nil
	end)

	Players.PlayerAdded:Connect(function(player)
		self:_publishPlayerAttributes(player, 0)
	end)

	for _, player in Players:GetPlayers() do
		self:_publishPlayerAttributes(player, 0)
	end

	return self
end

function PlayerRideService:_publishPlayerAttributes(player: Player, distanceStuds: number)
	player:SetAttribute("PowerWatts", math.floor(self.powerWatts + 0.5))
	player:SetAttribute("SpeedStudsPerSecond", roundToTenths(self.speedStudsPerSecond))
	player:SetAttribute("DistanceStuds", roundToTenths(distanceStuds))
	player:SetAttribute("BridgeConnected", self.bridgeConnected)
	player:SetAttribute("BridgeStatus", self.bridgeStatus)
end

function PlayerRideService:_getState(
	player: Player,
	character: Model,
	rootPart: BasePart
): PlayerState
	local state = self.playerStates[player]

	if state and state.character == character then
		return state
	end

	state = {
		character = character,
		lastPosition = rootPart.Position,
		distanceStuds = 0,
	}
	self.playerStates[player] = state

	return state
end

function PlayerRideService:_update(deltaTime: number)
	local targetSpeed = PowerMath.powerToSpeedStudsPerSecond(self.powerWatts, self.config)
	local maxDelta = self.config.AccelerationStudsPerSecond * deltaTime

	self.speedStudsPerSecond = PowerMath.approach(self.speedStudsPerSecond, targetSpeed, maxDelta)
	self.telemetryElapsed += deltaTime
	local shouldPublishTelemetry = self.telemetryElapsed >= TELEMETRY_INTERVAL_SECONDS

	if shouldPublishTelemetry then
		self.telemetryElapsed = 0
	end

	for _, player in Players:GetPlayers() do
		local character = player.Character

		if not character then
			continue
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			continue
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if not rootPart or not rootPart:IsA("BasePart") then
			continue
		end

		local state = self:_getState(player, character, rootPart)
		local positionDelta = rootPart.Position - state.lastPosition
		local horizontalDistance = Vector3.new(positionDelta.X, 0, positionDelta.Z).Magnitude

		state.distanceStuds += horizontalDistance
		state.lastPosition = rootPart.Position

		humanoid.WalkSpeed = self.speedStudsPerSecond
		humanoid.AutoRotate = true

		if shouldPublishTelemetry then
			self:_publishPlayerAttributes(player, state.distanceStuds)
		end
	end
end

function PlayerRideService:setPowerSample(sample, maxPowerWatts: number)
	self.powerWatts = PowerMath.clampPowerWatts(sample.powerWatts, maxPowerWatts)
	self.bridgeConnected = sample.ok
	self.bridgeStatus = if sample.ok
		then "bridge connected"
		else sample.errorMessage or "using fallback power"

	for _, player in Players:GetPlayers() do
		local state = self.playerStates[player]
		local distanceStuds = if state then state.distanceStuds else 0
		self:_publishPlayerAttributes(player, distanceStuds)
	end
end

return PlayerRideService
