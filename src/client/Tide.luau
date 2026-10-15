--!strict
-- P2 client: renders the Night's Tide ring and tints HP while exposed.
-- The wall is a ring of thin beam parts; it fades in at rain_start and
-- narrows as the server pushes radius updates.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TideDoT = require(ReplicatedStorage.Shared.Config.TideDoT)
local Net = require(script.Parent.Net)

local Tide = {}

local WALL_SEGMENTS = 48
local WALL_HEIGHT = 60

local folder: Folder? = nil
local segments: { Part } = {}
local center = Vector3.zero
local radius = 0
local active = false
local targetRadius = 0

local function ensureFolder(): Folder
	if folder and folder.Parent then
		return folder
	end
	local f = Instance.new("Folder")
	f.Name = "TideRing"
	f.Parent = workspace
	folder = f
	table.clear(segments)
	for i = 1, WALL_SEGMENTS do
		local p = Instance.new("Part")
		p.Name = `TideSegment{i}`
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.ForceField
		p.Color = Color3.fromRGB(70, 130, 255)
		p.Transparency = 0.55
		p.Size = Vector3.new(8, WALL_HEIGHT, 2)
		p.Parent = f
		segments[i] = p
	end
	return f
end

local function layout()
	local f = ensureFolder()
	if not active or radius <= 0 then
		for _, p in segments do
			p.Transparency = 1
		end
		return
	end

	local step = (math.pi * 2) / WALL_SEGMENTS
	local segLen = math.max((2 * math.pi * radius) / WALL_SEGMENTS, 4)
	for i, p in segments do
		local a = (i - 1) * step
		local pos = Vector3.new(
			center.X + math.cos(a) * radius,
			WALL_HEIGHT * 0.5 - 8,
			center.Z + math.sin(a) * radius
		)
		p.Size = Vector3.new(segLen * 1.08, WALL_HEIGHT, 2)
		p.CFrame = CFrame.lookAt(pos, Vector3.new(center.X, pos.Y, center.Z))
		p.Transparency = if f.Parent then 0.55 else 1
	end
end

-- Atmosphere shift while outside the ring (the HP-bar tint itself is HUD work, P3)
local function tintExposed()
	local char = Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not (hum and hrp and hrp:IsA("BasePart")) then
		return
	end
	local flat = Vector3.new(hrp.Position.X - center.X, 0, hrp.Position.Z - center.Z)
	local outside = active and radius > 0 and flat.Magnitude > radius
	if outside then
		Lighting.Ambient = TideDoT.tintColor:Lerp(Color3.new(0, 0, 0), 0.85)
	elseif Lighting.Ambient ~= Color3.new(0, 0, 0) then
		Lighting.Ambient = Color3.new(0, 0, 0)
	end
end

function Tide.Start()
	ensureFolder()

	Net.TidePhase.On(
		function(state: string, day: number, cx: number, cz: number, r: number, phase: string)
			center = Vector3.new(cx, 0, cz)
			radius = r
			targetRadius = r
			active = r > 0 and phase ~= "boot" and phase ~= "end"
			if phase == "rain_start" or phase == "boss" then
				active = true
			end
			print(`[NightTide] phase={phase} state={state} day={day} radius={math.floor(r)}`)
			layout()
		end
	)

	RunService.Heartbeat:Connect(function(dt: number)
		if math.abs(radius - targetRadius) > 0.5 then
			radius += (targetRadius - radius) * math.min(dt * 4, 1)
			layout()
		end
		tintExposed()
	end)

	print("[NightTide] tide client up")
end

return Tide
