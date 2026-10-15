# Feature 001 — Expedition Loop (Vertical Slice)

**Status:** Draft
**Milestone:** M1 — one map, one class, one night boss, full day cycle, solo + co-op

## Summary
The core Nightreign loop as a playable Roblox experience: players spawn into Limveld,
farm through a timed day while the Night's Tide ring shrinks, fight a night boss at the
ring's center, survive a second day, then face the Nightlord. Death of the whole party
or the Nightlord's death ends the run.

## User Stories

### P1 — I can move and fight like a Nightfarer
As a player, I want souls-flavored movement and melee so the game feels like the source.
- **Given** I spawn, **when** I hold Sprint, **then** my character surge-sprints (faster
  than default run, no stamina bar in v1).
- **Given** I press Q, **when** I have a weapon, **then** I dodge-roll with brief i-frames
  (0.3s) and a 1.2s cooldown.
- **Given** I left-click near an enemy, **when** my swing connects during the active
  frames, **then** the server validates range + cooldown and applies damage.
- **Given** I fall any height, **then** I take no fall damage (Nightfarer trait).

### P2 — The day cycle and Night's Tide run the match
As a player, the world pressures me on a clock, like Limveld.
- **Given** Day 1 starts, **when** 4:30 (compressed default: 2:00) elapses, **then** the
  Night's Tide ring appears at map radius and begins shrinking to a target circle over
  3:00 (compressed: 1:20).
- **Given** I stand outside the ring, **then** I take escalating DoT (2%+15/s ramping to
  10%+30 2x/s after 110s exposure; exposure resets on reaching safety) and my HP bar tints.
- **Given** the accelerated phase begins at 11:00 (compressed: 5:00), **when** the ring
  collapses, **then** it funnels to the boss arena and the night boss spawns.
- **Given** the boss dies, **then** a new day begins, the ring resets to full map, and
  HP/flasks restore.

### P3 — Farming rewards me with runes, levels, and loot
- **Given** I kill an enemy, **then** it drops runes (server-rolled) that all nearby
  party members collect.
- **Given** I have enough runes, **when** I interact with a Site of Grace, **then** I
  level up a stat (Vigor/Endurance/Strength/Dexterity) via a server-validated purchase.
- **Given** an enemy dies, **when** the rarity roll hits, **then** it drops a weapon of
  rarity (common/uncommon/rare/legendary) with rolled bonus power; I equip via pickup.

### P4 — Downed state and revival create co-op moments
- **Given** my HP hits 0, **then** I enter downed state: crawl slowly, cannot attack.
- **Given** an ally attacks my downed body, **then** I revive with 30% HP.
- **Given** I stay downed 60s or the whole party is downed, **then** I die: lose one
  level, drop runes at the death spot, respawn at the last Grace.
- **Given** solo mode, **then** enemy HP/poise are ÷3, runes +20%, and I get 1 auto-revive
  per boss fight.

### P5 — The Nightlord ends the run
- **Given** Night 2's boss dies, **then** the party enters the Spirit Shelter (small prep
  zone: Grace + merchant), and the exit door starts the Nightlord encounter.
- **Given** the Nightlord dies, **then** the run is won: victory screen, rewards tally.
- **Given** the whole party dies during any boss, **then** the run is lost: defeat screen.

## Functional Requirements
- FR-1: Match state machine (DAY1 → NIGHT1 → DAY2 → NIGHT2 → SHELTER → NIGHTLORD → END)
  on the server, with a config-driven timeline (authentic 15-min days default; compressible).
- FR-2: Night's Tide = server-owned ring (center, radius, phase); clients render + predict DoT.
- FR-3: Combat: server validates range/cooldown/i-frames; blink-typed remotes only.
- FR-4: Enemies via jecs: spawner components, AI state (idle/chase/attack), loot tables.
- FR-5: Map: one hand-authored ~1024-stud island template + seeded POI scatter (camps,
  churches, Grace sites, boss arenas) — procedural models acceptable for v1 placeholders.
- FR-6: Party: 1–3 players; reserved-server teleport from hub (hub may be stub in M1).
- FR-7: HUD: HP/flask/rune counters, day-phase timer, tide ring on a minimap corner.

## Success Criteria
- SC-1: A full 3-day run completes co-op (3P) and solo without server errors in output.
- SC-2: Tide DoT numbers match config within 1 tick across server/client.
- SC-3: Revive-by-hit works with 2 players in under 3s of contact.
- SC-4: Run of `luau-lsp analyze` + `selene` + `stylua --check` all green at merge.
- SC-5: Full authentic timeline runs 45:00 ±30s; compressed timeline runs 15:00 ±30s.
