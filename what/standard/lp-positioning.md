---
type: positioning
status: active
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
tags: [positioning, lattice_protocol, adna, spacelattice, daedalus]
---

# LatticeProtocol Stack — Where SpaceLattice.aDNA Sits

## The stack

```
┌────────────────────────────────────────────────────────────────┐
│                    LatticeProtocol Stack                        │
│                                                                  │
│  ┌────────────────────────┐  ┌────────────────────────────────┐│
│  │   Knowledge / Govern   │  │           Runtime              ││
│  │                        │  │                                ││
│  │  Agentic-DNA           │  │  lattice-protocol              ││
│  │  (= adna template)     │  │  (federated AI compute,        ││
│  │  - public template     │  │   Python, L1/L2/L3 tiers,      ││
│  │  - who/what/how triad  │  │   marketplace, ledger, CLI)    ││
│  │  - skills, contexts    │  │                                ││
│  └────────────────────────┘  └────────────────────────────────┘│
│            ↓ forked via skill_project_fork           ↑          │
│  ┌────────────────────────────────────────────────────────────┐│
│  │      SpaceLattice.aDNA  ← this vault                       ││
│  │                                                            ││
│  │  Agentic IDE governance vault                              ││
│  │  - Spacemacs distribution governed by aDNA                 ││
│  │  - Standard / local / overlay layered architecture         ││
│  │  - Self-improving via ADR-gated session-friction loop      ││
│  │  - Sustainability + telemetry frameworks                   ││
│  │                                                            ││
│  │       ↕ sibling-couples to                                  ││
│  │                                                            ││
│  │  LatticeProtocol/spacelattice                              ││
│  │  - Fork of syl20bnr/spacemacs                              ││
│  │  - LP-specific branding + distribution layer + theme       ││
│  │  - The runtime operators install                           ││
│  └────────────────────────────────────────────────────────────┘│
└────────────────────────────────────────────────────────────────┘
```

## The three repos

| Repo | Type | Role | License |
|------|------|------|---------|
| [`LatticeProtocol/lattice-protocol`](https://github.com/LatticeProtocol/lattice-protocol) | Code (Python, **PRIVATE**) | Federated AI computing — protocol layer, federation, marketplace, ledger, CLI. v0.1.0-alpha. The *executable core* that aDNA vaults orchestrate against. | MIT |
| [`LatticeProtocol/Agentic-DNA`](https://github.com/LatticeProtocol/Agentic-DNA) (= alias `LatticeProtocol/adna`) | Template (PUBLIC) | The aDNA standard template — `who/`/`what/`/`how/` triad, skill recipes, context library. Cloned at `~/lattice/adna/`; symlinked at `~/lattice/.adna/`. **Do not modify** — updated via `git pull` upstream. | MIT |
| [`LatticeProtocol/SpaceLattice.aDNA`](https://github.com/LatticeProtocol/SpaceLattice.aDNA) (this vault) | Governance vault (PUBLIC) | The agentic IDE governance layer — Spacemacs distribution + aDNA layered architecture + self-improvement + sustainability + telemetry. **The developer surface for working with the LatticeProtocol stack.** | GPL-3.0 (matches Spacemacs upstream) |
| [`LatticeProtocol/spacelattice`](https://github.com/LatticeProtocol/spacelattice) | Code (sibling fork, PUBLIC) | Fork of `syl20bnr/spacemacs`. The Spacemacs runtime SpaceLattice.aDNA governs. Branding work follows v1.0 campaign Phase 4. | GPL-3.0 |

## How they relate

### `lattice-protocol` ← consumed by → `SpaceLattice.aDNA`

The lattice-protocol library is what operators using SpaceLattice for ML ops actually invoke. Examples (forward-looking):

- An ML researcher in SpaceLattice opens a `.lattice.yaml` definition; SpaceLattice's adna layer parses frontmatter; from there, `M-x lp/run-lattice` (future binding) shells to `latlab lattice run` from the lattice-protocol CLI
- A federated training job submitted from L1 (the SpaceLattice machine) to L2 (Dell HPC); SpaceLattice surfaces job state via `M-x lp/job-status`
- The marketplace registry (`latlab lattice publish`) is invokable from SpaceLattice via leader bindings

The *integration* of lattice-protocol functionality into SpaceLattice is part of the v1.0 campaign (estimated Phase 3 customization-walk-throughs + Phase 4 fork branding).

### `Agentic-DNA` (template) ← forked by → `SpaceLattice.aDNA`

SpaceLattice.aDNA was cut from Agentic-DNA via `skill_project_fork` (genesis 2026-05-03). It inherits:

- The triad (`who/`/`what/`/`how/`)
- Workspace-level skills (`how/skills/skill_*.md`)
- Templates (`how/templates/template_*.md`)
- Context library (`what/context/`)
- aDNA standard spec (`what/docs/adna_standard.md`)

It adds (per ADR 000):

- Three-layer architecture (`standard/local/overlay`)
- Project-specific skills in `how/standard/skills/`
- The adna Spacemacs layer (`what/standard/layers/adna/`)
- Sibling fork repo (`LatticeProtocol/spacelattice`, opened 2026-05-05 per ADR 005)

### `spacelattice` (fork) ← governed by → `SpaceLattice.aDNA` vault

Sibling-coupling pattern matching `RareHarness.aDNA ↔ rareharness/` and `VideoForge.aDNA ↔ lattice-video-forge/`. Vault carries: design, ADRs, skills, runbooks, knowledge. Code repo carries: actual Spacemacs distribution code.

Coordinated PRs / ADRs keep them in sync. Standing rule: every change to `what/standard/` in vault is ADR-gated; every change to `LatticeProtocol/spacelattice` is PR-gated upstream of the rebase cadence.

## Where SpaceLattice fits in the existing workspace ecosystem

In `~/lattice/`:

| Pattern | Examples | SpaceLattice's place |
|---------|----------|------------------------|
| Forge.aDNA | SiteForge, ComfyForge, CanvasForge, VideoForge | Different — SpaceLattice is not an artifact-producing forge |
| Platform.aDNA | RareHarness | Different — SpaceLattice doesn't deploy to partners |
| Org-Vault.aDNA | lattice-labs, wga, context_commons, RareArchive, WilhelmAI | Different — SpaceLattice is not the operational home of an org |
| **Project (informal)** | (was) spacemacs.aDNA | SpaceLattice now sits here. Could promote to formal **Tooling.aDNA** or **AgenticIDE.aDNA** pattern category if/when N=2 tooling vaults emerge |

## Operator audience

Developers doing **agentic software engineering** with the LatticeProtocol stack:

- ML researchers building federated training graphs
- Biomedical pipeline engineers
- aDNA vault operators editing context graphs
- LatticeProtocol contributors hacking the runtime/SDK
- Anyone using Claude Code + Obsidian + Spacemacs in concert

## The Daedalus persona, revisited

ADR 000 picked Daedalus for the labyrinth + adaptive-wings metaphors. Both scale cleanly to the SpaceLattice rename:

- **The Labyrinth** is now the **lattice graph**: aDNA context graphs + lattice-protocol federation graphs + cross-vault wikilink graphs
- **The wings** are now the **agentic IDE uplift**: `SPC a` transient + `SPC c c` Claude Code spawn + `M-x adna-index-project` + Obsidian round-trip + (future) lattice-protocol command bindings
- **The toolsmith** archetype is unchanged — Daedalus forges tools that the operator wields

Persona stays. ADR 005 § Decision 4 ratifies.

## What's *not* in scope for SpaceLattice.aDNA

- Lattice-protocol library development (lives in `lattice-protocol` repo)
- Agentic-DNA template development (lives in `adna` repo)
- Forge artifacts (SiteForge, VideoForge, etc. live in their respective vaults)
- Platform deployment topology (RareHarness handles that pattern)
- Org-Vault organizational governance (lattice-labs, WilhelmAI, etc.)

SpaceLattice does one thing: govern the agentic IDE. The other repos do their things. Coordination is via cross-vault references + workspace CLAUDE.md routing.

## References

- ADR 005 (this rename + repositioning): `what/decisions/adr/adr_005_rename_to_spacelattice.md`
- Fork strategy: `what/standard/fork-strategy.md`
- Customization reference (operator-supplied): `what/context/spacemacs/spacemacs_customization_reference.md`
- Sustainability framework: `what/standard/sustainability.md`
- Telemetry framework: `what/standard/telemetry.md`
- v1.0 campaign master: `how/campaigns/campaign_spacelattice_v1_0/campaign_spacelattice_v1_0.md`
