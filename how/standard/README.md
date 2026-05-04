---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [standard, how, commons, skills, runbooks]
---

# how/standard/

The **standard operations layer** — published commons for skills and runbooks. Every file here builds and runs on a fresh machine without `how/local/` present.

## Subdirs

| Dir | Purpose |
|-----|---------|
| `skills/` | Agent procedures for install, deploy, layer add/promote, self-improve, health-check, adna_index, overlay_consume, publish_lattice. Phase 3-7 implementation. |
| `runbooks/` | Human-runnable procedures: fresh_machine, update_spacemacs, recover_from_breakage, share_to_lattice. |

## Skills vs runbooks

| | Skill | Runbook |
|---|-------|---------|
| Audience | Agent (Claude Code) executes | Human reads + executes |
| Format | Per `~/lattice/.adna/how/templates/template_skill.md` | Per project convention |
| Trigger | Agent detects condition or operator invokes by name | Human follows when situation arises |
| Verification | `skill_health_check` after each step | Human checks visual outcome |

## Inherited templates

The 23 templates inherited from `.adna/` at `how/templates/` are the canonical source for new skill files in `skills/`:

- New skill → `template_skill.md`
- New runbook for human → custom format documented in `runbooks/README.md`

## ADR gate

Every change in `skills/` or `runbooks/` requires an ADR per `what/standard/LAYER_CONTRACT.md`. Self-improvement (`skill_self_improve`) drafts ADRs but never commits without operator approval.
