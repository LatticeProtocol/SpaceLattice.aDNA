---
type: mission
mission_id: mission_sl_p3_06_perf_evil_fonts
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 6
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [mission, completed, spacelattice, v1_0, p3, customization, performance, evil, fonts, user_in_loop]
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

## Decisions recorded (2026-05-08)

| Dimension | Knob | Decision | Delta |
|-----------|------|----------|-------|
| §2.5 | `dotspacemacs-gc-cons` | 200 MB | locked ADR-016 |
| §2.5 | `dotspacemacs-read-process-output-max` | 4 MB | locked ADR-016 |
| §2.5 | `dotspacemacs-enable-lazy-installation` | `'unused` | default |
| §2.5 | `dotspacemacs-enable-load-hints` | `nil` | default (macOS skip) |
| §2.5 | `dotspacemacs-enable-package-quickstart` | `nil` | default |
| §2.5 | `dotspacemacs-byte-compile` | `nil` | already in template |
| §2.6 | `evil-escape-key-sequence` | `fd` | default |
| §2.6 | `dotspacemacs-undo-system` | `undo-fu` | default |
| §2.6 | `dotspacemacs-folding-method` | `'evil` | already in template |
| §2.6 | `dotspacemacs-search-tools` | `'("rg" "ag" "grep")` | already in template |
| §2.7 | `dotspacemacs-default-font` | SpaceMono Nerd Font 13.0 | **changed** ADR-023 |
| §2.7 | `dotspacemacs-default-icons-font` | `nerd-icons` | **added** ADR-023 |
| §2.7 | `dotspacemacs-maximized-at-startup` | `t` | already in template |
| §2.7 | `dotspacemacs-fullscreen-at-startup` | `nil` | default |
| §2.7 | `dotspacemacs-undecorated-at-startup` | `nil` | default |

**Pre-requisites for font/icons**: `brew install --cask font-space-mono-nerd-font` + `M-x nerd-icons-install-fonts` after first deploy.

## AAR

- **Worked**: Full §2.5/§2.6/§2.7 walk completed in one session; all 15 knobs confirmed; operator-in-the-loop Q&A efficient (pre-session format validated again). ADR-023 filed; dotfile updated; health-check green.
- **Didn't**: `dotspacemacs-default-icons-font` was not present in the template — had to add it (wasn't missing, just unset; Spacemacs defaults to `all-the-icons` if absent). Expected it to be there.
- **Finding**: `dotspacemacs-maximized-at-startup` was already `t` in the template — no delta needed. The template baseline is better than expected; P3-06 produced only 2 real changes out of 15 knobs (13 were already correct defaults).
- **Change**: Font baseline moved to unified Nerd Fonts stack (SpaceMono Nerd Font + nerd-icons). ADR-023 gates both changes. Future installs must run the brew cask before deploying.
- **Follow-up**: Operator must install Space Mono Nerd Font and run `nerd-icons-install-fonts` before first deploy. Tracked as a pre-requisite note in ADR-023 and the P3-06 decision block in `who/operators/stanley.md`.
