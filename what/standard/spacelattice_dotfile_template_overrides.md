---
type: context
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
status: active
tags: [dotfile, template, distribution, branding, defaults, p4]
---

# Spacelattice Dotfile Template Overrides

LP-specific defaults that the rendered `init.el` carries over the upstream Spacemacs template. These are all set in `dotfile.spacemacs.tmpl`; the `spacemacs-latticeprotocol` layer applies any runtime overrides that must fire after the dotfile is read.

## Overrides Table

| Variable | LP Default | Upstream Default | ADR | Notes |
|---|---|---|---|---|
| `dotspacemacs-distribution` | `'spacemacs-latticeprotocol` | `'spacemacs` | ADR-030 | Points to the LP distribution layer |
| `dotspacemacs-themes` | `'(latticeprotocol-dark latticeprotocol-light spacemacs-dark)` | `'(spacemacs)` | ADR-030 | LP pair + dark fallback |
| `dotspacemacs-startup-banner` | `'official` | `'official` | ADR-029 | LP banners held in reserve; `'official` retained |
| `dotspacemacs-frame-title-format` | `'("%b [" (:eval (projectile-project-name)) "]")` | `"%b"` | ADR-022 | Buffer + project name |
| `dotspacemacs-gc-cons` | `'(200000000 0.1)` | `'(100000000 0.1)` | ADR-016 | 200 MB GC threshold |
| `dotspacemacs-read-process-output-max` | `(* 4 1024 1024)` | `(* 1 1024 1024)` | ADR-016 | 4 MB LSP buffer |
| `dotspacemacs-background-transparency` | `100` | `90` | ADR-020 | Fully opaque background |
| `dotspacemacs-mode-line-theme` | `'doom` | `'vim-powerline` | P3-04 | doom-modeline |
| `dotspacemacs-default-font` | `'("SpaceMono Nerd Font" :size 13.0 ...)` | `'("Source Code Pro" ...)` | ADR-023 | Nerd Font for icons |
| `dotspacemacs-default-icons-font` | `'nerd-icons` | — | ADR-023 | nerd-icons package |
| `dotspacemacs-line-numbers` | `'(:relative t :enabled-for-modes prog-mode text-mode)` | `nil` | P3-11 | Relative line numbers |

## Runtime Overrides (via `config.el`)

These are set by the `spacemacs-latticeprotocol` layer at load time and override dotfile values:

| Variable | Value | Reason |
|---|---|---|
| `spacemacs-buffer-logo-title` | `"[L A T T I C E   P R O T O C O L]"` | LP branding string (ADR-027) |
| `spacemacs-buffer-name` | `"*spacelattice*"` | LP buffer name (ADR-027) |
| `spacemacs-repository` | `"spacelattice"` | LP update check target (ADR-027) |
| `spacemacs-repository-owner` | `"LatticeProtocol"` | LP update check target (ADR-027) |
| `spacemacs-checkversion-branch` | `"lp-stable"` | LP stable branch (ADR-027) |
| `spacemacs-buffer-note-file` | `what/docs/lp_release_notes_v1_0.org` | LP release notes (ADR-030) |

## Operator Override Path

Any of the above can be overridden per-machine in `what/local/operator.private.el` (gitignored). This file is loaded last in `dotspacemacs/user-init`. Example: switch to a custom LP ASCII banner:

```elisp
(setq dotspacemacs-startup-banner
      (expand-file-name
       "private/layers/spacemacs-latticeprotocol/banners/lp-banner-1.txt"
       spacemacs-start-directory))
```

## Reference

- `what/standard/dotfile.spacemacs.tmpl` — the rendered template
- `what/standard/layers/spacemacs-latticeprotocol/config.el` — runtime overrides
- `what/standard/spacelattice_distribution_spec.md` — distribution layer spec (ADR-025)
