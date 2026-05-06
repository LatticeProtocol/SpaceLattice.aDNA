---
type: operator
name: Stanley
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
hostname: null
primary_models:
  - claude-opus-4-7
  - claude-sonnet-4-6
  - claude-haiku-4-5
secondary_models:
  - llama (local)
  - ollama (local)
layer_preferences:
  - lsp
  - python
  - typescript
  - rust
  - org
  - adna
  - markdown
os: macOS
shell: zsh
telemetry_consent: true
telemetry_classes:
  friction_signal: true
  adr_proposal: true
  customization_share: false
  perf_metric: false
tags: [operator, stanley, daedalus, mac, ml_ops]
---

# Operator profile — Stanley

## Role

Single-operator owner of `SpaceLattice.aDNA`. Genesis architect (2026-05-03). Customizations carried in `what/local/operator.private.el` and `what/local/machine.pins.md` once first install runs.

## Workflow context

- Lives in `~/lattice/` workspace alongside other aDNA vaults (science_stanley, RareHarness, RareArchive, WilhelmAI, VideoForge, etc.)
- Daily work spans federated ML, biomedical pipelines, agentic-coding, aDNA context-graph editing
- Uses Claude Code as primary agentic interface (the `SPC c c` Spacemacs binding pins to current aDNA root)
- Obsidian for visual graph navigation (round-trip hooks in `what/standard/obsidian-coupling.md` activate when both open)

## Customizations carried in local layer

To be populated when `skill_install` runs and `what/local/` is bootstrapped from `what/local/*.example` templates.

## Promotion log (local → standard)

| Date | Promoted | ADR | Notes |
|------|----------|-----|-------|
| — | — | — | — |
