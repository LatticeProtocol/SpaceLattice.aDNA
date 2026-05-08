---
type: adr
adr_id: "020"
adr_kind: standard_config
title: "dotspacemacs-background-transparency: set to 100 (opaque background)"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, appearance, transparency, dotfile, p3, p3_02]
---

# ADR-020: Background Transparency — Opaque (100)

## Status

Accepted

## Context

P3-02 §1.3.9 (frame appearance) walk revealed that `dotspacemacs-background-transparency` was
absent from `dotfile.spacemacs.tmpl`. The variable controls background-layer transparency
independently of the frame-level active/inactive transparency (both already set to 90 in the
template).

The three transparency variables are independent:
- `dotspacemacs-active-transparency 90` — frame alpha when active (already in template)
- `dotspacemacs-inactive-transparency 90` — frame alpha when inactive (already in template)
- `dotspacemacs-background-transparency` — background-only layer; text/foreground stays opaque

The upstream default of 90 (10% background bleed-through) can introduce visual noise in
code-heavy workflows — terminal content or desktop bleed behind editor text degrades
readability. macOS compositor support for background-only transparency is also inconsistent
across Emacs builds.

## Decision

Add `dotspacemacs-background-transparency 100` to the `dotspacemacs/init` `setq-default`
block in `what/standard/dotfile.spacemacs.tmpl`, immediately after
`dotspacemacs-inactive-transparency`:

```elisp
dotspacemacs-background-transparency 100
```

100 = fully opaque background. Frame-level active/inactive transparency (90) is preserved —
this variable only affects the background compositing layer.

## Consequences

**Positive:**
- No compositor bleed-through behind code text — fully solid background
- Explicit value documents intent; invisible background transparency effects are common
  sources of confusion in compositor-heavy setups
- Frame-level transparency (active 90 / inactive 90) unchanged; operators who want
  a translucent frame retain that

**Negative / Trade-offs:**
- Cosmetic only; operators preferring a translucent background can override in
  `what/local/operator.private.el` with `dotspacemacs-background-transparency 90`

**Scope:**
- Modified: `what/standard/dotfile.spacemacs.tmpl` (1 line added after
  `dotspacemacs-inactive-transparency`)

## Dry-run result

Template edit applied. Valid elisp integer literal (100). No external dependencies.
`skill_health_check` (`emacs --batch` layer-load) is the gate on next `skill_deploy`.

## Operator approval

Accepted at P3-02 §1.3.9 session (2026-05-08). Operator selected 100 (opaque background).
