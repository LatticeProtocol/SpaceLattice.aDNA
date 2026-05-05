---
campaign_id: campaign_spacelattice_v1_0
type: campaign
title: "SpaceLattice v1.0 — Genesis to Production"
owner: stanley
status: planning
phase_count: 6
mission_count: TBD (designed by mission_sl_planning_01)
estimated_sessions: TBD
calibrated_sessions: TBD
estimation_class: governance-broad
priority: medium
predecessor: "spacemacs.aDNA genesis (plan-driven; AAR at how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md)"
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
tags: [campaign, spacelattice, v1_0, daedalus, customization_walk, telemetry, lp_fork, sustainability]
---

# Campaign — SpaceLattice v1.0 (Genesis to Production)

## Mission statement

Take SpaceLattice.aDNA from **v0.2.0** (rename + repositioning + framework outlines) to **v1.0.0** (production-ready agentic IDE governance vault for developers doing agentic software engineering with the LatticeProtocol stack — with sibling `LatticeProtocol/spacelattice` Spacemacs fork branded and operational, sustainability + telemetry frameworks live, and a complete customization walk validated with operator-in-the-loop).

## Predecessors

- Genesis (Plan A): `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan A; AAR at `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- Plan B (rename + framework foundation): `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan B (this campaign opens at Plan B exit)

## Phases

### Phase 0 — Planning (M-Planning-01)

**Single mission**: `mission_sl_planning_01` (this directory's first mission file).

**Objective**: Review integrated context (open audit findings, customization reference, LP fork playbook, LP/aDNA reference repos, sustainability + telemetry frameworks) and design the rest of the campaign — concrete mission tree, scope per mission, estimation, phase-gate criteria.

**Phase exit gate**: Operator approves the mission tree designed by M-Planning-01. The remaining mission files (P1 onwards) are scaffolded by M-Planning-01 with status `planned`; operator triggers each mission individually.

### Phase 1 — Audit closure

Close the open audit findings carried forward from genesis:

- **#4** Inherited backlog cleanup (6 idea files from .adna template, currently `status: deferred`)
- **#5** Sanitization WARNs in inherited L1 upgrade skill (private IPv4 + email) — formally acknowledged via ADR or upstream-fixed
- **#6** No schedule for `skill_self_improve` — implement scheduling mechanism
- Genesis open items integrated into v1.0 (this phase closes the standing-order overhang from Plan A)

Mission count: TBD by M-Planning-01 (estimate: 2-3 missions).

**Phase exit gate**: All 4 audit findings closed; STATE.md "Active Blockers" empty.

### Phase 2 — Sustainability + telemetry implementation

Take the framework outlines (`what/standard/sustainability.md` + `what/standard/telemetry.md`) to working code:

- `update_spacemacs.md` runbook gets concrete teeth (sed patterns, conflict-resolution heuristics)
- `skill_self_improve` schedule mechanism (cron / launchd / on-trigger)
- `skill_telemetry_submit` full procedure + sanitization extension
- `skill_telemetry_aggregate` full procedure
- GitHub issue template (`.github/ISSUE_TEMPLATE/telemetry.yml`) for the upstream repo
- First round-trip telemetry test (operator submits demo → maintainer aggregates → ADR drafted → publish round-trip)
- `who/peers/telemetry/{outbox,sent,inbox}/` structure operationalized

Mission count: TBD by M-Planning-01 (estimate: 3-4 missions).

**Phase exit gate**: Telemetry round-trip demonstrated end-to-end; sustainability runbook teeth match outline; cron/launchd schedule documented.

### Phase 3 — Customization walk-through (user-in-the-loop)

The big one. Systematic walk through the **22 dimensions** documented in `what/context/spacemacs/spacemacs_customization_reference.md`, with operator-in-the-loop at each dimension:

- Dotfile entry points (5 functions × lifecycle position)
- `dotspacemacs-*` variables (~85 variables across 9 groups)
- Layer anatomy + grammar
- `configuration-layer/` API surface
- Theme system + `latticeprotocol-theme` design
- Modeline (6 themes; LP modeline segment design)
- Banner system (LP banner asset preparation)
- Startup buffer / scratch / frame title / which-key
- Editing styles (vim / emacs / hybrid evaluation)
- Completion stack (helm / ivy / compleseus choice)
- Package management knobs
- Lifecycle ordering verification
- Performance knobs (LSP, GC, native-comp)
- Evil & misc toggles
- Font / icon handling (LP-specific font + icon strategy)
- Wild customizations survey + which to import
- Canonical workarounds applied
- Org-mode power-user setup (operator-tailored)
- Language stack patterns (operator's actual languages: Python ML, TypeScript, Rust, etc.)
- Keybinding remap philosophy + operator's `SPC o l` LP prefix
- Performance-tuning recipes applied
- LP-specific concerns

User-in-the-loop protocol: each customization mission opens with operator review of the dimension's spec section, operator signals preferences, agent drafts changes (per existing skill_layer_add / etc. workflows), operator gates each diff. Mission AAR captures decisions for the operator profile.

Mission count: TBD by M-Planning-01 (estimate: 8-12 missions covering the 22 dimensions in groups).

**Phase exit gate**: All 22 dimensions reviewed; operator profile (`who/operators/stanley.md`) updated with decisions; `what/local/operator.private.el` populated; standard layer absorbs operator-validated patterns via `skill_layer_promote` for those that should be commons.

### Phase 4 — Fork branding (LP playbook execution)

Execute the LP fork playbook from `what/context/spacemacs/spacemacs_customization_reference.md` § 4B against `LatticeProtocol/spacelattice`:

- Local clone of fork to `~/lattice/spacelattice/` (deferred from Plan B per ADR 005)
- Set up upstream remote + sync workflow
- New `layers/+distributions/spacemacs-latticeprotocol/` (or rename to `spacelattice` to match repo name; M-Planning-01 decides)
- New `layers/+themes/latticeprotocol-theme/` with dark + light themes (or `spacelattice-theme`)
- Branding constants: version, buffer name, banner title, frame title
- Banner asset replacement (PNG + SVG + ICNS + ASCII text variants)
- News mechanism: `core/news/news-1.0.0.org`
- Welcome widget: `lp-welcome` local package
- Dotfile template: `core/templates/dotspacemacs-template.el` defaults updated
- CI workflow: `.github/workflows/{ci,upstream-sync}.yml`
- Rebase cadence operationalized; first weekly rebase against `upstream/develop` succeeds
- `skill_install` updated to consume the LP fork instead of `syl20bnr/spacemacs`

Mission count: TBD by M-Planning-01 (estimate: 6-9 missions).

**Phase exit gate**: Operator can `gh repo clone LatticeProtocol/spacelattice` + run `skill_install` against the fork + see SpaceLattice branding (banner, modeline, frame title, distribution name). First rebase against upstream succeeds with documented conflict resolutions.

### Phase 5 — Polish + v1.0 release

Final hardening before v1.0:

- Doc pass: README, MANIFEST, CLAUDE, all skill READMEs reviewed for v1.0 readiness
- Peer-readiness: install-from-tarball validation (re-run DoD #6 against latest tarball)
- Install on a second reference machine (operator's secondary host or VM) — true peer scenario
- All audit findings closed; sanitization scan clean; health-check green across host matrix
- Tag `v1.0.0` on `LatticeProtocol/SpaceLattice.aDNA`
- Tag `latticeprotocol-1.0.0` on `LatticeProtocol/spacelattice` (the fork)
- `core/news/news-1.0.0.org` ships with the fork release
- Release announcement (informal — README + CHANGELOG entry)

Mission count: TBD by M-Planning-01 (estimate: 3-4 missions).

**Phase exit gate**: v1.0 tagged on both repos; second peer-machine install validated; release notes published; campaign AAR closes.

## Decision points / phase gates

Between each phase, the operator confirms before the next phase opens. Per Standing Order #1 ("Phase gates are human gates").

## Estimation classes (per workspace conventions)

This campaign is **governance-broad**: multi-domain (customization + branding + telemetry), multi-host validation, sustained operator-in-the-loop interaction. Per-phase estimates land at M-Planning-01 close.

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
- Genesis AAR: `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md`
- Plan B: `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` § Plan B
