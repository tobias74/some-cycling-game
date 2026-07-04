local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local BleBridgeClient = require(script.Parent.Services.BleBridgeClient)
local CyclistRigService = require(script.Parent.Services.CyclistRigService)

local function configureCharacter(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = GameConfig.RunnerWalkSpeed
	end
end

local function onPlayerAdded(player: Player)
	player.CharacterAdded:Connect(configureCharacter)

	if player.Character then
		configureCharacter(player.Character)
	end
end

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

local cyclist = CyclistRigService.new(GameConfig.Cyclist)

BleBridgeClient.startPolling(GameConfig.BleBridge, function(sample)
	sample.maxPowerWatts = GameConfig.BleBridge.MaxPowerWatts
	cyclist:setPowerSample(sample)
end)
