---
type: aar
mission_id: mission_sl_p1_03_self_improve_schedule
campaign: campaign_spacelattice_v1_0
date: 2026-05-06
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [aar, p1, self_improve, schedule, stop_hook, adr_007, spacemacs]
---

# AAR — P1-03: skill_self_improve schedule

**Mission**: `mission_sl_p1_03_self_improve_schedule`
**Closed**: 2026-05-06
**Session**: `session_stanley_20260506_001828_p1_03_self_improve_schedule`

## Schedule Decision Summary

**Chosen mechanism**: Claude Code `Stop` hook + session-count gate (ADR-007, accepted 2026-05-06).

| Mechanism | Verdict | Key reason |
|-----------|---------|-----------|
| launchd plist | Rejected | macOS-only; fires outside session; can't invoke agent skill |
| cron | Rejected | Context-free; same fundamental problem as launchd |
| **Claude Code Stop hook** | **Accepted** | Fires at session end with fresh context; cross-platform; operator present |

## Artifacts Delivered

| Artifact | Path |
|---------|------|
| Check script | `how/standard/skills/schedule_self_improve_check.sh` |
| Project hook | `.claude/settings.json` |
| ADR | `what/decisions/adr/adr_007_self_improve_schedule.md` |
| Skill update | `how/standard/skills/skill_self_improve.md` § Schedule |

## Verification Result

| Test | Expected | Actual |
|------|----------|--------|
| `SELF_IMPROVE_THRESHOLD=5` (2 sessions in history) | Silent | ✅ Silent |
| `SELF_IMPROVE_THRESHOLD=1` (2 sessions in history) | Reminder printed | ✅ Printed |

## AAR

- **Worked**: Claude Code Stop hook is a fundamentally better fit than launchd/cron — the mission scaffold suggested the old approach but re-evaluation took < 5 minutes and produced a cleaner answer
- **Didn't**: Nothing blocked; the hook format and script were straightforward
- **Finding**: Missions that pre-prescribe "launchd or cron" for scheduling agent skills should be re-evaluated against Claude Code hooks; the hooks system closes the agent-invocation gap that makes daemons awkward
- **Change**: For future scheduling decisions in this vault: evaluate Claude Code hooks first, especially for agent skills; document the rationale for/against in the ADR
- **Follow-up**: P1-02 is the last P1 mission (sanitization WARNs ADR-006); after that, P1 phase gate check
