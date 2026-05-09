---
type: spec
title: SpaceLattice Theme Specification
spec_id: spacelattice_theme_spec
version: 1.0.0
created: 2026-05-09
updated: 2026-05-09
last_edited_by: agent_stanley
status: active
tags: [spec, theme, latticeprotocol-dark, latticeprotocol-light, p4_03]
adr: adr_026_latticeprotocol_theme
---

# SpaceLattice Theme Specification

Two themes ship with the LP distribution: `latticeprotocol-dark` and `latticeprotocol-light`. Both are direct derivatives of the spacemacs-dark / spacemacs-light palettes with the minimum number of changes needed to give LP a distinct visual identity.

## Design Principle

> Familiar, not foreign. The operator already knows spacemacs-dark. The LP theme is spacemacs-dark with cooler shadows and a sharper accent — recognizable in one glance, distinct on close inspection.

## Dark Theme — `latticeprotocol-dark`

**Upstream**: spacemacs-dark  
**Delta**: 2 tweaks

### Palette

| Token | LP Value | Upstream Value | Role |
|-------|----------|----------------|------|
| `lp-bg` | `#1e2029` | `#292b2e` | Background — cooler, deeper blue-black |
| `lp-bg-alt` | `#1a1b22` | `#212026` | Alternate background (popups, code blocks) |
| `lp-bg-hl` | `#2d2e3a` | `#3e3d31` | Highlight background (hl-line, selection) |
| `lp-fg` | `#b2b2b2` | `#b2b2b2` | Default foreground — unchanged |
| `lp-fg-dark` | `#9a9ab0` | `#5d4d7a` | Dimmed foreground (inactive mode line) |
| `lp-cursor` | `#e3dedd` | `#e3dedd` | Cursor — unchanged |
| `lp-selection` | `#2d3040` | `#444155` | Region / selection — cooler blue-purple |
| `lp-border` | `#3c3c4a` | — | Window borders, mode line box |
| `lp-comment` | `#2aa1ae` | `#2aa1ae` | Comments — unchanged |
| `lp-keyword` | `#5b9bd5` | `#4f97d7` | Keywords, accent **← LP tweak** |
| `lp-type` | `#ce537a` | `#ce537a` | Types — unchanged |
| `lp-const` | `#a45bad` | `#a45bad` | Constants — unchanged |
| `lp-func` | `#bc6ec5` | `#bc6ec5` | Function names — unchanged |
| `lp-string` | `#2d9574` | `#2d9574` | Strings — unchanged |
| `lp-variable` | `#7590db` | `#7590db` | Variables — unchanged |
| `lp-warning` | `#dc752f` | `#dc752f` | Warnings — unchanged |
| `lp-error` | `#e0211d` | `#e0211d` | Errors — unchanged |
| `lp-success` | `#42ae2c` | `#42ae2c` | Success — unchanged |

### Delta Rationale

| Change | Reason |
|--------|--------|
| `bg` `#292b2e` → `#1e2029` | Eliminates the brown-gray warmth of spacemacs-dark; gives LP the cooler "lattice node at rest" tonality without breaking contrast ratios |
| `keyword` `#4f97d7` → `#5b9bd5` | Slightly higher saturation — makes the LP accent color feel crisp and distinguishable without jarring |

## Light Theme — `latticeprotocol-light`

**Upstream**: spacemacs-light  
**Delta**: 1 tweak

### Palette

| Token | LP Value | Upstream Value | Role |
|-------|----------|----------------|------|
| `lp-bg` | `#f2f4f8` | `#fbf8ef` | Background — cooler off-white **← LP tweak** |
| `lp-bg-alt` | `#e8eaf0` | — | Alternate background |
| `lp-bg-hl` | `#dde1ea` | — | Highlight background |
| `lp-fg` | `#655370` | `#655370` | Default foreground — unchanged |
| `lp-fg-dark` | `#44475a` | `#44475a` | Dimmed foreground |
| `lp-cursor` | `#655370` | `#655370` | Cursor — unchanged |
| `lp-selection` | `#d4d8e8` | — | Region selection |
| `lp-border` | `#b8bcc8` | — | Borders |
| `lp-comment` | `#2aa1ae` | `#2aa1ae` | Comments — unchanged |
| `lp-keyword` | `#3a81c3` | `#3a81c3` | Keywords — unchanged |
| `lp-type` | `#b03060` | `#b03060` | Types — unchanged |
| `lp-const` | `#715ab1` | `#715ab1` | Constants — unchanged |
| `lp-func` | `#6c3163` | `#6c3163` | Function names — unchanged |
| `lp-string` | `#2d9574` | `#2d9574` | Strings — unchanged |
| `lp-variable` | `#715ab1` | `#715ab1` | Variables — unchanged |
| `lp-warning` | `#dc752f` | `#dc752f` | Warnings — unchanged |
| `lp-error` | `#e0211d` | `#e0211d` | Errors — unchanged |

### Delta Rationale

| Change | Reason |
|--------|--------|
| `bg` `#fbf8ef` → `#f2f4f8` | Removes the warm cream tint of spacemacs-light; the cooler blue-gray neutral matches the dark theme's tonality for a cohesive LP identity when switching |

## Face Coverage

Both themes define the same set of ~55 face specifications across:

| Group | Faces |
|-------|-------|
| Core UI | `default`, `cursor`, `region`, `highlight`, `hl-line`, `fringe`, `vertical-border`, `minibuffer-prompt`, `link` |
| Mode line | `mode-line`, `mode-line-inactive`, `mode-line-buffer-id` |
| Line numbers | `line-number`, `line-number-current-line` |
| Search | `isearch`, `isearch-fail`, `lazy-highlight` |
| Font lock | 13 `font-lock-*` faces |
| Errors | `error`, `warning`, `success` |
| Parentheses | `show-paren-match`, `show-paren-mismatch` |
| Org-mode | 14 `org-*` faces |
| Company | 6 `company-*` faces |
| Helm | 9 `helm-*` faces |
| Magit | 9 `magit-*` faces |

## Dotfile Integration

`dotspacemacs-themes` in `dotfile.spacemacs.tmpl` should list:

```elisp
dotspacemacs-themes '(latticeprotocol-dark
                      latticeprotocol-light)
```

The `latticeprotocol-theme` layer in `dotspacemacs-configuration-layers` loads the local package and registers the theme load path via `init-latticeprotocol-theme`.

## File Layout

```
layers/+themes/latticeprotocol-theme/
├── packages.el                              — layer declaration + load-path init
└── local/latticeprotocol-theme/
    ├── latticeprotocol-dark-theme.el        — dark variant (this spec §Dark)
    └── latticeprotocol-light-theme.el       — light variant (this spec §Light)
```
