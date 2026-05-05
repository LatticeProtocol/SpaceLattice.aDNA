---
type: skill
skill_type: agent
status: stub
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
category: telemetry
trigger: "Operator wants to submit anonymized telemetry to the SpaceLattice.aDNA upstream channel — typically after a skill_self_improve cycle landed an ADR worth sharing with the fleet."
phase_introduced: 8
implementation_status: stub_design_pending_v1_0_p2_mission
tags: [skill, telemetry, submit, operator_gated, stub, daedalus]
requirements:
  tools: [gh, python3, "PyYAML"]
  context:
    - what/standard/telemetry.md
    - what/standard/LAYER_CONTRACT.md
    - who/operators/<operator>.md (consent state)
  permissions:
    - "read what/local/, what/standard/, what/decisions/"
    - "execute sanitization scan"
    - "gh issue create against LatticeProtocol/SpaceLattice.aDNA"
---

# skill_telemetry_submit — submit anonymized telemetry (STUB)

## Purpose (stub)

Wrapper around `gh issue create` that submits anonymized telemetry to the upstream `LatticeProtocol/SpaceLattice.aDNA` repo with the `telemetry` label.

Operator-gated. Default opt-out per `who/operators/<operator>.md` `telemetry_consent` field. Mandatory sanitization scan before submission.

## Status

**STUB** — full procedure designed by M-Planning-01 (v1.0 campaign Phase 0) and implemented in Phase 2.

This stub exists so:
- The skill name + path are reserved
- `what/standard/telemetry.md` and ADR 005 can reference it
- Future missions know where to land the implementation

## Outline (placeholder for full implementation)

### Steps (intent only — full procedure in Phase 2)

1. **Check consent**: read `who/operators/<operator>.md` for `telemetry_consent: true` and per-class opt-ins
2. **Build payload**: from operator's recent ADRs, friction signals, perf metrics (per consent classes)
3. **Anonymize**: run LAYER_CONTRACT § 4 sanitization scan + telemetry-specific extensions
4. **Validate schema**: against the JSON Schema (designed by M-Planning-01)
5. **Confirm with operator**: show full payload, ask "Submit? [y/N]"
6. **Submit**: `gh issue create --repo LatticeProtocol/SpaceLattice.aDNA --label telemetry --title <title> --body <body>`
7. **Record in outbox**: `who/peers/telemetry/sent/<utc>.md` (gitignored audit copy)

### Hard rules (stub)

1. **Sanitization scan must pass.** No FAIL. WARNs require operator acknowledgment.
2. **Operator confirms each submission.** No batch auto-submit.
3. **Default opt-out.** Master consent switch in operator profile must be `true`.
4. **No secrets ever.** Pattern match must be perfect; if any doubt, abort.

## Reference

- Framework: `what/standard/telemetry.md`
- Sanitization: `what/standard/LAYER_CONTRACT.md` § 4
- Companion skill: `how/standard/skills/skill_telemetry_aggregate.md` (upstream side)
- Self-improvement bridge: `how/standard/skills/skill_self_improve.md`
- Implementation timeline: v1.0 campaign Phase 2 (designed by M-Planning-01)

## Implementation note for the planning mission

This skill's full implementation should:

1. Be entirely operator-driven (no agent auto-submit even when consent is `true`)
2. Show the FULL payload before submission so operator can verify anonymization worked
3. Cache the issue URL/number in `who/peers/telemetry/sent/<utc>.md` for traceability
4. Provide `--dry-run` flag that prints the payload without submitting
5. Provide `--withdraw <issue-number>` to delete a previously-submitted issue (uses `gh issue delete`)
