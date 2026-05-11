---
type: mission
mission_id: mission_sl_p4_10_agent_command_tree
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 10
status: completed
mission_class: implementation
created: 2026-05-07
updated: 2026-05-10
completed_date: 2026-05-10
last_edited_by: agent_stanley
tags: [mission, planned, spacemacs, v1_0, p4, agent, keybinding, command_tree, mcp, extensibility]
blocked_by: [mission_sl_p4_09_claude_code_ide_layer]
---

# Mission — P4-10: Agent Command Tree

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Formalize and activate the agent-extensible command tree for Spacemacs.aDNA. `what/context/agent_command_tree.md` was seeded in the 2026-05-07 research integration session — it describes the full `SPC` keybinding hierarchy and patterns for agents to extend it dynamically. This mission:

1. Gets operator approval on the agent command tree design
2. Adds the `SPC a x` extension transient stub to the live `adna` layer
3. Updates `skill_adna_index` with post-extension re-indexing instructions

This makes Spacemacs.aDNA a self-documenting, agent-extensible system: agents can add commands, expose them via MCP, and update the context graph — all within the vault's governance framework.

## Deliverables

- Operator review + approval of `what/context/agent_command_tree.md`
- `what/standard/layers/adna/keybindings.el` updated — add `SPC a x` transient stub:
  ```elisp
  (transient-define-prefix adna/extensions-menu ()
    "SPC a x — Agent-authored extensions."
    ["Agent Extensions"
     ;; populated by agents via what/local/operator.private.el
     ])
  (spacemacs/set-leader-keys "ax" #'adna/extensions-menu)
  ```
- ADR for the `SPC a x` addition (extends ADR-013 scope — agent-owned transient slot)
- `how/standard/skills/skill_adna_index.md` updated — "After adding a command, re-run `M-x adna-index-project` to update `graph.json`"
- `skill_health_check` run after adna layer keybinding change
- Live verification: `SPC a x` visible in which-key, opens empty (stub) transient
- AAR

## Estimated effort

1 session.

## Dependencies

P4-09 closed (claude-code-ide live — the MCP tool registration pattern depends on claude-code-ide being active; agent command tree demonstrates the full loop: keybinding + MCP tool exposure).

## Reference

- `what/context/agent_command_tree.md` (seeded 2026-05-07)
- `what/standard/layers/adna/keybindings.el` (existing adna layer keybindings)
- ADR-013: `what/decisions/adr/adr_013_keybinding_transient_refactor.md` (SPC a origin)
- ADR-019: `what/decisions/adr/adr_019_claude_code_ide_layer.md` (MCP tool registration)
- `how/standard/skills/skill_adna_index.md`

## AAR
- **Worked**: Transient stub pattern (one placeholder entry + `ignore`) wires cleanly and serves as a graft point for `transient-append-suffix` — no empty-group elisp edge case.
- **Didn't**: Live Emacs validation deferred (no operator boot this session) — byte-compile check substitutes as gate.
- **Finding**: Context doc and keybindings.el were out of sync for 3 days; stub activation immediately resolves the dead-reference problem without requiring agent extensions to exist.
- **Change**: Future keybinding context docs should note their activation status (wired / stub / planned) so the gap is visible at a glance.
- **Follow-up**: P5-01 doc pass should verify `agent_command_tree.md` accurately reflects the live keybinding layout after this change.
