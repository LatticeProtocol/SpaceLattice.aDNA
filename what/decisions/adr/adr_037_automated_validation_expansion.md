---
type: adr
adr_id: adr_037
title: "Automated validation expansion — validate_layers.py + health-check G/H + CI validate job"
status: accepted
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
supersedes: []
superseded_by: []
adr_kind: implementation
tags: [adr, accepted, validation, ci, health_check, python, p5_03]
---

# ADR-037 — Automated Validation Expansion

## Context

CI currently byte-compiles all `.el` files across three Emacs versions (ADR-031). This catches syntax errors but has no structural validation — it cannot detect a layer that is missing a required file, has a malformed `layers.el`, or has slipped an operator home path into `standard/`.

P5-00 gap register identified GAP-03: no `validate_layers.py`, no structural gate.

Honest scope statement (from mission spec): Full UI validation (layout rendering, Claude Code window placement, which-key output) requires a running Emacs session and operator sign-off. Automated checks cover: layer structure, key function definitions, sanitization. This is the right split of concerns.

## Decision

Add three complementary validation layers:

1. **`what/standard/index/validate_layers.py`** — Python 3.11 script, no Emacs required. Runs 7 structural checks on `what/standard/layers/`.

2. **`skill_health_check.md` Checks G + H** — two new checks in the existing A-I battery:
   - Check G: all LP layers byte-compile individually (catches cross-file stub issues)
   - Check H: `validate_layers.py` passes (structural correctness gate)

3. **`.github/workflows/ci.yml` `validate` job** — runs `validate_layers.py` in CI (Python only, no Emacs needed). Runs in parallel with the existing `byte-compile` matrix job.

4. **`how/standard/runbooks/operator_acceptance_test.md`** — structured batch + boot checklist for what automation cannot cover (layout rendering, which-key display, Claude window geometry).

## validate_layers.py checks

| # | Check | Level |
|---|-------|-------|
| 1 | Each dir in `what/standard/layers/` has `packages.el` | FAIL |
| 2 | Each dir has `layers.el` | FAIL |
| 3 | Each `layers.el` contains `spacemacs-bootstrap` (load-order declaration) | FAIL |
| 4 | `adna/keybindings.el` defines `adna/extensions-menu` (SPC a x stub live) | FAIL |
| 5 | `claude-code-ide/keybindings.el` defines `SPC c` bindings | FAIL |
| 6 | `adna/layouts.el` defines `adna/layout-agentic-default` | FAIL |
| 7 | No file in `what/standard/` contains operator home paths (`/Users/<name>/` or `/home/<name>/`) | FAIL |

Exit 0 = all pass. Exit 1 = one or more failures. Per-check output for actionable error messages.

## Consequences

- CI now has two parallel gates: byte-compile (Emacs, 3 versions) + validate (Python, no Emacs)
- `skill_health_check` now has 9 active checks (A-C + D/D+ + E + F + G + H + I)
- Check H calls `validate_layers.py`, so validate_layers.py must be present at health-check time
- Operators get a structured acceptance test runbook for the install/deploy workflow
- Post-v1.0 CI can extend `validate_layers.py` without new ADRs (adds checks don't change the contract)

## Operator approval

Stanley — 2026-05-11
