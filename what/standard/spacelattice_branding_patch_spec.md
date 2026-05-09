---
type: spec
title: SpaceLattice Branding Patch Specification
spec_id: spacelattice_branding_patch_spec
version: 1.0.0
created: 2026-05-09
updated: 2026-05-09
last_edited_by: agent_stanley
status: active
tags: [spec, branding, strings, logo, buffer-name, version, p4_04]
adr: adr_027_lp_branding_strings
---

# SpaceLattice Branding Patch Specification

Catalogue of all Spacemacs core string constants overridden by the LP distribution, the upstream source file where each is defined, and the vault-layer mechanism used to apply the override.

## Implementation Approach

Per ADR-024 (vault-only layer model), no Spacemacs core files are patched. All overrides are applied via `setq` in `what/standard/layers/spacemacs-latticeprotocol/config.el`, which loads after Spacemacs core. The overrides take effect on each Spacemacs startup.

## Override Catalogue

| # | Variable | Upstream Source File | Upstream Value | LP Value | Status |
|---|----------|---------------------|----------------|----------|--------|
| 1 | `spacemacs-buffer-logo-title` | `core/core-spacemacs-buffer.el` | `"[S P A C E M A C S]"` | `"[L A T T I C E   P R O T O C O L]"` | ✅ Live |
| 2 | `spacemacs-buffer-name` | `core/core-spacemacs-buffer.el` | `"*spacemacs*"` | `"*spacelattice*"` | ✅ Live |
| 3 | `latticeprotocol-version` | _(new defconst — no upstream)_ | _(n/a)_ | `"0.1.0"` | ✅ Live |
| 4 | `spacemacs-repository` | `core/core-spacemacs.el` | `"spacemacs"` | `"spacelattice"` | ✅ Live |
| 5 | `spacemacs-repository-owner` | `core/core-spacemacs.el` | `"syl20bnr"` | `"LatticeProtocol"` | ✅ Live |
| 6 | `spacemacs-checkversion-branch` | `core/core-spacemacs.el` | `"master"` | `"lp-stable"` | ✅ Live |
| 7 | Banner image path | `core/core-spacemacs-buffer.el` (`spacemacs-buffer//choose-banner`) | `"img/spacemacs.png"` | `"img/latticeprotocol.png"` | ⏳ Deferred to P4-05 (banner assets) |

## Notes

**Item 3 (`latticeprotocol-version`)**: Added as a new `defconst` in `config.el`, not a `setq` override of an existing symbol. Upstream `spacemacs-version` is preserved untouched — both coexist.

**Item 7 (banner image)**: The `spacemacs-buffer//choose-banner` function looks up the image by path. The LP-branded banner asset does not yet exist; override will be wired in P4-05 once the image file is produced.

**Rebase safety**: Items 1–6 are pure `setq`/`defconst` applied post-load. No upstream function or file is modified, so upstream rebases cannot produce conflicts in this layer.

## Implementation Location

```
what/standard/layers/spacemacs-latticeprotocol/config.el
  └── ;;; LP Version (P4-04)        — defconst latticeprotocol-version
  └── ;;; LP Branding Strings       — setq spacemacs-buffer-logo-title + spacemacs-buffer-name
  └── ;;; LP Repository Constants   — setq spacemacs-repository + owner + branch
```
