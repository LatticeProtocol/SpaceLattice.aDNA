;;; config.el --- claude-code-ide layer configuration  -*- lexical-binding: t -*-
;;
;; Layer-level configuration variables. Operators can override any of these
;; in what/local/operator.private.el (loaded after this layer).

;; Custom system prompt for this vault's sessions.
;; Identifies the agent as operating within the Spacemacs.aDNA / LatticeProtocol context.
;; Operators can override in operator.private.el:
;;   (setq claude-code-ide-system-prompt "Your custom prompt here.")
(defvar claude-code-ide-adna-system-prompt
  "You are operating within a Spacemacs.aDNA agentic IDE environment. \
The vault's CLAUDE.md, STATE.md, and context graph (what/standard/index/graph.json) \
describe the project's governance, current phase, and available capabilities. \
You have access to Emacs buffer context, diagnostics, LSP references, and tree-sitter \
analysis via MCP tools."
  "Default system prompt for Spacemacs.aDNA sessions.
Set `claude-code-ide-system-prompt' to this value in user-config.")

;;; config.el ends here
