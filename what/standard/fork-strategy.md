---
type: strategy
status: outline
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
implementation_phase: v1_0_campaign_p4
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
tags: [strategy, fork, spacemacs, latticeprotocol, branding]
---

# Fork Strategy — `LatticeProtocol/spacelattice`

## Purpose

The fork is the **runtime target** that operators ride. The vault governs; the fork executes. This document is the high-level plan for what we put into the fork, when, and how it relates to the vault's standard layer.

## Two-repo split

| Repo | Role | What lives here |
|------|------|------------------|
| `LatticeProtocol/Spacemacs.aDNA` (this vault) | Governance | ADRs, skills, runbooks, the `adna` Spacemacs layer, `pins.md`, layer contracts, knowledge / context library |
| `LatticeProtocol/spacelattice` (sibling fork) | Runtime | The actual Spacemacs codebase — forked from `syl20bnr/spacemacs` at pinned SHA — with LP-specific branding / distribution layer / theme / version constants overlaid |

## Stages

### Stage 0 — fork opened (this turn, 2026-05-05)

- GitHub fork exists at `https://github.com/LatticeProtocol/spacelattice`
- No local clone yet
- No LP-specific changes yet (mirrors upstream)

### Stage 1 — local clone + scaffolding (M-Planning-01 first execution; v1.0 campaign Phase 4 missions)

- `git clone --depth 50 -b develop https://github.com/LatticeProtocol/spacelattice.git ~/lattice/spacelattice`
- Add `upstream` remote pointing at `syl20bnr/spacemacs`
- Create LP distribution layer scaffold: `layers/+distributions/spacemacs-latticeprotocol/{layers,packages,config,keybindings}.el` + `README.org`
- Create LP theme scaffold: `layers/+themes/latticeprotocol-theme/{packages.el,local/latticeprotocol-theme/...}`
- Document everything in vault's `what/standard/`

### Stage 2 — branding overlay (v1.0 campaign Phase 4 missions)

Per LP fork playbook (`what/context/spacemacs/spacemacs_customization_reference.md` §4):

| Surface | Action |
|---------|--------|
| Banner image | Replace `core/banners/img/spacemacs.png` with Spacemacs asset |
| Banner text | Replace `core/banners/000-banner.txt` with Spacemacs ASCII art |
| Logo title | Patch `spacemacs-buffer-logo-title` → `"[L A T T I C E   P R O T O C O L]"` (or similar) |
| Buffer name | Patch `spacemacs-buffer-name` → `"*spacelattice*"` |
| Distribution name | New `dotspacemacs-distribution 'spacemacs-latticeprotocol` default in template |
| Theme | Ship `latticeprotocol-dark` + `latticeprotocol-light` themes |
| Version | New `latticeprotocol-version` defconst + version-line render |
| Frame title | Default `"%I@%S [LP]"` |
| News mechanism | `core/news/news-1.0.0.org` for LP-1.0 release |
| License | GPL-3.0 preserved (matches upstream); LP-specific assets may relicense |

### Stage 3 — runtime activation (post-v1.0)

Once branding is shipped:
- `skill_install` updated to clone `LatticeProtocol/spacelattice` instead of `syl20bnr/spacemacs`
- `pins.md` tracks the fork's `develop` (we still consume upstream via fork rebase)
- Operators get the Spacemacs distribution at install time

### Stage 4 — peer adoption + telemetry feedback

When peer operators adopt Spacemacs, the telemetry feedback loop (`what/standard/telemetry.md`) drives evolution. Friction signals across the fleet inform fork-side ADRs.

## Rebase cadence

Per LP fork playbook §4B.5:

- **Weekly** rebase of fork's `develop` against `upstream/develop`
- **Conflict-prone files**: `core/templates/dotspacemacs-template.el`, `core/core-spacemacs-buffer.el`, `core/core-spacemacs.el`, `core/core-versions.el`, `layers/+distributions/spacemacs/packages.el`
- **Mitigation**: keep LP overrides additive in separate files where possible (e.g., `core/lp-branding.el` loaded with one-line patch upstream); never duplicate full files
- **Tracking**: maintain `UPSTREAM_REV` file in fork; bump only after CI passes

## Namespace hygiene

| Convention | Use |
|-----------|-----|
| `lp/` | Public LP commands |
| `lp//` | Private LP helpers |
| `latticeprotocol-` | LP variables |
| `lp\|` | LP macros (mirroring `spacemacs\|`) |
| `dotspacemacs-lp-` | LP-specific dotfile variables (do **not** introduce `dotspacemacs-` symbols — they have privileged scan in `dotspacemacs/init`) |

Never collide with `spacemacs/`, `spacemacs|`, `spacemacs-` upstream symbols.

## Reserved leader keys

Per LP fork playbook §4B.5: Spacemacs owns `SPC o l` (under the `SPC o` user-reserved prefix). Never bind under `SPC h`, `SPC f`, `SPC b`, `SPC p`, `SPC m`, `SPC w`, `SPC SPC`, `SPC :`, or root SPC keys (Spacemacs reserves these).

## Relationship to vault's standard layer

The vault's `what/standard/layers/adna/` is the **`adna` Spacemacs layer** — the editor-side bridge to aDNA vaults. It lives in the vault (governance) and is symlinked into `~/.emacs.d/private/layers/adna/` at deploy time.

The fork's `layers/+distributions/spacemacs-latticeprotocol/` is the **LP distribution** — the Spacemacs flavor of Spacemacs. It lives in the fork (runtime) and is selected via `dotspacemacs-distribution 'spacemacs-latticeprotocol`.

Both work together: the operator's `~/.spacemacs` declares the LP distribution AND the `adna` layer. The first gives them Spacemacs branding + curated layer set; the second gives them aDNA-vault awareness inside Emacs.

## Implementation deferred

This document is the strategy. The execution plan — which mission does which stage — is M-Planning-01's job to design.
