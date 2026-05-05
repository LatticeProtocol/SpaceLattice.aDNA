# Changelog — spacemacs.aDNA

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Phase 8 (live install + DoD completion)

- Plan file extended: `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Phase 8 added (8 steps).
- **Tooling install**: `brew tap d12frosted/emacs-plus` + `brew install emacs-plus@29 fd`. Result: GNU Emacs 29.4 + fd 10.4.2 (ripgrep 14.1.1 already present).
- **`skill_install` end-to-end** (DoD #2): preflight green; clean host (no prior `~/.emacs.d/`); cloned Spacemacs `develop` into `~/.emacs.d/`; rendered `~/.spacemacs` and `~/.emacs.d/private/packages.el` from templates; symlinked `what/standard/layers/adna/` → `~/.emacs.d/private/layers/adna/`; **first batch boot succeeded in 3.5 min** (Spacemacs installed ~40 layer packages from MELPA), exit 0.
- **Spacemacs SHA captured**: `e57594e7aa1d459d3428b9b116bb84b344aa6084` (develop tip on 2026-05-04). Updated `what/standard/pins.md` (was `PIN PENDING`). ADR 002 ratifies.
- **`(adna/health-check)`** (DoD #3 E): returned OK in `emacs --batch` invocation.
- **`M-x adna-index-project`** (DoD #4 elisp side): elisp wrapper invoked Python CLI; `what/standard/index/graph.json` written, 223 nodes, 341 edges.
- **Two real elisp bugs caught by live boot** and fixed:
  - `adna/wikilink-at-point` had malformed `cl-loop` (`for orig (point)` missing `=` — actually moved `orig` capture into outer `let` which is cleaner anyway)
  - `packages.el` redundantly declared `transient` and `vterm`; both are owned by `spacemacs-bootstrap` (transient) and `shell` (vterm) layers. Removed our declarations + `init-transient` / `init-vterm` functions; layer still works because we use `(when (fboundp 'vterm) ...)` defensive check in `adna/spawn-claude-code`.
- **Deploy receipt** written to `deploy/<host>/<utc>.md` (gitignored — machine-specific audit trail).
- **Pending in Phase 8**: install-from-tarball validation (DoD #6 full satisfaction). GitHub push (Phase 7 step 6) still operator-gated.

### Phase 7 (complete except GitHub push)

### Phase 7 (complete except GitHub push)

- **`how/standard/skills/skill_publish_lattice.md`** — 7-step publishing skill: clean-state check, build publish tree (rsync with explicit excludes for `what/local/`, `how/local/`, `who/operators/`, `deploy/`, `dist/`, `.git/`, `how/sessions/active/`, `*.dryrun.log`), sanitization scan via LAYER_CONTRACT § 4, tarball at `dist/<utc>.tar.gz`, extract + health-check the tarball, push to `github.com/LatticeProtocol/spacemacs.aDNA` (REQUIRES OPERATOR CONFIRMATION), publish receipt at `who/peers/published/<utc>.md`.
- **Live dry-run publish** (steps 1-5) caught 6 operator-home path violations (Clause 1) across CHANGELOG.md, STATE.md, README.md, and `what/decisions/adr/adr_000_vault_identity.md`. All replaced with `~/...` shorthand or rephrased to remove the literal pattern.
- **Hostname-literal regex tightened** in `what/standard/LAYER_CONTRACT.md` to avoid `.env.local` (gitignore line) and `settings.local.json` (inherited claude-code context) false positives. Pattern now requires non-`.` lookbehind + lookahead.
- **GitHub push DEFERRED** — Step 6 (`git push origin main` + tag) requires explicit operator confirmation; dry-run produces tarball locally only. DoD #6 partial satisfaction (tarball + extract health-check green); full satisfaction requires running `skill_install` from extracted tarball on a clean reference environment with emacs.

### Phase 6 (complete)

- **`what/standard/LAYER_CONTRACT.md`** — full normative contract replacing the Phase 2 stub. 7 sections, 6 clauses (standard-is-commons, local-is-private, overlay-is-third-party, promotion ritual, license interlock, sanitization scan), with verification mechanisms. Sanitization scan inlined as Python (regex patterns: hostname literals, user-home paths, secret patterns, IP ranges, emails). Self-validates: contract's own scan runs clean against this vault's `what/standard/` + `how/standard/`.
- **`how/standard/skills/skill_layer_promote.md`** — `local/` → `standard/` promotion ritual. Sanitization scan gate, ADR-required, dry-run health-check, operator-gated apply. Move/move+example/copy options.
- **`how/standard/skills/skill_overlay_consume.md`** — third-party Spacemacs distribution consumption. Per-layer ADR-gated disposition (merge / hold / reject). License compatibility check (GPL-3.0 / Apache / MIT / BSD acceptable; AGPL / proprietary REJECT). Provenance tracking.
- **Layer Contract enforcement (live fix)**: scan flagged an operator-home plan reference in `how/standard/skills/README.md` (Clause 1 violation); replaced absolute path with the `~/` shorthand. Contract examples reformatted to use `<placeholder>` shape so the scan doesn't false-trigger on its own documentation.

### Phase 5 (complete — DoD #5 satisfied)

- **`how/standard/skills/skill_self_improve.md`** — closed-loop self-improvement spec. Reads recent sessions + ADRs, detects friction via 6 rules (A: repeated manual fix; B: missing layer/package; C: slow operation; D: cross-layer key conflict; E: in-file duplicated keybinding; F: extensible), drafts ADR + unified diff + dry-run health-check in scratch worktree, presents bundle for operator ACCEPT/REJECT/DEFER. Hard rule: never auto-commits to `what/standard/`.
- **DoD #5 demonstration**: synthetic friction (duplicated `SPC a h` binding) injected into `what/standard/layers/adna/keybindings.el`, Rule E detection fired (`"ah"` bound 2x), ADR 001 drafted (`adr_kind: synthetic_demo`), proposal diff generated, scratch-worktree dry-run green (A/E/F all OK), operator ACCEPTED, diff applied to working tree (injection removed), commit landed.
  - Evidence files: `what/decisions/adr/adr_001_demo_dedup_keybind.md`, `adr_001.diff`, `adr_001.dryrun.log`
  - Synthetic friction never entered committed history; the closed loop is the artifact.

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

The seven-phase genesis plan lives at `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` (originating operator's machine). Stop gates between every phase per the user's "Report at the end of each phase" directive.

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
