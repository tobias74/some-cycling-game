local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerMath = require(ReplicatedStorage.Shared.PowerMath)

local PlayerRideService = {}
PlayerRideService.__index = PlayerRideService

type PlayerState = {
	character: Model?,
	origin: CFrame?,
	distanceStuds: number,
}

function PlayerRideService.new(config)
	local self = setmetatable({
		config = config,
		powerWatts = 0,
		speedStudsPerSecond = 0,
		playerStates = {} :: { [Player]: PlayerState },
	}, PlayerRideService)

	RunService.Heartbeat:Connect(function(deltaTime)
		self:_update(deltaTime)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.playerStates[player] = nil
	end)

	return self
end

function PlayerRideService:_getState(player: Player, character: Model): PlayerState
	local state = self.playerStates[player]

	if state and state.character == character then
		return state
	end

	state = {
		character = character,
		origin = character:GetPivot(),
		distanceStuds = 0,
	}
	self.playerStates[player] = state

	return state
end

function PlayerRideService:_update(deltaTime: number)
	local targetSpeed = PowerMath.powerToSpeedStudsPerSecond(self.powerWatts, self.config)
	local maxDelta = self.config.AccelerationStudsPerSecond * deltaTime

	self.speedStudsPerSecond = PowerMath.approach(self.speedStudsPerSecond, targetSpeed, maxDelta)

	for _, player in Players:GetPlayers() do
		local character = player.Character

		if not character then
			continue
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid or humanoid.Health <= 0 then
			continue
		end

		local state = self:_getState(player, character)
		state.distanceStuds += self.speedStudsPerSecond * deltaTime

		humanoid.WalkSpeed = math.max(self.speedStudsPerSecond, 1)
		humanoid.AutoRotate = false
		character:PivotTo(state.origin * CFrame.new(state.distanceStuds, 0, 0))
	end
end

function PlayerRideService:setPowerWatts(powerWatts: number, maxPowerWatts: number)
	self.powerWatts = PowerMath.clampPowerWatts(powerWatts, maxPowerWatts)
end

return PlayerRideService
