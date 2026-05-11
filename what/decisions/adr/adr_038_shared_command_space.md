---
type: adr
adr_id: adr_038
title: "Shared human-agent command space — scripts/ directory + adna/load-scripts auto-discovery"
status: accepted
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
supersedes: []
superseded_by: []
adr_kind: implementation
related_adrs: [adr_013, adr_034]
tags: [adr, accepted, scripts, command_tree, mcp, auto_discovery, p5_04]
---

# ADR-038 — Shared Human-Agent Command Space

## Context

`SPC a x` was wired as a stub transient (ADR-034, P4-10). It opens correctly but has no commands registered under it. The original design intent (ADR-013, 2026-05-06) was a bidirectional command space where:

- Operators write elisp scripts → auto-appear in `SPC a x`
- Agents propose commands → operator approves → promoted to standard
- Scripts can be exposed to Claude Code as MCP tools

P5-00 gap register identified GAP-04: no `scripts/` directory, no auto-discovery mechanism.

## Decision

### 1. `scripts/` directory in the `adna` layer

`what/standard/layers/adna/scripts/` is a new optional subdirectory for elisp scripts that:
- Add `SPC a x` sub-commands
- Automate operator workflows
- Can be wrapped as MCP tools via `claude-code-ide-make-tool`

Three seed scripts are provided as standard (see deliverables). Operators may also maintain `what/local/scripts/` (gitignored) for private scripts that auto-load but never reach the commons without promotion.

### 2. `adna/load-scripts` auto-discovery

A new function `adna/load-scripts` in `funcs.el`:
- Discovers all `.el` files in `what/standard/layers/adna/scripts/` (standard scripts)
- Also loads `what/local/scripts/` if present (operator-private)
- Called via `spacemacs-post-user-config-hook` so it fires after all layers load

### 3. Seed scripts interface contract

Each script in `scripts/`:
- `(provide 'adna-<name>)` at bottom
- Defines one interactive command `adna/<name>`
- Registers under `SPC a x` via `spacemacs/set-leader-keys`

### 4. LAYER_CONTRACT extension

`LAYER_CONTRACT.md` gains Clause N: scripts in `what/standard/layers/adna/scripts/` are subject to the same sanitization rules as all standard layer files (§ 4). Scripts in `what/local/scripts/` are gitignored and may contain operator-specific paths.

## Promotion path

```
draft in what/local/scripts/   →   appears in SPC a x immediately (auto-loaded)
         ↓ propose via SITREP
ADR authored + operator approves
         ↓ skill_layer_promote (sanitization scan)
what/standard/layers/adna/scripts/   →   reaches commons
```

## MCP bridge

Any `adna/<name>` function can be registered as an MCP tool:
```elisp
(claude-code-ide-make-tool
 :function #'adna/show-sitrep
 :name "read_vault_state"
 :description "Open STATE.md and latest active session side-by-side")
```
This replaces token-heavy file-read roundtrips with direct Emacs function calls.

## Consequences

- `adna/load-scripts` adds startup cost proportional to script count (negligible for typical use)
- The `scripts/` pattern is now available to any future LP layer (not just adna)
- `SPC a x` becomes a live, growable command space instead of a stub
- Operators can try private scripts in `what/local/scripts/` without ADR overhead
- Promotion via `skill_layer_promote` keeps the standard clean (sanitization-scanned)

## Operator approval

Stanley — 2026-05-11
