--!strict
-- P1 tunables — constitution III: every gameplay number lives here.

local Stats = {
	-- movement
	WalkSpeed = 16,
	SprintSpeed = 26,
	SprintFovKick = 8,

	-- dodge roll
	RollSpeed = 45,
	RollDuration = 0.35,
	RollIFrames = 0.3,
	RollCooldown = 1.2,

	-- melee
	SwingCooldown = 0.6,
	MeleeRange = 8,
	MeleeDamage = 25,
}

table.freeze(Stats)
return Stats
