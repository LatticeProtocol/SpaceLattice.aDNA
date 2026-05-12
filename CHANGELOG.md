# Changelog — Spacemacs.aDNA

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-05-11

Full campaign `campaign_spacelattice_v1_0` complete. 41 missions, 34 ADRs, all skills live.

**P1 (Audit closure)**: backlog cleanup, sanitization WARN ADR, self-improve schedule.
**P2 (Sustainability + telemetry)**: runbook teeth, telemetry schema, submit/aggregate skills, end-to-end round-trip validated.
**P3 (Customization walk)**: 22 dimensions documented — dotfile lifecycle, layer anatomy, themes, editing/completion, perf, org-mode, Obsidian coupling, macOS context, dotfile hardening.
**P4 (Fork branding)**: distribution layer, claude-code-ide layer (treemacs + Claude Code window contract), agentic layout system (4 named layouts, `SPC a l` transient), agent command tree + extensions menu (`SPC a x`), CI/upstream monitor, pin update skill.
**P5 (Polish + release)**: strategic AAR + gap analysis, `adna/claude-project-switch`, automated validation (`validate_layers.py` + CI job), shared human-agent command tree (`scripts/` auto-discovery), v1.0 doc pass.

See the `[Unreleased]` section below for per-phase detailed entries.

## [Unreleased]

### Vault rename: SpaceLattice.aDNA → Spacemacs.aDNA (2026-05-07)

**ADR-017** (supersedes ADR-005). Vault directory, GitHub repo, and all display references renamed. Rationale: `SpaceLattice` implied a distribution project; `Spacemacs.aDNA` accurately names this as Spacemacs governed by aDNA — a context-native operationalization of the IDE, not a competing fork. Sibling fork `LatticeProtocol/spacelattice` unchanged.

- Directory: `SpaceLattice.aDNA/` → `Spacemacs.aDNA/`
- GitHub repo: `LatticeProtocol/SpaceLattice.aDNA` → `LatticeProtocol/Spacemacs.aDNA`
- Modeline format symbol: `spacelattice-main` → `adna-main`
- Upstream profile: `who/upstreams/spacelattice_fork.md` → `who/upstreams/spacemacs_fork.md`

### P3 pre-flight — presentation layer + Transient keybindings (2026-05-06)

**Headline**: P2→P3 gate confirmed by operator. P3 pre-flight complete: dotfile placeholders resolved, doom-modeline adapted to spacemacs-dark, adna layer keybindings refactored to Transient hierarchy, LP stubs + Claude Code variants added.

**Dotfile `what/standard/dotfile.spacemacs.tmpl`** (ADR-012):
- `dotspacemacs-startup-banner` → `"{{VAULT_ROOT}}/what/standard/assets/banner_active.txt"` (was `'official`)
- `dotspacemacs-themes` → `'(spacemacs-dark spacemacs-light)` (was `{{THEME_PRIMARY}}` placeholder)
- `dotspacemacs-mode-line-theme` → `'doom` (was `spacemacs :separator wave`)
- `dotspacemacs-default-font` → `'("Source Code Pro" :size 13 ...)` (was `{{FONT_FAMILY}} {{FONT_SIZE}}` placeholders)
- Added doom-modeline user-config block: `icon nil` (text-only, spacemacs-dark faces), `adna-vault` segment (⬡vault-name), `adna-main` modeline format

**Banner system** (ADR-012):
- `what/standard/assets/banner_active.txt` — active banner (v2_monolith LP box design)
- `what/standard/assets/banner_v1_dot_field.txt` — lattice dot field
- `what/standard/assets/banner_v2_monolith.txt` — LP monolith with ╔══╗ border
- `what/standard/assets/banner_v3_signal.txt` — dashed border ▶◀ signal style

**adna layer keybindings `keybindings.el`** (ADR-013):
- Replaced flat `spacemacs/set-leader-keys` with three Transient menus
- `adna/menu` (SPC a): Navigate / Skills & Graph / Links & Sessions / LP & Claude → groups
- `adna/lp-menu` (SPC a l + SPC o l): Run / Publish & Index / Browse groups + back
- `adna/claude-menu` (SPC a , + SPC c c): Launch / Review groups + back

**adna layer functions `funcs.el`** (ADR-013):
- `adna/--spawn-vterm-command` — shared vterm/eshell dispatch helper
- LP stubs: `adna/lp-run-lattice`, `adna/lp-job-status`, `adna/lp-publish`, `adna/lp-open-marketplace`, `adna/lp-federation-graph`
- Claude Code variants: `adna/spawn-claude-plan` (`--plan`), `adna/spawn-claude-loop` (`--loop`), `adna/spawn-claude-review` (`/review`)

**ADRs filed**: ADR-012 (presentation layer), ADR-013 (keybinding Transient refactor)

---

### P2-04 close — skill_telemetry_aggregate + first round-trip (2026-05-06)

**Headline**: P2-04 closed. `skill_telemetry_aggregate.md` promoted from stub to full 7-step maintainer procedure. First end-to-end telemetry round-trip executed. **P2 phase-gate COMPLETE** — all 4 P2 missions closed.

**skill_telemetry_aggregate.md** (full procedure, ADR-011):
- Step 1: Poll via `gh api "...?labels=telemetry&state=all" --paginate`
- Step 2: Parse + validate — per-class handlers, rejected/ audit trail
- Step 3: De-dup by issue ID via gitignored `_state.json`
- Step 4: Aggregate — group by class, build batch metadata
- Step 5: Pattern detection — ≥5 same `signal_class` → `pattern_<id>.md`
- Step 6: Write `who/peers/telemetry/inbox/<utc>_aggregate.md` (committed)
- Step 7: Update `_state.json` (gitignored idempotency state)
- Flags: `--dry-run`, `--since <iso8601>`

**Round-trip evidence**:
- GitHub Issue #1 submitted: `LatticeProtocol/Spacemacs.aDNA/issues/1` (operator side, `friction_signal: package_load_fail`, SHA `e57594e7`)
- Maintainer aggregation: `who/peers/telemetry/inbox/20260506T053941Z_aggregate.md` (committed)
- Pattern detection: threshold not triggered (1 issue, threshold=5) — logged correctly
- Demo ADR draft: `who/peers/telemetry/inbox/demo_adr_draft_p2_04.md` (loop-closed evidence)

**Infrastructure updates**:
- `who/peers/telemetry/` directory structure created: `inbox/`, `sent/`, `outbox/`
- `.gitignore`: added `who/peers/telemetry/inbox/_state.json`
- `who/operators/stanley.md`: added `telemetry_consent: true` + per-class opt-ins
- `telemetry` label created on upstream repo (`LatticeProtocol/Spacemacs.aDNA`)
- ADR-011 accepted; AAR at `missions/artifacts/aar_mission_sl_p2_04.md`

### M-Planning-01 close — v1.0 campaign Phase 0 done (2026-05-05)

**Headline**: Phase-0 planning mission of `campaign_spacelattice_v1_0` closed. Campaign moves to `status: execution`. 26 P1-P5 mission scaffolds + 1 user-in-the-loop runbook + 10/10 deliverables validated. Full AAR.

**Mission tree designed**:
- 27 missions total (1 P0 + 3 P1 + 4 P2 + 8 P3 + 8 P4 + 3 P5)
- Calibrated effort: ~38 sessions (range 31-44)
- Mission file pattern: `mission_sl_p<phase>_<NN>_<slug>.md` per campaign CLAUDE.md naming convention
- All scaffolds `status: planned` with `blocked_by` chains forming a clean DAG (P1 parallel-capable; P2-P5 sequential per phase)

**Per-phase scope refinement** (in campaign master):
- P1 (audit closure): 3 missions close findings #4 (backlog), #5 (sanitization WARNs), #6 (self-improve schedule). #7 (peer federation) deferred to release notes.
- P2 (sustainability + telemetry): 4 missions — runbook teeth, telemetry schema, submit skill, aggregate skill + first end-to-end round-trip
- P3 (customization walk-through): 8 missions covering 22 dimensions of `spacemacs_customization_reference.md` per the suggested grouping; all run user-in-the-loop per protocol
- P4 (fork branding): 8 missions — clone → distribution layer → theme → branding → banner → news+welcome → CI → first rebase
- P5 (polish + release): 3 missions — doc pass → second-machine install → tag + release notes

**Phase-gate criteria**: Each phase exit gate is now a concrete checklist (P1 4 items, P2 5 items, P3 5 items, P4 4 items, P5 5 items) replacing the prior single-line sketches.

**User-in-the-loop runbook authored**:
- `how/standard/runbooks/customization_session_protocol.md` — 7-step protocol for all P3 customization missions: open → load reference → structured Q&A → record decisions → draft changes → operator-gates each diff → AAR. Failure modes + cross-cutting rules documented.

**Audit findings closure plan**:
- #4 → P1-01; #5 → P1-02; #6 → P1-03; #7 deferred-to-release-notes (P5-03)

**LP fork branding execution plan**:
- 8 sequenced missions per fork-strategy stages and customization reference §4

**Files added**:
- 26 mission scaffolds at `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_p*.md`
- `how/standard/runbooks/customization_session_protocol.md`
- `how/campaigns/campaign_spacelattice_v1_0/missions/artifacts/aar_mission_sl_planning_01.md`
- `how/sessions/history/2026-05/session_stanley_20260505_225149_planning_01.md`

**Files updated**:
- `how/campaigns/campaign_spacelattice_v1_0/campaign_spacelattice_v1_0.md` — frontmatter (`status: execution`, `mission_count: 27`, `estimated_sessions: 31-44`, `calibrated_sessions: 38`); per-phase Scope subsections; concrete phase-gate checklists
- `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_planning_01.md` — `status: completed`
- `STATE.md` — current phase + next steps + recent decisions/upgrades

**Operator hand-off**: Trigger any P1 mission when ready (P1-01, P1-02, P1-03 are parallel-capable; suggested order P1-01 → P1-03 → P1-02).

### Plan B — Rename + repositioning + v1.0 campaign foundation (2026-05-05) — v0.2.0 target

**Headline**: vault renamed `spacemacs.aDNA` → `Spacemacs.aDNA`. Atomic rename ratified by **ADR 005**, which closes 5 coupled decisions (rename, sibling fork repo, LP-stack repositioning, persona-retention, version bump).

**Filesystem + GitHub**:
- `mv ~/lattice/spacemacs.aDNA ~/lattice/Spacemacs.aDNA`
- `gh repo rename Spacemacs.aDNA --repo LatticeProtocol/spacemacs.aDNA` (GitHub auto-creates redirect from old name)
- 39 tracked files updated via per-file sed (literal token `spacemacs.aDNA` → `Spacemacs.aDNA`)
- `~/.spacemacs` re-rendered with new `LOCAL_LAYER_DIR`; `~/.emacs.d/private/layers/adna` symlink relinked
- `.publish-clone/` remote re-pointed to renamed repo
- Workspace `~/lattice/CLAUDE.md` row + tree entry updated

**Sibling fork opened**:
- `gh repo fork syl20bnr/spacemacs --org LatticeProtocol --fork-name spacelattice` → `LatticeProtocol/spacelattice` (PUBLIC, default branch `develop`, parent confirmed)
- Local clone deferred to v1.0 campaign Phase 4 (per ADR 005)
- Provenance: `who/upstreams/spacemacs_fork.md`
- Strategy: `what/standard/fork-strategy.md` (Stage 0 — fork opened; Stages 1-4 deferred)

**LP-stack repositioning**:
- `what/standard/lp-positioning.md` documents the agentic-IDE-governance-vault role of Spacemacs.aDNA alongside `lattice-protocol` (runtime) + `Agentic-DNA` (template) + `LatticeProtocol/spacelattice` (sibling fork)

**Customization reference persisted**:
- `what/context/spacemacs/spacemacs_customization_reference.md` — operator-supplied Spacemacs Customization Architecture & LatticeProtocol Fork Playbook (~30K tokens) — verbatim, with aDNA frontmatter
- `what/context/spacemacs/AGENTS.md` — load-discipline + section index

**Sustainability framework outlined**:
- `what/standard/sustainability.md` — stay-current cadence (weekly upstream check, monthly Emacs version check), 4-tier troubleshooting protocol (recover_from_breakage → skill_self_improve → cross-vault coord → upstream contribution), upgrade protocol, integration of findings during operation
- Implementation deferred to v1.0 campaign Phase 2 (concrete schedules, runbook teeth, automation)

**Telemetry framework outlined**:
- `what/standard/telemetry.md` — channel (GitHub Issues w/ `telemetry` label per ADR 005), permission model (default opt-out, layered consent, per-submission confirm), submission contents schema outline (friction signals, ADR proposals, customizations, perf metrics), aggregation flow upstream, **agentic SRE feedback-loop diagram** (operator session → friction → operator-gated ADR → telemetry submit → fleet aggregate → upstream ADR → publish → operator pulls update)
- Schema details + skill implementations deferred to v1.0 campaign Phase 2

**Skill stubs**:
- `how/standard/skills/skill_telemetry_submit.md` (stub — operator-gated submission)
- `how/standard/skills/skill_telemetry_aggregate.md` (stub — maintainer-side fleet aggregation)
- Both reference framework doc; full implementation in v1.0 P2

**Campaign scaffold**:
- `how/campaigns/campaign_spacelattice_v1_0/campaign_spacelattice_v1_0.md` — master file, 6 phases (P0 planning → P5 v1.0 release), mission_count + estimated_sessions = TBD pending M-Planning-01
- `how/campaigns/campaign_spacelattice_v1_0/CLAUDE.md` — campaign-scoped governance overlay
- `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_planning_01.md` — **the planning mission**, ready-to-run after this commit. Designs the rest of the campaign (mission tree, scope, estimation, phase-gate criteria, telemetry schema, sustainability runbook expansion plan, audit-findings closure plan, LP fork branding execution plan, customization walk-through mission grouping, user-in-the-loop session protocol)

**Audit findings tracked**:
- #4 inherited backlog cleanup → 6 ideas marked `status: deferred` (this commit); closure scope in v1.0 P1
- #5 sanitization WARNs → tracked; ADR closure in v1.0 P1
- #6 self-improve schedule → tracked; closure in v1.0 P2
- #7 peer federation → deferred to post-v1.0

**`.gitignore` extended** with telemetry outbox/sent (operator-local; gitignored).

**Files added in this turn**:
- `what/decisions/adr/adr_005_rename_to_spacelattice.md`
- `what/context/spacemacs/{AGENTS.md, spacemacs_customization_reference.md}`
- `what/standard/{lp-positioning, fork-strategy, sustainability, telemetry}.md`
- `who/upstreams/spacemacs_fork.md`
- `how/standard/skills/skill_telemetry_{submit, aggregate}.md` (stubs)
- `how/campaigns/campaign_spacelattice_v1_0/{campaign_spacelattice_v1_0, CLAUDE}.md`
- `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_planning_01.md`

**Operator hand-off**: trigger `mission_sl_planning_01` in next session to design the v1.0 campaign mission tree.

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
- **DoD #6 install-from-tarball validated**: regenerated tarball with Phase 8 fixes; extracted to clean ref dir at `/tmp/refclean-<utc>`; ran skill_install steps inline with isolated `HOME=/tmp/refhome-<utc>`; cloned Spacemacs at pinned SHA; rendered templates; symlinked adna layer; **batch boot succeeded in 3.5 min, exit 0**; `(adna/health-check)` returned OK on the ref-clean install. The canonical peer-operator workflow is end-to-end validated.
- **Phase 8 followup**: dotfile sets `vterm-always-compile-module t` so first-install in batch mode doesn't block on the `vterm-module` interactive compile prompt. This was caught when the ref-clean boot hung waiting for "Compile vterm-module? (y or n)".

### Genesis AAR + ADR 003 (2026-05-05) — closes Standing Order #5

- **Genesis AAR** at `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`. Free-standing artifact (no formal mission file existed because genesis was plan-driven). 13/13 deliverables validated, 8-row gap register, 4 technical-debt entries, GO readiness, 8 lessons learned. Closes Standing Order #5 ("every mission gets an AAR").
- **ADR 003 — Fix skill_install + skill_health_check batch-boot invocation**:
  - `skill_install.md` step 6 was `emacs --batch -l ~/.spacemacs` — wrong; loads only the dotfile, not Spacemacs's bootstrap. Fixed to `-l ~/.emacs.d/init.el`.
  - `skill_install.md` step 6 also used `| tee | tail` which SIGPIPE-killed emacs. Fixed to `> $LOG 2>&1` redirect.
  - `skill_health_check.md` checks D + E carried the same wrong invocation. Fixed.
- **`build_graph.py` SKIP_DIRS extended**: `.publish-clone` and `dist` now skipped. Without this, running `adna-index-project` after a publish would double-count vault content (the `.publish-clone/` working clone holds a full copy of the published tree). Graph node count corrects from spurious 448 back to actual ~228 nodes.

### Phase 7 step 6 (GitHub publish, 2026-05-05)

- **`LatticeProtocol/Spacemacs.aDNA` PUBLIC** at https://github.com/LatticeProtocol/Spacemacs.aDNA
- Tagged `v0.1.0-genesis`
- Tarball SHA-256: `55b1a04a7e5c99fe...` (size 680197 bytes)
- Publish receipt: `who/peers/published/20260505T023357Z.md`
- License: GPL-3.0 (matches Spacemacs upstream)

### DoD final sweep — all 8 checks GREEN, no deferrals (2026-05-04)

- DoD #1 git repo + triad ✅
- DoD #2 skill_install end-to-end ✅ (real ~/.emacs.d/ install)
- DoD #3 skill_health_check A-F ✅ (all 6 classes including emacs batch boot + adna self-test)
- DoD #4 M-x adna-index-project ✅ (elisp wrapper invokes Python CLI; graph.json 225 nodes, 342 edges)
- DoD #5 skill_self_improve demo ✅ (ADR 001 evidence)
- DoD #6 install-from-tarball ✅ (ref-clean install boots, adna/health-check OK)
- DoD #7 private content gitignored ✅ (zero violations)
- DoD #8 README operator-orientation ✅

### Phase 7 (complete except GitHub push)

### Phase 7 (complete except GitHub push)

- **`how/standard/skills/skill_publish_lattice.md`** — 7-step publishing skill: clean-state check, build publish tree (rsync with explicit excludes for `what/local/`, `how/local/`, `who/operators/`, `deploy/`, `dist/`, `.git/`, `how/sessions/active/`, `*.dryrun.log`), sanitization scan via LAYER_CONTRACT § 4, tarball at `dist/<utc>.tar.gz`, extract + health-check the tarball, push to `github.com/LatticeProtocol/Spacemacs.aDNA` (REQUIRES OPERATOR CONFIRMATION), publish receipt at `who/peers/published/<utc>.md`.
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
  - `layers.md` — canonical Spacemacs layer set + the Spacemacs.aDNA-specific `adna` layer
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
| 7 — Lattice publishing | pending | tarball + push to `github.com/LatticeProtocol/Spacemacs.aDNA` |
| DoD | pending | 8-check end-to-end verification |
