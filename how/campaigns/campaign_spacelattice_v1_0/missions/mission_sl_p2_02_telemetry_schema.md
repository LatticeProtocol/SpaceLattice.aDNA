---
type: mission
mission_id: mission_sl_p2_02_telemetry_schema
campaign: campaign_spacelattice_v1_0
campaign_phase: 2
campaign_mission_number: 2
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p2, telemetry, schema]
blocked_by: [mission_sl_p2_01_sustainability_runbook_teeth]
---

# Mission — P2-02: Telemetry schema lock-in

**Phase**: P2 — Sustainability + telemetry implementation.
**Class**: implementation.

## Objective

Promote the telemetry schema in `what/standard/telemetry.md` from outline to full schema. Author JSON Schema (or YAML schema) for each of the 4 submission classes (`friction_signal`, `adr_proposal`, `customization_share`, `perf_metric`), document telemetry-specific anonymization extension patterns beyond `LAYER_CONTRACT § 4`, define operator-side and maintainer-side validation logic, and verify privacy posture per field.

## Deliverables

- Full JSON Schema per submission class (in `what/standard/telemetry.md` body OR a sibling `what/standard/telemetry_schema.json` referenced from the framework doc)
- Telemetry-specific sanitization extensions (e.g., layer-name-as-identifier, version-string-as-fingerprint patterns)
- Operator-side validator: skill stub or elisp function in `what/standard/layers/adna/funcs.el` (`adna/telemetry-validate`)
- Maintainer-side validator: parser snippet in `skill_telemetry_aggregate` (used at P2-04)
- Privacy-posture table: each schema field annotated with privacy class (anonymous / pseudonymous / identifiable)
- ADR: `adr_009_<slug>.md` ratifying the schema lock-in
- `what/standard/telemetry.md` `status: outline` → `status: active`

## Estimated effort

1-2 sessions.

## Dependencies

P2-01 closed (sustainability runbook teeth provides context for what telemetry needs to capture).

## Reference

- `what/standard/telemetry.md` (current outline)
- `what/standard/LAYER_CONTRACT.md` § 4 (sanitization scan baseline)
- `who/peers/telemetry/` directory structure (defined in framework)
