---
type: mission
mission_id: mission_sl_p3_13_dotfile_perf_hardening
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 13
status: planned
mission_class: implementation
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [mission, planned, spacemacs, v1_0, p3, performance, config, dotfile, adr_018]
blocked_by: [mission_sl_p3_12_platform_context_macos]
---

# Mission — P3-13: Dotfile Performance Hardening

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Operator-gate and validate the performance + editing config batch from ADR-018. The settings were applied to `dotfile.spacemacs.tmpl` in the §P3-13 section during the 2026-05-07 research integration session (sourced from emacsredux.com). This mission walks the operator through each setting, confirms or adjusts choices, deploys, and validates.

ADR-016 (already accepted) covers GC threshold + LSP buffer — do not re-litigate those.

## Deliverables

- Operator walk-through of each ADR-018 setting (12 total):
  - **High priority**: bidi suppression, fontification skip, ffap reject
  - **Medium priority**: cursor in non-selected windows, save-interprogram-paste, window-combination-resize, set-mark-command-repeat-pop, winner-mode
  - **Low priority**: kill-do-not-save-duplicates, help-window-select, reb-re-syntax, executable-make-buffer-file-executable
- Any operator adjustments recorded in amendment to ADR-018 or a new ADR
- `skill_deploy` run to update `init.el`
- `skill_inspect_live` to confirm no visual regressions
- `skill_health_check` — batch load validation
- `who/operators/stanley.md` updated with any per-setting decisions
- AAR

## Estimated effort

1 session.

## Dependencies

P3-12 closed (darwin block health-checked; known-good baseline before adding perf batch).

## Reference

- ADR-018: `what/decisions/adr/adr_018_perf_config_hardening.md`
- `what/standard/dotfile.spacemacs.tmpl` §P3-13 Performance hardening
- Source: https://emacsredux.com/blog/2026/04/07/stealing-from-the-best-emacs-configs/
