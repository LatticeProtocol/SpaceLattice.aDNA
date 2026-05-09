---
type: spec
title: "Spacelattice CI Design — byte-compile + upstream monitor"
status: active
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [spec, ci, github_actions, upstream_monitor, vault_only]
---

# Spacelattice CI Design

Governance: ADR-031.  
Workflows live at: `.github/workflows/ci.yml` + `.github/workflows/upstream-sync.yml`

---

## 1. Layer byte-compile CI (`ci.yml`)

### Purpose

Confirm that every `.el` file under `what/standard/layers/` compiles without errors across the supported Emacs version matrix. Catches syntax errors, undefined-at-compile-time references, and macro expansion failures before they reach operator machines.

### Trigger

```
on:
  push:
    branches: [master]
    paths: ['what/standard/layers/**/*.el']
  pull_request:
    paths: ['what/standard/layers/**/*.el']
```

Scoped to layer elisp changes only — documentation edits and frontmatter-only changes do not trigger CI.

### Emacs matrix

| Version | Rationale |
|---------|-----------|
| `28.2` | Minimum supported per `what/standard/pins.md` Emacs table |
| `29.4` | Recommended production version (native-comp + tree-sitter) |
| `snapshot` | Early-warning for upcoming Emacs changes |

### Test command

```bash
find what/standard/layers -name '*.el' -print0 \
  | xargs -0 emacs --batch -f batch-byte-compile
```

`batch-byte-compile` exits non-zero on the first compile error. The `fail-fast: false` matrix option lets all three Emacs versions report before the run fails, so version-specific regressions surface in one pass.

### Why not `package-lint`

LP layers are Spacemacs private layers — they do not have a MELPA-style `;;; Package-Version:` header or `;;; Commentary:` section. `package-lint` would produce false positives on every file. Byte-compile is the correct gate for private layers.

### `.elc` cleanup

Compiled files are not committed (covered by `.gitignore`). The CI runner discards them at job end.

---

## 2. Upstream monitor (`upstream-sync.yml`)

### Purpose

Detect when `syl20bnr/spacemacs develop` has advanced past the pinned SHA in `what/standard/pins.md`. Opens a GitHub issue as the operator's cue to run the pin-bump runbook.

Under the vault-only model (ADR-024), Spacemacs upstream is consumed via ADR-gated pin bumps, not automated rebases. This monitor is the automation layer that surfaces drift; human judgment is the gate.

### Trigger

```
on:
  schedule:
    - cron: '0 9 * * 1'   # Monday 09:00 UTC
  workflow_dispatch:        # manual on-demand run
```

### SHA sources

| Source | How parsed |
|--------|-----------|
| Pinned SHA | `grep 'Pinned SHA' what/standard/pins.md \| grep -oE '[0-9a-f]{40}'` |
| Upstream HEAD | GitHub API: `GET /repos/syl20bnr/spacemacs/git/ref/heads/develop` → `.object.sha` |

### Drift detection

If `pinned_sha == upstream_sha`: log "Pinned SHA matches upstream — no action." and exit 0.

If they differ: query `GET /repos/syl20bnr/spacemacs/compare/{pinned}...{upstream}` for `ahead_by`, then open a GitHub issue on this vault's repo.

### Issue template

```
Title: Upstream Spacemacs: N new commits (YYYY-MM-DD)

**Pinned SHA:** `{pinned}`
**Upstream HEAD:** `{upstream}`
**Commits ahead:** N

**Compare:** https://github.com/syl20bnr/spacemacs/compare/{pinned}...{upstream}

Follow runbook: `how/standard/runbooks/update_spacemacs.md`

If an issue already exists for this cycle, close this duplicate.
```

Label: `upstream-sync` (must be created on the repo before the first weekly run).

### Permissions required

```yaml
permissions:
  issues: write
```

Uses `GITHUB_TOKEN` — no extra secrets needed.

### No auto-PR rationale

An automated PR would merge upstream changes without the ADR review required by the pin-bump runbook. The issue approach preserves operator control while eliminating the manual "check if upstream moved" step.

---

## 3. Required repository setup

Before the first weekly upstream-monitor run:

1. Create the `upstream-sync` label on `LatticeProtocol/Spacemacs.aDNA` (any color; suggested: `#0075ca`).
2. Verify `GITHUB_TOKEN` has `issues: write` scope (default for Actions on public repos).
3. Optionally run `workflow_dispatch` manually to confirm the SHA parse works before the first Monday cron.
