---
type: context
title: "Platform context — macOS"
status: active
created: 2026-05-07
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [platform, macos, osx, emacs, spacemacs, configuration, deployment]
---

# Platform context — macOS

macOS-specific configuration reference for Spacemacs.aDNA deployments. All elisp
snippets in this file are applied conditionally via `(eq system-type 'darwin)` guards
in `dotfile.spacemacs.tmpl`. For the operator-facing install checklist, see
`how/standard/runbooks/macos_setup.md`.

---

## Build recommendations

### Emacs Plus (Homebrew)

The recommended macOS Emacs build is **Emacs Plus** from Homebrew. Key flags:

```bash
brew install emacs-plus@30 \
  --with-no-frame-refocus \
  --with-native-comp \
  --with-savchenkovaleriy-big-sur-curvy-3d-icon
```

| Flag | Effect |
|------|--------|
| `--with-no-frame-refocus` | Prevents macOS from stealing focus when switching apps away from Emacs |
| `--with-native-comp` | Enables GCC-based ahead-of-time compilation of Emacs Lisp — significant startup/runtime speedup |
| `--with-savchenkovaleriy-big-sur-curvy-3d-icon` | macOS Monterey/Sonoma-compatible app icon (aesthetic) |

Alternative: Emacs Mac Port (`railwaycat/emacsmacport`) provides tighter Cocoa integration but lags on Emacs version updates. Emacs Plus preferred for this vault.

---

## Modifier key mapping

macOS keyboards map physical keys differently from Linux. Standard Spacemacs/Emacs
configuration for ergonomic use:

```elisp
(when (eq system-type 'darwin)
  ;; Command → Meta (most natural for Emacs M- bindings on Mac)
  (setq mac-command-modifier 'meta)
  ;; Option → none (left for macOS diacritics, special chars)
  (setq mac-option-modifier 'none))
```

**C-M-d conflict fix**: macOS binds C-M-d to the Dictionary popover, intercepting
Emacs's `down-list` binding. To release it:

```bash
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
  -dict-add 70 '<dict><key>enabled</key><false/></dict>'
```

Log out and back in for the change to take effect.

---

## Frame and display settings

```elisp
(when (eq system-type 'darwin)
  ;; Reuse existing frame instead of popping new ones (e.g., from 'open' CLI)
  (setq ns-pop-up-frames nil)

  ;; Transparent title bar — integrates Emacs frame into macOS chrome
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))

  ;; Disable sRGB colorspace — more accurate color rendering for themes
  (setq ns-use-srgb-colorspace nil))
```

---

## Shell and PATH integration

macOS GUI Emacs does not inherit the shell's PATH. The `exec-path-from-shell`
package (included in the Spacemacs `osx` layer) resolves this:

```elisp
;; Already handled by the osx Spacemacs layer — no manual config needed
;; when the osx layer is in dotspacemacs-configuration-layers.
```

Verify PATH is correct after install:

```
M-x exec-path-from-shell-initialize  ; manual trigger if needed
```

---

## Emoji and Unicode input

- **Globe key (macOS 12+)**: Press the globe key on modern Apple keyboards to open the system emoji picker. Works in Emacs GUI without configuration.
- **Programmatic access**: `M-x ns-do-show-character-palette` opens the full macOS Character Viewer from within Emacs.
- Unicode rendering requires the `unicode-fonts` Spacemacs layer (already in standard layer list).

---

## dwim-shell-command — macOS integration package

`dwim-shell-command` provides macOS-specific shell command bindings from within Emacs,
operable on the current buffer or dired selection.

```elisp
(use-package dwim-shell-command
  :defer t
  :bind (([remap shell-command] . dwim-shell-command)
         :map dired-mode-map
         ([remap dired-do-async-shell-command] . dwim-shell-command)
         ([remap dired-do-shell-command] . dwim-shell-command)
         ([remap dired-smart-shell-command] . dwim-shell-command)))
```

macOS-specific capabilities (loaded via `dwim-shell-commands`):

| Command | Effect |
|---------|--------|
| `dwim-shell-commands-macos-reveal-in-finder` | Reveal current file in Finder |
| `dwim-shell-commands-macos-trash` | Move to Trash (reversible delete) |
| `dwim-shell-commands-macos-toggle-dark-mode` | Toggle macOS dark/light mode |
| `dwim-shell-commands-macos-ocr-image` | OCR image file to text |

**Layer placement (P3-12 decision)**: Added to `dotspacemacs-additional-packages` (not a separate layer). `with-eval-after-load` binding block lives in `dotfile.spacemacs.tmpl §P3-12`.

---

## Keybinding system extensions

### Karabiner-Elements — Hyper key setup

**Operator setup (P3-12 confirmed)**: Caps Lock → **Hyper key** (Ctrl+Shift+Alt+Cmd simultaneously).

The Hyper modifier gives Emacs a clean, conflict-free modifier namespace (`H-` prefix) for custom bindings, separate from `C-`, `M-`, `s-` (Super), and `A-` (Alt). No macOS system shortcut uses `H-`, so every `H-<key>` binding is available.

**Karabiner-Elements configuration**:

```json
{
  "description": "Caps Lock → Hyper (Ctrl+Shift+Alt+Cmd)",
  "manipulators": [
    {
      "from": { "key_code": "caps_lock", "modifiers": { "optional": ["any"] } },
      "to": [{ "key_code": "left_shift", "modifiers": ["left_control", "left_option", "left_command"] }],
      "to_if_alone": [{ "key_code": "escape" }],
      "type": "basic"
    }
  ]
}
```

`to_if_alone` maps a bare Caps Lock tap to `Escape` — useful in vim/evil-mode for exiting normal state without reaching for the corner key.

**Emacs side**: Spacemacs receives `H-<key>` events automatically when Karabiner remaps Caps Lock this way. No elisp configuration needed. Reserve `H-` bindings for global commands that should work in any major mode (e.g., `H-l` → `adna-find-context`, `H-s` → `adna-session-new`).

Configuration lives in `~/.config/karabiner/karabiner.json`. Install via `brew install --cask karabiner-elements`.

---

## iOS org-mode companion apps

For operators using org-mode with mobile sync (relevant to `p3_14_org_mode_deep_config`):

| App | Purpose | Notes |
|-----|---------|-------|
| **Plain Org** | Full org-mode file access on iOS | Reads/writes `.org` files from iCloud Drive |
| **Journelly** | Note-taking with org markup | Appends to org journal files |
| **Flat Habits** | Habit tracking with org integration | Checkboxes + datetrees |
| **Beorg** | Org-agenda on iOS | Full agenda + capture |

Sync mechanism: iCloud Drive folder shared between macOS Emacs (`~/Library/Mobile Documents/...`) and iOS apps. Org directory should point to iCloud-synced path.

---

## macOS-specific performance notes

- **Native compilation** (`--with-native-comp`): Most significant performance boost. Async compilation runs on first launch — expect background activity for 5-10 minutes.
- **GC threshold**: Already tuned to 200 MB via ADR-016 (`dotspacemacs-gc-cons`). Larger threshold reduces GC pauses on modern Macs with abundant RAM.
- **LSP buffer**: Already at 4 MB via ADR-016 (`dotspacemacs-read-process-output-max`). macOS LSP servers (sourcekit-lsp for Swift, clangd for C++) benefit from this.

---

## References

- Runbook: `how/standard/runbooks/macos_setup.md`
- Mission: `mission_sl_p3_12_platform_context_macos` (author + operator review)
- ADR-002: Initial Spacemacs pin (`what/decisions/adr/adr_002_initial_spacemacs_pin.md`)
- ADR-016: GC + LSP buffer (`what/decisions/adr/adr_016_gc_threshold_lsp_buffer.md`)
- Source: https://xenodium.com/awesome-emacs-on-macos (2026-05-07)
