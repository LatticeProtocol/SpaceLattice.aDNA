---
type: framework
status: active
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
implementation_phase: v1_0_campaign_p2
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
channel_choice: github_issues_with_telemetry_label
tags: [framework, telemetry, feedback_loop, agentic_sre, operator_gated, daedalus]
---

# Telemetry Feedback Framework — Operator-Gated Agentic SRE Loop

## Purpose

SpaceLattice.aDNA is designed to **improve itself** in two loops:

1. **Local loop** — `skill_self_improve` reads operator sessions, detects friction, drafts ADRs, operator gates. *(Already implemented; closes locally.)*
2. **Fleet loop** — telemetry from peer operators (with permission) flows back to the upstream vault repo, drives **agentic SRE** at the maintainer side, produces ADRs that ship in subsequent publishes. *(This document defines the frame; full implementation in v1.0 campaign Phase 2.)*

The operator is **always** the gate. No telemetry is submitted without explicit per-submission consent. Default opt-out.

## Schema file

The canonical machine-readable schema for all telemetry submissions lives at:

```
what/standard/telemetry_schema.json
```

JSON Schema Draft-07. Four submission classes defined as `$defs` entries, dispatched via `oneOf`. Each field is annotated with its privacy class (ANON / PSEUDO / IDENT) in the `description` property. Ratified by ADR-009.

To validate a payload file:
```bash
python3 -c "
import json, sys
schema = json.load(open('what/standard/telemetry_schema.json'))
payload = json.load(open(sys.argv[1]))
print('type:', payload.get('type', '(missing)'))
" path/to/payload.json
```

Full jsonschema validation (requires `pip install jsonschema`):
```bash
python3 -c "
import json, jsonschema, sys
schema = json.load(open('what/standard/telemetry_schema.json'))
payload = json.load(open(sys.argv[1]))
jsonschema.validate(payload, schema)
print('valid')
" path/to/payload.json
```

The elisp operator-side stub `adna/telemetry-validate` in `what/standard/layers/adna/funcs.el` wraps the basic parse check. Full jsonschema validation is deferred to Phase 4 (P4 layer hardening).

---

## Channel: GitHub Issues with `telemetry` label

Per ADR 005 lock-in. Operator submits via `skill_telemetry_submit` — a wrapper around `gh issue create` that:

- Anonymizes (hostname, username, paths stripped)
- Validates schema
- Tags with `telemetry`
- Includes a structured frontmatter-like body
- Confirms with operator before submission (no auto-submit)

Maintainer-side aggregation via `skill_telemetry_aggregate` — runs `gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues?labels=telemetry` to pull all telemetry issues, batch-process, drive upstream ADRs.

## Permission model

### Layered consent

```
operator-profile-level    →  who/operators/<name>.md     telemetry_consent: true | false
                                                            (master switch; default false)

submission-class-level    →  per-submission category opt-in:
                              friction_signals     :  default true if master is true
                              adr_proposals        :  default true
                              local_customizations :  default false (must opt in)
                              perf_metrics         :  default false (must opt in)

per-submission-level      →  always confirm: "Submit this telemetry payload? [y/N]"
                              skill_telemetry_submit shows the FULL payload before submitting
```

### Sanitization (mandatory, regardless of consent)

Per LAYER_CONTRACT § 4 sanitization scan. Before submission:

- Hostname literals → stripped (replaced with `<host>`)
- User-home paths → stripped (replaced with `~/`)
- Email addresses → stripped (unless explicit upstream attribution)
- Secret patterns → ABORT (never submit)
- IP addresses (private + public) → stripped
- Internal URL fragments → stripped

If sanitization fails (FAIL pattern matched), submission aborts. Operator decides whether to edit-and-retry or skip.

## Submission contents (illustration — canonical schema in `telemetry_schema.json`)

The YAML blocks below are illustrative shapes; the canonical, validated source is `what/standard/telemetry_schema.json` (JSON Schema Draft-07, ratified ADR-009). Privacy class annotations on each field use: **ANON** (no operator-linkable data), **PSEUDO** (hash/enum, linkable only with a key), **IDENT** (never permitted).

### Friction signals (default-on if telemetry enabled)

```yaml
type: friction_signal
detected_via_rule: A | B | C | D | E | F          # skill_self_improve rule that fired
signal_class: layer_load_error | slow_op | repeated_manual_fix | layer_conflict | duplicated_keybind
signal_count: <N>                                  # times observed in recent sessions
spacemacs_sha: <SHA>                               # operator's pinned SHA at time of observation
emacs_version: <version>
os: macOS | linux | wsl2
layer_set_hash: <hash of standard/layers.md>       # to correlate with similar configs
```

### ADR proposals (default-on)

```yaml
type: adr_proposal
adr_id_local: adr_NNN_<slug>                       # operator's local ADR ID
title: <title>
target_layer: standard | local
proposed_by: agent_self_improve
detection_evidence: <one-sentence anonymized>
diff_summary:
  files_changed: <N>
  lines_added: <N>
  lines_removed: <N>
operator_decision: accepted | rejected | deferred
```

### Local customizations (default-off; explicit opt-in)

```yaml
type: customization_share
target: dotspacemacs_init | layers_added | leader_keys_added | theme_overrides
content_hash: <hash>                                # for de-duplication, not the actual content
content_summary: <one-line description>
operator_motivation: <optional one-line>
```

### Performance metrics (default-off)

```yaml
type: perf_metric
boot_time_ms: <ms>
gcs_during_boot: <count>
emacs_memory_mb: <mb>
package_count: <count>
layer_count: <count>
```

## Telemetry-specific sanitization extensions

Beyond the base LAYER_CONTRACT § 4 scan, telemetry payloads have additional sanitization requirements before submission. These extend (not replace) the base rules:

| Rule ID | Field | Constraint | Rationale |
|---------|-------|------------|-----------|
| LS-1 | `layer_set_hash` | Hash MUST be computed from sorted layer **filenames only** — no file content, no absolute paths | Content hashing would fingerprint private configurations; filename-only hash is anonymous enough for fleet correlation |
| CS-1 | `content_hash` | MUST be salted+truncated SHA-256 (`SHA256(operator_salt + content)[:12]` hex chars) | Prevents rainbow-table reversal of shared customizations; salt is operator-local and never submitted |
| DE-1 | `detection_evidence` | One sentence maximum; no file paths, no hostnames, no variable names that embed paths | Human-written text is the highest-risk field in `adr_proposal` — enforced length + content rule |
| SHA-1 | `spacemacs_sha`, all classes | 40-char lowercase hex only — no `git@[github.com]:...` prefix, no branch names | URL-style SHA refs could leak repository topology |
| VER-1 | `emacs_version` | `N.N` or `N.N.N` format only — no build dates, no distribution names | Build-date strings can fingerprint specific package manager installs |

These rules are checked by `adna/telemetry-validate` (operator side) and the maintainer-side parser in `skill_telemetry_aggregate` before aggregation.

## Privacy posture per field

Every field from all 4 submission classes. Privacy classes: **ANON** = no operator-linkable data; **PSEUDO** = hash or small enum (linkable only with a key or prior knowledge); **IDENT** = never permitted in telemetry payloads.

### friction_signal

| Field | Privacy class | Notes |
|-------|--------------|-------|
| `type` | ANON | Const discriminator — "friction_signal" |
| `detected_via_rule` | ANON | Enum A–F; alphabetic labels carry no operator context |
| `signal_class` | ANON | 5-value enum; no operator identity |
| `signal_count` | ANON | Integer; aggregate observation count |
| `spacemacs_sha` | ANON | 40-char public commit SHA; see rule SHA-1 |
| `emacs_version` | ANON | Version triplet; see rule VER-1 |
| `os` | ANON | 3-value enum (macOS / linux / wsl2) |
| `layer_set_hash` | PSEUDO | 16-hex truncated hash of filenames only; see rule LS-1; correlation key for fleet matching |

### adr_proposal

| Field | Privacy class | Notes |
|-------|--------------|-------|
| `type` | ANON | Const discriminator |
| `adr_id_local` | PSEUDO | Numeric sequence (`adr_NNN_slug`) — sequence may correlate multiple submissions from same operator |
| `title` | PSEUDO | Operator-written text; sanitization mandatory; no paths/hostnames/names |
| `target_layer` | ANON | 2-value enum (standard / local) |
| `proposed_by` | ANON | 2-value enum (agent_self_improve / operator_manual) |
| `detection_evidence` | PSEUDO | Operator/agent-written text; 200-char max; see rule DE-1 |
| `diff_summary.files_changed` | ANON | Integer |
| `diff_summary.lines_added` | ANON | Integer |
| `diff_summary.lines_removed` | ANON | Integer |
| `operator_decision` | ANON | 3-value enum (accepted / rejected / deferred) |

### customization_share

| Field | Privacy class | Notes |
|-------|--------------|-------|
| `type` | ANON | Const discriminator |
| `target` | ANON | 4-value enum; no operator identity |
| `content_hash` | PSEUDO | Salted+truncated 12-hex hash; see rule CS-1; linkable for de-dup only |
| `content_summary` | PSEUDO | Operator-written text; 100-char max; sanitization mandatory |
| `operator_motivation` | PSEUDO | Optional operator-written text; 200-char max; sanitization mandatory |

### perf_metric

| Field | Privacy class | Notes |
|-------|--------------|-------|
| `type` | ANON | Const discriminator |
| `boot_time_ms` | ANON | Integer; hardware-influenced but not personally identifying |
| `gcs_during_boot` | ANON | Integer |
| `emacs_memory_mb` | ANON | Numeric; system-influenced |
| `package_count` | ANON | Integer |
| `layer_count` | ANON | Integer |
| `spacemacs_sha` | ANON | 40-char public commit SHA; see rule SHA-1 |
| `emacs_version` | ANON | Version triplet; see rule VER-1 |
| `os` | ANON | 3-value enum |

**IDENT fields**: no field in any submission class is classified IDENT. Operator identity (username, hostname, email, paths) is stripped by LAYER_CONTRACT § 4 sanitization before any payload is built. Fields that could approach IDENT (e.g., free-text `operator_motivation`) are capped at 200 chars and mandatory-sanitized — classified PSEUDO, not IDENT.

## Aggregation flow (upstream side)

Maintainer agent at the upstream vault repo:

1. Periodic poll: `gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues?labels=telemetry&state=all`
2. Parse each issue body (structured frontmatter)
3. Validate schema; reject malformed
4. Append to `who/peers/telemetry/inbox/<utc>.md` (committed audit trail; aggregated, not raw)
5. Run upstream `skill_self_improve_aggregate` (designed by planning mission):
   - Detect cross-fleet patterns (e.g., 5+ operators hit same friction signal)
   - Draft upstream ADR proposing fix
   - Maintainer gates
6. Accepted ADR → standard/ change → next publish (`skill_publish_lattice`) → operators pull update

## Feedback loop diagram

```
┌────────────────────── operator session ──────────────────────┐
│  friction observed                                            │
│    ↓                                                          │
│  skill_self_improve drafts ADR + diff + dry-run               │
│    ↓                                                          │
│  operator gates: accept | reject | defer                      │
│    ↓ (if accepted)                                            │
│  ADR commits in operator's local vault                        │
│    ↓                                                          │
│  skill_telemetry_submit (operator-gated, sanitized)           │
│    ↓                                                          │
│  GitHub issue (anonymized)                                    │
└───────────────────────────┬───────────────────────────────────┘
                            ↓
┌──────────────── upstream vault maintainer ─────────────────────┐
│  skill_telemetry_aggregate (periodic poll)                    │
│    ↓                                                          │
│  who/peers/telemetry/inbox/<utc>.md (audit trail)             │
│    ↓                                                          │
│  pattern detection across fleet                               │
│    ↓ (if pattern fires)                                       │
│  upstream skill_self_improve_aggregate drafts ADR             │
│    ↓                                                          │
│  maintainer gates                                             │
│    ↓ (if accepted)                                            │
│  ADR landed in upstream what/standard/                        │
│    ↓                                                          │
│  skill_publish_lattice → published mirror updated             │
└───────────────────────────┬───────────────────────────────────┘
                            ↓
┌────────────────── operator pulls update ───────────────────────┐
│  git pull on local fork                                        │
│    ↓                                                          │
│  skill_deploy reapplies                                       │
│    ↓                                                          │
│  benefit returns to fleet — original friction now fixed       │
└──────────────────────────────────────────────────────────────┘
```

This is the **agentic SRE loop**: telemetry-driven, operator-gated, deterministic, auditable.

## Where telemetry lives in the vault

| Location | Purpose | Tracked? |
|----------|---------|----------|
| `who/peers/telemetry/outbox/` | Operator's queued submissions before send | ❌ gitignored (per-machine) |
| `who/peers/telemetry/sent/` | Operator's local copy of submitted telemetry | ❌ gitignored |
| `who/peers/telemetry/inbox/` | **Upstream maintainer side**: aggregated incoming telemetry | ✅ committed (audit trail; sanitized + anonymized) |
| `what/standard/telemetry.md` | This framework doc | ✅ |
| `how/standard/skills/skill_telemetry_submit.md` | Submit skill (stub now; full in v1.0 P2) | ✅ |
| `how/standard/skills/skill_telemetry_aggregate.md` | Aggregate skill (stub now; full in v1.0 P2) | ✅ |

## .gitignore rules

```
/who/peers/telemetry/outbox/
/who/peers/telemetry/sent/
```

(Inbox is committed because it's the upstream's aggregated audit trail; outbox/sent are operator-local.)

## Privacy posture (principles)

Full per-field classification: see § Privacy posture per field above.

- **Operator owns submission cadence** — no auto-submit, no agent override
- **Anonymization mandatory** — sanitization scan (LAYER_CONTRACT § 4 + telemetry-specific extensions above) runs first; FAIL aborts
- **Audit trail symmetric** — operator can verify what was submitted (`who/peers/telemetry/sent/<utc>.md` mirrors the issue body); maintainer's aggregated inbox is also tracked
- **Right to delete** — operators can `gh issue delete` their own telemetry issues; maintainer-side aggregate inbox carries the issue ID for traceability but the ADR-derived patterns won't include the original issue if deleted (must run aggregate again)
- **No IDENT fields** — no field in any submission class carries operator identity; see per-field table

## Cadence (initial proposal; M-Planning-01 confirms)

| Operator cadence | Default | Override |
|-------------------|---------|----------|
| Per session | Off | Operator can enable per-session telemetry summary |
| Weekly | Off | Operator can enable weekly batch (skill prompts) |
| On request | On (when explicitly invoked) | `M-x adna/submit-telemetry` |

Maintainer cadence: weekly aggregate + monthly pattern review.

## Integration with skill_self_improve

`skill_self_improve` does NOT auto-submit telemetry. It drafts ADRs locally. After operator-gated commit, the operator can OPTIONALLY invoke `skill_telemetry_submit` referencing that ADR. Bridge:

```
skill_self_improve → ADR committed in local vault
                  → operator (optional) → skill_telemetry_submit → telemetry issue
                  → fleet aggregation
```

The two skills are independent. Self-improve works without telemetry; telemetry works without auto-self-improve. Together they close the agentic SRE loop.

## Implementation status (v1.0 P2)

| Deliverable | Mission | Status |
|-------------|---------|--------|
| JSON Schema (full, Draft-07) | P2-02 | ✅ `what/standard/telemetry_schema.json` — ADR-009 |
| Telemetry-specific sanitization extensions | P2-02 | ✅ § Telemetry-specific sanitization extensions above |
| Privacy-posture table per field | P2-02 | ✅ § Privacy posture per field above |
| Operator-side validator stub (`adna/telemetry-validate`) | P2-02 | ✅ `what/standard/layers/adna/funcs.el` |
| Maintainer-side parser snippet | P2-02 | ✅ `how/standard/skills/skill_telemetry_aggregate.md` |
| `skill_telemetry_submit` complete procedure | P2-03 | ⬜ next mission |
| `skill_telemetry_aggregate` complete procedure | P2-03/P2-04 | ⬜ planned |
| GitHub issue template (`.github/ISSUE_TEMPLATE/telemetry.yml`) | P2-03 | ⬜ planned |
| First round-trip test | P2-04 | ⬜ planned (phase-gate evidence) |

## References

- ADR 005 (channel choice): `what/decisions/adr/adr_005_rename_to_spacelattice.md`
- Sanitization scan (LAYER_CONTRACT § 4): `what/standard/LAYER_CONTRACT.md`
- Self-improvement loop: `how/standard/skills/skill_self_improve.md`
- Sustainability framework: `what/standard/sustainability.md`
- Stub skills: `how/standard/skills/skill_telemetry_{submit,aggregate}.md`
