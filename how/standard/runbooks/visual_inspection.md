---
type: runbook
status: active
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [runbook, visual, inspection, ui, validation, acceptance]
---

# Visual Inspection Runbook

Screenshot-based UI validation checklist for a deployed Spacemacs.aDNA battle station. Run this after `skill_install`, `skill_deploy`, or any change to `what/standard/layers/adna/` to confirm the visible IDE state matches the expected v1.0 contract.

This runbook does not automate assertions — it guides the operator's eyes. For automated structural checks, use `skill_health_check`.

---

## Prerequisites

- Spacemacs running (not in batch mode)
- `skill_health_check` Checks A-I passed
- Vault directory open in current buffer (any `*.aDNA/` file)

---

## Checklist

### V1 — Theme

| Expected | How to check |
|----------|-------------|
| `spacemacs-dark` applied (dark background, Spacemacs color palette) | `M-x spacemacs/describe-theme` → confirm `spacemacs-dark` is active |
| No light theme visible | Look at the editor background — should be dark (#292b2e or similar) |

**Fail signal**: Light background, or wrong theme name in `spacemacs/describe-theme`.

---

### V2 — Banner

| Expected | How to check |
|----------|-------------|
| LP monolith banner (`banner_active.txt`) visible on Spacemacs startup buffer | Open `*spacemacs*` buffer (`SPC b h`) — should show the ╔══╗ bordered monolith design |
| Banner is not the default Spacemacs logo | Confirm no Spacemacs rocket logo |

**Fail signal**: Default Spacemacs rocket, or `File not found` error for `banner_active.txt`.  
**Fix**: Verify `dotspacemacs-startup-banner` in `~/.spacemacs` points to `what/standard/assets/banner_active.txt`.

---

### V3 — Modeline

| Expected | How to check |
|----------|-------------|
| `doom` modeline format active | Modeline shows left/right segments, no separator-wave style |
| `adna-main` format applied inside `*.aDNA/` buffer | Open any vault `.md` file — modeline left side should show `⬡<vault-name>` segment |
| Vault name visible in modeline | Confirm vault directory name appears (e.g., `⬡Spacemacs.aDNA`) |

**Fail signal**: Wave separator style, or no vault segment visible.  
**Fix**: Check `doom-modeline` user-config block in `~/.spacemacs` `dotspacemacs/user-config`.

---

### V4 — SPC a (adna transient menu)

| Expected | How to check |
|----------|-------------|
| `SPC a` opens the adna transient | Press `SPC a` — which-key popup OR transient buffer should appear within 1 second |
| Groups visible: Navigate / Skills & Graph / Links & Sessions / LP & Claude / Extensions | Confirm group labels in the transient popup |
| `SPC a m` opens MANIFEST.md | Press `SPC a m` — MANIFEST.md opens in current window |

**Fail signal**: `SPC a` does nothing, produces error, or shows wrong groups.  
**Fix**: Verify `adna` layer in `dotspacemacs-configuration-layers`.

---

### V5 — SPC a l (layout transient)

| Expected | How to check |
|----------|-------------|
| `SPC a l` opens the layout transient | Press `SPC a l` — layout transient appears with options: `a` default, `f` focus, `p` pair, `w` writing |
| `SPC a l a` activates agentic-default layout | Press `SPC a l a` — treemacs opens far-left, window arrangement matches agentic-default |

**Fail signal**: `SPC a l` missing or layout doesn't activate.  
**Fix**: Check `layouts.el` loaded and `adna/layout-agentic-default` function is defined (`M-x adna/layout-agentic-default`).

---

### V6 — SPC a x (extensions menu)

| Expected | How to check |
|----------|-------------|
| `SPC a x` opens the extensions transient | Press `SPC a x` — extensions transient appears |
| Seed scripts visible: `s` sitrep, `h` health-check, `o` open-claude | which-key or transient shows `s`, `h`, `o` keys with labels |
| Pressing `s` runs sitrep script | Press `SPC a x s` — vterm buffer opens and runs `adna-show-sitrep.el` |

**Fail signal**: `SPC a x` empty or seed scripts absent.  
**Fix**: Check `scripts/` directory at `what/standard/layers/adna/scripts/` — verify 3 `.el` files present. Check `adna/load-scripts` ran at startup.

---

### V7 — Claude Code spawn (SPC c c / SPC a , l)

| Expected | How to check |
|----------|-------------|
| `SPC c c` spawns a Claude Code vterm session | Press `SPC c c` from inside a `*.aDNA/` buffer — vterm buffer `*claude:<vault-name>*` opens on the right at ~80 cols |
| Treemacs occupies far-left pane | Treemacs visible at far left when agentic-default layout is active |
| Claude Code terminal occupies right pane | vterm buffer in right pane, center is the main edit area |

**Fail signal**: `SPC c c` does nothing, errors, or opens in wrong position.  
**Fix**: Check `claude-code-ide` layer active. Verify `claude-code-ide-window-width` is 80 in `what/local/operator.private.el` or layer default.

---

### V8 — adna-mode minor mode

| Expected | How to check |
|----------|-------------|
| `adna-mode` activates inside `*.aDNA/` vault buffers | Open any `.md` file inside the vault → `M-x describe-mode` → confirm `adna-mode` listed |
| `adna-vault-root` buffer-local var set | `C-h v adna-vault-root` → shows the vault root path |

**Fail signal**: `adna-mode` not listed, or `adna-vault-root` nil.  
**Fix**: Verify `adna/setup-global-hooks` called from `dotspacemacs/user-config` in `~/.spacemacs`.

---

## Pass Criteria

All 8 checks pass: theme, banner, modeline, SPC a menu, SPC a l layout, SPC a x extensions, SPC c c Claude, adna-mode activation.

Record result in the deploy receipt at `deploy/<hostname>/<utc>.md` under a `visual_inspection:` key:

```yaml
visual_inspection:
  date: 2026-05-11
  operator: stanley
  checks_passed: [V1, V2, V3, V4, V5, V6, V7, V8]
  checks_failed: []
  notes: ""
```

Any failed check must be resolved and re-verified before marking the deploy complete.
