---
type: adr
adr_id: "012"
adr_kind: standard_config
title: "Presentation layer: resolve dotfile placeholders, adopt doom-modeline, add banner system"
status: accepted
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, dotfile, presentation, p3]
---

# ADR-012: Presentation Layer — Dotfile Placeholder Resolution, doom-modeline, Banner System

## Status

Accepted

## Context

During P3 pre-flight review, `what/standard/dotfile.spacemacs.tmpl` was found to contain unresolved template placeholders (`{{THEME_PRIMARY}}`, `{{THEME_FALLBACK}}`, `{{FONT_FAMILY}}`, `{{FONT_SIZE}}`) that would cause broken Spacemacs startups on any fresh install without a separate render step. The modeline was also set to the Spacemacs default (`spacemacs :separator wave`), which provides less information density than desired. No banner system was configured — Spacemacs would fall back to `'official`.

User-in-the-loop consultation (P3 pre-flight session 2026-05-06) produced concrete visual selections:
- Theme: stock `spacemacs-dark` / `spacemacs-light` (no doom-themes dependency)
- Modeline: `doom-modeline` adapted to spacemacs-dark faces via `doom-modeline-icon nil` (text-only, inherits spacemacs faces, no icon font required)
- Banner: custom ASCII SpaceLattice text at `{{VAULT_ROOT}}/what/standard/assets/banner_active.txt` (symlink-swappable)
- Font: Source Code Pro 13pt

## Decision

1. **Resolve all placeholders** in `dotspacemacs/init` to concrete values:
   - `dotspacemacs-startup-banner` → `"{{VAULT_ROOT}}/what/standard/assets/banner_active.txt"` (the `{{VAULT_ROOT}}` token is substituted by `skill_deploy`, not hardcoded)
   - `dotspacemacs-themes` → `'(spacemacs-dark spacemacs-light)`
   - `dotspacemacs-mode-line-theme` → `'doom`
   - `dotspacemacs-default-font` → `'("Source Code Pro" :size 13 :weight normal :width normal)`

2. **Add doom-modeline configuration** in `dotspacemacs/user-config` via `with-eval-after-load 'doom-modeline`:
   - `doom-modeline-icon nil` — text-only; inherits spacemacs-dark faces
   - Custom `adna-vault` segment — shows `⬡vault-name` with `success` face weight bold when `adna-mode` is active
   - Custom `spacelattice-main` modeline format: left: `bar matches buffer-info remote-host buffer-position`; right: `adna-vault misc-info lsp checker major-mode process`

3. **Add banner asset files** at `what/standard/assets/`:
   - `banner_v1_dot_field.txt` — lattice dot-field design
   - `banner_v2_monolith.txt` — LP monolith with box-drawing border (initial `banner_active.txt` content)
   - `banner_v3_signal.txt` — dashed border with ▶◀ arrows
   - `banner_active.txt` — active banner (operator swaps to change startup look without dotfile redeploy)

## Consequences

### Positive
- Dotfile is immediately deployable without a separate render step for these four values
- doom-modeline provides superior information density (LSP status, git branch, checker) with no icon-font requirement
- `adna-vault` segment surfaces vault context directly in the modeline while in aDNA vaults
- Banner system is swappable without a dotfile redeploy (operator changes `banner_active.txt` symlink/content)
- No doom-themes dependency introduced — spacemacs-dark faces are authoritative

### Negative
- `{{VAULT_ROOT}}` must still be substituted by `skill_deploy` — banner path is not fully resolved at template author time

### Neutral
- `doom-modeline` package is already declared in `what/standard/layers.md` as a dependency of the `doom` modeline theme; this ADR activates its configuration, not its installation

## References

- `what/standard/dotfile.spacemacs.tmpl`
- `what/standard/assets/banner_active.txt`
- `what/standard/assets/banner_v{1,2,3}_*.txt`
- ADR-005 (rename + identity)
- P3 pre-flight session 2026-05-06
