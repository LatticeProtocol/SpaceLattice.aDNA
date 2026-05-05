---
type: decision
adr_id: adr_005
adr_number: 5
title: "Rename to SpaceLattice.aDNA + open sibling Spacemacs fork + reposition under LatticeProtocol stack"
status: accepted
proposed_by: agent_init
target_layer: standard
target_files:
  - "(rename, all 39 tracked files referencing literal 'spacemacs.aDNA' token)"
  - what/decisions/adr/adr_005_rename_to_spacelattice.md
ratifies:
  - "vault rename: spacemacs.aDNA -> SpaceLattice.aDNA (filesystem + GitHub)"
  - "sibling code repo open: LatticeProtocol/spacelattice (fork of syl20bnr/spacemacs)"
  - "repositioning: SpaceLattice as Lattice-Protocol-aware Spacemacs distribution governed by aDNA"
  - "persona retained: Daedalus"
  - "version bump: v0.1.0 (genesis) -> v0.2.0 (rename + repositioning)"
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
supersedes:
  what/decisions/adr/adr_000_vault_identity.md (clauses on naming + sibling-repo-policy; vault identity otherwise preserved)
superseded_by:
tags: [decision, adr, rename, repositioning, fork, lattice_protocol, daedalus, v0_2_0]
---

# ADR 005 — Rename to SpaceLattice.aDNA + sibling Spacemacs fork + LP repositioning

## Status

**Accepted** at 2026-05-05 by the operator. Atomic decision closing 5 coupled choices that ADR 000 had punted or under-specified.

## Context

Genesis (Plan A) shipped the vault as `spacemacs.aDNA` v0.1.0, governing a Spacemacs-based agentic battle station. The operator's broader intent — formed during genesis but only now articulable — is for this vault to position as a **Lattice-Protocol-aware Spacemacs distribution governed by aDNA**, not just a generic Spacemacs config governance vault. Three inadequacies in ADR 000 surface:

1. **Naming**: `spacemacs.aDNA` connotes "spacemacs governed by aDNA" but obscures the lattice-protocol relationship. The intended audience (developers doing agentic software engineering with aDNA + Lattice Protocol) reads `SpaceLattice.aDNA` as evocative of both Spacemacs and the lattice graph the aDNA architecture is built around.

2. **Sibling code repo policy**: ADR 000 §1 stated "Vault is self-contained. No sibling code repo." This was correct at genesis when no Spacemacs branding work was contemplated. The operator's Spacemacs Customization Architecture reference doc (now persisted at `what/context/spacemacs/spacemacs_customization_reference.md`) lays out concretely how a LatticeProtocol fork of Spacemacs would be branded (banner, distribution layer, theme, version constants, news mechanism, license posture). Executing on that vision requires a forked Spacemacs codebase — necessitating a sibling code repo.

3. **Positioning**: ADR 000 framed the vault as informal pattern (project) "until N=2 tooling vaults emerge." The repositioning here is not a new pattern but a clearer placement of *this* vault within the existing LatticeProtocol stack: alongside `lattice-protocol` (the executable runtime) and `adna` (= `Agentic-DNA`, the public template).

This ADR closes all three at once.

## Decisions

### 1. Vault rename: `spacemacs.aDNA` → `SpaceLattice.aDNA`

**Filesystem**: `mv ~/lattice/spacemacs.aDNA ~/lattice/SpaceLattice.aDNA` (atomic).

**GitHub repo**: `gh repo rename SpaceLattice.aDNA --repo LatticeProtocol/spacemacs.aDNA --yes`. GitHub auto-creates a redirect from the old name; existing operator clones remain functional.

**Internal references**: bulk `sed` replaces the literal token `spacemacs.aDNA` → `SpaceLattice.aDNA` across 39 tracked files (governance, skills, runbooks, ADRs, layer code, templates, who/operators+upstreams+peers, publish receipts). The `.spacemacs` dotfile template's `LOCAL_LAYER_DIR` placeholder is re-rendered against the new path; the `~/.emacs.d/private/layers/adna` symlink is recreated against the new vault root.

**Workspace integration**: `~/lattice/CLAUDE.md` row + tree entry updated to `SpaceLattice.aDNA`.

### 2. Sibling code repo: `LatticeProtocol/spacelattice` (fork of `syl20bnr/spacemacs`)

`gh repo fork syl20bnr/spacemacs --org LatticeProtocol --fork-name spacelattice --clone=false`.

The fork repo on GitHub mirrors upstream `develop` at fork time. **Local clone deferred** to the v1.0 campaign's first execution mission (M-Planning-01). Branding work (per the LP fork playbook in the customization reference) follows in dedicated missions during P4 of the v1.0 campaign.

**Naming choice**: `spacelattice` (lowercase) follows the workspace convention for sibling code repos — precedent: `rareharness` (sibling of `RareHarness.aDNA`), `lattice-video-forge` (sibling of `VideoForge.aDNA`). The vault remains `SpaceLattice.aDNA` (governance, aDNA pattern).

This supersedes ADR 000 §1's "vault is self-contained, no sibling code repo" clause.

### 3. Repositioning under LatticeProtocol stack

`SpaceLattice.aDNA` positions as the **agentic-IDE governance vault** in the LatticeProtocol stack:

| Layer | Repo | Role |
|-------|------|------|
| Runtime | `LatticeProtocol/lattice-protocol` (private) | Federated AI computing — the Python-based executable core (L1/L2/L3 tiers, marketplace, ledger, CLI) |
| Knowledge architecture standard | `LatticeProtocol/Agentic-DNA` (public, alias `LatticeProtocol/adna`) | The aDNA template — `who/`/`what/`/`how/` triad, skills, context library |
| **Agentic IDE** | **`LatticeProtocol/SpaceLattice.aDNA`** (public, this vault) | **Spacemacs distribution governed by aDNA — the developer surface for working with the LatticeProtocol stack** |
| Spacemacs runtime fork | `LatticeProtocol/spacelattice` (public, opened this turn) | A fork of `syl20bnr/spacemacs` that the vault governs; branding + distribution layer + theme follow in v1.0 campaign |

The full LP positioning is documented in `what/standard/lp-positioning.md`.

### 4. Persona retained: Daedalus

The labyrinth metaphor scales: the lattice graph IS a labyrinth; the wings are the developer-uplift the vault provides. No persona change.

### 5. Version bump: v0.2.0

Genesis was tagged `v0.1.0-genesis` (initial publish) and `v0.1.0` (post-AAR / post-ADR-003 fixes). This ADR + accompanying changes are a semver minor bump — no breaking API, but substantive scope expansion (rename, sibling repo, repositioning, campaign foundation, sustainability + telemetry frameworks).

Tag at end of this turn: `v0.2.0` on `LatticeProtocol/SpaceLattice.aDNA`. Legacy tags `v0.1.0-genesis` and `v0.1.0` are preserved.

## Consequences

- All operator-facing strings reflect the SpaceLattice identity.
- The standard layer is now positioned with explicit LP-stack context — peer operators understand they're working with the developer-surface piece of LatticeProtocol.
- Future branding work has a target (the `spacelattice` fork) ready to be cloned and customized per the LP fork playbook.
- The v1.0 campaign (`how/campaigns/campaign_spacelattice_v1_0/`) is scaffolded; M-Planning-01 designs the rest.
- ADR 000 is partially superseded (clauses on naming + sibling-repo-policy); the rest of ADR 000 (layered architecture, persona, license, etc.) remains in force.
- The customization reference doc is now in-vault context at `what/context/spacemacs/`; subsequent missions can cite specific sections.
- Sustainability + telemetry frameworks have outline-level docs at `what/standard/sustainability.md` and `what/standard/telemetry.md`; full implementation is planning-mission scope.

## Alternatives considered

1. **Keep the name `spacemacs.aDNA`**. Rejected: name doesn't telegraph the LP relationship; operator wants reposition.

2. **Rename to `Spacemacs.aDNA` (capital S only)**. Rejected: semantically the same; rename should signal repositioning, not just casing fix.

3. **Rename to `LatticeIDE.aDNA` or `LP-IDE.aDNA`**. Rejected: drops the Spacemacs lineage, which is load-bearing for operator audience comprehension.

4. **Skip the fork repo open in this turn**. Rejected: deferring repo creation makes the v1.0 campaign's downstream missions harder to scope (they'd need to open the fork before they could plan against it). GitHub-side fork is fast (~10 sec); deferring local clone is reasonable.

5. **Use `SpaceLattice.aDNA` as both vault repo and fork repo**. Rejected: collision impossible (same `LatticeProtocol/<repo>` namespace). Workspace convention is lowercase sibling code repo.

6. **Fork target `LatticeProtocol/SpaceLattice` (no `.aDNA` suffix, no lowercase)**. Considered as alternative naming. Rejected for fork: `.aDNA` suffix in workspace convention applies to *governance vaults*, not to code repos. The aDNA pattern is in the vault; the code repo is sibling, lowercase.

## Reversibility

| Aspect | Reversibility |
|--------|---------------|
| Filesystem rename | Trivial (`mv` again); GitHub redirect from old name persists indefinitely |
| Workspace CLAUDE.md row | Trivial edit |
| 39-file content sed | Trivial reverse-sed |
| GitHub vault rename | `gh repo rename spacemacs.aDNA --repo LatticeProtocol/SpaceLattice.aDNA` reverts |
| Sibling fork repo | `gh repo delete LatticeProtocol/spacelattice` (operator-confirmed, public-repo-deletion ritual applies) |
| Persona, version | n/a (no rollback needed; both are forward decisions) |

Successor ADR can amend any decision.

## Verification (post-execution this turn)

- `git ls-files | xargs grep -l 'spacemacs\.aDNA'` returns empty
- `gh repo view LatticeProtocol/SpaceLattice.aDNA` shows new name + PUBLIC visibility
- `gh repo view LatticeProtocol/spacelattice` shows fork relationship to `syl20bnr/spacemacs`
- `~/.spacemacs` `LOCAL_LAYER_DIR` points at `/Users/stanley/lattice/SpaceLattice.aDNA/what/local`
- `~/.emacs.d/private/layers/adna` symlink target is the renamed vault path
- `emacs --batch -l ~/.emacs.d/init.el --eval '(adna/health-check)'` returns OK
- `cd .publish-clone && git remote -v` shows `LatticeProtocol/SpaceLattice.aDNA.git`
- Workspace `~/lattice/CLAUDE.md` row + tree entry updated

## References

- Customization reference (operator-supplied; persisted in this turn): `what/context/spacemacs/spacemacs_customization_reference.md`
- LP positioning: `what/standard/lp-positioning.md`
- Sustainability framework outline: `what/standard/sustainability.md`
- Telemetry framework outline: `what/standard/telemetry.md`
- Campaign master file: `how/campaigns/campaign_spacelattice_v1_0/campaign_spacelattice_v1_0.md`
- Planning mission: `how/campaigns/campaign_spacelattice_v1_0/missions/mission_sl_planning_01.md`
- Plan: `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` (Plan B, 2026-05-05)
- Predecessor naming ADR: `RareHarness.aDNA/what/decisions/adr_000_project_identity.md` (rename precedent)
