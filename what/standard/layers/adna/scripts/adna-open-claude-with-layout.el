;;; adna-open-claude-with-layout.el --- activate agentic layout + Claude Code  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Part of the adna layer scripts/ auto-discovery system (ADR-038).
;; Bound to SPC a x o.
;;
;; Combines layout activation (P5-01) and Claude Code startup (P4-09) into a
;; single one-key workflow. Replaces the manual sequence:
;;   SPC a l a  (activate layout)
;;   SPC c s    (start Claude)

(defun adna/open-claude-with-layout ()
  "Activate the agentic-default layout then start Claude Code for current project.
One-key session start: layout geometry + Claude in a single command."
  (interactive)
  (when (fboundp 'adna/layout-agentic-default)
    (adna/layout-agentic-default))
  (cond
   ((fboundp 'claude-code-ide)
    (call-interactively #'claude-code-ide))
   ((fboundp 'adna/spawn-claude-code)
    (call-interactively #'adna/spawn-claude-code))
   (t
    (user-error "Neither claude-code-ide nor adna/spawn-claude-code is available"))))

(when (fboundp 'spacemacs/set-leader-keys)
  (spacemacs/declare-prefix "axo" "open claude")
  (spacemacs/set-leader-keys "axo" #'adna/open-claude-with-layout))

(provide 'adna-open-claude-with-layout)
;;; adna-open-claude-with-layout.el ends here
