---
type: decision
adr_id: adr_000
adr_number: 0
title: "Vault identity, persona, layered architecture, and publish target"
status: accepted
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
ratifies:
  - subject: spacemacs
  - persona: daedalus
  - pattern: project
  - layered_architecture: [standard, local, overlay]
  - publish_target: github.com/LatticeProtocol/spacemacs.aDNA
supersedes:
superseded_by:
tags: [decision, adr, identity, governance, daedalus, layered_config, self_improving, genesis]
---

# ADR 000 — Vault identity, persona, layered architecture, and publish target

## Status

**Accepted** at genesis (2026-05-03). Foundational decision for the vault.

## Context

`spacemacs.aDNA` is a new aDNA project vault whose subject is a Spacemacs-based IDE used as the canonical battle station for ML ops, agentic coding, and aDNA context-graph navigation. This ADR captures the four decisions made before any code or content was written, in the planning phase under `~/.claude/plans/please-read-the-claude-md-splendid-boole.md`.

The decisions were taken collectively because each one constrains the others:

- **Pattern** (project vs new pattern category) constrains how the workspace catalogues this vault.
- **Persona** (Daedalus vs alternatives) shapes the agent's voice and operating frame.
- **Layered architecture** (standard/local/overlay) is the structural innovation that all subsequent skills depend on.
- **Publish target** decides whether the standard layer is private, personal, or commons.

## Decisions

### 1. Pattern: project (informal)

This vault is tracked as a standard project in `~/lattice/CLAUDE.md`'s project table. It is **not** formalized as a new aDNA pattern category (e.g., `BattleStation.aDNA`) at genesis.

**Reasoning.** The workspace pattern catalogue (`Forge.aDNA`, `Platform.aDNA`, `Org-Vault.aDNA`) only formalizes a category once a second instance emerges — see the Platform.aDNA canonical-spec note: *"promotes to workspace-canonical once a second platform emerges."* `spacemacs.aDNA` is N=1; promotion to a formal `BattleStation.aDNA` pattern is deferred until a second tooling vault appears.

**Reversibility.** If a second IDE-governance vault is forked, this ADR will be superseded by an ADR that formalizes `BattleStation.aDNA`, adds a workspace ecosystem section, and migrates `spacemacs.aDNA`'s pattern field accordingly.

### 2. Persona: Daedalus

The vault's agentic governance persona is **Daedalus** — master craftsman of the Labyrinth, maker of adaptive wings.

**Reasoning.** Three of Daedalus's mythic affordances map directly to this vault's purpose:

- **The Labyrinth** corresponds to the aDNA context graph the vault helps the operator navigate (wikilinks, ADR supersessions, mission references, frontmatter relations).
- **The wings** correspond to the IDE-as-uplift — the `adna` layer, the install/deploy/self-improve skills, the layered architecture. Tools that lift the operator above the maze rather than just through it.
- **The toolsmith** archetype matches the vault's primary work product — forging tools (skills, runbooks, layers, ADRs).

Available alternatives considered: Hephaestus (smith god — strong but already taken by ComicForge before its supersession), Prometheus (fire-bringer / democratization), Athena (strategic wisdom + weaving). Daedalus was selected on labyrinth-correspondence and absence of prior workspace use.

**Reversibility.** Persona is updateable via a successor ADR. Edit `## Identity & Personality` in `CLAUDE.md` and update `persona:` in MANIFEST.md, STATE.md, and CLAUDE.md frontmatter.

### 3. Layered architecture: standard / local / overlay

The vault enforces three filesystem-level configuration layers with strict precedence at deploy time:

```
overlay/  (third-party Spacemacs distros — proposes via ADR; never silently overwrites)
   ↓
standard/ (shared, deterministic, reproducible — the published commons)
   ↓
local/    (per-operator, gitignored — never published unless explicitly promoted)
```

`skill_deploy` renders in this order: `standard/` first, then accepted `overlay/` choices, then `local/` last. Final artifacts go to `~/.spacemacs` and `$SPACEMACSDIR/private/`.

**Reasoning.** No existing aDNA vault carries a layered separation. Inventing it here is necessary because:

- The standard layer must build on a fresh machine with no `local/` present (so peers can adopt the commons).
- The local layer must accept secrets, hostnames, and personal preferences that should never be published.
- The overlay layer must accept third-party Spacemacs distributions without silently overwriting the commons.

The contract is formalized in `what/standard/LAYER_CONTRACT.md`.

**Promotion ritual.** `skill_layer_promote` is the only path from `local/` → `standard/`. It requires a successor ADR, a sanitization scan (no hostnames, no secrets, no operator-specific paths), and operator approval.

**Reversibility.** Layers can be merged or split via successor ADRs. The contract change requires updating `LAYER_CONTRACT.md`, the `.gitignore`, and the deploy order in `skill_deploy.md`.

### 4. Publish target: `github.com/LatticeProtocol/spacemacs.aDNA`

The `standard/` layer (when `skill_publish_lattice` runs in Phase 7) mirrors to `github.com/LatticeProtocol/spacemacs.aDNA`. Same pattern as `SiteForge.aDNA`'s mirror at `github.com/LatticeProtocol/SiteForge.aDNA`.

**Reasoning.** The standard layer is a commons. Operators clone the repo, run `skill_install`, and arrive at the same battle station. The LatticeProtocol GitHub org houses the lattice-public commons; placing this vault there matches existing precedent.

**Reversibility.** A successor ADR can change publish target (operator-personal GitHub, alternative org, or no public mirror). Update `skill_publish_lattice.md`'s remote and re-publish.

## Consequences

- The vault's `standard/` layer is treated as commons from genesis, so contributions there require ADRs.
- The `local/` layer is private by contract — `.gitignore` enforces it; `skill_layer_promote` is the only escape hatch.
- Naming and identity language across the vault uses the labyrinth + wings metaphors (Daedalus).
- Phase 7 publish creates a public repo; the standard layer must remain sanitization-scan clean from Phase 2 onward.

## References

- Plan: `/Users/stanley/.claude/plans/please-read-the-claude-md-splendid-boole.md`
- Template ADR: `~/lattice/.adna/how/templates/template_adr.md`
- Workspace project catalogue: `~/lattice/CLAUDE.md`
- Pattern precedent: `RareHarness.aDNA/what/decisions/adr_000_project_identity.md` (Platform.aDNA precedent)
