local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerMath = require(ReplicatedStorage.Shared.PowerMath)

local CyclistRigService = {}
CyclistRigService.__index = CyclistRigService

type VisualPart = {
	part: BasePart,
	offset: CFrame,
	spinMultiplier: number?,
}

local function createPart(
	model: Model,
	name: string,
	size: Vector3,
	offset: CFrame,
	color: Color3,
	shape: Enum.PartType?
): BasePart
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = offset
	part.Anchored = true
	part.CanCollide = false
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model

	return part
end

local function createVisualPart(
	visualParts: { VisualPart },
	model: Model,
	name: string,
	size: Vector3,
	offset: CFrame,
	color: Color3,
	shape: Enum.PartType?,
	spinMultiplier: number?
)
	local part = createPart(model, name, size, offset, color, shape)

	table.insert(visualParts, {
		part = part,
		offset = offset,
		spinMultiplier = spinMultiplier,
	})
end

local function setModelAttributes(
	model: Model,
	powerWatts: number,
	speed: number,
	ok: boolean,
	status: string
)
	model:SetAttribute("PowerWatts", math.floor(powerWatts + 0.5))
	model:SetAttribute("SpeedStudsPerSecond", math.floor(speed * 10 + 0.5) / 10)
	model:SetAttribute("BridgeConnected", ok)
	model:SetAttribute("BridgeStatus", status)
end

function CyclistRigService.new(config)
	local model = Instance.new("Model")
	model.Name = "BleCyclist"
	model.Parent = Workspace

	local self = setmetatable({
		config = config,
		model = model,
		visualParts = {},
		powerWatts = 0,
		speedStudsPerSecond = 0,
		distanceStuds = 0,
		wheelSpin = 0,
		bridgeOk = false,
		bridgeStatus = "waiting for bridge",
	}, CyclistRigService)

	self:_createRig()
	self:_start()

	return self
end

function CyclistRigService:_createRig()
	local black = Color3.fromRGB(28, 31, 34)
	local tire = Color3.fromRGB(8, 9, 10)
	local metal = Color3.fromRGB(78, 90, 104)
	local accent = Color3.fromRGB(227, 53, 43)
	local skin = Color3.fromRGB(227, 188, 145)
	local jersey = Color3.fromRGB(38, 126, 202)

	createVisualPart(
		self.visualParts,
		self.model,
		"RearWheel",
		Vector3.new(2.4, 0.16, 2.4),
		CFrame.new(-2.1, 0, 0) * CFrame.Angles(math.rad(90), 0, 0),
		tire,
		Enum.PartType.Cylinder,
		1
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"FrontWheel",
		Vector3.new(2.4, 0.16, 2.4),
		CFrame.new(2.1, 0, 0) * CFrame.Angles(math.rad(90), 0, 0),
		tire,
		Enum.PartType.Cylinder,
		1
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"FrameTopTube",
		Vector3.new(3.2, 0.16, 0.16),
		CFrame.new(0, 1.15, 0),
		accent
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"FrameDownTube",
		Vector3.new(2.8, 0.16, 0.16),
		CFrame.new(-0.2, 0.65, 0) * CFrame.Angles(0, 0, math.rad(-16)),
		accent
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"SeatPost",
		Vector3.new(0.14, 1.4, 0.14),
		CFrame.new(-0.7, 1.35, 0),
		metal
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"Fork",
		Vector3.new(0.14, 1.6, 0.14),
		CFrame.new(1.65, 0.85, 0) * CFrame.Angles(0, 0, math.rad(-12)),
		metal
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"Handlebar",
		Vector3.new(0.2, 0.2, 1.4),
		CFrame.new(1.95, 1.78, 0),
		black
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"Seat",
		Vector3.new(0.85, 0.16, 0.45),
		CFrame.new(-0.7, 2.1, 0),
		black
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"Torso",
		Vector3.new(0.8, 1.1, 0.45),
		CFrame.new(-0.15, 2.65, 0) * CFrame.Angles(0, 0, math.rad(-18)),
		jersey
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"Head",
		Vector3.new(0.5, 0.5, 0.5),
		CFrame.new(0.2, 3.35, 0),
		skin,
		Enum.PartType.Ball
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"Helmet",
		Vector3.new(0.58, 0.34, 0.58),
		CFrame.new(0.2, 3.58, 0),
		black,
		Enum.PartType.Ball
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"LeftArm",
		Vector3.new(0.22, 1.2, 0.22),
		CFrame.new(0.65, 2.65, -0.38) * CFrame.Angles(0, 0, math.rad(-48)),
		skin
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"RightArm",
		Vector3.new(0.22, 1.2, 0.22),
		CFrame.new(0.65, 2.65, 0.38) * CFrame.Angles(0, 0, math.rad(-48)),
		skin
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"LeftLeg",
		Vector3.new(0.24, 1.15, 0.24),
		CFrame.new(-0.55, 1.55, -0.28) * CFrame.Angles(0, 0, math.rad(28)),
		black
	)
	createVisualPart(
		self.visualParts,
		self.model,
		"RightLeg",
		Vector3.new(0.24, 1.15, 0.24),
		CFrame.new(-0.15, 1.5, 0.28) * CFrame.Angles(0, 0, math.rad(-24)),
		black
	)

	self:_render()
	setModelAttributes(self.model, 0, 0, false, self.bridgeStatus)
end

function CyclistRigService:_start()
	RunService.Heartbeat:Connect(function(deltaTime)
		local targetSpeed = PowerMath.powerToSpeedStudsPerSecond(self.powerWatts, self.config)
		local maxDelta = self.config.AccelerationStudsPerSecond * deltaTime

		self.speedStudsPerSecond =
			PowerMath.approach(self.speedStudsPerSecond, targetSpeed, maxDelta)
		self.distanceStuds += self.speedStudsPerSecond * deltaTime
		self.wheelSpin += self.speedStudsPerSecond * deltaTime / 1.2

		self:_render()
		setModelAttributes(
			self.model,
			self.powerWatts,
			self.speedStudsPerSecond,
			self.bridgeOk,
			self.bridgeStatus
		)
	end)
end

function CyclistRigService:_render()
	local baseFrame = self.config.SpawnCFrame * CFrame.new(self.distanceStuds, 0, 0)

	for _, visualPart in self.visualParts do
		local offset = visualPart.offset

		if visualPart.spinMultiplier then
			offset *= CFrame.Angles(0, self.wheelSpin * visualPart.spinMultiplier, 0)
		end

		visualPart.part.CFrame = baseFrame * offset
	end
end

function CyclistRigService:setPowerSample(sample)
	local maxPowerWatts = 1000

	if sample.maxPowerWatts then
		maxPowerWatts = sample.maxPowerWatts
	end

	self.powerWatts = PowerMath.clampPowerWatts(sample.powerWatts, maxPowerWatts)
	self.bridgeOk = sample.ok

	if sample.ok then
		self.bridgeStatus = "bridge connected"
	else
		self.bridgeStatus = sample.errorMessage
	end
end

return CyclistRigService
