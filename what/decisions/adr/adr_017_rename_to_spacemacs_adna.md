---
type: adr
adr_id: adr_017
adr_kind: identity
status: accepted
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
title: "Rename vault and GitHub repo: SpaceLattice.aDNA → Spacemacs.aDNA"
supersedes: adr_005_rename_to_spacelattice
tags: [adr, accepted, identity, rename, spacemacs, vault, github]
---

# ADR-017 — Rename to Spacemacs.aDNA

**Supersedes**: ADR-005 (rename to SpaceLattice.aDNA, 2026-05-05)

## Context

ADR-005 renamed the vault from `spacemacs.aDNA` to `SpaceLattice.aDNA` to signal LP-brand alignment and the project's position within the Lattice Protocol ecosystem. After working inside the vault through Phase 2 and into Phase 3, operator review concluded that the `SpaceLattice` name implies a distribution project — a fork of Spacemacs being developed and published as a distinct product.

That is not what this vault is. The vault is:

- A **governance vault** that operationalizes Spacemacs as an agentic IDE using the aDNA standard
- An **integrated context vault** — context graphs, ADRs, skills, and session history that make Spacemacs agent-navigable
- A **self-improving system** — the friction loop produces ADRs that improve the shared template, not a competing Spacemacs distribution

The name `Spacemacs.aDNA` accurately captures this: it is Spacemacs, governed by aDNA. The `.aDNA` suffix is the semantic signal that this is a governance vault, not a code project.

## Decision

- **Vault directory**: `SpaceLattice.aDNA/` → `Spacemacs.aDNA/`
- **GitHub repo**: `LatticeProtocol/SpaceLattice.aDNA` → `LatticeProtocol/Spacemacs.aDNA`
- **Display name** throughout: `SpaceLattice` → `Spacemacs`
- **Modeline format symbol**: `spacelattice-main` → `adna-main` (cleaner, no Spacemacs-namespace collision risk)
- **Upstream file**: `who/upstreams/spacelattice_fork.md` → `who/upstreams/spacemacs_fork.md`

## What does NOT change

- The sibling fork `LatticeProtocol/spacelattice` — independent GitHub repo; rename is a separate decision
- Internal campaign ID `campaign_spacelattice_v1_0` — historical document, not a display name
- Mission file prefixes `mission_sl_` — historical IDs preserved
- Persona: Daedalus — still accurate (labyrinth = context graph, wings = the adna layer)

## Rationale

The `.aDNA` suffix convention is semantic: it marks a governance vault following the aDNA standard. Applying `SpaceLattice` as the prefix created ambiguity — it could mean "a Lattice Protocol product called SpaceLattice" rather than "Spacemacs governed by aDNA." 

`Spacemacs.aDNA` removes the ambiguity. The name is self-documenting:
- New operators understand immediately what is governed
- The fork (`LatticeProtocol/spacelattice`) remains distinct by naming convention
- The vault's purpose as context-native IDE operationalization is clear

## Implementation

Applied 2026-05-07 via comprehensive sed replacement across all vault files (excluding `.publish-clone/`, which will be eliminated by the aDNA v2 infrastructure campaign M05). Workspace `~/lattice/CLAUDE.md` updated. GitHub repo renamed via `gh repo rename`.

## Workspace impact

One entry in `~/lattice/CLAUDE.md` updated: directory and repo reference changed to `Spacemacs.aDNA`. No other workspace vaults are affected.
