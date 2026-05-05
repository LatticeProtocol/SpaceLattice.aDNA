---
type: mission
mission_id: mission_sl_p3_05_editing_completion_packages
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 5
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, customization, editing, completion, packages, user_in_loop]
blocked_by: [mission_sl_p3_04_themes_modeline_banner_startup]
---

# Mission — P3-05: Editing styles + completion stack + package management

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Walk dimensions §2.1 (editing styles: vim / emacs / hybrid + tunable variants), §2.2 (completion stack: helm / ivy / compleseus + the "last layer wins" rule), §2.3 (package management knobs: `configuration-layer-elpa-archives`, `package-archive-priorities`, `dotspacemacs-frozen-packages`, `dotspacemacs-install-packages` policy, quelpa recipes, rollback). Operator-in-the-loop: lock down editing-style + completion-engine + package-policy decisions for the operator's primary stack.

## Deliverables

- 7-step protocol
- Decisions recorded in profile: editing_style, completion_engine, install_packages policy
- Layer changes: `dotspacemacs-editing-style`, `dotspacemacs-configuration-layers` (helm vs ivy vs compleseus), `dotspacemacs-install-packages`, `dotspacemacs-frozen-packages` — typically lands in `dotfile.spacemacs.tmpl` (ADR-gated standard change) or operator-private layer
- AAR

## Estimated effort

1-2 sessions.

## Dependencies

P3-04 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §2.1, §2.2, §2.3
