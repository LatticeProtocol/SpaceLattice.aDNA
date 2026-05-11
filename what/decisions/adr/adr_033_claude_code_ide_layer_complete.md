---
type: adr
adr_number: 033
title: "claude-code-ide layer skeleton completion: layers.el + skill_deploy correction"
status: accepted
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, claude_code_ide, layer, skill_deploy, p4_09]
---

# ADR-033: claude-code-ide layer skeleton completion

## Status

Accepted

## Context

ADR-019 (2026-05-07) designed and accepted the `claude-code-ide` Spacemacs layer. During the 2026-05-07 research integration session, a 4-file skeleton was created at `what/standard/layers/claude-code-ide/`: `packages.el`, `config.el`, `keybindings.el`, `README.org`. The layer was declared in `dotfile.spacemacs.tmpl` and symlinked by `skill_install` Step 5 (extended in P4-01).

One file was missing: `layers.el`. Every Spacemacs layer that uses `spacemacs/declare-prefix` or `spacemacs/set-leader-keys` must declare `spacemacs-bootstrap` as a load-order dependency via `layers.el`; without it, `keybindings.el` may execute before the Spacemacs keybinding APIs are available.

Additionally, `skill_deploy.md` Step 5 retained the pre-P4-01 description ("Refresh `~/.emacs.d/private/layers/adna` symlink") despite `skill_install` Step 5 having been extended in P4-01 to symlink all 4 LP layers. This documentation drift could mislead future operators or agents reading `skill_deploy.md` in isolation.

## Decision

1. **Add `layers.el`** to `what/standard/layers/claude-code-ide/`:
   ```elisp
   (configuration-layer/declare-layer-dependencies '(spacemacs-bootstrap))
   ```
   This is the minimal, correct load-order declaration. No functional change to layer behavior — `spacemacs-bootstrap` is always loaded; this just makes the dependency explicit and ensures ordering.

2. **Correct `skill_deploy.md` Step 5** description from "Refresh `~/.emacs.d/private/layers/adna` symlink" to "Refresh all LP layer symlinks (adna, claude-code-ide, spacemacs-latticeprotocol, +themes/latticeprotocol-theme)" — matching the actual behavior of `skill_install` Step 5 post-P4-01.

## Consequences

### Positive
- `claude-code-ide` layer is now a complete, well-formed Spacemacs layer (5 files)
- `skill_deploy.md` and `skill_install.md` are consistent in their layer coverage description
- Future `skill_health_check` batch runs will validate `claude-code-ide` loads cleanly

### Negative
- None — `layers.el` is a declaration-only file; no runtime behavior changes

### Neutral
- Layer now follows the same 5-file convention as the `adna` layer

## References

- ADR-019: `what/decisions/adr/adr_019_claude_code_ide_layer.md` (layer design + full keybinding scheme)
- ADR-024: vault-only layer model (layers live in `what/standard/layers/`)
- `what/standard/layers/adna/layers.el` — pattern reference
- Mission: `mission_sl_p4_09_claude_code_ide_layer`
