---
type: adr
adr_number: 035
title: "Agentic layout system — named window configurations via SPC a l"
status: accepted
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, p5, layout, keybindings, treemacs, claude_code]
---

# ADR-035: Agentic Layout System — Named Window Configurations via `SPC a l`

## Status

Accepted

## Context

P5-00 gap analysis (GAP-01) confirmed that `adna/layouts.el` does not exist. The operator must manually arrange windows each Spacemacs session to achieve the battle-station configuration (treemacs left, Claude Code terminal bottom, edit area center-right). This is a must-fix gap for v1.0 per the p5_gap_register.

The layout system was deferred from P4 (see `idea_agentic_layout_system.md` in backlog and `mission_sl_p4_layout_intelligence.md` stub). P5-01 is the assigned mission.

A secondary issue: `SPC a l` was already wired to `adna/lp-menu` (Lattice Protocol submenu) inside the `adna/menu` root transient. P5-01 gates on `SPC a l a` activating the agentic layout, which conflicts. This keybinding shuffle must be resolved.

## Decision

**1. New file `layouts.el`** in `what/standard/layers/adna/`. Defines 4 named layout functions:
- `adna/layout-agentic-default` — primary battle-station: treemacs left + edit area center-right + claude vterm bottom-right
- `adna/layout-vault-navigation` — treemacs + content + imenu-list three-pane
- `adna/layout-campaign-planning` — campaign doc + mission file + STATE.md three-pane
- `adna/layout-code-review` — magit + source + vterm

Each function is interactive (`(interactive)`), uses `delete-other-windows` for a clean slate, then opens the relevant buffers/modes via native Emacs split + mode calls. No Spacemacs layout registry dependency — functions work in any Emacs 28+ session.

**2. New `adna/layouts-menu` transient** in `keybindings.el` with keys a/v/c/r for the 4 layouts.

**3. Keybinding shuffle**: Move LP submenu from key `l` → `p` inside `adna/menu` root transient. The standalone `SPC o l` binding for `adna/lp-menu` is unchanged — operators who use that shortcut are unaffected. Assign `SPC a l` → `adna/layouts-menu`.

## Consequences

### Positive
- Named layouts eliminate manual window arrangement at session start
- `SPC a l a` is the primary battle-station activation — one key, reproducible state
- `SPC o l` LP shortcut is preserved; no regression for existing users
- `layouts.el` is a standard adna layer file — covered by existing CI byte-compile glob
- Four layouts cover the dominant use cases (agentic coding, vault nav, campaign planning, code review)

### Negative
- Operators who had `SPC a l` memorized as LP shortcut must update muscle memory (mitigation: `SPC o l` still works)

### Neutral
- `adna/layout-campaign-planning` finds STATE.md via `adna/--find-state-md` helper (new function in funcs.el); other layouts use standard Emacs primitives
- Operator boot check (live Emacs) deferred to P5-01 Session 2 — batch byte-compile in Session 1 is the automated gate
