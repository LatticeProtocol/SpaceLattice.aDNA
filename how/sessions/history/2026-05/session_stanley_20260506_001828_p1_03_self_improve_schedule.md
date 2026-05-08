---
type: session
session_id: session_stanley_20260506_001828_p1_03_self_improve_schedule
mission: mission_sl_p1_03_self_improve_schedule
campaign: campaign_spacelattice_v1_0
status: completed
tier: 1
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
operator: stanley
tags: [session, p1, self_improve, schedule, adr_007, spacemacs]
---

# Session — P1-03: skill_self_improve schedule

**Intent**: Design and ratify the skill_self_improve invocation schedule. Evaluate three mechanisms (launchd, cron, Claude Code Stop hook); implement chosen artifact; file ADR-007; update skill with Schedule subsection; operator-verify; close audit finding #6.

**Decision preview**: Recommending Claude Code Stop hook + session-count gate (threshold 5). Rationale: skill_self_improve requires Claude Code to execute (it's an agent skill); Stop hook fires at natural session boundary with fresh context; works cross-platform; operator-controlled suggestion, not auto-run.

## SITREP

**Completed**: P1-03 fully executed — Claude Code Stop hook + session-count gate chosen over launchd/cron; check script authored and verified; ADR-007 accepted; `.claude/settings.json` created; `skill_self_improve.md` Schedule section added; STATE.md finding #6 closed; AAR artifact written; commit staged.

**In progress**: Nothing — P1-03 fully closed.

**Next up**: P1-02 (the final P1 mission) — audit `how/skills/skill_l1_upgrade.md` for private IPv4 + email WARNs; choose ADR-acknowledge or upstream-PR path; file ADR-006. After P1-02 closes, run the P1 phase gate check (3 AARs + 2 ADRs + findings #4/#5/#6 closed) before P2 begins.

**Blockers**: None.

**Next Session Prompt**: P1-03 is closed (ADR-007 accepted; Stop hook live). One P1 mission remains: P1-02 sanitization WARNs. Start by reading `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_p1_02_sanitization_warns_adr.md` and `how/skills/skill_l1_upgrade.md`. Locate the two patterns that trigger WARNs in `skill_publish_lattice` (private IPv4 regex match + email regex match). Determine context (illustrative vs. operational). File ADR-006 acknowledging as inherited-template debt with `LAYER_CONTRACT.md` § Exceptions entry, OR open upstream PR against `LatticeProtocol/adna`. After P1-02 closes, verify P1 phase gate (4 checklist items) and confirm with operator before starting P2.

## Files Touched

- `how/standard/skills/schedule_self_improve_check.sh` — new (the check script)
- `.claude/settings.json` — new (project-level Stop hook)
- `what/decisions/adr/adr_007_self_improve_schedule.md` — new
- `how/standard/skills/skill_self_improve.md` — add Schedule subsection
- `how/campaigns/.../mission_sl_p1_03_self_improve_schedule.md` — mark completed
- `STATE.md` — close audit finding #6
- `how/missions/artifacts/aar_p1_03_self_improve_schedule_2026_05_06.md` — new
