;;; config.el --- adna layer config  -*- lexical-binding: t -*-
;;
;; Author:  Spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Variables, customization options, minor-mode definition for the adna layer.
;; Loaded by Spacemacs after packages.el and before funcs.el.

;;; ============================================================================
;;; Layer directory (captured at load time for scripts/ auto-discovery)
;;; ============================================================================

(defvar adna--layer-dir
  (when load-file-name (file-name-directory load-file-name))
  "Absolute path to the adna layer directory.
Captured at load time from `load-file-name'. Used by `adna/load-scripts'
to locate the scripts/ subdirectory regardless of install path.")

;;; ============================================================================
;;; Buffer-local frontmatter mirror
;;; ============================================================================

(defvar adna-vault-root nil
  "Absolute path of the nearest *.aDNA/ ancestor directory.
Set per-buffer when adna-mode activates; nil if not inside a vault.")
(make-variable-buffer-local 'adna-vault-root)

(defvar adna-frontmatter-raw nil
  "Parsed YAML frontmatter as alist; nil if buffer has no frontmatter.")
(make-variable-buffer-local 'adna-frontmatter-raw)

(defvar adna-frontmatter-type nil
  "Type field from buffer's YAML frontmatter.")
(make-variable-buffer-local 'adna-frontmatter-type)

(defvar adna-frontmatter-status nil
  "Status field from buffer's YAML frontmatter.")
(make-variable-buffer-local 'adna-frontmatter-status)

(defvar adna-frontmatter-tags nil
  "Tags list from buffer's YAML frontmatter.")
(make-variable-buffer-local 'adna-frontmatter-tags)

(defvar adna-frontmatter-created nil
  "Created date from buffer's YAML frontmatter.")
(make-variable-buffer-local 'adna-frontmatter-created)

(defvar adna-frontmatter-updated nil
  "Updated date from buffer's YAML frontmatter.")
(make-variable-buffer-local 'adna-frontmatter-updated)

(defvar adna-frontmatter-last-edited-by nil
  "Last_edited_by field from buffer's YAML frontmatter.")
(make-variable-buffer-local 'adna-frontmatter-last-edited-by)

;;; ============================================================================
;;; Customization
;;; ============================================================================

(defgroup adna nil
  "Spacemacs.aDNA configuration group."
  :group 'tools
  :prefix "adna-")

(defcustom adna-vault-search-paths '("~/lattice/")
  "Where to look for aDNA vaults when resolving cross-vault wikilinks."
  :type '(repeat directory)
  :group 'adna)

(defcustom adna-claude-code-command "claude"
  "Command spawned by SPC c c. Override in operator.private.el if needed."
  :type 'string
  :group 'adna)

(defcustom adna-obsidian-roundtrip-enabled nil
  "If non-nil, poll .obsidian/workspace.json for active-file changes.
Off by default; opt-in via what/local/operator.private.el."
  :type 'boolean
  :group 'adna)

(defcustom adna-obsidian-vault-override nil
  "Override the vault name passed to Obsidian Advanced URI plugin.
Default behavior derives the vault name from the directory name."
  :type '(choice (const nil) string)
  :group 'adna)

(defcustom adna-prefer-local nil
  "If non-nil, prefer local LLM over Claude API for in-Emacs LLM calls."
  :type 'boolean
  :group 'adna)

(defcustom adna-log-llm-calls nil
  "If non-nil, log every in-Emacs LLM call to *Messages*."
  :type 'boolean
  :group 'adna)

(defcustom adna-build-graph-script "what/standard/index/build_graph.py"
  "Path (relative to vault root) of the Python CLI fallback for context graph."
  :type 'string
  :group 'adna)

;;; ============================================================================
;;; Minor mode
;;; ============================================================================

(define-minor-mode adna-mode
  "Minor mode for buffers inside an *.aDNA/ ancestor directory.

When active:
- `adna-vault-root' is set to the nearest *.aDNA/ ancestor.
- Buffer-local variables `adna-frontmatter-*' carry parsed YAML frontmatter.
- The mode-line shows ` aDNA'."
  :init-value nil
  :lighter " aDNA"
  :group 'adna)

;;; ============================================================================
;;; Scripts auto-discovery hook (ADR-038)
;;; ============================================================================

;; `adna/load-scripts' is defined in funcs.el (loaded after config.el).
;; Schedule it to run after the full Spacemacs user-config phase so all layers
;; and packages are available when scripts register their SPC a x sub-commands.
(add-hook 'spacemacs-post-user-config-hook
          (lambda ()
            (when (fboundp 'adna/load-scripts)
              (adna/load-scripts))))

;;; config.el ends here
