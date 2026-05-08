---
type: framework
status: outline
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
implementation_phase: v1_0_campaign_p2
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
tags: [framework, sustainability, stay_current, troubleshoot, upgrade, daedalus]
---

# Sustainability Framework — Staying Current as an Agentic Context Fork

## Purpose

Spacemacs.aDNA is an **agentic context fork** of Spacemacs/Emacs — a governance vault + sibling code repo (`LatticeProtocol/spacelattice`) that tracks upstream `syl20bnr/spacemacs` and the broader Emacs ecosystem. This document defines the operating posture: how we stay current, troubleshoot downstream, upgrade, and integrate findings during routine operation.

This is the **outline**. Concrete schedules, automation, and runbook teeth are designed by M-Planning-01 and implemented in v1.0 campaign Phase 2.

## Cadences

| Activity | Cadence | Trigger | Mechanism |
|----------|---------|---------|-----------|
| Spacemacs upstream check | Weekly | cron / launchd / manual | `git fetch upstream develop && git log <pin>..origin/develop` |
| Spacemacs pin bump | As needed (notable upstream changes) | Operator decision | `update_spacemacs.md` runbook (ADR-gated) |
| Emacs version check | Monthly | Release tracking | Check `https://www.gnu.org/software/emacs/news.html`; bump pin in `pins.md` if minimum changes |
| Layer health check | Per-session (continuous) | `skill_health_check` invoked by other skills | `emacs --batch -l ~/.emacs.d/init.el --eval '(adna/health-check)'` |
| Self-improvement loop | Periodic + on friction | `skill_self_improve` schedule (TBD by planning mission) | Read recent sessions → detect friction → ADR-draft + diff + dry-run → operator gate |
| Vault audit | Monthly | Time-based | `skill_vault_review` (inherited skill) |

## Stay-current process

### 1. Spacemacs upstream

The fork at `LatticeProtocol/spacelattice` rebases against `upstream/develop` at the cadence above. Per LP fork playbook §4B.5:

- Track `upstream/develop` (the Spacemacs rolling branch)
- Fork branch: `lp-develop`
- Conflict-prone files: `core/templates/dotspacemacs-template.el`, `core/core-spacemacs-buffer.el`, `core/core-spacemacs.el`, `core/core-versions.el`, `layers/+distributions/spacemacs/packages.el`
- Mitigation: keep LP overrides in additive files (`core/lp-branding.el`) loaded with one-line patch upstream
- Maintain `UPSTREAM_REV` file; bump only after CI passes

The vault's `what/standard/pins.md` records the operator-facing SHA. The fork's pinned SHA can lead the vault's recorded SHA during validation; ADR-gated promotion when validated.

### 2. Emacs version

Spacemacs requires Emacs ≥ 28.2; we currently pin to ≥ 29.0 (`pins.md`) with this build at 29.4. Major Emacs releases:

- Track release announcements + `etc/NEWS` files
- New major version → ADR proposing the upgrade with rationale (tree-sitter, native-comp improvements, etc.)
- Operator confirms; `pins.md` updated; `skill_install` re-run

### 3. Package ecosystem

Layer-bundled packages from MELPA/ELPA evolve independently. Spacemacs's `dotspacemacs-frozen-packages` and `:pin` mechanisms allow operators to pin specific packages. Default policy: trust Spacemacs's own package management (it handles version conflicts).

Operator-private package overrides go in `what/local/operator.private.el` via `dotspacemacs-additional-packages`.

## Troubleshooting protocol

When something breaks, escalation order:

### Tier 1 — `recover_from_breakage.md` runbook

Already exists. Covers 6 known failure modes (missing package, template render glitch, corrupt clone, ELPA timeout, adna layer broken, OOM). Most issues resolved here.

### Tier 2 — `skill_self_improve` reads sessions

If a pattern emerges across 2+ sessions (operator hits same issue repeatedly), `skill_self_improve` notices and drafts an ADR. The operator gates; the fix lands.

### Tier 3 — Cross-vault coordination

If the issue affects multiple vaults in the workspace (e.g., a Python-layer regression that hits both Spacemacs and other aDNA projects), file a coord note at `~/lattice/lattice-labs/who/coordination/` (per workspace convention). Sister-vault operators see it.

### Tier 4 — Upstream contribution

If the issue is in upstream Spacemacs/Emacs/a layer's package, `skill_upstream_contribution` (inherited skill) protocol applies. The fix flows out via:

- Issue or PR to `syl20bnr/spacemacs` (or relevant upstream)
- Documented in our ADR with `target: upstream` field
- Local workaround in `what/local/operator.private.el` until upstream merges

## Upgrade protocol

| Change class | Mechanism | Gate |
|--------------|-----------|------|
| `what/standard/` content | ADR (manual or via `skill_self_improve`) | Operator |
| `local/` → `standard/` promotion | `skill_layer_promote` + sanitization scan | Operator |
| Third-party Spacemacs distro absorption | `skill_overlay_consume` per-layer ADR | Operator (per-layer) |
| Spacemacs pin bump | `update_spacemacs.md` runbook | Operator |
| Layer addition | `skill_layer_add` | Operator |
| Fork branding | `LatticeProtocol/spacelattice` PR (post-v1.0) | Maintainer + Operator |
| Vault rename / repositioning | Atomic ADR (precedent: ADR 005) | Operator |

Every change to `what/standard/` is ADR-gated. Every upgrade writes a deploy receipt at `deploy/<hostname>/<utc>.md` (gitignored).

## Integration of findings during operation

Operator finds friction in routine work:

```
operator session
  → friction observed
    → option A: filed in how/sessions/active/ (session journal)
    → option B: skill_self_improve reads sessions, drafts ADR
    → option C: operator manually files how/backlog/idea_*.md
    → option D: operator promotes via skill_layer_promote (if local/ change)
```

Operator-friction → vault-improvement → publish (if shared) → peer-operator-benefit.

The **telemetry feedback loop** (`what/standard/telemetry.md`) extends this: operator-friction → telemetry submission (with permission) → upstream maintainer agent aggregates → upstream ADR → upstream publish → peer-operator-benefit. See telemetry doc for details.

## Failure modes for the framework itself

| Failure | Symptom | Mitigation |
|---------|---------|------------|
| Upstream Spacemacs goes dormant | No commits to develop for >3 months | Switch tracking to a maintained fork (e.g., a community mirror); document in successor ADR |
| Critical Spacemacs bug + no upstream fix | Operator can't deploy or use | Patch in our fork's `core/lp-branding.el`-style additive file; track until upstream catches up |
| Layer ecosystem regression | Multiple layers break after upgrade | Pin via `dotspacemacs-frozen-packages`; rollback via `~/.emacs.d/.cache/.rollback/` |
| Telemetry submission fails | No telemetry coming back | Reverts to "manual feedback only"; operator escalates via GitHub Issue without telemetry mechanism |

## Implementation deferred

This document is the framework outline. The following are designed by M-Planning-01 (v1.0 campaign Phase 0) and implemented in Phase 2:

1. **Concrete schedules** — cron entries / launchd plists / manual cadence for each cadence above
2. **`update_spacemacs.md` runbook teeth** — actual sed patterns, conflict-resolution heuristics, CI integration
3. **`skill_self_improve` schedule** — daily/weekly/on-trigger; how it integrates with running emacs sessions
4. **Cross-vault coordination skill** — automate the Tier-3 escalation
5. **Native-compilation policy** — when to byte-compile vs native-compile, performance trade-offs

## References

- Pins: `what/standard/pins.md`
- LP fork playbook: `what/context/spacemacs/spacemacs_customization_reference.md` §4
- Layer contract: `what/standard/LAYER_CONTRACT.md`
- Telemetry: `what/standard/telemetry.md`
- Runbooks: `how/standard/runbooks/{fresh_machine,update_spacemacs,recover_from_breakage}.md`
- Self-improvement: `how/standard/skills/skill_self_improve.md`
