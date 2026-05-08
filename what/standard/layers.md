---
type: layers_manifest
status: active
created: 2026-05-03
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [layers, standard, spacemacs, manifest]
---

# Spacemacs layer manifest — standard

The canonical layer list rendered into `~/.spacemacs` via `dotfile.spacemacs.tmpl` placeholder `{{LAYER_LIST}}`. Operators add personal layers in `what/local/operator.private.el` (loaded last in deploy).

## Distribution layers (Spacemacs upstream)

### Editing & navigation

| Layer | Purpose | Notes |
|-------|---------|-------|
| `auto-completion` | Company-mode + snippets | `:variables auto-completion-tab-key-behavior 'cycle` |
| `better-defaults` | Saner emacs defaults | — |
| `helm` | Selection framework | Default. Alternative: `ivy` |
| `treemacs` | File tree | `:variables treemacs-use-follow-mode t` |
| `git` | Magit + git-gutter | — |
| `version-control` | VC mode integration | — |

### Languages

| Layer | Purpose | Notes |
|-------|---------|-------|
| `lsp` | Language Server Protocol orchestration | Required for python/typescript/rust |
| `python` | Python with ML emphasis | numpy / pandas / jupyter integration; `:variables python-backend 'lsp` |
| `typescript` | TypeScript / JavaScript | tide or LSP backend |
| `rust` | Rust | `:variables rust-backend 'lsp rust-format-on-save t` |
| `shell-scripts` | Bash / zsh | — |
| `emacs-lisp` | Elisp (for editing the `adna` layer itself) | — |
| `markdown` | Markdown editing + preview | `:variables markdown-live-preview-engine 'vmd` |
| `org` | Org-mode | `:variables org-want-todo-bindings t` |
| `yaml` | YAML editing (frontmatter, lattice yaml) | — |

### Tools

| Layer | Purpose | Notes |
|-------|---------|-------|
| `shell` | Built-in shell + eshell + vterm | `:variables shell-default-shell 'vterm` |
| `multiple-cursors` | Multi-cursor editing | — |
| `spell-checking` | flyspell | — |
| `syntax-checking` | flycheck | — |

## Spacemacs.aDNA-specific layers

### `adna` (vault-private)

Lives in `what/standard/layers/adna/`. Symlinked to `~/.emacs.d/private/layers/adna/` by `skill_install`.

Capabilities (full spec: `what/standard/adna-bridge.md`):

- `adna-mode` minor mode auto-activated inside `*.aDNA/` ancestor directories
- YAML frontmatter parsed into buffer-local variables on `find-file-hook`
- `SPC a` transient menu — open MANIFEST, jump to triad root, run nearest skill, render lattice graph, capture session note
- `SPC c c` — Spawn Claude Code session pinned to nearest aDNA root
- Wikilink follow (`RET` on `[[Target]]` resolves via aDNA convention)
- Obsidian round-trip via Advanced URI plugin
- `M-x adna-index-project` — emit context graph to `what/standard/index/graph.json`

License: GPL-3.0 (matches Spacemacs upstream — see `who/upstreams/syl20bnr.md`).

### `claude-code-ide` (vault-private)

Lives in `what/standard/layers/claude-code-ide/`. Symlinked to `~/.emacs.d/private/layers/claude-code-ide/` by `skill_install`.

Wraps [`claude-code-ide.el`](https://github.com/manzaltu/claude-code-ide.el) — an MCP bridge between Claude Code CLI and Emacs. Default-on per ADR-019.

Capabilities:

- Active buffer and text selection context visible to Claude Code sessions
- Flycheck/Flymake diagnostics exposed to Claude via MCP
- Tree-sitter AST analysis as MCP tools
- LSP/xref navigation (go-to-definition, find-references) as MCP tools
- Ediff integration for reviewing/accepting Claude's code suggestions
- Multi-session support across concurrent projects
- Custom function exposure via `claude-code-ide-make-tool`

Keybindings (extends ADR-013):

| Key | Command | Description |
|-----|---------|-------------|
| `SPC c c` | `claude-code-ide-menu` | Main transient menu |
| `SPC c s` | `claude-code-ide` | Start session for current project |
| `SPC c t` | `claude-code-ide-toggle` | Toggle Claude window |
| `SPC c p` | `claude-code-ide-send-prompt` | Send prompt from minibuffer |
| `SPC c l` | `claude-code-ide-list-sessions` | List/switch sessions |
| `SPC c r` | `claude-code-ide-resume` | Resume previous conversation |

Dependencies: `eat` (terminal backend), `flycheck` (diagnostics — already standard), `vterm` (fallback).

License: GPL-3.0.

## Layer addition protocol

`skill_layer_add` (Phase 3) is the only sanctioned path to add a new layer to `standard/`:

1. Operator names the layer + reason
2. Skill drafts an ADR proposing the addition with:
   - Why this layer
   - Default `:variables` (if any)
   - Which existing layer it might conflict with
3. Skill renders a draft `dotfile.spacemacs.tmpl` change + appends to this file
4. Skill runs `skill_health_check` in scratch worktree
5. Operator approves → layer lands in standard

## Local layer additions

Operators can add layers without ADR via `what/local/operator.private.el`. These are loaded last in `dotspacemacs/user-init`. They:

- Stay private (gitignored)
- Don't pollute the commons
- Can be promoted via `skill_layer_promote` later (ADR-gated)
