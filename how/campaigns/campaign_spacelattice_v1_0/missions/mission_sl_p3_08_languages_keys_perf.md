---
type: mission
mission_id: mission_sl_p3_08_languages_keys_perf
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 8
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, customization, languages, keybindings, perf_recipes, phase_gate, user_in_loop]
blocked_by: [mission_sl_p3_07_wild_workarounds_org]
---

# Mission — P3-08: Language stack + keybinding philosophy + final perf recipe (P3 phase-gate)

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Walk dimensions §3.4 (language-stack patterns: LSP knobs, tree-sitter on Emacs 29+, DAP, compleseus + lsp), §3.5 (keybinding remap philosophies: reserved prefixes per CONVENTIONS.org; operator's `SPC o l` LP prefix per fork-strategy namespace hygiene), §3.6 (performance-tuning recipes: gc-cons, read-process-output-max, package-quickstart, line-numbers plist, native-comp settings). Operator-in-the-loop: lock down languages stack + leader-key conventions + final perf recipe. **P3 phase-gate evidence**: 22 dimensions reviewed; operator profile complete; standard layer absorption (where applicable).

## Deliverables

- 7-step protocol
- Decisions recorded: language layers enabled (Python/TypeScript/Rust/etc. per operator), `SPC o l` LP prefix bindings (`olh`/`olu`/etc. — used in P4-02 distribution layer's `keybindings.el`), final performance recipe
- Layer changes: language layers added via `skill_layer_add` (each ADR-gated); leader-key bindings drafted for inclusion in P4-02 distribution layer
- **P3 phase-gate**: All 22 dimensions reviewed; operator profile (`who/operators/stanley.md`) complete; `what/local/operator.private.el` populated; standard layer absorbed validated patterns via `skill_layer_promote` (those eligible for commons)
- AAR (mission close + P3 phase close coverage)

## Estimated effort

1-2 sessions.

## Dependencies

P3-07 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §3.4, §3.5, §3.6
- `what/standard/fork-strategy.md` (namespace hygiene + reserved leader keys)
- `who/operators/stanley.md` (operator profile — populated across P3-01 through P3-08)
