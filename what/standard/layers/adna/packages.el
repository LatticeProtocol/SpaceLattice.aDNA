;;; packages.el --- adna layer  -*- lexical-binding: t -*-
;;
;; Author:  spacemacs.aDNA / Daedalus
;; URL:     https://github.com/LatticeProtocol/spacemacs.aDNA
;; License: GPL-3.0
;;
;; Spacemacs layer manifest. Spacemacs loads this file first when activating
;; the layer; declares external packages this layer depends on and provides
;; init functions for each.

(defconst adna-packages
  '(yaml
    transient
    vterm
    json
    (markdown-mode :location built-in))
  "List of packages required by the adna layer.")

(defun adna/init-yaml ()
  "Initialize yaml package for frontmatter parsing."
  (use-package yaml
    :defer t))

(defun adna/init-transient ()
  "Initialize transient package for SPC a menu."
  (use-package transient
    :defer t))

(defun adna/init-vterm ()
  "Initialize vterm for SPC c c Claude Code spawn."
  (use-package vterm
    :defer t
    :commands vterm))

(defun adna/init-json ()
  "Json is built-in; nothing to install."
  (require 'json))

(defun adna/post-init-markdown-mode ()
  "Hook into markdown-mode so adna-mode auto-activates on markdown buffers."
  (with-eval-after-load 'markdown-mode
    (add-hook 'markdown-mode-hook 'adna/maybe-activate-mode)))

;;; packages.el ends here
