;;; layouts.el --- adna layer named window layouts  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Named window configurations for the adna battle station.
;; Each function calls `delete-other-windows' for a clean slate, then
;; constructs the target layout using standard Emacs split primitives.
;; All functions are interactive — callable via `SPC a l' transient or M-x.
;;
;; ADR-035: https://github.com/LatticeProtocol/Spacemacs.aDNA
;;          what/decisions/adr/adr_035_agentic_layout_system.md
;;
;; Layouts defined here:
;;   adna/layout-agentic-default   — treemacs + edit area + claude terminal
;;   adna/layout-vault-navigation  — treemacs + content + imenu-list
;;   adna/layout-campaign-planning — campaign doc + mission file + STATE.md
;;   adna/layout-code-review       — magit + source + vterm

;;; ============================================================================
;;; Private helpers
;;; ============================================================================

(defun adna/--find-state-md (&optional root)
  "Return absolute path to STATE.md in vault ROOT, or nil if absent."
  (let ((r (or root (adna/find-vault-root))))
    (when r
      (let ((path (expand-file-name "STATE.md" r)))
        (when (file-exists-p path) path)))))

;;; ============================================================================
;;; Layouts
;;; ============================================================================

(defun adna/layout-agentic-default ()
  "Primary battle-station layout.
Treemacs file tree on the left (side window), main edit area on the
top-right, Claude Code terminal on the bottom-right.

  ┌──────────┬─────────────────────────────┐
  │ treemacs │  file buffer (edit/review)  │
  │          ├─────────────────────────────┤
  │          │  claude-code terminal       │
  └──────────┴─────────────────────────────┘"
  (interactive)
  (delete-other-windows)
  (when (fboundp 'treemacs) (treemacs))
  ;; After treemacs opens its side window, selected window is the main area.
  (split-window-below (floor (* 0.65 (frame-height))))
  (other-window 1)
  (adna/spawn-claude-code)
  ;; Return focus to the edit area.
  (other-window 1))

(defun adna/layout-vault-navigation ()
  "aDNA vault exploration layout.
Treemacs file tree on the left, content buffer in the center,
imenu-list symbol navigator on the right (if available).

  ┌──────────┬──────────────┬────────────┐
  │ treemacs │ content buf  │ imenu-list │
  └──────────┴──────────────┴────────────┘"
  (interactive)
  (delete-other-windows)
  (when (fboundp 'treemacs) (treemacs))
  (when (fboundp 'imenu-list-smart-toggle) (imenu-list-smart-toggle)))

(defun adna/layout-campaign-planning ()
  "Campaign and mission editing layout.
Three equal columns: left for a campaign doc, center for a mission
file, right for STATE.md (opened automatically if found in vault).

  ┌──────────────┬──────────────┬──────────┐
  │ campaign doc │ mission file │ STATE.md │
  └──────────────┴──────────────┴──────────┘"
  (interactive)
  (delete-other-windows)
  (let* ((col-w (floor (/ (frame-width) 3)))
         (w-mid   (split-window-right col-w))
         (w-right (with-selected-window w-mid (split-window-right col-w)))
         (state   (adna/--find-state-md)))
    (when state
      (with-selected-window w-right (find-file state)))
    ;; Park focus in center column for mission file editing.
    (select-window w-mid)))

(defun adna/layout-code-review ()
  "Code review layout.
Magit status (or log) on the top-left, source file on the top-right,
vterm spanning the full bottom.

  ┌──────────────────┬──────────────┐
  │ magit status/log │  source file │
  ├──────────────────┴──────────────┤
  │  vterm                          │
  └─────────────────────────────────┘"
  (interactive)
  (delete-other-windows)
  (let* ((w-top    (selected-window))
         (w-bottom (split-window-below (floor (* 0.65 (frame-height)))))
         (w-source (with-selected-window w-top (split-window-right (floor (* 0.5 (frame-width)))))))
    (when (fboundp 'magit-status)
      (with-selected-window w-top (magit-status)))
    (when (fboundp 'vterm)
      (with-selected-window w-bottom (vterm)))
    ;; Park focus on source file window.
    (select-window w-source)))

;;; layouts.el ends here
