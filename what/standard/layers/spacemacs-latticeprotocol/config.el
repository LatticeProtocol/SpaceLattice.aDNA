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

;;; LP Banner (ADR-029)
;; Official Spacemacs banner retained as distribution default.
;; LP ASCII assets (lp-banner-{1..4}.txt, latticeprotocol.svg) live in
;; what/standard/layers/spacemacs-latticeprotocol/banners/ — available for
;; operator override in what/local/operator.private.el when desired.

(setq dotspacemacs-startup-banner 'official)

;;; LP News + Welcome (P4-06 — ADR-030)
;; Point the startup buffer note to LP release notes instead of upstream Spacemacs news.
;; Stub at what/docs/lp_release_notes_v1_0.org; final content authored at P5-03.

(with-eval-after-load 'spacemacs-buffer
  (setq spacemacs-buffer-note-file
        (expand-file-name "what/docs/lp_release_notes_v1_0.org"
                          dotspacemacs-directory)))

;;; Modeline format
;; The standard adna layer uses `adna-main' modeline segment format.
;; Override here if LP distribution needs a different segment name.
;; (setq doom-modeline-format 'lp-main)

;;; config.el ends here
