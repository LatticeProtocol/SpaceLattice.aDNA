---
type: mission
mission_id: mission_sl_p3_01_dotfile_entry_lifecycle
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 1
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, customization, dotfile, lifecycle, user_in_loop]
blocked_by: [mission_sl_p2_04_telemetry_aggregate_skill_and_round_trip]
---

# Mission — P3-01: Dotfile entry-points + lifecycle ordering

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Walk the customization-reference dimensions covering dotfile entry-points and startup lifecycle: §1.1 (5 dotfile functions: `dotspacemacs/{layers,init,user-env,user-init,user-config}`), §1.2 (location resolution: `$SPACEMACSDIR/init.el` → `~/.spacemacs` → `~/.spacemacs.d/init.el`), §1.10 (consolidated startup lifecycle), §2.4 (precise lifecycle ordering table). Operator-in-the-loop: confirm where typical operator-class configurations should live across the 5 functions; record decisions in `who/operators/stanley.md`.

## Deliverables

- 7-step protocol completed per `how/standard/runbooks/customization_session_protocol.md`
- Decisions recorded in `who/operators/stanley.md` under `## Mission p3_01_dotfile_entry_lifecycle`
- Layer changes drafted per decision: typical landing zones are `what/local/operator.private.el` (operator overrides) and possibly `what/standard/dotfile.spacemacs.tmpl` defaults (ADR-gated)
- ADRs filed for any standard-layer changes (per Standing Order #8)
- Mission AAR with scorecard

## Estimated effort

1-2 sessions.

## Dependencies

P2 closed (phase gate).

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §1.1, §1.2, §1.10, §2.4
- `how/standard/runbooks/customization_session_protocol.md` (the 7-step protocol)
- `what/standard/dotfile.spacemacs.tmpl`
