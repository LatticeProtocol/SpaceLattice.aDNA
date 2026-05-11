;;; adna-show-sitrep.el --- open STATE.md + active session side-by-side  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Part of the adna layer scripts/ auto-discovery system (ADR-038).
;; Bound to SPC a x s.

(defun adna/show-sitrep ()
  "Open STATE.md and most recent active session file side-by-side.
Useful for starting a session: see current operational state + last handoff."
  (interactive)
  (let* ((root (condition-case _ (adna/vault-root) (error nil)))
         (state (and root (expand-file-name "STATE.md" root)))
         (active-dir (and root (expand-file-name "how/sessions/active/" root)))
         (sessions (and active-dir
                        (file-directory-p active-dir)
                        (directory-files active-dir t "\\.md$")))
         (session (and sessions (car (sort sessions #'string>)))))
    (cond
     ((null root)
      (user-error "Not inside an *.aDNA/ vault"))
     ((not (file-readable-p state))
      (user-error "STATE.md not found at %s" state))
     (t
      (find-file state)
      (when session
        (split-window-right)
        (other-window 1)
        (find-file session))))))

(when (fboundp 'spacemacs/set-leader-keys)
  (spacemacs/declare-prefix "axs" "sitrep")
  (spacemacs/set-leader-keys "axs" #'adna/show-sitrep))

(provide 'adna-show-sitrep)
;;; adna-show-sitrep.el ends here
