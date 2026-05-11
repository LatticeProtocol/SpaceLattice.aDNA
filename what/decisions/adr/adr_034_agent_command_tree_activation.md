---
type: adr
adr_number: 034
title: "SPC a x agent-extensions transient stub: activating the agent command tree"
status: accepted
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
supersedes:
superseded_by:
extends: what/decisions/adr/adr_013_keybinding_transient_refactor.md
tags: [adr, decision, keybinding, transient, agent_command_tree, extensibility, p4_10]
---

# ADR-034: SPC a x agent-extensions transient stub

## Status

Accepted

## Context

`what/context/agent_command_tree.md` (seeded 2026-05-07, research integration session) documents the full `SPC` keybinding hierarchy for Spacemacs.aDNA and defines `SPC a x` as the reserved agent-extension slot. The context doc describes the extension pattern — agents draft elisp in `what/local/operator.private.el`, bind commands under `SPC a x`, report in SITREP, re-index, and promote to standard via `skill_layer_promote` if generally useful.

However, `SPC a x` was not wired in `what/standard/layers/adna/keybindings.el`. The context doc referenced a binding that did not exist in the live layer. A user pressing `SPC a x` would see nothing in which-key.

ADR-013 established the Transient hierarchy (`SPC a` root + `SPC o l` LP + `SPC c c` Claude Code). ADR-034 extends that hierarchy by adding the agent-extensible slot.

## Decision

1. **Add `adna/extensions-menu` transient** to `what/standard/layers/adna/keybindings.el`:
   ```elisp
   (transient-define-prefix adna/extensions-menu ()
     "SPC a x — Agent-authored extensions. Add entries via what/local/operator.private.el."
     ["Agent Extensions"
      ("?" "No extensions registered — see agent_command_tree.md" ignore)])
   ```

2. **Add `("x" "Agent extensions" adna/extensions-menu)`** to the parent `adna/menu` transient's "LP & Claude →" section.

3. **Wire to `SPC a x`**:
   ```elisp
   (spacemacs/declare-prefix "ax" "agent-extensions")
   (spacemacs/set-leader-keys "ax" #'adna/extensions-menu)
   ```

4. **Extension protocol** (documented in `agent_command_tree.md`, not in keybindings.el): agents add entries by calling `transient-append-suffix` or redefining suffix groups in `what/local/operator.private.el`. After adding a command, re-run `M-x adna-index-project` to capture the new command in `graph.json`.

## Consequences

- `SPC a x` is now live and visible in which-key as "agent-extensions"
- The stub transient shows a single placeholder entry directing agents to the context doc
- Agent-authored extensions stay in `what/local/` (gitignored) until promoted via `skill_layer_promote`
- The context doc (`agent_command_tree.md`) remains the authoritative reference for the extension protocol
- `skill_adna_index` updated to note that re-indexing is expected after any `SPC a x` extension

## Rationale

Activating the stub now makes the keybinding system self-consistent with the context doc. An empty slot is worse than a documented placeholder: operators and agents learn that `SPC a x` is the correct extension point rather than inventing ad-hoc bindings elsewhere.

The transient design (one placeholder entry with `ignore`) is the minimal viable stub. It opens cleanly, displays the help string, and serves as a graft point for `transient-append-suffix` calls from `operator.private.el`.
