---
type: adr
adr_number: 025
title: "Distribution layer content — SPC o l keybindings + vault-side spec"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, distribution_layer, keybindings, p4_02]
---

# ADR-025: Distribution layer content — `SPC o l` keybindings + vault-side spec

## Status

Accepted (P4-02, 2026-05-08)

## Context

P4-01 created skeleton files for `what/standard/layers/spacemacs-latticeprotocol/` under the
vault-only model (ADR-024). The `keybindings.el` skeleton contained only the binding table as
a comment and a `"Populated in P4-02."` stub. The layer was non-functional at that stage —
loading the layer in Spacemacs registered no bindings, and `SPC o l` produced no which-key
sub-menu.

P3-08 established the canonical `SPC o l` LP prefix binding table in
`who/operators/stanley.md §3.5` (5 bindings: h/f/s/g/c). These decisions had been deferred
to P4-02 for implementation. Mission P4-02 closes that deferred work.

## Decision

### 1. Keybindings populated

`what/standard/layers/spacemacs-latticeprotocol/keybindings.el` is filled with working elisp:

- `(spacemacs/declare-prefix "ol" "lattice-protocol")` registers the which-key description.
- Four bindings set unconditionally (adna layer is a declared layer dependency):
  - `SPC o l h` → `adna/open-manifest` (vault home)
  - `SPC o l f` → `lp/find-context` (context file browser)
  - `SPC o l s` → `adna/capture-session-note` (new session file)
  - `SPC o l g` → `adna/render-lattice-graph` (open graph.json)
- One binding set inside `(with-eval-after-load 'claude-code-ide ...)`:
  - `SPC o l c` → `claude-code-ide-toggle` (safe: no-ops if layer absent)

### 2. `lp/find-context` defined inline

A minimal `lp/find-context` function is defined in `keybindings.el`. It calls
`helm-find-files-1` rooted at `what/context/` (falls back to `find-file` if helm is
unavailable). This avoids needing a separate `funcs.el` for a single simple helper.

### 3. Vault-side spec created

`what/standard/spacelattice_distribution_spec.md` documents layer identity, file inventory,
declared dependencies, package list, keybinding table, operator acceptance test, and
extension points for P4-03 through P4-10.

### 4. Existing skeleton files unchanged

`layers.el`, `packages.el`, `config.el`, and `README.org` are unchanged — their P4-01
skeleton content is correct and complete for this mission's scope.

## Consequences

### Positive

- `SPC o l` is now a functional which-key sub-menu with 4 live bindings.
- All bound functions are already implemented in the `adna` layer — no stubs that call
  `(message "coming soon")`.
- `SPC o l c` is future-safe: it binds only when `claude-code-ide` is loaded, avoiding
  a void-function error if P4-09 is not yet installed.
- Vault-side spec gives agents a single document to read for distribution layer context
  without traversing all layer files.

### Negative

- `lp/find-context` defined in `keybindings.el` is slightly unconventional (functions
  normally live in `funcs.el`). Trade-off accepted: the function is a one-liner UI bridge
  and P4-09 may supersede it; adding a full `funcs.el` for one function adds overhead.

### Neutral

- `lp/` namespace reserved for public distribution-layer commands per fork-strategy.md §3;
  this ADR places the first real `lp/` symbol.
- `SPC o l u` (url-at-point) explicitly skipped — `SPC j o` covers this (P3-08 §3.5 note).
