---
type: adr
adr_id: adr_031
adr_kind: decision
title: "CI + Upstream Monitor workflows (vault-only adaptation)"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes: []
superseded_by: []
tags: [adr, ci, github_actions, upstream_monitor, vault_only, p4_07]
---

# ADR-031 — CI + Upstream Monitor workflows

## Context

P4-07 originally specified two GitHub Actions workflows for the `LatticeProtocol/spacelattice` fork:

1. A byte-compile / lint CI matrix (Emacs 28.2 / 29.x / snapshot)
2. A weekly rebase-and-PR sync against `syl20bnr/spacemacs develop`

ADR-024 (vault-only layer model, 2026-05-08) abolished the separate fork. All LP-specific Spacemacs code now lives in `what/standard/layers/` inside this vault. Consequences:

- CI workflows must live in **this vault's** `.github/workflows/`, targeting the elisp files under `what/standard/layers/`.
- The "weekly rebase + PR" pattern assumed a fork to rebase. Under the vault-only model, Spacemacs upstream is consumed via ADR-gated pin bumps (`how/standard/runbooks/update_spacemacs.md`). The weekly automation should instead **detect pin drift and open a GitHub issue** as the trigger for the operator to run the pin-bump runbook.

P2-01 (`mission_sl_p2_01_sustainability_runbook_teeth`) sketched the CI integration design in `how/standard/runbooks/update_spacemacs.md`. This ADR realizes that sketch.

## Decision

Adopt a two-workflow design, both living at `.github/workflows/`:

### 1. `ci.yml` — Layer byte-compile

**Purpose**: Validate that every `.el` file under `what/standard/layers/` compiles without errors across a matrix of Emacs versions.

**Triggers**: push to `master` or pull-request, scoped to `what/standard/layers/**/*.el` path changes.

**Matrix**: Emacs `28.2`, `29.4`, `snapshot` (via `purcell/setup-emacs`).

**Test method**: `find what/standard/layers -name '*.el' -print0 | xargs -0 emacs --batch -f batch-byte-compile`

`batch-byte-compile` exits non-zero on compile errors — no extra failure-detection logic needed. `.elc` files are not committed (covered by `.gitignore`).

**No `package-lint`**: LP layers are Spacemacs private layers, not MELPA packages. `package-lint` expects a package header + commentary block that private layers don't have. Byte-compile is the right gate.

### 2. `upstream-sync.yml` — Upstream monitor

**Purpose**: Detect when Spacemacs upstream (`syl20bnr/spacemacs develop`) has advanced past the SHA pinned in `what/standard/pins.md` and open a GitHub issue to prompt the operator.

**Trigger**: weekly cron (Monday 09:00 UTC) + `workflow_dispatch` for manual runs.

**Mechanism**:
1. Parse pinned SHA from the `Pinned SHA` row in `what/standard/pins.md` (40-char hex).
2. Fetch upstream HEAD via GitHub API (`repos/syl20bnr/spacemacs/git/ref/heads/develop`).
3. If SHAs differ, query `repos/syl20bnr/spacemacs/compare/{pinned}...{upstream}` for `ahead_by` count.
4. Open an issue titled `Upstream Spacemacs: N new commits (YYYY-MM-DD)` with a compare link and a pointer to the pin-bump runbook.

The workflow uses `gh issue create --label "upstream-sync"`. The `upstream-sync` label must exist on the repository; if it doesn't, `gh issue create` is called with `|| true` so the workflow doesn't fail.

**No auto-rebase, no auto-PR**: operator remains in the loop per ADR-024 vault-only governance philosophy. The issue is the signal; the ADR + runbook is the action.

## Rationale

- Fork-rebase automation would require a fork that no longer exists (ADR-024).
- Issue-based notification surfaces drift as a visible, operator-owned work item — consistent with ADR-gated pin-bump discipline.
- Byte-compile CI gives the vault a regression gate that doesn't require a full running Spacemacs instance (a headless smoke test with full Spacemacs init is an order of magnitude more complex and is deferred to a future ADR).
- `purcell/setup-emacs` is the de-facto standard action for Emacs CI; no need to maintain a custom Docker image.

## Consequences

- `.github/workflows/ci.yml` and `.github/workflows/upstream-sync.yml` created in this vault.
- `what/standard/spacelattice_ci_spec.md` documents the design for operators.
- The `upstream-sync` GitHub label must be created on `LatticeProtocol/Spacemacs.aDNA` before the first weekly run.
- P4-08 (`skill_update_pin`) is downstream: it adds vault-side skill documentation for the ADR-gated pin bump that this monitor triggers.
