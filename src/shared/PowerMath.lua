local PowerMath = {}

function PowerMath.clampPowerWatts(powerWatts: number, maxPowerWatts: number): number
	if powerWatts ~= powerWatts then
		return 0
	end

	return math.clamp(powerWatts, 0, maxPowerWatts)
end

function PowerMath.powerToSpeedStudsPerSecond(powerWatts: number, riderConfig): number
	local wattsForMaxSpeed = math.max(riderConfig.WattsForMaxSpeed, 1)
	local normalized = math.clamp(powerWatts / wattsForMaxSpeed, 0, 1)
	local curved = normalized ^ 0.65

	return riderConfig.BaseSpeedStudsPerSecond
		+ (riderConfig.MaxSpeedStudsPerSecond - riderConfig.BaseSpeedStudsPerSecond) * curved
end

function PowerMath.approach(current: number, target: number, maxDelta: number): number
	local delta = target - current

	if math.abs(delta) <= maxDelta then
		return target
	end

	return current + math.sign(delta) * maxDelta
end

return PowerMath
