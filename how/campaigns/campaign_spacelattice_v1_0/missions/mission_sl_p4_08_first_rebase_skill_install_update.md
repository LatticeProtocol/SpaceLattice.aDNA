---
type: mission
mission_id: mission_sl_p4_08_first_rebase_skill_install_update
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 8
status: planned
mission_class: verification
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, fork_branding, rebase, skill_install, phase_gate]
blocked_by: [mission_sl_p4_07_ci_workflows]
---

# Mission — P4-08: First rebase + skill_install update (P4 phase-gate)

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: verification.

## Objective

Execute the first weekly rebase against `upstream/develop` — validates the rebase strategy + conflict-resolution heuristics from P2-01. Document conflicts encountered and resolutions applied. Update vault `skill_install.md` to clone `LatticeProtocol/spacelattice` instead of `syl20bnr/spacemacs`. **P4 phase-gate evidence**: operator can clone fork + run `skill_install` + see Spacemacs branding (banner, modeline, frame title, distribution name).

## Deliverables

- First rebase artifact: `~/lattice/spacelattice/UPSTREAM_REV` bumped + commit log + conflict-resolution notes
- Vault-side rebase receipt: `how/standard/runbooks/rebase_log_<utc>.md` documenting outcome + insights
- `how/standard/skills/skill_install.md` updated: clone target → `LatticeProtocol/spacelattice`; `what/standard/pins.md` updated to fork's `lp-develop` SHA
- ADR: `adr_019_<slug>.md` ratifying the install-source switch
- **P4 phase-gate validation**: clean install on host shows Spacemacs branding + first rebase succeeds with documented conflict resolutions
- AAR (mission close + P4 phase close coverage)

## Estimated effort

1-2 sessions.

## Dependencies

P4-07 closed (CI workflows in place to gate the rebase).

## Reference

- `how/standard/runbooks/update_spacemacs.md` (post-P2-01 expansion)
- `how/standard/skills/skill_install.md` (current — pre-update)
- `what/context/spacemacs/spacemacs_customization_reference.md` §4B.5 (rebase strategy)
