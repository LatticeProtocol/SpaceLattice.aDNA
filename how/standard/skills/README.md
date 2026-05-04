---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [skills, how, standard, agentic, procedures]
---

# how/standard/skills/

Agent procedures specific to spacemacs.aDNA. Phase 3-7 of the genesis plan populates this directory.

## Skills inventory (planned)

| Skill | Phase | Trigger |
|-------|-------|---------|
| `skill_install.md` | 3 | Fresh machine — clone Spacemacs, render templates, first boot, write deploy receipt |
| `skill_deploy.md` | 3 | Re-apply `what/standard/` + `what/local/` to `~/.spacemacs` and `$SPACEMACSDIR/private/` (skips clone if already installed) |
| `skill_health_check.md` | 3 | `emacs --batch` validation — layer load, frontmatter parse, graph emission. Used as gate by other skills |
| `skill_layer_add.md` | 3 | Operator wants a new Spacemacs layer added to standard. Drafts ADR + diff + dry-run |
| `skill_adna_index.md` | 4 | Rebuild `what/standard/index/graph.json` from triad. Wraps `M-x adna-index-project` and `build_graph.py` |
| `skill_self_improve.md` | 5 | Read recent sessions → detect friction → draft ADR + diff + dry-run → present to operator |
| `skill_layer_promote.md` | 6 | Operator-approved promotion `local/` → `standard/`. ADR + sanitization scan |
| `skill_overlay_consume.md` | 6 | Consume third-party Spacemacs distribution. Per-layer ADR-gated disposition |
| `skill_publish_lattice.md` | 7 | rsync standard layer + sanitize + tarball + push to `github.com/LatticeProtocol/spacemacs.aDNA` |

## Skill format

All skills use `~/lattice/.adna/how/templates/template_skill.md`. Frontmatter includes `skill_type: agent`, `category`, `trigger`, and a `requirements` block (tools, context, permissions).

## How an agent invokes a skill

1. Agent reads CLAUDE.md and notices the operator's request matches a skill's `trigger` field
2. Agent loads the skill file
3. Agent executes steps in order, treating each as authoritative
4. Agent reports completion + any deviations

The plan file (`/Users/stanley/.claude/plans/please-read-the-claude-md-splendid-boole.md`) drove the genesis fork itself. Subsequent operations are skill-driven.
