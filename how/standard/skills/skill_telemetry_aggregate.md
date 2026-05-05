---
type: skill
skill_type: agent
status: stub
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
category: telemetry
trigger: "Maintainer-side: periodic poll of upstream LatticeProtocol/SpaceLattice.aDNA telemetry-labeled issues. Aggregates fleet signals into who/peers/telemetry/inbox/ for cross-fleet pattern analysis."
phase_introduced: 8
implementation_status: stub_design_pending_v1_0_p2_mission
tags: [skill, telemetry, aggregate, maintainer, upstream, agentic_sre, stub, daedalus]
requirements:
  tools: [gh, python3, "PyYAML"]
  context:
    - what/standard/telemetry.md
  permissions:
    - "gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues (read-only against the upstream)"
    - "write who/peers/telemetry/inbox/"
    - "(does not submit ADRs; companion skill skill_self_improve_aggregate proposes those, also TBD)"
---

# skill_telemetry_aggregate — aggregate fleet telemetry (STUB)

## Purpose (stub)

Maintainer-side skill that polls the upstream `LatticeProtocol/SpaceLattice.aDNA` repo's telemetry-labeled issues, aggregates them into `who/peers/telemetry/inbox/<utc>.md` audit-trail files, and surfaces cross-fleet patterns to drive upstream ADR proposals.

The fleet-loop counterpart of operator-side `skill_telemetry_submit`.

## Status

**STUB** — full procedure designed by M-Planning-01 (v1.0 campaign Phase 0) and implemented in Phase 2.

## Outline (placeholder for full implementation)

### Steps (intent only — full procedure in Phase 2)

1. **Poll issues**: `gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues?labels=telemetry&state=all --paginate`
2. **Parse each issue body**: structured frontmatter-style payload per `what/standard/telemetry.md` schema
3. **Validate schema**: skip malformed (log and label `telemetry-malformed` for human review)
4. **Aggregate** by signal class, time window, signal count
5. **Write audit batch**: `who/peers/telemetry/inbox/<utc>_aggregate.md` with frontmatter:
   ```yaml
   type: telemetry_aggregate
   batch_window: <ISO8601_start>/<ISO8601_end>
   issue_count: <N>
   signals_by_class: {...}
   patterns_detected: [...]
   ```
6. **Pattern detection**: if N+ operators hit the same friction signal, surface as `pattern_<id>.md` in inbox
7. **Hand off to `skill_self_improve_aggregate`** (companion skill, also TBD): drafts upstream ADR proposing fleet-level fix

### Hard rules (stub)

1. **Read-only against upstream.** Doesn't modify telemetry issues; doesn't auto-close them.
2. **Audit trail symmetric.** Aggregate output is committed (not gitignored) so peers can verify what's been aggregated.
3. **De-dup by issue ID.** Re-running the skill processes only new issues since last batch.
4. **Maintainer gates the next step.** This skill aggregates; ADR proposals from aggregates require maintainer approval.

## Reference

- Framework: `what/standard/telemetry.md`
- Companion skill: `how/standard/skills/skill_telemetry_submit.md` (operator side)
- Bridge to self-improve: future `skill_self_improve_aggregate` (upstream version of self-improve, fleet-aware)
- Implementation timeline: v1.0 campaign Phase 2 (designed by M-Planning-01)

## Implementation note for the planning mission

This skill's full implementation should:

1. Run idempotently — re-runs catch up from last batch
2. Track last-processed issue ID in `who/peers/telemetry/inbox/_state.json` (gitignored)
3. Provide cross-fleet correlation primitives (group by spacemacs_sha + os + signal_class)
4. Emit pattern_*.md files with severity scoring (P+M operators see same friction → priority bumps)
5. Include opt-in for maintainer to ping operators if their issue needs more info (via issue comment, not separate channel)
