---
type: mission
mission_id: mission_sl_p5_02_claude_code_integration_depth
campaign: campaign_spacelattice_v1_0
campaign_phase: 5
campaign_mission_number: 2
status: planned
mission_class: implementation
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
tags: [mission, planned, spacemacs, v1_0, p5, claude_code, integration, multi_session, adr_036]
blocked_by: [mission_sl_p5_01_agentic_layout_system]
---

# Mission — P5-02: Claude Code Integration Depth

**Phase**: P5 — Polish + v1.0 release.
**Class**: implementation.

## Objective

Deepen the Claude Code integration beyond the skeleton layer delivered in P4-09. Fill in the stub functions in `adna/funcs.el`, wire multi-project session management to the layout system, verify window configuration coordination, and produce a documented operator acceptance test runbook. The goal: the operator can open Spacemacs, activate the agentic layout, start a Claude Code session, and have a coherent two-pane workflow — code on the left, Claude on the right — without manual window manipulation.

## Deliverables

### 1. `adna/funcs.el` — fill Claude Code stubs
Current stubs (4 functions) call `claude-code-ide` with simple `(claude-code-ide)` invocations. Review each:

**`adna/spawn-claude-code`** → wire to `claude-code-ide` (start for current project-root). If already correct, document it as non-stub.

**`adna/spawn-claude-plan`** → `claude-code-ide` with `--plan` flag or equivalent transient arg (check upstream claude-code-ide.el for plan-mode API).

**`adna/spawn-claude-loop`** → `claude-code-ide` with `--loop` flag or equivalent.

**`adna/spawn-claude-review`** → `claude-code-ide` with file path for current buffer; review workflow.

New function **`adna/claude-project-switch`**:
```elisp
(defun adna/claude-project-switch ()
  "Activate agentic layout then list Claude Code sessions for switching."
  (interactive)
  (when (fboundp 'adna/layout-agentic-default)
    (adna/layout-agentic-default))
  (call-interactively #'claude-code-ide-list-sessions))
```
Bind to `SPC c l` (replacing simple session list) and `SPC a x p` (as an agent extension example).

### 2. Window coordination audit
- `claude-code-ide-window-side 'right` + `claude-code-ide-window-width 100` currently set in packages.el
- With treemacs open (~25 cols), a 100-col Claude window may overflow on a standard display
- Recommendation: adjust `claude-code-ide-window-width` to 80 in `spacemacs-latticeprotocol/config.el` or add a conditional in `adna/layout-agentic-default` that sets width before opening Claude
- Document the decision and any config change in ADR-036

### 3. `adna-bridge.md` update
`what/standard/adna-bridge.md` was written at Phase 4 spec time (pre-P4-09). Update to reflect:
- `claude-code-ide` layer is live (P4-09)
- MCP tools registered via `claude-code-ide-emacs-tools-setup` (already in packages.el)
- Custom MCP tool registration pattern documented in `agent_command_tree.md`
- Correct `SPC c` keybinding table (updated from P4-09/ADR-033)

### 4. Multi-project session management documentation
`what/context/spacemacs/multi_project_claude.md` (new):
- How to have N Claude Code sessions for N projects open simultaneously
- Session naming and discovery via `claude-code-ide-list-sessions`
- Layout switching between projects: `SPC a l a` → `SPC c l`
- Closing / archiving sessions
- Project-scoped system prompts via `claude-code-ide-adna-system-prompt`

### 5. `how/standard/runbooks/claude_code_acceptance_test.md`
Operator acceptance test runbook (supplements batch validation from P5-03):
```
Step 1: Boot Spacemacs — verify adna layer loaded (SPC a opens transient)
Step 2: SPC a l a — agentic-default layout activates (treemacs + empty right)
Step 3: SPC c s — Claude Code session starts in project dir; terminal appears right side
Step 4: Ask Claude to open a file — verify file opens in left buffer area
Step 5: SPC c t — toggle Claude window; verify it hides/shows
Step 6: SPC c l — session list appears; select different project
Step 7: SPC a x — agent extensions transient opens; placeholder visible
Step 8: SPC a h — MANIFEST.md opens; wikilink follows correctly
```

### 6. ADR-036
`what/decisions/adr/adr_036_claude_code_window_integration.md`:
- Problem: `claude-code-ide-window-width 100` may conflict with treemacs (P5-01) on standard displays
- Decision: adjust width to 80; add layout coordination contract between layouts.el and claude-code-ide packages.el
- Window contract: treemacs owns far-left; Claude Code terminal owns right; center = file edit

## Estimated effort

1 session.

## Dependencies

P5-01 (agentic layout system must be live so window coordination can be verified and documented).

## Reference

- `what/standard/layers/adna/funcs.el` (stubs to fill)
- `what/standard/layers/claude-code-ide/packages.el` (window config)
- `what/standard/adna-bridge.md` (needs update)
- `what/context/agent_command_tree.md` (MCP tool pattern)
- ADR-019 (claude-code-ide layer decision)
- ADR-033 (P4-09 layer completion)
- `mission_sl_p5_01_agentic_layout_system` (layout system — prerequisite)
