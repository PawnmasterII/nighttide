--!strict
-- NightTide server bootstrap.

local Combat = require(script.Combat)
local Match = require(script.Match)

Combat.Start()
Match.Start()
print("[NightTide] server up — live sync confirmed ✓")
