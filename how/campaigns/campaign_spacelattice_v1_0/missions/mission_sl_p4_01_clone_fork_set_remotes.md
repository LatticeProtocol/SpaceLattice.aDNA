---
type: mission
mission_id: mission_sl_p4_01_clone_fork_set_remotes
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 1
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, fork_branding, clone, remotes]
blocked_by: [mission_sl_p3_08_languages_keys_perf]
---

# Mission — P4-01: Clone the LP fork + set remotes + workspace integration

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Local clone of `LatticeProtocol/spacelattice` to `~/lattice/spacelattice/`. Set up `upstream` remote pointing at `syl20bnr/spacemacs`. Create `lp-develop` branch tracking `upstream/develop`. Verify branch + remotes match the fork-strategy spec. Update workspace `~/lattice/CLAUDE.md` workspace table + tree to include the `spacelattice/` entry.

## Deliverables

- `git clone --depth 50 -b develop git@github.com:LatticeProtocol/spacelattice.git ~/lattice/spacelattice`
- `git remote add upstream https://github.com/syl20bnr/spacemacs.git` + `git fetch upstream`
- `git checkout -B lp-develop upstream/develop` + `git push -u origin lp-develop`
- `~/lattice/CLAUDE.md` workspace table + tree updated with `spacelattice/` row (sibling code repo for SpaceLattice.aDNA)
- Vault update: `what/standard/pins.md` records the fork's `lp-develop` HEAD SHA at clone time
- ADR: `adr_012_<slug>.md` ratifying the local clone topology + branch model

## Estimated effort

1 session.

## Dependencies

P3 closed.

## Reference

- `what/standard/fork-strategy.md` Stage 1
- `what/context/spacemacs/spacemacs_customization_reference.md` §4B.2 (git setup commands)
- ADR 005 (fork creation, 2026-05-05)
