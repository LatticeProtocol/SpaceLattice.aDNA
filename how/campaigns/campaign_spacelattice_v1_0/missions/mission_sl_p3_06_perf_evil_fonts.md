---
type: mission
mission_id: mission_sl_p3_06_perf_evil_fonts
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 6
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, customization, performance, evil, fonts, user_in_loop]
blocked_by: [mission_sl_p3_05_editing_completion_packages]
---

# Mission — P3-06: Performance + evil + fonts/icons

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Walk dimensions §2.5 (performance knobs: `dotspacemacs-gc-cons`, `dotspacemacs-read-process-output-max`, `dotspacemacs-enable-lazy-installation`, `dotspacemacs-enable-load-hints`, `dotspacemacs-enable-package-quickstart`, `dotspacemacs-byte-compile`, native-comp), §2.6 (evil & misc: `evil-escape-key-sequence`, `dotspacemacs-undo-system`, `dotspacemacs-folding-method`, `dotspacemacs-search-tools`), §2.7 (font + icon: `dotspacemacs-default-font` fallback chains, `dotspacemacs-default-icons-font` all-the-icons vs nerd-icons, frame parameters: transparency, decoration). Operator-in-the-loop: tune for actual workload (ML/agentic SE).

## Deliverables

- 7-step protocol
- Decisions recorded: gc-cons threshold, read-process-output-max (LSP throughput), lazy-installation policy, evil-escape sequence, undo-system, default-font, icon-font, transparency
- Layer changes: most lands in `dotfile.spacemacs.tmpl` defaults (operator-tuned baselines, ADR-gated) and/or `what/local/operator.private.el` (machine-specific overrides like font when operator has multiple hosts)
- AAR

## Estimated effort

1 session.

## Dependencies

P3-05 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §2.5, §2.6, §2.7
