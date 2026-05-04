---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [runbooks, how, standard, human]
---

# how/standard/runbooks/

Human-runnable procedures for spacemacs.aDNA. Phase 3 populates with the initial four; later phases add more.

## Runbooks (planned)

| Runbook | Phase | When to follow |
|---------|-------|----------------|
| `fresh_machine.md` | 3 | New laptop / new Linux box / new VM — get from zero to working battle station |
| `update_spacemacs.md` | 3 | Upstream Spacemacs `develop` has moved — bump the pin |
| `recover_from_breakage.md` | 3 | Something is wrong with `~/.emacs.d/` or `~/.spacemacs` — restore from backup, re-deploy |
| `share_to_lattice.md` | 7 | Publish standard layer changes to peers — invokes `skill_publish_lattice` |

## Runbook format

| Section | Purpose |
|---------|---------|
| Frontmatter | `type: runbook`, status, intent, time-estimate |
| **Pre-conditions** | Host state, files that must exist |
| **Steps** | Numbered, copy-pasteable commands or actions |
| **Post-conditions** | What "done" looks like |
| **Rollback** | If a step fails, what's the recovery path |
| **Notes** | Edge cases, OS-specific quirks |

Runbooks are markdown — operators read top-to-bottom, copy-paste, verify each step.

## Difference from skills

Runbooks are for the operator. Skills are for the agent. A runbook may invoke a skill ("run `skill_install`"); a skill may reference a runbook ("if abort, see `recover_from_breakage.md`"). They cross-reference but don't duplicate.
