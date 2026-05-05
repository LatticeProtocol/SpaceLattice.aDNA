---
type: mission
mission_id: mission_sl_p4_04_branding_strings
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 4
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, fork_branding, strings]
blocked_by: [mission_sl_p4_03_theme]
---

# Mission — P4-04: Branding strings (logo title, buffer name, version, repository constants)

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Patch fork core files to apply LP branding strings: `core/core-spacemacs-buffer.el` (logo-title + buffer-name + banner-image-path lookup), `core/core-versions.el` (add `latticeprotocol-version` defconst preserving `spacemacs-version`), `core/core-spacemacs.el` (repository constants for self-hosted update-check). Per customization reference §4B.3 diffs. Prefer additive changes via a `core/lp-branding.el` module per fork-strategy mitigation strategy (reduce rebase conflict surface).

## Deliverables

- `core/lp-branding.el` (new additive module) loaded via single-line patch upstream of relevant `core/core-*.el` files
- `latticeprotocol-version` defconst at "0.1.0" (or matching fork tag at this point)
- `spacemacs-buffer-logo-title` → `"[L A T T I C E   P R O T O C O L]"`
- `spacemacs-buffer-name` → `"*spacelattice*"` (matches repo name)
- Repository constants → `LatticeProtocol/spacelattice` + `lp-stable` branch
- Vault-side: `what/standard/spacelattice_branding_patch_spec.md` cataloguing all string locations + replacement values
- ADR: `adr_015_<slug>.md` ratifying the patch set + rebase mitigation strategy

## Estimated effort

1 session.

## Dependencies

P4-03 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §4A.5 + §4B.3 (branding strings + version-string changes)
- `what/standard/fork-strategy.md` § Mitigations (additive overrides)
