local StadiumTrack = {}

local HALF_PI = math.pi / 2
local THREE_HALF_PI = 3 * math.pi / 2

local function horizontalDistanceSquared(first: Vector3, second: Vector3): number
	local deltaX = first.X - second.X
	local deltaZ = first.Z - second.Z

	return deltaX * deltaX + deltaZ * deltaZ
end

function StadiumTrack.getLength(config): number
	return 2 * config.StraightLengthStuds + 2 * math.pi * config.CurveRadiusStuds
end

function StadiumTrack.getPositionAndTangent(distanceStuds: number, config): (Vector3, Vector3)
	local straightLength = config.StraightLengthStuds
	local radius = config.CurveRadiusStuds
	local halfStraight = straightLength / 2
	local trackLength = StadiumTrack.getLength(config)
	local distance = distanceStuds % trackLength
	local center = config.Center
	local position: Vector3
	local tangent: Vector3

	if distance < straightLength then
		position = Vector3.new(-halfStraight + distance, config.SurfaceY, radius)
		tangent = Vector3.new(1, 0, 0)
	elseif distance < straightLength + math.pi * radius then
		local curveDistance = distance - straightLength
		local angle = HALF_PI - curveDistance / radius

		position = Vector3.new(
			halfStraight + radius * math.cos(angle),
			config.SurfaceY,
			radius * math.sin(angle)
		)
		tangent = Vector3.new(math.sin(angle), 0, -math.cos(angle))
	elseif distance < 2 * straightLength + math.pi * radius then
		local straightDistance = distance - straightLength - math.pi * radius

		position = Vector3.new(halfStraight - straightDistance, config.SurfaceY, -radius)
		tangent = Vector3.new(-1, 0, 0)
	else
		local curveDistance = distance - 2 * straightLength - math.pi * radius
		local angle = -HALF_PI - curveDistance / radius

		position = Vector3.new(
			-halfStraight + radius * math.cos(angle),
			config.SurfaceY,
			radius * math.sin(angle)
		)
		tangent = Vector3.new(math.sin(angle), 0, -math.cos(angle))
	end

	return position + Vector3.new(center.X, 0, center.Z), tangent
end

function StadiumTrack.getNearestDistance(worldPosition: Vector3, config): number
	local straightLength = config.StraightLengthStuds
	local radius = config.CurveRadiusStuds
	local halfStraight = straightLength / 2
	local localPosition = worldPosition - Vector3.new(config.Center.X, 0, config.Center.Z)
	local bestDistance = 0
	local bestDistanceSquared = math.huge

	local function consider(candidatePosition: Vector3, candidateDistance: number)
		local distanceSquared = horizontalDistanceSquared(localPosition, candidatePosition)

		if distanceSquared < bestDistanceSquared then
			bestDistanceSquared = distanceSquared
			bestDistance = candidateDistance
		end
	end

	local bottomX = math.clamp(localPosition.X, -halfStraight, halfStraight)
	consider(Vector3.new(bottomX, config.SurfaceY, radius), bottomX + halfStraight)

	local rightOffset = localPosition - Vector3.new(halfStraight, 0, 0)
	local rightAngle = math.clamp(math.atan2(rightOffset.Z, rightOffset.X), -HALF_PI, HALF_PI)
	consider(
		Vector3.new(
			halfStraight + radius * math.cos(rightAngle),
			config.SurfaceY,
			radius * math.sin(rightAngle)
		),
		straightLength + radius * (HALF_PI - rightAngle)
	)

	local topX = math.clamp(localPosition.X, -halfStraight, halfStraight)
	consider(
		Vector3.new(topX, config.SurfaceY, -radius),
		straightLength + math.pi * radius + halfStraight - topX
	)

	local leftOffset = localPosition - Vector3.new(-halfStraight, 0, 0)
	local leftAngle = math.atan2(leftOffset.Z, leftOffset.X)

	if leftAngle > HALF_PI then
		leftAngle -= 2 * math.pi
	end

	leftAngle = math.clamp(leftAngle, -THREE_HALF_PI, -HALF_PI)
	consider(
		Vector3.new(
			-halfStraight + radius * math.cos(leftAngle),
			config.SurfaceY,
			radius * math.sin(leftAngle)
		),
		2 * straightLength + math.pi * radius + radius * (-HALF_PI - leftAngle)
	)

	return bestDistance % StadiumTrack.getLength(config)
end

return StadiumTrack
