---
type: mission
mission_id: mission_sl_p3_04_themes_modeline_banner_startup
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 4
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, customization, theme, modeline, banner, startup, user_in_loop]
blocked_by: [mission_sl_p3_03_layer_anatomy_api]
---

# Mission — P3-04: Themes + modeline + banner + startup buffer

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Walk dimensions §1.6 (theme system: `dotspacemacs-themes`, cycling via `SPC T n` / `SPC T s`, `theming` layer, themes-megapack), §1.7 (modeline: 6 modeline themes — spacemacs / all-the-icons / custom / doom / vim-powerline / vanilla — and segments), §1.8 (banner system: text banners 000-banner.txt … + image banners + selection logic + 75-col width), §1.9 (startup buffer + scratch + frame title + transient states + which-key). Operator-in-the-loop: theme + modeline + banner + frame-title preferences. Pre-figures decisions for P4-03 (theme) and P4-05 (banner assets).

## Deliverables

- 7-step protocol
- Decisions recorded: modeline theme, banner type, frame-title format, startup-buffer config (recents/projects/agenda/todos lengths)
- Profile updated
- Layer changes: `what/local/operator.private.el` overrides + draft frame-title-format/startup-list overrides candidates for `dotfile.spacemacs.tmpl` (ADR-gated)
- Pre-figuring outputs: theme-palette preferences feed P4-03; banner-asset constraints feed P4-05
- AAR

## Estimated effort

1-2 sessions.

## Dependencies

P3-03 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §1.6, §1.7, §1.8, §1.9
- `what/standard/fork-strategy.md` (theme + banner planning sections)
