---
type: adr
adr_number: 029
title: "Banner reverted to official — LP assets held in reserve"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes: adr_028_lp_banner_assets
superseded_by:
tags: [adr, decision, banner, branding, p4]
---

# ADR-029: Banner Reverted to Official — LP Assets Held in Reserve

## Status

Accepted

## Context

P4-05 (ADR-028) wired `lp-banner-1.txt` as the distribution default via a `setq` in `config.el`. However, the operator's stated preference from the P3-04 walk-through was that `'official` (the Spacemacs rocket/cat logo) is the **permanent** startup banner default. ADR-028 overrode this prematurely.

The LP ASCII banner assets (`lp-banner-{1..4}.txt`, `latticeprotocol.svg`) remain valuable vault assets — they are **not removed**. They remain in `what/standard/layers/spacemacs-latticeprotocol/banners/` for future operator use.

## Decision

Revert `dotspacemacs-startup-banner` in `config.el` to `'official`.

The LP banner assets are held in reserve. Operators who prefer a custom LP banner can override in `what/local/operator.private.el`:
```elisp
(setq dotspacemacs-startup-banner
      (expand-file-name
       "private/layers/spacemacs-latticeprotocol/banners/lp-banner-1.txt"
       spacemacs-start-directory))
```

This change supersedes the banner `setq` introduced by ADR-028 while leaving all asset files intact.

## Consequences

### Positive
- Aligns with operator-confirmed preference from P3-04 session
- Spacemacs rocket/cat banner is visually polished and familiar; better first impression
- LP assets remain available for future use without extra work

### Negative
- LP distribution does not visually differentiate on startup banner; relies on branding strings (`[L A T T I C E   P R O T O C O L]`) and themes for identity

### Neutral
- `config.el` lines 27-35 simplified; no `expand-file-name` call required
- ADR-028 assets spec (`spacelattice_assets.md`) still valid — banner files documented and deployed
