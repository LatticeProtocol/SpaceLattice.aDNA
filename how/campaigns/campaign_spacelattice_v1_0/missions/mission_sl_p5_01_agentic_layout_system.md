---
type: mission
mission_id: mission_sl_p5_01_agentic_layout_system
campaign: campaign_spacelattice_v1_0
campaign_phase: 5
campaign_mission_number: 1
status: completed
mission_class: implementation
created: 2026-05-10
updated: 2026-05-11
completed: 2026-05-11
last_edited_by: agent_stanley
tags: [mission, planned, spacemacs, v1_0, p5, layout, treemacs, claude_code, agentic_layout, adr_035]
blocked_by: []
---

# Mission — P5-01: Agentic Layout System

**Phase**: P5 — Polish + v1.0 release.
**Class**: implementation.

## Objective

Implement the agentic layout system for Spacemacs.aDNA: named window configurations accessible via `SPC a l`, with a default "agentic" layout that places the file tree (treemacs) on the left, Claude Code terminal on the left-center, and the file review/edit area on the right. This realizes the user's primary interaction model: human and agent work side-by-side, with the command tree as the coordination layer.

Folds in the deferred `mission_sl_p4_layout_intelligence.md` (P4 backlog).

## Deliverables

### 1. `what/standard/layers/adna/layouts.el`
New file defining 4 named layouts:

**`adna/layout-agentic-default`** — the primary battle-station layout:
```
┌──────────┬──────────────────────────────┐
│ treemacs │  file buffer (edit / review) │
│  (25 col)│                              │
│          ├──────────────────────────────┤
│          │  claude-code terminal        │
│          │  (eat/vterm, SPC c s)        │
└──────────┴──────────────────────────────┘
```
Note: `claude-code-ide-window-side` is already set to `'right` (packages.el). This layout ensures treemacs is open on the far-left and the bottom area is reserved for the Claude terminal, so the main edit area stays center-right. Verify coordination with `claude-code-ide-window-width 100` — may need reduction to ~80 with treemacs present.

**`adna/layout-vault-navigation`** — aDNA vault exploration:
```
┌──────────┬──────────────┬──────────────┐
│ treemacs │ content buf  │  imenu-list  │
│          │              │              │
└──────────┴──────────────┴──────────────┘
```

**`adna/layout-campaign-planning`** — campaign/mission editing:
```
┌──────────────┬──────────────┬──────────┐
│ campaign doc │ mission file │ STATE.md │
└──────────────┴──────────────┴──────────┘
```
Activated via `adna/layout-campaign-planning` which opens STATE.md + most recent active mission side-by-side.

**`adna/layout-code-review`** — code review:
```
┌──────────────────┬──────────────┐
│ magit diff / log │  source file │
├──────────────────┴──────────────┤
│  vterm                          │
└─────────────────────────────────┘
```

Implementation pattern: each layout function uses `delete-other-windows`, opens the right buffers/modes via `treemacs` / `vterm` / `find-file`, then splits with `split-window-right` / `split-window-below`. Use `window-configuration-to-register` for save/restore if Spacemacs's `spacemacs/custom-layout` macro is unavailable in batch.

### 2. `adna/keybindings.el` additions
- Add `("l" "Layouts →" adna/layouts-menu)` to parent `adna/menu` transient
- New `adna/layouts-menu` transient:
  ```
  (a) Agentic default    adna/layout-agentic-default
  (v) Vault navigation   adna/layout-vault-navigation
  (c) Campaign planning  adna/layout-campaign-planning
  (r) Code review        adna/layout-code-review
  ```
- Wire `SPC a l` via `spacemacs/declare-prefix "al" "layouts"` + `spacemacs/set-leader-keys "al" #'adna/layouts-menu`
- ADR-035 required

### 3. `dotfile.spacemacs.tmpl` — default layout hook
Add to `dotspacemacs/user-config` section `§P5-01`:
```elisp
;; §P5-01 — Agentic default layout on startup (opt-in via what/local/)
;; Uncomment to activate agentic layout automatically at boot:
;; (add-hook 'emacs-startup-hook #'adna/layout-agentic-default)
```
The opt-in stays commented in standard; operators uncomment in `what/local/operator.private.el`.

### 4. `what/context/spacemacs/agentic_layout_guide.md`
New context doc:
- Layout inventory table: name / keybinding / use-case / window configuration diagram
- How `claude-code-ide-window-side 'right` interacts with each layout
- Treemacs width recommendation with Claude Code active
- Multi-project session switching: `SPC a l a` → `SPC c l` → select session
- Composition rules: which layouts can be stacked / what to avoid

### 5. ADR-035
`what/decisions/adr/adr_035_agentic_layout_system.md`:
- Problem: no named layouts; operator must manually arrange windows each session
- Decision: 4 named layouts in `layouts.el`; `SPC a l` transient; default layout opt-in hook
- Coordinates with `claude-code-ide-window-side 'right` (ADR-019/036)
- Consequence: `layouts.el` is a new file in the `adna` layer; byte-compile + health check must cover it

### 6. Health check + CI
- `skill_health_check.md` — add note: "Check I: `layouts.el` byte-compiles and defines `adna/layout-agentic-default`"
- CI glob `what/standard/layers/**/*.el` already picks up `layouts.el` — verify

### 7. Live operator validation (deferred to operator boot)
- `SPC a l a` activates agentic-default layout
- Treemacs opens left, Claude Code terminal opens bottom, file buffer fills center-right
- `SPC a l v` switches to vault-navigation
- All 4 layouts cycle cleanly without errors

## Estimated effort

2 sessions (session 1: layouts.el + keybindings + ADR; session 2: context doc + validation + health check update).

## Dependencies

P5-00 (gap register confirms layout is must-have for v1.0).

## Reference

- `how/backlog/idea_agentic_layout_system.md` (3-layer design, 8 layouts — 4 selected for standard)
- `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_p4_layout_intelligence.md` (deferred P4 mission — fold into this)
- `what/standard/layers/adna/keybindings.el` (parent `adna/menu` — add `SPC a l` here)
- `what/standard/layers/claude-code-ide/packages.el` (window-side + width config)
- ADR-019, ADR-013 (keybinding and Claude Code layer decisions)

## Session Progress

### Session 1 — 2026-05-11 (agent_stanley) ✓ COMPLETE

**Objectives**:
- [x] ADR-035 drafted and accepted (`what/decisions/adr/adr_035_agentic_layout_system.md`)
- [x] `layouts.el` created with 4 named layout functions + `adna/--find-state-md` helper
- [x] `keybindings.el` updated: `adna/layouts-menu` transient, `SPC a l` wired, LP key `l→p`

**Keybinding resolution (ADR-035)**: `SPC a l` was formerly wired to `adna/lp-menu`. Moved LP to key `p` in root menu; `SPC o l` standalone unchanged. `SPC a l` now routes to `adna/layouts-menu`.

**Deferred to Session 2**:
- `what/context/spacemacs/agentic_layout_guide.md` — layout inventory + coordination notes
- `dotfile.spacemacs.tmpl` `§P5-01` startup hook block (commented opt-in)
- `skill_health_check.md` Check I expansion (layouts.el byte-compile + function definition check)
- CI glob verification (`what/standard/layers/**/*.el` covers layouts.el)
- Operator boot check: `SPC a l a` live Emacs validation

### Session 2 — 2026-05-11 (agent_stanley) ✓ COMPLETE

**Objectives**:
- [x] `what/context/spacemacs/agentic_layout_guide.md` created — layout inventory + window diagrams + claude-code-ide coordination + multi-project switching + composition rules + startup opt-in
- [x] `dotfile.spacemacs.tmpl` §P5-01 startup hook block added (commented opt-in, references `what/local/operator.private.el`)
- [x] `skill_health_check.md` Check I added — `layouts.el` byte-compile + `adna/layout-agentic-default` symbol check; exit code 80; SKIP branch for emacs-absent environments
- [x] CI glob verified: `what/standard/layers/**/*.el` already covers `layouts.el` — no ci.yml change needed
- [x] AAR filed: `how/missions/artifacts/aar_mission_sl_p5_01_agentic_layout_system.md`

**Operator boot check (deferred)**: Run `SPC a l a` in running Spacemacs to confirm layout activates. If Claude Code panel crowds edit area, set `(setq claude-code-ide-window-width 80)` in `what/local/operator.private.el`.

**Mission status: COMPLETE** — all 6 deliverables landed across 2 sessions.
