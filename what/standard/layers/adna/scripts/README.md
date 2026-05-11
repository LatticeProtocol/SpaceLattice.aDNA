---
type: readme
title: "adna layer scripts/ — shared human-agent command space"
status: active
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [scripts, command_tree, spc_a_x, mcp, adna]
---

# adna/scripts/ — Shared Human-Agent Command Space

This directory is part of the `adna` Spacemacs layer. Files here are auto-loaded at
Spacemacs startup via `adna/load-scripts` and register sub-commands under `SPC a x`.

See `what/context/spacemacs/shared_command_space.md` for the full conceptual overview.

## What belongs here

- Elisp files that add `SPC a x` sub-commands
- Functions that automate operator workflows (open STATE.md, run health checks, etc.)
- Functions wrapped as MCP tools via `claude-code-ide-make-tool`

## What doesn't belong here

| Not here | Where instead |
|----------|---------------|
| Operator-specific scripts (machine paths, personal aliases) | `what/local/scripts/` (gitignored) |
| Full Spacemacs layers (own packages.el, layers.el) | `what/standard/layers/<name>/` |
| One-off experiments | `what/local/scripts/` first, then promote if useful |

## Script interface contract

Each script in this directory must:

1. Use `(provide 'adna-<name>)` at the bottom
2. Define one primary interactive command named `adna/<name>`
3. Register the command under `SPC a x` via `spacemacs/set-leader-keys`

Example skeleton:

```elisp
;;; adna-my-command.el --- description  -*- lexical-binding: t -*-
;; License: GPL-3.0

(defun adna/my-command ()
  "What this command does."
  (interactive)
  ;; implementation
  )

(when (fboundp 'spacemacs/set-leader-keys)
  (spacemacs/declare-prefix "axm" "my command")
  (spacemacs/set-leader-keys "axm" #'adna/my-command))

(provide 'adna-my-command)
;;; adna-my-command.el ends here
```

## Promotion path

```
Draft in what/local/scripts/    →   auto-loads, appears in SPC a x
         ↓  propose via session SITREP
Operator approves + ADR authored
         ↓  skill_layer_promote (sanitization scan)
what/standard/layers/adna/scripts/    →   reaches commons
```

## MCP bridge

Any script function can be exposed to Claude Code:

```elisp
(when (fboundp 'claude-code-ide-make-tool)
  (claude-code-ide-make-tool
   :function #'adna/my-command
   :name "my_command_name"
   :description "What this does, in plain language for Claude"))
```

## Seed scripts (provided by standard)

| File | Command | SPC a x key | Description |
|------|---------|-------------|-------------|
| `adna-show-sitrep.el` | `adna/show-sitrep` | `s` | STATE.md + latest session side-by-side |
| `adna-run-health-check.el` | `adna/run-health-check` | `h` | vterm health-check runner |
| `adna-open-claude-with-layout.el` | `adna/open-claude-with-layout` | `o` | Agentic layout + Claude Code in one key |
