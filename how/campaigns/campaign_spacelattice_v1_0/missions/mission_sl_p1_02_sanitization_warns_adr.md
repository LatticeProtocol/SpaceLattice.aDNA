---
type: mission
mission_id: mission_sl_p1_02_sanitization_warns_adr
campaign: campaign_spacelattice_v1_0
campaign_phase: 1
campaign_mission_number: 2
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p1, audit_closure, sanitization, adr]
blocked_by: []
---

# Mission — P1-02: Sanitization WARNs — ADR or upstream PR

**Phase**: P1 — Audit closure.
**Class**: implementation.

## Objective

Close audit finding #5: 2 sanitization WARNs (private IPv4 + email) emitted by `skill_publish_lattice` dry-run on every publish, originating in inherited `how/skills/skill_l1_upgrade.md`. Audit the patterns, decide formal disposition (ADR formally accepting as inherited-template debt vs. upstream PR to the `adna` template to fix), and execute.

## Deliverables

- Audit report: location of the 2 sanitization patterns in `skill_l1_upgrade.md`; context (illustrative vs. operational)
- Disposition decision recorded in mission notes
- If ADR path: `what/decisions/adr/adr_006_<slug>.md` formally accepting + a `LAYER_CONTRACT.md` § Exceptions entry
- If upstream-PR path: PR opened against `LatticeProtocol/adna` repo + vault-side ADR with `target: upstream` field tracking it
- `skill_publish_lattice` dry-run no longer emits the WARNs (or emits them with a documented `# acknowledged` annotation)
- STATE.md update: audit finding #5 → closed

## Estimated effort

1 session.

## Dependencies

None — parallel-capable with P1-01 and P1-03.

## Reference

- Genesis AAR § Gap Register #6: `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- `how/skills/skill_l1_upgrade.md` (inherited)
- `what/standard/LAYER_CONTRACT.md` § 4 (sanitization scan)
- `how/standard/skills/skill_publish_lattice.md` (dry-run produces the WARN evidence)
