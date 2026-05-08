---
type: context
title: "Org-mode configuration reference — Spacemacs.aDNA"
status: stub
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [org-mode, configuration, spacemacs, layer, agenda, capture, roam, export]
---

# Org-mode configuration reference

> **Status: stub** — Full research and configuration to be completed in mission
> `mission_sl_p3_14_org_mode_deep_config`. This file seeds the research agenda and
> captures initial context so the mission agent can proceed directly to work.

---

## Research agenda for p3_14

The mission agent should research and document each of the following, then update this
file from `status: stub` to `status: active`:

### Spacemacs org layer variables

The Spacemacs `org` layer is already in the standard layer list with:

```elisp
(org :variables org-want-todo-bindings t
               org-enable-roam-support t)
```

Research needed:
- Full list of `org-layer` variables and their defaults
- Which variables to set for ML/agentic-dev workflow optimization
- `org-enable-*` flags (notifications, org-sticky-header, org-projectile, org-journal)

### org-agenda configuration

- How to set `org-agenda-files` to cover all aDNA vault `.org` files
- Recommended agenda views for a software engineer / ML researcher workflow
- Custom agenda commands (`org-agenda-custom-commands`)
- Integration with the `~/lattice/` workspace (projectile-linked org files)

### org-capture templates

Starter templates to configure:
- Quick inbox item (`t` — TODO in inbox file)
- Session note (`s` — timestamped note to active session file)
- Code snippet (`c` — code block with language and reference)
- Meeting/decision note (`d` — decision record with link to ADR candidate)

### org-roam

`org-enable-roam-support t` enables org-roam. Research:
- Recommended `org-roam-directory` location relative to `~/lattice/`
- Whether org-roam and Obsidian can coexist (both manage a graph; `obsidian-coupling.md` has context)
- org-roam-ui for visual graph browsing
- Dailies (`org-roam-dailies`) vs org-journal

### org-babel

Relevant for ML/data science work:
- Enabling `python`, `shell`, `jupyter`, `emacs-lisp` backends
- `org-babel-do-load-languages` configuration
- Interaction with Jupyter via `ein` layer or `emacs-jupyter`

### org-export backends

- HTML export (web sharing)
- LaTeX/PDF export (papers, reports) — relates to existing `latex` layer
- reveal.js export (`ox-reveal`) for presentations — relates to CanvasForge workflows
- Markdown export (`ox-md`) for GitHub

### org-clock

- `org-clock-persist t` for cross-session clock tracking
- Clock report configuration
- Integration with org-agenda for time tracking views

### iOS sync

Determined by research in `platform_macos.md`: Plain Org / Beorg connect via iCloud Drive.
Research:
- Recommended `org-directory` path under iCloud (`~/Library/Mobile Documents/...`)
- Conflict-free sync patterns (one writer at a time)

---

## Current standard state

The `org` layer is already enabled in `dotfile.spacemacs.tmpl` with:

```elisp
(org :variables org-want-todo-bindings t
               org-enable-roam-support t)
```

The `§P3-07 Workarounds / org-mode` section in user-config is currently empty —
this is the section that p3_14 will populate.

---

## Known integration points

| Integration | Location | Notes |
|-------------|----------|-------|
| Obsidian coupling | `what/standard/obsidian-coupling.md` | aDNA uses wikilinks; org also supports wikilinks via `org-roam` |
| LaTeX layer | `dotfile.spacemacs.tmpl` | `latex` layer already standard — org PDF export uses this |
| Projectile | `what/standard/layers/adna/` | `org-projectile` links TODOs to project files |
| Session notes | `how/sessions/` | aDNA session notes are Markdown; org capture can supplement |

---

## References

- Mission: `mission_sl_p3_14_org_mode_deep_config`
- Spacemacs org layer docs: https://develop.spacemacs.org/layers/+emacs/org/README.html
- org-roam docs: https://www.orgroam.com/manual.html
- macOS iOS sync: `what/context/platform_macos.md` §iOS org-mode companion apps
- ADR precedent: ADR-015 (dotfile structure), ADR-016 (user-config variables)
