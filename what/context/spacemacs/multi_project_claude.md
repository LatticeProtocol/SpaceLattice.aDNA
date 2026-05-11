---
type: context
status: active
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [context, spacemacs, claude_code, multi_project, window_contract, sessions, mcp]
---

# Multi-project Claude Code workflow

This document describes how to run Claude Code sessions for multiple aDNA vaults simultaneously inside a single Spacemacs frame, and how the window contract keeps them coherent.

## Window contract

Three permanent zones in every agentic layout (ADR-036):

```
┌──────────┬────────────────────────┬─────────────────┐
│ treemacs │  file edit area        │  Claude Code    │
│  ~35 col │  (remaining width)     │  terminal 80col │
└──────────┴────────────────────────┴─────────────────┘
```

- **Far-left**: treemacs — project/vault file tree
- **Center**: file edit area — the buffer you are reading or writing
- **Far-right**: Claude Code terminal (`eat` backend, 80 cols, right side)

**Minimum comfortable frame width**: 160 columns. Below 160: collapse treemacs first.

Configuration in `what/standard/layers/claude-code-ide/packages.el`:

```elisp
(setq claude-code-ide-window-side 'right
      claude-code-ide-window-width 80
      claude-code-ide-focus-on-open nil)
```

## Starting a session

### Single-vault workflow (most common)

1. Open a file in the target vault — `adna-mode` activates automatically
2. `SPC a l a` — activate agentic-default layout (treemacs + edit + Claude zone)
3. `SPC c s` — start Claude Code session for current project root

Claude's terminal appears in the right zone. The session name includes the vault directory (e.g., `*claude-code-ide:Spacemacs.aDNA*`).

### Project-switch workflow (N vaults)

Use `adna/claude-project-switch` (`SPC a , s` or `SPC a x p`) to:
1. Re-activate the agentic-default layout (clean slate)
2. Call `claude-code-ide-list-sessions` — presents all open sessions across projects

Select a session to bring it to the right zone. The edit area center re-focuses to that project's last buffer.

## Session naming and discovery

Sessions are named by `claude-code-ide.el` using the project root basename:

```
*claude-code-ide:Spacemacs.aDNA*
*claude-code-ide:RareHarness.aDNA*
*claude-code-ide:SiteForge.aDNA*
```

`SPC c l` (`claude-code-ide-list-sessions`) lists all active sessions and lets you switch. Sessions persist until you kill the buffer or exit Emacs.

## Routing prompts between sessions

Each `SPC c p` send-prompt targets the **currently selected session** (the one in the right zone). To route a prompt to a different project:

1. `SPC c l` — list sessions, select the target
2. `SPC c p` — now sends to that project's session

Tip: keep projects with heavy context in separate named layouts and switch via `SPC a l a/v/c/r`.

## Resuming and continuing conversations

| Key | Command | When to use |
|-----|---------|-------------|
| `SPC c r` | `claude-code-ide-resume` | Resume a prior conversation from the session's history |
| `SPC c n` | `claude-code-ide-continue` | Continue the most recent conversation |

Both commands target the active session in the right zone.

## MCP tool context per project

`claude-code-ide-emacs-tools-setup` registers xref, imenu, tree-sitter, and project info as MCP tools. These tools are **buffer-scoped** — they reflect whichever buffer is active in the edit area at the time Claude calls them.

To give Claude context from a different project:
1. Switch the edit area buffer to a file in that project
2. Claude's next MCP tool call will pick up that project's LSP/tree-sitter context

## Project-scoped system prompts

The LP distribution sets `claude-code-ide-adna-system-prompt` as a default. Override per-operator in `what/local/operator.private.el`:

```elisp
;; Custom prompt for RareHarness clinical sessions
(setq claude-code-ide-system-prompt
      "You are operating in RareHarness.aDNA — rare-disease clinical decision support. ...")
```

Per-session overrides are not yet supported by `claude-code-ide.el`; all sessions share the configured system prompt. Track upstream feature request for per-buffer system prompts.

## Closing and archiving sessions

- `C-x k` — kill the Claude terminal buffer to end the session
- Sessions do not auto-archive; killed sessions are gone
- For audit purposes, copy important exchange excerpts to the session file in `how/sessions/active/` before closing

## Acceptance test

See `how/standard/runbooks/claude_code_acceptance_test.md` for the 8-step operator validation checklist.
