;;; config.el --- spacemacs-latticeprotocol distribution layer configuration  -*- lexical-binding: t -*-
;;
;; Author:  LatticeProtocol / Daedalus (Spacemacs.aDNA)
;; License: GPL-3.0
;;
;; Branding overrides applied via setq — no core file patching (ADR-024).
;; All LP-specific setq calls go here; upstream Spacemacs core files are never modified.

;;; LP Version (P4-04 — ADR-027)

(defconst latticeprotocol-version "0.1.0"
  "LatticeProtocol distribution version string.")

;;; LP Branding Strings (P4-04 — ADR-027)
;; Applied after Spacemacs core loads; overrides take effect on next startup buffer render.

(setq spacemacs-buffer-logo-title "[L A T T I C E   P R O T O C O L]")
(setq spacemacs-buffer-name "*spacelattice*")

;;; LP Repository Constants (P4-04 — ADR-027)
;; Used by Spacemacs update-check to point at the LP distribution rather than upstream.

(setq spacemacs-repository "spacelattice"
      spacemacs-repository-owner "LatticeProtocol"
      spacemacs-checkversion-branch "lp-stable")

;;; LP Banner (P4-05 — ADR-028)
;; Points to the deployed ASCII banner (safe default — works in all terminals).
;; To use the PNG image banner, run the SVG→PNG derivation step in spacelattice_assets.md
;; and override dotspacemacs-startup-banner in what/local/operator.private.el instead.

(setq dotspacemacs-startup-banner
      (expand-file-name
       "private/layers/spacemacs-latticeprotocol/banners/lp-banner-1.txt"
       spacemacs-start-directory))

;;; Modeline format
;; The standard adna layer uses `adna-main' modeline segment format.
;; Override here if LP distribution needs a different segment name.
;; (setq doom-modeline-format 'lp-main)

;;; config.el ends here
