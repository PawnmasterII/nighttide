--!strict
-- P1 client movement: surge sprint + dodge roll input.
-- Roblox Humanoids have no fall damage by default — the Nightfarer trait is free.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(ReplicatedStorage.Shared.Config.Stats)
local Net = require(script.Net)
local Tide = require(script.Tide)

local Movement = {}

local sprinting = false
local pendingRollDir: Vector3? = nil

local function humanoid(): Humanoid?
	local char = Players.LocalPlayer.Character
	if not char then
		return nil
	end
	return char:FindFirstChildOfClass("Humanoid")
end

local function applySpeed()
	local hum = humanoid()
	if not hum then
		return
	end
	hum.WalkSpeed = if sprinting then Stats.SprintSpeed else Stats.WalkSpeed
end

local function onSprint(_action: string, state: Enum.UserInputState)
	if state == Enum.UserInputState.Begin then
		sprinting = true
	elseif state == Enum.UserInputState.End then
		sprinting = false
	end
	applySpeed()
	return Enum.ContextActionResult.Sink
end

local function onRoll(_action: string, state: Enum.UserInputState)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local hum = humanoid()
	if not hum then
		return Enum.ContextActionResult.Pass
	end
	local dir = hum.MoveDirection -- world space, already normalized
	pendingRollDir = dir
	Net.RollRequest.Fire(dir.X, dir.Z)
	return Enum.ContextActionResult.Sink
end

-- Prediction: on grant, dash along the requested direction (client owns its
-- character physics; server owns cooldown + i-frames).
local function applyRollDash()
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not pendingRollDir or not (hrp and hrp:IsA("BasePart")) then
		return
	end
	local horizontal = Vector3.new(pendingRollDir.X, 0, pendingRollDir.Z)
	if horizontal.Magnitude < 0.1 then
		horizontal = hrp.CFrame.LookVector
	end
	hrp.AssemblyLinearVelocity = horizontal.Unit * Stats.RollSpeed
	task.delay(Stats.RollDuration, function()
		local still = char and char:FindFirstChild("HumanoidRootPart")
		if still and still:IsA("BasePart") then
			local v = still.AssemblyLinearVelocity
			still.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
		end
	end)
end

local function onSwing(_action: string, state: Enum.UserInputState)
	if state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	Net.SwingRequest.Fire()
	return Enum.ContextActionResult.Sink
end

function Movement.Start()
	ContextActionService:BindAction("NightTideSprint", onSprint, false, Enum.KeyCode.LeftShift)
	ContextActionService:BindAction("NightTideRoll", onRoll, false, Enum.KeyCode.Q)
	ContextActionService:BindAction("NightTideSwing", onSwing, false, Enum.KeyCode.F)

	Net.RollResult.On(function(code: number)
		if code == 0 then
			applyRollDash()
		else
			print("[NightTide] roll on cooldown")
		end
	end)

	Net.SwingResult.On(function(code: number, damage: number, part: Instance?)
		if code == 0 and part then
			print(`[NightTide] hit {part.Name} for {damage}`)
		end
	end)

	-- Respawn: restore base speed
	Players.LocalPlayer.CharacterAdded:Once(function()
		task.wait(0.1)
		sprinting = false
		applySpeed()
	end)

	Tide.Start()

	print("[NightTide] client up — Shift sprint · Q roll · F swing")
end

return Movement
