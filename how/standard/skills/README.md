---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [skills, how, standard, agentic, procedures]
---

# how/standard/skills/

Agent procedures specific to Spacemacs.aDNA. All skills are live as of v1.0.0.

## Skills inventory

| Skill | Trigger |
|-------|---------|
| `skill_install.md` | Fresh machine — clone Spacemacs, render templates, first boot, write deploy receipt |
| `skill_deploy.md` | Re-apply `what/standard/` + `what/local/` to `~/.spacemacs` and `$SPACEMACSDIR/private/` (skips clone if already installed) |
| `skill_health_check.md` | `emacs --batch` validation — layer load, frontmatter parse, graph emission. Gate for other skills |
| `skill_layer_add.md` | Operator wants a new Spacemacs layer added to standard. Drafts ADR + diff + dry-run |
| `skill_adna_index.md` | Rebuild `what/standard/index/graph.json` from triad. Wraps `M-x adna-index-project` and `build_graph.py` |
| `skill_self_improve.md` | Read recent sessions → detect friction → draft ADR + diff + dry-run → present to operator |
| `skill_layer_promote.md` | Operator-approved promotion `local/` → `standard/`. ADR + sanitization scan |
| `skill_overlay_consume.md` | Consume third-party Spacemacs distribution. Per-layer ADR-gated disposition |
| `skill_publish_lattice.md` | rsync standard layer + sanitize + tarball + push to `github.com/LatticeProtocol/Spacemacs.aDNA` |
| `skill_update_pin.md` | Bump Spacemacs SHA pin via successor ADR + dry-run + smoke test |
| `skill_inspect_live.md` | Live inspection of running Spacemacs state via `emacsclient` |
| `skill_telemetry_submit.md` | Operator-gated telemetry submission (friction signals → GitHub Issue) |
| `skill_telemetry_aggregate.md` | Maintainer-side fleet aggregation of telemetry signals |

## Skill format

All skills use `~/lattice/.adna/how/templates/template_skill.md`. Frontmatter includes `skill_type: agent`, `category`, `trigger`, and a `requirements` block (tools, context, permissions).

## How an agent invokes a skill

1. Agent reads CLAUDE.md and notices the operator's request matches a skill's `trigger` field
2. Agent loads the skill file
3. Agent executes steps in order, treating each as authoritative
4. Agent reports completion + any deviations
