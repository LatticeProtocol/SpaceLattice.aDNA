---
type: runbook
status: active
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
ratified_by: how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_planning_01.md
applies_to: campaign_spacelattice_v1_0/missions/mission_sl_p3_*
tags: [runbook, customization, user_in_the_loop, p3, daedalus]
---

# Customization Session Protocol — User-in-the-Loop

## Purpose

Generic 7-step protocol applied across every Phase-3 customization mission of the v1.0 campaign. Each P3 mission walks one or more dimensions from the customization reference (`what/context/spacemacs/spacemacs_customization_reference.md`) with operator-in-the-loop. This runbook defines the per-mission interaction shape so missions can be authored as scaffolds without duplicating protocol text.

## Scope

Applies to: `mission_sl_p3_01_*` through `mission_sl_p3_08_*`. Optional reference for any future operator-in-loop mission outside P3 (e.g., post-v1.0 customization re-walks).

Does **not** apply to: P1 audit closure missions (mostly agent-driven), P2 implementation missions (skill authoring, schema design), P4 fork branding (mechanical execution), P5 polish (closeout).

## Pre-conditions

- Mission file `status: ready` (operator-triggered)
- `who/operators/<name>.md` operator profile exists (created on first P3 mission if missing)
- Customization reference loaded into context
- Vault git status clean (or operator acknowledges in-progress work)

## The 7 steps

### Step 1 — Mission opens; operator confirms readiness

Agent reports:

- Mission ID + title
- Dimensions covered (cite reference §§)
- Estimated time (operator's session-count target)
- What artifacts will be produced (operator profile entries, layer changes, ADRs)

Operator responds:

- "Proceed" — mission begins
- "Defer" — mission stays `planned`, agent exits
- "Reduce scope" — agent re-frames within session budget; operator confirms

Agent does **not** start substantive reads or edits before this gate.

### Step 2 — Reference excerpt loaded

Agent loads the **specific** reference paragraphs (cite numbered subsections from `spacemacs_customization_reference.md`) for the mission's dimension(s). Avoid loading the full reference if a few subsections suffice — context budget is doctrine.

If multiple subsections cover the same surface (e.g., §1.6 + §4A.4 both touch theme), agent presents both and notes overlap.

### Step 3 — Structured Q&A

Agent presents the dimension's options as a structured choice — one question per knob, with:

- The variable / file / setting name
- Default (verbatim from reference)
- Options (enum or "open-ended")
- Recommendation (if any) with one-line rationale
- "Skip / use default" always available

Format: bulleted list with operator picking inline. No bulk forms.

For variables with many options (e.g., `dotspacemacs-themes`), agent may pre-narrow to 3-5 candidates with rationale.

### Step 4 — Operator answers; decisions recorded

For each answered question, agent appends to `who/operators/<name>.md` under a per-mission heading:

```markdown
## Mission p3_<NN>_<slug> (closed YYYY-MM-DD)

### Dimension X (reference §Y.Z)

- **Variable**: `dotspacemacs-foo`
- **Decision**: `'bar`
- **Reason**: <operator's stated reason or "operator preference">
```

Decisions are immutable once recorded. Subsequent missions can re-open via a follow-up mission, not by editing prior records.

### Step 5 — Agent drafts changes

Based on decisions, agent drafts changes in the appropriate place:

| Target | Mechanism |
|--------|-----------|
| Operator-private only | Edit `what/local/operator.private.el` directly |
| New layer | `skill_layer_add` (ADR + dry-run + diff) |
| Existing layer modification | `skill_self_improve` (Rule appropriate to the change) |
| Standard `dotfile.spacemacs.tmpl` change | ADR + edit + dry-run via `skill_health_check` |
| Standard layer (`what/standard/layers/adna/`) change | `skill_self_improve` Rule + ADR |
| Promotion of validated local pattern to standard | `skill_layer_promote` (sanitization-gated) |

Agent presents each diff individually before the next operator gate.

### Step 6 — Operator gates each diff

For each drafted change:

- Agent shows the diff
- Operator: "accept", "reject", or "modify-then-accept"
- On accept: agent applies + runs `skill_health_check` (where applicable)
- On reject: change is discarded; operator decision is recorded as "deferred" in profile
- On modify: operator dictates the modification; agent re-drafts; loop

No batch acceptance — every diff is gated individually. This is non-negotiable for standard-layer changes per Standing Order #11.

### Step 7 — Mission close: AAR captures decisions + artifacts

Agent appends an AAR to `missions/artifacts/aar_mission_sl_p3_<NN>_<slug>.md` per `template_aar.md`:

- Scorecard: each dimension's decision recorded vs. deferred
- Operator profile diff: lines added under the mission's heading
- Artifacts: ADRs filed, layer changes committed, local-only edits noted
- Lessons learned: surprises, pattern emergence, candidate promotions for future missions
- Readiness: GO/NO-GO for the next P3 mission (typically GO)

Mission `status: completed`. Operator triggers next P3 mission when ready.

## Failure modes

| Failure | Symptom | Mitigation |
|---------|---------|------------|
| Operator hits decision fatigue mid-mission | Slowing answers, "I don't know" pile-up | Pause; mark remaining questions as "deferred to follow-up mission"; close current mission with partial scorecard |
| Diff fails `skill_health_check` dry-run | Layer load error or byte-compile fail | Reject the diff; surface error to operator; re-draft or defer dimension |
| Decision conflicts with prior mission's recorded decision | Agent detects conflict during Step 4 | Stop; surface conflict to operator; either revise prior record (with audit note) or accept new decision and mark prior as superseded |
| Mid-mission operator wants to change a prior dimension | Operator says "actually go back to X" | Open a follow-up mission for the prior dimension; do not retroactively edit |
| Reference paragraph missing or contradictory | Agent finds gap in §X.Y | Flag in mission AAR's gap register; treat dimension's decision as deferred until reference is updated |

## Cross-cutting rules

- **Context budget is doctrine** (Standing Order #3). If the dimension's reference subsection plus the operator profile plus draft diff would exceed comfortable single-session context, narrow the mission's dimension scope.
- **Layer discipline is doctrine**. Operator-only choices land in `what/local/`. Shared patterns require `skill_layer_promote` (sanitization-gated). Never assume an operator's choice is safe to commit to standard.
- **AAR before status: completed** (Standing Order #5). No exceptions.
- **No auto-commits to standard** (Standing Order #11). Every standard-layer change is operator-gated per diff.

## References

- Customization reference: `what/context/spacemacs/spacemacs_customization_reference.md`
- Skill authoring: `how/standard/skills/{skill_layer_add,skill_layer_promote,skill_self_improve,skill_health_check}.md`
- Operator profile: `who/operators/<name>.md`
- AAR template: `how/templates/template_aar.md`
- Campaign master: `how/campaigns/campaign_spacelattice_v1_0/campaign_spacelattice_v1_0.md`
- Mission spec: `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_planning_01.md` (deliverable #10)
