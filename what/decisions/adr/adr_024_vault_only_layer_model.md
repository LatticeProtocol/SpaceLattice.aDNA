---
type: adr
adr_id: adr_024
adr_kind: architecture
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
title: "Vault-only layer model: drop separate fork, LP code lives in what/standard/layers/"
supersedes: adr_005_rename_to_spacelattice
tags: [adr, accepted, architecture, fork, layers, vault_only, p4]
---

# ADR-024 — Vault-only layer model

**Supersedes**: ADR-005 (fork `LatticeProtocol/spacelattice` opened, 2026-05-05); `what/standard/fork-strategy.md` two-repo model

## Context

ADR-005 opened `LatticeProtocol/spacelattice` as a sibling fork of `syl20bnr/spacemacs`, intending LP-specific branding (distribution layer, theme, banner, version strings) to live there. The P4 campaign was designed around cloning this fork, setting remotes, rebasing against upstream weekly, and patching core Spacemacs files for branding.

After completing the P3 customization walk, two facts are now clear:

1. **The `adna` and `claude-code-ide` layers already prove the vault-only pattern works.** Both are Spacemacs layers that live entirely in `what/standard/layers/` and are deployed by `skill_install` symlinks to `~/.emacs.d/private/layers/`. No fork required.

2. **All LP-specific Spacemacs behavior can be expressed as Spacemacs private layers.** The LP distribution layer (`spacemacs-latticeprotocol`) and theme (`latticeprotocol-theme`) are private layers that can be declared in `dotspacemacs-configuration-layers` and symlinked at install time. Branding strings (`spacemacs-buffer-logo-title`, `spacemacs-buffer-name`) can be overridden via `setq` in the distribution layer's `config.el` — no core file patching needed. The only genuine fork capability (patching core Spacemacs banner images) was already decided as a stub/skip in P3-04 (official banner stays).

3. **`LatticeProtocol/spacelattice` was opened but never received any LP-specific commits.** Archiving it has zero code loss.

The operator confirmed preference for a single-repo model: `LatticeProtocol/Spacemacs.aDNA` holds everything — governance vault AND LP-specific Spacemacs layers.

## Decision

### What changes

- **All LP-specific Spacemacs code lives in the vault** at `what/standard/layers/`:
  ```
  what/standard/layers/
  ├── adna/                          ← existing
  ├── claude-code-ide/               ← existing
  ├── spacemacs-latticeprotocol/     ← LP distribution layer (P4-01/P4-02)
  └── +themes/
      └── latticeprotocol-theme/     ← LP theme (P4-01/P4-03)
  ```
- **`skill_install` Step 5** is extended to symlink all LP layers (not just `adna`):
  ```bash
  for LAYER in adna claude-code-ide spacemacs-latticeprotocol; do
    ln -s "$VAULT/what/standard/layers/$LAYER" ~/.emacs.d/private/layers/$LAYER
  done
  ln -s "$VAULT/what/standard/layers/+themes/latticeprotocol-theme" \
        ~/.emacs.d/private/layers/latticeprotocol-theme
  ```
- **Branding is done via `setq` overrides** in `spacemacs-latticeprotocol/config.el`. No core Spacemacs file patching.
- **`LatticeProtocol/spacelattice`** is archived on GitHub. No LP commits existed; archive is reversible.
- **`what/standard/fork-strategy.md`** is superseded (banner added; file preserved for audit).
- **P4 missions are re-scoped**: no clone/rebase work; all deliverables are in-vault layer files.
- **P4-08** ("first rebase skill") is renamed to `skill_update_pin` — updates the Spacemacs SHA pin in `what/standard/pins.md` via ADR; replaces rebase cadence with pin-update cadence.

### What does NOT change

- Upstream Spacemacs is still consumed via `skill_install` clone at pinned SHA (`pins.md`)
- SHA pin discipline and `update_spacemacs.md` runbook remain canonical for absorbing upstream changes
- `dotspacemacs-distribution 'spacemacs-latticeprotocol` still applies (private layer, not a fork-side distribution)
- Campaign/mission IDs remain historical (`campaign_spacelattice_v1_0`, `mission_sl_*`) — preserved for audit trail

## Rationale

The vault-only model has three advantages over the fork model:

1. **No rebase overhead.** Weekly rebasing of a fork against upstream Spacemacs is operationally expensive. Pin bumps via ADR are auditable and operator-controlled.
2. **All LP capability fits in private layers.** Spacemacs's `private/layers/` mechanism was designed for exactly this use case — operator-specific extensions that don't belong upstream. Our distribution layer, theme, and branding overrides fit cleanly in this model.
3. **Single repo, single truth.** Governance and code in one place matches the vault's self-describing nature. New operators clone `Spacemacs.aDNA`, run `skill_install`, and have a working battle station — no second repo required.

## Implementation sequence

1. ADR-024 written and accepted (this document) — 2026-05-08
2. `what/standard/fork-strategy.md` superseded (banner added)
3. P4-01 mission rescoped (scaffold layer dirs + extend skill_install)
4. P4-08 mission renamed to `skill_update_pin` scope
5. `LatticeProtocol/spacelattice` archived (operator action via GitHub web UI or `gh repo archive`)
6. `~/lattice/CLAUDE.md` workspace table updated
7. P4 execution: P4-01 scaffold → P4-02 distribution layer → P4-03 theme → P4-04 branding

## Workspace impact

- `~/lattice/CLAUDE.md`: `spacelattice/` sibling code repo entry removed from `Spacemacs.aDNA` description
- `what/standard/fork-strategy.md`: supersession banner added
- No other workspace vaults affected
