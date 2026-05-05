---
type: mission
mission_id: mission_sl_p2_03_telemetry_submit_skill
campaign: campaign_spacelattice_v1_0
campaign_phase: 2
campaign_mission_number: 3
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p2, telemetry, submit_skill]
blocked_by: [mission_sl_p2_02_telemetry_schema]
---

# Mission — P2-03: skill_telemetry_submit — full procedure

**Phase**: P2 — Sustainability + telemetry implementation.
**Class**: implementation.

## Objective

Promote `how/standard/skills/skill_telemetry_submit.md` from stub to full procedure. The skill wraps `gh issue create` to submit operator-gated telemetry: validates against the P2-02 schema, runs sanitization scan (LAYER_CONTRACT § 4 + telemetry extensions), confirms with the operator (full payload preview), submits, writes audit copy to `who/peers/telemetry/sent/`, tags the issue with `telemetry`. Author `.github/ISSUE_TEMPLATE/telemetry.yml` for the upstream repo so even web-form submissions enforce the schema.

## Deliverables

- Full `skill_telemetry_submit.md` (replaces stub) with step-by-step:
  - Collect → validate (schema) → sanitize (LAYER_CONTRACT § 4 + telemetry extensions) → confirm-with-operator → submit-via-gh-cli → audit-write → tag
  - Failure modes: sanitization FAIL → ABORT; gh auth missing → fail with remediation; schema mismatch → fail with diff
- `.github/ISSUE_TEMPLATE/telemetry.yml` (GitHub issue form enforcing the schema, suitable for the upstream `LatticeProtocol/SpaceLattice.aDNA` repo)
- `.gitignore` confirms `who/peers/telemetry/{outbox,sent}/` are gitignored (operator-local)
- ADR: `adr_010_<slug>.md` ratifying the submit-skill lock-in
- Demo invocation against a test telemetry payload (operator confirms; demo issue can be deleted post-validation)

## Estimated effort

1-2 sessions.

## Dependencies

P2-02 closed (schema is required to validate).

## Reference

- `what/standard/telemetry.md` (post-p2_02 schema)
- `how/standard/skills/skill_telemetry_submit.md` (current stub)
- GitHub Issue Forms documentation (for `.github/ISSUE_TEMPLATE/telemetry.yml`)
