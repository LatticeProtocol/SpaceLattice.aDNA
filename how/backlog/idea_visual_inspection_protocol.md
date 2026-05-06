---
type: idea
status: proposed
priority: high
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [backlog, visual-inspection, health-check, ux, qa, spacelattice]
---

# Idea: Visual Inspection Protocol for SpaceLattice

## Problem

The current `skill_health_check` validates Spacemacs loads in batch mode (layer-load, elisp eval). It cannot verify:
- Visual appearance of the theme, modeline, banner, and startup buffer
- That layers render correctly in a GUI frame (font rendering, icon display, tab appearance)
- That the `adna` layer's `SPC a` transient menu looks and behaves as expected
- That eww renders pages correctly
- That the centaur-tabs (tabs layer) display project grouping correctly
- That imenu-list renders the outline panel correctly

An agent needs a way to visually inspect these things and report to the operator.

## Proposed solution

A **visual inspection runbook** (`how/standard/runbooks/visual_inspection.md`) that defines:

1. **Screenshot capture** — use `emacs --screenshot` (Emacs 29+) or `screencapture` (macOS) to capture the frame after startup
2. **Key UI checkpoints** — a checklist of what to verify in each screenshot:
   - Banner / startup buffer rendered
   - Theme color applied
   - Modeline showing correct info
   - `SPC a` transient menu opens
   - `SPC j J` decision tree appears
   - eww renders a test URL
   - imenu-list panel opens
   - centaur-tabs show project grouping
3. **Asciinema recording** — for demonstrating layer interactions (keybindings, transient menus, eww nav)
4. **Demo GIF** — final deliverable from P5-01 (already in backlog)

## Implementation path

- **P3 validation sessions** (P3-10, P3-11): ad-hoc visual inspection during layer audit
- **P3-11 eww mission**: first live demo of eww as agentic browser
- **P5-01 doc pass**: formal `visual_inspection.md` runbook + demo GIF recorded with `asciinema` + `agg`
- **skill_health_check v2** (post-v1.0, potential P6): add screenshot-based UI regression checks

## Design constraints

- Inspection should work headless where possible (Emacs 29 `--screenshot`)
- Where headless fails (GUI-only features), document as "operator-run in GUI" step
- Asciinema/vhs for terminal recordings; screencapture for GUI screenshots
- Output artifacts stored in `how/sessions/` or `missions/artifacts/` (gitignored per local session policy)

## Routed to

- Immediate: P3-11 mission includes eww visual validation checklist (first step)
- Medium: P5-01 includes formal runbook + demo GIF production
- Long-term: skill_health_check v2 post-v1.0
