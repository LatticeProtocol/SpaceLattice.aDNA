# Changelog — spacemacs.aDNA

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Phase 4 (complete)

- **aDNA Spacemacs layer authored** at `what/standard/layers/adna/`:
  - `packages.el` — Spacemacs layer manifest declaring `yaml`, `transient`, `vterm`, `json`, `markdown-mode`
  - `config.el` — defcustoms (`adna-vault-search-paths`, `adna-claude-code-command`, `adna-obsidian-roundtrip-enabled`, etc.), buffer-local frontmatter mirrors, `adna-mode` minor mode definition
  - `funcs.el` — interactive commands: `adna/find-vault-root`, `adna/parse-frontmatter`, `adna/open-{manifest,claude,state}`, `adna/jump-triad-root`, `adna/run-nearest-skill`, `adna/render-lattice-graph`, `adna-index-project`, `adna/capture-session-note`, `adna/follow-wikilink`, `adna/open-in-obsidian`, `adna/spawn-claude-code`, `adna/health-check`. ~17 commands, ~280 lines.
  - `keybindings.el` — `SPC a` transient (m/c/s/r/k/g/i/n/w/o/h) + `SPC c c` Claude Code spawn
- **Python CLI fallback** `what/standard/index/build_graph.py` — walks the triad, parses frontmatter via PyYAML, identifies wikilinks + markdown links + frontmatter refs (supersedes / superseded_by / pattern_spec / ratifies / implementation_path / target_files / etc.), emits JSON. Custom date serializer for YAML datetime objects. Self-validate mode for `skill_health_check` check F.
- **`skill_adna_index.md`** in `how/standard/skills/` — wraps both callers (elisp + Python CLI), documents output schema, edge kinds, failure modes.
- **`graph.json` added to `.gitignore`** — regenerated artifact, doesn't belong in commit history.
- **End-to-end validation against this vault**: 218 nodes, 331 edges. Edge kinds: 230 references, 99 wikilinks, 2 frontmatter refs. Top node types: directory_index (38), skill (20), context_guide (13), context (13), folder_note (12).

### Phase 3 (complete)

- `how/standard/skills/skill_install.md` — idempotent install on fresh machine. 8 steps: preflight, backup, clone-at-pin, render-templates, symlink-adna, batch-boot, health-check, deploy-receipt. OS matrix: macOS / Linux / WSL2.
- `how/standard/skills/skill_deploy.md` — lighter cousin (steps 4-8 only). For when only templates changed.
- `how/standard/skills/skill_health_check.md` — green/red gate. 6 check classes (A: structure; B: frontmatter; C: layer-contract; D: emacs-batch-boot; E: adna-layer; F: graph-emission). Used by every other skill that touches `what/standard/`.
- `how/standard/skills/skill_layer_add.md` — ADR-gated Spacemacs layer addition. Conflict scan, ADR draft, diff, dry-run in scratch worktree, operator-gated commit.
- `how/standard/runbooks/fresh_machine.md` — human-runnable orchestration of `skill_install` for new hosts. Includes OS-specific dep install commands.
- `how/standard/runbooks/update_spacemacs.md` — bump pin via successor ADR + dry-run + smoke test.
- `how/standard/runbooks/recover_from_breakage.md` — diagnostic-first recovery for 6 common failure modes; restore-from-backup path; nuke-and-reinstall path.

### Phase 2 (complete)

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
