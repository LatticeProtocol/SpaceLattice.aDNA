---
type: mission
mission_id: mission_sl_p4_08_first_rebase_skill_install_update
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 8
status: completed
mission_class: verification
created: 2026-05-05
updated: 2026-05-10
last_edited_by: agent_stanley
tags: [mission, completed, spacelattice, v1_0, p4, fork_branding, pin_bump, skill_update_pin, install_source, phase_gate]
blocked_by: []
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
- `how/standard/skills/skill_install.md` (updated — clone target → LP fork)
- `what/standard/pins.md` (bumped to `37e2a32b`, 2026-05-10, ADR-032)
- `how/standard/runbooks/rebase_log_2026_05_10T000000Z.md` (first pin-bump receipt)
- `what/decisions/adr/adr_032_install_source_switch.md` (accepted)
- `how/standard/skills/skill_update_pin.md` (new — ADR-gated pin-bump procedure)

## AAR (lightweight)

- **Worked**: Pin bump + install-source switch delivered cleanly; ADR-024 rescope (vault-only = pin-only rebase) eliminated all conflict-resolution complexity.
- **Didn't**: `~/lattice/spacelattice/` local fork clone was not present on current machine — fork-side `UPSTREAM_REV` artifact deferred; vault-side receipt covers the audit requirement.
- **Finding**: "First rebase" language in original mission spec is misleading post-ADR-024; renamed to "first pin bump" in `skill_update_pin.md` and ADR-032 for future clarity.
- **Change**: `skill_update_pin.md` introduced as the canonical ADR-gated pin-bump procedure; links wired from `pins.md` update protocol + `skill_install.md` reproducibility pact.
- **Follow-up**: P4-09 (claude-code-ide layer completion) is next; no blockers.

Full AAR: `missions/artifacts/aar_sl_p4_08.md`
