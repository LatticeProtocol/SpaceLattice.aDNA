;;; packages.el --- spacemacs-latticeprotocol distribution layer packages  -*- lexical-binding: t -*-
;;
;; Author:  LatticeProtocol / Daedalus (Spacemacs.aDNA)
;; License: GPL-3.0

(defconst spacemacs-latticeprotocol-packages
  '((latticeprotocol-theme :location local))
  "Packages owned by the spacemacs-latticeprotocol distribution layer.
The theme is declared as a local package; its source lives at
`what/standard/layers/+themes/latticeprotocol-theme/local/latticeprotocol-theme/'.
`skill_install' symlinks it into ~/.emacs.d/private/layers/latticeprotocol-theme/.")

(defun spacemacs-latticeprotocol/init-latticeprotocol-theme ()
  "Initialize the LatticeProtocol theme package.
Populated by mission P4-03 when theme files are authored."
  ;; Theme files populated in P4-03.
  )

;;; packages.el ends here
