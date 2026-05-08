;;; packages.el --- adna layer  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; URL:     https://github.com/LatticeProtocol/Spacemacs.aDNA
;; License: GPL-3.0
;;
;; Spacemacs layer manifest. Spacemacs loads this file first when activating
;; the layer; declares external packages this layer depends on and provides
;; init functions for each.

(defconst adna-packages
  '(yaml
    (json :location built-in)
    (markdown-mode :location built-in))
  "List of packages required by the adna layer.

`transient' and `vterm' are NOT listed here even though adna code uses them —
they're already declared by spacemacs-bootstrap (transient) and shell (vterm)
layers. Declaring them again would cause init-function ownership warnings
during boot. We post-init markdown-mode (also built into Spacemacs) below.")

(defun adna/init-yaml ()
  "Initialize yaml package for frontmatter parsing."
  (use-package yaml
    :defer t))

(defun adna/init-json ()
  "Json is built-in; nothing to install."
  (require 'json))

(defun adna/post-init-markdown-mode ()
  "Hook into markdown-mode so adna-mode auto-activates on markdown buffers."
  (with-eval-after-load 'markdown-mode
    (add-hook 'markdown-mode-hook 'adna/maybe-activate-mode)))

;;; packages.el ends here
