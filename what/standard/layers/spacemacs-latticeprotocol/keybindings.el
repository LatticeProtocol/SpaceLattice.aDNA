;;; keybindings.el --- spacemacs-latticeprotocol distribution layer keybindings  -*- lexical-binding: t -*-
;;
;; Author:  LatticeProtocol / Daedalus (Spacemacs.aDNA)
;; License: GPL-3.0
;;
;; `SPC o l' LP prefix (P3-08 binding table, operator profile §3.5):
;;
;;   SPC o l h  →  adna/open-manifest      Vault home (MANIFEST.md)
;;   SPC o l f  →  lp/find-context         Helm-browse what/context/
;;   SPC o l s  →  adna/capture-session-note  New session file
;;   SPC o l g  →  adna/render-lattice-graph  Open graph.json
;;   SPC o l c  →  claude-code-ide-toggle   Toggle Claude Code IDE buffer

;;; Context finder (lp/ namespace — simple helm bridge to what/context/)

(defun lp/find-context ()
  "Open helm-find-files rooted at what/context/ of nearest aDNA vault."
  (interactive)
  (let* ((root (adna/--root-or-error))
         (ctx-dir (expand-file-name "what/context/" root)))
    (if (and (fboundp 'helm-find-files-1) (file-directory-p ctx-dir))
        (helm-find-files-1 ctx-dir)
      (find-file ctx-dir))))

;;; SPC o l — lattice-protocol sub-prefix

(spacemacs/declare-prefix "ol" "lattice-protocol")

(spacemacs/set-leader-keys
  "olh" #'adna/open-manifest            ; h = home — vault MANIFEST.md
  "olf" #'lp/find-context               ; f = find context file
  "ols" #'adna/capture-session-note     ; s = session new
  "olg" #'adna/render-lattice-graph)    ; g = graph

;; Claude Code IDE toggle — bound only when that layer is active
(with-eval-after-load 'claude-code-ide
  (spacemacs/set-leader-keys
    "olc" #'claude-code-ide-toggle))    ; c = Claude Code IDE toggle

;;; keybindings.el ends here
