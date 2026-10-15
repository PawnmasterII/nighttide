--!strict
-- P2: day cycle + Night's Tide. Server-authoritative match state.
-- State machine: DAY1 -> NIGHT1 -> DAY2 -> NIGHT2 -> SHELTER -> NIGHTLORD -> END

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DayTimeline = require(ReplicatedStorage.Shared.Config.DayTimeline)
local TideDoT = require(ReplicatedStorage.Shared.Config.TideDoT)
local Net = require(script.Parent.Net)

local Match = {}

export type MatchState = "DAY1" | "NIGHT1" | "DAY2" | "NIGHT2" | "SHELTER" | "NIGHTLORD" | "END"

local state: MatchState = "DAY1"
local dayIndex = 1
local elapsed = 0
local tideCenter = Vector3.zero
local tideRadius = 0
local tideActive = false

-- exposure seconds per player, reset when safe
local exposure: { [Player]: number } = {}
local tickAccum: { [Player]: number } = {}

local function pickCenter(): Vector3
	local t = DayTimeline.current()
	local rng = Random.new(os.time() + dayIndex * 7919)
	return t.centers[rng:NextInteger(1, #t.centers)]
end

local function broadcastPhase(phase: string)
	Net.TidePhase.FireAll(state, dayIndex, tideCenter.X, tideCenter.Z, tideRadius, phase)
end

-- Lerp the ring from start to end radius across the slow-shrink window,
-- then again (faster) during the collapse window.
local function computeRadius(t: number, cfg: DayTimeline.Timeline): number
	local ph = cfg.phases[1]
	if t < ph.openAt then
		return cfg.tideStartRadius
	elseif t <= ph.closeDoneAt then
		local a = (t - ph.openAt) / (ph.closeDoneAt - ph.openAt)
		return cfg.tideStartRadius + (cfg.tideEndRadius - cfg.tideStartRadius) * a
	elseif t < ph.accelerateAt then
		return cfg.tideEndRadius
	elseif t <= ph.collapseDoneAt then
		local a = (t - ph.accelerateAt) / (ph.collapseDoneAt - ph.accelerateAt)
		-- accelerate: ease-in collapse
		return cfg.tideEndRadius * (1 - a * a)
	end
	return 0
end

local function distanceFromCenter(pos: Vector3): number
	local flat = Vector3.new(pos.X - tideCenter.X, 0, pos.Z - tideCenter.Z)
	return flat.Magnitude
end

local function applyTideDamage(dt: number)
	for _, player in Players:GetPlayers() do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not (hum and hrp and hrp:IsA("BasePart")) then
			continue
		end

		if not tideActive or distanceFromCenter(hrp.Position) <= tideRadius then
			exposure[player] = 0
			tickAccum[player] = 0
			continue
		end

		exposure[player] = (exposure[player] or 0) + dt
		local exp = exposure[player] :: number
		local interval = if exp > TideDoT.tierOneEnd
			then TideDoT.tierTwoTickRate
			else TideDoT.tickRate
		tickAccum[player] = (tickAccum[player] or 0) + dt
		if tickAccum[player] < interval then
			continue
		end
		tickAccum[player] = 0

		local maxHp = hum.MaxHealth
		local dmg = if exp > TideDoT.tierOneEnd
			then maxHp * TideDoT.tierTwoPercent + TideDoT.tierTwoFlat
			else maxHp * TideDoT.tierOnePercent + TideDoT.tierOneFlat
		hum:TakeDamage(dmg)
	end
end

local function runDay(kind: "DAY1" | "DAY2")
	state = kind
	dayIndex = if kind == "DAY1" then 1 else 2
	elapsed = 0
	tideCenter = pickCenter()
	tideActive = false
	tideRadius = DayTimeline.current().tideStartRadius
	table.clear(exposure)
	table.clear(tickAccum)

	local cfg = DayTimeline.current()
	local ph = cfg.phases[1]

	while elapsed < cfg.dayLength do
		elapsed += task.wait()
		local wasActive = tideActive
		tideActive = elapsed >= ph.openAt
		tideRadius = computeRadius(elapsed, cfg)

		if tideActive and not wasActive then
			broadcastPhase("rain_start")
		end
		if elapsed >= ph.collapseDoneAt then
			broadcastPhase("boss")
			break
		end
	end

	state = if kind == "DAY1" then "NIGHT1" else "NIGHT2"
	broadcastPhase("boss")
	-- Night boss placeholder: P3 replaces this with a real encounter.
	task.wait(3)
	broadcastPhase("day_clear")
end

function Match.GetState(): (MatchState, number, Vector3, number, boolean)
	return state, dayIndex, tideCenter, tideRadius, tideActive
end

function Match.Start()
	Net.TidePhase.FireAll(state, dayIndex, 0, 0, 0, "boot")

	RunService.Heartbeat:Connect(function(dt)
		if state == "DAY1" or state == "DAY2" then
			applyTideDamage(dt)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		exposure[player] = nil
		tickAccum[player] = nil
	end)

	task.spawn(function()
		runDay("DAY1")
		runDay("DAY2")
		state = "SHELTER"
		broadcastPhase("shelter")
		task.wait(5)
		state = "NIGHTLORD"
		broadcastPhase("nightlord")
		print("[NightTide] NIGHTLORD phase — encounter lands in P5")
		state = "END"
		broadcastPhase("end")
	end)

	print("[NightTide] match started")
end

return Match
