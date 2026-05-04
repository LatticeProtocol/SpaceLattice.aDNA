# Changelog — spacemacs.aDNA

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Phase 2 (in progress)

- Triad scaffold (additive on inherited template):
  - `who/{operators,upstreams,peers}/` — operator profiles, Spacemacs upstream attribution, peer forks
  - `what/{standard,local,overlay}/` — three-layer architecture
  - `how/{standard,local}/` — skills + runbooks split into commons and machine-specific
- Foundational ADR 000 — vault identity, persona (Daedalus), pattern (project, informal), publish target, layered architecture
- `what/standard/` documents authored:
  - `pins.md` — Spacemacs SHA + Emacs version + OS matrix (pin pending first install)
  - `layers.md` — canonical Spacemacs layer set + the spacemacs.aDNA-specific `adna` layer
  - `dotfile.spacemacs.tmpl` — template rendered to `~/.spacemacs` by `skill_deploy`
  - `packages.el.tmpl` — template for additional packages
  - `adna-bridge.md` — spec for the `adna` Spacemacs layer (impl in Phase 4)
  - `model-routing.md` — Claude / local-llama / API model precedence
  - `obsidian-coupling.md` — Spacemacs ↔ Obsidian round-trip via Advanced URI plugin
  - `LAYER_CONTRACT.md` (stub — full contract in Phase 6)
- `what/local/` templates: `operator.private.el.example`, `machine.pins.md.example`, `secrets.env.example`
- `what/overlay/` README — overlay consumption protocol
- `how/standard/skills/` and `how/standard/runbooks/` — README placeholders enumerating Phase 3-7 deliverables
- README.md — operator-facing 60-second orientation
- `.gitignore` — layered architecture: `what/local/` + `how/local/` ignored except `*.example`, `README.md`, `.gitkeep`

## [0.1.0-genesis] — 2026-05-03

### Phase 1

- Forked from `~/lattice/.adna/` base template via `skill_project_fork`
- Stripped Obsidian per-device files (`plugins/`, `themes/`, `workspace.json`, `graph.json`)
- `git init` + first `.gitignore` written before any `git add`
- Identity transition: Berthier (template default) → **Daedalus** (locked persona)
- Frontmatter customization in MANIFEST.md, STATE.md, CLAUDE.md (subject: spacemacs, pattern: project, persona: daedalus, version: 0.1.0-genesis)
- Workspace integration: row added to `~/lattice/CLAUDE.md` project table; entry added to Workspace Layout tree

## Genesis plan

The seven-phase genesis plan lives at `/Users/stanley/.claude/plans/please-read-the-claude-md-splendid-boole.md`. Stop gates between every phase per the user's "Report at the end of each phase" directive.

| Phase | Status | Description |
|-------|--------|-------------|
| 0 — Pre-flight | done | Read-only verification |
| 1 — Fork + identity | done | Fork mechanics, persona, workspace integration |
| 2 — Triad scaffold | in progress | Layered subdirs, ADR 000, README, frontmatter on every file |
| 3 — `skill_install` + `skill_deploy` | pending | Idempotent install, host check, backup, deploy receipt |
| 4 — aDNA bridge layer | pending | Elisp at `what/standard/layers/adna/` + Python CLI fallback |
| 5 — Self-improvement loop | pending | `skill_self_improve` with operator gate |
| 6 — Layer contract + overlay | pending | Full LAYER_CONTRACT + `skill_overlay_consume` |
| 7 — Lattice publishing | pending | tarball + push to `github.com/LatticeProtocol/spacemacs.aDNA` |
| DoD | pending | 8-check end-to-end verification |
