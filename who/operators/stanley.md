---
type: operator
name: Stanley
status: active
created: 2026-05-03
updated: 2026-05-08
last_edited_by: agent_stanley
hostname: null
primary_models:
  - claude-opus-4-7
  - claude-sonnet-4-6
  - claude-haiku-4-5
secondary_models:
  - llama (local)
  - ollama (local)
layer_preferences:
  - lsp
  - python
  - typescript
  - rust
  - org
  - adna
  - markdown
os: macOS
shell: zsh
telemetry_consent: true
telemetry_classes:
  friction_signal: true
  adr_proposal: true
  customization_share: false
  perf_metric: false
tags: [operator, stanley, daedalus, mac, ml_ops]
---

# Operator profile — Stanley

## Role

Single-operator owner of `Spacemacs.aDNA`. Genesis architect (2026-05-03). Customizations carried in `what/local/operator.private.el` and `what/local/machine.pins.md` once first install runs.

## Workflow context

- Lives in `~/lattice/` workspace alongside other aDNA vaults (science_stanley, RareHarness, RareArchive, WilhelmAI, VideoForge, etc.)
- Daily work spans federated ML, biomedical pipelines, agentic-coding, aDNA context-graph editing
- Uses Claude Code as primary agentic interface (the `SPC c c` Spacemacs binding pins to current aDNA root)
- Obsidian for visual graph navigation (round-trip hooks in `what/standard/obsidian-coupling.md` activate when both open)

## Customizations carried in local layer

To be populated when `skill_install` runs and `what/local/` is bootstrapped from `what/local/*.example` templates.

## Mission p3_01_dotfile_entry_lifecycle (closed 2026-05-06)

### Knob A — Dotfile location
- **Decision**: `$SPACEMACSDIR` → vault root (`~/lattice/Spacemacs.aDNA/`). `init.el` rendered at vault root by `skill_deploy` (gitignored). `dotspacemacs-directory` auto-equals vault root.
- **Reason**: Fully self-contained vault deployment — any lattice user clones Spacemacs.aDNA and runs `skill_install`; only `export SPACEMACSDIR=...` lands in their shell profile. All config is vault-resident; `~/.emacs.d/` holds only the Spacemacs framework + packages.

### Knob B — user-env usage
- **Decision**: Keep `(spacemacs/load-spacemacs-env)` default. Add `what/local/.spacemacs.env.example` template. Optionally augment with `exec-path-from-shell-copy-envs` for PATH portability in GUI Emacs.
- **Reason**: With Knob A, `.spacemacs.env` naturally lives at vault root (gitignored, operator-private). No change to function body needed at this time.

### Knob C — user-init / user-config landing zone rule
- **Decision**: Three-line rule: (1) ELPA/archive config → `user-init`; (2) mode hooks that must fire on command-line-opened files → `user-init` (FAQ caveat, §2.4 position 4 vs 13); (3) everything else → `user-config`.
- **Reason**: Maps directly to §2.4 lifecycle positions. Simple enough to apply without consulting reference each time.

### Knob D — user-config section structure
- **Decision**: Topical `;;;` section headers in `user-config` mapped 1:1 to P3 missions (§P3-01 through §P3-11). `with-eval-after-load` wrappers within each section. Empty sections get a `(populated by mission P3-XX)` stub.
- **Reason**: Each P3 mission owns its section. No ambiguity about where to add new config.

### Knob E — dotspacemacs-directory for asset paths
- **Decision**: Use `(list (concat dotspacemacs-directory "what/local/"))` for `dotspacemacs-configuration-layer-path`. Use `(concat dotspacemacs-directory "what/local")` for private-elisp path. Remove `{{VAULT_ROOT}}` / `{{LOCAL_LAYER_DIR}}` / `{{LAYER_PATH_LIST}}` substitutions from `skill_deploy`. Banner stays `'official` — custom ASCII assets in `what/standard/assets/` deferred to P4 fork branding.
- **Reason**: With Knob A, `dotspacemacs-directory` IS the vault root. Template is portable across operators with no machine-specific render step. Banner reverted to official during P3-01 session — operator prefers standard Spacemacs logo at v0.x stage.

## Mission p3_02_dotspacemacs_variables (completed 2026-05-08)

### §1.3.1 Layer / package management — CONFIRMED (2026-05-07)

All current template values confirmed correct. No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-excluded-packages` | `'()` — leave empty | No current pain point; exclusions can cause subtle breakage if layers depend on them internally |
| `dotspacemacs-frozen-packages` | `'()` — leave empty | Freeze reactively (after a bad MELPA update breaks something); pre-emptive freezing creates maintenance debt |
| `dotspacemacs-distribution` | `'spacemacs` — confirmed | Home buffer + `spacemacs/*` namespace used by adna layer; `spacemacs-base` saves ~200ms but not worth the friction |
| All other §1.3.1 vars | Confirmed at template defaults | `layer-path`, `lazy-install`, `install-packages`, `additional-packages` all already correct from pre-flight |

### §1.3.2 ELPA / version / dump — CONFIRMED + 2 changes (2026-05-07)

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-elpa-https` | `t` — confirmed | Keep; forced on `develop` for security |
| `dotspacemacs-elpa-timeout` | `5` — confirmed | Adequate on reliable connections |
| `dotspacemacs-gc-cons` | `'(200000000 0.1)` — **changed** (was 100 MB) | 2× default; heavy LSP + ML use makes GC pauses noticeable at 100 MB; ADR-016 |
| `dotspacemacs-read-process-output-max` | `(* 4 1024 1024)` — **changed** (was 1 MB) | 4× default; LSP throughput on large Python/TypeScript/Rust projects; ADR-016 |
| `dotspacemacs-use-spacelpa` | `nil` — confirmed | Experimental; vault pins SHA via machine.pins.md |
| `dotspacemacs-verify-spacelpa-archives` | `t` — confirmed | Moot with Spacelpa off but correct default |
| `dotspacemacs-check-for-update` | `nil` — confirmed | Vault-pinned SHA governs updates; not background polling |
| `dotspacemacs-elpa-subdirectory` | `'emacs-version` — confirmed | Per-version isolation prevents stale byte-compiled packages |

Both changes landed in `what/standard/dotfile.spacemacs.tmpl` (standard template, ADR-016). No operator-private overrides needed.

### §1.3.3 Editing style & leaders — CONFIRMED (2026-05-07)

All variables confirmed at template defaults. No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-editing-style` | `'vim` — confirmed | Modal editing is the battle-station baseline |
| `dotspacemacs-leader-key` | `"SPC"` — confirmed | Standard; Transient tree (ADR-013) built on it |
| `dotspacemacs-emacs-command-key` | `"SPC"` — confirmed | Standard (`SPC SPC` → `M-x`) |
| `dotspacemacs-ex-command-key` | `":"` — confirmed | Standard Vim ex-command key |
| `dotspacemacs-emacs-leader-key` | `"M-m"` — confirmed | Conventional emacs/insert-state fallback |
| `dotspacemacs-major-mode-leader-key` | `","` — confirmed | Ergonomic major-mode leader in normal state |
| `dotspacemacs-major-mode-emacs-leader-key` | `"C-M-m"` — confirmed | TTY default; `,` covers this in normal state |
| `dotspacemacs-distinguish-gui-tab` | `nil` — confirmed | No conflicting TAB/C-i bindings to separate |

### §1.3.4 Startup buffer / banner / lists — CONFIRMED (2026-05-07)

All variables confirmed at template defaults. No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-startup-banner` | `'official` — confirmed | Pre-confirmed P3-01 Knob E; custom assets deferred to P4 |
| `dotspacemacs-startup-banner-scale` | `'auto` — confirmed | No fixed scale needed |
| `dotspacemacs-startup-lists` | `'((recents . 5) (projects . 7))` — confirmed | Agenda/todos deferred; easy to add later |
| `dotspacemacs-startup-buffer-responsive` | `t` — confirmed | Re-render on resize |
| `dotspacemacs-show-startup-list-numbers` | `t` — confirmed | Numeric keyboard jump |
| `dotspacemacs-startup-buffer-show-version` | `t` — confirmed | Useful at a glance |
| `dotspacemacs-startup-buffer-multi-digit-delay` | `0.4` — confirmed | Snappy enough |
| `dotspacemacs-startup-buffer-show-icons` | `nil` — confirmed | Defer to P4; icon font mixing adds install complexity |
| `dotspacemacs-new-empty-buffer-major-mode` | `'text-mode` — confirmed | org-mode surprising for scratch |
| `dotspacemacs-scratch-mode` | `'text-mode` — confirmed | org-roam is better home for persistent notes |
| `dotspacemacs-scratch-buffer-persistent` | `nil` — confirmed | org-roam handles persistent notes |
| `dotspacemacs-scratch-buffer-unkillable` | `nil` — confirmed | No accidental-kill habit to guard against |
| `dotspacemacs-initial-scratch-message` | `nil` — confirmed | No noise |

### §1.3.5 Themes / modeline / fonts / cursor — CONFIRMED (2026-05-07)

All variables confirmed at template values. No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-themes` | `'(spacemacs-dark spacemacs-light)` — confirmed | Pre-confirmed ADR-012 |
| `dotspacemacs-mode-line-theme` | `'doom` — confirmed | Pre-confirmed ADR-012; adna vault segment deferred to P4 |
| `dotspacemacs-colorize-cursor-according-to-state` | `t` — confirmed | Visual evil-state indicator is useful |
| `dotspacemacs-default-font` | `'("Source Code Pro" :size 15.0 ...)` — confirmed | Pre-confirmed ADR-012; belt-and-suspenders guard in §P3-06 |
| `dotspacemacs-default-icons-font` | `'all-the-icons` — confirmed (implicit) | Consistent with standard template; nerd-icons revisit deferred to P4 |

### §1.3.6 Layouts / sessions — CONFIRMED (2026-05-07)

All variables confirmed at template defaults. No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-default-layout-name` | `"Default"` — confirmed | Custom layout name deferred to P4; layout intelligence mission will design this deliberately |
| `dotspacemacs-display-default-layout` | `nil` — confirmed | Reduces modeline noise; appears on non-default layouts |
| `dotspacemacs-auto-resume-layouts` | `nil` — confirmed | Fresh workspace per session; `SPC l L` restores manually |
| `dotspacemacs-auto-generate-layout-names` | `nil` — confirmed | Named layouts more intentional; auto-naming produces noise |

Note: layout system will be extended in P4 via the Agentic Layout Intelligence mission (see `how/backlog/idea_agentic_layout_system.md`).

### §1.3.7 Files / autosave / rollback — CONFIRMED (2026-05-08)

All 4 variables confirmed at template defaults. No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-large-file-size` | `1` — confirmed | 1 MB is conservative; revisit if large logs/CSVs become routine in Spacemacs |
| `dotspacemacs-auto-save-file-location` | `'cache` — confirmed | Keeps project trees clean; `~/.emacs.d/cache/auto-save/` out of sight |
| `dotspacemacs-max-rollback-slots` | `5` — confirmed | Adequate history depth; not a routine rollback workflow |
| `dotspacemacs-enable-paste-transient-state` | `nil` — confirmed | Standard vim paste behavior; kill-ring cycling via `C-j`/`C-k` adds keybinding surface with low ROI |

### §1.3.8 which-key / cycling / windowing — CONFIRMED (2026-05-08)

All 8 variables confirmed at defaults (4 existing + 4 new). No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-which-key-delay` | `0.4` — confirmed | Snappy without being intrusive |
| `dotspacemacs-which-key-position` | `'bottom` — confirmed | Standard; full-width visibility |
| `dotspacemacs-switch-to-buffer-prefers-purpose` | `nil` — confirmed | No purpose-based window management in use |
| `dotspacemacs-loading-progress-bar` | `t` — confirmed | Useful feedback during boot |
| `dotspacemacs-enable-cycling` | `nil` — confirmed (new) | vim `C-o`/`C-i` cover history navigation; cycling adds keybinding surface |
| `dotspacemacs-maximize-window-keep-side-windows` | `t` (default) — confirmed (new) | treemacs preserved on `SPC w m`; important for agentic coding flow |
| `dotspacemacs-enable-load-hints` | `nil` — confirmed (new) | macOS no-op (Windows-only optimization) |
| `dotspacemacs-enable-package-quickstart` | `nil` — confirmed (new) | homebrew + custom layer setup prone to stale-autoload issues with quickstart |

### §1.3.9 Frame appearance — CONFIRMED + 1 change (2026-05-08)

10 existing variables confirmed at template defaults. 2 new variables added.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-fullscreen-at-startup` | `nil` — confirmed | Maximize (`t` for `maximized-at-startup`) preferred over native fullscreen |
| `dotspacemacs-fullscreen-use-non-native` | `nil` — confirmed | Not using fullscreen; moot |
| `dotspacemacs-maximized-at-startup` | `t` — confirmed | Full workspace real estate on boot |
| `dotspacemacs-undecorated-at-startup` | `nil` — confirmed | Keep title bar for macOS window management |
| `dotspacemacs-active-transparency` | `90` — confirmed | Subtle transparency; keep for now |
| `dotspacemacs-inactive-transparency` | `90` — confirmed | Matching inactive opacity |
| `dotspacemacs-background-transparency` | `100` — **changed** (default 90) | Opaque background; no bleed-through behind code text; ADR-020 |
| `dotspacemacs-scroll-bar-while-scrolling` | `t` (default) — confirmed (new) | Autohide scrollbar is low-clutter position indicator |
| `dotspacemacs-show-transient-state-title` | `t` — confirmed | Readable TS header |
| `dotspacemacs-show-transient-state-color-guide` | `t` — confirmed | Color hints in TS keys are helpful |
| `dotspacemacs-mode-line-unicode-symbols` | `t` — confirmed | Unicode glyphs render correctly on macOS with all-the-icons |
| `dotspacemacs-smooth-scrolling` | `t` — confirmed | No jarring recenter on scroll edge |

Change landed in `what/standard/dotfile.spacemacs.tmpl` (ADR-020).

### §1.3.10 Editing knobs — CONFIRMED (2026-05-08)

19 variables total. 15 existing (5 non-default + 10 at default) all confirmed. 4 new variables confirmed at defaults.

**Existing non-defaults confirmed:**

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-line-numbers` | `'(:relative t :enabled-for-modes prog-mode text-mode)` — confirmed | Relative line numbers in code/text; absolute elsewhere (e.g., terminals, org agenda) |
| `dotspacemacs-enable-server` | `t` — confirmed | emacsclient integration (P3-00 closed-loop validation relies on it) |
| `dotspacemacs-persistent-server` | `t` — confirmed | Quit functions keep server alive; required for emacsclient workflow |
| `dotspacemacs-search-tools` | `'("rg" "ag" "grep")` — confirmed | `ack` dropped; `rg` is the standard in lattice ML pipelines |
| `dotspacemacs-whitespace-cleanup` | `'trailing` — confirmed | Clean trailing whitespace on save; not overly aggressive |

**New variables confirmed at defaults:**

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-activate-smartparens-mode` | `t` (default) — confirmed | Auto-pairing on; strict mode off (already confirmed); right balance |
| `dotspacemacs-undo-system` | `'undo-redo` (default) — confirmed | Emacs 29+ native linear undo; evil integrates cleanly; no background process |
| `dotspacemacs-use-SPC-as-y` | `nil` (default) — confirmed | SPC is leader key; double-duty on prompts creates confusion + accidental confirmations |
| `dotspacemacs-swap-number-row` | `nil` (default) — confirmed | Standard US QWERTY layout |

## Mission p3_03_layer_anatomy_api (closed 2026-05-08)

### Knob A — Layer class for `adna` (§1.4 layer classes)
- **Decision**: Private class. `skill_install` symlinks `what/standard/layers/adna/` → `~/.emacs.d/private/layers/adna/`. Spacemacs loads it as a private layer; no `dotspacemacs-configuration-layer-path` entry needed for `adna` itself. `what/local/` path in layer-path is for operator-private custom layers, not for `adna`.
- **Reason**: Symlink deploy is the vault's canonical deploy mechanism (ADR-015). Private class is the correct Spacemacs category for vault-governed layers not contributed upstream.

### Knob B — `layers.el` (§1.4 file inventory)
- **Decision**: Add `layers.el` with `(configuration-layer/declare-layer-dependencies '(spacemacs-bootstrap))`.
- **Reason**: `keybindings.el` does `(require 'transient)` directly; transient is owned by `spacemacs-bootstrap`. `layers.el` makes the load-order dependency explicit per §1.4 standard. No functional change (spacemacs-bootstrap always loads first in practice), but documents the dependency correctly.

### Knob C — Package declaration patterns (§1.4 grammar)
- **Decision**: Fix `json` → `(json :location built-in)` in packages.el. Other declarations correct: `yaml` (ELPA, `init-yaml` owns it), `(markdown-mode :location built-in)` with `post-init-markdown-mode` (correct ownership pattern), deliberate omission of `transient`/`vterm` from packages list (owned by spacemacs-bootstrap/shell layers).
- **Reason**: Bare symbol for a built-in library is technically incorrect per §1.4 grammar and confusing to read. Aligning with the grammar standard.

### Knob D — `spacemacs|use-package-add-hook` (§1.4 hook macro)
- **Decision**: Not needed currently. `with-eval-after-load` in `post-init-markdown-mode` is the correct pattern — adna doesn't need to inject into another layer's `use-package` body.
- **Reason**: Hook macro is for cross-layer `use-package` injection (e.g., extending lsp-mode's body without touching the lsp layer). adna's markdown-mode hook is self-contained. Pattern documented for future use if adna needs to extend an upstream layer.

### Knob E — Layer `:variables` exposure (§1.4 dotspacemacs-configuration-layers grammar)
- **Decision**: Expose `adna-claude-code-command` as a `:variables` entry in the dotfile template. All other `defcustom` vars stay `defcustom`-only (configured via `what/local/operator.private.el`).
- **Reason**: `adna-claude-code-command` is the most likely to vary across machines (different PATH configurations). Exposing it as `:variables` in the template makes the override path obvious without requiring knowledge of `defcustom`. Other vars are opt-in behavioral toggles better configured in operator.private.el.

### Knob F — LP distribution layer (§1.4 layer classes, §4B fork playbook)
- **Decision**: Distribution name = `'spacemacs-latticeprotocol` (per fork-strategy.md). Stub deferred to P4-02. Structure confirmed: `layers/+distributions/spacemacs-latticeprotocol/` in fork repo, `layers.el` declares `(configuration-layer/declare-layer-dependencies '(spacemacs))`, namespace `lp/` + `latticeprotocol-`.
- **Reason**: Name follows fork-strategy.md. Stub in P4-02 aligns with the phased campaign plan.

### §1.5 API familiarity (configuration-layer/ symbols)

| Symbol | Intended usage |
|--------|----------------|
| `declare-layer-dependencies` | yes — in adna `layers.el` (this mission); in distribution `layers.el` (P4-02) |
| `declare-layer` / `declare-layers` | yes — distribution `layers.el` will use these to force-add LP-curated layers (P4-02) |
| `package-usedp` | possibly — guard adna code paths that depend on optional pkgs in future hardening missions |
| `layer-usedp` | possibly — guard LP-only behaviors if LP distribution layer is not active |
| `sync` | already using — `SPC f e R` is standard re-sync workflow |
| `create-layer` | rarely — reference scaffolding when adding new private layers |
| `update-packages` | occasionally — routine MELPA refresh |
| `rollback` | rarely — break-glass after a bad MELPA update |
| `configuration-layer-elpa-archives` | possibly — `user-init` override if internal ELPA mirror needed (L2 HPC context) |
| `load` / `load-lock-file` | no — framework-internal |
| `make-package` / `force-distribution` | no — framework-internal |

### Knob H — README.org (pre-audit F-3)
- **Decision**: Updated README.org: fixed `#+AUTHOR:` (SpaceLattice → Spacemacs), removed Phase 2/4 placeholder sections, added live implementation status table (all 5 files), updated key bindings table to 16 rows matching actual `keybindings.el`.
- **Reason**: README was written in Phase 2 as a stub. Phase 4 implementation completed 2026-05-06. ADR-017 renamed the vault; author line was never updated.

## Mission p3_04_themes_modeline_banner_startup (completed 2026-05-08)

### §1.6 Theme system depth

| Topic | Decision | Rationale |
|-------|----------|-----------|
| `theming` layer | **Add to standard** (ADR-021) | Per-theme face overrides are first-class. `theming-modifications` alist available; no overhead when empty. |
| `themes-megapack` | Skip — on-demand | No bulk install; individual alternate themes declared in `dotspacemacs-themes` on demand (P4-03). |
| Custom theme dir | `what/standard/assets/themes/` | Reserved for future in-tree themes; no action now. |

**P4-03 pre-figuring — alternate theme candidates** (intel, not binding decisions):
- `doom-one` — dark, high-contrast; similar palette to spacemacs-dark but more saturated
- `modus-vivendi` — Emacs built-in since 29; WCAG AAA accessibility; best for long sessions

### §1.7 Modeline depth (doom-modeline knobs)

| Variable | Decision | Location |
|----------|----------|----------|
| `doom-modeline-icon` | **`t`** — enabled | `what/local/operator.private.el` (requires `M-x all-the-icons-install-fonts`; standard keeps nil) |
| `doom-modeline-lsp` | `nil` — off (default) | Standard |
| `doom-modeline-env-version` | `nil` — off (default) | Standard |
| `doom-modeline-github` | `nil` — off (default) | Standard |
| Segment format string | `adna-main` confirmed (P3-preflight) | Standard; no change needed |

### §1.8 Banner system — P4-05 pre-figuring

- **v1.0 banner**: **Stay with `'official` Spacemacs image indefinitely**. P4-05 mission becomes stub/skip.
- No custom logo PNG or text-banner switch planned.

### §1.9 Frame title / which-key / transient states

| Variable | Decision | Location |
|----------|----------|----------|
| `dotspacemacs-frame-title-format` | **`'("%b [" (:eval (projectile-project-name)) "]")`** — buffer + project (ADR-022) | Standard template |
| `dotspacemacs-icon-title-format` | `nil` (default) | Standard |
| `dotspacemacs-which-key-delay` | `0.4` (default confirmed) | Standard |
| `dotspacemacs-which-key-position` | `'bottom` (default confirmed) | Standard |
| `dotspacemacs-show-transient-state-title` | `t` (default confirmed) | Standard |
| `dotspacemacs-show-transient-state-color-guide` | `t` (default confirmed) | Standard |

## Mission p3_05_editing_completion_packages (completed 2026-05-08)

### §2.1 Editing style

| Decision | Value | Rationale |
|----------|-------|-----------|
| `dotspacemacs-editing-style` | `'vim` — confirmed | Pure Evil modal editing is the battle-station baseline. Normal/Insert/Visual state model. No tunable variants needed at this time. |
| Tunable `:variables` | None | `evil-want-Y-yank-to-eol`, `evil-escape-key-sequence` — revisit in P3-06 (§2.6 Evil knobs). |
| Leader keys | All defaults confirmed | `SPC` / `M-m` / `,` — already recorded in P3-02 §1.3.3. |
| `dotspacemacs-distinguish-gui-tab` | `nil` — confirmed | No conflicting TAB/C-i bindings; already recorded in P3-02. |

**Decision**: editing style is `'vim` with no `:variables` overrides. All leader keys stay at Spacemacs defaults. Evil-escape sequence (`fd` default) and other Evil toggles deferred to P3-06 §2.6.

### §2.2 Completion stack

| Decision | Value | Rationale |
|----------|-------|-----------|
| Completion framework | `helm` — confirmed | Mature, deepest Spacemacs integration, largest action set. Already present in `dotspacemacs-configuration-layers`. |
| ivy | Not included | Redundant with helm; some Spacemacs features are helm-only anyway. |
| compleseus | Not included | Modern but still some rough edges in Spacemacs layer; reconsider post-v1.0 if compleseus layer matures. |
| "Last layer wins" rule | Noted | If multiple completion layers listed, last one wins. Template has only `helm` — no conflict possible. |

**Decision**: `helm` is the sole completion framework. No other completion layers in `dotspacemacs-configuration-layers`. Template already reflects this; no change needed.

### §2.3 Package management

| Knob | Decision | Location | Rationale |
|------|----------|----------|-----------|
| `dotspacemacs-install-packages` | `'used-only` — confirmed | `dotspacemacs/layers` | Install only packages used by active layers; delete orphans on startup. Keeps ELPA dir clean. Already confirmed in P3-02 §1.3.1. |
| `dotspacemacs-frozen-packages` | `'()` — confirmed | `dotspacemacs/layers` | No proactive freezing; freeze reactively after a bad MELPA update. Already confirmed in P3-02 §1.3.1. |
| `dotspacemacs-additional-packages` | `'()` — confirmed | `dotspacemacs/layers` | No packages outside layers at this time. |
| `configuration-layer-elpa-archives` | Default (MELPA + org + gnu) — confirmed | `dotspacemacs/user-init` | No custom mirrors needed. L2 HPC offline mirror deferred to future hardening mission if needed. |
| `package-archive-priorities` | Default (not set) — confirmed | `dotspacemacs/user-init` | MELPA naturally wins; no priority overrides required. |
| Per-package archive pinning | None at this time | `dotspacemacs-additional-packages :pin` | Use if a specific package needs MELPA-stable pin after a bad release. |
| Quelpa recipes | None at this time | `dotspacemacs-additional-packages :location (recipe ...)` | Available for packages not on MELPA; no current need. |
| Rollback | Available — noted for reference | `SPC f e r` / `configuration-layer/rollback` | Path: `~/.emacs.d/.cache/.rollback/<emacs-version>/develop/<timestamp>/`. Use after a bad MELPA update that `frozen-packages` didn't guard. |
| `dotspacemacs-use-spacelpa` | `nil` — confirmed | `dotspacemacs/init` | Experimental lock-file mechanism; vault SHA pinning via `machine.pins.md` is the governance-level equivalent. |

**Lifecycle placement rule (from Knob C, P3-01)**: `configuration-layer-elpa-archives` and `package-archive-priorities` land in `user-init` (lifecycle position 4); `dotspacemacs-frozen-packages` and `dotspacemacs-install-packages` land in `dotspacemacs/layers` (position 1). No changes to template needed — both already in correct positions.

**Finding**: All three primary P3-05 decisions (editing-style, completion-engine, install-packages) are Spacemacs defaults. No ADR issued — no drift from standard.

## Mission p3_06_perf_evil_fonts (completed 2026-05-08)

### §2.5 Performance knobs

| Knob | Decision | Rationale |
|------|----------|-----------|
| `dotspacemacs-gc-cons` | 200 MB — already locked ADR-016 | Heavy LSP/ML use; confirmed in P3-02 |
| `dotspacemacs-read-process-output-max` | 4 MB — already locked ADR-016 | LSP throughput for agentic SE; confirmed in P3-02 |
| `dotspacemacs-enable-lazy-installation` | `'unused` (default) | Install layers on first use; good balance for dev workloads |
| `dotspacemacs-enable-load-hints` | `nil` (default, skip) | macOS — Windows-only speedup, no effect here |
| `dotspacemacs-enable-package-quickstart` | `nil` (default) | Scan each boot; avoids stale autoloads after package changes |
| `dotspacemacs-byte-compile` | `nil` (default) | Native-comp (Emacs `--with-native-comp`) handles this; no manual byte-compile |

### §2.6 Evil & misc

| Knob | Decision | Rationale |
|------|----------|-----------|
| `evil-escape-key-sequence` | `fd` (default) | Fast to type, minimal conflicts; no custom override needed |
| `dotspacemacs-undo-system` | `undo-fu` (default) | Lightweight, reliable; no need for full undo-tree visualization at this time |
| `dotspacemacs-folding-method` | `'evil` (default) | Native Evil fold ops (za/zc/zo) sufficient for current workload |
| `dotspacemacs-search-tools` | `'("rg" "ag" "grep")` — already in template | rg-first; rg installed on L1 machine |

### §2.7 Font + icon

| Knob | Decision | Notes |
|------|----------|-------|
| `dotspacemacs-default-font` | `"SpaceMono Nerd Font"` @ 13.0, normal weight | ADR-023; pre-req: `brew install --cask font-space-mono-nerd-font` |
| `dotspacemacs-default-icons-font` | `'nerd-icons` | ADR-023; pre-req: `M-x nerd-icons-install-fonts` after first deploy |
| `dotspacemacs-maximized-at-startup` | `t` | Already in template — no change needed |
| `dotspacemacs-fullscreen-at-startup` | `nil` | Default; maximized (not native fullscreen) is preferred |
| `dotspacemacs-undecorated-at-startup` | `nil` | Keep macOS title bar |
| `background-transparency` | 100 | Already locked ADR-020 |

## Promotion log (local → standard)

| Date | Promoted | ADR | Notes |
|------|----------|-----|-------|
| — | — | — | — |
