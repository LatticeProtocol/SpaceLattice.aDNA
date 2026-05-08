---
type: runbook
title: "macOS setup — Spacemacs.aDNA deployment"
status: active
platform: macos
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [runbook, macos, osx, deployment, setup, platform]
---

# macOS setup — Spacemacs.aDNA deployment

Platform-specific checklist for deploying Spacemacs.aDNA on macOS (Sonoma / Sequoia).
Run this before or alongside `skill_install`. For configuration details and elisp
snippets, see `what/context/platform_macos.md`.

**Prerequisites**: Homebrew installed, Xcode Command Line Tools installed.

---

## Step 1 — Install Emacs Plus

```bash
brew tap d12frosted/emacs-plus
brew install emacs-plus@30 \
  --with-no-frame-refocus \
  --with-native-comp \
  --with-savchenkovaleriy-big-sur-curvy-3d-icon
```

Create the Applications symlink so macOS treats it as a proper app:

```bash
ln -fs /opt/homebrew/opt/emacs-plus@30/Emacs.app /Applications/
```

Verify:

```bash
emacs --version   # Should show GNU Emacs 30.x
```

**Native compilation note**: On first launch, Emacs will async-compile all Lisp files.
This takes 5-15 minutes. The `*Warnings*` buffer will show progress. Normal — do not quit.

---

## Step 2 — System hotkey conflict

macOS binds `C-M-d` to Dictionary lookup, intercepting Emacs's `down-list`. Fix it:

```bash
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
  -dict-add 70 '<dict><key>enabled</key><false/></dict>'
```

Log out and back in. Verify: `C-M-d` in Emacs should call `down-list`, not open Dictionary.

---

## Step 3 — Shell PATH

macOS GUI apps don't inherit shell PATH. The Spacemacs `osx` layer (already in our
standard layer list) handles this via `exec-path-from-shell`. After first Spacemacs
launch, verify:

```
M-x exec-path-from-shell-initialize
```

Then check:

```
M-: (executable-find "rg")     ; should return a path
M-: (executable-find "git")    ; should return a path
```

If not found, ensure `rg` and `git` are installed via Homebrew:

```bash
brew install ripgrep git
```

---

## Step 4 — Modifier key verification

After Spacemacs launches with the standard dotfile, verify modifier keys:

- Press `Cmd-x` → should invoke `M-x` (minibuffer opens)
- Press `Option-x` → should insert special character (Option passes through to macOS)
- `C-M-d` → should call `down-list` (not Dictionary popup, after Step 2)

These are configured in `dotfile.spacemacs.tmpl` under the `(when (eq system-type 'darwin) ...)` block.

---

## Step 5 — Font installation

The standard dotfile uses **Source Code Pro** at 15pt. Install if not present:

```bash
brew install --cask font-source-code-pro
```

Alternative: **JetBrains Mono** or **Fira Code** (update `dotspacemacs-default-font` in
`what/local/operator.private.el` to override without touching standard).

---

## Step 6 — vterm compilation

The `vterm` package requires compilation of a native C module. The standard dotfile
sets `vterm-always-compile-module t` (auto-compiles on first install). Verify `cmake`
is available:

```bash
brew install cmake
```

After Spacemacs launches, vterm will compile automatically. Check `*vterm-compile*`
buffer if there are errors.

---

## Step 7 — Optional: dwim-shell-command (macOS integration)

```bash
# No system deps — pure elisp. Install via Spacemacs package management:
# Add to dotspacemacs-additional-packages: dwim-shell-command
# Then SPC q r to restart Spacemacs and install.
```

See `what/context/platform_macos.md` for configuration snippets.

---

## Step 8 — Optional: Karabiner-Elements (system-wide keybindings)

If you want Emacs-style `C-a`/`C-e`/`C-k` in all macOS apps:

```bash
brew install --cask karabiner-elements
```

Recommended rule: remap `Caps Lock → Left Control` in Karabiner preferences.
Also consider the "Emacs key bindings everywhere" complex modification from the Karabiner
gallery.

---

## Step 9 — Optional: iOS org sync

If using org-mode with mobile sync (configured in `p3_14_org_mode_deep_config`):

1. Create an iCloud Drive folder for org files: `~/Library/Mobile Documents/iCloud~com~organizer~rideorganizer/Documents/org/` (or simpler symlink)
2. Set `org-directory` to point to this path in `what/local/operator.private.el`
3. Install Plain Org or Beorg on iOS, point to the same iCloud folder

---

## Verification checklist

After completing relevant steps, confirm:

- [ ] `emacs --version` shows 30.x
- [ ] Native compilation in progress (or complete) — `*Warnings*` buffer shows `.elc` compilation
- [ ] `C-M-d` calls `down-list` (not Dictionary popup)
- [ ] `Cmd-x` opens minibuffer (`M-x`)
- [ ] `Option-x` inserts special character (macOS passthrough)
- [ ] `M-x exec-path-from-shell-initialize` finds `rg` and `git`
- [ ] `vterm` opens (`SPC '`) without errors
- [ ] Font renders at correct size (15pt Source Code Pro)

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `emacs: command not found` | `brew link emacs-plus@30` |
| Native comp warnings flood `*Warnings*` | Normal on first launch — wait for completion |
| `C-M-d` still opens Dictionary | Log out and back in after `defaults write` |
| `rg` not found by Emacs | Run `exec-path-from-shell-initialize`, or add `/opt/homebrew/bin` to shell PATH |
| vterm compile fails | `brew install cmake`, then `SPC q r` |
| Font too small/large | Set `:size` in `dotspacemacs-default-font` in `what/local/operator.private.el` |

---

## References

- Context: `what/context/platform_macos.md`
- Mission: `mission_sl_p3_12_platform_context_macos`
- `skill_install`: `how/standard/skills/skill_install.md`
- `skill_deploy`: `how/standard/skills/skill_deploy.md`
