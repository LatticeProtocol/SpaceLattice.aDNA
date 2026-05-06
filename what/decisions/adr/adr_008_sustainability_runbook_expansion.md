---
type: adr
adr_id: adr_008
adr_number: 8
title: "Expand update_spacemacs.md: sed patterns, heuristics, CI design"
status: accepted
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
proposed_by: agent_stanley
target_files:
  - how/standard/runbooks/update_spacemacs.md
ratifies:
  - conflict_detection_patterns: 5 (core-versions, core-spacemacs-buffer, core-spacemacs, dotspacemacs-template, packages.el)
  - heuristics_table: per-file disposition (rebase-on-ours / manual review / track-upstream)
  - ci_design_sketch: sync-upstream.yml + UPSTREAM_SYNC_CONFLICT_REPORT.md (authored in P4-07)
supersedes:
superseded_by:
tags: [adr, accepted, sustainability, runbook, p2, spacelattice]
---

# ADR-008: Expand update_spacemacs.md with rebase-conflict teeth

## Status

Accepted

## Context

`how/standard/runbooks/update_spacemacs.md` was authored in the SpaceLattice genesis as a skeleton covering the pin-bump workflow (steps 1-7: fetch, ADR, dry-run, update, commit, install, smoke-test). It did not cover the harder problem: handling merge conflicts that arise when `git rebase upstream/develop` runs on the LP fork (`LatticeProtocol/spacelattice`).

The sustainability framework (`what/standard/sustainability.md` §Stay-current process) lists "upstream rebase conflict resolution" as a weekly cadence activity with a reference to `what/context/spacemacs/spacemacs_customization_reference.md §4B.5` for the conflict-prone file list. But no concrete detection checks, re-injection patterns, or CI design existed.

P2-01 of `campaign_spacelattice_v1_0` mandated this expansion as the sustainability framework's first concrete deliverable.

## Decision

Append a new `## Handling upstream rebase conflicts` section to `update_spacemacs.md` containing:

1. **Per-file heuristics table** — 7 files from the §4B.5 hot list, each with a disposition (rebase-on-ours / manual review / track-upstream) and rationale.

2. **5 detection + re-injection patterns** — one per LP-modified file:
   - P1: `core/core-versions.el` — `latticeprotocol-version` defconst re-injection via `sed -i`
   - P2: `core/core-spacemacs-buffer.el` — `(require 'lp-branding)` EOF append via `printf >>`
   - P3: `core/core-spacemacs.el` — `latticeprotocol-startup-hook` re-injection; flagged manual review
   - P4: `core/templates/dotspacemacs-template.el` — `dotspacemacs-distribution` default patch via `sed -i`
   - P5: `layers/+distributions/spacemacs/packages.el` — LP package entry re-injection via `sed -i`

3. **All-at-once detection script** — single bash block to run all 5 checks; non-zero exit if any fail.

4. **Dry-run validation** — scratch-dir simulation of pattern 1 proving sed produces correct output without touching the real fork.

5. **CI integration design sketch** — `sync-upstream.yml` GitHub Action (weekly schedule + manual dispatch) and `UPSTREAM_SYNC_CONFLICT_REPORT.md` PR template. Sketch-level only; actual file authoring deferred to P4-07 (`mission_sl_p4_07_ci_upstream_sync`).

## Consequences

### Positive

- Runbook is now executable: an operator (or agent) can run the detection script after any rebase and know exactly which LP injection points survived.
- Patterns are idempotent — safe to run even when LP changes are intact.
- CI design is pinned in the runbook so P4-07 has a clear spec to implement against.
- Heuristics table documents institutional knowledge about each file's conflict character — prevents re-learning this on every rebase.

### Negative

- Patterns P3 and P4 require manual review; the anchor lines in `core/core-spacemacs.el` may shift across upstream versions. This is flagged explicitly in the runbook.
- Pattern 5 depends on a sentinel comment (`; SpaceLattice.aDNA additions`) that P4 must add to the packages.el file. Until P4 lands, pattern 5 requires manual insertion of the sentinel.

### Neutral

- The CI design sketch (`sync-upstream.yml` + PR template) is not runnable until P4-07 authors the actual files. The sketch is forward-referenced to P4-07.
- ADR numbers 004 skipped in the series — this is a pre-existing gap (no ADR-004 was filed during genesis or P1).

## Alternatives considered

**Alternative A — Script file instead of runbook section**: Author a standalone `scripts/lp-rebase-check.sh` in the fork repo. Rejected: the script belongs to the fork's execution context, not the vault's governance. The runbook keeps governance in the vault where it belongs; the script can be extracted from the runbook in P4-07 when the fork is scaffolded.

**Alternative B — Defer entirely to P4**: The fork doesn't exist locally yet (Stage 0); no LP changes have been made yet. Argument for deferral: patterns are untested against real fork files. Rejected: the vault's runbook should document the *design intent* now; P4 will validate and adapt the patterns against the real fork files, updating the runbook via ADR if patterns need adjustment.

## References

- Friction source: `what/standard/sustainability.md` §Implementation deferred item 2
- Context: `what/context/spacemacs/spacemacs_customization_reference.md §4B.5`
- Fork strategy: `what/standard/fork-strategy.md` §Rebase cadence
- Mission: `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_p2_01_sustainability_runbook_teeth.md`
- CI authoring: `mission_sl_p4_07_ci_upstream_sync` (deferred to P4)
