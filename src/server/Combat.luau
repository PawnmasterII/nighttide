--!strict
-- P1 combat: swing validation, i-frame windows, damage application.
-- Server-authoritative per constitution I.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = require(ReplicatedStorage.Shared.Config.Stats)
local Net = require(script.Parent.Net)

local Combat = {}

local iFrameUntil: { [Player]: number } = {}
local lastRoll: { [Player]: number } = {}
local lastSwing: { [Player]: number } = {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function characterRoot(player: Player): BasePart?
	local char = player.Character
	if not char then
		return nil
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	return if hrp and hrp:IsA("BasePart") then hrp else nil
end

function Combat.IsInvulnerable(player: Player): boolean
	return (iFrameUntil[player] or 0) > os.clock()
end

function Combat.Start()
	-- Training dummy: anchored part with a Health attribute (R15 rigs come in P3).
	local dummy = Instance.new("Part")
	dummy.Name = "TrainingDummy"
	dummy.Size = Vector3.new(4, 8, 4)
	dummy.Position = Vector3.new(0, 4, -20)
	dummy.Anchored = true
	dummy.Color = Color3.fromRGB(160, 60, 60)
	dummy:SetAttribute("Health", 100.0)
	dummy:SetAttribute("MaxHealth", 100.0)
	dummy.Parent = workspace

	Net.RollRequest.On(function(player: Player, _dirX: number, _dirZ: number)
		local now = os.clock()
		if (lastRoll[player] or -math.huge) + Stats.RollCooldown > now then
			Net.RollResult.Fire(player, 1)
			return
		end
		lastRoll[player] = now
		iFrameUntil[player] = now + Stats.RollIFrames

		-- Server grants the speed burst so client edits can't fake it forever;
		-- the client animates locally for responsiveness.
		task.spawn(function()
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if not hum then
				return
			end
			local prev = hum.WalkSpeed
			hum.WalkSpeed = Stats.RollSpeed
			task.wait(Stats.RollDuration)
			if hum.Parent and hum.WalkSpeed == Stats.RollSpeed then
				hum.WalkSpeed = prev
			end
		end)

		Net.RollResult.Fire(player, 0)
	end)

	Net.SwingRequest.On(function(player: Player)
		local now = os.clock()
		if (lastSwing[player] or -math.huge) + Stats.SwingCooldown > now then
			return
		end
		lastSwing[player] = now

		local char = player.Character
		if not char then
			return
		end
		local hrp = characterRoot(player)
		if not hrp then
			return
		end

		rayParams.FilterDescendantsInstances = { char }
		local result =
			workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * Stats.MeleeRange, rayParams)
		if not result then
			Net.SwingResult.FireAll(1, 0, nil)
			return
		end

		local part = result.Instance
		local health = part:GetAttribute("Health")
		if typeof(health) == "number" then
			local dealt = math.min(Stats.MeleeDamage, health)
			part:SetAttribute("Health", health - dealt)
			Net.SwingResult.FireAll(0, dealt, part)
			if health - dealt <= 0 then
				part:Destroy() -- dummy death; loot/XP arrive in P3
			end
		else
			Net.SwingResult.FireAll(0, 0, part)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		iFrameUntil[player] = nil
		lastRoll[player] = nil
		lastSwing[player] = nil
	end)
end

return Combat
