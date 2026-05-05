---
type: mission
mission_id: mission_sl_p4_07_ci_workflows
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 7
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, fork_branding, ci, github_actions, upstream_sync]
blocked_by: [mission_sl_p4_06_news_welcome_dotfile]
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
- `what/standard/fork-strategy.md` § Rebase cadence
- `how/standard/runbooks/update_spacemacs.md` (post-P2-01 expansion — CI integration design)
