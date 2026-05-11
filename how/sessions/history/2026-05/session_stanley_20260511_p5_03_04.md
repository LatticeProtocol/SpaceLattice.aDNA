---
type: session
tier: 2
status: completed
session_id: session_stanley_20260511_p5_03_04
intent: "P5-03 automated validation infrastructure + P5-04 shared human-agent command tree"
operator: stanley
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
missions_in_scope:
  - mission_sl_p5_03_automated_validation
  - mission_sl_p5_04_shared_command_tree
tags: [session, active, p5, validation, command_tree, scripts, adr_037, adr_038]
---

# Session — P5-03 + P5-04

Two missions in one session. Both are unblocked, ~1-session scope each.

## Scope declaration

- P5-03: `validate_layers.py` + health-check G/H + CI validate job + operator acceptance runbook + ADR-037
- P5-04: `scripts/` directory + 3 seed scripts + `adna/load-scripts` auto-discovery + context docs + ADR-038

## Conflict scan

Last committed session: `session_stanley_20260511_p5_02` (archived). No active sessions in conflict.

## Progress

### P5-03

- [x] Session file opened
- [x] ADR-037 authored
- [x] `validate_layers.py` created (7 checks, 7/7 pass)
- [x] `skill_health_check.md` Checks G + H added
- [x] `ci.yml` validate job added
- [x] `operator_acceptance_test.md` created
- [x] Mission file marked completed + AAR

### P5-04

- [x] ADR-038 authored
- [x] `scripts/` directory + README.md
- [x] `adna-show-sitrep.el` seed script (SPC a x s)
- [x] `adna-run-health-check.el` seed script (SPC a x h)
- [x] `adna-open-claude-with-layout.el` seed script (SPC a x o)
- [x] `adna--layer-dir` defvar in `config.el`
- [x] `adna/load-scripts` in `funcs.el`
- [x] load-scripts hook wired in `config.el`
- [x] `shared_command_space.md` context doc
- [x] `agent_command_tree.md` scripts section
- [x] `LAYER_CONTRACT.md` scripts/ clause (Clause 8)
- [x] Mission file marked completed + AAR

## Files touched

**Created:**
- `what/decisions/adr/adr_037_automated_validation_expansion.md`
- `what/decisions/adr/adr_038_shared_command_space.md`
- `what/standard/index/validate_layers.py`
- `how/standard/runbooks/operator_acceptance_test.md`
- `what/standard/layers/adna/scripts/README.md`
- `what/standard/layers/adna/scripts/adna-show-sitrep.el`
- `what/standard/layers/adna/scripts/adna-run-health-check.el`
- `what/standard/layers/adna/scripts/adna-open-claude-with-layout.el`
- `what/context/spacemacs/shared_command_space.md`

**Modified:**
- `how/standard/skills/skill_health_check.md` (Checks G + H; exit codes 85/86)
- `.github/workflows/ci.yml` (validate job)
- `what/standard/layers/adna/config.el` (adna--layer-dir defvar + hook)
- `what/standard/layers/adna/funcs.el` (adna/load-scripts + health-check update)
- `what/context/agent_command_tree.md` (seed table + discovery protocol)
- `what/standard/LAYER_CONTRACT.md` (Clause 8)
- `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_p5_03_automated_validation.md`
- `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_p5_04_shared_command_tree.md`
- `STATE.md`

## Next session prompt

P5-03 and P5-04 are complete. Next mission is **P5-05 doc pass** — v1.0 README/MANIFEST/CLAUDE.md refresh + GAP-05/06/07/08 cleanup (stale comments, LAYER_CONTRACT min-files clause, visual inspection runbook). All 4 must-fix P5 gates are now closed (GAP-01 through GAP-04). After P5-05: P5-06 second-machine install, then P5-07 v1.0 tag + campaign AAR.

Boot validation deferred: run `SPC a x` in Spacemacs to verify seed commands (s/h/o) appear via which-key. Also verify `validate_layers.py` passes CI on next push.
