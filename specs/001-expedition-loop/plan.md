# Plan — Feature 001 Expedition Loop

## Stack
- **Runtime:** Roblox Studio, Rojo 7.7.1 live-sync from `src/`
- **Language:** Luau `--!strict`, verified by luau-lsp (sourcemap-driven DataModel types)
- **ECS:** jecs (Wally) — server-side entities for enemies, loot drops, tide zones
- **Networking:** blink 0.18.9 (rokit CLI) — IDL at `net/Net.blink` compiles to `net/gen/{Server,Client,Types}.luau`; Rojo maps those files in as `Net` ModuleScripts (single file = the module itself, no children). `tools/check.sh` runs codegen first.
- **Utilities:** Promise, Trove, Signal (Wally) — lifecycle hygiene
- **Testing:** luau-lsp analyze + selene + stylua gates; manual playtest via Studio MCP
  (play solo + console log read + screenshot)

## Layout (Rojo)
```
src/
  shared/            → ReplicatedStorage.Shared
    Config/          — all tunables (DayTimeline, TideDoT, Rarity, Stats, SoloMode)
    Net/             — blink contract (single source of remotes)
    Util/            — pure helpers (formatting, math)
  server/            → ServerScriptService.Server
    init.server.luau — bootstraps services
    Match/           — match state machine, tide ring owner
    Combat/          — validation, damage, i-frames
    Enemies/         — jecs world, spawners, AI, bosses
    Loot/            — rarity rolls, equipment
    Progression/     — runes, levels, Grace sites
  client/            → StarterPlayer.StarterPlayerScripts.Client
    init.client.luau
    Hud/             — HP/flask/runes/timer/minimap ring
    Movement/        — sprint, dodge-roll input + prediction
    Effects/         — tide rain tint, boss vignettes
```

## Key decisions
- Humanoid + custom input layer for movement (not the new CCL — custom abilities
  unsupported as of 2026-10; revisit when dodge/roll abilities ship).
- Tide ring = server-computed circle; clients interpolate between server syncs (5 Hz)
  and locally predict DoT ticks to avoid per-hit remotes.
- Place file (`nighttide.rbxlx`) built via `rojo build` for first open; after that,
  live-sync carries all script edits. Terrain/meshes added in Studio are out-of-band.
- Config-first compression: `Config.DayTimeline` holds both authentic and compressed
  timelines; the active one is a single setting — SC-5 verifies both.

## Risks
- blink API drift → pin wally versions in `wally.toml`, lockfile committed.
- jecs learning curve → keep enemy count modest in M1; iterate.
- Studio MCP must be enabled manually once (user's 30-second toggle) before agent
  playtesting works; until then playtests are user-run.
