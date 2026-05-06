---
type: decision
adr_id: adr_007
adr_number: 7
title: "skill_self_improve schedule: Claude Code Stop hook + session-count gate"
status: accepted
accepted_at: 2026-05-06
proposed_by: agent_stanley
ratified_by: operator_stanley
target_layer: standard
target_files:
  - how/standard/skills/schedule_self_improve_check.sh
  - .claude/settings.json
  - how/standard/skills/skill_self_improve.md
detected_via:
  rule: audit_finding
  evidence: "Genesis AAR Gap Register #6 — skill_self_improve has no scheduled invocation cadence"
supersedes:
superseded_by:
tags: [decision, adr, self_improve, schedule, stop_hook, session_count_gate, accepted]
---

# ADR-007: skill_self_improve schedule — Claude Code Stop hook + session-count gate

## Status

Accepted 2026-05-06. Closes audit finding #6.

## Context

`skill_self_improve` (introduced Phase 5) has no scheduled invocation cadence — the genesis AAR flagged this as Gap Register #6. Without a trigger, the self-improving loop only fires when the operator manually remembers to ask for it, defeating its purpose.

Three mechanisms were evaluated:

| Mechanism | Platform | Fires when | Can invoke Claude Code agent? | Notes |
|-----------|----------|-----------|-------------------------------|-------|
| **launchd plist** | macOS only | Calendar schedule (wall-clock) | No — invokes shell, not agent | Fires outside session; no session context available; operator may not be present |
| **cron** | Linux/macOS | Calendar schedule (wall-clock) | No — same as launchd | Same problems; more portable but still context-free |
| **Claude Code Stop hook** | All platforms (hook runs at session end) | Claude session ends | Yes — fires while session context is warm, operator present | Aligns with existing operator workflow |

`skill_self_improve` is an **agent skill**: it reads session history, detects friction, drafts an ADR, runs a dry-run health-check, and presents a bundle for operator approval. Launchd/cron can invoke shell scripts but cannot run the multi-step agentic skill logic — they would at best fire a reminder. The Stop hook fires at the exact moment session history is freshest and the operator is still present.

**Privacy and control**: the Stop hook fires a shell script (`schedule_self_improve_check.sh`) that reads only local session file timestamps and ADR frontmatter. No content is transmitted anywhere. The hook prints a reminder — it does not auto-run the skill. Operator retains full control.

## Decision

Use a **Claude Code `Stop` hook** that calls `how/standard/skills/schedule_self_improve_check.sh`. The script counts session files accumulated since the last self-improve ADR. When the count meets or exceeds a configurable threshold (default: 5), it prints a one-line reminder to the operator at session end.

**Contract:**
- **When fires**: at the end of every Claude Code session in this vault (via `Stop` hook in `.claude/settings.json`)
- **What it reads**: `how/sessions/history/` file timestamps; `what/decisions/adr/*.md` frontmatter (greps for `self_improve` tag)
- **What it does**: prints a single-line reminder to stdout if threshold met; otherwise silent
- **What it does NOT do**: run `skill_self_improve` automatically; modify any file; transmit data
- **Threshold**: `SELF_IMPROVE_THRESHOLD` env var (default 5); override in shell profile for tighter/looser cadence

**Implementation**:
- `how/standard/skills/schedule_self_improve_check.sh` — the check script (executable, `set -euo pipefail`)
- `.claude/settings.json` — project-level Claude Code hook: `Stop` → `bash how/standard/skills/schedule_self_improve_check.sh`

## Consequences

### Positive

- Self-improvement cadence is now automatic and aligned with the operator's natural workflow (session end)
- Works identically on macOS and Linux (hook is a shell script; no platform-specific daemon)
- Zero operator setup beyond the git-tracked `.claude/settings.json`
- Operator controls frequency via `SELF_IMPROVE_THRESHOLD` env var — no daemon config to edit
- Script failure (exit non-zero) does not fail the session; it's fire-and-forget

### Negative

- Fires only when operator uses Claude Code in this vault — if sessions are long gaps apart, the reminder may lag
- The default threshold of 5 is an estimate; first-week cadence may feel noisy or sparse depending on session frequency

### Neutral

- `.claude/settings.json` is a new project-level file — tracked in git so peers get the same hook automatically on clone
- launchd and cron alternatives remain documented here for operators on air-gapped systems who cannot use Claude Code's hook system (they may set up a cron job calling the same script)

## Alternatives Considered

**launchd/cron**: Rejected. Cannot run the agent skill; fires without session context; macOS-only (launchd) or requires daemon config (cron). The reminder-only use case is better served by the Stop hook, which fires in the right context.

**Manual cadence**: Rejected as primary mechanism. "Remember to run skill_self_improve" is exactly what audit finding #6 identified as insufficient. Retained as fallback documentation only.

**PostToolUse hook**: Considered but rejected. PostToolUse fires on every tool call — too frequent. Stop fires once per session, matching the intended "after a session's work is done" cadence.

## Reversibility

Remove the `Stop` entry from `.claude/settings.json` to disable. The script itself is inert without the hook. No state is stored by the hook.
