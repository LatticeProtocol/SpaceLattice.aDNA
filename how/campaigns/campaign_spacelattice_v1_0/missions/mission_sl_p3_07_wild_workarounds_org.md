---
type: mission
mission_id: mission_sl_p3_07_wild_workarounds_org
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 7
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, customization, wild_customizations, workarounds, org_mode, user_in_loop]
blocked_by: [mission_sl_p3_06_perf_evil_fonts]
---

# Mission — P3-07: Wild customizations + canonical workarounds + org-mode power-user

**Phase**: P3 — Customization walk-through (user-in-the-loop).
**Class**: implementation.

## Objective

Walk dimensions §3.1 (wild high-signal layer combinations: general IDE / Clojure / Data-R / Python-DS / C-C++ / Web-JS-TS / Notes / Email / DevOps / Themes-heavy), §3.2 (canonical workarounds for 10 well-known pain points: org double-loading, org-roam-mode auto-enable, mode-hooks for CLI files, exec-path-from-shell, helm/ivy daemon stale prompts, LSP file-watchers, ELPA TLS in MITM proxies, package-install-file native-comp, treemacs auto-loading, evil-escape jj/fd, macOS title-bar matching), §3.3 (org-mode power-user setup: roam-v2, journal, agenda integration, refile, babel-loaded-languages). Operator-in-the-loop: which workarounds apply, how heavy is the org-mode usage.

## Deliverables

- 7-step protocol
- Decisions recorded: which workarounds adopted; how org-mode is configured for operator's note-taking / agenda workflow
- Layer changes: each workaround → entry in profile + edit in `what/local/operator.private.el` or `dotfile.spacemacs.tmpl`; org-mode config per operator's stack
- AAR

## Estimated effort

1-2 sessions.

## Dependencies

P3-06 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §3.1, §3.2, §3.3
