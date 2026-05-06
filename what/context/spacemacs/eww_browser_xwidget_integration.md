---
type: context
status: active
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [context, eww, browser, xwidget, webkit, web, agentic, spacelattice]
load_when: ["eww configuration", "browser integration", "web browsing in emacs", "P3-11 mission", "skill_layer_add eww"]
---

# SpaceLattice Browser Integration — eww + xwidget-webkit

## Purpose

SpaceLattice.aDNA treats Emacs as a **first-class browser environment**. The goal is not to replace a modern browser for all tasks, but to enable:

1. **Docs lookup** — reading developer docs, API references, GitHub READMEs without leaving Emacs
2. **Programmatic web interaction** — Claude Code / agent tasks that need to fetch or navigate web content
3. **Agentic task support** — opening URLs for the operator, capturing content into org/aDNA buffers
4. **Inspection mode** — reading rendered HTML output to verify local dev servers, review generated sites

## Browser Stack (priority order)

| Browser | When | JS? | Vimium-style nav? |
|---------|------|-----|-------------------|
| `eww` | Text-heavy pages, docs, programmatic fetch | ❌ | `o` → ace-link-eww |
| `xwidget-webkit` | JS-requiring pages (compiled with `--with-xwidgets`) | ✅ | `v` → xwwp / `t` → xwwp-ace-toggle |
| External browser | Auth flows, SPAs, Slack, Claude.ai | ✅ | n/a |

## eww — Built-in Emacs Web Browser

### Capabilities and limits

**Can do**: Load any URL, render HTML to text via `shr.el`, follow links, maintain history + bookmarks, submit simple forms (text fields, dropdowns, checkboxes), download files, display images, integration with `ace-link` and `link-hint`.

**Cannot do**: Execute JavaScript. Render modern CSS. Handle SPAs or React apps. Play video/audio. Manage cookies across JS auth flows.

**Rule of thumb**: If a site works in w3m or Links, it works in eww. If a site requires JavaScript to render content, use xwidget-webkit or an external browser.

### Starting eww

```elisp
;; From anywhere in Emacs:
M-x eww RET https://example.com RET

;; From elisp (agentic use):
(eww "https://example.com")

;; From org-mode link:
;; [[https://example.com]]  →  RET to open in eww (with browse-url routing)
```

### Key bindings (SpaceLattice config)

| Key | Action |
|-----|--------|
| `o` | `ace-link-eww` — Vimium-style overlay on all visible links |
| `RET` | Follow link under cursor |
| `&` | Open current URL in external browser |
| `v` | Open in new eww buffer (overridden in SpaceLattice config) |
| `b` | Back |
| `f` | Forward |
| `H` | History |
| `r` | Reload |
| `d` | Download URL |
| `q` | Quit / bury buffer |
| `w` | Copy URL at point |
| `C-c C-f` | Toggle fonts |
| `S` | View page source |

### Programmatic use (agentic workflows)

```elisp
;; Fetch and capture a URL to a new buffer:
(with-current-buffer (url-retrieve-synchronously "https://example.com")
  (goto-char (point-min))
  (search-forward "\r\n\r\n")       ; skip headers
  (shr-render-region (point) (point-max) (current-buffer))
  (buffer-string))

;; Open URL and return the rendered text:
(defun adna/eww-fetch-text (url)
  "Return the rendered text of URL via eww/shr."
  (with-temp-buffer
    (url-insert-file-contents url)
    (shr-render-region (point-min) (point-max))
    (buffer-string)))

;; Open a URL in eww programmatically (non-blocking):
(eww-browse-url "https://docs.python.org/3/")
```

### Browse-url routing (SpaceLattice standard)

Configured in `dotfile.spacemacs.tmpl` `user-config`. Routes auth/SPA URLs to external browser, everything else to eww:

```elisp
(setq browse-url-browser-function
      '((".*claude\\.ai.*"       . browse-url-default-browser)
        (".*atlassian\\.net.*"   . browse-url-default-browser)
        (".*slack\\.com.*"       . browse-url-default-browser)
        (".*"                    . eww-browse-url)))
```

Add patterns as needed in `what/local/operator.private.el` (gitignored, loaded last).

## xwidget-webkit — JavaScript-capable Emacs Browser

### Prerequisites

Emacs must be compiled with `--with-xwidgets`. On macOS with emacs-plus:

```bash
brew install emacs-plus@29 --with-xwidgets
```

Check: `(boundp 'xwidget-webkit-mode)` — t if available.

### Usage

```elisp
;; Open URL in webkit widget:
(xwidget-webkit-browse-url "https://example.com")

;; From eww: press & to open current URL in webkit
```

### xwwp — Vimium-style overlays for webkit

Package: `canatella/xwwp` (add to `dotspacemacs-additional-packages` when xwidgets available).

```elisp
;; Install xwwp if xwidgets available:
(when (boundp 'xwidget-webkit-mode)
  (use-package xwwp
    :bind (:map xwidget-webkit-mode-map
           ("v" . xwwp-follow-link)
           ("t" . xwwp-ace-toggle))))
```

- `v` → overlay letters on all visible links (exact Vimium match)
- `t` → overlay letters on ALL interactive elements (buttons, inputs)

## ace-link — Link jumping in eww, info, help

Package: `ace-link` (in `dotspacemacs-additional-packages`).

Works in: `eww-mode`, `Info-mode`, `help-mode`, `woman-mode`, `org-mode`, `compilation-mode`.

Press `o` in any of these modes → letters appear over all visible links → type to jump.

Configured in SpaceLattice `user-config`:
```elisp
(with-eval-after-load 'eww
  (define-key eww-mode-map (kbd "o") #'ace-link-eww))
```

## link-hint — Vimium overlay in any buffer

Package: `link-hint` (in `dotspacemacs-additional-packages`).

Unlike `ace-link` (mode-specific), `link-hint` works in any buffer that has link-type text (org links, eww URLs, file paths, buttons, etc.).

SpaceLattice bindings (configured in `user-config`):
```elisp
(spacemacs/set-leader-keys "jo" #'link-hint-open-link)
(spacemacs/set-leader-keys "jO" #'link-hint-copy-link)
```

- `SPC j o` → open any visible link
- `SPC j O` → copy any visible link URL to kill-ring

## Agentic Use Patterns

### Pattern: agent opens URL for operator review

```elisp
;; Agent opens a URL; operator sees it in eww buffer
(eww "https://arxiv.org/abs/2406.12345")
```

### Pattern: agent fetches URL, captures to org

```elisp
(defun adna/capture-url-to-org (url)
  "Fetch URL and capture title + summary to org."
  (interactive "sURL: ")
  (let* ((text (adna/eww-fetch-text url))
         (title (with-current-buffer "*eww*"
                  (eww-current-url))))
    (org-capture nil "w")))   ; configure 'w' capture template for web clips
```

### Pattern: local dev server inspection

```elisp
;; Open local Astro/SiteForge dev server in eww
(eww "http://localhost:4321/")
;; Note: eww can render static HTML well; JS-driven content needs xwidget-webkit
```

### Pattern: SiteForge / ComfyForge output review

```elisp
;; Review generated site output without leaving Emacs
(eww (concat "file://" (expand-file-name "~/lattice/SiteForge.aDNA/dist/index.html")))
```

## Operational Checklist (P3-11 mission deliverables)

Before P3-11 closes, verify in a live Emacs session:

- [ ] `M-x eww RET https://emacs.org` loads and renders
- [ ] `o` key opens ace-link overlay with letters on all visible links
- [ ] `SPC j o` opens link-hint overlay in an org buffer
- [ ] `SPC j J` (avy-goto-char-timer) shows decision tree after brief pause
- [ ] `browse-url-browser-function` routing verified: `https://claude.ai` → external, `https://emacs.org` → eww
- [ ] Xwidget check: `(boundp 'xwidget-webkit-mode)` returns t or nil (document result)
- [ ] If xwidgets available: `xwwp-follow-link` works in webkit buffer
- [ ] `adna-browse-url-function` routes wikilink URLs to eww

## Implementation Phase

- **Dotfile config**: v0.2.0 base (this session — browse-url routing, ace-link, link-hint)
- **P3-11 mission**: Live installation, full keybinding validation, xwidget check, operator review
- **Future**: If xwidgets not compiled in, document `brew install emacs-plus@29 --with-xwidgets` in `skill_install`

## References

- eww GNU manual: https://www.gnu.org/software/emacs/manual/html_mono/eww.html
- xwwp (xwidget Vimium): https://github.com/canatella/xwwp
- ace-link: https://github.com/abo-abo/ace-link
- link-hint: https://github.com/noctuid/link-hint.el
- Spacemacs eww issue: https://github.com/syl20bnr/spacemacs/issues/4107 (no official layer; configure in user-config)
