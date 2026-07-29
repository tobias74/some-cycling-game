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

	Track = {
		Center = Vector3.new(0, 0, 0),
		StraightLengthStuds = 140,
		CurveRadiusStuds = 52,
		WidthStuds = 24,
		SurfaceY = 0.4,
		SurfaceThicknessStuds = 0.4,
		CurveSegments = 32,
		LaneCount = 3,
		FollowLookAheadStuds = 7,
		MaxCenterlineDriftStuds = 6,
	},
}

return GameConfig
