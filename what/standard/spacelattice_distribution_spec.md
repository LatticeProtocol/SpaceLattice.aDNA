---
type: context
title: "SpaceLattice distribution layer spec"
status: active
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [context, standard, distribution_layer, spacelattice, p4_02]
---

# SpaceLattice Distribution Layer Spec

Vault-side specification for `what/standard/layers/spacemacs-latticeprotocol/`.

Per ADR-024 (vault-only layer model) all LP-specific Spacemacs layers live in the vault at
`what/standard/layers/`. The distribution layer is symlinked into `~/.emacs.d/private/layers/`
by `skill_install` Step 5; no fork clone is required.

## Layer identity

| Field | Value |
|-------|-------|
| Layer name | `spacemacs-latticeprotocol` |
| Directory | `what/standard/layers/spacemacs-latticeprotocol/` |
| Deploy path | `~/.emacs.d/private/layers/spacemacs-latticeprotocol/` |
| Namespace (commands) | `lp/` (public), `lp//` (private helpers) |
| Namespace (variables) | `latticeprotocol-` |
| Governed by ADR | ADR-024 (vault-only), ADR-025 (this content) |

## Files

| File | Purpose |
|------|---------|
| `layers.el` | Declares `spacemacs` distribution as dependency |
| `packages.el` | Declares `(latticeprotocol-theme :location local)` |
| `config.el` | `latticeprotocol-version` constant; branding overrides (P4-04) |
| `keybindings.el` | `SPC o l` LP prefix wiring (P4-02) |
| `README.org` | Distribution layer documentation |

## Declared dependencies (`layers.el`)

```elisp
(configuration-layer/declare-layer-dependencies '(spacemacs))
```

Inherits the upstream `spacemacs` distribution (home buffer, `spacemacs/*` namespaces).

## Packages (`packages.el`)

```elisp
(defconst spacemacs-latticeprotocol-packages
  '((latticeprotocol-theme :location local)))
```

Theme files authored in P4-03. Local package source at
`what/standard/layers/+themes/latticeprotocol-theme/local/latticeprotocol-theme/`.

## Keybinding table (`keybindings.el`) — P3-08 source of truth

`SPC o` is the Spacemacs user-reserved prefix. `SPC o l` is the LP sub-prefix.

| Binding | Function | Description |
|---------|----------|-------------|
| `SPC o l h` | `adna/open-manifest` | Vault home — open MANIFEST.md |
| `SPC o l f` | `lp/find-context` | Helm-browse `what/context/` |
| `SPC o l s` | `adna/capture-session-note` | Create new session file in `how/sessions/active/` |
| `SPC o l g` | `adna/render-lattice-graph` | Open `what/standard/index/graph.json` |
| `SPC o l c` | `claude-code-ide-toggle` | Toggle Claude Code IDE buffer (when layer active) |

`lp/find-context` is defined inline in `keybindings.el`; all other functions are
provided by the `adna` layer (`what/standard/layers/adna/funcs.el`) or the
`claude-code-ide` layer (`what/standard/layers/claude-code-ide/`).

Bindings that conflict with Spacemacs-reserved prefixes (`SPC h`, `SPC f`, `SPC b`,
`SPC p`, `SPC m`, `SPC w`) are explicitly avoided per P3-08 namespace reservation.

## Operator acceptance test

1. `skill_install` Step 5 symlinks `spacemacs-latticeprotocol` into `~/.emacs.d/private/layers/`.
2. Spacemacs loads; layer listed in `SPC f e h` (layer descriptions).
3. `SPC o l` opens which-key sub-menu titled "lattice-protocol".
4. Each binding dispatches the correct interactive function.
5. `adna/health-check` returns OK (no regression in adna layer).

## Extension points

- P4-03 fills `config.el` theme overrides and `latticeprotocol-theme` local package.
- P4-04 populates `config.el` branding strings (`spacemacs-buffer-logo-title` etc.).
- P4-06 adds `lp-welcome` local package to `packages.el`.
- P4-09 completes `claude-code-ide` layer; `SPC o l c` becomes fully functional.
- P4-10 formalizes `SPC a x` agent command tree extension; keybindings.el updated accordingly.
