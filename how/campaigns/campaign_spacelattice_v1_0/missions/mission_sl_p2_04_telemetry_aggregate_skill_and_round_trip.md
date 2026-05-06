---
type: mission
mission_id: mission_sl_p2_04_telemetry_aggregate_skill_and_round_trip
campaign: campaign_spacelattice_v1_0
campaign_phase: 2
campaign_mission_number: 4
status: completed
mission_class: integration
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [mission, completed, spacelattice, v1_0, p2, telemetry, aggregate, round_trip, phase_gate]
blocked_by: []
completed_at: 2026-05-06
session: session_stanley_20260506T053454Z_p2_04_telemetry_aggregate
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
- `how/standard/skills/skill_telemetry_aggregate.md` (promoted to active — ADR-011)
- `who/peers/telemetry/inbox/20260506T053941Z_aggregate.md` (round-trip evidence)
- `who/peers/telemetry/inbox/demo_adr_draft_p2_04.md` (loop-closed evidence)
- ADR-011: `what/decisions/adr/adr_011_skill_telemetry_aggregate.md`

## Completion notes

All deliverables completed in session `session_stanley_20260506T053454Z_p2_04_telemetry_aggregate` (2026-05-06):

- ✅ `skill_telemetry_aggregate.md` — stub → full 7-step procedure; `status: active`; ADR-011 ratifies
- ✅ `adr_011_skill_telemetry_aggregate.md` — accepted
- ✅ Round-trip test: GitHub Issue #1 submitted (operator side); parsed + aggregated (maintainer side); inbox entry committed
- ✅ Demo ADR draft: `who/peers/telemetry/inbox/demo_adr_draft_p2_04.md` committed
- ✅ P2 phase-gate evidence: all 7 criteria met
- ✅ AAR: `missions/artifacts/aar_mission_sl_p2_04.md`
