---
type: context
title: "Shared human-agent command space — SPC a x and the scripts/ pattern"
status: active
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [context, command_tree, scripts, spc_a_x, mcp, adna, shared, bidirectional]
---

# Shared Human-Agent Command Space

`SPC a x` is not a menu. It is a **shared workspace** — a bidirectional channel where
human operators and agents converge on the same vocabulary of vault-specific actions.

This document explains the pattern, the flow, and the token-economy rationale.

---

## The pattern

Commands available under `SPC a x` are auto-discovered from two directories:

```
what/standard/layers/adna/scripts/   ← standard scripts (shared, ADR-gated)
what/local/scripts/                  ← operator-private scripts (gitignored)
```

At Spacemacs startup, `adna/load-scripts` (wired in `config.el` via
`spacemacs-post-user-config-hook`) loads all `.el` files from both directories.
Each script registers its command under `SPC a x`. The menu self-populates.

---

## Bidirectional flow

### Human → SPC a x

1. Operator writes an elisp file in `what/local/scripts/`
2. Spacemacs reloads (or operator evaluates the file manually)
3. Command appears in `SPC a x` immediately
4. If the command is generally useful, propose via SITREP → ADR → `skill_layer_promote`

### Agent → SPC a x

1. Agent identifies a useful workflow (e.g., "agents always open STATE.md first")
2. Agent drafts the function and proposes it in the session SITREP
3. Operator approves → ADR filed → file promoted to `what/standard/layers/adna/scripts/`
4. Standard scripts reach all operators on next install/deploy

---

## Scripts vs. skills

Both scripts and skills encode reusable workflows. The distinction:

| | Skills (`how/standard/skills/`) | Scripts (`scripts/`) |
|-|----------------------------------|----------------------|
| **Audience** | Agent — markdown recipe | Human + agent — live elisp |
| **Invoked by** | Agent reading + executing | `SPC a x` or `M-x adna/<name>` |
| **Lives in** | `how/standard/skills/` | `scripts/` (or `what/local/scripts/`) |
| **Promotion** | Already standard (in how/) | `skill_layer_promote` for local → standard |
| **ADR required** | For standard/ changes | For standard/ promotion |

Skills are agent recipes. Scripts are live functions. Both live in the same governance
framework and reference the same vault context.

---

## MCP tool exposure

Any script function can be wrapped as an MCP tool, giving Claude Code direct access
to Emacs state without file-read token overhead:

```elisp
(when (fboundp 'claude-code-ide-make-tool)
  (claude-code-ide-make-tool
   :function #'adna/show-sitrep
   :name "read_vault_state"
   :description "Open STATE.md and latest active session file side-by-side"))
```

This replaces:
```
Agent: "Read STATE.md and the latest session file and tell me what's in progress"
→ 2 file-read tool calls + full content in context
```

With:
```
Claude Code calls MCP tool read_vault_state
→ Emacs opens the files; agent sees the rendered view directly
```

---

## Token economy

Scripts that replace repetitive file-read roundtrips save context window. Design guideline:

> If an action happens more than 3 times per session, consider scripting it.

Common candidates:
- Opening STATE.md + active session (done: `adna/show-sitrep`)
- Running health check (done: `adna/run-health-check`)
- Activating agentic layout + starting Claude (done: `adna/open-claude-with-layout`)
- Listing active missions + opening the current one
- Jumping to the campaign master file
- Running `adna-index-project` and showing node count

---

## Seed scripts (v1.0)

| Key | Function | What it does |
|-----|----------|-------------|
| `SPC a x s` | `adna/show-sitrep` | STATE.md + latest active session, side-by-side |
| `SPC a x h` | `adna/run-health-check` | Opens vterm, runs `validate_layers.py` |
| `SPC a x o` | `adna/open-claude-with-layout` | Activates agentic layout + starts Claude Code |

---

## References

- ADR-038: Decision to add `scripts/` pattern and `adna/load-scripts` auto-discovery
- ADR-034: Original `SPC a x` stub (P4-10)
- ADR-013: Keybinding philosophy (P3-pre-flight)
- `what/standard/layers/adna/scripts/README.md`: Script interface contract
- `what/context/agent_command_tree.md`: Full keybinding hierarchy
