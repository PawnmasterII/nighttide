# NightTide Art Pipeline

Decision log + workflow for AI-assisted asset creation (agreed 2026-10-15).

## Policy
1. **Native Roblox AI first** (free): Assistant mesh gen, Material Generator, Texture
   Generator, Procedural Models — all placeholders.
2. **Mixamo** (free) for combat/locomotion animation on R15 rigs.
3. **Meshy / Tripo** (paid, later) for hero meshes: Nightlord, bosses, class weapons.
   - Roblox needs: FBX/OBJ import via Studio 3D Importer; watch tri budgets
     (field props ≤ ~4k tris, bosses ≤ ~15k).
4. **Pixifield** — key art, class concept sheets, trailer material. Not a Roblox plugin;
   exports flow manually (image → reference for mesh gen, or marketing assets).
5. **Audio:** Roblox Creator Store audio + ElevenLabs SFX (paid tier for commercial
   license). **No Suno** (user decision).

## Flows
- Placeholder prop: MCP `generate_mesh "weathered stone well"` → box-select bounding part
  first for sizing → save to `assets/models/` as .rbxm for Rojo sync.
- Tiling material: Material Generator → save variant → apply to terrain/parts.
- Custom class character: model mesh → **Avatar Auto-Setup** (Studio, Avatar Setup tab)
  → R15 rig + cages automatic → animate via Mixamo-retargeted clips or Animation Editor.
- Mixamo animation: export R15 rig from Studio (Den_S Blender rig exporter) → Blender →
  Mixamo → FBX back → Studio import. FBX animation import is known-flaky; if it fails,
  use the Blender plugin rebuild path (see devforum thread 2962873) or Cascadeur's
  Roblox R15 pipeline.

## Asset inventory targets (M1)
- [ ] Island template terrain (Studio tools, manual — Rojo can't sync terrain)
- [ ] 6–10 POI placeholder structures (Assistant mesh gen / procedural models)
- [ ] 3 enemy placeholder rigs (blocky R15 + Mixamo clips: idle/chase/attack/death)
- [ ] Night boss placeholder (scaled R15 + simple kit)
- [ ] UI frames: HP/flask/rune counters (Creator Store or generated)
- [ ] Night's Tide wall (beams + particles, scripted — no asset needed)
