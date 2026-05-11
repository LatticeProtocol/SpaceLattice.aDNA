---
type: decision
adr_id: ADR-036
status: accepted
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [adr, accepted, claude_code, window_contract, layouts, treemacs, p5_02]
supersedes: []
superseded_by: []
---

# ADR-036 — Claude Code window integration contract

## Status

**Accepted** — 2026-05-11

## Context

P5-01 delivered the agentic layout system (`layouts.el`, `SPC a l`). The canonical `adna/layout-agentic-default` layout opens treemacs on the far-left, a main edit area, and a Claude Code terminal on the right. With `claude-code-ide-window-width` at 100 (the P4-09 default), the Claude terminal overflows on standard laptop displays when treemacs is also open:

- treemacs: ~35 cols
- Claude terminal: 100 cols
- Available frame width: typically 160–180 cols on a 1440px display at 14pt font
- Remaining edit area: 25–45 cols — too narrow for comfortable editing

Additionally, the `adna/layout-agentic-default` function called `adna/spawn-claude-code` (the vterm fallback from pre-P4-09) rather than `claude-code-ide` (the live MCP-connected backend from P4-09).

A formal window contract is needed so that layout functions, the claude-code-ide layer, and future third-party layers can reason about zone ownership without stepping on each other.

## Decision

### 1. Window contract

Three permanent zones in every agentic layout:

| Zone | Owner | Canonical width |
|------|-------|----------------|
| Far-left | treemacs (or equivalent file tree) | ~35 cols |
| Center | file edit area | frame width − 35 − 80 |
| Far-right | Claude Code terminal | 80 cols |

**Minimum comfortable frame width**: 160 columns. Operators on narrow displays should close treemacs (treemacs own toggle: `SPC p t`) before opening the Claude terminal.

### 2. Window width: 100 → 80

`claude-code-ide-window-width` is adjusted from 100 to 80 in `what/standard/layers/claude-code-ide/packages.el`. This leaves a 45-col edit area on a 160-col frame — workable for code review and mission editing. Operators who prefer more Claude context can override in `what/local/operator.private.el`:

```elisp
(setq claude-code-ide-window-width 100)
```

### 3. Layout function update

`adna/layout-agentic-default` in `layouts.el` now calls `claude-code-ide` (with `fboundp` guard) instead of `adna/spawn-claude-code`. Fallback to `adna/spawn-claude-code` remains for environments where the `claude-code-ide` layer is not loaded.

### 4. `adna/claude-project-switch`

New function in `funcs.el` (P5-02). Activates `adna/layout-agentic-default`, then calls `claude-code-ide-list-sessions` — the single operator gesture for multi-project context switching. Bound at `SPC a , s` (claude-menu) and `SPC a x p` (extensions menu, as a canonical extension example).

### 5. `SPC c c` ownership

`SPC c c` is owned by the `claude-code-ide` layer (`claude-code-ide-menu`). The `adna` layer sets `SPC c c` → `adna/claude-menu` at layer init time, but the `claude-code-ide` layer overrides it inside `(with-eval-after-load 'claude-code-ide ...)`. The adna spawn functions remain accessible via `SPC a ,` (the claude sub-menu inside the `SPC a` transient). This is the intended final state — no collision resolution needed.

## Consequences

- **Edit area is at least 45 cols wide** on a 160-col frame with treemacs open — sufficient for mission file editing.
- **No operator action required** on existing installs; width is set in packages.el init block.
- **`adna/layout-agentic-default` now starts a live MCP session** (when `claude-code-ide` is loaded) rather than a plain vterm shell — operators get diagnostics and project context from first keystroke.
- **`SPC a x p`** provides a concrete example for the `SPC a x` agent-extension pattern used in P5-04 (shared command tree).

## Verification

- `skill_health_check` Check E: `adna/claude-project-switch` appears in the fbound check list
- `claude_code_acceptance_test.md` Steps 3, 6, 7: layout + toggle + project-switch validated live
- `(describe-variable 'claude-code-ide-window-width)` → `80` after load

## References

- ADR-013: `SPC c` prefix established
- ADR-019: claude-code-ide layer decision (P4-09)
- ADR-033: P4-09 layer completion ratification
- ADR-035: agentic layout system (P5-01)
- `what/context/spacemacs/multi_project_claude.md`
- `how/standard/runbooks/claude_code_acceptance_test.md`
