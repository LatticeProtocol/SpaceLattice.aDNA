---
type: mission
mission_id: mission_sl_p5_05_doc_pass
campaign: campaign_spacelattice_v1_0
campaign_phase: 5
campaign_mission_number: 5
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p5, polish, doc_pass, release_prep]
blocked_by: [mission_sl_p5_04_shared_command_tree]
---

# Mission — P5-05: v1.0 documentation pass

**Phase**: P5 — Polish + v1.0 release.
**Class**: implementation.

## Objective

Final v1.0 documentation pass: review README, MANIFEST, CLAUDE.md, all `how/standard/skills/*.md` skill READMEs for v1.0 readiness. Update `~/lattice/CLAUDE.md` workspace row to "Production v1.0". Prepare CHANGELOG.md release entry (committed at P5-03). Note any remaining audit findings.

## Deliverables

- README.md updated for v1.0 (section ordering, links checked, install command points to LP fork via post-P4-08 `skill_install`)
- MANIFEST.md updated (`status: production`, version notes)
- CLAUDE.md (project-level) reviewed for outdated phase references; Spacemacs Standing Orders refresh if applicable
- All `how/standard/skills/*.md` READMEs reviewed for accuracy at v1.0
- `~/lattice/CLAUDE.md` workspace table row + tree entry updated to "Production v1.0"
- CHANGELOG.md staged release entry (commit body finalized at P5-03)
- Audit register cleared or moved to post-v1.0 backlog

## Gap Register Items (from P5-00)

Four nice-to-have gaps assigned to this mission by `p5_gap_register.md`:

**GAP-05** — `what/standard/layers/adna/funcs.el` section header + docstring (line ~308):
- Section comment: "Phase 2 stub — full jsonschema in Phase 4" → "Phase 2 stub — full jsonschema deferred post-v1.0"
- Function docstring for `adna/telemetry-validate`: update "deferred to Phase 4 layer hardening" → "deferred post-v1.0"

**GAP-06** — `what/standard/layers/adna/funcs.el` section header (line ~346):
- Remove stale label "LP command stubs (SPC o l / SPC a l — Phase 3 namespace reservation)" — functions are fully implemented; just label as "LP commands (SPC o l / SPC a l)"

**GAP-07** — `what/standard/LAYER_CONTRACT.md`:
- Add Clause N: minimum required files per standard layer (packages.el, config.el, keybindings.el, README.org, layers.el)
- No ADR required — clarification of existing convention, not a new decision
- Source: `how/backlog/idea_layer_contract_min_files.md`

**GAP-08** — `how/standard/runbooks/visual_inspection.md` (new):
- Screenshot-based UI validation checklist: banner, theme, modeline, `SPC a` transient, eww render, centaur-tabs, imenu-list
- Headless path: `emacs --screenshot` (Emacs 29+) or `screencapture` (macOS)
- Ties to `skill_health_check` as a manual companion check (pre-v1.0 release gate)
- Source: `how/backlog/idea_visual_inspection_protocol.md`

## Estimated effort

1 session.

## Dependencies

P5-01 through P5-04 closed (review their outputs for accuracy before finalizing docs).

## Reference

- README.md, MANIFEST.md, CLAUDE.md (project + workspace)
- `how/standard/skills/`
- `~/lattice/CLAUDE.md` (workspace router)
- `how/campaigns/campaign_spacelattice_v1_0/missions/artifacts/p5_gap_register.md` (GAP-05/06/07/08)
