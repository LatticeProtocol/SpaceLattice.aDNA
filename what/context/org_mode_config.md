---
type: context
title: "Org-mode configuration reference — Spacemacs.aDNA"
status: active
created: 2026-05-07
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [org-mode, configuration, spacemacs, layer, agenda, capture, roam, export, babel, clock]
---

# Org-mode configuration reference

Configuration decisions for the `org` Spacemacs layer in Spacemacs.aDNA.
Research completed P3-14 (2026-05-08). All decisions reflected in
`dotfile.spacemacs.tmpl §P3-07`.

---

## Spacemacs org layer variables

The `org` layer is enabled with these `:variables` in `dotspacemacs-configuration-layers`:

```elisp
(org :variables org-want-todo-bindings t
               org-enable-roam-support t
               org-enable-roam-protocol t
               org-enable-sticky-header t
               org-enable-org-journal-support nil)
```

| Variable | Value | Rationale |
|----------|-------|-----------|
| `org-want-todo-bindings` | `t` | `t`/`T`/`m` bindings in org agenda view |
| `org-enable-roam-support` | `t` | org-roam v2 for zettelkasten-style linked notes |
| `org-enable-roam-protocol` | `t` | `org-protocol://roam-ref` capture from browser extensions |
| `org-enable-sticky-header` | `t` | Breadcrumb header visible while scrolling long org files |
| `org-enable-org-journal-support` | `nil` | Deferred — style TBD (daily/weekly); org-roam dailies may cover this |
| `org-enable-notifications` | `nil` (default) | macOS notification center integration; defer until agenda workflow is stable |
| `org-enable-org-projectile` | `nil` (default) | Links TODOs to projectile projects; defer to P4+ (requires `helm-projectile`) |

---

## Directory and file layout

```
<vault-root>/org/         ← org-directory, org-roam-directory
├── inbox.org             ← capture target for quick TODOs
├── work.org              ← active work items, meeting notes
├── .roam.db              ← org-roam DB (gitignored)
└── roam/                 ← future org-roam node files (created by org-roam-capture)
```

`org-directory` is vault-local (`Spacemacs.aDNA/org/`). Machine-specific paths
(e.g., iCloud-synced org for iOS) go in `what/local/operator.private.el`:

```elisp
;; In operator.private.el — iCloud sync path for iOS access:
;; (setq org-directory "~/Library/Mobile Documents/iCloud~com~orgmode~beorg/Documents/org/")
```

---

## Agenda

```elisp
(setq org-agenda-files
      (list (concat dotspacemacs-directory "org/inbox.org")
            (concat dotspacemacs-directory "org/work.org")))
```

**Rationale**: Minimal agenda scope. Avoids slow scans of large roam graphs.
`inbox.org` = fast capture target; `work.org` = structured active items.
Expand to include additional files (e.g., `projects.org`) once workflow is stable.

### Custom agenda views (future)

Add to `operator.private.el` once needed:

```elisp
(setq org-agenda-custom-commands
  '(("n" "NEXT actions" todo "NEXT")
    ("w" "Waiting" todo "WAIT")
    ("d" "Daily review" ((agenda "" ((org-agenda-span 1)))
                         (todo "NEXT")))))
```

---

## Capture templates

```elisp
(setq org-capture-templates
  '(("t" "TODO inbox" entry
     (file+headline "org/inbox.org" "Inbox")
     "* TODO %?\n  %i\n  %a\n  :CREATED: %U")

    ("s" "Session note" entry
     (file+olp+datetree "org/work.org")
     "* %<%H:%M> %?\n  %i")

    ("d" "Decision candidate" entry
     (file+headline "org/work.org" "Decisions")
     "* DECISION %?\n  Context: %i\n  Ref: %a\n  :CREATED: %U")

    ("c" "Code snippet" entry
     (file+headline "org/work.org" "Snippets")
     "* %?\n  #+BEGIN_SRC %^{Language}\n  %i\n  #+END_SRC\n  Ref: %a")))
```

| Key | Template | Target | Purpose |
|-----|---------|--------|---------|
| `t` | TODO inbox | `inbox.org :: Inbox` | Quick capture for GTD processing |
| `s` | Session note | `work.org` (datetree) | Timestamped note during active session |
| `d` | Decision candidate | `work.org :: Decisions` | Pre-ADR capture with context link |
| `c` | Code snippet | `work.org :: Snippets` | Saved code block with language prompt |

**Access**: `SPC a o c` (org-capture). After filling, `C-c C-c` to save, `C-c C-k` to abort.

---

## Refile

```elisp
(setq org-refile-targets '((nil :maxlevel . 9)
                            (org-agenda-files :maxlevel . 9))
      org-refile-use-outline-path t
      org-outline-path-complete-in-steps nil)
```

Full-depth refile into any heading in the agenda files. `outline-path-complete-in-steps nil`
enables helm fuzzy-search across the full path in one step.

---

## TODO keywords

```elisp
(setq org-todo-keywords
  '((sequence "TODO" "NEXT" "WAIT" "|" "DONE" "CANCELLED")))
```

GTD-lite state machine. `NEXT` = committed, being worked on. `WAIT` = blocked on external.

---

## Org-babel languages

```elisp
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell      . t)
   (python     . t)
   (jupyter    . t)))
```

| Language | Use case |
|---------|---------|
| `emacs-lisp` | Config examples, aDNA tooling scripts |
| `shell` | Runbook code blocks, DevOps automation |
| `python` | ML pipeline snippets, data exploration |
| `jupyter` | Interactive kernel execution via `ein` layer |

**Safety**: `org-confirm-babel-evaluate t` (default) prompts before running
unfamiliar code blocks. Do not set to `nil` globally.

---

## Org-clock

```elisp
(setq org-clock-persist t
      org-clock-in-resume t
      org-clock-out-remove-zero-time-clocks t
      org-clock-report-include-clocking-task t)
(org-clock-persistence-insinuate)
```

| Setting | Effect |
|---------|--------|
| `org-clock-persist t` | Saves running clock across Emacs restarts |
| `org-clock-in-resume t` | Resumes the last clock on startup if one was running |
| `org-clock-out-remove-zero-time-clocks t` | Cleans up zero-time CLOCK entries |
| `org-clock-report-include-clocking-task t` | Includes current task in clock reports |

**Access**: `SPC a o l` (org-clock-in-last), `, C l` (org-clock-in) in org buffers.

---

## Org-export backends

HTML and LaTeX export are available by default (latex layer already in standard).
Enable Markdown and reveal.js backends:

```elisp
(with-eval-after-load 'ox
  (require 'ox-md nil t)     ; Markdown export (ox-md, built-in since Org 8)
  (require 'ox-reveal nil t)) ; Reveal.js presentations — needs ox-reveal package
```

| Backend | Package | Use case |
|---------|---------|---------|
| HTML | built-in | Web sharing, documentation |
| LaTeX/PDF | built-in (`latex` layer) | Papers, reports, formal docs |
| Markdown | `ox-md` (built-in org) | GitHub README, static sites |
| Reveal.js | `ox-reveal` (MELPA) | Presentations — relates to CanvasForge |

`ox-reveal` deferred from additional-packages until needed (not in active use).

---

## Org-roam

```elisp
(with-eval-after-load 'org-roam
  (setq org-roam-directory  (concat dotspacemacs-directory "org/")
        org-roam-db-location (concat dotspacemacs-directory "org/.roam.db"))
  (org-roam-db-autosync-mode))
```

**Obsidian coexistence**: Obsidian uses its own graph (`.obsidian/`); org-roam uses
`.roam.db`. Both can coexist in the vault — they manage different graph representations
of the same files. Best practice: keep `org/` files distinct from Obsidian-managed
Markdown files to avoid formatting conflicts.

**org-roam-ui** (visual graph browser): Package `org-roam-ui` provides a localhost web
browser visualization. Defer to additional-packages if desired:

```elisp
;; In operator.private.el or additional-packages:
;; (org-roam-ui :follow t :sync-theme t)
```

**Dailies** (`org-roam-dailies`): Available via `SPC a o r d` when org-roam-support
is enabled. Alternative to org-journal. Deferred — use once agenda workflow is stable.

---

## iOS sync

The `org/` directory can sync to iOS via iCloud Drive. Apps: Plain Org (read/write),
Beorg (agenda + capture), Journelly (journal). Full app comparison in
`what/context/platform_macos.md §iOS org-mode companion apps`.

**iCloud path** (machine-specific — goes in `operator.private.el`):

```elisp
;; Override org-directory for iCloud sync:
(setq org-directory
      "~/Library/Mobile Documents/iCloud~com~orgmode~beorg/Documents/org/")
;; Update agenda files to match:
(setq org-agenda-files
      (mapcar (lambda (f) (concat org-directory f))
              '("inbox.org" "work.org")))
```

**Sync discipline**: Only one writer at a time (Emacs OR iOS app). iCloud handles
conflict resolution but doesn't merge org-mode syntax well — staggered writes are safer.

---

## References

- Spacemacs org layer: `https://develop.spacemacs.org/layers/+emacs/org/README.html`
- org-roam manual: `https://www.orgroam.com/manual.html`
- Mission: `mission_sl_p3_14_org_mode_deep_config`
- Platform iOS context: `what/context/platform_macos.md §iOS org-mode companion apps`
- ADR-016: GC + LSP buffer (user-config variable patterns)
