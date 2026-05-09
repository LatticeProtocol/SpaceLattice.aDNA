---
type: adr
adr_number: 030
title: "LP dotfile template overrides — distribution, themes, news wire"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, dotfile, distribution, themes, branding, p4]
---

# ADR-030: LP Dotfile Template Overrides — Distribution, Themes, News Wire

## Status

Accepted

## Context

The `dotfile.spacemacs.tmpl` (rendered to `init.el` by `skill_deploy`) still carried upstream Spacemacs defaults for `dotspacemacs-distribution` and `dotspacemacs-themes`. P4-06 is the mission to lock in LP-specific defaults that ship with the distribution. Three changes are required:

1. **Distribution**: `'spacemacs` → `'spacemacs-latticeprotocol` (the LP distribution layer name, confirmed in P3-03 and ADR-025).
2. **Themes**: Add `spacemacs-dark` as a fallback third option after the two LP themes; ensures graceful degradation if the LP theme package fails to load.
3. **News wire**: `config.el` already wires `spacemacs-buffer-note-file` to `what/docs/lp_release_notes_v1_0.org` (ADR-029 section). The vault doc is created as a stub; final content at P5-03.

Frame-title-format (ADR-022: `'("%b [" (:eval (projectile-project-name)) "]")`) is kept as-is — it is already informative and carries the project name. The mission spec's `"%I@%S [LP]"` format is overridden by this decision; buffer+project format is more useful in daily operation.

## Decision

1. Edit `dotfile.spacemacs.tmpl`:
   - `dotspacemacs-distribution 'spacemacs` → `'spacemacs-latticeprotocol`
   - `dotspacemacs-themes` → `'(latticeprotocol-dark latticeprotocol-light spacemacs-dark)`
2. Create `what/standard/spacelattice_dotfile_template_overrides.md` — vault reference doc for all LP dotfile defaults.
3. Create `what/docs/lp_release_notes_v1_0.org` — stub LP release notes file (final at P5-03).

## Consequences

### Positive
- Fresh installs default to the LP distribution and LP themes without operator friction
- `spacemacs-dark` fallback ensures a working state if LP theme load fails
- LP news stub is in place; no operator-facing gap at first boot

### Negative
- `dotspacemacs-distribution 'spacemacs-latticeprotocol` will show an error if the LP layer is not installed; standard bootstrap assumption
- `spacemacs-dark` as third theme is visible in `SPC T n` cycle — minor clutter

### Neutral
- Frame-title-format kept as buffer+project (ADR-022); mission spec's format not adopted
- Release notes stub empty until P5-03; startup buffer shows an empty note section until then
