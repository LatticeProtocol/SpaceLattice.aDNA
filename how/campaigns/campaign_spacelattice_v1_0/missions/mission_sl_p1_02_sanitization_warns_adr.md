---
type: mission
mission_id: mission_sl_p1_02_sanitization_warns_adr
campaign: campaign_spacelattice_v1_0
campaign_phase: 1
campaign_mission_number: 2
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [mission, completed, spacelattice, v1_0, p1, audit_closure, sanitization, adr_006]
completed: 2026-05-06
session: session_stanley_20260506_005521_p1_02_sanitization_warns
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

## Mission Notes (completed 2026-05-06)

**Audit findings:**

| WARN | Line | Match | Context |
|------|------|-------|---------|
| Private IPv4 | 230 | `10.42.0.1` | Nebula lighthouse ping verification step |
| Email (false positive) | 99 | `git@github.com` | Git SSH clone URL — matches email regex |

**Disposition: upstream-PR path** (both WARNs)

- WARN #1: Fixed locally — replaced `10.42.0.1` with `<lighthouse-ip>` placeholder. The actual lighthouse IP is deployment-specific (from operator's Nebula `config.yml`), making the placeholder more accurate. Upstream PR to `LatticeProtocol/adna` tracks the template fix.
- WARN #2: Documented as known false positive — `git@github.com` is a standard git SSH URL, not an email address. No content change needed. `LAYER_CONTRACT.md § 8` documents the pattern with bracket-escaped examples to prevent recursive scanner triggering.

**Verification:** sanitization scan (full publish scope) now emits exactly 1 WARN (`how/skills/skill_l1_upgrade.md:99: 'git@github.com'`) — the documented false positive. Zero private IPv4 WARNs.

**P1 Phase Gate:** ✅ all criteria met — P2 opens.

## AAR

- **Worked**: Dual-disposition (fix vs. document) cleanly separated the two WARN types; scan confirmation was fast and deterministic.
- **Didn't**: Adding literal patterns to LAYER_CONTRACT.md § 8 immediately triggered new WARNs — required bracket-escaping of domain names to prevent the scanner from matching its own documentation.
- **Finding**: LAYER_CONTRACT.md's sanitization documentation must itself be WARN-clean; escape inline patterns with `@[domain]` bracket notation to break TLD matching.
- **Change**: Future Known False Positives entries use bracket notation (`@[domain.tld]`) by default — add this as a convention note to the § 8 header.
- **Follow-up**: Upstream PR to `LatticeProtocol/adna` (URL in ADR-006 when merged); also open a PR to tighten the email regex to exclude git SSH URL patterns.
