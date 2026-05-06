---
type: mission
mission_id: mission_sl_p1_03_self_improve_schedule
campaign: campaign_spacelattice_v1_0
campaign_phase: 1
campaign_mission_number: 3
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p1, audit_closure, self_improve, schedule]
blocked_by: []
---

# Mission — P1-03: skill_self_improve schedule

**Phase**: P1 — Audit closure.
**Class**: implementation.

## Objective

Close audit finding #6: `skill_self_improve` has no scheduled invocation cadence. Design and document a schedule mechanism (cron / launchd / session-end emacs hook / manual cadence), ratify via ADR, and update the skill to declare the schedule contract.

## Deliverables

- Schedule decision: which mechanism (recommendation: launchd on macOS, cron on Linux, session-end emacs hook for opportunistic friction sweep)
- Schedule artifact authored: launchd plist OR cron entry OR runbook section instructing manual invocation OR emacs hook code in `what/standard/layers/adna/`
- ADR: `what/decisions/adr/adr_007_<slug>.md` ratifying the schedule choice + privacy/control trade-off
- `how/standard/skills/skill_self_improve.md` updated with a "Schedule" subsection declaring the contract (when fired, by what mechanism, what it reads, what it does)
- Operator-verification: schedule fires once, no false-positive friction detected, ADR-draft path (if any) gates correctly
- STATE.md update: audit finding #6 → closed

## Estimated effort

1-2 sessions.

## Dependencies

None — parallel-capable with P1-01 and P1-02.

## Reference

- Genesis AAR § Gap Register #7: `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- `how/standard/skills/skill_self_improve.md` (current)
- `what/standard/sustainability.md` § Cadences + § Stay-current process (schedule context)

## Schedule Decision

**Chosen mechanism**: Claude Code `Stop` hook + session-count gate (ADR-007).

| Mechanism | Decision | Reason |
|-----------|----------|--------|
| launchd plist | Rejected | macOS-only; fires outside session; cannot run agent skill |
| cron | Rejected | Same problems; cross-platform but context-free |
| Claude Code Stop hook | **Accepted** | Fires at session end with fresh context; cross-platform; operator present; non-intrusive (reminder only) |

**Artifacts delivered**:
- `how/standard/skills/schedule_self_improve_check.sh` — check script (executable)
- `.claude/settings.json` — project-level Stop hook
- `what/decisions/adr/adr_007_self_improve_schedule.md` — ratification
- `how/standard/skills/skill_self_improve.md` — Schedule subsection added

**Verification**: script tested at threshold 5 (silent, 2 sessions below threshold) and threshold 1 (printed reminder — correct).

## AAR

- **Worked**: Claude Code hook approach is a cleaner fit than the original mission's launchd/cron recommendations — skill_self_improve is an agent skill; the hook fires in the right context
- **Didn't**: Nothing blocked; the new hook mechanism wasn't in the original scaffold but evaluation took <5 min
- **Finding**: The mission brief pre-assumed launchd/cron; re-evaluating against the Claude Code hooks system produced a strictly better answer — the P1-01 plan improvement (suggesting hook evaluation) paid off immediately
- **Change**: Future missions that mention scheduling agentic skills should default to evaluating Claude Code hooks first before daemon-based approaches
- **Follow-up**: ADR-007 accepted; `.claude/settings.json` now tracked in git — peers who clone get the hook automatically
