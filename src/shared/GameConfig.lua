local GameConfig = {
	RoundLengthSeconds = 180,
	MinimumPlayers = 1,

	RunnerWalkSpeed = 18,
	ChaserWalkSpeed = 22,

	BleBridge = {
		Endpoint = "https://blebridge.com/v1/demo/power",
		PollIntervalSeconds = 0.5,
		RequestTimeoutSeconds = 2,
		FallbackPowerWatts = 90,
		MaxPowerWatts = 1000,
	},

	Rider = {
		BaseSpeedStudsPerSecond = 2,
		MaxSpeedStudsPerSecond = 48,
		WattsForMaxSpeed = 600,
		AccelerationStudsPerSecond = 18,
	},
}

return GameConfig
