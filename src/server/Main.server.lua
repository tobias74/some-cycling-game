local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local BleBridgeClient = require(script.Parent.Services.BleBridgeClient)
local PlayerRideService = require(script.Parent.Services.PlayerRideService)

local playerRide = PlayerRideService.new(GameConfig.Rider)

BleBridgeClient.startPolling(GameConfig.BleBridge, function(sample)
	playerRide:setPowerSample(sample, GameConfig.BleBridge.MaxPowerWatts)
end)
