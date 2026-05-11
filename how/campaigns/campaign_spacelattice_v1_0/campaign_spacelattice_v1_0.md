---
campaign_id: campaign_spacelattice_v1_0
type: campaign
title: "Spacemacs v1.0 — Genesis to Production"
owner: stanley
status: execution
phase_count: 6
mission_count: 41
estimated_sessions: "47-68"
calibrated_sessions: 62
estimation_class: governance-broad
priority: medium
predecessor: "spacemacs.aDNA genesis (plan-driven; AAR at how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md)"
created: 2026-05-05
updated: 2026-05-10
last_edited_by: agent_stanley
p2_progress: "4/4 missions closed ✅ P2 COMPLETE"
p3_core_progress: "13/13 missions closed ✅ P3 FULLY COMPLETE (2026-05-08) — core P3-00→P3-08 + extended P3-09/12/13/14 all closed"
ratified_by:
  - what/decisions/adr/adr_005_rename_to_spacelattice.md
  - what/decisions/adr/adr_017_rename_to_spacemacs_adna.md
tags: [campaign, spacelattice, v1_0, daedalus, customization_walk, telemetry, lp_fork, sustainability]
---

# Campaign — Spacemacs v1.0 (Genesis to Production)

## Mission statement

Take Spacemacs.aDNA from **v0.2.0** (rename + repositioning + framework outlines) to **v1.0.0** (production-ready agentic IDE governance vault for developers doing agentic software engineering with the LatticeProtocol stack — with sibling `LatticeProtocol/spacelattice` Spacemacs fork branded and operational, sustainability + telemetry frameworks live, and a complete customization walk validated with operator-in-the-loop).

## Predecessors

- Genesis (Plan A): `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan A; AAR at `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- Plan B (rename + framework foundation): `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan B (this campaign opens at Plan B exit)

## Mission tree summary

| Phase | Missions | Count | Sessions est. |
|-------|----------|-------|---------------|
| P0 | mission_sl_planning_01 | 1 | 1 (closed) |
| P1 | p1_01_backlog_cleanup, p1_02_sanitization_warns_adr, p1_03_self_improve_schedule | 3 | 3-4 |
| P2 | p2_01_sustainability_runbook_teeth, p2_02_telemetry_schema, p2_03_telemetry_submit_skill, p2_04_telemetry_aggregate_skill_and_round_trip | 4 | 5-8 |
| P3 | p3_01 dotfile-entry-lifecycle, p3_02 dotspacemacs-variables, p3_03 layer-anatomy-api, p3_04 themes-modeline-banner-startup, p3_05 editing-completion-packages, p3_06 perf-evil-fonts, p3_07 wild-workarounds-org, p3_08 languages-keys-perf, p3_09 obsidian-plugin-audit, **p3_12 platform-context-macos**, **p3_13 dotfile-perf-hardening**, **p3_14 org-mode-deep-config** | 12 | 14-20 |
| P4 | p4_01 clone-fork, p4_02 distribution-layer, p4_03 theme, p4_04 branding-strings, p4_05 banner-assets, p4_06 news-welcome-dotfile, p4_07 ci-workflows, p4_08 first-rebase-skill-install-update, **p4_09 claude-code-ide-layer**, **p4_10 agent-command-tree** | 10 | 11-16 |
| P5 | p5_00 strategic-aar, p5_01 agentic-layout, p5_02 claude-code-depth, p5_03 automated-validation, p5_04 shared-command-tree, p5_05 doc-pass, p5_06 second-machine-install, p5_07 tag-release-notes | 8 | 9-11 |
| **Total** | | **41** | **47-68 (calibrated ~62)** |

## Phases

### Phase 0 — Planning (M-Planning-01)

**Single mission**: `mission_sl_planning_01.md`.

**Objective**: Review integrated context (open audit findings, customization reference, LP fork playbook, LP/aDNA reference repos, sustainability + telemetry frameworks) and design the rest of the campaign — concrete mission tree, scope per mission, estimation, phase-gate criteria.

**Scope**: Closed by `mission_sl_planning_01.md` on 2026-05-05. Produced 26 P1-P5 mission scaffolds, the user-in-the-loop runbook (`how/standard/runbooks/customization_session_protocol.md`), per-phase scope refinement (this section), and phase-gate criteria (each phase below).

**Mission count**: 1 (closed).

**Phase exit gate** — *MET 2026-05-05*:
- [x] M-Planning-01 closed with full AAR
- [x] All P1-P5 mission files instantiated with `status: planned`
- [x] Campaign master: `mission_count`, `estimated_sessions`, `calibrated_sessions`, `status: execution` set
- [x] Operator approval (this turn)

### Phase 1 — Audit closure

Close the open audit findings carried forward from genesis (Gap Register #4, #5, #6; #7 deferred to release notes only).

**Scope** (3 missions, parallel-capable):

- `mission_sl_p1_01_backlog_cleanup` — closes finding #4 (6 inherited backlog `idea_*.md` files; review + adapt-or-archive)
- `mission_sl_p1_02_sanitization_warns_adr` — closes finding #5 (private IPv4 + email WARNs in inherited `skill_l1_upgrade.md`; ADR-acknowledge or upstream PR)
- `mission_sl_p1_03_self_improve_schedule` — closes finding #6 (`skill_self_improve` schedule mechanism: launchd / cron / session-end hook + ADR)
- Finding #7 (peer federation) stays deferred; documented in P5-03 release notes

**Mission count**: 3. Sessions estimate: 3-4.

**Phase exit gate**:
- [ ] All 3 P1 missions closed with AARs
- [ ] STATE.md "Active Blockers" empty
- [ ] Audit findings #4, #5, #6 → closed (recorded in STATE.md)
- [ ] At least 2 ADRs filed (#5 ADR-or-PR, #6 schedule)

### Phase 2 — Sustainability + telemetry implementation

Take the framework outlines (`what/standard/sustainability.md` + `what/standard/telemetry.md`) to working code.

**Scope** (4 missions, sequenced):

- `mission_sl_p2_01_sustainability_runbook_teeth` — `update_spacemacs.md` runbook gets concrete teeth (sed patterns × 5 conflict-prone files, file-disposition heuristics, CI integration design)
- `mission_sl_p2_02_telemetry_schema` — full JSON Schema for the 4 submission classes; telemetry-specific anonymization extensions; operator + maintainer validation logic; privacy-posture verification
- `mission_sl_p2_03_telemetry_submit_skill` — `skill_telemetry_submit` from stub to full procedure; `.github/ISSUE_TEMPLATE/telemetry.yml` authored
- `mission_sl_p2_04_telemetry_aggregate_skill_and_round_trip` — `skill_telemetry_aggregate` from stub to full procedure; **first end-to-end round-trip test** (operator submits → maintainer aggregates → ADR drafted → publish)

**Mission count**: 4. Sessions estimate: 5-8.

**Phase exit gate**:
- [ ] All 4 P2 missions closed with AARs
- [x] Telemetry schema landed — `what/standard/telemetry_schema.json` (JSON Schema Draft-07, ADR-009); `telemetry.md` status: active (P2-02 closed 2026-05-06)
- [ ] `update_spacemacs.md` runbook teeth match outline (sed + heuristics + CI design)
- [ ] Schedule for `skill_self_improve` documented + working (closed in P1-03; verified at P2 close)
- [ ] **First telemetry round-trip demonstrated end-to-end** (operator-submitted demo → maintainer aggregation → ADR draft → publish round-trip)

### Phase 3 — Customization walk-through (user-in-the-loop)

Systematic walk through the **22 dimensions** of `what/context/spacemacs/spacemacs_customization_reference.md`, with operator-in-the-loop at each dimension. All P3 missions follow the 7-step protocol in `how/standard/runbooks/customization_session_protocol.md` (authored by P0).

**Scope** (10 missions — P3-00 infrastructure + 22 customization dimensions grouped):

- `mission_sl_p3_00_closed_loop_validation` ✅ — `skill_inspect_live` + `skill_health_check` D+ + `skill_deploy` Step 9; ADR-014 accepted *(added P3 pre-flight 2026-05-06)*
- `mission_sl_p3_01_dotfile_entry_lifecycle` — §1.1 (5 dotfile functions), §1.2 (location resolution), §1.10 (consolidated lifecycle), §2.4 (precise lifecycle table)
- `mission_sl_p3_02_dotspacemacs_variables` — §1.3 (~85 variables across 9 sub-groups; the "big walk")
- `mission_sl_p3_03_layer_anatomy_api` — §1.4 (layer anatomy + grammar), §1.5 (`configuration-layer/` API surface)
- `mission_sl_p3_04_themes_modeline_banner_startup` — §1.6 (theme), §1.7 (modeline; 6 themes), §1.8 (banner + selection logic), §1.9 (startup buffer + scratch + frame title)
- `mission_sl_p3_05_editing_completion_packages` — §2.1 (editing styles), §2.2 (completion stack), §2.3 (package mgmt knobs)
- `mission_sl_p3_06_perf_evil_fonts` ✅ — §2.5 (performance), §2.6 (evil + misc), §2.7 (font + icon)
- `mission_sl_p3_07_wild_workarounds_org` ✅ — §3.1 (wild combos), §3.2 (10 canonical workarounds), §3.3 (org-mode power-user)
- `mission_sl_p3_08_languages_keys_perf` ✅ — §3.4 (LSP + tree-sitter + DAP), §3.5 (keybinding philosophy + `SPC o l`), §3.6 (perf recipes); **P3 phase-gate PASSED** (22 dimensions complete 2026-05-08)
- `mission_sl_p3_09_obsidian_plugin_audit` ✅ — 15 plugins → 2 tracked (advanced-canvas + templater); 10 optional documented; `what/context/obsidian_plugins.md` created *(2026-05-08)*
- `mission_sl_p3_12_platform_context_macos` ✅ — `dwim-shell-command` → additional-packages; Karabiner Hyper key (Caps Lock → H-) documented; darwin-conditional block confirmed *(2026-05-08)*
- `mission_sl_p3_13_dotfile_perf_hardening` ✅ — all 12 ADR-018 settings confirmed without adjustment; perf hardening batch operator-gated *(2026-05-08)*
- `mission_sl_p3_14_org_mode_deep_config` ✅ — 4 capture templates + org-clock + ox-md export; `what/context/org_mode_config.md` stub → active *(2026-05-08)*

**Mission count**: 13 (1 infrastructure + 12 customization walk). Sessions estimate: 14-20.

**Phase exit gate**:
- [x] P3-00 closed (infrastructure) ✅
- [x] All 12 P3 customization walk missions (P3-01→P3-09, P3-12, P3-13, P3-14) closed with AARs ✅ (2026-05-08)
- [x] All 22 dimensions reviewed in operator-in-the-loop sessions ✅
- [x] `who/operators/stanley.md` operator profile updated with all decisions ✅
- [ ] `what/local/operator.private.el` populated with operator-specific overrides (deferred to first `skill_install` run)
- [ ] Standard layer absorbed validated patterns via `skill_layer_promote` (deferred to P4+)

**P3 COMPLETE (2026-05-08)**

### Phase 4 — Fork branding (LP playbook execution)

Execute the LP fork playbook from `what/context/spacemacs/spacemacs_customization_reference.md` § 4 + `what/standard/fork-strategy.md` against `LatticeProtocol/spacelattice`.

**Scope** (8 missions, sequenced):

- `mission_sl_p4_01_clone_fork_set_remotes` ✅ — LP layer scaffold + skill_install Step 5 extended to all 4 layers (vault-only model, ADR-024; completed 2026-05-08)
- `mission_sl_p4_02_distribution_layer` ✅ — `SPC o l` keybindings live (5 bindings mapped to adna/claude-code-ide functions); `spacelattice_distribution_spec.md` + ADR-025 accepted (completed 2026-05-08)
- `mission_sl_p4_03_theme` — new `layers/+themes/latticeprotocol-theme/` (dark + light)
- `mission_sl_p4_04_branding_strings` — patches to `core/core-spacemacs-buffer.el` (logo title + buffer name), `core/core-versions.el` (`latticeprotocol-version`), `core/core-spacemacs.el` (repository constants); prefer additive `core/lp-branding.el` module
- `mission_sl_p4_05_banner_assets` — image (PNG + SVG + ICNS) + ASCII text variants 000–003
- `mission_sl_p4_06_news_welcome_dotfile` — `core/news/news-1.0.0.org` + `lp-welcome.el` widget + `dotspacemacs-template.el` LP defaults
- `mission_sl_p4_07_ci_workflows` — `.github/workflows/{ci,upstream-sync}.yml`
- `mission_sl_p4_08_first_rebase_skill_install_update` — first weekly rebase against `upstream/develop`; vault `skill_install.md` updated to clone the LP fork; **P4 phase-gate validation**
- `mission_sl_p4_09_claude_code_ide_layer` — complete `what/standard/layers/claude-code-ide/` (skeleton created 2026-05-07); update `skill_install`/`skill_deploy` to symlink the layer; health-check validation; operator `SPC c c` acceptance test *(added 2026-05-07 — claude-code-ide.el integration, ADR-019)*
- `mission_sl_p4_10_agent_command_tree` ✅ — `adna/extensions-menu` transient stub added to `keybindings.el`; `SPC a x` wired; `skill_adna_index.md` re-index note added; ADR-034 accepted *(completed 2026-05-10)*

**Mission count**: 10. Sessions estimate: 11-16.

**Phase exit gate**:
- [x] All 10 P4 missions closed with AARs ✅ (2026-05-10)
- [x] Vault-only model (ADR-024) — LP layers live in `what/standard/layers/`; `skill_install` Step 5 symlinks all 4 layers ✅
- [x] First pin bump (`skill_update_pin`): `e57594e7` → `37e2a32b`; install source → LP fork ✅ (ADR-032)
- [x] CI workflow authored: byte-compile matrix Emacs 28.2/29.4/snapshot + upstream drift monitor ✅ (ADR-031)

**P4 COMPLETE (2026-05-10)**

### Phase 5 — Strategic AAR + Final build-out + v1.0 release

Comprehensive final phase: opens with strategic review + gap analysis, delivers the agentic layout system, Claude Code integration depth, automated validation infrastructure, and shared human-agent command tree, then closes with the original polish + release sequence.

**Scope** (8 missions, sequenced with two parallel tracks after P5-00):

**P5-00 — Strategic AAR + Gap Analysis** *(opens P5; gates all implementation)*
- Walk all ADRs, `what/standard/`, `adna/funcs.el` stubs, and `how/backlog/` for gaps vs. original design goals
- Output: `p5_gap_register.md` with must-fix / nice-to-have / post-v1.0 tiers
- Gate: shapes scope for P5-01 through P5-04

**P5-01 — Agentic Layout System** *(2 sessions)*
- `what/standard/layers/adna/layouts.el` — 4 named layouts (agentic-default, vault-navigation, campaign-planning, code-review)
- Default layout: treemacs left + Claude terminal bottom + file buffer center-right
- `SPC a l` transient + `adna/layouts-menu`; opt-in boot hook in dotfile template
- `what/context/spacemacs/agentic_layout_guide.md`; ADR-035
- Folds in deferred `mission_sl_p4_layout_intelligence.md`

**P5-02 — Claude Code Integration Depth** *(1 session)*
- Fill `adna/funcs.el` Claude Code spawn stubs; add `adna/claude-project-switch`
- Window coordination audit (treemacs + Claude terminal width contract)
- `adna-bridge.md` updated to reflect P4-09 live layer
- Multi-project session management context doc + operator acceptance test runbook; ADR-036

**P5-03 — Automated Validation Infrastructure** *(1 session, parallel with P5-01/02)*
- `what/standard/index/validate_layers.py` — layer structure validator (no Emacs needed)
- `skill_health_check.md` checks G/H/I (per-layer byte-compile, structure, graph freshness)
- CI: add `validate_layers` job alongside byte-compile matrix
- `how/standard/runbooks/operator_acceptance_test.md` — structured live boot checklist; ADR-037

**P5-04 — Shared Human-Agent Command Tree** *(1 session)*
- `what/standard/layers/adna/scripts/` directory + 3 seed scripts (show-sitrep, run-health-check, open-claude-with-layout)
- `adna/load-scripts` auto-discovery — `SPC a x` self-populates from scripts/ at init
- `what/context/shared_command_space.md` — bidirectional pattern, MCP tool bridge, token economy
- `agent_command_tree.md` updated; `LAYER_CONTRACT.md` scripts/ clause; ADR-038

**P5-05 — Doc Pass** *(1 session, was P5-01)*
- README, MANIFEST, CLAUDE.md, all skill READMEs reviewed for v1.0 readiness
- Review P5-01 through P5-04 outputs (agentic_layout_guide, shared_command_space) for accuracy
- `~/lattice/CLAUDE.md` workspace row → "Production v1.0"; CHANGELOG staged

**P5-06 — Second-Machine Install Validation** *(1 session, was P5-02)*
- True peer install on second host; `skill_install` E2E; deploy receipt
- Verify agentic layout activates at boot; Claude terminal positions correctly

**P5-07 — Tag v1.0.0 + Release Notes + Campaign AAR** *(1 session, was P5-03)*
- `git tag v1.0.0` on vault; `gh release create` with release notes
- Release notes highlight: agentic layout, shared command tree, automated validation
- **Campaign AAR**: full scorecard across all 41 missions + 6 phases

**Mission count**: 8. Sessions estimate: 9-11.

**Phase exit gate**:
- [ ] P5-00 complete — gap register filed; no must-fix items outstanding
- [ ] P5-01 complete — agentic layout live; `SPC a l a` activates correctly (operator-validated at boot)
- [ ] P5-02 complete — Claude Code stubs filled; window contract documented; acceptance test runbook authored
- [ ] P5-03 complete — `validate_layers.py` passes; CI green on 3 Emacs versions + validator; operator acceptance checklist authored
- [ ] P5-04 complete — `scripts/` directory seeded; `SPC a x` auto-discovers scripts; shared_command_space.md live
- [ ] P5-05 complete — all docs v1.0 ready; CHANGELOG staged
- [ ] P5-06 complete — second-machine receipt filed; agentic layout validated on peer host
- [ ] P5-07 complete — `v1.0.0` tagged; `gh release` published; campaign AAR closes all phases; STATE.md → "v1.0.0 released"

## Decision points / phase gates

Between each phase, the operator confirms before the next phase opens. Per Standing Order #1 ("Phase gates are human gates").

## Estimation classes (per workspace conventions)

This campaign is **governance-broad**: multi-domain (customization + branding + telemetry), multi-host validation, sustained operator-in-the-loop interaction. Per-phase estimates set at M-Planning-01 close. Total calibrated: ~38 sessions.

## Anti-scope

- New aDNA pattern formalization (`BattleStation.aDNA`) — defer until N≥2 tooling vaults exist
- Cross-vault federation (peer telemetry visibility across vaults) — defer to post-v1.0
- Spacemacs upstream PRs from our work — handle case-by-case via `skill_upstream_contribution`; not a campaign deliverable
- Multi-OS install validation beyond macOS + Linux — Windows (native) explicitly out per genesis ADR

## References

- ADR 005 (rename + repositioning): `what/decisions/adr/adr_005_rename_to_spacelattice.md`
- ADR 017 (rename → Spacemacs.aDNA): `what/decisions/adr/adr_017_rename_to_spacemacs_adna.md`
- ADR 018 (perf hardening batch): `what/decisions/adr/adr_018_perf_config_hardening.md`
- ADR 019 (claude-code-ide layer): `what/decisions/adr/adr_019_claude_code_ide_layer.md`
- LP positioning: `what/standard/lp-positioning.md`
- Fork strategy: `what/standard/fork-strategy.md`
- Customization reference: `what/context/spacemacs/spacemacs_customization_reference.md`
- Platform context (macOS): `what/context/platform_macos.md`
- Org-mode config reference: `what/context/org_mode_config.md`
- Agent command tree: `what/context/agent_command_tree.md`
- Sustainability framework: `what/standard/sustainability.md`
- Telemetry framework: `what/standard/telemetry.md`
- User-in-the-loop runbook (P3): `how/standard/runbooks/customization_session_protocol.md`
- macOS setup runbook: `how/standard/runbooks/macos_setup.md`
- Genesis AAR: `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- M-Planning-01 AAR: `how/campaigns/campaign_spacelattice_v1_0/missions/artifacts/aar_mission_sl_planning_01.md`
- Plan B: `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan B
