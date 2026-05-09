;;; packages.el --- latticeprotocol-theme layer packages  -*- lexical-binding: t -*-
;;
;; Author:  LatticeProtocol / Daedalus (Spacemacs.aDNA)
;; License: GPL-3.0

(defconst latticeprotocol-theme-packages
  '((latticeprotocol-theme :location local))
  "Packages owned by the latticeprotocol-theme layer.
The theme source lives in `local/latticeprotocol-theme/' — authored in P4-03.")

(defun latticeprotocol-theme/init-latticeprotocol-theme ()
  "Initialize LatticeProtocol theme — register load path for local theme files."
  (add-to-list 'custom-theme-load-path
               (expand-file-name "local/latticeprotocol-theme"
                                 (file-name-directory load-file-name))))

;;; packages.el ends here
