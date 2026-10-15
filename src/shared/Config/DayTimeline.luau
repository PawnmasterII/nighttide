--!strict
-- P2 tunables — expedition timeline. Constitution III: every number lives here.
-- Authentic = Nightreign parity. Compressed = dev/testing default.

export type Phase = {
	name: string,
	-- seconds from day start
	openAt: number, -- tide first appears
	closeDoneAt: number, -- slow shrink completes (ring at final radius)
	accelerateAt: number, -- fast collapse begins
	collapseDoneAt: number, -- boss arena reached
}

export type Timeline = {
	dayLength: number,
	tideStartRadius: number,
	tideEndRadius: number,
	phases: { Phase },
	-- tide ring center candidates (map POIs); one is chosen per day
	centers: { Vector3 },
}

local AUTHENTIC: Timeline = {
	dayLength = 900, -- 15:00
	tideStartRadius = 512,
	tideEndRadius = 90,
	phases = {
		{
			name = "open",
			openAt = 270,
			closeDoneAt = 450,
			accelerateAt = 660,
			collapseDoneAt = 840,
		},
	},
	centers = {
		Vector3.new(300, 0, -240),
		Vector3.new(-320, 0, 180),
		Vector3.new(120, 0, 420),
	},
}

local COMPRESSED: Timeline = {
	dayLength = 300, -- 5:00
	tideStartRadius = 512,
	tideEndRadius = 90,
	phases = {
		{ name = "open", openAt = 90, closeDoneAt = 150, accelerateAt = 220, collapseDoneAt = 280 },
	},
	centers = {
		Vector3.new(300, 0, -240),
		Vector3.new(-320, 0, 180),
		Vector3.new(120, 0, 420),
	},
}

local DayTimeline = {
	-- Flip this one field to switch pacing (SC-5 verifies both).
	-- USER DECISION PENDING: default stays authentic until told otherwise.
	active = "compressed" :: "authentic" | "compressed",
	authentic = AUTHENTIC,
	compressed = COMPRESSED,
}

function DayTimeline.current(): Timeline
	return if DayTimeline.active == "authentic" then AUTHENTIC else COMPRESSED
end

table.freeze(DayTimeline)
return DayTimeline
