---
type: framework
status: outline
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
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

## Submission contents (schema outline)

The full schema is designed by M-Planning-01 (v1.0 campaign Phase 2). Outline:

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

## Privacy posture

- **Operator owns submission cadence** — no auto-submit, no agent override
- **Anonymization mandatory** — sanitization scan runs first; FAIL aborts
- **Audit trail symmetric** — operator can verify what was submitted (`who/peers/telemetry/sent/<utc>.md` mirrors the issue body); maintainer's aggregated inbox is also tracked
- **Right to delete** — operators can `gh issue delete` their own telemetry issues; maintainer-side aggregate inbox carries the issue ID for traceability but the ADR-derived patterns won't include the original issue if deleted (must run aggregate again)

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

## Implementation deferred to v1.0 campaign Phase 2

- Schema details (full YAML / JSON Schema)
- `skill_telemetry_submit` complete procedure (currently stub)
- `skill_telemetry_aggregate` complete procedure (currently stub)
- Sanitization scan extension (telemetry-specific patterns beyond LAYER_CONTRACT § 4)
- First round-trip test: operator submits demo telemetry → maintainer aggregates → ADR drafted → publish round-trip
- GitHub issue template (`.github/ISSUE_TEMPLATE/telemetry.yml`) authored

## References

- ADR 005 (channel choice): `what/decisions/adr/adr_005_rename_to_spacelattice.md`
- Sanitization scan (LAYER_CONTRACT § 4): `what/standard/LAYER_CONTRACT.md`
- Self-improvement loop: `how/standard/skills/skill_self_improve.md`
- Sustainability framework: `what/standard/sustainability.md`
- Stub skills: `how/standard/skills/skill_telemetry_{submit,aggregate}.md`
