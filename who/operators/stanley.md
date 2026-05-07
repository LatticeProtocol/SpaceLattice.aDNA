---
type: operator
name: Stanley
status: active
created: 2026-05-03
updated: 2026-05-07
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

Single-operator owner of `SpaceLattice.aDNA`. Genesis architect (2026-05-03). Customizations carried in `what/local/operator.private.el` and `what/local/machine.pins.md` once first install runs.

## Workflow context

- Lives in `~/lattice/` workspace alongside other aDNA vaults (science_stanley, RareHarness, RareArchive, WilhelmAI, VideoForge, etc.)
- Daily work spans federated ML, biomedical pipelines, agentic-coding, aDNA context-graph editing
- Uses Claude Code as primary agentic interface (the `SPC c c` Spacemacs binding pins to current aDNA root)
- Obsidian for visual graph navigation (round-trip hooks in `what/standard/obsidian-coupling.md` activate when both open)

## Customizations carried in local layer

To be populated when `skill_install` runs and `what/local/` is bootstrapped from `what/local/*.example` templates.

## Mission p3_01_dotfile_entry_lifecycle (closed 2026-05-06)

### Knob A — Dotfile location
- **Decision**: `$SPACEMACSDIR` → vault root (`~/lattice/SpaceLattice.aDNA/`). `init.el` rendered at vault root by `skill_deploy` (gitignored). `dotspacemacs-directory` auto-equals vault root.
- **Reason**: Fully self-contained vault deployment — any lattice user clones SpaceLattice.aDNA and runs `skill_install`; only `export SPACEMACSDIR=...` lands in their shell profile. All config is vault-resident; `~/.emacs.d/` holds only the Spacemacs framework + packages.

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

## Mission p3_02_dotspacemacs_variables (in_progress — resumed next session)

### §1.3.1 Layer / package management — CONFIRMED (2026-05-07)

All current template values confirmed correct. No changes.

| Variable | Decision | Rationale |
|---|---|---|
| `dotspacemacs-excluded-packages` | `'()` — leave empty | No current pain point; exclusions can cause subtle breakage if layers depend on them internally |
| `dotspacemacs-frozen-packages` | `'()` — leave empty | Freeze reactively (after a bad MELPA update breaks something); pre-emptive freezing creates maintenance debt |
| `dotspacemacs-distribution` | `'spacemacs` — confirmed | Home buffer + `spacemacs/*` namespace used by adna layer; `spacemacs-base` saves ~200ms but not worth the friction |
| All other §1.3.1 vars | Confirmed at template defaults | `layer-path`, `lazy-install`, `install-packages`, `additional-packages` all already correct from pre-flight |

**Next**: §1.3.2 ELPA / version / dump — GC tuning and LSP read buffer size are the substantive decisions.

## Promotion log (local → standard)

| Date | Promoted | ADR | Notes |
|------|----------|-----|-------|
| — | — | — | — |
