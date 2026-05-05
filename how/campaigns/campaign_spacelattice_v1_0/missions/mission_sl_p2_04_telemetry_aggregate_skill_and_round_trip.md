---
type: mission
mission_id: mission_sl_p2_04_telemetry_aggregate_skill_and_round_trip
campaign: campaign_spacelattice_v1_0
campaign_phase: 2
campaign_mission_number: 4
status: planned
mission_class: integration
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p2, telemetry, aggregate, round_trip, phase_gate]
blocked_by: [mission_sl_p2_03_telemetry_submit_skill]
---

# Mission — P2-04: skill_telemetry_aggregate + first round-trip (P2 phase-gate)

**Phase**: P2 — Sustainability + telemetry implementation.
**Class**: integration.

## Objective

Promote `how/standard/skills/skill_telemetry_aggregate.md` from stub to full maintainer-side procedure (poll → parse → validate → append to inbox → cross-fleet pattern detection). Execute the **first end-to-end telemetry round-trip**: operator submits demo telemetry → maintainer aggregates → ADR drafted → publish round-trip — phase-gate evidence for closing P2.

## Deliverables

- Full `skill_telemetry_aggregate.md` (replaces stub):
  - Periodic poll via `gh api repos/.../issues?labels=telemetry&state=all`
  - Parse + validate against P2-02 schema; reject malformed
  - Append to `who/peers/telemetry/inbox/<utc>.md` (committed audit trail)
  - Cross-fleet pattern detection (initial: 5+ identical friction signals → ADR draft trigger)
- ADR: `adr_011_<slug>.md` ratifying the aggregate-skill lock-in
- **Round-trip test artifacts**:
  - Demo telemetry submission (`who/peers/telemetry/sent/<utc>.md` — operator-local)
  - GitHub issue created (URL recorded in mission AAR)
  - Maintainer-side aggregation evidence: `who/peers/telemetry/inbox/<utc>.md` populated and committed
  - Demo ADR draft showing the loop closed
- **P2 phase-gate evidence**: round-trip demonstrated end-to-end (mandatory)

## Estimated effort

1-2 sessions.

## Dependencies

P2-03 closed.

## Reference

- `what/standard/telemetry.md` (post-p2_02 schema + framework)
- `how/standard/skills/skill_telemetry_aggregate.md` (current stub)
- `who/peers/telemetry/inbox/` (initial empty)
