---
type: manifest
subject: spacemacs
pattern: project
persona: daedalus
version: "0.1.0-genesis"
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [manifest, governance, spacemacs, daedalus, battle_station, ide, layered_config, self_improving, genesis]
---

# SpaceLattice.aDNA — Project Manifest

## Project Identity

**SpaceLattice.aDNA** — Agentic battle station for ML ops, agentic coding, and aDNA context-graph navigation. The vault governs a Spacemacs-based IDE; Spacemacs is the *subject*, not a wrapper around it.

The vault carries a layered configuration architecture (`standard/` shared, `local/` private, `overlay/` third-party) and a self-improving loop where the agent observes session friction, drafts ADRs with diffs and dry-run health checks, and proposes them through an operator approval gate. The operator is always the gate; the agent never auto-commits to `standard/`.

Persona: **Daedalus** — master craftsman, builder of the Labyrinth (context-graph navigation) and adaptive wings (uplift / extension). The labyrinth metaphor is the through-line for context-graph editing inside the IDE.

## Architecture

This project uses the **aDNA (Agentic DNA)** knowledge architecture with three additional layered subdirs unique to SpaceLattice.aDNA:

```
SpaceLattice.aDNA/
├── what/
│   ├── standard/          # shared, deterministic, reproducible — the published commons
│   ├── local/             # gitignored — operator/machine-specific
│   ├── overlay/           # third-party Spacemacs distributions (consumed via skill_overlay_consume)
│   ├── decisions/adr/     # ADR-gated changes — every standard/ edit requires one
│   ├── context/           # (inherited) agent context library
│   ├── docs/              # (inherited) aDNA spec docs
│   └── lattices/          # (inherited) lattice YAML tools + examples
├── how/
│   ├── standard/skills/   # install, deploy, layer_add, layer_promote, self_improve, health_check, adna_index, overlay_consume, publish_lattice
│   ├── standard/runbooks/ # fresh_machine, update_spacemacs, recover_from_breakage, share_to_lattice
│   ├── local/             # gitignored — machine-specific runbooks and install logs
│   ├── skills/            # (inherited) workspace-level skills
│   ├── sessions/          # (inherited) session tracking
│   ├── missions/          # (inherited) mission machinery
│   ├── campaigns/         # (inherited) campaign machinery
│   └── templates/         # (inherited) 23 reusable templates
└── who/
    ├── operators/         # current machine's operator profile
    ├── upstreams/         # Spacemacs maintainers, layer authors
    ├── peers/             # other SpaceLattice.aDNA forks once they exist
    ├── governance/        # (inherited)
    ├── team/              # (inherited)
    └── coordination/      # (inherited)
```

Inherited files from the .adna template (sessions, missions, campaigns, templates, the prd_rfc pipeline) are kept; the layered subdirs are additive.

## Layer Contract (summary)

Strict precedence at deploy time:

```
overlay/  (third-party Spacemacs distros — proposes via ADR; never silently overwrites)
   ↓
standard/ (shared, deterministic, reproducible — the published commons)
   ↓
local/    (per-operator, gitignored — never published unless explicitly promoted)
```

Render order in `skill_deploy`: `standard/` first, layer accepted `overlay/` choices, then `local/` last. Final artifacts: `~/.spacemacs` and `$SPACEMACSDIR/private/`.

**Promotion is a skill, not an accident.** `skill_layer_promote` is the only path from `local/` → `standard/`, and requires an ADR with sanitization scan.

Full contract: `what/standard/LAYER_CONTRACT.md` (Phase 6).

## Self-improvement loop (summary)

`skill_self_improve` reads recent session notes, detects friction (repeated manual fixes, layer load errors, slow ops, layer conflicts, duplicated keybindings), drafts an ADR + unified diff, runs a dry-run `skill_health_check` in a scratch worktree, and presents the bundle to the operator. Operator gates the commit.

Full skill: `how/standard/skills/skill_self_improve.md` (Phase 5).

## Subject — Spacemacs

The IDE this vault governs. Spacemacs SHA, Emacs minimum version, and OS support matrix are pinned in `what/standard/pins.md`. The canonical layer set is enumerated in `what/standard/layers.md`. Templates `dotfile.spacemacs.tmpl` and `packages.el.tmpl` are rendered to `~/.spacemacs` and `~/.emacs.d/private/packages.el` at deploy time.

The vault includes a Spacemacs layer at `what/standard/layers/adna/` that:

- Detects `*.aDNA/` ancestor directories and activates an `adna-mode` minor mode
- Surfaces a `SPC a` transient menu (open MANIFEST, jump to triad root, run nearest skill, render lattice graph, capture session)
- Reads aDNA YAML frontmatter and exposes it as buffer-local variables
- Round-trips wikilinks with Obsidian
- Spawns Claude Code via `SPC c c` pinned to the nearest aDNA root
- Emits a context graph at `what/standard/index/graph.json` via `M-x adna-index-project`

## Entry Points

| Audience | Start Here | Then |
|----------|-----------|------|
| **Agents** | `CLAUDE.md` (auto-loaded) | `STATE.md` → `how/sessions/active/` → work |
| **Operators (humans)** | `README.md` | copy-paste install command → `what/standard/layers.md` |
| **Peer forkers** | `https://github.com/LatticeProtocol/SpaceLattice.aDNA` (planned) | `skill_install` from extracted tarball |

## Active Phase

**Genesis (v0.1.0)** — 2026-05-03. Fork freshly cut from `.adna/` template; layered scaffold and Spacemacs adna layer to be added in Phase 2-4. First deploy and first self-improvement loop validation pending Phase 5+.

See `STATE.md` for current operational state and `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` for the seven-phase plan.

## Reuse from `.adna/` template

| Inherited | Used for |
|-----------|----------|
| `how/templates/template_adr.md` | Every ADR in `what/decisions/adr/` |
| `how/templates/template_skill.md` | Every skill in `how/standard/skills/` |
| `how/templates/template_session.md` | Session capture from `SPC a` transient |
| `what/docs/adna_standard.md` | Frontmatter conformance spec |
| `how/skills/skill_project_fork.md` | This fork's own ancestry |
| `what/context/` | aDNA core / Claude Code / lattice basics context library |
