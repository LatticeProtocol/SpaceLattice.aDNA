---
type: context
title: "Agent command tree — dynamic keybinding extension for Spacemacs.aDNA"
status: active
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [agent, keybinding, transient, mcp, command-tree, extensibility, adna]
---

# Agent command tree — dynamic keybinding extension

Spacemacs.aDNA is designed so that agents can discover, add, and compose commands at
runtime. This document describes the keybinding hierarchy, how agents extend it, and
how custom Emacs capabilities can be exposed to Claude Code via MCP tools.

---

## Current keybinding hierarchy (per ADR-013)

```
SPC                 — Spacemacs leader
├── SPC a           — adna transient menu (this vault's primary agent menu)
│   ├── SPC a h     — open MANIFEST.md
│   ├── SPC a t     — jump to triad root (who/what/how)
│   ├── SPC a s     — run nearest skill
│   ├── SPC a g     — render lattice graph
│   ├── SPC a n     — capture session note
│   └── SPC a x     — agent extensions (stub — populated by agents at runtime)
│
├── SPC c           — Claude Code integration
│   ├── SPC c c     — claude-code-ide-menu (main transient, ADR-019)
│   ├── SPC c s     — start Claude for current project
│   ├── SPC c t     — toggle Claude window
│   ├── SPC c p     — send prompt from minibuffer
│   ├── SPC c l     — list/switch sessions
│   └── SPC c r     — resume previous conversation
│
└── SPC o l         — LP (LatticeProtocol) prefix
    ├── SPC o l v   — show vault root
    ├── SPC o l g   — open graph.json
    └── SPC o l s   — run skill_self_improve
```

The `adna` layer owns `SPC a`. The `claude-code-ide` layer owns `SPC c c`. LP bindings
live under `SPC o l` (namespaced under Spacemacs's user prefix `SPC o`).

---

## SPC a x — Agent extension stub

`SPC a x` is an intentionally reserved transient slot for agent-authored command
extensions. When an agent adds a new capability, it appends a binding here.

### How agents add a command

1. **Draft the elisp function** in a local layer (`what/local/`) or as a lambda:

```elisp
(defun my-custom-command ()
  "Description of what this does."
  (interactive)
  ;; implementation
  )
```

2. **Add the binding** to `SPC a x` in `what/local/operator.private.el`:

```elisp
(with-eval-after-load 'adna
  (spacemacs/declare-prefix "ax" "agent extensions")
  (spacemacs/set-leader-keys "axc" #'my-custom-command))
```

3. **Report the binding in the session SITREP** so the operator knows it exists.

4. **If the command is generally useful**, propose promotion via `skill_layer_promote`
   (ADR-gated, sanitization-scanned before it reaches standard/).

5. **Re-run `M-x adna-index-project`** after any command additions so `graph.json`
   reflects the new capability.

### Example: adding a lattice-specific command

```elisp
;; In what/local/operator.private.el
(defun adna/open-state-md ()
  "Open STATE.md for the nearest aDNA vault."
  (interactive)
  (let ((state (concat (adna/vault-root) "STATE.md")))
    (when (file-readable-p state)
      (find-file state))))

(spacemacs/declare-prefix "axs" "state")
(spacemacs/set-leader-keys "axsf" #'adna/open-state-md)
```

---

## MCP tool registration via claude-code-ide

`claude-code-ide.el` exposes Emacs capabilities to Claude Code via MCP. Agents can
register custom Emacs functions as MCP tools, making them available to Claude during
any session:

```elisp
;; Register a custom function as an MCP tool
(claude-code-ide-make-tool
 :function #'my-function
 :name "my_tool_name"
 :description "What this tool does, in plain language for Claude"
 :args '((:name "param_name"
          :type string
          :description "What this parameter means")))
```

### Built-in MCP tools (via `claude-code-ide-emacs-tools-setup`)

| Tool name | Function | Description |
|-----------|---------|-------------|
| `xref_find_references` | `xref-find-references` | Find all references to symbol |
| `xref_find_definitions` | `xref-find-definitions` | Go to definition |
| `imenu_list` | `imenu-index-function` | List all symbols in current file |
| `treesit_parse` | tree-sitter API | Parse AST of current buffer |
| `project_info` | projectile/project.el | Current project root and type |

### Agent-authored tool pattern

```elisp
;; Pattern: expose an aDNA-specific capability to Claude as an MCP tool
(claude-code-ide-make-tool
 :function (lambda (vault-path)
             (let ((state (expand-file-name "STATE.md" vault-path)))
               (with-temp-buffer
                 (insert-file-contents state)
                 (buffer-string))))
 :name "read_state_md"
 :description "Read STATE.md from an aDNA vault path, returning the current operational snapshot"
 :args '((:name "vault_path" :type string :description "Absolute path to the aDNA vault")))
```

---

## Graph awareness — updating after extension

The `what/standard/index/graph.json` represents the vault's capability graph. After
adding any new command, tool, or skill:

```
M-x adna-index-project
```

This re-emits `graph.json` with updated nodes. The graph is used by:
- `skill_adna_index` to render the full capability map
- Future federation tools to understand what this vault exposes
- Context recipes that enumerate available agent capabilities

Agents should include graph re-indexing in their SITREP when they add commands.

---

## Discovery — agent reading the command tree

An agent dropped into Spacemacs.aDNA can discover the current command tree by:

1. **Reading this file** — canonical description of the designed hierarchy
2. **Reading ADR-013** — the keybinding refactor decision with full rationale
3. **Querying which-key**: In a live Spacemacs session, `SPC a` then wait 0.4s to see
   all current `SPC a` bindings rendered by which-key
4. **Reading `what/standard/layers/adna/keybindings.el`** — programmatic source of truth
   for the `adna` layer's bindings
5. **Reading `what/standard/layers/claude-code-ide/keybindings.el`** — `SPC c` bindings

---

## Extension discipline

| Action | Scope | Mechanism |
|--------|-------|-----------|
| Add command for this session | local/ | `operator.private.el` |
| Add command to standard | ADR + skill_layer_promote | Sanitization + operator gate |
| Expose function to Claude via MCP | Any | `claude-code-ide-make-tool` |
| Remove a command | Any | Edit the binding file; re-run health-check |

**Rule**: Agents propose, operators gate. A new binding in `standard/` requires an ADR.
A binding in `local/` is private and cannot reach the commons without promotion.

---

## References

- ADR-013: Keybinding refactor (`what/decisions/adr/adr_013_keybinding_refactor.md`)
- ADR-019: claude-code-ide layer (`what/decisions/adr/adr_019_claude_code_ide_layer.md`)
- `adna` layer keybindings: `what/standard/layers/adna/keybindings.el`
- `claude-code-ide` layer: `what/standard/layers/claude-code-ide/`
- Mission: `mission_sl_p4_10_agent_command_tree`
