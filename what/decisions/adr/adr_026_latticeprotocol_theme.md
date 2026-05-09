---
type: decision
adr_id: adr_026
title: LP Theme — spacemacs-dark/light derivatives with minimal palette delta
status: accepted
created: 2026-05-09
updated: 2026-05-09
last_edited_by: agent_stanley
tags: [adr, accepted, theme, latticeprotocol-dark, latticeprotocol-light, p4_03]
supersedes: ~
superseded_by: ~
---

# ADR-026 — LP Theme: spacemacs-dark/light derivatives with minimal palette delta

## Context

P4-03 requires authoring the `latticeprotocol-theme` layer (scaffolded in P4-01). The layer ships two theme variants: dark and light. Operator input (P3-04 decision blocks) recorded doom-one and modus-vivendi as candidate inspirations but made no firm commitment. The operator's session direction: _close to spacemacs-dark with small changes_.

## Decision

**Derive from spacemacs-dark (dark) and spacemacs-light (light) with the minimum palette delta required for LP visual identity.**

Dark theme — 2 tweaks vs. spacemacs-dark:
- `bg`: `#1e2029` (cooler blue-black vs. `#292b2e`)
- `keyword/accent`: `#5b9bd5` (more saturated vs. `#4f97d7`)

Light theme — 1 tweak vs. spacemacs-light:
- `bg`: `#f2f4f8` (cooler off-white vs. `#fbf8ef`)

All other face colors inherited unchanged from the upstream palettes.

## Alternatives Considered

| Option | Why Not Chosen |
|--------|----------------|
| Full custom palette (doom-one inspired) | Operator explicitly asked for minimal delta from spacemacs-dark; full custom would feel unfamiliar |
| Thin wrapper re-exporting doom-one/modus-vivendi | Introduces an external dependency; requires those packages to be installed |
| Zero changes (exact spacemacs-dark clone) | Provides no visual differentiation; LP distribution has no distinct look |

## Implementation

- `layers/+themes/latticeprotocol-theme/local/latticeprotocol-theme/latticeprotocol-dark-theme.el` — self-contained deftheme, ~55 faces
- `layers/+themes/latticeprotocol-theme/local/latticeprotocol-theme/latticeprotocol-light-theme.el` — self-contained deftheme, ~55 faces
- `layers/+themes/latticeprotocol-theme/packages.el` — `init-latticeprotocol-theme` registers load path via `add-to-list 'custom-theme-load-path`
- Spec: `what/standard/spacelattice_theme_spec.md`

## Operator Approval

Approved in session `session_sl_p4_03_2026_05_09T020901Z`. Palette approach confirmed by operator: "close to spacemacs-dark with small changes."
