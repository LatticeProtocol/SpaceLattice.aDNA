---
type: mission
mission_id: mission_sl_p4_07_ci_workflows
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 7
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [mission, completed, spacelattice, v1_0, p4, fork_branding, ci, github_actions, upstream_monitor]
blocked_by: []
---

# Mission — P4-07: CI + upstream-sync GitHub Actions workflows

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Author 2 GitHub Actions workflows in the fork: `.github/workflows/ci.yml` (matrix Emacs 28.2 / 29.x / 30-snapshot; layer tests; lint via `package-lint` + `byte-compile-file`; headless smoke `--batch -l init.el`) and `.github/workflows/upstream-sync.yml` (weekly cron rebase against `upstream/develop` + open PR with conflict report). Consumes the CI integration design from P2-01.

## Deliverables

- `.github/workflows/ci.yml` — matrix CI per fork-strategy outline (Emacs 28.2 / 29.x / 30-snapshot)
- `.github/workflows/upstream-sync.yml` — weekly cron rebase + conflict-report PR template (P2-01 design)
- First green CI run after the workflows merge (evidence: badge or run-URL captured in mission AAR)
- Vault-side: `what/standard/spacelattice_ci_spec.md` documenting CI design
- ADR: `adr_018_<slug>.md` ratifying CI + upstream-sync workflow

## Estimated effort

1-2 sessions.

## Dependencies

P4-06 closed; P2-01 sustainability runbook teeth (CI integration design) referenced.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §4B.4 (build/test/release)
- `what/standard/fork-strategy.md` § Rebase cadence (superseded by ADR-024; preserved for audit)
- `how/standard/runbooks/update_spacemacs.md` (post-P2-01 expansion — CI integration design)

---

## Completion (2026-05-08)

**ADR-024 adaptation**: The original objective assumed a `LatticeProtocol/spacelattice` fork. ADR-024 abolished that fork (vault-only model). Deliverables adapted accordingly:

- `.github/workflows/ci.yml` — byte-compile matrix (Emacs 28.2 / 29.4 / snapshot) on `what/standard/layers/**/*.el` ✅
- `.github/workflows/upstream-sync.yml` — weekly upstream-monitor (opens GitHub issue on SHA drift vs. `update_spacemacs.md` runbook) ✅
- `what/standard/spacelattice_ci_spec.md` — CI design doc ✅
- `what/decisions/adr/adr_031_ci_upstream_monitor.md` — accepted ✅

`package-lint` replaced by byte-compile (LP layers are private layers, not MELPA packages). Fork rebase automation replaced by issue-based drift notification (operator-gated pin bumps per ADR-024). ADR number changed to 031 (031 is next available; original spec said 018 which was already used).

First green CI run: deferred — workflows will run on next push that touches `what/standard/layers/**/*.el` or on next Monday. Badge available after first run.

## AAR

**Worked**: Vault-only model adaptation was clean. SHA parse (`grep 'Pinned SHA' pins.md | grep -oE '[0-9a-f]{40}'`) confirmed against live file. Two-workflow split (compile CI vs. upstream-monitor) matches the vault-only governance philosophy: CI gates quality, monitor surfaces drift, humans decide.

**Didn't**: `package-lint` was in the original spec but is wrong for private layers. Caught in planning — no rework needed.

**Finding**: The `upstream-sync` GitHub label must be created manually on the repo before the first Monday cron fires. Noted in `spacelattice_ci_spec.md` § Required repository setup.

**Change**: Future CI specs should lead with "private layer or MELPA package?" to select the right lint approach immediately.

**Follow-up**: (1) Create `upstream-sync` label on `LatticeProtocol/Spacemacs.aDNA`. (2) Add CI badge to `README.md` after first green run (P5-01 doc pass). (3) P4-08 (`skill_update_pin`) documents the ADR-gated workflow this monitor triggers.

Full AAR artifact: `how/campaigns/campaign_spacelattice_v1_0/missions/artifacts/aar_mission_sl_p4_07.md`
