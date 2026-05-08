---
type: context_reference
status: active
source: operator_supplied_2026_05_05
provenance: "Operator-supplied during the rename + v1.0 campaign foundation turn (2026-05-05). Persisted verbatim as in-vault context. Sections 1-3 are the Spacemacs customization surface inventory; section 4 is the LatticeProtocol fork playbook."
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
ratified_by: what/decisions/adr/adr_005_rename_to_spacelattice.md
size_estimate: "~30K tokens"
sections:
  - "§1 Customization Surface — Object Inventory"
  - "§2 Dimensions of Variation"
  - "§3 Customizations in the Wild — Broad Survey"
  - "§4A Forking & Branding — Concept-level Touchpoint Map"
  - "§4B Forking & Branding — Concrete Fork Playbook"
tags: [context_reference, spacemacs, customization, lp_fork_playbook, daedalus, large_reference]
---

# Spacemacs Customization Architecture — Reference & LatticeProtocol Fork Playbook

> Branch baseline: `develop` (default for new installs since 2024). Where `master` materially differs, it is flagged as `[master]`. Spacemacs requires Emacs ≥ 28.2; `develop` is the rolling branch; `master` is effectively frozen and not recommended.

---

## 1. Customization Surface — Object Inventory

### 1.1 Dotfile entry points (functions)

All five user functions live in a single dotfile (`~/.spacemacs` *or* `~/.spacemacs.d/init.el` *or* `$SPACEMACSDIR/init.el`). They are byte-stamps in the startup lifecycle, **not** ordinary hooks; Spacemacs calls each by name through `dotspacemacs|call-func`.

| Function | Signature | Lifecycle position | Legal contents | Source |
|---|---|---|---|---|
| `dotspacemacs/layers` | `()` → side-effects on `setq-default` | Phase 1 — read before any package work; called from `dotspacemacs/load-file` early in `core-spacemacs.el::spacemacs/init` | **Only** assignments to layer-related `dotspacemacs-*` variables: `dotspacemacs-distribution`, `dotspacemacs-enable-lazy-installation`, `dotspacemacs-ask-for-lazy-installation`, `dotspacemacs-configuration-layer-path`, `dotspacemacs-configuration-layers`, `dotspacemacs-additional-packages`, `dotspacemacs-frozen-packages`, `dotspacemacs-excluded-packages`, `dotspacemacs-install-packages`. Anything else is undefined behaviour | `core/templates/dotspacemacs-template.el` |
| `dotspacemacs/init` | `()` | Phase 2 — runs immediately after `dotspacemacs/layers`, **before** any layer or package | The exhaustive `setq-default` of every other `dotspacemacs-*` variable (see §1.3). Must not call `require`, must not load packages | `dotspacemacs-template.el` header |
| `dotspacemacs/user-env` | `()` | Phase 2.5 — runs before layer code; default body is `(spacemacs/load-spacemacs-env)` reading `~/.spacemacs.env` | Environment variable setup (`setenv`, `exec-path-from-shell-copy-env`, etc.) | `DOCUMENTATION.org` §Environment variables |
| `dotspacemacs/user-init` | `()` | Phase 3 — after `dotspacemacs/init`, **before** layer `init-*` functions and package loading | "Variables that need to be set before packages are loaded": `configuration-layer-elpa-archives`, `package-archive-priorities`, mode hooks (because files passed on the command line are read before `user-config`), `theming-modifications`, layer pre-config switches | `LAYERS.org`, `FAQ.org` |
| `dotspacemacs/user-config` | `()` | Phase 5 — last user-controlled call, after all layers' `init-*`/`config-*` and after `configuration-layer/load`; drives `spacemacs-post-user-config-hook` | The "99 %" of user code: keybindings via `spacemacs/set-leader-keys`, `with-eval-after-load` blocks, `setq` overrides of variables Spacemacs explicitly set, `(require …)` of `dotspacemacs-additional-packages` whose layer keeps them deferred | `core/core-spacemacs.el` |
| `dotspacemacs/emacs-custom-settings` | (auto-generated marker) | Last lines of dotfile | `custom-set-variables` / `custom-set-faces` written by `M-x customize`. Spacemacs marks the boundary with the comment `;; Do not write anything past this comment.` | `dotspacemacs-template.el` |

`dotspacemacs/user-load` is **not** present in the canonical `develop` template. Some forks (e.g. portions of the older master) and PR branches added `dotspacemacs/user-load` as a hook called only during the Spacemacs portable-dump phase (`spacemacs-dump-mode = 'dumping`) — its sole purpose is to `require`/`load` libraries that should be baked into the dump file. If you're targeting `develop`, treat it as optional/historical.

### 1.2 Dotfile location & resolution order

`core/core-dotspacemacs.el::dotspacemacs/location` resolves in this order (first hit wins):

1. `$SPACEMACSDIR/init.el` (when env var `SPACEMACSDIR` is set)
2. `~/.spacemacs` (the dotfile)
3. `~/.spacemacs.d/init.el` (the dotdirectory)
4. If none exist, `dotspacemacs/maybe-install-dotfile` is invoked at the end of `spacemacs/init`, copying `core/templates/.spacemacs.template` (renamed from `dotspacemacs-template.el`) to `~/.spacemacs` and prompting for editing style + distribution.

The variable `dotspacemacs-directory` is set to `(file-name-directory dotspacemacs-filepath)` and is the canonical anchor for relative paths inside the dotfile (e.g. `(concat dotspacemacs-directory "banners/lp-logo.svg")`).

The Spacemacs dotfile is **complementary** to vanilla `~/.emacs.d/init.el`: Emacs still reads `~/.emacs.d/init.el` (which is provided by the Spacemacs repo itself); `user-emacs-directory` continues to point at `~/.emacs.d/`.

### 1.3 Exhaustive `dotspacemacs-*` variable enumeration (develop branch, `dotspacemacs-template.el`)

Grouping reflects the order in which they appear in the template. Defaults shown verbatim from the template.

#### 1.3.1 Layer / package management (set in `dotspacemacs/layers`)

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-distribution` | symbol | `'spacemacs` | Selects base distribution layer in `layers/+distributions/`. Built-ins: `spacemacs-base`, `spacemacs`. Custom values must match a directory there (see §4). |
| `dotspacemacs-enable-lazy-installation` | `'all` \| `'unused` \| `nil` | `'unused` | Lazy-install layers when a matching file is opened. |
| `dotspacemacs-ask-for-lazy-installation` | bool | `t` | Confirmation prompt before lazy install. |
| `dotspacemacs-configuration-layer-path` | list of strings | `'()` | Extra search paths for layers (must end with `/`). |
| `dotspacemacs-configuration-layers` | list | `'(emacs-lisp helm multiple-cursors treemacs)` | The layer list (see §1.4 grammar). |
| `dotspacemacs-additional-packages` | list | `'()` | Packages installed without a layer. Supports `:location` recipes. |
| `dotspacemacs-frozen-packages` | list | `'()` | Packages that may not be updated. |
| `dotspacemacs-excluded-packages` | list | `'()` | Packages never installed/loaded. |
| `dotspacemacs-install-packages` | `'used-only` \| `'used-but-keep-unused` \| `'all` | `'used-only` | Orphan-package policy. |

#### 1.3.2 ELPA / version / dump (set in `dotspacemacs/init`)

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-elpa-https` | bool | `t` *(historical; remains in master template, removed/forced from develop)* | Force HTTPS for ELPA. `develop` no longer supports disabling for security reasons. |
| `dotspacemacs-elpa-timeout` | int | `5` | Seconds before ELPA contact timeout. |
| `dotspacemacs-gc-cons` | `(threshold . pct)` list | `'(100000000 0.1)` | Sets `gc-cons-threshold` and `gc-cons-percentage` after startup completes. |
| `dotspacemacs-read-process-output-max` | int | `(* 1024 1024)` | `read-process-output-max` for LSP throughput. |
| `dotspacemacs-use-spacelpa` | bool | `nil` | Use the (experimental) Spacelpa locked archive. |
| `dotspacemacs-verify-spacelpa-archives` | bool | `t` | Signature verification on Spacelpa tarballs. |
| `dotspacemacs-check-for-update` | bool | `nil` | Periodic git-based update check (only on non-`develop` branches). |
| `dotspacemacs-elpa-subdirectory` | sexp \| `nil` | `'emacs-version` | Per-Emacs-version ELPA dirs. |

#### 1.3.3 Editing style & leaders

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-editing-style` | `'vim` \| `'emacs` \| `'hybrid` \| list w/ `:variables` | `'vim` | Evil state baseline; `hybrid` swaps insert state for hybrid state. |
| `dotspacemacs-leader-key` | string | `"SPC"` | Vim/hybrid leader. |
| `dotspacemacs-emacs-command-key` | string | `"SPC"` | Key for `M-x` after leader. |
| `dotspacemacs-ex-command-key` | string | `":"` | Vim ex-command key. |
| `dotspacemacs-emacs-leader-key` | string | `"M-m"` | Leader in emacs/insert state. |
| `dotspacemacs-major-mode-leader-key` | string | `","` | Major-mode leader (= `SPC m`). |
| `dotspacemacs-major-mode-emacs-leader-key` | string | `"M-<return>"` GUI / `"C-M-m"` TTY | Same in emacs state. |
| `dotspacemacs-distinguish-gui-tab` | bool | `nil` | Bind `C-i`/`TAB` and `C-m`/`RET` separately in GUI. |

#### 1.3.4 Startup buffer / banner / lists

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-startup-buffer-show-version` | bool | `t` | Show `(spacemacs-version)@(emacs-version)` line. |
| `dotspacemacs-startup-banner` | `'official` \| int \| `'random` \| `'random*` \| `'doge` \| `'cat` \| string path \| `nil` | `'official` | Banner selector (see §1.7). |
| `dotspacemacs-startup-banner-scale` | `'auto` \| number | `'auto` | Image scaling factor. |
| `dotspacemacs-startup-lists` | alist `((TYPE . SIZE) …)` | `'((recents . 5) (projects . 7))` | List sections. Types: `recents`, `recents-by-project` (size = `(N . M)`), `bookmarks`, `projects`, `agenda`, `todos`. |
| `dotspacemacs-startup-buffer-responsive` | bool | `t` | Re-render on frame resize. |
| `dotspacemacs-show-startup-list-numbers` | bool | `t` | Numeric prefixes for lists. |
| `dotspacemacs-startup-buffer-multi-digit-delay` | float | `0.4` | Multi-digit jump delay. |
| `dotspacemacs-startup-buffer-show-icons` | bool | `nil` | Show nerd-icons file icons (GUI + nerd-icons font). |
| `dotspacemacs-new-empty-buffer-major-mode` | symbol | `'text-mode` | Mode for `SPC b N`. |
| `dotspacemacs-scratch-mode` | symbol | `'text-mode` | Mode of `*scratch*`. |
| `dotspacemacs-scratch-buffer-persistent` | bool | `nil` | Persist scratch contents across sessions. |
| `dotspacemacs-scratch-buffer-unkillable` | bool | `nil` | Bury instead of kill `*scratch*`. |
| `dotspacemacs-initial-scratch-message` | string \| `nil` | `nil` | Custom welcome message. |

#### 1.3.5 Themes, modeline, fonts, cursor

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-themes` | list of theme specs | `'(spacemacs-dark spacemacs-light)` | First element is loaded; `SPC T n` cycles. Each entry can be a symbol or a list with `:package` and/or `:location` keys. |
| `dotspacemacs-mode-line-theme` | symbol \| list | `'(spacemacs :separator wave :separator-scale 1.5)` | Values: `spacemacs`, `all-the-icons`, `custom`, `doom`, `vim-powerline`, `vanilla`. Optional `:separator` (e.g. `wave`, `slant`, `arrow`, `bar`, `nil`) and `:separator-scale`. |
| `dotspacemacs-colorize-cursor-according-to-state` | bool | `t` | Cursor color follows evil state (GUI). |
| `dotspacemacs-default-font` | plist or list of plists | `'("Source Code Pro" :size 10.0 :weight normal :width normal)` | Fallback chain supported. |
| `dotspacemacs-default-icons-font` | `'all-the-icons` \| `'nerd-icons` | `'all-the-icons` | Icon font family. |

#### 1.3.6 Layouts / sessions

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-default-layout-name` | string | `"Default"` | Default perspective name. |
| `dotspacemacs-display-default-layout` | bool | `nil` | Show "Default" in modeline. |
| `dotspacemacs-auto-resume-layouts` | bool | `nil` | Resume saved layouts at startup. |
| `dotspacemacs-auto-generate-layout-names` | bool | `nil` | Auto-name layouts created via "jump by number". |

#### 1.3.7 Files, autosave, rollback

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-large-file-size` | int (MB) | `1` | Threshold to prompt "open literally". |
| `dotspacemacs-auto-save-file-location` | `'original` \| `'cache` \| `nil` | `'cache` | Auto-save destination. |
| `dotspacemacs-max-rollback-slots` | int | `5` | Package rollback history depth. |
| `dotspacemacs-enable-paste-transient-state` | bool | `nil` | `C-j`/`C-k` cycle kill-ring after paste. |

#### 1.3.8 which-key / cycling / windowing

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-which-key-delay` | float | `0.4` | which-key popup delay. |
| `dotspacemacs-which-key-position` | `'right` \| `'bottom` \| `'right-then-bottom` \| `(posframe . pos)` | `'bottom` | which-key placement. `posframe` positions: `center`, `top-center`, `bottom-center`, `top-left-corner`, `top-right-corner`, `bottom-left-corner`, `bottom-right-corner`. |
| `dotspacemacs-switch-to-buffer-prefers-purpose` | bool | `nil` | Honour `purpose` window dedication. |
| `dotspacemacs-enable-cycling` | bool \| list | `nil` | Cycle on consecutive `TAB` after commands like `spacemacs/alternate-buffer`. List subset: `'(alternate-buffer alternate-window)`. |
| `dotspacemacs-maximize-window-keep-side-windows` | bool | `t` | `SPC w m` preserves treemacs/neotree. |
| `dotspacemacs-enable-load-hints` | bool | `nil` | Reorder `load-path` for Windows speedup. |
| `dotspacemacs-enable-package-quickstart` | bool | `nil` | Use `package-quickstart-file`. |
| `dotspacemacs-loading-progress-bar` | bool | `t` | Boot progress bar. |

#### 1.3.9 Frame appearance

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-fullscreen-at-startup` | bool | `nil` | Native fullscreen on launch. |
| `dotspacemacs-fullscreen-use-non-native` | bool | `nil` | Use non-native fullscreen (avoids OSX animation). |
| `dotspacemacs-maximized-at-startup` | bool | `t` | Maximize frame (only if not fullscreen). |
| `dotspacemacs-undecorated-at-startup` | bool | `nil` | Strip window decorations. |
| `dotspacemacs-active-transparency` | int 0–100 | `90` | Active-frame opacity. |
| `dotspacemacs-inactive-transparency` | int 0–100 | `90` | Inactive-frame opacity. |
| `dotspacemacs-background-transparency` | int 0–100 | `90` | Background-only transparency. |
| `dotspacemacs-show-transient-state-title` | bool | `t` | Title in TS header. |
| `dotspacemacs-show-transient-state-color-guide` | bool | `t` | Color hints in TS keys. |
| `dotspacemacs-mode-line-unicode-symbols` | bool \| `'display-graphic-p` | `t` | Unicode glyphs in modeline. |
| `dotspacemacs-smooth-scrolling` | bool | `t` | Disable recenter on edge. |
| `dotspacemacs-scroll-bar-while-scrolling` | bool / number | `t` | Show/hide scrollbar; numeric = autohide seconds. |

#### 1.3.10 Editing knobs

| Variable | Type | Default | Effect |
|---|---|---|---|
| `dotspacemacs-line-numbers` | `t` \| `'relative` \| `'visual` \| `nil` \| plist | `nil` | Plist keys: `:relative`, `:visual`, `:disabled-for-modes (mode …)`, `:size-limit-kb`, `:enabled-for-modes (mode …)`. |
| `dotspacemacs-folding-method` | `'evil` \| `'origami` \| `'vimish` | `'evil` | Code-folding backend. |
| `dotspacemacs-smartparens-strict-mode` | bool | `nil` | Strict smartparens in prog modes. |
| `dotspacemacs-activate-smartparens-mode` | bool | `t` | smartparens on by default. |
| `dotspacemacs-smart-closing-parenthesis` | bool | `nil` | `)` skips auto-paren. |
| `dotspacemacs-highlight-delimiters` | `'any` \| `'current` \| `'all` \| `nil` | `'all` | Rainbow-delim scope. |
| `dotspacemacs-enable-server` | bool | `nil` | Start `server-start`. |
| `dotspacemacs-server-socket-dir` | string \| `nil` | `nil` | Override server socket dir. |
| `dotspacemacs-persistent-server` | bool | `nil` | Quit functions keep server up. |
| `dotspacemacs-search-tools` | list of strings | `'("rg" "ag" "ack" "grep")` | First found wins. |
| `dotspacemacs-undo-system` | `'undo-redo` \| `'undo-fu` \| `'undo-tree` | `'undo-redo` | Sets `evil-undo-system`. **Note**: history is incompatible across `undo-tree`. |
| `dotspacemacs-frame-title-format` | string \| `nil` | `"%I@%S"` | `format-spec` keys: `%a` abbreviated path, `%t` projectile project, `%I` invocation, `%S` system, `%U` $USER, `%b` buffer name, `%f` visited file, `%F` frame, `%s` process status, `%p`/`%P`, `%m` mode, `%n` Narrow, `%z`/`%Z` coding system. |
| `dotspacemacs-icon-title-format` | string \| `nil` | `nil` | Icon title; falls back to frame format. |
| `dotspacemacs-show-trailing-whitespace` | bool | `t` | Highlight trailing ws in prog/text. |
| `dotspacemacs-whitespace-cleanup` | `'all` \| `'trailing` \| `'changed` \| `nil` | `nil` | On-save cleanup policy. |
| `dotspacemacs-use-clean-aindent-mode` | bool | `t` | clean-aindent virtual indent. |
| `dotspacemacs-use-SPC-as-y` | bool | `nil` | `SPC` confirms y/n prompts. |
| `dotspacemacs-swap-number-row` | symbol \| `nil` | `nil` | Layouts: `qwerty-us`, `qwertz-de`, `querty-ca-fr`. |
| `dotspacemacs-zone-out-when-idle` | int \| `nil` | `nil` | Idle seconds before `zone-out`. |
| `dotspacemacs-pretty-docs` | bool | `nil` | `space-doc-mode` on layer READMEs. |
| `dotspacemacs-home-shorten-agenda-source` | bool | `nil` | Show only file name (not full path) for agenda items in home buffer. |
| `dotspacemacs-byte-compile` | bool | `nil` | Byte-compile some Spacemacs files. |

> Variables related to the Emacs portable dumper (`dotspacemacs-enable-emacs-pdumper`, `dotspacemacs-emacs-pdumper-executable-file`, `dotspacemacs-emacs-dumper-dump-file`) are present in the dump-aware path of `core/core-dumper.el` but are not part of the standard template on `develop`. They surface only on Emacs builds where pdumper is enabled and `native-comp` is **not** in use; both features are mutually exclusive in current Spacemacs (issue #15721).

### 1.4 Layer anatomy

Directory structure under `layers/<category>/<layer>/` (categories prefixed `+`: `+lang`, `+tools`, `+completion`, `+themes`, `+distributions`, `+intl`, `+emacs`, `+frameworks`, `+vim`, `+fun`, `+filetree`, `+source-control`, `+web-services`, `+os`, `+spacemacs`, `+misc`, `+pair-programming`, `+chat`, `+games`, `+readers`, `+checkers`).

| File | Required? | Loaded order | Contract |
|---|---|---|---|
| `layers.el` | optional | **First** | Declare layer dependencies via `(configuration-layer/declare-layer-dependencies '(layer-a layer-b))`. |
| `packages.el` | **required** | After `layers.el` | Define `<layer>-packages` (list) and `<layer>/init-<pkg>`, `<layer>/pre-init-<pkg>`, `<layer>/post-init-<pkg>`. |
| `funcs.el` | optional | Before `config.el` | Function definitions; auto-loaded only if used. |
| `config.el` | optional | Before package init | Variable declarations and `defvar` defaults. |
| `keybindings.el` | optional | After `config.el` | Global / leader keybindings via `spacemacs/set-leader-keys`. |
| `README.org` | **required** for distribution layers | n/a | Documentation; first heading `Description`, subsequent headings per `CONVENTIONS.org`. |
| `local/<package>/` | optional | n/a | Source for `:location local` packages; auto-added to `load-path`. |

#### Package declaration grammar in `<layer>-packages`

```elisp
(setq <layer>-packages
  '(simple-pkg
    (pkg :location elpa)
    (pkg :location built-in)
    (pkg :location local)
    (pkg :location (recipe :fetcher github :repo "u/r" :commit "abc123"))
    (pkg :location (recipe :fetcher local))            ;; quelpa from local/
    (pkg :step pre)                                     ;; install during pre-init
    (pkg :step bootstrap)                               ;; bootstrap-only
    (pkg :excluded t)                                   ;; suppress
    (pkg :toggle (display-graphic-p))                   ;; conditional
    (pkg :requires (other-pkg))
    (pkg :protected t)))                                ;; cannot be excluded
```

#### Init function naming

```elisp
(defun <layer>/init-<pkg> ()
  (use-package <pkg> :defer t :init … :config …))
(defun <layer>/pre-init-<pkg> () …)
(defun <layer>/post-init-<pkg> () …)
```

The package "owner" is the layer providing the `init-<pkg>` function. Only one layer may own a package; `pre-init` / `post-init` modify but do not own. Layers process in user-dotfile order — a later layer may "seize" a package by also providing `init-<pkg>`. Packages are processed alphabetically within the install phase.

#### `spacemacs|use-package-add-hook`

```elisp
(spacemacs|use-package-add-hook helm
  :pre-init  (…)
  :post-init (…)
  :pre-config  (…)
  :post-config (…))
```

Injects code into another layer's `use-package` form for `<pkg>`. Must run before that `use-package` is evaluated, hence is placed in the calling layer's `init-<pkg>` (commonly `pre-init-<pkg>`).

#### Layer classes

| Class | Location | Visibility | Source-controlled by Spacemacs? |
|---|---|---|---|
| Distribution | `layers/+distributions/<dist>/` | Public; selected via `dotspacemacs-distribution` | Yes |
| Public (contrib) | `layers/+<category>/<layer>/` | Public, listed via `SPC h SPC` | Yes |
| Private | `private/<layer>/` | User-local | No (gitignored) |
| External | any path in `dotspacemacs-configuration-layer-path` | User-local | No |

#### Declaration grammar in `dotspacemacs-configuration-layers`

```elisp
dotspacemacs-configuration-layers
'(emacs-lisp                                    ;; bare symbol
  (git :variables git-magit-status-fullscreen t);; with layer variables
  (org :variables                                ;; multiple variables
       org-enable-roam-support t
       org-enable-github-support t
       org-want-todo-bindings t)
  (auto-completion :disabled-for org markdown)   ;; per-mode disable
  (helm :variables helm-position 'bottom))
```

### 1.5 `configuration-layer/` API surface

Public entry points (`core/core-configuration-layer.el`):

| Symbol | Purpose | Where called |
|---|---|---|
| `configuration-layer/declare-layer` | Force-add a single layer | `layers.el` |
| `configuration-layer/declare-layers` | Force-add several | `layers.el` |
| `configuration-layer/declare-layer-dependencies` | Soft-require dependency layers | `layers.el` |
| `configuration-layer/load` | Top-level layer/package install + load | `init.el` |
| `configuration-layer/sync` | Re-run synchronization (`SPC f e R`) | Interactive |
| `configuration-layer/load-lock-file` | Load Spacelpa lock file | `init.el` |
| `configuration-layer/update-packages` | Bulk update | Interactive |
| `configuration-layer/rollback` | Restore from `.cache/.rollback/` | Interactive |
| `configuration-layer/create-layer` | Scaffolding generator | Interactive (`SPC SPC`) |
| `configuration-layer/package-usedp` | Predicate for guarded code | Layer code |
| `configuration-layer/layer-usedp` | Predicate | Layer code |
| `configuration-layer/make-package` | Internal: build pkg object | Internal |
| `configuration-layer-elpa-archives` | User-overridable archive alist | `dotspacemacs/user-init` |
| `configuration-layer-force-distribution` | Override `dotspacemacs-distribution` (for testing) | Internal |

Lazy install: when `dotspacemacs-enable-lazy-installation` is non-nil, `configuration-layer//lazy-install-extensions` registers file-extension → layer mappings so opening (e.g.) `foo.ex` prompts to install `elixir`.

### 1.6 Theme system

* `dotspacemacs-themes` accepts:
  * a bare symbol (`spacemacs-dark`) — assumed to be the same-name `-theme` ELPA package.
  * a list with keyword properties: `(spacemacs-dark :package custom-theme-name)` or `(my-theme :location (recipe :fetcher github :repo "u/r"))`.
* Theme cycling: `SPC T n` (next), `SPC T s` (helm/ivy theme picker, all installed themes).
* The default `spacemacs-theme` package (light/dark) ships with the distribution.
* External themes: declare in `dotspacemacs-themes`; Spacemacs auto-installs the `<name>-theme` package on first launch.
* The `theming` layer (`layers/+themes/theming/`) exposes `theming-modifications` — an alist `((theme (face attrs…) …))` for face overrides per theme, with `M-x spacemacs/update-theme`.
* `themes-megapack` installs ~100 community themes on demand.
* For a custom in-tree theme, populate `~/.spacemacs.d/themes/<name>-theme.el` and `(add-to-list 'custom-theme-load-path …)` in `dotspacemacs/user-init`.

### 1.7 Modeline

Mechanism is selected by `dotspacemacs-mode-line-theme`:

| Value | Provider | Notes |
|---|---|---|
| `spacemacs` | `spaceline` (`TheBB/spaceline`) | Default; supports `:separator` + `:separator-scale`. |
| `all-the-icons` | `spaceline-all-the-icons` | Requires `all-the-icons` font; many `spaceline-all-the-icons-*` knobs. |
| `custom` | User-defined `spaceline-custom-theme` | Function defined in `dotspacemacs/user-init`. |
| `doom` | `doom-modeline` | Configure via `setq doom-modeline-*` in `user-config`. |
| `vim-powerline` | classic Vim-style | Legacy. |
| `vanilla` | Emacs default | Disables Spaceline. |

Spaceline segments enabled by default include: evil-state, perspective name, window number, anzu, version-control, major-mode, minor-modes (with diminish), buffer-id, line/column, flycheck status, battery (`fancy-battery`), org-clock. Per-segment toggle via `spaceline-NAME-p` variables and the interactive functions `spaceline-toggle-NAME-{on,off}`.

`spaceline-pre-hook` runs before each render — keep it lightweight. `spaceline-window-numbers-unicode` / `spaceline-workspace-numbers-unicode` enable circled numerals.

### 1.8 Banner system

Implemented in `core/core-spacemacs-buffer.el`.

* Banner directory: `core/banners/` containing:
  * `000-banner.txt` … `004-banner.txt` (regular text banners)
  * `998-banner.txt` (`cat`/`random*` special)
  * `999-banner.txt` (`doge`/`random*` special)
  * `997-banner.txt` (dark-theme doge variant)
  * `img/spacemacs.png` (and `.svg`/`.icns`) — the official image banner
* Selection logic in `spacemacs-buffer//choose-banner` based on `dotspacemacs-startup-banner`:
  * `'official` → `img/spacemacs.png` (image)
  * `'random` → uniform pick from `001-banner.txt` … `004-banner.txt`, excluding 99x specials
  * `'random*` → includes specials
  * `'doge` / `'cat` → `999-banner.txt` / `998-banner.txt`
  * Integer `N` → `(format "%03d-banner.txt" N)` in `core/banners/`
  * String → absolute or relative path to a text file *or* an Emacs-supported image format (`.png`, `.svg`, `.xpm`, etc.)
  * `nil` → no banner
* Image banner constraints: rendered via `create-image`; recommended dimensions ~200–300 px wide, height auto-scaled by `dotspacemacs-startup-banner-scale` (`'auto` or numeric multiplier). The image is centered: `(- spacemacs-buffer--window-width width) / 2`.
* Title beneath the banner is `spacemacs-buffer-logo-title` (defconst, default `"[S P A C E M A C S]"`).
* Version line injected by `spacemacs-buffer//inject-version`: `"<spacemacs-version>@<emacs-version> (<dotspacemacs-distribution>)"` right-justified at column ~80.

### 1.9 Startup buffer / scratch / frame title / transient states / which-key

* Startup buffer name: `*spacemacs*`. Function: `spacemacs-buffer/goto-buffer`. Population pipeline: banner → version → buttons → release-note → quickhelp → startup-lists → footer. Buttons inserted by `spacemacs-buffer//insert-buttons` ([Update Packages], [Update Spacemacs], [?]).
* Startup-lists: each list is rendered through `spacemacs-buffer//insert-recents`, `…-projects`, `…-bookmarks`, `…-agenda`, `…-todos`, with shortcuts `r`, `p`, `b`, `a`, `t`. Lengths from `dotspacemacs-startup-lists`; default cap from `spacemacs-buffer-startup-lists-length` (default 20).
* Scratch buffer: governed by `dotspacemacs-scratch-mode`, `dotspacemacs-initial-scratch-message`, `dotspacemacs-scratch-buffer-persistent` (caches to `.cache/spacemacs-scratch.el`), `dotspacemacs-scratch-buffer-unkillable`.
* Frame title: `spacemacs/title-prepare` reads `dotspacemacs-frame-title-format` (and `dotspacemacs-icon-title-format`).
* Transient states: defined via `spacemacs|define-transient-state` macro (see `core/core-transient-state.el`); titles controlled by `dotspacemacs-show-transient-state-title`, color hints by `dotspacemacs-show-transient-state-color-guide`.
* which-key: package `which-key`; variables `dotspacemacs-which-key-delay`, `dotspacemacs-which-key-position`. Spacemacs adds prefix descriptions via `which-key-add-key-based-replacements` from `core/core-keybindings.el`.

### 1.10 Startup lifecycle (consolidated)

```
~/.emacs.d/init.el
  └─ load core/core-load-paths.el
  └─ require 'core-spacemacs
  └─ spacemacs/init                                                  ; Phase 0
       ├─ hidden-mode-line-mode + remove GUI elements
       ├─ prefer-coding-system 'utf-8
       ├─ dotspacemacs/load-file                                     ; reads dotfile
       ├─ require 'core-configuration-layer
       ├─ dotspacemacs/init                                  [P2]    ; user
       ├─ dotspacemacs/user-init                             [P3]    ; user
       └─ dotspacemacs/maybe-install-dotfile (if no dotfile)
  └─ configuration-layer/load-lock-file
  └─ configuration-layer/stable-elpa-init
  └─ configuration-layer/load                                        ; Phase 4
       ├─ declare distribution layer  (spacemacs / spacemacs-base / custom)
       ├─ declare spacemacs-bootstrap                                ; always
       ├─ resolve all configured layers  (recursive deps)
       ├─ install missing packages alphabetically
       └─ for each used package, in alpha order:
            ├─ pre-init-<pkg>      (each layer w/ pre-init)
            ├─ init-<pkg>          (the owner)
            └─ post-init-<pkg>     (each layer w/ post-init)
  └─ spacemacs-buffer/display-startup-note
  └─ spacemacs/setup-startup-hook
       └─ adds emacs-startup-hook lambda:
            ├─ dotspacemacs/user-config                       [P5]
            ├─ run-hooks 'spacemacs-post-user-config-hook
            ├─ funcall dotspacemacs-scratch-mode in *scratch*
            └─ apply gc-cons / set spacemacs-initialized t
```

Spacemacs exposes `spacemacs-post-user-config-hook` and `spacemacs/defer-until-after-user-config` for code that must run *after* `dotspacemacs/user-config`.

`dotspacemacs/user-env` is invoked from the `:init` block of `core-spacemacs.el`, between the dotfile load and the layer load — i.e. between Phase 2 and Phase 4.

> **Caveat (FAQ.org)**: files passed on the Emacs command line are read **before** `user-config` runs; therefore mode hooks must be registered in `user-init` to take effect on the first opened file.

---

## 2. Dimensions of Variation

### 2.1 Editing styles

| Variant | `dotspacemacs-editing-style` | Insert state | Leader |
|---|---|---|---|
| Vim | `'vim` | Evil insert | `SPC` |
| Emacs | `'emacs` | Standard | `M-m` (`dotspacemacs-emacs-leader-key`) |
| Hybrid | `'hybrid` | "Hybrid" state (Emacs keys with Evil normal escape) | `SPC` |
| Tunable | `'(vim :variables evil-want-Y-yank-to-eol t evil-escape-key-sequence "jk")` | Configured per-variable | per editing style |

Major-mode leader: default `,` (`SPC m`); set `nil` to disable. evil-escape sequence (default `fd`) in `dotspacemacs/user-config`: `(setq evil-escape-key-sequence "jk")`.

### 2.2 Completion stack

| Layer | Engine | Default | When |
|---|---|---|---|
| `helm` | helm | Yes (default if no layer chosen) | Mature, biggest action set |
| `ivy` | ivy + counsel + swiper | optional | Smaller, faster; some Spacemacs features helm-only |
| `compleseus` | vertico / selectrum + consult + embark + marginalia + orderless | Emacs ≥ 27 | Modern, vertical UI; configure via `compleseus-engine 'vertico` (default) or `'selectrum`; `compleseus-consult-preview-keys` |

Rule: if multiple completion layers are listed, **the last one wins** (`compleseus` after `helm` overrides). Layers expose hooks (`spacemacs/helm-find-files`, `spacemacs/compleseus-find-file`, etc.) that other layers route through.

### 2.3 Package management knobs

| Knob | Effect |
|---|---|
| `configuration-layer-elpa-archives` | Set in `dotspacemacs/user-init`; alist `(("name" . "URL/"))`. Spacemacs default: `melpa`, `org`, `gnu`. |
| `package-archive-priorities` | Standard Emacs mechanism for archive precedence; set in `user-init`. |
| `dotspacemacs-additional-packages` with `:pin "archive-name"` | Per-package archive pinning (legacy form `(pkg :pin "melpa-stable")`). |
| `dotspacemacs-frozen-packages` | Block updates; useful while pinning. |
| `dotspacemacs-install-packages` `'used-only` / `'used-but-keep-unused` / `'all` | Orphan-deletion policy. |
| `dotspacemacs-use-spacelpa` + `dotspacemacs-verify-spacelpa-archives` | Use the Spacelpa lockfile mechanism (experimental). Lockfile lives at `.cache/.lock`. |
| `quelpa` recipes | Allowed in `:location (recipe :fetcher github …)`. |
| Rollback | `~/.emacs.d/.cache/.rollback/<emacs-version>/develop/<timestamp>/`; `SPC f e r` or `configuration-layer/rollback`. |

### 2.4 Lifecycle ordering — precise table

| Order | Location | Caller | What may run |
|---|---|---|---|
| 1 | `dotspacemacs/layers` | `dotspacemacs/load-file` | Layer-list `setq-default` only |
| 2 | `dotspacemacs/init` | `spacemacs/init` | All other `dotspacemacs-*` `setq-default` |
| 3 | `dotspacemacs/user-env` | `core-spacemacs.el` | `setenv`, `exec-path-from-shell-copy-env` |
| 4 | `dotspacemacs/user-init` | `spacemacs/init` | `setq` for layer pre-config, mode hooks, archive overrides, `theming-modifications`, `custom-theme-load-path` |
| 5 | Layer `layers.el` | `configuration-layer/load` | `configuration-layer/declare-layer-dependencies` |
| 6 | Layer `funcs.el` (autoload) | lazy | function defs |
| 7 | Layer `config.el` | configuration-layer | `defvar` defaults |
| 8 | Layer `pre-init-<pkg>` | per-package | inject before owner's `use-package` |
| 9 | Layer `init-<pkg>` (owner) | per-package | `use-package` declarations |
| 10 | Layer `post-init-<pkg>` | per-package | inject `:post-init`/`:post-config` |
| 11 | Layer `keybindings.el` | configuration-layer | `spacemacs/set-leader-keys` |
| 12 | `spacemacs-buffer/display-startup-note` | `spacemacs/init` | Render home buffer |
| 13 | `dotspacemacs/user-config` | `emacs-startup-hook` | The bulk of user code |
| 14 | `spacemacs-post-user-config-hook` | `emacs-startup-hook` | Deferred logic |
| 15 | gc-cons applied; `spacemacs-initialized = t` | `emacs-startup-hook` | Ready |

### 2.5 Performance knobs

| Knob | Default | Recommendation |
|---|---|---|
| `dotspacemacs-gc-cons` | `'(100000000 0.1)` | 100 MB threshold; LSP-heavy users push to 200 MB. |
| `dotspacemacs-read-process-output-max` | `1 MB` | LSP throughput; raise to 4–8 MB if servers stutter. |
| `dotspacemacs-enable-lazy-installation` | `'unused` | Use for laptops; `nil` for deterministic CI. |
| `dotspacemacs-enable-load-hints` | `nil` | Windows boot speedup. |
| `dotspacemacs-enable-package-quickstart` | `nil` | Run `M-x package-quickstart-refresh` first; set to `t` to skip per-package autoload scan. |
| `dotspacemacs-byte-compile` | `nil` | Byte-compile a subset; native-comp fronts the gain. |
| Native compilation | n/a (Emacs build flag) | `--with-native-comp` strongly recommended; mutually exclusive with `dotspacemacs-enable-emacs-pdumper` (Spacemacs portable dump). |
| `gcmh` | optional package | Some users add as `dotspacemacs-additional-packages` for adaptive GC. |

### 2.6 Evil & misc toggles

| Knob | Effect |
|---|---|
| `evil-escape-key-sequence` | Custom escape (default `fd`). |
| `evil-undo-system` (set via `dotspacemacs-undo-system`) | `undo-redo` (Emacs 28+ built-in), `undo-fu`, or `undo-tree`. |
| `dotspacemacs-folding-method` | `evil` / `origami` / `vimish`. |
| `evil-symbol-word-search` | Set in `user-config` for `*` search to include `_`/`-`. |
| Search engines | `helm-engine`, `engine-mode` layer; `dotspacemacs-search-tools` for grep backends. |

### 2.7 Font / icon handling

* `dotspacemacs-default-font` may be a list to enable fallback (`'("Source Code Pro" :size 11.0 …)` or `'(("Iosevka") ("Symbola"))`).
* Icon font: `all-the-icons` or `nerd-icons` (set `dotspacemacs-default-icons-font`). After install, run `M-x all-the-icons-install-fonts` or `nerd-icons-install-fonts`.
* Frame parameters: `dotspacemacs-{active,inactive,background}-transparency`, `dotspacemacs-undecorated-at-startup`, `dotspacemacs-maximized-at-startup`, `dotspacemacs-fullscreen-at-startup`, `dotspacemacs-fullscreen-use-non-native`. For finer control, edit `default-frame-alist` in `dotspacemacs/user-config`:

```elisp
(add-to-list 'default-frame-alist '(internal-border-width . 16))
(add-to-list 'default-frame-alist '(alpha . (95 90)))
```

---

## 3. Customizations in the Wild — Broad Survey

### 3.1 High-signal layer combinations

Patterns observed across `practicalli/spacemacs-config`, `Falkor/spacemacs-config`, `MilesMcBain/spacemacs_cfg`, `bc-abe/Spacemacs`, `fernandomayer/spacemacs`, `maverobot/dot-spacemacs`, `ngm/commonplace.doubleloop.net`, the Practicalli Clojure stack, and frequent r/spacemacs threads:

* **General-purpose IDE stack**: `auto-completion better-defaults emacs-lisp git helm/ivy/compleseus lsp syntax-checking version-control treemacs (org :variables …) (shell :variables shell-default-shell 'vterm)` — recurs in 60 %+ of public dotfiles.
* **Clojure-heavy** (Practicalli): `clojure html javascript markdown yaml sql (lsp :variables lsp-enable-file-watchers nil) syntax-checking treemacs`.
* **Data / R**: `ess polymode (auto-completion :variables auto-completion-enable-help-tooltip t) latex bibtex`.
* **Python / DS**: `(python :variables python-formatter 'black python-sort-imports-on-save t python-fill-column 79) ipython-notebook (lsp :variables lsp-pyright-multi-root nil)`.
* **C/C++**: `(c-c++ :variables c-c++-backend 'lsp-clangd c-c++-enable-clang-format-on-save t) cmake dap`.
* **Web/JS/TS**: `(javascript :variables js2-basic-offset 2 node-add-modules-path t) typescript html prettier emmet`.
* **Note-taking power-users**: `(org :variables org-enable-roam-support t org-enable-org-journal-support t org-enable-github-support t org-enable-bootstrap-support t org-enable-reveal-js-support t org-enable-notifications t org-want-todo-bindings t org-enable-roam-protocol t)`, plus `pdf-tools deft elfeed-org`.
* **Email**: `(mu4e :variables mu4e-installation-path "/usr/local/share/emacs/site-lisp/mu4e" mu4e-enable-async-operations t) gnus`.
* **DevOps**: `ansible docker kubernetes terraform nginx systemd`.
* **Themes-heavy hackers**: `themes-megapack` + `(colors :variables colors-enable-rainbow-identifiers nil colors-enable-nyan-cat-progress-bar t)`.

### 3.2 Canonical workarounds for known pain points

| Pain point | Workaround |
|---|---|
| Org double-loading (Spacemacs uses ELPA org since 0.300) | Wrap user org config in `(with-eval-after-load 'org …)`; keep org code out of `user-init`. |
| `org-roam-mode` not enabled when `org-enable-roam-support` is set (issue #14411) | Add explicit `(org-roam-mode)` to `user-config`. |
| Mode hooks not running for files passed via CLI | Move `add-hook 'prog-mode-hook …` from `user-config` to `user-init`. |
| `exec-path-from-shell` warning re. interactive shells | Move env vars to `~/.profile`/`~/.zshenv`, or `(setq exec-path-from-shell-check-startup-files nil)` in `user-init`. |
| Helm/ivy stale prompts hijacked by daemon mode | Excluded `tooltip-mode`, set `(setq tramp-ssh-controlmaster-options "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=no")`. |
| LSP slow / disable file watchers | `(lsp :variables lsp-enable-file-watchers nil)`; raise `dotspacemacs-read-process-output-max`. |
| Companies' MITM proxies break ELPA TLS | Trust corporate cert in OS truststore (no longer permitted to flip `dotspacemacs-elpa-https`). |
| `package-install-file` "buffer modified" prompt during native-comp install (#15143) | Quelpa interaction; mostly fixed upstream in Emacs 28 branch. |
| treemacs auto-loading regressions | Pin treemacs via custom recipe in `dotspacemacs-additional-packages`. |
| evil-escape `jj` triggers in visual state | Use `fd` or `jk` instead. |
| Window decoration/title-bar matching | `(set-frame-parameter nil 'ns-transparent-titlebar t)` (macOS) + `dotspacemacs-undecorated-at-startup`. |

### 3.3 Org-mode power-user setups

Common knobs (compiled from public dotfiles + the Org layer README):

```elisp
(org :variables
     org-enable-roam-support t
     org-enable-roam-ui t
     org-enable-roam-protocol t
     org-enable-org-journal-support t
     org-journal-dir "~/org/journal/"
     org-journal-file-format "%Y-%m-%d.org"
     org-journal-enable-agenda-integration t
     org-enable-github-support t
     org-enable-bootstrap-support t
     org-enable-reveal-js-support t
     org-enable-epub-support t
     org-enable-jira-support t
     jiralib-url "https://corp.atlassian.net:443"
     org-enable-notifications t
     org-start-notification-daemon-on-startup t
     org-enable-sticky-header t
     org-want-todo-bindings t
     org-projectile-file "TODOs.org")
```

In `user-config`:

```elisp
(with-eval-after-load 'org
  (setq org-todo-keywords '((sequence "TODO" "NEXT" "WAIT" "|" "DONE" "CANCELLED")))
  (setq org-refile-targets '((nil :maxlevel . 9)
                             (org-agenda-files :maxlevel . 9)))
  (setq org-refile-use-outline-path t)
  (setq org-outline-path-complete-in-steps nil)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (shell . t) (python . t) (sql . t) (plantuml . t))))
```

Roam V2 power-users typically pair with `org-fc` (spaced repetition), `org-noter` (PDF annotations), `bibtex-completion` + `org-ref` for academic workflows.

### 3.4 Language-stack patterns

* **LSP**: enabling the `lsp` layer auto-loads `syntax-checking` and `auto-completion`. Knobs commonly set: `lsp-modeline-diagnostics-enable`, `lsp-modeline-diagnostics-scope`, `lsp-modeline-code-actions-enable`, `lsp-headerline-breadcrumb-enable`, `lsp-ui-doc-{position,delay,max-width}`, `lsp-enable-file-watchers`, `lsp-idle-delay`.
* **Tree-sitter**: layer `+tools/tree-sitter` (legacy `emacs-tree-sitter` package). For Emacs 29+, users frequently add the `treesit-auto` package via `dotspacemacs-additional-packages` and rely on built-in `treesit.el`.
* **DAP**: layer `+tools/dap` provides `dap-mode`. Convention: enable per-language debug adapter via `(dap :variables dap-python-debugger 'debugpy)`.
* **Compleseus + LSP**: `consult-lsp` widely paired in fork dotfiles.

### 3.5 Keybinding remap philosophies

Per `CONVENTIONS.org`:

| Reserved prefix | Purpose |
|---|---|
| `SPC o` | User custom bindings (global-map) |
| `SPC m o` | User custom bindings in major modes |
| `SPC m h` | Header/section commands |
| `SPC m i` | Insertion of common elements |
| `SPC m x` | Region manipulation |
| `SPC m t` | Test execution / table commands |
| `SPC m E` | Error management |
| `SPC m r` | Refactoring |
| `SPC m c` | Compile |
| `SPC m d` | Debug |
| `SPC m =` | Format |
| `SPC m g` | Goto |

Common extension patterns:

```elisp
(spacemacs/set-leader-keys
  "oc" 'org-capture
  "oa" 'org-agenda
  "of" 'find-file-in-project
  "ot" 'org-todo-list
  "op" 'org-pomodoro)

(spacemacs/set-leader-keys-for-major-mode 'clojure-mode
  "ec" 'cider-eval-defun-at-point)
```

For multi-key chord setup (`key-chord`), users typically wrap with `with-eval-after-load 'evil` and bind only outside insert state.

### 3.6 Performance-tuning recipes

Recurring patterns:

```elisp
;; In dotspacemacs/init OR an early-init.el companion:
dotspacemacs-gc-cons '(200000000 0.1)
dotspacemacs-read-process-output-max (* 4 1024 1024)
dotspacemacs-loading-progress-bar nil
dotspacemacs-enable-package-quickstart t
dotspacemacs-line-numbers '(:relative t :disabled-for-modes
                            org-mode dired-mode pdf-view-mode
                            :size-limit-kb 1000)

;; In dotspacemacs/user-config:
(setq lsp-idle-delay 0.5
      lsp-enable-file-watchers nil
      lsp-completion-provider :capf
      gc-cons-threshold 200000000)
(add-hook 'emacs-startup-hook
  (lambda () (message "Spacemacs ready in %.2fs (%d GCs)"
                      (float-time (time-subtract after-init-time before-init-time))
                      gcs-done)))
```

For native-comp users, adding to `user-init`:
```elisp
(when (boundp 'native-comp-eln-load-path)
  (add-to-list 'native-comp-eln-load-path
               (expand-file-name "eln-cache/" user-emacs-directory)))
(setq native-comp-async-report-warnings-errors 'silent)
```

---

## 4. Forking & Branding — LatticeProtocol

### Part 4A: Concept-level Touchpoint Map

Every imprint surface, the file(s) it touches, and the rebrand consideration.

#### 4A.1 Banner

* **Text banners**: `core/banners/000-banner.txt` … `004-banner.txt`. Plain ASCII; conventional width 75 columns (`spacemacs-buffer--banner-length` defconst, ~75–80). For LatticeProtocol, ship `core/banners/000-banner.txt` (replace) and 1–4 alternates.
* **Image banner**: `core/banners/img/spacemacs.png` (and `.svg`, `.icns`). PNG ≈ 200 × 200 px; SVG variant for scaling. Replace with `lattice.png` and update `spacemacs-buffer//choose-banner` only if you want to rename the symbol; otherwise overwrite the file path the `'official` symbol resolves to (defined in `spacemacs-buffer//choose-banner` as `(concat spacemacs-banner-directory "img/spacemacs.png")`).
* **Title under banner**: `spacemacs-buffer-logo-title` defconst in `core/core-spacemacs-buffer.el` — `"[S P A C E M A C S]"`. Change to `"[L A T T I C E   P R O T O C O L]"`.
* **Selection logic**: file is `spacemacs-buffer//choose-banner`; specials at `998` (cat) / `999` (doge) — re-purpose or remove for branding.
* **Banner directory constant**: `spacemacs-banner-directory` (defined relative to `spacemacs-start-directory`).

#### 4A.2 Splash / dashboard widgets

* Buttons inserted by `spacemacs-buffer//insert-buttons` in `core/core-spacemacs-buffer.el`. Modify to add a "[LatticeProtocol Docs]" button beside `[?]` / `[Update Packages]`.
* Footer text: `spacemacs-buffer//insert-footer` (Spacemacs uses the heart emoji + "Made with ♥"); rebrand here.
* Sections/widgets: extend by appending to `spacemacs-buffer//startup-hook` or by injecting into `spacemacs-buffer//insert-startup-lists`.

#### 4A.3 Distribution layer pattern

Anatomy of `layers/+distributions/spacemacs/`:
* `packages.el`: `(setq spacemacs-packages '(…))` + `init-…` for each.
* (sometimes) `config.el`, `funcs.el`, `keybindings.el`, `README.org`.

Anatomy of `layers/+distributions/spacemacs-bootstrap/packages.el`:
```elisp
(setq spacemacs-bootstrap-packages
  '((async :step bootstrap)
    (bind-map :step bootstrap)
    (bind-key :step bootstrap)
    (diminish :step bootstrap)
    (evil :step bootstrap)
    (hydra :step bootstrap)
    (use-package :step bootstrap)
    (which-key :step bootstrap)))
```

`spacemacs-bootstrap` is **always** declared by `core-configuration-layer.el::configuration-layer//declare-default-layers`.

**To add `+latticeprotocol`**:
* Create `layers/+distributions/spacemacs-latticeprotocol/{packages.el,config.el,keybindings.el,README.org}`.
* Add it as a value for `dotspacemacs-distribution`. Spacemacs' code path:
  ```elisp
  (let ((distribution (if configuration-layer-force-distribution
                          configuration-layer-force-distribution
                        dotspacemacs-distribution)))
    (unless (eq 'spacemacs-bootstrap distribution)
      (configuration-layer/declare-layer distribution)))
  ```
  works for any directory under `layers/+distributions/`, so a custom symbol Just Works.
* For LatticeProtocol, depend on `spacemacs` via `(configuration-layer/declare-layer-dependencies '(spacemacs))` in `layers.el` to inherit the full distribution and only **override** what you want.

#### 4A.4 Default theme

* Ship `latticeprotocol-theme` as a `:location local` package or as a separate ELPA-style package.
* Place sources under `layers/+themes/latticeprotocol-theme/local/latticeprotocol-theme/latticeprotocol-theme.el`.
* In the dotspacemacs template, prepend it to `dotspacemacs-themes`:
  ```elisp
  dotspacemacs-themes
  '((latticeprotocol-dark  :location (recipe :fetcher local))
    (latticeprotocol-light :location (recipe :fetcher local))
    spacemacs-dark spacemacs-light)
  ```
* Internal default — set `spacemacs--default-user-theme` in `core/core-themes-support.el` for first-launch rendering before the user dotfile is present.

#### 4A.5 Branding strings

| String / variable | File | Notes |
|---|---|---|
| `spacemacs-version` | `core/core-versions.el` (defined as `defconst`) | The version number string. Mirror as `latticeprotocol-version`. |
| `spacemacs-repository`, `spacemacs-repository-owner`, `spacemacs-checkversion-remote`, `spacemacs-checkversion-branch` | `core/core-spacemacs.el` | Update for self-hosted update-check (or set `dotspacemacs-check-for-update nil` and remove). |
| `spacemacs-buffer-logo-title` | `core/core-spacemacs-buffer.el` | Title under banner. |
| `spacemacs-buffer-name` | `core/core-spacemacs-buffer.el` (`*spacemacs*`) | Rename to `*latticeprotocol*`. |
| Frame title prefix | `dotspacemacs-frame-title-format` template | Distribute a template with `%I@%S [LP]`. |
| Modeline branding | `spaceline` / custom segment | Add an `lp` segment with `spaceline-define-segment lp …`. |
| `display-startup-echo-area-message` | `core-spacemacs.el` | Returns "Spacemacs is ready." — rebrand. |
| `spacemacs-version-check-lighter` | `core/core-release-management.el` | Modeline new-version glyph. |

#### 4A.6 Dotfile template

* File: `core/templates/dotspacemacs-template.el` (file alias `.spacemacs.template` in older revisions).
* Rendered to `~/.spacemacs` by `dotspacemacs/install` (interactive, asks editing style + distribution) and `dotspacemacs/maybe-install-dotfile` (called by `spacemacs/init` when no dotfile exists).
* Changes you typically make for a fork: header comment block, default `dotspacemacs-distribution 'latticeprotocol`, default `dotspacemacs-configuration-layers`, default `dotspacemacs-themes`, default `dotspacemacs-startup-banner`, default `dotspacemacs-frame-title-format`.

#### 4A.7 Bundled layer set / opinionated defaults

* The `spacemacs` distribution's `packages.el` lists ~25 base layers (`better-defaults`, `spacemacs-defaults`, `spacemacs-completion`, `spacemacs-editing`, `spacemacs-editing-visual`, `spacemacs-evil`, `spacemacs-language`, `spacemacs-layouts`, `spacemacs-misc`, `spacemacs-modeline`, `spacemacs-navigation`, `spacemacs-org`, `spacemacs-project`, `spacemacs-purpose`, `spacemacs-visual`).
* For LatticeProtocol, fork `spacemacs` distribution into `spacemacs-latticeprotocol` and curate the layer list in its `packages.el`. Use `(configuration-layer/declare-layer-dependencies …)` rather than copy-paste to keep upstream churn manageable.

#### 4A.8 Repository strategy

| Path | Strategy |
|---|---|
| `core/`, `layers/+*` (other than your fork's distribution) | **Track upstream `develop`**; rebase regularly. |
| `core/templates/dotspacemacs-template.el` | **Pin / fork**; conflict-prone — expect frequent upstream updates. |
| `core/banners/`, `core/core-spacemacs-buffer.el`, `core/core-versions.el` | **Pin** with light merge. |
| `layers/+distributions/spacemacs-latticeprotocol/` | **New, fully owned**. |
| `layers/+themes/latticeprotocol-theme/` | **New, fully owned**. |
| Namespace conventions | All custom functions prefixed `lp/` or `latticeprotocol/`; no collisions with `spacemacs/`, `spacemacs|`, `spacemacs-`. |

Cadence: rebase weekly against `upstream/develop`; cut a `release/lattice-vX.Y` branch quarterly.

#### 4A.9 Package archive overrides

* `configuration-layer-elpa-archives` is the override surface (in `dotspacemacs/user-init`).
* For a self-hosted Spacelpa-style mirror, set `dotspacemacs-use-spacelpa t` and host a tarball at `<mirror>/spacelpa-<version>.tar`. The path is read from `configuration-layer--stable-elpa-tarball-archive`.

#### 4A.10 News / changelog mechanism

* Spacemacs stores release notes inside `core/news/`; `spacemacs-buffer//inject-version` and `spacemacs-buffer//insert-release-note` render the latest. The version-comparison key is `spacemacs-buffer--release-note-version`, persisted to `~/.emacs.d/.cache/spacemacs-buffer.el`.
* For LatticeProtocol: ship `core/news/news-<X.Y.Z>.org`; bump `latticeprotocol-version`.

#### 4A.11 Asset locations

| Asset | Path | Format |
|---|---|---|
| Image banner (default) | `core/banners/img/spacemacs.png` | PNG 256×256 typical |
| SVG banner | `core/banners/img/spacemacs.svg` | SVG |
| macOS dock icon | `core/banners/img/spacemacs.icns` | ICNS |
| Desktop launcher icon (Linux) | referenced from `~/.local/share/applications/spacemacs.desktop` | PNG/SVG |
| Text banners | `core/banners/0NN-banner.txt` | UTF-8 plain text |
| Startup buffer footer artwork | none (text only) | n/a |

#### 4A.12 License posture

* Spacemacs core is **GPLv3**. Any fork that distributes modified Spacemacs core must remain GPLv3. Layer/file headers carry `;;; License: GPLv3` and copyright `Sylvain Benner & Contributors`.
* The Spacemacs **logo** by Nasser Alshammari is **CC BY-SA 4.0**. If you replace the logo, you remove that constraint; if you re-use, keep the attribution and license-share.
* All bundled assets (banners, images) inherit licenses from their original sources. Document the LatticeProtocol license at the repo root (`COPYING.LP` or extend `LICENSE` with branded notice).
* Bundled third-party packages on MELPA/ELPA retain their own licenses; nothing changes there.

---

### Part 4B: Concrete Fork Playbook

#### 4B.1 Suggested directory layout (LatticeProtocol fork)

```
latticeprotocol/                                    ; clone of syl20bnr/spacemacs
├── README.md                                       ; rebranded
├── LICENSE                                         ; GPLv3 (preserved) + LP notice
├── CHANGELOG.lp.md
├── core/
│   ├── core-versions.el                            ; bumped: latticeprotocol-version
│   ├── core-spacemacs.el                           ; rebranded strings
│   ├── core-spacemacs-buffer.el                    ; logo-title + banner-name
│   ├── banners/
│   │   ├── img/
│   │   │   ├── latticeprotocol.png                 ; new asset
│   │   │   ├── latticeprotocol.svg
│   │   │   └── latticeprotocol.icns
│   │   ├── 000-banner.txt                          ; LP ASCII art (replaces upstream)
│   │   ├── 001-banner.txt                          ; LP variant
│   │   └── …
│   ├── news/
│   │   └── news-0.1.0.org                          ; LP release note
│   └── templates/
│       └── dotspacemacs-template.el                ; rebranded, LP defaults
├── layers/
│   ├── +distributions/
│   │   ├── spacemacs/
│   │   ├── spacemacs-base/
│   │   ├── spacemacs-bootstrap/
│   │   └── spacemacs-latticeprotocol/              ; NEW
│   │       ├── README.org
│   │       ├── layers.el
│   │       ├── packages.el
│   │       ├── config.el
│   │       └── keybindings.el
│   └── +themes/
│       └── latticeprotocol-theme/                  ; NEW
│           ├── packages.el
│           └── local/
│               └── latticeprotocol-theme/
│                   ├── latticeprotocol-dark-theme.el
│                   └── latticeprotocol-light-theme.el
├── doc/
│   └── DOCUMENTATION.lp.org                        ; supplementary
└── .github/workflows/
    ├── upstream-sync.yml                           ; weekly rebase from develop
    └── ci.yml                                      ; Makefile + tests/
```

#### 4B.2 Git setup commands

```bash
# 1. Fork on GitHub UI: github.com/syl20bnr/spacemacs → github.com/<you>/latticeprotocol
# 2. Clone with both remotes
git clone git@github.com:<you>/latticeprotocol.git
cd latticeprotocol
git remote add upstream https://github.com/syl20bnr/spacemacs.git
git fetch upstream

# 3. Track develop upstream + create your dev branch
git checkout -B lp-develop upstream/develop
git push -u origin lp-develop

# 4. Periodic sync (weekly)
git fetch upstream
git checkout lp-develop
git rebase upstream/develop          # rebase keeps history linear; use merge if you prefer audit trails
# Resolve template/banner conflicts (the canonical hot spots)
git push --force-with-lease origin lp-develop

# 5. Release branches
git checkout -b release/0.1.0 lp-develop
# tag once stable
git tag -a latticeprotocol-0.1.0 -m "LatticeProtocol 0.1.0"
git push origin latticeprotocol-0.1.0
```

End-user installation:
```bash
git clone -b lp-develop https://github.com/<you>/latticeprotocol.git ~/.emacs.d
# OR via Chemacs2 to coexist with vanilla
```

#### 4B.3 File diffs / snippets

##### Banner replacement

Replace `core/banners/000-banner.txt` with LatticeProtocol ASCII art (75-col wide). Replace `core/banners/img/spacemacs.png` with `latticeprotocol.png` (same filename to keep `'official` symbol working) **or** rename the asset and patch the lookup:

```diff
--- a/core/core-spacemacs-buffer.el
+++ b/core/core-spacemacs-buffer.el
@@
-(defconst spacemacs-buffer-logo-title "[S P A C E M A C S]"
+(defconst spacemacs-buffer-logo-title "[L A T T I C E   P R O T O C O L]"
   "The title displayed beneath the logo.")
@@
-(defconst spacemacs-buffer-name "*spacemacs*"
+(defconst spacemacs-buffer-name "*latticeprotocol*"
   "Name of the spacemacs buffer.")
@@
-     ((eq banner 'official)
-      (concat spacemacs-banner-directory "img/spacemacs.png"))
+     ((eq banner 'official)
+      (concat spacemacs-banner-directory "img/latticeprotocol.png"))
```

##### Distribution layer creation

`layers/+distributions/spacemacs-latticeprotocol/layers.el`:
```elisp
;;; layers.el --- LatticeProtocol Distribution Layer File
(configuration-layer/declare-layer-dependencies '(spacemacs))
```

`layers/+distributions/spacemacs-latticeprotocol/packages.el`:
```elisp
;;; packages.el --- LatticeProtocol Distribution packages
(defconst spacemacs-latticeprotocol-packages
  '(latticeprotocol-theme
    (lp-welcome :location local)))

(defun spacemacs-latticeprotocol/init-latticeprotocol-theme ()
  (use-package latticeprotocol-theme :defer t))

(defun spacemacs-latticeprotocol/init-lp-welcome ()
  (use-package lp-welcome
    :commands (lp/show-welcome)
    :init
    (add-hook 'spacemacs-post-user-config-hook #'lp/show-welcome)))
```

`layers/+distributions/spacemacs-latticeprotocol/config.el`:
```elisp
(setq-default
 dotspacemacs-themes '(latticeprotocol-dark latticeprotocol-light spacemacs-dark)
 dotspacemacs-startup-banner 'official
 dotspacemacs-frame-title-format "%I@%S [LP]"
 dotspacemacs-mode-line-theme '(spacemacs :separator slant :separator-scale 1.4))
```

`layers/+distributions/spacemacs-latticeprotocol/keybindings.el`:
```elisp
(spacemacs/declare-prefix "ol" "lattice-protocol")
(spacemacs/set-leader-keys
  "olh" #'lp/open-handbook
  "olu" #'lp/check-updates)
```

`layers/+distributions/spacemacs-latticeprotocol/README.org`:
```org
#+TITLE: LatticeProtocol distribution layer

* Description
This is the LatticeProtocol distribution. Set =dotspacemacs-distribution= to
=spacemacs-latticeprotocol= to enable.

* Features
- LatticeProtocol theme (dark + light)
- Branded startup buffer
- =SPC o l= prefix for LP commands
```

##### `core/templates/dotspacemacs-template.el` fork

```diff
@@
-    ;; Base distribution to use. This is a layer contained in the directory
-    ;; `+distribution'. For now available distributions are `spacemacs-base'
-    ;; or `spacemacs'. (default 'spacemacs)
-    dotspacemacs-distribution 'spacemacs
+    ;; Base distribution to use. Available: `spacemacs-base', `spacemacs',
+    ;; `spacemacs-latticeprotocol'. (default 'spacemacs-latticeprotocol)
+    dotspacemacs-distribution 'spacemacs-latticeprotocol
@@
-    dotspacemacs-themes '(spacemacs-dark
-                          spacemacs-light)
+    dotspacemacs-themes '(latticeprotocol-dark
+                          latticeprotocol-light
+                          spacemacs-dark)
@@
-    dotspacemacs-frame-title-format "%I@%S"
+    dotspacemacs-frame-title-format "%I@%S [LP]"
```

##### Version-string changes

`core/core-versions.el`:
```diff
-(defconst spacemacs-version "0.999.0")
+(defconst spacemacs-version "0.999.0")            ; preserve for upstream code
+(defconst latticeprotocol-version "0.1.0"
+  "Current version of LatticeProtocol.")
```

`core/core-spacemacs-buffer.el` (version line):
```diff
-(format "%s@%s (%s)"
-        spacemacs-version
+(format "LP %s · spacemacs %s@%s (%s)"
+        latticeprotocol-version
+        spacemacs-version
         emacs-version
         dotspacemacs-distribution)
```

`core/core-spacemacs.el` (release-management remote):
```diff
-(defconst spacemacs-repository "spacemacs")
-(defconst spacemacs-repository-owner "syl20bnr")
-(defconst spacemacs-checkversion-branch "master")
+(defconst spacemacs-repository "latticeprotocol")
+(defconst spacemacs-repository-owner "<your-org>")
+(defconst spacemacs-checkversion-branch "lp-stable")
```

##### Default theme integration

`layers/+themes/latticeprotocol-theme/packages.el`:
```elisp
(defconst latticeprotocol-theme-packages
  '((latticeprotocol-theme :location local)))

(defun latticeprotocol-theme/init-latticeprotocol-theme ()
  (use-package latticeprotocol-theme :defer t))
```

`layers/+themes/latticeprotocol-theme/local/latticeprotocol-theme/latticeprotocol-dark-theme.el`:
```elisp
;;; latticeprotocol-dark-theme.el --- LatticeProtocol dark theme  -*- lexical-binding: t -*-
(deftheme latticeprotocol-dark "LatticeProtocol dark theme.")
(let ((bg "#0a0e14") (fg "#e6e6e6") (accent "#7dd3fc"))
  (custom-theme-set-faces
   'latticeprotocol-dark
   `(default ((t (:background ,bg :foreground ,fg))))
   `(cursor  ((t (:background ,accent))))
   `(mode-line ((t (:background ,accent :foreground ,bg :box nil))))
   `(font-lock-keyword-face ((t (:foreground ,accent :weight bold))))))
(provide-theme 'latticeprotocol-dark)
```

##### Welcome / news widget

`layers/+distributions/spacemacs-latticeprotocol/local/lp-welcome/lp-welcome.el`:
```elisp
;;; lp-welcome.el --- LatticeProtocol welcome buffer hook  -*- lexical-binding: t -*-
(defvar lp-welcome-shown-version nil)

(defun lp/show-welcome ()
  "Show the LatticeProtocol welcome banner once per version."
  (unless (equal lp-welcome-shown-version latticeprotocol-version)
    (with-current-buffer (get-buffer-create "*LP Welcome*")
      (erase-buffer)
      (insert (format "Welcome to LatticeProtocol %s\n\n" latticeprotocol-version))
      (insert-file-contents (concat user-emacs-directory
                                    "core/news/news-"
                                    latticeprotocol-version ".org"))
      (org-mode)
      (display-buffer (current-buffer)))
    (setq lp-welcome-shown-version latticeprotocol-version)))
(provide 'lp-welcome)
```

#### 4B.4 Build / test / release workflow

**Local testing**:
```bash
# Smoke test in isolation
HOME=$(mktemp -d) emacs --eval "(progn (setq user-emacs-directory \"$PWD/\") (load-file \"$PWD/init.el\"))"

# Layer tests (Spacemacs uses Makefiles per layer under tests/)
cd tests/<layer>; make

# Check dotfile validity
emacs -nw -Q -l init.el --eval "(dotspacemacs/test-dotfile)"
```

**CI** (`.github/workflows/ci.yml`) — minimum:
* Matrix on Emacs 28.2, 29.x, 30 snapshot.
* Run `make -C tests/<layer>` for the LP distribution and theme layers.
* Lint with `package-lint` / `byte-compile-file` for new files.
* Headless smoke: launch with `--batch -l init.el`.

**Upstream sync** (`.github/workflows/upstream-sync.yml`):
* Weekly cron: `git fetch upstream develop` → `git rebase upstream/develop` on a synthetic branch → open PR with conflict report.

**Release**:
1. Bump `latticeprotocol-version` in `core/core-versions.el`.
2. Add `core/news/news-<X.Y.Z>.org`.
3. Tag `latticeprotocol-X.Y.Z`.
4. Update `lp-stable` branch (mirror of tag) for `dotspacemacs-check-for-update` consumers.

#### 4B.5 Rebase strategy & conflict-prone files

**Hot list** (expect conflicts on most upstream pulls):

| File | Conflict reason |
|---|---|
| `core/templates/dotspacemacs-template.el` | Variables added/renamed/reordered upstream every release. |
| `core/core-spacemacs-buffer.el` | Banner / startup-buffer logic actively maintained. |
| `core/core-spacemacs.el` | Branding strings + lifecycle constants. |
| `core/core-versions.el` | Version bumps every release. |
| `core/core-configuration-layer.el` | Distribution-resolution code. |
| `layers/+distributions/spacemacs/packages.el` | Layer set evolves. |
| `core/banners/` | Less frequent, but image swaps will conflict. |

**Mitigations**:
* Keep all branding overrides in **separate, additive files** wherever possible: a `core/lp-branding.el` loaded at the bottom of `core/core-spacemacs-buffer.el` (single one-line patch upstream) that redefines `spacemacs-buffer-logo-title`, `spacemacs-buffer//choose-banner`, etc. via `defvar`/`fset`. This reduces the surface that conflicts on every rebase.
* Use a `.gitattributes` `merge=ours` for files you fully own (the LP distribution layer, the LP theme).
* Maintain a single-commit "branding patch" on top of `upstream/develop`, with a script that applies it (`scripts/lp-rebrand.sh`); rebase that patch, never the directory itself.
* Pin upstream commits in a `UPSTREAM_REV` file; bump only after CI passes, so rebases are deterministic.

**Conflict-prone variable additions on the template** — use a programmatic generator: when upstream adds a new `dotspacemacs-*`, your `scripts/regenerate-template.el` re-runs `(dotspacemacs/install)` against an upstream copy, then patches the LP-specific defaults via `sed`/`replace-string`. This isolates the divergence to a generator script rather than the rendered template.

**Namespace hygiene** — to avoid collision with future upstream symbols:
* All custom functions: `lp/…`, `lp//…` (private), `latticeprotocol-…`.
* All custom variables: `latticeprotocol-…` or `dotspacemacs-lp-…` (do **not** introduce `dotspacemacs-…` symbols, since those have a privileged scan in `dotspacemacs/init`).
* Custom macros: `lp|…` mirroring the `spacemacs|` convention.
* Custom prefix `SPC o l` is reserved for users by convention (`SPC o`); LatticeProtocol owns it because the fork *is* the user-facing surface — but never bind under `SPC h`, `SPC f`, `SPC b`, `SPC p`, `SPC m`, `SPC w`, `SPC SPC`, `SPC :`, or root SPC keys, all of which Spacemacs reserves.

---

## Reference repos (operator-supplied)

- **Lattice Protocol runtime**: https://github.com/LatticeProtocol/lattice-protocol
- **Agentic-DNA template**: https://github.com/LatticeProtocol/adna (alias for `Agentic-DNA`)

These repos ground the LP-stack positioning of this fork. See `what/standard/lp-positioning.md` for how Spacemacs.aDNA fits in.
