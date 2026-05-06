---
type: adr
adr_number: 009
title: "Telemetry schema lock-in — JSON Schema Draft-07, 4 submission classes, privacy-posture table"
status: accepted
adr_kind: design
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
ratifies: what/standard/telemetry_schema.json
tags: [adr, telemetry, schema, privacy, design, daedalus, p2]
---

# ADR-009: Telemetry schema lock-in

## Status

Accepted

## Context

`what/standard/telemetry.md` (ratified by ADR-005) defined the telemetry feedback framework and named four submission classes (`friction_signal`, `adr_proposal`, `customization_share`, `perf_metric`) in YAML shape outline. The outline was marked `status: outline` pending a Phase 2 design mission (P2-02) to produce a machine-validated, privacy-annotated schema.

P2-01 closed (ADR-008) established the sustainability runbook. P2-02 is the natural next step: lock the telemetry schema so P2-03 (`skill_telemetry_submit` full implementation) and P2-04 (round-trip test + phase gate) have an authoritative, versioned schema to validate against.

Without a locked schema:
- Operator-side validation is ad-hoc and inconsistent across forks
- Maintainer-side aggregation can't reliably parse incoming issues
- Privacy posture is documented in prose only, not auditable per-field

## Decision

Lock the telemetry schema as **JSON Schema Draft-07** in a sibling file at `what/standard/telemetry_schema.json`. The schema:

1. Defines all 4 submission classes as `$defs` entries dispatched via `oneOf`
2. Annotates every field with its privacy class (ANON / PSEUDO / IDENT) in the JSON Schema `description` property
3. Enforces field types, enums, string patterns, and length constraints
4. Is referenced (not duplicated) from `telemetry.md` — the framework doc remains the human-readable source; the schema file is the machine-readable source

**Draft-07** chosen over 2020-12 for broadest tooling compatibility (`python jsonschema` lib default; Emacs `json-mode` validates against draft-07).

**Telemetry-specific sanitization extensions** (beyond LAYER_CONTRACT § 4) are codified in `telemetry.md` § Telemetry-specific sanitization extensions:

| Rule | Field | Constraint |
|------|-------|------------|
| LS-1 | `layer_set_hash` | Hash of filenames only, not content |
| CS-1 | `content_hash` | Salted+truncated SHA-256, 12 hex chars |
| DE-1 | `detection_evidence` | 1 sentence max, no paths/hostnames |
| SHA-1 | `spacemacs_sha` | 40-char hex only, no URL prefix |
| VER-1 | `emacs_version` | N.N or N.N.N format only |

**Operator-side validator stub** `adna/telemetry-validate` added to `what/standard/layers/adna/funcs.el`. Phase 2 stub confirms schema file loadable + payload has known `type`. Full `jsonschema` validation deferred to Phase 4.

**Maintainer-side parser snippet** added to `how/standard/skills/skill_telemetry_aggregate.md` (§ Maintainer parser snippet). Implements JSON extraction from issue body, type validation, per-class routing, and rejected-payload audit trail.

`what/standard/telemetry.md` status promoted from `outline` to `active`.

## Consequences

### Positive

- P2-03 and P2-04 have an authoritative schema to validate against — no schema drift between operator and maintainer sides
- Privacy posture is auditable per-field, not just prose-documented
- Fleet-level de-duplication (via `layer_set_hash`, `content_hash`) is mathematically defined, not approximated
- Sanitization extensions close gaps where LAYER_CONTRACT § 4 was insufficient for telemetry-specific fields
- JSON Schema is machine-validated — typos and structural errors caught before operator submits

### Negative

- Draft-07 will need migration if a future vault or downstream consumer requires 2020-12 features (unlikely for this schema's simplicity)
- `adna/telemetry-validate` is a Phase 2 stub — full field-level validation deferred to Phase 4; operators who install between P2 and P4 get type-check but not constraint-check

### Neutral

- `telemetry_schema.json` is a new tracked file in `what/standard/` — included in `skill_publish_lattice` rsync and sanitization scan (clean; no operator-home paths)
- The YAML shape outlines in `telemetry.md` §§ Submission contents remain as illustration; canonical source is the JSON Schema file
