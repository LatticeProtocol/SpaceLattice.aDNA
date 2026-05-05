;;; keybindings.el --- adna layer keybindings  -*- lexical-binding: t -*-
;;
;; Author:  SpaceLattice.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Spacemacs leader keybindings for the adna layer. Loaded last (after
;; packages.el, config.el, funcs.el).

;; SPC a — aDNA navigation prefix
(spacemacs/declare-prefix "a" "adna")

(spacemacs/set-leader-keys
  ;; Triad navigation
  "am" 'adna/open-manifest
  "ac" 'adna/open-claude
  "as" 'adna/open-state
  "ar" 'adna/jump-triad-root
  ;; Skills + graph
  "ak" 'adna/run-nearest-skill
  "ag" 'adna/render-lattice-graph
  "ai" 'adna-index-project
  ;; Sessions
  "an" 'adna/capture-session-note
  ;; Wikilinks + Obsidian
  "aw" 'adna/follow-wikilink
  "ao" 'adna/open-in-obsidian
  ;; Health-check (manual invocation)
  "ah" 'adna/health-check)

;; SPC c c — spawn Claude Code at nearest aDNA root
;; (declare-prefix is no-op if `c' already declared by another layer)
(spacemacs/declare-prefix "c" "claude")
(spacemacs/set-leader-keys "cc" 'adna/spawn-claude-code)

;;; keybindings.el ends here
