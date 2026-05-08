---
type: decision
adr_id: ADR-018
title: "Performance and editing config hardening batch"
status: accepted
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
supersedes: []
superseded_by: []
tags: [adr, performance, config, dotfile, bidi, kill-ring, window, editing]
---

# ADR-018 — Performance and editing config hardening batch

## Context

Mission `p3_13_dotfile_perf_hardening` identified a batch of well-established Emacs
configuration improvements (sourced from emacsredux.com, 2026-04-07) not yet present
in `dotfile.spacemacs.tmpl`. Several are high-impact performance settings; others
improve editing ergonomics. ADR-016 already handled LSP buffer size and GC threshold
(skip those). This ADR covers the remaining batch.

## Decision

Add the following settings to `dotspacemacs/user-config` in `dotfile.spacemacs.tmpl`,
organized under a new `§P3-13 Performance hardening` section comment:

### Performance — high priority

**Bidi display suppression** (large file speedup — multi-thousand-line JSON/logs):
```elisp
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
```

**Skip fontification during input** (eliminates micro-stutter in large buffers + tree-sitter):
```elisp
(setq redisplay-skip-fontification-on-input t)
```

**ffap hostname ping rejection** (prevents multi-second freezes when cursor is on a hostname):
```elisp
(setq ffap-machine-p-known 'reject)
```

### Performance — medium priority

**Cursor in non-selected windows** (reduces rendering work):
```elisp
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)
```

### Editing ergonomics

**Clipboard preservation before kill** (prevents losing external clipboard content):
```elisp
(setq save-interprogram-paste-before-kill t)
```

**Kill ring deduplication**:
```elisp
(setq kill-do-not-save-duplicates t)
```

**Auto-chmod on save** (makes script files with shebangs executable automatically):
```elisp
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)
```

### Window management

**Proportional window resizing** (all windows resize proportionally when splitting):
```elisp
(setq window-combination-resize t)
```

**winner-mode** (reversible `C-x 1` — toggle single-window focus on/off):
```elisp
(winner-mode +1)
```

**Mark ring navigation** (after first `C-u C-SPC`, continue with just `C-SPC`):
```elisp
(setq set-mark-command-repeat-pop t)
```

### UX conveniences

**Auto-focus help windows**:
```elisp
(setq help-window-select t)
```

**Sane re-builder syntax** (no double-escaping in interactive regex development):
```elisp
(setq reb-re-syntax 'string)
```

## Implementation

All settings land in `dotspacemacs/user-config` under `§P3-13 Performance hardening`.
Settings without side effects (bidi, ffap, kill-ring, help) are unconditional.
`winner-mode` is already available in Spacemacs baseline — no extra package needed.

## Health check

Run `skill_health_check` after dotfile update. No new package dependencies —
all settings use built-in Emacs variables and minor modes.

## Rationale

These are community-validated, low-risk improvements from Bozhidar Batsov's
"Stealing from the Best Emacs Configs" post. Each setting addresses a specific known
friction point. Batching them into one ADR avoids ADR sprawl for low-risk config tuning.

## References

- Source: https://emacsredux.com/blog/2026/04/07/stealing-from-the-best-emacs-configs/
- ADR-016: GC + LSP buffer (already applied — not duplicated here)
- Mission: `mission_sl_p3_13_dotfile_perf_hardening`
