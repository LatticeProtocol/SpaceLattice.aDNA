---
type: governance
subtype: campaign_claude
campaign_id: campaign_spacelattice_v1_0
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
tags: [governance, campaign, spacelattice, v1_0]
---

# Campaign CLAUDE.md — Spacemacs v1.0

This file is the agent's governance overlay scoped to `campaign_spacelattice_v1_0`. The vault's project-level CLAUDE.md (`/Users/stanley/lattice/Spacemacs.aDNA/CLAUDE.md`) is canonical; this file adds campaign-specific direction.

## Campaign master

- **Master file**: `campaign_spacelattice_v1_0.md` (this directory)
- **Status**: planning (will move to `execution` when M-Planning-01 closes)
- **Phases**: 6 (P0 planning → P5 v1.0 release)
- **Predecessor**: spacemacs.aDNA genesis (plan-driven, AAR ratified)

## Operating direction (campaign-specific)

### Persona

Daedalus retained per ADR 005. Labyrinth metaphor scales to the lattice + LP-stack positioning.

### Phase gates

Standing Order #1 applies: between each phase, operator confirms before the next phase opens. Don't auto-advance.

### User-in-the-loop emphasis

This campaign is heavier on operator interaction than genesis was. Phase 3 (customization walk-through) explicitly walks each dimension with operator-in-the-loop at each step. Default posture for this campaign:

- Each mission opens with a brief operator-direction prompt
- Each substantive change is operator-gated (per existing skill_layer_add / skill_layer_promote / skill_self_improve patterns)
- Mission AARs capture operator decisions, not just agent activity

### Cross-vault context

This campaign references but does not modify:

- `~/lattice/lattice-protocol/` (private; the LP runtime; we integrate with it but don't develop it)
- `~/lattice/adna/` (the public aDNA template; do not modify per workspace rules)
- `~/lattice/spacelattice/` (planned local clone of the fork; created in Phase 4 by M-Planning-01's first execution)

### Telemetry

Operator-gated. Per-submission consent. Default opt-out. Sanitization mandatory. Schema designed in P2; first round-trip in P2.

## Mission tracking

Missions live at `missions/mission_sl_<phase>_<num>_<slug>.md`. Naming convention:

| Prefix | Phase | Examples |
|--------|-------|----------|
| `mission_sl_planning_<N>` | P0 (planning) | mission_sl_planning_01 |
| `mission_sl_p1_<N>_<slug>` | P1 (audit closure) | mission_sl_p1_01_backlog_cleanup |
| `mission_sl_p2_<N>_<slug>` | P2 (sustainability + telemetry) | mission_sl_p2_03_telemetry_submit_skill |
| `mission_sl_p3_<N>_<slug>` | P3 (customization walk) | mission_sl_p3_07_org_mode_power_user |
| `mission_sl_p4_<N>_<slug>` | P4 (fork branding) | mission_sl_p4_02_distribution_layer |
| `mission_sl_p5_<N>_<slug>` | P5 (polish + release) | mission_sl_p5_01_doc_pass |

The mission tree is filled in by M-Planning-01.

## AAR discipline

Every mission ends with an AAR per Standing Order #5. Use `template_aar.md` for substantive missions; `template_aar_lightweight.md` for trivial closeouts. AARs land at `missions/artifacts/aar_<mission_id>.md`.

## Reference

- Master: `campaign_spacelattice_v1_0.md` (in this dir)
- Project CLAUDE.md: `/Users/stanley/lattice/Spacemacs.aDNA/CLAUDE.md`
- Plan: `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan B
