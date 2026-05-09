---
type: mission
mission_id: mission_sl_p3_14_org_mode_deep_config
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 14
status: completed
mission_class: research_and_implementation
created: 2026-05-07
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [mission, completed, spacemacs, v1_0, p3, org_mode, agenda, capture, roam, babel, export]
blocked_by: [mission_sl_p3_07_wild_workarounds_org]
---

# Mission — P3-14: Org-Mode Deep Configuration

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: research_and_implementation.

## Objective

Research and operator-gate a complete org-mode configuration for Spacemacs.aDNA. The `org` layer is already in the standard layer list with `org-want-todo-bindings t` and `org-enable-roam-support t`, and `§P3-07 Workarounds / org-mode` in user-config is currently empty. This mission fills that section with a validated, operator-approved org-mode setup.

`what/context/org_mode_config.md` was seeded as a research-agenda stub in the 2026-05-07 session — start by completing that file, then translate decisions into dotfile config.

## Deliverables

**Research (session 1)**:
- Web research: Spacemacs org layer variables, org-agenda, org-capture templates, org-roam, org-babel languages, org-export backends, org-clock, iOS sync
- Complete `what/context/org_mode_config.md` (stub → active)
- Operator decision on each sub-feature: enable/configure/defer/skip

**Implementation (session 2)**:
- Draft `§P3-07` org-mode section in `dotfile.spacemacs.tmpl` with operator-approved settings
- Org-agenda files pointing to `~/lattice/` vault hierarchy (or operator-specified path)
- Org-capture templates (minimum: TODO inbox, session note, decision candidate)
- Org-roam directory (if enabled): set `org-roam-directory` in `operator.private.el` (machine-specific path)
- Org-babel language enablement: `python`, `shell`, `emacs-lisp` at minimum
- ADR for any standard-layer choices (org-roam enable/disable is a good candidate)
- `skill_deploy` + `skill_health_check` validation
- `who/operators/stanley.md` updated with org-mode section
- iOS sync setup instructions (if operator wants mobile access)
- AAR

## Estimated effort

2 sessions.

## Dependencies

P3-07 closed (wild combos + workarounds section reviewed first — org-mode context from that mission informs this one).

## Reference

- `what/context/org_mode_config.md` (stub seeded 2026-05-07 — contains full research agenda)
- `what/standard/dotfile.spacemacs.tmpl` `§P3-07 Workarounds / org-mode` (current placeholder)
- Spacemacs org layer docs: https://develop.spacemacs.org/layers/+emacs/org/README.html
- org-roam manual: https://www.orgroam.com/manual.html
- `what/context/platform_macos.md` §iOS org-mode companion apps (mobile sync)
