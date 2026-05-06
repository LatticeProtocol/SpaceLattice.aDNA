---
type: mission
mission_id: mission_sl_p2_01_sustainability_runbook_teeth
campaign: campaign_spacelattice_v1_0
campaign_phase: 2
campaign_mission_number: 1
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p2, sustainability, runbook]
blocked_by: [mission_sl_p1_01_backlog_cleanup, mission_sl_p1_02_sanitization_warns_adr, mission_sl_p1_03_self_improve_schedule]
---

# Mission — P2-01: Sustainability runbook expansion (`update_spacemacs.md` teeth)

**Phase**: P2 — Sustainability + telemetry implementation.
**Class**: implementation.

## Objective

Convert `how/standard/runbooks/update_spacemacs.md` from outline to working teeth: concrete sed patterns for the top-5 conflict-prone files, file-disposition heuristics (rebase-on-ours / -theirs / manual), and CI integration design for the upstream-sync workflow. Closes the sustainability framework's first deliverable from `what/standard/sustainability.md`.

## Deliverables

- 5 sed patterns — one per conflict-prone file (`core/templates/dotspacemacs-template.el`, `core/core-spacemacs-buffer.el`, `core/core-spacemacs.el`, `core/core-versions.el`, `layers/+distributions/spacemacs/packages.el`)
- Heuristics table: per-file disposition rule (e.g., `core-versions.el` → rebase-on-ours for `latticeprotocol-version` defconst; `dotspacemacs-template.el` → manual review)
- CI integration design: GitHub Action workflow sketch + conflict-report PR template (used by P4-07 to author the actual workflow file)
- `update_spacemacs.md` rewritten with the above (status: outline → active)
- ADR: `adr_008_<slug>.md` ratifying the runbook expansion
- Dry-run validation: simulated rebase against a fabricated upstream commit produces sensible output

## Estimated effort

2 sessions.

## Dependencies

P1 closed (audit findings cleared, STATE.md "Active Blockers" empty).

## Reference

- `what/standard/sustainability.md` (framework outline)
- `what/context/spacemacs/spacemacs_customization_reference.md` § 4B.5 (rebase strategy + conflict-prone files)
- `what/standard/fork-strategy.md` (rebase cadence)
- `how/standard/runbooks/update_spacemacs.md` (current outline)
