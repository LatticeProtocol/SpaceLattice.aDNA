---
campaign_id: campaign_spacelattice_v1_0
type: campaign
title: "SpaceLattice v1.0 — Genesis to Production"
owner: stanley
status: execution
phase_count: 6
mission_count: 31
estimated_sessions: "36-53"
calibrated_sessions: 48
estimation_class: governance-broad
priority: medium
predecessor: "spacemacs.aDNA genesis (plan-driven; AAR at how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md)"
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
p2_progress: "4/4 missions closed ✅ P2 COMPLETE"
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
tags: [campaign, spacelattice, v1_0, daedalus, customization_walk, telemetry, lp_fork, sustainability]
---

# Campaign — SpaceLattice v1.0 (Genesis to Production)

## Mission statement

Take SpaceLattice.aDNA from **v0.2.0** (rename + repositioning + framework outlines) to **v1.0.0** (production-ready agentic IDE governance vault for developers doing agentic software engineering with the LatticeProtocol stack — with sibling `LatticeProtocol/spacelattice` Spacemacs fork branded and operational, sustainability + telemetry frameworks live, and a complete customization walk validated with operator-in-the-loop).

## Predecessors

- Genesis (Plan A): `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan A; AAR at `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- Plan B (rename + framework foundation): `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan B (this campaign opens at Plan B exit)

## Mission tree summary

| Phase | Missions | Count | Sessions est. |
|-------|----------|-------|---------------|
| P0 | mission_sl_planning_01 | 1 | 1 (closed) |
| P1 | p1_01_backlog_cleanup, p1_02_sanitization_warns_adr, p1_03_self_improve_schedule | 3 | 3-4 |
| P2 | p2_01_sustainability_runbook_teeth, p2_02_telemetry_schema, p2_03_telemetry_submit_skill, p2_04_telemetry_aggregate_skill_and_round_trip | 4 | 5-8 |
| P3 | p3_01 dotfile-entry-lifecycle, p3_02 dotspacemacs-variables, p3_03 layer-anatomy-api, p3_04 themes-modeline-banner-startup, p3_05 editing-completion-packages, p3_06 perf-evil-fonts, p3_07 wild-workarounds-org, p3_08 languages-keys-perf, p3_09 obsidian-plugin-audit | 9 | 12-17 |
| P4 | p4_01 clone-fork, p4_02 distribution-layer, p4_03 theme, p4_04 branding-strings, p4_05 banner-assets, p4_06 news-welcome-dotfile, p4_07 ci-workflows, p4_08 first-rebase-skill-install-update | 8 | 9-13 |
| P5 | p5_01 doc-pass, p5_02 second-machine-install, p5_03 tag-release-notes | 3 | 3 |
| **Total** | | **28** | **32-45 (calibrated ~39)** |

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
- `mission_sl_p3_06_perf_evil_fonts` — §2.5 (performance), §2.6 (evil + misc), §2.7 (font + icon)
- `mission_sl_p3_07_wild_workarounds_org` — §3.1 (wild combos), §3.2 (10 canonical workarounds), §3.3 (org-mode power-user)
- `mission_sl_p3_08_languages_keys_perf` — §3.4 (LSP + tree-sitter + DAP), §3.5 (keybinding philosophy + `SPC o l`), §3.6 (perf recipes); P3 phase-gate evidence
- `mission_sl_p3_09_obsidian_plugin_audit` — trim `.obsidian/plugins/` from 15 plugins (~13MB) to essentials (~1.5MB); document optionals; operator UX verification post-trim *(added at P1-01 backlog audit 2026-05-06)*

**Mission count**: 10 (1 infrastructure + 9 customization walk). Sessions estimate: 12-17.

**Phase exit gate**:
- [x] P3-00 closed (infrastructure) ✅
- [ ] All 9 P3 customization walk missions (P3-01 through P3-09/10/11) closed with AARs
- [ ] All 22 dimensions reviewed in operator-in-the-loop sessions
- [ ] `who/operators/stanley.md` operator profile updated with all decisions
- [ ] `what/local/operator.private.el` populated with operator-specific overrides
- [ ] Standard layer absorbed validated patterns via `skill_layer_promote` (those eligible for commons)

### Phase 4 — Fork branding (LP playbook execution)

Execute the LP fork playbook from `what/context/spacemacs/spacemacs_customization_reference.md` § 4 + `what/standard/fork-strategy.md` against `LatticeProtocol/spacelattice`.

**Scope** (8 missions, sequenced):

- `mission_sl_p4_01_clone_fork_set_remotes` — local clone of fork; upstream remote set; `lp-develop` branch
- `mission_sl_p4_02_distribution_layer` — new `layers/+distributions/spacelattice/` (declares dependency on `spacemacs` distribution; LP keybindings `SPC o l`)
- `mission_sl_p4_03_theme` — new `layers/+themes/latticeprotocol-theme/` (dark + light)
- `mission_sl_p4_04_branding_strings` — patches to `core/core-spacemacs-buffer.el` (logo title + buffer name), `core/core-versions.el` (`latticeprotocol-version`), `core/core-spacemacs.el` (repository constants); prefer additive `core/lp-branding.el` module
- `mission_sl_p4_05_banner_assets` — image (PNG + SVG + ICNS) + ASCII text variants 000–003
- `mission_sl_p4_06_news_welcome_dotfile` — `core/news/news-1.0.0.org` + `lp-welcome.el` widget + `dotspacemacs-template.el` LP defaults
- `mission_sl_p4_07_ci_workflows` — `.github/workflows/{ci,upstream-sync}.yml`
- `mission_sl_p4_08_first_rebase_skill_install_update` — first weekly rebase against `upstream/develop`; vault `skill_install.md` updated to clone the LP fork; **P4 phase-gate validation**

**Mission count**: 8. Sessions estimate: 9-13.

**Phase exit gate**:
- [ ] All 8 P4 missions closed with AARs
- [ ] Operator can `gh repo clone LatticeProtocol/spacelattice` + run `skill_install` against the fork + see SpaceLattice branding (banner, modeline, frame title, distribution name `spacelattice`)
- [ ] First weekly rebase against `upstream/develop` succeeds with documented conflict resolutions
- [ ] CI workflow green on Emacs 28.2 + 29.x (matrix per fork-strategy)

### Phase 5 — Polish + v1.0 release

Final hardening before v1.0.

**Scope** (3 missions, sequenced):

- `mission_sl_p5_01_doc_pass` — README, MANIFEST, CLAUDE.md, all skill READMEs reviewed for v1.0 readiness; `~/lattice/CLAUDE.md` workspace row updated; CHANGELOG release entry staged
- `mission_sl_p5_02_second_machine_install` — true peer install on second host; `skill_install` E2E from clean clone; receipt to `deploy/<host>/`
- `mission_sl_p5_03_tag_release_notes` — `v1.0.0` tag on vault; `latticeprotocol-1.0.0` tag on fork; `lp-stable` branch; release notes; **campaign AAR**

**Mission count**: 3. Sessions estimate: 3.

**Phase exit gate**:
- [ ] All 3 P5 missions closed with AARs
- [ ] `v1.0.0` tagged on `LatticeProtocol/SpaceLattice.aDNA` (vault) — `gh release` published
- [ ] `latticeprotocol-1.0.0` tagged on `LatticeProtocol/spacelattice` (fork) — release notes shipped via `core/news/news-1.0.0.org`
- [ ] Second-machine install validated (P5-02 receipt)
- [ ] Release notes published (CHANGELOG + README + GitHub release)
- [ ] Campaign AAR closes the campaign; STATE.md updated

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
- LP positioning: `what/standard/lp-positioning.md`
- Fork strategy: `what/standard/fork-strategy.md`
- Customization reference: `what/context/spacemacs/spacemacs_customization_reference.md`
- Sustainability framework: `what/standard/sustainability.md`
- Telemetry framework: `what/standard/telemetry.md`
- User-in-the-loop runbook (P3): `how/standard/runbooks/customization_session_protocol.md`
- Genesis AAR: `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- M-Planning-01 AAR: `how/campaigns/campaign_spacelattice_v1_0/missions/artifacts/aar_mission_sl_planning_01.md`
- Plan B: `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan B
