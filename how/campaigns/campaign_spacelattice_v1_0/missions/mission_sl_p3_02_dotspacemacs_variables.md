---
type: mission
mission_id: mission_sl_p3_02_dotspacemacs_variables
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 2
status: in_progress
mission_class: implementation
created: 2026-05-05
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, customization, dotspacemacs_variables, user_in_loop]
blocked_by: [mission_sl_p3_01_dotfile_entry_lifecycle]
---

# Mission — P3-02: dotspacemacs-* variables walk (~85 variables, 9 sub-groups)

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Walk dimension §1.3 of the customization reference: ~85 `dotspacemacs-*` variables across 9 sub-groups (1.3.1 layer/package mgmt, 1.3.2 ELPA/version/dump, 1.3.3 editing style + leaders, 1.3.4 startup buffer/banner/lists, 1.3.5 themes/modeline/fonts/cursor, 1.3.6 layouts/sessions, 1.3.7 files/autosave/rollback, 1.3.8 which-key/cycling/windowing, 1.3.9 frame appearance, 1.3.10 editing knobs). Operator-in-the-loop: decide non-default values per variable; record in profile; draft layer changes.

## Deliverables

- 7-step protocol applied per group (9 sub-passes; agent paces one group per round to manage cognitive load — protocol Step 5 of `customization_session_protocol.md` failure-mode handling)
- Decisions recorded in operator profile under per-group sub-headings
- Layer changes: most lands in `what/local/operator.private.el`; subset proposed for `what/standard/dotfile.spacemacs.tmpl` (ADR-gated standard change)
- Candidate promotions for `skill_layer_promote` (deferred to a separate promotion mission if a strong pattern emerges)
- AAR with full scorecard (one row per group)

## Estimated effort

2-3 sessions.

## Dependencies

P3-01 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §1.3 (all 10 sub-sections)
- `how/standard/runbooks/customization_session_protocol.md`

## Progress

- §1.3.1 Layer / package management — **CONFIRMED** (2026-05-07)
  - All variables confirmed at template defaults. No changes.
  - `dotspacemacs-distribution` → `'spacemacs` (Home buffer + adna namespace worth the cost)
  - `dotspacemacs-excluded-packages` / `dotspacemacs-frozen-packages` → `'()` (reactive, not pre-emptive)

- §1.3.2 ELPA / version / dump — **CONFIRMED + 2 changes** (2026-05-07)
  - 6 variables confirmed at template defaults
  - `dotspacemacs-gc-cons` → `'(200000000 0.1)` — ADR-016
  - `dotspacemacs-read-process-output-max` → `(* 4 1024 1024)` — ADR-016
  - Both landed in `what/standard/dotfile.spacemacs.tmpl`

- **Next**: §1.3.3 editing style + leader keys
