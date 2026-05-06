---
type: mission
mission_id: mission_sl_p3_11_browser_integration_eww
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 11
status: planned
mission_class: implementation
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, eww, browser, xwidget, agentic]
blocked_by: [mission_sl_p3_10_layer_expansion_audit]
---

# Mission — P3-11: Browser Integration (eww + xwidget-webkit)

**Phase**: P3 — Customization walkthrough.
**Class**: implementation (operator-gated).

## Objective

Validate, configure, and document the full SpaceLattice browser stack (eww + xwidget-webkit) in a live Emacs session. Establish eww as a first-class agentic tool — documented in the context graph — so agents can programmatically open URLs, capture web content, and interact with local dev servers without leaving Emacs.

## Background

eww is Emacs's built-in web browser. SpaceLattice.aDNA treats it as the primary browser for text-heavy pages, docs lookup, and agentic URL fetching. The dotfile configures `browse-url-browser-function` routing and `ace-link` integration. xwidget-webkit is the JavaScript-capable alternative when compiled with `--with-xwidgets`. Context doc: `what/context/spacemacs/eww_browser_xwidget_integration.md`.

The Vimium-style navigation stack (avy-goto-char-timer, link-hint, ace-link) is also validated in this mission.

## Deliverables

### 1. Live session validation checklist

Execute in a running Emacs session and record pass/fail in this mission file:

| Check | Command | Expected | Result |
|-------|---------|---------|--------|
| eww loads | `M-x eww RET https://emacs.org` | Page renders, links visible | ⬜ |
| ace-link in eww | Press `o` in eww buffer | Letters overlay on all visible links | ⬜ |
| link-hint global | `SPC j o` in any org buffer | Letters overlay on all visible links | ⬜ |
| link-hint copy | `SPC j O` | URL copied to kill-ring | ⬜ |
| avy-char-timer | `SPC j J` | Decision tree appears after 0.3s pause | ⬜ |
| avy-goto-line | `SPC j l` | Lines labeled, jump on keystroke | ⬜ |
| browse-url routing | Org link `[[https://claude.ai]]` → RET | External browser opens | ⬜ |
| browse-url routing | Org link `[[https://emacs.org]]` → RET | eww opens | ⬜ |
| xwidget available | `(boundp 'xwidget-webkit-mode)` | t or nil (document which) | ⬜ |
| local dev server | `M-x eww RET http://localhost:4321/` | Local site renders | ⬜ (if server running) |
| file:// inspect | `(eww "file:///path/to/index.html")` | HTML file renders in eww | ⬜ |
| adna wikilink → eww | Click wikilink with http:// prefix | eww opens URL | ⬜ |

### 2. xwidget-webkit assessment

Determine if current emacs-plus@29 install was compiled `--with-xwidgets`:

```bash
emacs --batch --eval '(message "%s" (boundp (quote xwidget-webkit-mode)))' 2>&1
```

If `nil`: document in ADR and in `skill_install` runbook — xwidgets requires recompile.
If `t`: validate `xwwp` install and Vimium overlay behavior; add `xwwp` to `dotspacemacs-additional-packages`.

### 3. ADR-NNN — browser integration rationale

Document the full browser stack decision:
- eww as primary (no JS) vs. xwidget-webkit (JS) vs. external — why this hierarchy
- browse-url routing table (which domains go where and why)
- ace-link vs. link-hint usage split (mode-specific vs. universal)

### 4. skill_health_check extension

Add eww-specific health check step: verify `browse-url-browser-function` is set and `ace-link` is loaded.

```elisp
(cl-assert (functionp #'ace-link-eww) nil "ace-link not loaded")
(cl-assert (consp browse-url-browser-function) nil "browse-url routing not configured")
```

### 5. freshening `fresh_machine.md`

If xwidgets requires recompile:

```bash
brew uninstall emacs-plus@29
brew install emacs-plus@29 --with-xwidgets
```

Add this as an optional step in `how/standard/runbooks/fresh_machine.md` with a note on when to choose it.

### 6. Agentic use demo

Record a session where Claude Code uses `eww` to:
1. Open a docs URL (`https://docs.python.org/3/library/pathlib.html`)
2. Navigate to a specific section using `ace-link`
3. Capture text to an org buffer

Document the session transcript in this mission's AAR as proof of agentic web integration.

## Estimated effort

2 sessions.

## Dependencies

P3-10 complete (layer expansion audit locked down before adding more packages to additional-packages).

## Reference

- Context doc: `what/context/spacemacs/eww_browser_xwidget_integration.md`
- Dotfile config: `what/standard/dotfile.spacemacs.tmpl` `user-config` eww section
- xwwp: https://github.com/canatella/xwwp
- ace-link: https://github.com/abo-abo/ace-link
- link-hint: https://github.com/noctuid/link-hint.el
