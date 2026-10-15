# NightTide — Project Constitution

## Identity
A Roblox co-op extraction-boss-rush inspired by Elden Ring Nightreign's expedition loop:
3 players, 2 farm days with a shrinking Night's Tide ring, night bosses, Day 3 Nightlord.

## Core Principles

### I. Server-authoritative gameplay
All damage, loot rolls, level-ups, tide state, and boss logic live on the server.
Clients send *intent* (remotes via blink), never outcomes.

### II. Strict Luau everywhere
`--!strict` on all new modules. `luau-lsp analyze` must pass with zero errors before any
commit. No `any` leaks across module boundaries.

### III. Data-driven tuning
Every gameplay number (timings, DoT curves, rarity weights, boss stats) lives in shared
config modules, never inline. The day-length compressor is a config field, not a code change.

### IV. Filesystem-first
All code lives in `src/` synced via Rojo. The Studio-side place holds only what Rojo cannot
sync (terrain, meshes, plugins).

### V. Spec-driven slices
Each milestone is a spec-kit feature branch: spec → plan → tasks.md tracked in-repo.
tasks.md is updated as work completes, not reconstructed after.

### VI. Every system playable solo
If it needs 3 players to verify, it needs a solo-mode path (Nightreign parity: solo =
enemy HP/poise ÷3, +20% runes, 1 auto-revive per boss).

## Additional Constraints

- Audio policy (user decision): Roblox Creator Store audio + ElevenLabs SFX. **No Suno.**
- Art pipeline (user decision): Roblox-native AI tools for placeholders; Mixamo for
  combat animations; Meshy/Tripo only for hero assets later; Pixifield for key art.

## Development Workflow & Quality Gates

Per story, before commit:
- `luau-lsp analyze` — zero errors
- `selene src` — zero warnings
- `stylua --check src` — clean
- `rojo build` — succeeds
- Manual playtest via Studio MCP (play solo, exercise the story's acceptance scenario)

## Governance

Constitution supersedes other practices; amendments require a documented decision in the
spec directory. Complexity must be justified against the vertical slice.

**Version**: 1.0.0 | **Ratified**: 2026-10-15 | **Last Amended**: 2026-10-15
