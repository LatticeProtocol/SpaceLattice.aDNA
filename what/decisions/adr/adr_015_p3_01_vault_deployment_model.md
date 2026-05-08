---
type: adr
adr_id: "015"
adr_kind: standard_config
title: "Vault-resident deployment model: SPACEMACSDIR-first + dotspacemacs-directory paths + user-config section structure"
status: accepted
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, deployment, spacemacsdir, dotfile, user_config, structure, p3]
---

# ADR-015: Vault-Resident Deployment Model

## Status

Accepted

## Context

P3-01 (dotfile entry-points + lifecycle ordering) surfaced an architectural question: where should the rendered dotfile live? The genesis placed it at `~/.spacemacs` via `skill_deploy` substituting `{{VAULT_ROOT}}` and other `{{PLACEHOLDER}}` tokens into `dotfile.spacemacs.tmpl`. This scatters operator config into the home directory and requires machine-specific substitution at every deploy.

The operator's stated goal (P3-01 session, 2026-05-06): **"A fully modular deployment that would set up an in-place Spacemacs version of Emacs directly in any lattice user's home lattice dir."**

Spacemacs's resolution order (§1.2 of the customization reference):
1. `$SPACEMACSDIR/init.el` (env var wins if set)
2. `~/.spacemacs`
3. `~/.spacemacs.d/init.el`

Setting `SPACEMACSDIR` to the vault root changes everything: the dotfile stays in the vault, `dotspacemacs-directory` equals the vault root automatically (set by `dotspacemacs/location` from the env var before any dotfile function runs), and all vault-relative paths can use `dotspacemacs-directory` expressions instead of substituted absolute paths.

Concurrently, P3-01 also decided the internal structure of `dotspacemacs/user-config`: topical `;;;` section headers mapping 1:1 to P3 missions, so each mission owns its section without ambiguity.

## Decision

### 1. Deployment target: SPACEMACSDIR → vault root

`skill_install` writes `export SPACEMACSDIR="<vault-root>"` to the operator's shell profile (`~/.zshrc` or `~/.bashrc`) and exports it for the current session. This is the **only** line `skill_install` writes outside `~/.emacs.d/` (Spacemacs framework) and the vault itself.

`skill_deploy` renders `dotfile.spacemacs.tmpl` → `<vault-root>/init.el`. `init.el` at vault root is gitignored (operator-local rendered output). `dotfile.spacemacs.tmpl` remains the canonical tracked source.

`~/.emacs.d/` continues to hold the Spacemacs framework + packages — this is Spacemacs's hardcoded install target and is not changed.

### 2. Remove {{PLACEHOLDER}} substitutions

The following substitutions are eliminated from the render step because `dotspacemacs-directory` covers their purpose:

| Old substitution | Replacement in template |
|---|---|
| `{{LAYER_PATH_LIST}}` | `(list (concat dotspacemacs-directory "what/"))` |
| `{{LOCAL_LAYER_DIR}}` | `(concat dotspacemacs-directory "what/local")` |
| `{{THEME_PRIMARY}}`, `{{THEME_FALLBACK}}` | Already resolved in ADR-012 |
| `{{FONT_FAMILY}}`, `{{FONT_SIZE}}` | Already resolved in ADR-012 |

`{{LOCAL_LAYER_LIST}}` is retained as the mechanism for operators to enumerate additional named layers.

`dotspacemacs-startup-banner` stays `'official` (standard Spacemacs logo). Custom ASCII assets in `what/standard/assets/` are preserved for P4 fork branding. The vault-relative path mechanism via `dotspacemacs-directory` applies to layer path and private-elisp path only.

### 3. user-config section structure (Knob D)

`dotspacemacs/user-config` is reorganised with `;;;` section headers:

```
§P3-01  Dotfile structure / workspace anchor
§P3-02  dotspacemacs-* variables
§P3-03  adna layer / aDNA hooks
§P3-04  Themes / modeline / banner
§P3-05  Editing / completion / packages
§P3-06  Performance / evil / fonts
§P3-07  Workarounds / org-mode
§P3-08  Languages / keys / navigation
§P3-09  Obsidian plugin audit
§P3-10  Layer expansion audit
§P3-11  Browser / eww integration
```

Existing config blocks are moved to their matching section. Empty sections carry a `(populated by mission P3-XX)` stub comment.

### 4. user-env policy (Knob B)

`(spacemacs/load-spacemacs-env)` is retained. With `$SPACEMACSDIR` → vault root, `spacemacs/load-spacemacs-env` loads from `dotspacemacs-directory/.spacemacs.env` — the vault root. A `what/local/.spacemacs.env.example` template is added to document expected vars (`SPACEMACSDIR`, `PATH`, LP credentials).

### 5. Landing zone rule (Knob C)

Recorded in `who/operators/stanley.md`. Not a code change.

## Consequences

**Positive:**
- A new lattice user runs `skill_install` once — the only side-effect outside `~/.emacs.d/` and the vault is one `export` line in their shell rc
- Template has zero machine-specific substitutions remaining (except `{{LOCAL_LAYER_LIST}}` which is typically empty)
- `dotspacemacs-directory` is available in all 5 dotfile functions and provides portable vault-relative paths
- Banner, layer paths, private-elisp path — all use `dotspacemacs-directory`; no substitution machinery needed in `skill_deploy` render step

**Negative / Trade-offs:**
- `init.el` at vault root must be gitignored — operators cannot accidentally commit their rendered dotfile
- `SPACEMACSDIR` must be set before Emacs launches; a fresh shell without `.zshrc` sourced won't find the dotfile (acceptable: `skill_install` handles this)
- `~/.emacs.d/` (framework + packages) is still outside the vault — full "hermetic" packaging requires Emacs 29's `--init-directory` flag, deferred to post-v1.0

**Scope:**
- Modified: `what/standard/dotfile.spacemacs.tmpl`
- Modified: `how/standard/skills/skill_install.md`
- Modified: `how/standard/skills/skill_deploy.md`
- Modified: `.gitignore` (add `/init.el`, `/.spacemacs.env`)
- New: `what/local/.spacemacs.env.example`

## Dry-run result

Template changes validated via `skill_health_check` (Check D, batch boot) after applying.

## Operator approval

Accepted at P3-01 session (2026-05-06). All 5 knobs accepted after structured Q&A.
