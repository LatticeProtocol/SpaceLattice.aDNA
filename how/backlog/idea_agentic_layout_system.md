---
type: backlog
idea_id: idea_agentic_layout_system
status: promoted
priority: high
created: 2026-05-07
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [backlog, layout, agentic, context_graph, campaign_protocol, p5, ux]
target_phase: P5
promoted_to_mission: mission_sl_p5_01_agentic_layout_system
---

# Idea — Agentic Layout Intelligence System

## Origin

Surfaced during P3-02 §1.3.6 (layouts/sessions) confirmation, 2026-05-07. The layout variables
are minimal knobs — the real opportunity is making the *layout system* a first-class citizen of
the aDNA context graph and agentic workflow, not just a Spacemacs configuration detail.

## Problem

The current Spacemacs dotfile sets four layout variables to defaults and leaves layout
management to the operator's muscle memory. This misses the core value proposition: an
agentic IDE should know *which layout to use* based on the work at hand, be able to switch
layouts programmatically, and guide the operator toward the right window arrangement for each
campaign type.

Concretely:
- Opening a browser + terminal + editor for UI/UX work requires 3-5 manual steps
- Campaign design sessions have no canonical spatial arrangement
- The agent has no context about what "a good working environment" looks like per task type
- Layout switching is tribal knowledge, not documented in the context graph

## Proposed Solution

A three-layer agentic layout system:

### Layer 1 — Layout Inventory (`adna/layouts.el`)

Named, documented elisp layout functions registered in the `adna` layer. Each layout:
- Has a canonical name (`layout-web-design`, `layout-data-pipeline`, etc.)
- Defines a window split configuration (widths, positions, which buffers to open)
- Is bound to `SPC a l <key>` via the Transient tree
- Has a rationale comment explaining when to use it

**Proposed initial inventory**:

| Name | Key | Split Config | Best For |
|---|---|---|---|
| `layout-writing` | `w` | Narrow treemacs + wide single buffer | Blog posts, docs, vault content |
| `layout-code-review` | `r` | Magit diff left + source right + vterm bottom | PR review, git operations |
| `layout-web-design` | `d` | Browser 40% left + editor 40% + vterm 20% right | SiteForge, UI/UX, frontend work |
| `layout-data-pipeline` | `p` | Editor 50% + vterm top-right 25% + output bottom-right 25% | ML pipelines, L2 dispatch, datasets |
| `layout-agentic-terminal` | `a` | Claude Code terminal 60% left + treemacs 40% right | Running agentic tasks, session monitoring |
| `layout-vault-navigation` | `v` | Wide treemacs 30% + buffer 50% + imenu 20% | Context graph walking, mission planning, ADR writing |
| `layout-campaign-planning` | `c` | Campaign doc left + mission file center + STATE.md right | Campaign design, mission scaffolding |
| `layout-pair-terminal` | `t` | vterm L1 left + vterm L2 right + messages bottom | Federated ML job dispatch, multi-shell coordination |

### Layer 2 — Context Document (`what/context/spacemacs/agentic_layout_guide.md`)

A context graph document the agent loads when doing layout-related work:
- Full layout inventory with rationale for each
- Decision tree: "given campaign type X and current task Y, recommend layout Z"
- Switching instructions (elisp call, keybind, emacsclient command)
- Composition rules: layouts as starting points, not rigid templates
- Anti-patterns: common mismatches (e.g., using writing layout for code review)

### Layer 3 — Campaign Protocol Integration

Every campaign design session includes a layout planning step:

1. **Campaign design checklist** gains a `layout_plan:` section
2. **Campaign template** (`how/templates/template_campaign.md`) gains a `recommended_layouts:` frontmatter field
3. **`skill_layout_plan`** — new skill: agent reads campaign type + mission list → outputs recommended layout inventory with per-mission layout mapping
4. **Mission template** (`how/templates/template_mission.md`) gains `recommended_layout:` field
5. **AGENTS.md** (campaign-level) gets a standard `## Layout context` section explaining which layouts are active for this campaign

## Implementation Notes

- Layouts are pure elisp functions — no new packages required; `winum`, `treemacs`, `vterm` are already in the standard layer list
- The `adna` layer's `funcs.el` is the natural home (`adna/layouts.el` as a sub-file sourced by `packages.el`)
- Each named layout added to standard requires a lightweight ADR (kind: `standard_config`)
- `skill_layout_plan` is a `skill` lattice type — can be published to the registry
- Layout inventory grows over time via operator friction signals → `skill_self_improve` Rule F candidates

## Campaign Protocol Impact

This mission changes the campaign design ritual: agents running P0 (planning) for any future
Spacemacs-hosted campaign will load the layout guide and output a `layout_plan` section in
the campaign doc. This is a low-overhead addition — the guide is a single context file load,
and the output is a short table.

## Promoted to Mission

`mission_sl_p4_layout_intelligence.md` — seeded as P4 mission stub.
