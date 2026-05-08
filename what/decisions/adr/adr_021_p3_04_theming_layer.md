---
type: adr
adr_number: 021
title: "Add theming layer to standard configuration"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, p3, theming, layer]
---

# ADR-021: Add theming Layer to Standard Configuration

## Status

Accepted

## Context

P3-04 customization walk surfaced a need for per-theme face overrides. The Spacemacs `theming` layer (from `+themes/theming/`) provides the `theming-modifications` alist — a declarative way to override specific faces per theme via `M-x spacemacs/update-theme`. Without this layer, face overrides must be written as raw `custom-set-faces` calls in `user-config`, which are theme-unaware and harder to maintain.

The operator explicitly requested this layer be added. It is lightweight (no additional ELPA packages; purely infrastructure) and imposes no performance cost if `theming-modifications` is left empty.

## Decision

Add `theming` to `dotspacemacs-configuration-layers` in `what/standard/dotfile.spacemacs.tmpl`, under the `=== OS & fonts ===` section.

`theming-modifications` defaults to nil. Per-theme face overrides can be added in `dotspacemacs/user-config` or in `what/local/operator.private.el`.

## Consequences

### Positive
- Per-theme face overrides are now first-class: `theming-modifications` alist is available in `user-config`
- Overrides survive theme cycling (`SPC T n` / `SPC T s`) — they re-apply via `spacemacs/update-theme`
- Zero overhead if `theming-modifications` is empty

### Negative
- One additional layer in the layers list (cosmetic, no runtime cost)

### Neutral
- Operator can define face overrides in `operator.private.el` without touching the standard template
