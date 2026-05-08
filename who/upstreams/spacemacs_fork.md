---
type: upstream
name: "LatticeProtocol/spacelattice (sibling fork of syl20bnr/spacemacs)"
role: spacemacs_fork
status: opened
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
upstream_url: https://github.com/syl20bnr/spacemacs
fork_url: https://github.com/LatticeProtocol/spacelattice
fork_default_branch: develop
fork_pinned_sha: e57594e7aa1d459d3428b9b116bb84b344aa6084
fork_local_clone: deferred (planned at M-Planning-01 first execution)
license: GPL-3.0
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
tags: [upstream, spacemacs, fork, latticeprotocol, spacelattice, gpl_3]
---

# LatticeProtocol/spacelattice — sibling Spacemacs fork

## Role

The LatticeProtocol-owned fork of [`syl20bnr/spacemacs`](https://github.com/syl20bnr/spacemacs). Opened on GitHub at fork-time SHA `e57594e7aa1d459d3428b9b116bb84b344aa6084` (matches `what/standard/pins.md` ADR-002 pin).

This is the **runtime** target the Spacemacs.aDNA vault governs. The vault is the governance layer (skills, ADRs, layered architecture, knowledge); the fork is the executable Spacemacs distribution that operators clone into `~/.emacs.d/` (or ride via `~/.emacs.d/.private/...` when Spacemacs is fully integrated as a distribution).

## Current state (this turn)

- ✅ Fork exists on GitHub: `https://github.com/LatticeProtocol/spacelattice`
- ✅ Parent relationship recorded: upstream `syl20bnr/spacemacs`
- ✅ Default branch: `develop` (matches our pin policy)
- ⏸ Local clone deferred to M-Planning-01 first execution (~600 MB git history; no value clone-now-without-customizations)
- ⏸ LP-specific branding (banner, distribution layer, theme, version constants) deferred to v1.0 campaign Phase 4

## Engagement model

- **Track upstream `develop`** as canonical source (rebase strategy from LP fork playbook §4.5)
- **Pin-and-track** policy unchanged (`what/standard/pins.md`); pin updates ADR-gated
- **Branding work** lives in: `core/`, `core/banners/`, `core/templates/dotspacemacs-template.el`, `core/core-spacemacs-buffer.el`, `core/core-versions.el`, `core/core-spacemacs.el`, `layers/+distributions/spacemacs-latticeprotocol/` (new), `layers/+themes/latticeprotocol-theme/` (new). Concrete file diffs in customization reference §4B.3.

## Branding strategy (preview — full execution in v1.0 campaign Phase 4)

Per LP fork playbook §4A (touchpoint map) + §4B (concrete fork playbook), we'll touch:

1. **Distribution layer**: new `layers/+distributions/spacemacs-latticeprotocol/` with `(configuration-layer/declare-layer-dependencies '(spacemacs))` + selective overrides
2. **Banner**: replace `core/banners/img/spacemacs.png` + `000-banner.txt` with Spacemacs/LP visuals; update `spacemacs-buffer-logo-title`
3. **Theme**: ship `latticeprotocol-theme` package as `:location local` under `layers/+themes/`
4. **Version constants**: new `latticeprotocol-version` defconst alongside `spacemacs-version`
5. **News mechanism**: `core/news/news-X.Y.Z.org` for LP releases
6. **Dotfile template**: `core/templates/dotspacemacs-template.el` defaults updated for LP distribution
7. **Frame title**: `dotspacemacs-frame-title-format "%I@%S [LP]"` default

The LP fork playbook also covers rebase strategy (rebase weekly against `upstream/develop`, conflict-prone files, namespace hygiene `lp/`/`latticeprotocol-`/`lp|`).

## License

GPL-3.0 (matches Spacemacs upstream). All code in the fork follows GPL-3.0. The Spacemacs logo (Nasser Alshammari, CC BY-SA 4.0) is replaced by Spacemacs branding in the v1.0 campaign — until then, attribution preserved.

## Engagement protocol

When `skill_self_improve` proposes a change that should land in the fork itself (not just the vault's standard layer), the resulting ADR includes `target: fork` and the diff is filed as a PR to `LatticeProtocol/spacelattice`. The vault's standard layer carries the upstream-facing change spec; the fork carries the elisp/asset.

## Reference

- Customization reference: `what/context/spacemacs/spacemacs_customization_reference.md` (operator-supplied, persisted 2026-05-05)
- Renaming + positioning ADR: `what/decisions/adr/adr_005_rename_to_spacelattice.md`
- LP fork playbook (§4 of the customization reference)
- Upstream maintainer: `who/upstreams/syl20bnr.md`
