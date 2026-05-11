---
type: context
status: active
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [context, layout, agentic, treemacs, claude_code, window, spacemacs, adna, p5_01]
load_when: ["layout configuration", "window management", "SPC a l", "agentic layout", "treemacs setup", "claude code terminal layout", "multi-project session"]
---

# Agentic Layout Guide — Spacemacs.aDNA

## Purpose

Named window configurations that set up a battle-station for a specific working mode. Activated via `SPC a l` (`adna/layouts-menu` transient). Defined in `what/standard/layers/adna/layouts.el` (ADR-035).

---

## Layout Inventory

| Key | Layout | Keybinding | Primary Use |
|-----|--------|-----------|-------------|
| `a` | `adna/layout-agentic-default` | `SPC a l a` | Federated ML / agentic coding — daily driver |
| `v` | `adna/layout-vault-navigation` | `SPC a l v` | aDNA vault exploration, reading mission/context docs |
| `c` | `adna/layout-campaign-planning` | `SPC a l c` | Editing campaign docs, mission files, and STATE.md side-by-side |
| `r` | `adna/layout-code-review` | `SPC a l r` | Reviewing diffs, inspecting source, running shell commands |

All layouts call `delete-other-windows` first — they replace the current window configuration, not extend it. Each function is `interactive` and usable via `M-x`.

---

## Window Diagrams

### `adna/layout-agentic-default` — Daily Driver

```
┌──────────┬─────────────────────────────────────────────┐
│          │                                             │
│ treemacs │   file buffer (edit / review / run code)   │
│  (25 col)│                                             │
│          ├─────────────────────────────────────────────┤
│          │   claude-code terminal  (eat / vterm)       │
└──────────┴─────────────────────────────────────────────┘
```

- Treemacs opens as a **side window** on the far left (managed by its own window system, not affected by `delete-other-windows` on the main area).
- `split-window-below` splits the main area at 65% height — top for editing, bottom for Claude Code.
- `adna/spawn-claude-code` opens the terminal; focus returns to the edit area.
- `SPC c s` (claude-code-ide) toggles the terminal independently after layout activation.

### `adna/layout-vault-navigation` — Vault Explorer

```
┌──────────┬──────────────────────┬──────────────────┐
│          │                      │                  │
│ treemacs │   content buffer     │   imenu-list     │
│          │                      │  (symbol index)  │
└──────────┴──────────────────────┴──────────────────┘
```

- `imenu-list-smart-toggle` opens the symbol navigator on the right if `imenu-list` is available.
- Best for reading long context docs, ADRs, or operator profiles with deep heading structure.

### `adna/layout-campaign-planning` — Three-Column Planning

```
┌──────────────┬──────────────────┬──────────────────┐
│              │                  │                  │
│ campaign doc │   mission file   │   STATE.md       │
│  (left col)  │  (center, focus) │  (right col)     │
└──────────────┴──────────────────┴──────────────────┘
```

- STATE.md is opened automatically in the right column (via `adna/--find-state-md`).
- Focus lands in the center column — load your active mission file with `SPC f f`.
- Load a campaign doc in the left column with `C-x b` or `SPC f f`.

### `adna/layout-code-review` — Diff + Shell

```
┌──────────────────────┬──────────────────────────────┐
│                      │                              │
│   magit status/log   │   source file                │
│                      │                              │
├──────────────────────┴──────────────────────────────┤
│                                                     │
│   vterm (full-width terminal)                       │
└─────────────────────────────────────────────────────┘
```

- `magit-status` opens top-left; focus lands on the source file window (top-right).
- `vterm` spans the full bottom at 35% height for running tests and git commands.

---

## Coordination with `claude-code-ide` Layer

`claude-code-ide` is configured with `claude-code-ide-window-side 'right` (ADR-019). When treemacs is open in `agentic-default` or `vault-navigation`, the right side is already partially occupied.

**Recommended adjustment** when treemacs is active:

```elisp
;; In what/local/operator.private.el — reduce Claude Code panel from default 100
(setq claude-code-ide-window-width 80)
```

This prevents the Claude Code panel from crowding the edit area. The full-width default (100) is fine without treemacs.

**`vault-navigation` + Claude Code**: Not recommended to combine. The three-column layout (`treemacs` + content + `imenu-list`) leaves little horizontal space for a right-side panel. Use `agentic-default` if you need Claude Code alongside vault reading.

---

## Multi-Project Session Switching

When working across multiple aDNA vaults (e.g., `Spacemacs.aDNA` + `RareHarness.aDNA`):

1. Activate `agentic-default`: `SPC a l a`
2. List Claude Code sessions: `SPC c l` (claude-code-ide session list)
3. Select or create a session for the target vault
4. Switch projectile project: `SPC p p` — the edit area follows the new root

Each vault has its own Claude Code session. The layout persists across project switches.

---

## Composition Rules

**Do:**
- Activate a layout, then open specific files within it — layouts provide the frame, not the content.
- Use `winner-undo` (`C-c <left>`) to revert to a prior window configuration after a layout switch.
- Run `SPC a l a` at session start as the daily driver, then switch layouts for specific tasks.

**Avoid:**
- Combining `vault-navigation` and a Claude Code panel — three columns + a right-side panel is cramped below 1440px width.
- Calling `delete-other-windows` manually after a layout activation (the layout already does this).
- Activating `code-review` inside an existing magit buffer — magit manages its own windows; `delete-other-windows` first is safe.

---

## Startup Opt-In

The standard dotfile template (`what/standard/dotfile.spacemacs.tmpl §P5-01`) includes a commented startup hook. To activate `agentic-default` automatically at boot, add to `what/local/operator.private.el`:

```elisp
(add-hook 'emacs-startup-hook #'adna/layout-agentic-default)
```

The hook fires after all layers load. Treemacs and the Claude terminal open on first Emacs boot, giving an immediate battle-station without manual `SPC a l a`.

---

## Source Reference

- `what/standard/layers/adna/layouts.el` — layout function definitions
- `what/standard/layers/adna/keybindings.el` — `adna/layouts-menu` transient + `SPC a l` binding
- `what/decisions/adr/adr_035_agentic_layout_system.md` — decision record
- ADR-019 — `claude-code-ide` layer and window-side configuration
