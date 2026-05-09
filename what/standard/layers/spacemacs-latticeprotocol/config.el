;;; config.el --- spacemacs-latticeprotocol distribution layer configuration  -*- lexical-binding: t -*-
;;
;; Author:  LatticeProtocol / Daedalus (Spacemacs.aDNA)
;; License: GPL-3.0
;;
;; Branding overrides applied via setq — no core file patching (ADR-024).
;; All LP-specific setq calls go here; upstream Spacemacs core files are never modified.

;;; Version

(defconst latticeprotocol-version "0.1.0-alpha"
  "LatticeProtocol distribution version string.")

;;; Startup buffer branding
;; Uncomment and set when LP custom branding is ready (P4-04).
;;
;; (setq spacemacs-buffer-logo-title "SpaceLattice")
;; (setq spacemacs-buffer-name "*SpaceLattice*")

;;; Modeline format
;; The standard adna layer uses `adna-main' modeline segment format.
;; Override here if LP distribution needs a different segment name.
;; (setq doom-modeline-format 'lp-main)

;;; config.el ends here
