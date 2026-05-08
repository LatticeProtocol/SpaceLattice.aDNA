---
type: adr
adr_number: 023
title: "P3-06: Font → SpaceMono Nerd Font; icons font → nerd-icons"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, p3, font, nerd-icons, customization]
---

# ADR-023: P3-06 Font and Icons Font

## Status

Accepted — applied to `what/standard/dotfile.spacemacs.tmpl` 2026-05-08.

## Context

P3-06 customization walk (§2.7 font + icon). The template shipped with Source Code Pro 15.0 as the default font and no explicit `dotspacemacs-default-icons-font` setting. The operator workload is ML ops / agentic SE across multiple aDNA vaults. Two decisions emerged from the operator Q&A:

1. **Font**: Operator prefers Space Mono for code editing. Space Mono Nerd Font is the Nerd Fonts distribution of Space Mono — it includes all Nerd Fonts glyph extensions and works natively with nerd-icons. The Nerd Fonts variant is chosen over the standard Google Fonts release to ensure icon glyphs render correctly.

2. **Icons font**: `nerd-icons` is the more actively maintained icon library (vs `all-the-icons`), covers a wider glyph set, and is required by some newer layers. Consistent choice with the font selection above.

**Pre-requisites** (must run before deploying this template):
```
brew install --cask font-space-mono-nerd-font
```
Verify family name: `fc-list | grep -i "space mono"` → should show `SpaceMono Nerd Font`.
After first Spacemacs boot with this template: `M-x nerd-icons-install-fonts`.

## Decision

1. Change `dotspacemacs-default-font` from `'("Source Code Pro" :size 15.0 …)` to `'("SpaceMono Nerd Font" :size 13.0 :weight normal :width normal)`.
2. Add `dotspacemacs-default-icons-font 'nerd-icons` (was unset; Spacemacs default falls back to `all-the-icons`).

Size reduced from 15.0 to 13.0: Space Mono renders visually larger than Source Code Pro at the same point size; 13.0 produces comparable line density.

## Consequences

### Positive
- Unified Nerd Fonts stack: font and icons use the same glyph set — no missing icons
- Space Mono is optimized for code readability; better at distinguishing `0/O`, `1/l/I`
- `nerd-icons` is better supported by newer Spacemacs layers (doom-modeline already active)

### Negative
- Requires manual font install (`brew install --cask font-space-mono-nerd-font`) before deploying; Spacemacs falls back gracefully if the font is missing but icons won't render
- `M-x nerd-icons-install-fonts` required once after first boot

### Neutral
- Font size change (15.0 → 13.0) is subjective; operator can override in `what/local/operator.private.el` without touching standard
