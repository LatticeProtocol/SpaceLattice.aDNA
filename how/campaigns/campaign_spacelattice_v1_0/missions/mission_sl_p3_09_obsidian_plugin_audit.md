---
type: mission
mission_id: mission_sl_p3_09_obsidian_plugin_audit
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 9
status: planned
mission_class: implementation
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, obsidian, plugin_audit, disk_size]
blocked_by: [mission_sl_p3_08_languages_keys_perf]
---

# Mission — P3-09: Obsidian plugin audit + trim

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Spacemacs.aDNA ships an `.obsidian/` config with 15 plugins (~13MB, ~87% of `.obsidian/`). Most plugins are cosmetic and not required for aDNA wikilink navigation or context-graph operation. Trim the shipped set to essentials, document optionals, and verify Obsidian UX is intact post-trim.

## Deliverables

- Audit table: 15 plugins → keep / optional / remove-from-tracked-config
- **Essential set shipped** (tracked in git):
  - `obsidian-advanced-canvas` (canvas round-trip, required for CanvasForge consumer federation)
  - `templater-obsidian` (template system for mission/session/context files)
  - `obsidian-tasks-plugin` (optional but commonly useful; include or document as optional)
- **Optional plugin docs**: new file `what/local/obsidian_optional_plugins.md` listing the remaining plugins with one-line install instructions for each
- **UX validation**: operator opens Obsidian against the vault post-trim, confirms wikilink resolution and canvas round-trip work
- **Size before/after** in mission AAR (expected: ~13MB → ~1.5MB tracked)
- STATE.md note if plugin trim affects graph.json node count (unlikely)
- AAR at `how/missions/artifacts/aar_p3_09_obsidian_plugin_audit_<date>.md`

## Estimated effort

1 session.

## Dependencies

P3-08 closed (completes all 22 customization dimensions). P3-09 runs as the final P3 clean-up mission before the P3 phase-gate evidence check.

## Reference

- `how/backlog/idea_plugin_trimming.md` (source idea, kept-adapted at P1-01)
- `.obsidian/plugins/` (current 15-plugin set)
- `what/context/spacemacs/` — Obsidian-Spacemacs coupling context
- `what/standard/obsidian-coupling.md` (stub — may be expanded as part of this mission)
