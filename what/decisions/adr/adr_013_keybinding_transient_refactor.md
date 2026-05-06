---
type: adr
adr_id: "013"
adr_kind: standard_config
title: "Keybinding refactor: Transient hierarchy for SPC a, LP prefix SPC o l, Claude Code SPC c c"
status: accepted
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, keybindings, transient, p3]
---

# ADR-013: Keybinding Refactor — Transient Hierarchy, LP Prefix, Claude Code Sub-Commands

## Status

Accepted

## Context

`what/standard/layers/adna/keybindings.el` used flat `spacemacs/set-leader-keys` bindings under `SPC a`. This approach works but provides no visual grouping — the which-key popup renders a flat undifferentiated list. As the command surface grows (LP stubs, Claude Code variants), a flat list becomes hard to scan.

The Transient library (Emacs 28+ built-in, backport available) provides popup menus with grouped labeled columns, which-key interoperability, and recursive sub-menus. It is used by Magit and Claude Code (`/plan`, `/loop`) internally, making it a natural fit for SpaceLattice's battle-station context.

User-in-the-loop consultation (P3 pre-flight session 2026-05-06) selected the Transient refactor explicitly ("for decision 7 do the rebuild").

Simultaneously, P3 requires namespace reservation for Lattice Protocol CLI bindings (`SPC o l`) and Claude Code variants (plan mode, loop mode, file review) so that P4 fork branding has a populated layer to fill in.

## Decision

1. **Replace flat keybindings** under `SPC a` with a two-level Transient hierarchy:

   `adna/menu` (SPC a) — root menu, four groups:
   - Navigate: m (Manifest), c (CLAUDE.md), s (STATE.md), r (Triad root)
   - Skills & Graph: k (Run skill), i (Index vault), g (Graph JSON), h (Health check)
   - Links & Sessions: w (Follow wikilink), n (Session note), o (Obsidian)
   - LP & Claude →: l (adna/lp-menu), , (adna/claude-menu)

   `adna/lp-menu` (SPC a l / SPC o l) — LP sub-menu:
   - Run: r (Run lattice), j (Job status)
   - Publish & Index: p (Publish lattice), f (Federation graph)
   - Browse: m (Marketplace in eww)
   - < (Back to adna/menu)

   `adna/claude-menu` (SPC a , / SPC c c) — Claude Code sub-menu:
   - Launch: c (Interactive), p (Plan mode), l (Loop mode)
   - Review: r (Review file)
   - < (Back to adna/menu)

2. **Add LP stub functions** to `funcs.el`:
   - `adna/--spawn-vterm-command` — shared vterm/eshell dispatch helper
   - `adna/lp-run-lattice`, `adna/lp-job-status`, `adna/lp-publish`, `adna/lp-open-marketplace`, `adna/lp-federation-graph`

3. **Add Claude Code variant functions** to `funcs.el`:
   - `adna/spawn-claude-plan` — `claude --plan`
   - `adna/spawn-claude-loop` — `claude --loop <task>` (prompts for task)
   - `adna/spawn-claude-review` — `claude /review <file>`

4. **Wire leader keys**:
   - `SPC a` → `adna/menu` (Transient root)
   - `SPC o l` → `adna/lp-menu` (LP standalone entry point)
   - `SPC c c` → `adna/claude-menu` (Claude Code standalone entry point)

## Consequences

### Positive
- Grouped Transient popup replaces undifferentiated which-key flat list; new commands are discoverable without memorization
- Muscle memory for existing `SPC a m`, `SPC a s` etc. still works — Transient receives the key after `SPC a` triggers it
- LP namespace (`SPC o l`) is reserved at P3; P4 LP layer can fill stub implementations without keybinding conflicts
- Claude Code variants (plan/loop/review) are immediately available; stub implementations are vterm-dispatched and can be replaced in P4 without keybinding changes
- `<` back-navigation keeps the menu system explorable without escaping to the buffer

### Negative
- Requires `transient` package; on Emacs 27, must be installed separately (Emacs 28+ built-in)
- LP stubs dispatch via `latlab` CLI — will error if `latlab` is not on PATH (acceptable for P3; documented as stub)

### Neutral
- `adna/claude-menu` and `adna/lp-menu` are accessible both from `adna/menu` sub-entries and via their own `SPC` bindings — two entry points, same Transient prefix

## References

- `what/standard/layers/adna/keybindings.el`
- `what/standard/layers/adna/funcs.el`
- ADR-012 (presentation layer — companion P3 ADR)
- P3 pre-flight session 2026-05-06
