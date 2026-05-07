---
type: mission
mission_id: mission_sl_p4_layout_intelligence
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: TBD
status: planned
mission_class: implementation
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, layout, agentic, context_graph, campaign_protocol, ux]
blocked_by: [mission_sl_p3_02_dotspacemacs_variables]
---

# Mission — P4: Agentic Layout Intelligence System

**Phase**: P4 — Fork branding + capability hardening.
**Class**: implementation.

## Context

The layout system is currently four `dotspacemacs-*` variables at defaults (confirmed P3-02
§1.3.6, 2026-05-07). The real opportunity is making layout management a first-class agentic
capability: the agent knows which layout to use, can switch programmatically, and campaign
design includes deliberate layout planning. See `how/backlog/idea_agentic_layout_system.md`
for full design rationale.

## Objective

Build a three-layer agentic layout system:

1. **Layout inventory** — 8 named layouts in `adna/layouts.el`, bound to `SPC a l <key>`
2. **Context document** — `what/context/spacemacs/agentic_layout_guide.md` for agent context loading
3. **Campaign protocol integration** — template updates, `skill_layout_plan`, AGENTS.md standard section

## Deliverables

### Layer 1 — `adna/layouts.el` (8 named layouts)

| Layout | Key | Split Config |
|---|---|---|
| `layout-writing` | `w` | Narrow treemacs + wide single buffer |
| `layout-code-review` | `r` | Magit left + source right + vterm bottom |
| `layout-web-design` | `d` | Browser 40% + editor 40% + vterm 20% |
| `layout-data-pipeline` | `p` | Editor 50% + vterm top-right + output bottom-right |
| `layout-agentic-terminal` | `a` | Claude Code terminal 60% + treemacs 40% |
| `layout-vault-navigation` | `v` | Wide treemacs 30% + buffer 50% + imenu 20% |
| `layout-campaign-planning` | `c` | Campaign doc + mission file + STATE.md |
| `layout-pair-terminal` | `t` | vterm L1 left + vterm L2 right + messages bottom |

Each layout: elisp function, `SPC a l <key>` binding, rationale docstring, ADR reference.

### Layer 2 — Context document

`what/context/spacemacs/agentic_layout_guide.md`:
- Full inventory with rationale and decision tree
- Switching instructions (keybind, elisp call, emacsclient)
- Composition rules and anti-patterns
- Per-campaign-type layout recommendations table

### Layer 3 — Campaign protocol integration

- `how/templates/template_campaign.md` — add `recommended_layouts:` frontmatter field + `## Layout plan` section
- `how/templates/template_mission.md` — add `recommended_layout:` frontmatter field
- `how/standard/skills/skill_layout_plan.md` — new skill: reads campaign type + mission list → outputs layout mapping table
- Campaign AGENTS.md standard template — add `## Layout context` section with guide load instruction
- ADR for each of the 8 layouts (lightweight, `standard_config` kind; can batch as ADR-N "initial layout inventory")

## Estimated effort

2 sessions.

## Dependencies

P3-02 closed (for `adna` layer foundation). P4 phase gate opened.

## Reference

- `how/backlog/idea_agentic_layout_system.md` — full design rationale and inventory spec
- `what/standard/layers/adna/` — adna layer source (layouts.el added here)
- `what/context/spacemacs/spacemacs_customization_reference.md` §1.3.6 — layout variable reference
- `how/templates/` — campaign and mission templates to update
- `what/standard/dotfile.spacemacs.tmpl` — `SPC a l` Transient tree entry (already scaffolded in `adna` keybindings)

## Verification

- `SPC a l ?` opens layout Transient menu with all 8 bindings visible
- Each layout function switches window configuration correctly (visual check via `skill_inspect_live`)
- `what/context/spacemacs/agentic_layout_guide.md` loads cleanly in a test session context
- Campaign template updated: running P0 for a test campaign produces a `layout_plan` section
- `skill_layout_plan` outputs a layout-per-mission table given a sample campaign brief
