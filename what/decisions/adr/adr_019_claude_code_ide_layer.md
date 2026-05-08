---
type: decision
adr_id: ADR-019
title: "Add claude-code-ide layer — Claude Code MCP bridge with Emacs context"
status: accepted
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
supersedes: []
superseded_by: []
tags: [adr, layer, claude-code, mcp, ide, integration, standard]
---

# ADR-019 — Add claude-code-ide layer

## Context

The standard dotfile already includes the generic upstream Spacemacs `claude-code` layer,
which provides a basic terminal wrapper around the Claude Code CLI. However, a far more
capable integration exists: `claude-code-ide.el` by manzaltu
(https://github.com/manzaltu/claude-code-ide.el).

`claude-code-ide` creates a bidirectional bridge between Claude Code CLI and Emacs via
the Model Context Protocol (MCP). This allows Claude to understand and leverage:

- **Active buffer context**: Claude sees which file you are editing
- **Selection context**: Claude can work on highlighted text
- **Diagnostics**: Flycheck/Flymake errors and warnings passed to Claude
- **Tree-sitter AST analysis**: Structured syntax exposed as MCP tools
- **LSP/xref navigation**: Go-to-definition and references as MCP tools
- **Ediff integration**: Apply Claude's code suggestions with diff/accept/reject UI
- **Multi-session**: Concurrent Claude Code sessions across projects
- **Custom tools**: `claude-code-ide-make-tool` exposes custom Elisp functions as MCP tools

This is directly aligned with Spacemacs.aDNA's core purpose: context-native agentic IDE
operation. The existing `claude-code` Spacemacs upstream layer is superseded in scope by
this integration.

## Decision

1. **Create a private Spacemacs layer** at `what/standard/layers/claude-code-ide/` that
   wraps `claude-code-ide.el` with Spacemacs-native conventions.

2. **Add `claude-code-ide` to the standard dotfile** (default-on; opt-out via
   `dotspacemacs-excluded-packages`).

3. **Remove the generic `claude-code` entry** from the dotfile layer list — superseded.

4. **Keybinding scheme** (extends ADR-013, which established `SPC c c`):

   | Key | Command | Description |
   |-----|---------|-------------|
   | `SPC c c` | `claude-code-ide-menu` | Main transient menu |
   | `SPC c s` | `claude-code-ide` | Start Claude for current project |
   | `SPC c t` | `claude-code-ide-toggle` | Toggle Claude window |
   | `SPC c p` | `claude-code-ide-send-prompt` | Send prompt from minibuffer |
   | `SPC c l` | `claude-code-ide-list-sessions` | List/switch sessions |
   | `SPC c r` | `claude-code-ide-resume` | Resume previous conversation |

5. **Default configuration**:
   - Window: right side, 100 columns, focus-on-open nil
   - Terminal backend: `eat` (preferred; falls back to `vterm` already in standard)
   - Diagnostics: `flycheck` (already in standard layer list)
   - MCP tools: enabled via `claude-code-ide-emacs-tools-setup`

6. **Layer placement**: `claude-code-ide` layer lives alongside `adna` in
   `what/standard/layers/`. Symlinked to `~/.emacs.d/private/layers/` by `skill_install`
   and `skill_deploy`.

## Implementation notes

- The `claude-code-ide` package is installed via `:vc` (Emacs 30 built-in) pointing to
  the GitHub repo. No MELPA/ELPA entry needed.
- `eat` package for terminal backend should be added to `dotspacemacs-additional-packages`
  if not already present via a layer.
- `claude-code-ide-emacs-tools-setup` is called in `config.el` to register built-in
  MCP tools (xref, imenu, tree-sitter, project info).

## Health check

After adding the layer:
1. `skill_health_check` must pass (emacs --batch layer-load validation)
2. Verify `claude-code-ide-menu` is bound to `SPC c c` via which-key
3. Verify `claude-code-ide` launches a Claude Code session in a right-side window

## Rationale

Spacemacs.aDNA's thesis is that Spacemacs can serve as a context-native agentic IDE.
`claude-code-ide.el` is the most complete available implementation of that thesis —
providing MCP-backed bidirectional context flow between the agent and the editor.
Making it a standard default-on layer signals that Claude Code integration is core
to this vault's identity, not an optional add-on.

## References

- Package: https://github.com/manzaltu/claude-code-ide.el (researched 2026-05-07)
- ADR-013: Keybinding refactor (`SPC a`, `SPC o l`, `SPC c c`)
- Mission: `mission_sl_p4_09_claude_code_ide_layer`
- Operator decision: default-on (confirmed 2026-05-07)
