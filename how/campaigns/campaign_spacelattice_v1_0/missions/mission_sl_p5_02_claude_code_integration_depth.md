---
type: mission
mission_id: mission_sl_p5_02_claude_code_integration_depth
campaign: campaign_spacelattice_v1_0
campaign_phase: 5
campaign_mission_number: 2
status: completed
mission_class: implementation
created: 2026-05-10
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [mission, completed, spacemacs, v1_0, p5, claude_code, integration, multi_session, adr_036]
blocked_by: [mission_sl_p5_01_agentic_layout_system]
---

# Mission — P5-02: Claude Code Integration Depth

**Phase**: P5 — Polish + v1.0 release.
**Class**: implementation.

## Objective

Deepen the Claude Code integration beyond the skeleton layer delivered in P4-09. Verify and document the existing `adna/funcs.el` Claude Code implementations, wire multi-project session management to the layout system, document the window layout contract, and produce an operator acceptance test runbook. The goal: the operator can open Spacemacs, activate the agentic layout, start a Claude Code session, and have a coherent two-pane workflow — code on the left, Claude on the right — without manual window manipulation.

**Note (P5-00 gap register, GAP-02)**: The four spawn functions (`adna/spawn-claude-code`, `spawn-claude-plan`, `spawn-claude-loop`, `spawn-claude-review`) are already implemented in `adna/funcs.el` — they are NOT stubs. The real scope here is window contract documentation + `adna/claude-project-switch` addition + `adna-bridge.md` update + acceptance runbook.

## Deliverables

### 1. `adna/funcs.el` — verify Claude Code implementations + add project-switch
The four spawn functions are implemented. Verify each against the live `claude-code-ide.el` API:

**`adna/spawn-claude-code`** — verify it starts a Claude Code session in the vault root via vterm. Document any parameter gaps vs. `claude-code-ide` API.

**`adna/spawn-claude-plan`** — verify `--plan` flag is accepted by `claude` CLI (confirm actual flag name).

**`adna/spawn-claude-loop`** — verify `--loop` flag and task prompt flow.

**`adna/spawn-claude-review`** — verify file path quoting and `/review` command syntax.

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

- `what/standard/layers/adna/funcs.el` (spawn functions — verify, not fill)
- `what/standard/layers/claude-code-ide/packages.el` (window config)
- `what/standard/adna-bridge.md` (needs update)
- `what/context/agent_command_tree.md` (MCP tool pattern)
- ADR-019 (claude-code-ide layer decision)
- ADR-033 (P4-09 layer completion)
- `mission_sl_p5_01_agentic_layout_system` (layout system — prerequisite)

## AAR
- **Worked**: Window contract (80-col right, treemacs left, edit center) documents cleanly in ADR-036; `adna/claude-project-switch` slots naturally into both `SPC a ,` and `SPC a x p`.
- **Didn't**: `SPC c c` binding conflict between adna and claude-code-ide layers was not caught in P4-09 — claude-code-ide wins via `with-eval-after-load`, adna binding silently loses; documented not fixed (correct behavior).
- **Finding**: `adna/layout-agentic-default` was calling the vterm fallback (`adna/spawn-claude-code`) instead of the live `claude-code-ide` — a silent regression from P4-09 that this mission corrected.
- **Change**: Future layer additions that touch the `SPC c` prefix should be cross-checked against adna/keybindings.el binding table at PR time.
- **Follow-up**: P5-04 (shared command tree) can reference `SPC a x p` as the canonical extension pattern; `adna/extensions-menu` now has a real example entry.
