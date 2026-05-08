;;; keybindings.el --- claude-code-ide layer keybindings  -*- lexical-binding: t -*-
;;
;; SPC c — Claude Code prefix (established by ADR-013, extended here per ADR-019).
;;
;; All bindings live under SPC c to group Claude Code commands together.
;; The SPC a prefix remains owned by the adna layer.

(with-eval-after-load 'claude-code-ide
  (spacemacs/declare-prefix "c" "claude-code")
  (spacemacs/declare-prefix "cc" "menu")

  (spacemacs/set-leader-keys
    ;; Primary entry point — transient menu showing all Claude Code commands
    "cc"  #'claude-code-ide-menu

    ;; Session management
    "cs"  #'claude-code-ide           ; Start session for current project
    "ct"  #'claude-code-ide-toggle    ; Toggle Claude window (show/hide)
    "cp"  #'claude-code-ide-send-prompt ; Send prompt from minibuffer
    "cl"  #'claude-code-ide-list-sessions ; List/switch active sessions
    "cr"  #'claude-code-ide-resume    ; Resume previous conversation
    "cn"  #'claude-code-ide-continue  ; Continue most recent conversation
    ))

;;; keybindings.el ends here
