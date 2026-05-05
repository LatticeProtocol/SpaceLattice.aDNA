---
type: mission
mission_id: mission_sl_p4_02_distribution_layer
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 2
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, fork_branding, distribution_layer]
blocked_by: [mission_sl_p4_01_clone_fork_set_remotes]
---

# Mission — P4-02: LP distribution layer (`+distributions/spacelattice/`)

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Author the LP distribution layer at `layers/+distributions/spacelattice/` in the fork: `layers.el`, `packages.el`, `config.el`, `keybindings.el`, `README.org`. Inherits `spacemacs` distribution via `(configuration-layer/declare-layer-dependencies '(spacemacs))`. `keybindings.el` wires the `SPC o l` LP prefix decided in P3-08.

## Deliverables

- `~/lattice/spacelattice/layers/+distributions/spacelattice/layers.el` — declare-layer-dependencies '(spacemacs)
- `…/packages.el` — `spacelattice-packages` lists `latticeprotocol-theme`, `lp-welcome` local package (welcome widget lands at P4-06)
- `…/config.el` — setq-default for `dotspacemacs-themes`, `dotspacemacs-frame-title-format`, `dotspacemacs-mode-line-theme`
- `…/keybindings.el` — `(spacemacs/declare-prefix "ol" "lattice-protocol")` + LP commands (`olh` / `olu` etc.)
- `…/README.org` — distribution-layer documentation
- Vault-side: `what/standard/spacelattice_distribution_spec.md` documenting the layer
- ADR: `adr_013_<slug>.md` ratifying the distribution-layer scaffold

## Estimated effort

1-2 sessions.

## Dependencies

P4-01 closed.

## Reference

- `what/standard/fork-strategy.md` Stage 1 (distribution layer scaffolding)
- `what/context/spacemacs/spacemacs_customization_reference.md` §4A.3 + §4B.3 (distribution layer creation)
- P3-08 operator profile (SPC o l prefix decisions)
