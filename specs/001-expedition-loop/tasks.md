# Tasks — Feature 001 Expedition Loop

> Progress tracker. Check items **as** they complete. Provenance: name the command/run
> that verified each gate — never claim a runner that wasn't invoked.

## Setup
- [x] T0.1 Rokit + toolchain pinned in rokit.toml (rojo 7.7.1, wally 0.3.2, selene 0.32.0, stylua 2.6.0, luau-lsp 1.70.1) — verified: `rokit list` + `--version` calls
- [x] T0.2 VS Code extensions (evaera.vscode-rojo, johnnymorganz.luau-lsp) — verified: `code --list-extensions`
- [x] T0.3 Rojo Studio plugin placed (Store install lacks registry keys) — verified: Rojo.rbxm in %LOCALAPPDATA%\Roblox\Plugins
- [x] T0.4 Spec-kit scaffold + constitution + spec + plan — files in .specify/ and specs/001-expedition-loop/
- [ ] T0.5 **USER**: Enable Studio MCP (Assistant → ⋯ → Manage MCP Servers → Enable Studio as MCP server → Quick connect: Claude Code) — then verify `claude mcp list`
- [x] T0.6 wally.toml + `wally install` (jecs 0.11.0, Promise 3.5.2, Signal 2.0.3, Trove 1.8.3) — verified: "Downloaded 4 packages"; blink is a rokit CLI (0.18.9), not a wally pkg
- [x] T0.7 `rojo build -o nighttide.rbxlx` green — verified: built 216 KB place file; gates script `tools/check.sh` all green (selene 0 warn / stylua clean / analyze exit 0 / build OK)
- [ ] T0.8 `rojo serve` + plugin Connect → live-sync verified (edit a test script, see it land)

## P1 — Movement & combat feel
- [x] T1.1 Config: Config/Stats.luau (walk/sprint/roll numbers, i-frames, cooldowns)
- [x] T1.2 Net: blink contract net/Net.blink → codegen to net/gen/ (mapped into tree via default.project.json); RollRequest/SwingRequest/RollResult/SwingResult
- [x] T1.3 Client: sprint (26 vs 16 walk) + no-fall-damage (free via Humanoid)
- [x] T1.4 Client+Server: dodge-roll — server validates cooldown + grants i-frames; client predicts the dash velocity on grant
- [x] T1.5 Server: melee validation (8-stud ray, cooldown) + attribute damage on TrainingDummy
- [x] T1.6a Gate: `tools/check.sh` ALL GATES GREEN (blink → selene 0/0 → stylua clean → analyze 0 errors w/ sourcemap → rojo build OK)
- [ ] T1.6b Playtest: needs Studio session (MCP toggle pending, or manual F5: Shift sprint / Q roll / F swing vs the red dummy)

## P2 — Day cycle & Night's Tide
- [ ] T2.1 Config: Config/DayTimeline.luau (authentic + compressed) + Config/TideDoT.luau
- [ ] T2.2 Server: Match state machine (DAY1→NIGHT1→DAY2→NIGHT2→SHELTER→NIGHTLORD→END)
- [ ] T2.3 Server: tide ring (center/radius/phase) + DoT application + exposure ramp
- [ ] T2.4 Client: tide ring render (beams/particles wall) + HP tint + DoT prediction
- [ ] T2.5 Server: night boss spawn at ring collapse; day reset on kill
- [ ] T2.6 Gate: analyze+selene+stylua green; playtest one full compressed day

## P3 — Farming: runes, levels, loot
- [ ] T3.1 jecs world + enemy spawner components + basic chase AI
- [ ] T3.2 Runes: server-rolled drops, radial pickup, HUD counter
- [ ] T3.3 Grace sites: level-up purchase (Vigor/End/Str/Dex), server-validated
- [ ] T3.4 Loot: rarity table, weapon drops with rolled bonus, equip flow
- [ ] T3.5 Gate: green gates + playtest farm-to-level-up loop

## P4 — Downed/revive & solo rules
- [ ] T4.1 Downed state (crawl, no attack, 60s timer, level loss + rune drop on death)
- [ ] T4.2 Revive-by-ally-hit (30% HP) + party-wipe check
- [ ] T4.3 Solo mode multipliers (HP/poise ÷3, runes +20%, 1 auto-revive per boss)
- [ ] T4.4 Gate: green gates + 2-player revive test (SC-3)

## P5 — Nightlord finale
- [ ] T5.1 Spirit Shelter transition + prep zone (Grace + merchant stub)
- [ ] T5.2 Nightlord encounter (1 boss kit: phases, telegraphed AoE)
- [ ] T5.3 Win/defeat screens + rewards tally
- [ ] T5.4 Final gate: full co-op run (SC-1) + both timelines (SC-5)

## Defer to M2+
- Multi-class Nightfarers, lock-on camera, matchmaking hub place, ElevenLabs SFX pass,
  Meshy/Tripo hero assets, minimap polish
