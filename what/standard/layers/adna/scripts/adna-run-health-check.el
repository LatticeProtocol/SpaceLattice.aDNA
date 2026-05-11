;;; adna-run-health-check.el --- run skill_health_check from inside Emacs  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Part of the adna layer scripts/ auto-discovery system (ADR-038).
;; Bound to SPC a x h.

(defun adna/run-health-check ()
  "Run skill_health_check checks A-I in a vterm/eshell terminal window.
Opens a terminal at the vault root and runs validate_layers.py + batch checks."
  (interactive)
  (let* ((root (condition-case _ (adna/vault-root) (error nil))))
    (unless root
      (user-error "Not inside an *.aDNA/ vault"))
    (let* ((validate-script (expand-file-name "what/standard/index/validate_layers.py" root))
           (cmd (if (file-exists-p validate-script)
                    (format "cd %s && python3 %s\n"
                            (shell-quote-argument root)
                            (shell-quote-argument
                             (file-relative-name validate-script root)))
                  (format "cd %s && echo 'validate_layers.py not found'\n"
                          (shell-quote-argument root)))))
      (cond
       ((fboundp 'vterm)
        (let ((vterm-buffer-name "*adna:health-check*"))
          (vterm-other-window)
          (vterm-send-string cmd)))
       ((fboundp 'eat)
        (eat cmd))
       (t
        (eshell)
        (insert cmd)
        (eshell-send-input))))))

(when (fboundp 'spacemacs/set-leader-keys)
  (spacemacs/declare-prefix "axh" "health-check")
  (spacemacs/set-leader-keys "axh" #'adna/run-health-check))

(provide 'adna-run-health-check)
;;; adna-run-health-check.el ends here
