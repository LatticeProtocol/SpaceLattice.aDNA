---
type: adr
adr_number: 010
title: "skill_telemetry_submit — canonical operator submission path"
status: accepted
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, telemetry, submit_skill, p2]
---

# ADR-010: skill_telemetry_submit — canonical operator submission path

## Status

Accepted

## Context

P2-02 (ADR-009) locked the telemetry schema: four submission classes, JSON Schema Draft-07 validation, privacy-posture table, and five telemetry-specific sanitization rules (LS-1 / CS-1 / DE-1 / SHA-1 / VER-1). The schema defines *what* a valid telemetry payload looks like.

P2-03 addresses *how* an operator constructs, validates, and submits that payload. Without a canonical path:
- Operators hand-crafting JSON would introduce sanitization gaps (no automated scan)
- Schema compliance would be unverifiable before submission
- Submission auditing (local receipts) would be inconsistent across forks

The submission channel (GitHub Issues, label `telemetry`, repo `LatticeProtocol/SpaceLattice.aDNA`) was ratified in ADR-005. ADR-009 locks the schema. This ADR locks the execution path.

## Decision

Ratify `how/standard/skills/skill_telemetry_submit.md` as the canonical operator-side telemetry submission path. The skill implements a seven-step gate sequence:

1. **Consent check** — operator profile (`who/operators/<operator>.md`) must have `telemetry_consent: true` and the relevant per-class opt-in enabled
2. **Collect** — agent constructs the payload from source material (sessions, ADRs, snippets, metrics); operator does not hand-write JSON
3. **Sanitize** — LAYER_CONTRACT §4 base scan + telemetry-specific extensions; FAIL aborts
4. **Validate** — `jsonschema` against `what/standard/telemetry_schema.json`; FAIL aborts
5. **Confirm** — operator sees the full payload and explicitly approves; supports `--dry-run` flag
6. **Submit** — `gh issue create` against `LatticeProtocol/SpaceLattice.aDNA` with `telemetry` label
7. **Audit-write** — local receipt written to `who/peers/telemetry/sent/<utc>.md` (gitignored)

Additionally, create `.github/ISSUE_TEMPLATE/telemetry.yml` in this vault so GitHub's web UI enforces the same schema and sanitization acknowledgments for out-of-band submissions.

The `--withdraw <issue-number>` flag closes a previously-submitted issue via `gh issue close`.

## Consequences

### Positive

- Operators have a safe, schema-validated path from friction → upstream fleet data
- Sanitization is automated — no hand-auditing of JSON payloads
- Per-submission consent gates are enforced by the skill, not operator discipline
- Local receipts provide traceability without committing telemetry to the vault's git history
- `--dry-run` flag enables safe testing without live submissions
- GitHub issue form provides a fallback for web-UI submissions with the same confirmation checklist

### Negative

- Requires `gh` CLI authenticated against `github.com/LatticeProtocol/SpaceLattice.aDNA`
- Requires `python3` + `jsonschema` library on the operator's machine
- Operators who lose their local `sent/` receipts cannot recover submission history (by design — receipts are local audit trail, not shared)

### Neutral

- Full `jsonschema` constraint validation (regex patterns, `minLength`) requires `jsonschema` library; a future hardening pass can add a `pip install jsonschema` prerequisite check to the skill
- The GitHub issue form (`telemetry.yml`) renders labels only if the `telemetry` label exists on the upstream repo; until created, submissions fall back to unlabeled issues with a title prefix

## References

- ADR-005: Vault rename + telemetry channel (GitHub Issues) ratified
- ADR-009: Telemetry schema lock-in (4 submission classes, JSON Schema Draft-07, privacy-posture table, 5 sanitization extension rules)
- `what/standard/telemetry.md`: Full telemetry framework documentation
- `how/standard/skills/skill_telemetry_submit.md`: Implementation (this ADR ratifies)
- `.github/ISSUE_TEMPLATE/telemetry.yml`: GitHub issue form (this ADR ratifies)
- Mission: `mission_sl_p2_03_telemetry_submit_skill`
