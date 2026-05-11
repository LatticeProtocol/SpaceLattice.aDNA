---
type: mission
mission_id: mission_sl_p4_09_claude_code_ide_layer
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 9
status: completed
mission_class: implementation
created: 2026-05-07
updated: 2026-05-10
last_edited_by: agent_stanley
tags: [mission, completed, spacemacs, v1_0, p4, claude_code_ide, mcp, layer, adr_019, adr_033]
blocked_by: []
---

# Mission — P4-09: Claude Code IDE Layer

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Complete the `claude-code-ide` Spacemacs layer seeded during the 2026-05-07 research integration session. The layer skeleton (`packages.el`, `config.el`, `keybindings.el`, `README.org`) was created at `what/standard/layers/claude-code-ide/`, and ADR-019 was filed. This mission wires the layer into the deployment pipeline, validates it in a live Spacemacs session, and delivers the operator's first fully MCP-bridged Claude Code IDE experience.

The layer wraps `claude-code-ide.el` (https://github.com/manzaltu/claude-code-ide.el) — a bidirectional MCP bridge exposing buffer context, diagnostics, tree-sitter AST, and LSP navigation to Claude Code sessions.

## Deliverables

- `how/standard/skills/skill_install.md` updated — add symlink step for `claude-code-ide` layer alongside `adna` (Step 3.6 or similar)
- `how/standard/skills/skill_deploy.md` updated — add claude-code-ide layer to deploy checklist
- `skill_health_check` run: emacs --batch layer load with claude-code-ide in layer list → exit 0
- Live Spacemacs validation:
  - `SPC c c` → `claude-code-ide-menu` transient visible in which-key
  - `SPC c s` → Claude Code session opens in right-side window (100 cols)
  - MCP tools active: `claude-code-ide-emacs-tools-setup` called (verify via `*claude-code-ide-mcp*` buffer or similar)
  - Diagnostics backend: flycheck errors visible in a Claude session
- Operator acceptance test: open a project file with flycheck errors → start Claude session → verify Claude has diagnostic context
- Any follow-up ADR if config adjustments needed during live test
- `deploy/<hostname>/<utc>_p4_09.md` receipt (layer validation sub-receipt)
- AAR

## Estimated effort

1-2 sessions.

## Dependencies

P4-01 closed (fork cloned locally — claude-code-ide needs Claude Code CLI on PATH and may need fork-specific config). Can be unblocked from this dependency if operator wants to test standalone before fork work.

## Reference

- `what/standard/layers/claude-code-ide/` (complete: packages, config, keybindings, README, layers)
- ADR-019: `what/decisions/adr/adr_019_claude_code_ide_layer.md`
- ADR-033: `what/decisions/adr/adr_033_claude_code_ide_layer_complete.md` (layer completion)
- ADR-013: `what/decisions/adr/adr_013_keybinding_transient_refactor.md` (SPC c c origin)
- `what/context/agent_command_tree.md` (MCP tool registration patterns)
- Package: https://github.com/manzaltu/claude-code-ide.el

## AAR (lightweight)

- **Worked**: Layer skeleton was already solid per ADR-019; only `layers.el` was missing. Pattern from `adna/layers.el` applied directly. `skill_deploy.md` drift fixed in same pass.
- **Didn't**: Live acceptance test (SPC c c, MCP buffer, flycheck integration) deferred — no live Spacemacs session on current agent; layer is wired and ready for operator validation on next boot.
- **Finding**: A 5-file layer convention (packages/config/keybindings/README/layers) should be documented as the minimum layer contract in `LAYER_CONTRACT.md` to prevent skeleton drift on future layers.
- **Change**: `LAYER_CONTRACT.md` update (minimum 5-file layer) filed as P4-10 pre-work or backlog idea.
- **Follow-up**: P4-10 (agent command tree — `SPC a x` transient + `skill_adna_index` update) is next; no blockers.

Full AAR: `missions/artifacts/aar_sl_p4_09.md`
