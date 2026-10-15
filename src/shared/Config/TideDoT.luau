--!strict
-- Night's Tide damage model — ports the documented Nightreign numbers.
-- Exposure is per-Nightfarer consecutive seconds inside the rain; reaching
-- safety resets it to 0.

local TideDoT = {
	-- first tier: 0-110s exposure -> 2% max HP + 15 flat, once per second
	tierOneEnd = 110,
	tierOnePercent = 0.02,
	tierOneFlat = 15,

	-- second tier: past 110s -> 10% max HP + 30 flat, twice per second
	tierTwoPercent = 0.10,
	tierTwoFlat = 30,
	tierTwoTickRate = 0.5, -- seconds between ticks

	-- clients predict ticks at this rate; server is authoritative
	tickRate = 1.0,

	-- HP bar tint bleeds to this colour while exposed
	tintColor = Color3.fromRGB(200, 60, 220),
}

table.freeze(TideDoT)
return TideDoT
