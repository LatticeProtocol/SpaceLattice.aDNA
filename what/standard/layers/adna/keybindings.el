;;; keybindings.el --- adna layer keybindings  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Transient-based leader keybindings for the adna layer. Loaded last
;; (after packages.el, config.el, funcs.el). Requires transient (Emacs 28+
;; built-in; also available as a package on Emacs 27).

(require 'transient)

;; ── aDNA vault menu (SPC a) ────────────────────────────────────────────────

(transient-define-prefix adna/menu ()
  "⬡ Spacemacs — aDNA Vault Navigation"
  [["Navigate"
    ("m" "Manifest"      adna/open-manifest)
    ("c" "CLAUDE.md"     adna/open-claude)
    ("s" "STATE.md"      adna/open-state)
    ("r" "Triad root"    adna/jump-triad-root)]
   ["Skills & Graph"
    ("k" "Run skill"     adna/run-nearest-skill)
    ("i" "Index vault"   adna-index-project)
    ("g" "Graph JSON"    adna/render-lattice-graph)
    ("h" "Health check"  adna/health-check)]
   ["Links & Sessions"
    ("w" "Follow wikilink"  adna/follow-wikilink)
    ("n" "Session note"     adna/capture-session-note)
    ("o" "Obsidian"         adna/open-in-obsidian)]
   ["LP & Claude →"
    ("l" "Lattice Protocol" adna/lp-menu)
    ("," "Claude Code"      adna/claude-menu)
    ("x" "Agent extensions" adna/extensions-menu)]])

;; ── Lattice Protocol sub-menu (SPC a l / SPC o l) ─────────────────────────

(transient-define-prefix adna/lp-menu ()
  "⬡ Lattice Protocol — Commands"
  [["Run"
    ("r" "Run lattice"       adna/lp-run-lattice)
    ("j" "Job status"        adna/lp-job-status)]
   ["Publish & Index"
    ("p" "Publish lattice"   adna/lp-publish)
    ("f" "Federation graph"  adna/lp-federation-graph)]
   ["Browse"
    ("m" "Marketplace"       adna/lp-open-marketplace)]
   [""
    ("<" "← Back"            adna/menu)]])

;; ── Claude Code sub-menu (SPC a , / SPC c c) ──────────────────────────────

(transient-define-prefix adna/claude-menu ()
  "◆ Claude Code — Agentic Interface"
  [["Launch"
    ("c" "Interactive"    adna/spawn-claude-code)
    ("p" "Plan mode"      adna/spawn-claude-plan)
    ("l" "Loop mode"      adna/spawn-claude-loop)]
   ["Review"
    ("r" "Review file"    adna/spawn-claude-review)]
   [""
    ("<" "← Back"         adna/menu)]])

;; ── Agent extensions sub-menu (SPC a x) ──────────────────────────────────

(transient-define-prefix adna/extensions-menu ()
  "SPC a x — Agent-authored extensions. Add entries via what/local/operator.private.el."
  ["Agent Extensions"
   ("?" "No extensions registered — see agent_command_tree.md" ignore)])

;; ── Leader key wiring ─────────────────────────────────────────────────────

;; SPC a → aDNA Transient root menu
(spacemacs/declare-prefix "a" "adna")
(spacemacs/set-leader-keys "a" #'adna/menu)

;; SPC o l → LP sub-menu (standalone entry point)
(spacemacs/declare-prefix "ol" "lattice-protocol")
(spacemacs/set-leader-keys "ol" #'adna/lp-menu)

;; SPC c c → Claude Code sub-menu
;; declare-prefix is no-op if 'c' already claimed by another layer
(spacemacs/declare-prefix "c" "claude")
(spacemacs/set-leader-keys "cc" #'adna/claude-menu)

;; SPC a x → agent-extensible sub-menu stub
(spacemacs/declare-prefix "ax" "agent-extensions")
(spacemacs/set-leader-keys "ax" #'adna/extensions-menu)

;;; keybindings.el ends here
