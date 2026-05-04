;;; funcs.el --- adna layer functions  -*- lexical-binding: t -*-
;;
;; Author:  spacemacs.aDNA / Daedalus
;; License: GPL-3.0
;;
;; Interactive commands and helpers for the adna layer. Loaded after config.el.

(eval-when-compile (require 'cl-lib))
(require 'json)

;;; ============================================================================
;;; Vault detection
;;; ============================================================================

(defun adna/find-vault-root (&optional dir)
  "Return absolute path of nearest *.aDNA/ ancestor of DIR, or nil.
DIR defaults to `default-directory'."
  (let* ((dir (file-name-as-directory (expand-file-name (or dir default-directory))))
         (parent (file-name-directory (directory-file-name dir))))
    (cond
     ((string-match-p "\\.aDNA/?$" (directory-file-name dir)) dir)
     ((or (null parent) (equal dir parent)) nil)
     (t (adna/find-vault-root parent)))))

(defun adna/maybe-activate-mode ()
  "Activate adna-mode if current buffer is inside a *.aDNA/ vault."
  (when buffer-file-name
    (let ((root (adna/find-vault-root (file-name-directory buffer-file-name))))
      (when root
        (setq-local adna-vault-root root)
        (adna-mode 1)
        (when (string-match-p "\\.\\(md\\|org\\|yaml\\|yml\\)\\'" buffer-file-name)
          (adna/parse-frontmatter))))))

(defun adna/setup-global-hooks ()
  "Install the find-file-hook so adna-mode auto-activates inside vaults.
Called from dotspacemacs/user-config in ~/.spacemacs."
  (add-hook 'find-file-hook #'adna/maybe-activate-mode))

;;; ============================================================================
;;; Frontmatter parsing
;;; ============================================================================

(defun adna/parse-frontmatter ()
  "Parse YAML frontmatter at start of current buffer; populate buffer-locals."
  (save-excursion
    (goto-char (point-min))
    (when (looking-at "^---\n")
      (let* ((fm-start (match-end 0))
             (fm-end (and (re-search-forward "^---\n" nil t) (match-beginning 0))))
        (when fm-end
          (let* ((yaml-str (buffer-substring-no-properties fm-start fm-end))
                 (data (when (fboundp 'yaml-parse-string)
                         (condition-case _err
                             (yaml-parse-string yaml-str :object-type 'alist)
                           (error nil)))))
            (when data
              (setq-local adna-frontmatter-raw data)
              (setq-local adna-frontmatter-type
                          (cdr (assq 'type data)))
              (setq-local adna-frontmatter-status
                          (cdr (assq 'status data)))
              (setq-local adna-frontmatter-tags
                          (cdr (assq 'tags data)))
              (setq-local adna-frontmatter-created
                          (cdr (assq 'created data)))
              (setq-local adna-frontmatter-updated
                          (cdr (assq 'updated data)))
              (setq-local adna-frontmatter-last-edited-by
                          (cdr (assq 'last_edited_by data))))))))))

;;; ============================================================================
;;; Triad navigation
;;; ============================================================================

(defun adna/--root-or-error ()
  "Return current vault root or signal an error."
  (or adna-vault-root
      (adna/find-vault-root)
      (user-error "Not inside an *.aDNA/ vault")))

(defun adna/open-manifest ()
  "Open MANIFEST.md of nearest aDNA vault."
  (interactive)
  (find-file (expand-file-name "MANIFEST.md" (adna/--root-or-error))))

(defun adna/open-claude ()
  "Open CLAUDE.md of nearest aDNA vault."
  (interactive)
  (find-file (expand-file-name "CLAUDE.md" (adna/--root-or-error))))

(defun adna/open-state ()
  "Open STATE.md of nearest aDNA vault."
  (interactive)
  (find-file (expand-file-name "STATE.md" (adna/--root-or-error))))

(defun adna/jump-triad-root ()
  "Cycle between who/, what/, how/ of the current vault.
If buffer is not inside a triad leg, jump to what/."
  (interactive)
  (let* ((root (adna/--root-or-error))
         (current (cond
                   ((null buffer-file-name) "what")
                   ((string-match-p "/who/" buffer-file-name) "what")
                   ((string-match-p "/what/" buffer-file-name) "how")
                   ((string-match-p "/how/" buffer-file-name) "who")
                   (t "what"))))
    (find-file (expand-file-name current root))))

;;; ============================================================================
;;; Skill execution
;;; ============================================================================

(defun adna/run-nearest-skill ()
  "Find skills under how/standard/skills/ and how/skills/, present picker."
  (interactive)
  (let* ((root (adna/--root-or-error))
         (dirs (cl-loop for sub in '("how/standard/skills" "how/skills")
                        for full = (expand-file-name sub root)
                        when (file-directory-p full)
                        collect full))
         (skills (cl-loop for d in dirs
                          append (directory-files d t "^skill_.*\\.md$"))))
    (if (null skills)
        (user-error "No skills found under how/standard/skills/ or how/skills/")
      (let* ((choice (completing-read "Skill: " (mapcar #'file-name-base skills) nil t)))
        (find-file (cl-find-if (lambda (f) (string= (file-name-base f) choice)) skills))))))

;;; ============================================================================
;;; Lattice graph
;;; ============================================================================

(defun adna/render-lattice-graph ()
  "Open what/standard/index/graph.json in current frame."
  (interactive)
  (let* ((root (adna/--root-or-error))
         (graph-file (expand-file-name "what/standard/index/graph.json" root)))
    (if (file-exists-p graph-file)
        (find-file graph-file)
      (when (yes-or-no-p "graph.json missing — generate now? ")
        (adna-index-project)))))

(defun adna-index-project ()
  "Build context graph for current vault. Calls Python CLI fallback."
  (interactive)
  (let* ((root (adna/--root-or-error))
         (script (expand-file-name adna-build-graph-script root))
         (output (expand-file-name "what/standard/index/graph.json" root))
         (default-directory root))
    (unless (file-exists-p script)
      (user-error "build_graph.py not found at %s" script))
    (let* ((cmd (format "python3 %s --vault %s --output %s"
                        (shell-quote-argument script)
                        (shell-quote-argument root)
                        (shell-quote-argument output)))
           (result (shell-command-to-string cmd)))
      (message "%s" (string-trim result))
      (when (file-exists-p output)
        (message "graph.json updated: %s" output)))))

;;; ============================================================================
;;; Session capture
;;; ============================================================================

(defun adna/capture-session-note ()
  "Create a new session file in how/sessions/active/ from template."
  (interactive)
  (let* ((root (adna/--root-or-error))
         (template (expand-file-name "how/templates/template_session.md" root))
         (active-dir (expand-file-name "how/sessions/active" root))
         (timestamp (format-time-string "%Y%m%dT%H%M"))
         (slug (read-string "Session slug (lowercase_underscore): "))
         (name (format "session_%s_%s.md" timestamp slug))
         (target (expand-file-name name active-dir)))
    (unless (file-exists-p template)
      (user-error "Template missing: %s" template))
    (make-directory active-dir t)
    (copy-file template target nil)
    (find-file target)))

;;; ============================================================================
;;; Wikilink follow
;;; ============================================================================

(defun adna/wikilink-at-point ()
  "Return the [[Target]] text at point, or nil."
  (save-excursion
    (let ((line-start (line-beginning-position))
          (line-end (line-end-position)))
      (goto-char line-start)
      (cl-loop while (re-search-forward "\\[\\[\\([^]]+\\)\\]\\]" line-end t)
               for start = (match-beginning 0)
               for end = (match-end 0)
               for orig (point)
               when (and (<= start orig) (>= end orig))
               return (match-string-no-properties 1)))))

(defun adna/wikilink-resolve (target)
  "Resolve TARGET wikilink to absolute path within current vault, or nil."
  (let* ((root (adna/--root-or-error))
         (with-ext (if (string-match-p "\\.[a-zA-Z0-9]+\\'" target)
                       target
                     (concat target ".md"))))
    (cond
     ((file-exists-p (expand-file-name with-ext root))
      (expand-file-name with-ext root))
     ((and buffer-file-name
           (file-exists-p (expand-file-name with-ext (file-name-directory buffer-file-name))))
      (expand-file-name with-ext (file-name-directory buffer-file-name)))
     (t
      (let ((found (directory-files-recursively
                    root
                    (concat "\\`" (regexp-quote (file-name-nondirectory with-ext)) "\\'"))))
        (when found (car found)))))))

(defun adna/follow-wikilink ()
  "Follow [[Target]] wikilink at point."
  (interactive)
  (let* ((target (adna/wikilink-at-point)))
    (cond
     ((null target)
      (message "No wikilink at point."))
     (t
      (let ((path (adna/wikilink-resolve target)))
        (if (and path (file-exists-p path))
            (find-file path)
          (message "Wikilink target not found: %s" target)))))))

;;; ============================================================================
;;; Obsidian round-trip
;;; ============================================================================

(defun adna/open-in-obsidian ()
  "Open current file in Obsidian via Advanced URI plugin (if installed)."
  (interactive)
  (unless buffer-file-name
    (user-error "Buffer has no file."))
  (let* ((root (adna/--root-or-error))
         (relpath (file-relative-name buffer-file-name root))
         (vault-name (or adna-obsidian-vault-override
                         (file-name-nondirectory (directory-file-name root))))
         (uri (format "obsidian://adv-uri?vault=%s&filepath=%s"
                      (url-hexify-string vault-name)
                      (url-hexify-string relpath))))
    (browse-url uri)))

;;; ============================================================================
;;; Claude Code (SPC c c)
;;; ============================================================================

(defun adna/spawn-claude-code ()
  "Spawn Claude Code in vterm/eshell at the nearest aDNA root."
  (interactive)
  (let* ((root (adna/--root-or-error))
         (vault-name (file-name-nondirectory (directory-file-name root)))
         (default-directory root))
    (cond
     ((fboundp 'vterm)
      (let ((vterm-buffer-name (format "*claude:%s*" vault-name)))
        (vterm)
        (vterm-send-string adna-claude-code-command)
        (vterm-send-return)))
     (t
      (eshell)
      (insert (format "cd %s && %s"
                      (shell-quote-argument root)
                      adna-claude-code-command))
      (eshell-send-input)))))

;;; ============================================================================
;;; Health check (called by skill_health_check check E)
;;; ============================================================================

(defun adna/health-check ()
  "Self-test the adna layer. Returns t on success, prints to *Messages*.
Used by skill_health_check Check E. In batch mode, exits 0/non-0."
  (interactive)
  (let ((failures '()))
    ;; Required functions defined
    (dolist (fn '(adna/find-vault-root
                  adna/parse-frontmatter
                  adna/open-manifest
                  adna/jump-triad-root
                  adna/follow-wikilink
                  adna/spawn-claude-code
                  adna-index-project))
      (unless (fboundp fn)
        (push (format "fbound-fail: %s" fn) failures)))
    ;; Required vars defined
    (dolist (v '(adna-vault-root
                 adna-frontmatter-raw
                 adna-claude-code-command))
      (unless (boundp v)
        (push (format "bound-fail: %s" v) failures)))
    ;; Minor mode
    (unless (fboundp 'adna-mode)
      (push "adna-mode minor mode not defined" failures))
    (cond
     (failures
      (message "adna/health-check: FAIL — %s" (mapconcat #'identity failures "; "))
      (when noninteractive (kill-emacs 50))
      nil)
     (t
      (message "adna/health-check: OK")
      t))))

;;; funcs.el ends here
