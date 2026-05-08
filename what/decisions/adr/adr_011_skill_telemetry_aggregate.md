---
type: adr
adr_number: 011
title: "skill_telemetry_aggregate — canonical maintainer aggregation path"
status: accepted
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, telemetry, aggregate_skill, p2, fleet, maintainer]
---

# ADR-011: skill_telemetry_aggregate — canonical maintainer aggregation path

## Status

Accepted

## Context

P2-02 (ADR-009) locked the telemetry schema. P2-03 (ADR-010) ratified `skill_telemetry_submit` as the operator-side submission path. These two ADRs define the first half of the fleet loop: friction detected locally → sanitized payload → GitHub issue on the upstream repo.

The second half of the loop — maintainer polls issues, parses payloads, surfaces patterns, drives ADR proposals — was designed by M-Planning-01 and stubbed in `skill_telemetry_aggregate.md` with the Python parser already present. P2-04 promotes the stub to a full procedure and executes the first end-to-end round-trip as P2 phase-gate evidence.

Without a canonical aggregation path:
- Maintainers would hand-poll GitHub issues without schema validation, creating inconsistent fleet data
- Cross-fleet pattern detection (the signal that drives upstream ADR proposals) would be ad-hoc
- The inbox audit trail (`who/peers/telemetry/inbox/`) would be unstructured, making it hard to track which issues have been processed

## Decision

Ratify `how/standard/skills/skill_telemetry_aggregate.md` as the canonical maintainer-side telemetry aggregation path. The skill implements a seven-step sequence:

1. **Poll** — `gh api repos/LatticeProtocol/Spacemacs.aDNA/issues?labels=telemetry&state=all --paginate`; creates the `telemetry` label if absent
2. **Parse + validate** — extracts JSON payload from issue body, validates `type` field, routes to per-class handler; rejects malformed payloads to `who/peers/telemetry/inbox/rejected/` audit trail
3. **De-dup** — loads `who/peers/telemetry/inbox/_state.json` (gitignored); skips issues already processed in prior runs; idempotent
4. **Aggregate** — groups new records by submission class; builds batch metadata (window, count, signals_by_class)
5. **Pattern detection** — if ≥5 records share the same `friction_signal.signal_class`, emits `who/peers/telemetry/inbox/pattern_<signal_class>.md`; threshold is 5 (initial calibration, revisable by ADR)
6. **Write audit batch (committed)** — `who/peers/telemetry/inbox/<utc>_aggregate.md` with YAML frontmatter; committed to vault git so all peers can verify the aggregation
7. **Update `_state.json` (gitignored)** — records `last_processed_issue_id` and `last_run_utc`; machine-local idempotency

Additionally:
- `--dry-run` flag runs Steps 1–4, prints parsed records and pattern detections, stops without writing to inbox or updating state
- `--since <iso8601>` overrides `_state.json` for the batch window (useful for retroactive re-aggregation)

## Consequences

### Positive

- Fleet loop is now complete: operator friction → submit → aggregate → pattern → ADR proposal
- Cross-fleet pattern detection is schema-driven, not ad-hoc
- The committed inbox audit trail enables any fork operator to verify what has been aggregated
- Idempotent re-runs (de-dup by issue ID) make periodic scheduled aggregation safe
- `--dry-run` flag makes the skill safe to test without modifying vault state
- Rejected payload audit trail (`inbox/rejected/`) provides maintainer visibility into malformed submissions without noise in the main inbox

### Negative

- Requires `gh` CLI authenticated against `github.com/LatticeProtocol/Spacemacs.aDNA` on the maintainer's machine
- Pattern threshold (5) is a rough initial calibration — may produce false positives (rare fleet, same operator re-submitting) or miss real patterns (large fleet, high diversity). Revisable by ADR.
- The companion skill `skill_self_improve_aggregate` (fleet-aware ADR proposal generation) is post-v1.0 scope; the current skill surfaces patterns but does not auto-draft ADRs

### Neutral

- `_state.json` is gitignored by design — it's machine-local idempotency state, not shared. A maintainer switching machines must re-run from scratch (or set `last_processed_issue_id` manually) for the first run.
- Pattern files (`inbox/pattern_*.md`) are committed — they accumulate over time. A cleanup protocol (close pattern → archive file) is deferred to post-v1.0.

## References

- ADR-005: Telemetry channel (GitHub Issues) ratified
- ADR-009: Telemetry schema lock-in (four classes, JSON Schema Draft-07, five sanitization rules)
- ADR-010: `skill_telemetry_submit` — operator-side submission path
- `what/standard/telemetry.md`: Full telemetry framework
- `how/standard/skills/skill_telemetry_aggregate.md`: Implementation (this ADR ratifies)
- Mission: `mission_sl_p2_04_telemetry_aggregate_skill_and_round_trip`
