---
type: mission
mission_id: mission_sl_p4_03_theme
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 3
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, fork_branding, theme]
blocked_by: [mission_sl_p4_02_distribution_layer]
---

# Mission — P4-03: LP theme (`latticeprotocol-theme` dark + light)

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Author the LP theme at `layers/+themes/latticeprotocol-theme/` in the fork: `packages.el` + `local/latticeprotocol-theme/{latticeprotocol-dark,latticeprotocol-light}-theme.el`. Wire dark + light variants. Wire into the LP distribution layer (P4-02) as default themes.

## Deliverables

- `~/lattice/spacelattice/layers/+themes/latticeprotocol-theme/packages.el` — `latticeprotocol-theme-packages` (`:location local`)
- `…/local/latticeprotocol-theme/latticeprotocol-dark-theme.el`
- `…/local/latticeprotocol-theme/latticeprotocol-light-theme.el`
- LP color palette decided + documented (operator-in-loop input from P3-04 theme preferences)
- Vault-side: `what/standard/spacelattice_theme_spec.md` documenting palette + face mappings
- ADR: `adr_014_<slug>.md` ratifying the theme

## Estimated effort

1-2 sessions.

## Dependencies

P4-02 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §4A.4 + §4B.3 (theme integration)
- P3-04 operator profile (theme preferences)
