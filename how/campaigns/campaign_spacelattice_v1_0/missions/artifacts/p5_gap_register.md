---
type: artifact
artifact_id: p5_gap_register
mission: mission_sl_p5_00_strategic_aar_gap_analysis
status: final
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
tags: [p5, gap-analysis, gap-register, v1.0, spacelattice]
---

# P5 Gap Register — Spacemacs v1.0

Produced by P5-00 strategic AAR + gap analysis (2026-05-10).
Gates P5-01 through P5-07 execution.

## Sweep Summary

| Source | Files Read | Gaps Found |
|--------|-----------|------------|
| ADR sweep (`what/decisions/adr/`) | 34 ADRs | 0 — all accepted |
| `what/standard/layers/adna/` elisp | funcs.el, keybindings.el, config.el, packages.el | 4 |
| `what/standard/layers/claude-code-ide/` | keybindings.el, config.el | 0 — clean |
| `what/standard/layers/spacemacs-latticeprotocol/` | config.el, packages.el | 0 — clean |
| Dotfile / package templates | dotfile.spacemacs.tmpl, packages.el.tmpl | 0 — intentional markers only |
| Backlog (`how/backlog/`) | 7 idea files | 5 actionable |
| Design goals vs. shipped | campaign_spacelattice_v1_0.md P5 gate criteria | 4 must-fix (all in-mission) |

**Total gaps**: 12 | **Must-fix**: 4 | **Nice-to-have**: 4 | **Post-v1.0**: 4

---

## Gap Table

| ID | Description | Source | Severity | Assigned | Notes |
|----|-------------|--------|----------|----------|-------|
| **GAP-01** | `adna/layouts.el` does not exist — layout system (`SPC a l`) entirely absent | `what/standard/layers/adna/` | **must-fix** | P5-01 | 8 named layouts + `SPC a l` transient required per P5 gate |
| **GAP-02** | Claude Code window contract undocumented — `adna/spawn-claude-*` functions implemented but window width coordination with treemacs unverified; acceptance runbook absent | funcs.el:251–422 | **must-fix** | P5-02 | `claude-code-ide-window-width 100` may overflow with treemacs open; ADR-036 scoped in P5-02 mission |
| **GAP-03** | `validate_layers.py` does not exist — no automated layer validation script; CI only runs elisp batch health-check, not structural layer compliance | CI / P5 gate | **must-fix** | P5-03 | P5 gate: CI green on 3 Emacs versions + validator pass |
| **GAP-04** | `adna/extensions-menu` is a stub — shows "No extensions registered" placeholder; no `scripts/` auto-discovery | keybindings.el:65 | **must-fix** | P5-04 | P5 gate: `SPC a x` auto-discovers `scripts/` directory |
| **GAP-05** | `adna/telemetry-validate` is a Phase 2 stub — validates JSON parseable + type field only; full field-level jsonschema validation deferred (comment: "Phase 4 layer hardening") | funcs.el:308 | **nice-to-have** | P5-05 | Update stale comment to "post-v1.0 hardening" during doc pass; stub is functional for v1.0 telemetry round-trip |
| **GAP-06** | `adna/lp-*` section header stale — comment says "Phase 3 namespace reservation" but functions are fully implemented | funcs.el:346 | **nice-to-have** | P5-05 | Remove outdated phase label during doc pass |
| **GAP-07** | `LAYER_CONTRACT.md` missing minimum files clause — 5-file convention (packages/config/keybindings/README/layers) is visible by example but not codified; future layers may omit files | backlog: idea_layer_contract_min_files | **nice-to-have** | P5-05 | Small doc addition; no ADR required (clarification of existing convention) |
| **GAP-08** | Visual inspection protocol absent — `skill_health_check` validates batch load but cannot verify visual appearance (theme, banner, transient menus, eww, centaur-tabs) | backlog: idea_visual_inspection_protocol | **nice-to-have** | P5-05 | Runbook `how/standard/runbooks/visual_inspection.md` + demo GIF; already routed to P5-05 in idea file |
| **GAP-09** | `skill_publish_lattice` uses rsync workaround — vault has no `git remote origin`; publish clones to a detached `.publish-clone/` dir instead of normal `git push` | backlog: idea_skill_publish_lattice_git_fix | **post-v1.0** | post-v1.0 | Fix is upstream in `aDNA.aDNA/campaign_adna_v2_infrastructure` M04; this vault defers until aDNA template ships the fix |
| **GAP-10** | Demo GIF absent — no asciinema recording or demo GIF in README showing layer interactions | backlog: idea_demo_gif | **post-v1.0** | P5-05 (scope review) | Nice-to-have for initial v1.0; can ship with a static README and record demo in P5-06 second-machine session |
| **GAP-11** | Obsidian plugin trimming — operator-specific plugin audit not done; not a vault standards concern | backlog: idea_plugin_trimming | **post-v1.0** | post-v1.0 | Operator-specific; defer |
| **GAP-12** | Startup optimization — further perf tuning beyond P3-13 batch (12 settings confirmed) | backlog: idea_startup_optimization | **post-v1.0** | post-v1.0 | P3-13 handled perf hardening; further optimization is v1.1 |

---

## Must-Fix Summary (blocks v1.0 tag)

| Gap | Mission | Gate Criterion |
|-----|---------|---------------|
| GAP-01 — No `adna/layouts.el` | P5-01 | `SPC a l a` activates agentic-default layout; operator-validated |
| GAP-02 — Claude Code window contract | P5-02 | Window coordination documented; acceptance runbook authored |
| GAP-03 — No `validate_layers.py` | P5-03 | Validator passes; CI green on 3 Emacs versions |
| GAP-04 — Extensions menu stub | P5-04 | `scripts/` seeded; `SPC a x` auto-discovers scripts |

All four must-fix gaps have assigned P5 missions. No new missions required.

## Nice-to-Have Summary (target P5, not v1.0 blocking)

| Gap | Mission | Scope |
|-----|---------|-------|
| GAP-05 — Telemetry validate stale comment | P5-05 | Update comment label; update docstring |
| GAP-06 — LP command stubs stale label | P5-05 | Remove "Phase 3 namespace reservation" header |
| GAP-07 — LAYER_CONTRACT min files | P5-05 | Add Clause N to LAYER_CONTRACT.md |
| GAP-08 — Visual inspection protocol | P5-05 | `how/standard/runbooks/visual_inspection.md` |

All four nice-to-have items fold into the P5-05 doc pass (1 session, already planned).

## Post-v1.0 Deferred

| Gap | Reason |
|-----|--------|
| GAP-09 — publish skill git remote | Blocked on upstream `aDNA.aDNA` template fix |
| GAP-10 — Demo GIF | Can land post-initial v1.0 release |
| GAP-11 — Obsidian plugin trimming | Operator-specific; not vault standards |
| GAP-12 — Startup optimization | v1.1 hardening track |

---

## P5 Mission Unblock Status

| Mission | Blocked by | Gap Register Result |
|---------|-----------|-------------------|
| P5-01 Agentic layout | P5-00 (this mission) | ✅ **UNBLOCKED** — GAP-01 confirmed must-fix; scope confirmed (8 layouts, `SPC a l`, context doc) |
| P5-02 Claude Code depth | P5-01 | Pending P5-01 |
| P5-03 Automated validation | — (parallel) | ✅ **UNBLOCKED** — GAP-03 confirmed; `validate_layers.py` + 3-version CI scoped |
| P5-04 Command tree | — (parallel) | ✅ **UNBLOCKED** — GAP-04 confirmed; `scripts/` + `SPC a x` auto-discovery scoped |
| P5-05 Doc pass | P5-01–04 | Pending upstream missions |
| P5-06 Second-machine | P5-05 | Pending |
| P5-07 Tag v1.0.0 | P5-06 | Pending |

---

## Readiness Statement

**P5-00 gate**: PASS. 
- 4 must-fix gaps found; all assigned to existing P5 missions (P5-01/02/03/04). No new missions required.
- 4 nice-to-have gaps fold into P5-05 doc pass. No scope creep.
- 4 items explicitly deferred post-v1.0 with rationale.
- ADR record is clean (34/34 accepted). No orphaned proposed/stub ADRs.

**Next**: P5-01 (agentic layout system) + P5-03 + P5-04 (parallel-capable) are all unblocked.
