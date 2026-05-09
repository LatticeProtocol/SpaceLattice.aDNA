---
type: mission
mission_id: mission_sl_p4_01_clone_fork_set_remotes
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 1
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [mission, completed, spacelattice, v1_0, p4, vault_only, layer_scaffold, skill_install]
blocked_by: [mission_sl_p3_08_languages_keys_perf]
rescoped_by: adr_024_vault_only_layer_model
---

# Mission — P4-01: LP layer scaffold + skill_install extension (vault-only model)

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

> **Rescoped by ADR-024 (2026-05-08).** Original scope was "clone fork + set remotes." Replaced by vault-only layer model: all LP code lives in `what/standard/layers/`. No fork clone or git remotes work.

## Objective

Scaffold the LP distribution layer and theme directories inside the vault. Extend `skill_install` Step 5 to symlink all LP layers (not just `adna`) into `~/.emacs.d/private/layers/`. This prepares the deployment infrastructure that P4-02 (distribution layer content) and P4-03 (theme content) will populate.

## Deliverables

- Create `what/standard/layers/spacemacs-latticeprotocol/` with skeleton files:
  - `layers.el` — `(configuration-layer/declare-layer-dependencies '(spacemacs))`
  - `packages.el` — `(defconst spacemacs-latticeprotocol-packages '(latticeprotocol-theme))` with `:location local`
  - `config.el` — stub with branding override stubs
  - `keybindings.el` — stub for `SPC o l` LP prefix (populated P4-02 from P3-08 binding table)
  - `README.org` — distribution layer documentation stub
- Create `what/standard/layers/+themes/latticeprotocol-theme/` with skeleton:
  - `packages.el` — `(defconst latticeprotocol-theme-packages '((latticeprotocol-theme :location local)))`
  - `local/latticeprotocol-theme/` directory (theme files added P4-03)
- Extend `skill_install` Step 5 to symlink all LP layers
- `skill_health_check` confirms no new load errors from skeleton files
- Operator: archive `LatticeProtocol/spacelattice` on GitHub (no LP commits, reversible)

## Estimated effort

1 session.

## Dependencies

P3-08 closed ✅. ADR-024 accepted ✅ (2026-05-08).

## Reference

- `what/decisions/adr/adr_024_vault_only_layer_model.md` — architectural rationale
- `how/standard/skills/skill_install.md` Step 5 — current symlink pattern to extend
- `what/standard/layers/adna/` — canonical vault-resident Spacemacs layer example
