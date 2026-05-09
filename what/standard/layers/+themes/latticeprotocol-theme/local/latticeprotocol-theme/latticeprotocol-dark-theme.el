;;; latticeprotocol-dark-theme.el --- LatticeProtocol dark theme  -*- lexical-binding: t -*-
;;
;; Derived from spacemacs-dark. Two LP tweaks:
;;   bg:     #1e2029 (cooler blue-black vs. spacemacs-dark #292b2e)
;;   accent: #5b9bd5 (more saturated blue vs. spacemacs-dark #4f97d7)
;;
;; Author:  LatticeProtocol / Daedalus (Spacemacs.aDNA)
;; License: GPL-3.0

(deftheme latticeprotocol-dark "LatticeProtocol dark theme (spacemacs-dark derivative).")

(let* (;; LP palette — dark
       (lp-bg           "#1e2029")   ; LP tweak: cooler blue-black
       (lp-bg-alt       "#1a1b22")
       (lp-bg-hl        "#2d2e3a")
       (lp-fg           "#b2b2b2")
       (lp-fg-dark      "#9a9ab0")
       (lp-cursor       "#e3dedd")
       (lp-selection    "#2d3040")
       (lp-border       "#3c3c4a")
       ;; syntax
       (lp-comment      "#2aa1ae")
       (lp-keyword      "#5b9bd5")   ; LP tweak: more saturated
       (lp-type         "#ce537a")
       (lp-const        "#a45bad")
       (lp-func         "#bc6ec5")
       (lp-string       "#2d9574")
       (lp-variable     "#7590db")
       (lp-warning      "#dc752f")
       (lp-error        "#e0211d")
       (lp-success      "#42ae2c")
       ;; mode line
       (lp-ml-bg        "#221f2b")
       (lp-ml-bg-in     "#292b2e")
       (lp-ml-fg        "#b2b2b2")
       (lp-ml-fg-in     "#5d4d7a"))

  (custom-theme-set-faces
   'latticeprotocol-dark

   ;; --- Core UI ---
   `(default                        ((t (:background ,lp-bg :foreground ,lp-fg))))
   `(cursor                         ((t (:background ,lp-cursor))))
   `(region                         ((t (:background ,lp-selection))))
   `(highlight                      ((t (:background ,lp-bg-hl))))
   `(secondary-selection            ((t (:background ,lp-bg-hl))))
   `(hl-line                        ((t (:background ,lp-bg-hl))))
   `(fringe                         ((t (:background ,lp-bg :foreground ,lp-fg-dark))))
   `(vertical-border                ((t (:foreground ,lp-border))))
   `(minibuffer-prompt              ((t (:foreground ,lp-keyword :weight bold))))
   `(trailing-whitespace            ((t (:background ,lp-error))))
   `(link                           ((t (:foreground ,lp-keyword :underline t))))
   `(link-visited                   ((t (:foreground ,lp-const :underline t))))

   ;; --- Mode line ---
   `(mode-line                      ((t (:background ,lp-ml-bg :foreground ,lp-ml-fg
                                         :box (:line-width 1 :color ,lp-border)))))
   `(mode-line-inactive             ((t (:background ,lp-ml-bg-in :foreground ,lp-ml-fg-in
                                         :box (:line-width 1 :color ,lp-border)))))
   `(mode-line-buffer-id            ((t (:foreground ,lp-keyword :weight bold))))
   `(mode-line-emphasis             ((t (:foreground ,lp-fg :weight bold))))
   `(mode-line-highlight            ((t (:background ,lp-bg-hl))))

   ;; --- Line numbers ---
   `(line-number                    ((t (:background ,lp-bg :foreground ,lp-border))))
   `(line-number-current-line       ((t (:background ,lp-bg-hl :foreground ,lp-fg :weight bold))))

   ;; --- Search ---
   `(isearch                        ((t (:background ,lp-keyword :foreground ,lp-bg :weight bold))))
   `(isearch-fail                   ((t (:background ,lp-error :foreground ,lp-bg))))
   `(lazy-highlight                 ((t (:background ,lp-selection :foreground ,lp-fg))))

   ;; --- Font lock ---
   `(font-lock-comment-face         ((t (:foreground ,lp-comment :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,lp-comment :slant italic))))
   `(font-lock-doc-face             ((t (:foreground ,lp-comment))))
   `(font-lock-string-face          ((t (:foreground ,lp-string))))
   `(font-lock-keyword-face         ((t (:foreground ,lp-keyword :weight bold))))
   `(font-lock-builtin-face         ((t (:foreground ,lp-keyword))))
   `(font-lock-function-name-face   ((t (:foreground ,lp-func))))
   `(font-lock-variable-name-face   ((t (:foreground ,lp-variable))))
   `(font-lock-type-face            ((t (:foreground ,lp-type))))
   `(font-lock-constant-face        ((t (:foreground ,lp-const))))
   `(font-lock-preprocessor-face    ((t (:foreground ,lp-func))))
   `(font-lock-negation-char-face   ((t (:foreground ,lp-error))))
   `(font-lock-warning-face         ((t (:foreground ,lp-warning :weight bold))))

   ;; --- Errors / warnings ---
   `(error                          ((t (:foreground ,lp-error :weight bold))))
   `(warning                        ((t (:foreground ,lp-warning :weight bold))))
   `(success                        ((t (:foreground ,lp-success :weight bold))))

   ;; --- Parentheses ---
   `(show-paren-match               ((t (:background ,lp-keyword :foreground ,lp-bg :weight bold))))
   `(show-paren-mismatch            ((t (:background ,lp-error :foreground ,lp-bg))))

   ;; --- Org-mode ---
   `(org-level-1                    ((t (:foreground ,lp-keyword :weight bold :height 1.1))))
   `(org-level-2                    ((t (:foreground ,lp-func :weight bold))))
   `(org-level-3                    ((t (:foreground ,lp-variable :weight bold))))
   `(org-level-4                    ((t (:foreground ,lp-type))))
   `(org-level-5                    ((t (:foreground ,lp-const))))
   `(org-level-6                    ((t (:foreground ,lp-string))))
   `(org-level-7                    ((t (:foreground ,lp-warning))))
   `(org-level-8                    ((t (:foreground ,lp-comment))))
   `(org-block                      ((t (:background ,lp-bg-alt))))
   `(org-block-begin-line           ((t (:foreground ,lp-comment :slant italic))))
   `(org-block-end-line             ((t (:foreground ,lp-comment :slant italic))))
   `(org-code                       ((t (:foreground ,lp-string))))
   `(org-verbatim                   ((t (:foreground ,lp-const))))
   `(org-todo                       ((t (:foreground ,lp-error :weight bold))))
   `(org-done                       ((t (:foreground ,lp-success :weight bold))))
   `(org-date                       ((t (:foreground ,lp-keyword :underline t))))
   `(org-link                       ((t (:foreground ,lp-keyword :underline t))))
   `(org-tag                        ((t (:foreground ,lp-fg-dark :weight bold))))
   `(org-table                      ((t (:foreground ,lp-variable))))
   `(org-formula                    ((t (:foreground ,lp-warning))))
   `(org-headline-done              ((t (:foreground ,lp-fg-dark :strike-through t))))

   ;; --- Company (completion) ---
   `(company-tooltip                ((t (:background ,lp-bg-alt :foreground ,lp-fg))))
   `(company-tooltip-selection      ((t (:background ,lp-selection :foreground ,lp-fg))))
   `(company-tooltip-annotation     ((t (:foreground ,lp-comment))))
   `(company-tooltip-common         ((t (:foreground ,lp-keyword :weight bold))))
   `(company-scrollbar-bg           ((t (:background ,lp-bg-hl))))
   `(company-scrollbar-fg           ((t (:background ,lp-border))))

   ;; --- Helm ---
   `(helm-source-header             ((t (:background ,lp-ml-bg :foreground ,lp-keyword :weight bold :height 1.0))))
   `(helm-selection                 ((t (:background ,lp-selection))))
   `(helm-match                     ((t (:foreground ,lp-keyword :weight bold))))
   `(helm-candidate-number          ((t (:foreground ,lp-const))))
   `(helm-ff-directory              ((t (:foreground ,lp-func :weight bold))))
   `(helm-ff-file                   ((t (:foreground ,lp-fg))))
   `(helm-ff-executable             ((t (:foreground ,lp-string))))
   `(helm-ff-symlink                ((t (:foreground ,lp-keyword))))
   `(helm-buffer-directory          ((t (:foreground ,lp-func))))
   `(helm-buffer-modified           ((t (:foreground ,lp-warning))))

   ;; --- Magit ---
   `(magit-branch-local             ((t (:foreground ,lp-keyword))))
   `(magit-branch-remote            ((t (:foreground ,lp-string))))
   `(magit-tag                      ((t (:foreground ,lp-warning))))
   `(magit-hash                     ((t (:foreground ,lp-comment))))
   `(magit-section-heading          ((t (:foreground ,lp-keyword :weight bold))))
   `(magit-section-highlight        ((t (:background ,lp-bg-hl))))
   `(magit-diff-added               ((t (:background "#1a3a1a" :foreground "#4dc34d"))))
   `(magit-diff-removed             ((t (:background "#3a1a1a" :foreground "#e06c75"))))
   `(magit-diff-added-highlight     ((t (:background "#1f431f" :foreground "#5fd35f"))))
   `(magit-diff-removed-highlight   ((t (:background "#431f1f" :foreground "#ef7c83"))))))

(provide-theme 'latticeprotocol-dark)
;;; latticeprotocol-dark-theme.el ends here
