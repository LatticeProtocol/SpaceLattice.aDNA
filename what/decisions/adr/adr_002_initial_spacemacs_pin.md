---
type: decision
adr_id: adr_002
adr_number: 2
title: "Initial Spacemacs pin: e57594e7 (captured by first skill_install on 2026-05-04)"
status: accepted
proposed_by: agent_init
target_layer: standard
target_files:
  - what/standard/pins.md
detected_via:
  rule: first_install_bootstrap
  evidence: "skill_install step 3 captured `git rev-parse HEAD` from `develop` after clone"
ratifies:
  spacemacs_sha: "e57594e7aa1d459d3428b9b116bb84b344aa6084"
  pin_date: "2026-05-04"
  emacs_version: "29.4"
  install_host: "darwin (apple silicon)"
supersedes:
superseded_by:
tags: [decision, adr, pin, spacemacs, install, daedalus]
---

# ADR 002 — Initial Spacemacs pin (captured at first install)

## Status

**Accepted** at 2026-05-04 by the operator running the first `skill_install` execution.

## Context

`what/standard/pins.md` was authored in Phase 2 with `Pinned SHA: PIN PENDING` because the genesis machine did not have emacs installed yet. ADR 000 § 1 documents that this pin is captured on first install; the genesis plan's Phase 8 added the live install step (`brew install emacs-plus@29 fd` + `skill_install`) to clear that placeholder.

Phase 8 ran:

1. `brew install emacs-plus@29 fd` (Homebrew tap `d12frosted/emacs-plus`; bottle install on Apple Silicon, no source build needed; total time ~30 sec).
2. `skill_install` step 3 cloned `https://github.com/syl20bnr/spacemacs.git` at branch `develop`.
3. `git rev-parse HEAD` returned `e57594e7aa1d459d3428b9b116bb84b344aa6084`.
4. First batch boot (`emacs --batch -l ~/.emacs.d/init.el`) completed in ~3.5 minutes with exit 0; ~40 layer packages installed from MELPA.
5. `(adna/health-check)` returned OK; `(adna-index-project)` wrote `graph.json` with 223 nodes, 341 edges.

## Decision

Pin Spacemacs at SHA `e57594e7aa1d459d3428b9b116bb84b344aa6084` (develop tip on 2026-05-04). Update `what/standard/pins.md`'s "Pinned SHA" and "Pin date" fields accordingly. Mark first-install bootstrap section as past-tense.

## Consequences

- Reproducibility pact (per `pins.md`'s closing section) is now activated. Future operators who run `skill_install` will see the same upstream commit unless `update_spacemacs.md` (ADR-gated) bumps it.
- The pin captures Spacemacs at a specific point in `develop`'s history; operators absorbing later upstream changes follow the runbook.

## Alternatives considered

1. **Pin to a tagged release** (e.g., `30.0.0` if it exists). Rejected: Spacemacs's release cadence is slow; the brief specifies `develop` as the build target.
2. **Pin to a specific date-stamped commit** (e.g., commit closest to 2026-05-04 09:00 UTC). Rejected: arbitrary; the develop-tip-at-install policy is simpler and reproducible.
3. **Leave PIN PENDING and re-pin on every install**. Rejected: defeats the reproducibility goal; peers would each install at different upstream states.

## Reversibility

Trivial — successor ADR via `update_spacemacs.md` runbook bumps the pin.

## References

- Pin file: `what/standard/pins.md`
- Skill: `how/standard/skills/skill_install.md`
- Runbook for future bumps: `how/standard/runbooks/update_spacemacs.md`
- Foundational decision: `what/decisions/adr/adr_000_vault_identity.md` § 1 (clause defining pin discipline)
- Install log: `how/local/machine_runbooks/last_install.log` (gitignored, on originating operator's machine)
