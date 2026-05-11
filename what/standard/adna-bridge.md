---
type: spec
status: active
created: 2026-05-03
updated: 2026-05-11
last_edited_by: agent_stanley
implementation_phase: 4
implementation_path: what/standard/layers/adna/
tags: [spec, adna, bridge, layer, elisp, spacemacs, claude_code_ide, live]
---

# adna-bridge — Spacemacs layer spec (live as of P4-09)

This document describes the **live state** of the `adna` and `claude-code-ide` Spacemacs layers. Both layers are implemented at `what/standard/layers/` and active in the LP distribution.

## Two-layer architecture

The aDNA IDE integration is split across two layers:

| Layer | Path | Role |
|-------|------|------|
| `adna` | `what/standard/layers/adna/` | aDNA vault awareness, frontmatter, navigation, session capture, graph, wikilinks, Obsidian round-trip |
| `claude-code-ide` | `what/standard/layers/claude-code-ide/` | Claude Code CLI integration via MCP bridge; buffer context, LSP diagnostics, tree-sitter, project info |

The split keeps vault navigation concerns separate from the Claude Code MCP toolchain.

## `adna` layer

### Activation

`adna-mode` is a buffer-local minor mode. Activates when a buffer's file path has any `*.aDNA/` ancestor. The matched ancestor becomes `adna-vault-root` (buffer-local). Hooked to `find-file-hook` via `adna/setup-global-hooks` — called from `dotspacemacs/user-config`.

Implementation: `funcs.el` — `adna/find-vault-root`, `adna/maybe-activate-mode`.

### Frontmatter buffer-locals

Parsed on file open for `.md`, `.org`, `.yaml`, `.yml` files inside a vault:

| Buffer-local | Frontmatter field |
|---|---|
| `adna-frontmatter-type` | `type` |
| `adna-frontmatter-status` | `status` |
| `adna-frontmatter-tags` | `tags` |
| `adna-frontmatter-created` | `created` |
| `adna-frontmatter-updated` | `updated` |
| `adna-frontmatter-last-edited-by` | `last_edited_by` |
| `adna-frontmatter-raw` | full frontmatter as alist |

### Keybinding map — `SPC a`

| Key | Command | Behavior |
|-----|---------|----------|
| `SPC a` | `adna/menu` | Root transient menu |
| `SPC a m` | `adna/open-manifest` | Open `MANIFEST.md` |
| `SPC a c` | `adna/open-claude` | Open `CLAUDE.md` |
| `SPC a s` | `adna/open-state` | Open `STATE.md` |
| `SPC a r` | `adna/jump-triad-root` | Cycle `who/` → `what/` → `how/` |
| `SPC a k` | `adna/run-nearest-skill` | Pick and open a `skill_*.md` |
| `SPC a i` | `adna-index-project` | Rebuild `what/standard/index/graph.json` |
| `SPC a g` | `adna/render-lattice-graph` | Open graph.json |
| `SPC a n` | `adna/capture-session-note` | New session file from template |
| `SPC a w` | `adna/follow-wikilink` | Follow `[[Target]]` at point |
| `SPC a o` | `adna/open-in-obsidian` | Open file in Obsidian via Advanced URI |
| `SPC a l` | `adna/layouts-menu` | Named layout sub-menu |
| `SPC a l a` | `adna/layout-agentic-default` | Treemacs + edit + Claude terminal |
| `SPC a l v` | `adna/layout-vault-navigation` | Treemacs + content + imenu-list |
| `SPC a l c` | `adna/layout-campaign-planning` | Campaign doc + mission + STATE.md |
| `SPC a l r` | `adna/layout-code-review` | Magit + source + vterm |
| `SPC a p` | `adna/lp-menu` | Lattice Protocol sub-menu |
| `SPC a ,` | `adna/claude-menu` | Claude Code spawn sub-menu |
| `SPC a , s` | `adna/claude-project-switch` | Activate layout + list sessions |
| `SPC a x` | `adna/extensions-menu` | Agent-extensible commands |
| `SPC a x p` | `adna/claude-project-switch` | Project switch (example extension) |

### Claude Code spawn functions (vterm fallback)

Four functions in `funcs.el` provide a vterm/eshell fallback when `claude-code-ide.el` is not loaded. When the `claude-code-ide` layer is active, the `SPC c` commands are preferred for full MCP tool support.

| Function | CLI invocation |
|----------|---------------|
| `adna/spawn-claude-code` | `claude` |
| `adna/spawn-claude-plan` | `claude --plan` |
| `adna/spawn-claude-loop` | `claude --loop <task>` |
| `adna/spawn-claude-review` | `claude /review <file>` |

**`adna/claude-project-switch`** (P5-02): Activates `adna/layout-agentic-default`, then calls `claude-code-ide-list-sessions` if available. Provides single-key multi-project context switching.

## `claude-code-ide` layer

The `claude-code-ide` layer wraps [`manzaltu/claude-code-ide.el`](https://github.com/manzaltu/claude-code-ide.el) — the MCP bridge between the Claude Code CLI and Emacs. Delivers buffer selection, diagnostics, LSP references, and tree-sitter analysis as context to Claude Code sessions. Decision rationale: ADR-019.

### MCP tools registered

`claude-code-ide-emacs-tools-setup` is called in `:config` and registers:

- **xref** — go-to-definition, find-references
- **imenu** — current buffer symbol index
- **tree-sitter** — AST query for current node
- **project info** — project root, active files, compile commands

### Window contract (ADR-036)

| Zone | Owner | Width |
|------|-------|-------|
| Far-left | treemacs | ~35 cols |
| Center | file edit area | remaining |
| Far-right | Claude Code terminal | 80 cols |

`claude-code-ide-window-side 'right`, `claude-code-ide-window-width 80`. Terminal backend: `eat` (anti-flicker, proper color). Minimum comfortable frame width: **160 cols** (35 + 80 + 45 edit area). Below 160, collapse treemacs first.

### Keybinding map — `SPC c`

Established by ADR-013, extended in ADR-019:

| Key | Command | Behavior |
|-----|---------|----------|
| `SPC c c` | `claude-code-ide-menu` | Transient menu for all Claude commands |
| `SPC c s` | `claude-code-ide` | Start session for current project |
| `SPC c t` | `claude-code-ide-toggle` | Toggle Claude window |
| `SPC c p` | `claude-code-ide-send-prompt` | Send prompt from minibuffer |
| `SPC c l` | `claude-code-ide-list-sessions` | List/switch active sessions |
| `SPC c r` | `claude-code-ide-resume` | Resume previous conversation |
| `SPC c n` | `claude-code-ide-continue` | Continue most recent conversation |

### System prompt

`claude-code-ide-adna-system-prompt` identifies the session as operating inside a Spacemacs.aDNA/LatticeProtocol context. Set `claude-code-ide-system-prompt` to this value in `dotspacemacs/user-config`:

```elisp
(setq claude-code-ide-system-prompt claude-code-ide-adna-system-prompt)
```

## Health-check hook

`(adna/health-check)` is callable from `emacs --batch`. Checks:
- Required functions bound (including `adna/claude-project-switch`)
- Required vars bound
- `adna-mode` minor mode defined

Returns non-nil on success; calls `(kill-emacs 50)` on failure in batch contexts. Used by `skill_health_check` Check E and `skill_self_improve` dry-run gate.

## License

GPL-3.0 (matches Spacemacs upstream — see `who/upstreams/syl20bnr.md`).
