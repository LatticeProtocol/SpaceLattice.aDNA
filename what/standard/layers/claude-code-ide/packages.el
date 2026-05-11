;;; packages.el --- claude-code-ide layer  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; URL:     https://github.com/LatticeProtocol/Spacemacs.aDNA
;; License: GPL-3.0
;;
;; Wraps claude-code-ide.el — MCP bridge between Claude Code CLI and Emacs.
;; Provides buffer/selection/diagnostic/tree-sitter context to Claude Code
;; sessions. See ADR-019 for the layer decision rationale.

(defconst claude-code-ide-packages
  '((claude-code-ide :location (recipe
                                :fetcher github
                                :repo "manzaltu/claude-code-ide.el"
                                :branch "main"))
    eat)
  "Packages required by the claude-code-ide layer.

`vterm' is NOT listed here — it is already declared by the `shell' layer.
`eat' provides the preferred terminal backend (anti-flicker, better color).
`claude-code-ide' is installed directly from GitHub via package-vc.")

(defun claude-code-ide/init-claude-code-ide ()
  "Initialize claude-code-ide with Spacemacs-native configuration."
  (use-package claude-code-ide
    :defer t
    :commands (claude-code-ide
               claude-code-ide-menu
               claude-code-ide-toggle
               claude-code-ide-send-prompt
               claude-code-ide-list-sessions
               claude-code-ide-resume
               claude-code-ide-continue)
    :init
    ;; Window placement: right side, 80 cols, don't steal focus on open.
    ;; 80 cols leaves adequate edit area when treemacs (≈35 cols) is also open.
    ;; Window contract: treemacs far-left | edit center | Claude right (ADR-036).
    (setq claude-code-ide-window-side 'right
          claude-code-ide-window-width 80
          claude-code-ide-focus-on-open nil)
    ;; Use eat backend for anti-flicker and proper color rendering.
    (setq claude-code-ide-terminal-backend 'eat)
    ;; Flycheck for diagnostics (already standard layer).
    (setq claude-code-ide-diagnostics-backend 'flycheck)
    :config
    ;; Register built-in MCP tools: xref, imenu, tree-sitter, project info.
    (claude-code-ide-emacs-tools-setup)))

(defun claude-code-ide/init-eat ()
  "Initialize eat terminal emulator — preferred backend for claude-code-ide."
  (use-package eat
    :defer t))

;;; packages.el ends here
