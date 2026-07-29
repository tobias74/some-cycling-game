local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local StadiumTrack = require(ReplicatedStorage.Shared.StadiumTrack)

local TrackService = {}
TrackService.__index = TrackService

local TRACK_FOLDER_NAME = "StadiumTrack"
local TRACK_COLOR = Color3.fromRGB(177, 72, 58)
local LINE_COLOR = Color3.fromRGB(245, 242, 228)
local LINE_WIDTH_STUDS = 0.22
local LINE_HEIGHT_STUDS = 0.035
local PANEL_OVERLAP_STUDS = 0.15

local function createRibbonSegment(
	parent: Instance,
	name: string,
	first: Vector3,
	second: Vector3,
	width: number,
	height: number,
	color: Color3,
	canCollide: boolean,
	yOffset: number
)
	local horizontalFirst = Vector3.new(first.X, first.Y + yOffset, first.Z)
	local horizontalSecond = Vector3.new(second.X, second.Y + yOffset, second.Z)
	local midpoint = (horizontalFirst + horizontalSecond) / 2
	local length = (horizontalSecond - horizontalFirst).Magnitude
	local part = Instance.new("Part")

	part.Name = name
	part.Anchored = true
	part.CanCollide = canCollide
	part.CanQuery = canCollide
	part.CanTouch = canCollide
	part.CastShadow = canCollide
	part.Color = color
	part.Material = if canCollide then Enum.Material.Asphalt else Enum.Material.SmoothPlastic
	part.Size = Vector3.new(width, height, length + PANEL_OVERLAP_STUDS)
	part.CFrame = CFrame.lookAt(midpoint, horizontalSecond)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
end

local function offsetPosition(position: Vector3, tangent: Vector3, offset: number): Vector3
	local left = Vector3.new(-tangent.Z, 0, tangent.X)

	return position + left * offset
end

local function createSurfaceSegment(
	parent: Instance,
	config,
	firstDistance: number,
	secondDistance: number
)
	local first = StadiumTrack.getPositionAndTangent(firstDistance, config)
	local second = StadiumTrack.getPositionAndTangent(secondDistance, config)

	createRibbonSegment(
		parent,
		"TrackSurface",
		first,
		second,
		config.WidthStuds,
		config.SurfaceThicknessStuds,
		TRACK_COLOR,
		true,
		-config.SurfaceThicknessStuds / 2
	)
end

local function createLineSegment(
	parent: Instance,
	config,
	firstDistance: number,
	secondDistance: number,
	offset: number
)
	local firstPosition, firstTangent = StadiumTrack.getPositionAndTangent(firstDistance, config)
	local secondPosition, secondTangent = StadiumTrack.getPositionAndTangent(secondDistance, config)

	createRibbonSegment(
		parent,
		"LaneLine",
		offsetPosition(firstPosition, firstTangent, offset),
		offsetPosition(secondPosition, secondTangent, offset),
		LINE_WIDTH_STUDS,
		LINE_HEIGHT_STUDS,
		LINE_COLOR,
		false,
		LINE_HEIGHT_STUDS / 2
	)
end

local function forEachTrackSection(config, callback)
	local straightLength = config.StraightLengthStuds
	local curveLength = math.pi * config.CurveRadiusStuds
	local firstCurveStart = straightLength
	local secondStraightStart = firstCurveStart + curveLength
	local secondCurveStart = secondStraightStart + straightLength

	callback(0, straightLength)

	for index = 0, config.CurveSegments - 1 do
		local startAlpha = index / config.CurveSegments
		local endAlpha = (index + 1) / config.CurveSegments

		callback(
			firstCurveStart + curveLength * startAlpha,
			firstCurveStart + curveLength * endAlpha
		)
	end

	callback(secondStraightStart, secondCurveStart)

	for index = 0, config.CurveSegments - 1 do
		local startAlpha = index / config.CurveSegments
		local endAlpha = (index + 1) / config.CurveSegments

		callback(
			secondCurveStart + curveLength * startAlpha,
			secondCurveStart + curveLength * endAlpha
		)
	end
end

function TrackService.new(config)
	local oldTrack = Workspace:FindFirstChild(TRACK_FOLDER_NAME)

	if oldTrack then
		oldTrack:Destroy()
	end

	local self = setmetatable({
		config = config,
		folder = Instance.new("Folder"),
	}, TrackService)

	self.folder.Name = TRACK_FOLDER_NAME
	self.folder.Parent = Workspace
	self:_buildTrack()
	self:_positionSpawn()

	Players.PlayerAdded:Connect(function(player)
		self:_connectPlayer(player)
	end)

	for _, player in Players:GetPlayers() do
		self:_connectPlayer(player)
	end

	return self
end

function TrackService:_buildTrack()
	forEachTrackSection(self.config, function(firstDistance, secondDistance)
		createSurfaceSegment(self.folder, self.config, firstDistance, secondDistance)
	end)

	local laneWidth = self.config.WidthStuds / self.config.LaneCount

	for laneIndex = 0, self.config.LaneCount do
		local offset = -self.config.WidthStuds / 2 + laneIndex * laneWidth

		forEachTrackSection(self.config, function(firstDistance, secondDistance)
			createLineSegment(self.folder, self.config, firstDistance, secondDistance, offset)
		end)
	end
end

function TrackService:_positionSpawn()
	local spawnLocation = Workspace:FindFirstChildOfClass("SpawnLocation")

	if not spawnLocation then
		return
	end

	local startPosition, startTangent = StadiumTrack.getPositionAndTangent(0, self.config)
	local spawnPosition = startPosition + Vector3.new(0, 0.5, 0)

	spawnLocation.Anchored = true
	spawnLocation.CanCollide = false
	spawnLocation.Transparency = 1
	spawnLocation.Size = Vector3.new(6, 1, 6)
	spawnLocation.CFrame = CFrame.lookAt(spawnPosition, spawnPosition + startTangent)
end

function TrackService:_connectPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		self:_placeCharacterAtStart(character)
	end)

	if player.Character then
		self:_placeCharacterAtStart(player.Character)
	end
end

function TrackService:_placeCharacterAtStart(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local rootPart = character:WaitForChild("HumanoidRootPart", 10)

	if not humanoid or not humanoid:IsA("Humanoid") then
		return
	end

	if not rootPart or not rootPart:IsA("BasePart") then
		return
	end

	local startPosition, startTangent = StadiumTrack.getPositionAndTangent(0, self.config)
	local rootHeight = humanoid.HipHeight + rootPart.Size.Y / 2
	local rootPosition = startPosition + Vector3.new(0, rootHeight, 0)

	humanoid.AutoJumpEnabled = false
	humanoid.JumpHeight = 0
	humanoid.JumpPower = 0
	character:PivotTo(CFrame.lookAt(rootPosition, rootPosition + startTangent))
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
end

return TrackService
