---
type: decision
adr_id: adr_027
title: LP Branding Strings — setq overrides in distribution layer config.el
status: accepted
created: 2026-05-09
updated: 2026-05-09
last_edited_by: agent_stanley
tags: [adr, accepted, branding, strings, distribution, p4_04]
supersedes: ~
superseded_by: ~
---

# ADR-027 — LP Branding Strings: setq overrides in distribution layer config.el

## Context

P4-04 requires LP branding strings to appear in the Spacemacs startup buffer (logo title, buffer name), the Spacemacs version display (`latticeprotocol-version`), and the update-check repository constants (`spacemacs-repository`, `spacemacs-repository-owner`, `spacemacs-checkversion-branch`).

The original mission spec (authored before ADR-024) proposed patching Spacemacs core files or adding a `core/lp-branding.el` module loaded upstream of core. ADR-024 (vault-only layer model, 2026-05-08) superseded that approach: all LP-specific code lives in vault `what/standard/layers/`, not in a forked copy of Spacemacs core.

## Decision

**Apply all branding string overrides via `setq`/`defconst` in `what/standard/layers/spacemacs-latticeprotocol/config.el`.** No Spacemacs core files are patched.

Overrides applied (full catalogue in `what/standard/spacelattice_branding_patch_spec.md`):

```elisp
(defconst latticeprotocol-version "0.1.0")
(setq spacemacs-buffer-logo-title "[L A T T I C E   P R O T O C O L]")
(setq spacemacs-buffer-name "*spacelattice*")
(setq spacemacs-repository "spacelattice"
      spacemacs-repository-owner "LatticeProtocol"
      spacemacs-checkversion-branch "lp-stable")
```

Banner image override (`spacemacs-buffer//choose-banner` path) is deferred to P4-05 (banner assets mission), as the LP image asset does not yet exist.

## Rationale

| Factor | Assessment |
|--------|------------|
| ADR-024 compliance | Vault-only: no core patches, no fork maintenance burden |
| Load-order safety | `config.el` executes after Spacemacs core loads; `setq` reliably overwrites the defconst values |
| Rebase safety | No upstream file touched → zero merge conflicts on upstream pin updates |
| Reversibility | Remove or comment out the `setq` block to revert to upstream branding |

## Alternatives Considered

| Option | Why Not Chosen |
|--------|----------------|
| Patch `core/core-spacemacs-buffer.el` directly | Violates ADR-024; creates rebase conflict surface on every upstream update |
| Add `core/lp-branding.el` loaded before core | Requires a fork repo and `require` patch in `core/core-spacemacs.el` — also violates ADR-024 |
| Defer all branding to post-v1.0 | P4 is the branding phase; deferral would leave LP distribution indistinguishable from upstream Spacemacs |

## Operator Approval

Approved in session `session_sl_p4_04_2026_05_09T120000Z`.
