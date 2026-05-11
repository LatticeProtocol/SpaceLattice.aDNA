---
type: backlog_idea
status: active
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
tags: [backlog, layer_contract, convention, quality]
source: aar_sl_p4_09
---

# Idea: Document minimum file count for standard layers in LAYER_CONTRACT.md

## Problem

The `claude-code-ide` layer skeleton was seeded without `layers.el`. The 5-file convention (packages/config/keybindings/README/layers) is visible in examples (`adna` + `claude-code-ide`) but not codified in `what/standard/LAYER_CONTRACT.md`. Future layer additions may repeat the omission.

## Proposed change

Add a clause to `LAYER_CONTRACT.md` specifying the minimum required files for any standard layer:

```
Clause N — Minimum layer file contract
Every layer in what/standard/layers/ MUST include the following files:
  - packages.el   (package declarations + use-package forms)
  - config.el     (layer configuration variables)
  - keybindings.el (SPC keybinding declarations)
  - README.org    (user-facing documentation)
  - layers.el     (load-order dependencies — minimum: spacemacs-bootstrap)
Layers missing any of these files fail skill_health_check.
```

## Scope

Small addition to `what/standard/LAYER_CONTRACT.md`. ADR not required (clarification of existing convention, not a new decision).

## Priority

Low — convention is understood; risk is only on future layer additions.
