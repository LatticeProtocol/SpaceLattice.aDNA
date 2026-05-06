---
type: mission
mission_id: mission_sl_p3_00_closed_loop_validation
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 0
status: completed
mission_class: infrastructure
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
completed: 2026-05-06T19:57:28Z
tags: [mission, completed, spacelattice, v1_0, p3, validation, emacsclient, inspect, infrastructure]
blocked_by: []
---

# Mission — P3-00: Closed-Loop Validation Infrastructure

**Phase**: P3 — Pre-flight infrastructure (prerequisite to P3-01 through P3-11).
**Class**: infrastructure.

## Objective

Eliminate the "blind change" cycle that required operator screenshots to validate IDE configuration changes. Implement a self-contained live inspection system using the Emacs server (always running) and macOS screencapture, so the agent can validate font, tab filtering, doom-modeline, and projectile state directly without operator involvement.

## Motivation

Through P3 pre-flight visual configuration (font size, centaur-tabs filter, doom-modeline), every change required the operator to restart Spacemacs and share screenshots. The root causes were invisible to batch-boot:
- Integer font size applied as 1/10pt (not detected by `emacs --batch`)
- centaur-tabs filter API mismatch (hash cache, not batch-testable)
- Operator explicitly requested: "we need you to inspect/run/validate changes yourself"

## Deliverables

- [x] `how/standard/skills/skill_inspect_live.md` — new skill: socket finder + emacsclient query suite + screencapture + assertion report
- [x] `skill_health_check.md` Check D+ — live state assertions when emacsclient available (exits 70-79)
- [x] `skill_deploy.md` Step 9 — reload-type determination + `skill_inspect_live` post-deploy gate
- [x] `dotfile.spacemacs.tmpl` reload-type annotation — comment explaining hot-reload vs full-restart boundary
- [x] ADR-014 accepted — ratifies all of the above

## AAR

**Worked:** emacsclient found via `find /var/folders -name server -path "*/emacs<uid>/*"` — socket path is session-specific but discoverable. Single eval returns structured state string (font height, centaur-tabs prefix list, doom-modeline mode, projectile path). `screencapture -x` captures visual state in ~1s; Read delivers it to Claude Code context. Live inspection confirmed all P3 pre-flight settings correct in one pass.

**Didn't:** Socket finder returns empty when Spacemacs is not running — handled gracefully (SKIP). emacsclient cold-connects in ~200ms, acceptable overhead.

**Finding:** The most valuable assertion is `centaur-tabs-excluded-prefixes` — this cannot be tested any other way. Runtime hash cache (`centaur-tabs-hide-hash`) means the correct fix (excluded-prefixes API) was only confirmable via live query.

**Change:** `skill_deploy` now has a defined "done" criterion: GREEN from `skill_inspect_live`. Previously "done" was implicit (batch-boot passes, user confirms).

**Follow-up:** Add `skill_inspect_live` call to `skill_self_improve` dry-run flow (Phase 5 enhancement — low priority).

## Reference

- `how/standard/skills/skill_inspect_live.md`
- `how/standard/skills/skill_health_check.md` (Check D+)
- `how/standard/skills/skill_deploy.md` (Step 9)
- `what/decisions/adr/adr_014_closed_loop_validation.md`
