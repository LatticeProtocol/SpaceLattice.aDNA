---
type: spec
status: draft
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
implementation_phase: 4
implementation_path: what/standard/layers/adna/
tags: [spec, adna, bridge, layer, elisp, spacemacs]
---

# adna-bridge — Spacemacs layer spec

This document specifies the behaviors of the `adna` Spacemacs layer. The implementation lives at `what/standard/layers/adna/` and is authored in **Phase 4** of the genesis plan.

## Purpose

Make Spacemacs aware of aDNA vaults — detect them, parse their frontmatter, surface a navigation menu, round-trip with Obsidian, and emit a context graph. The layer is the *wings* in the Daedalus metaphor: it lifts the operator above the labyrinth of context-graph relations.

## Activation

`adna-mode` is a buffer-local minor mode. It activates when:

1. The buffer's `default-directory` (or the current file's path) has any ancestor matching `*.aDNA/` (case-sensitive).
2. The match is found via `locate-dominating-file` walking up from the file's path.

The matched ancestor's path becomes `adna-vault-root` (buffer-local). Once set, all aDNA-aware operations are scoped to that root.

Implementation: `funcs.el` — `adna/find-vault-root`, `adna/maybe-activate-mode`, hooked to `find-file-hook`.

## Frontmatter as buffer-local variables

On `find-file-hook` (only when `adna-mode` is active), parse YAML frontmatter (between leading `---` and the next `---`) and expose as buffer-locals:

| Buffer-local | Source frontmatter field |
|--------------|-----|
| `adna-frontmatter-type` | `type` |
| `adna-frontmatter-status` | `status` |
| `adna-frontmatter-tags` | `tags` (list) |
| `adna-frontmatter-created` | `created` |
| `adna-frontmatter-updated` | `updated` |
| `adna-frontmatter-last-edited-by` | `last_edited_by` |
| `adna-frontmatter-raw` | full frontmatter as alist |

Implementation: `funcs.el` — `adna/parse-frontmatter`, `adna/install-buffer-locals`. Use the `yaml` package for parsing.

## Transient menu — `SPC a`

A transient.el menu. Top-level prefix bound via `spacemacs/declare-prefix "a" "adna"`.

Bindings:

| Key | Command | Behavior |
|-----|---------|----------|
| `SPC a m` | `adna/open-manifest` | Open `<vault-root>/MANIFEST.md` |
| `SPC a c` | `adna/open-claude` | Open `<vault-root>/CLAUDE.md` |
| `SPC a s` | `adna/open-state` | Open `<vault-root>/STATE.md` |
| `SPC a r` | `adna/jump-triad-root` | Cycle through `who/`, `what/`, `how/` of the current vault |
| `SPC a k` | `adna/run-nearest-skill` | Find the nearest `skill_*.md` ancestor and execute it (process-call to the skill's procedure) |
| `SPC a g` | `adna/render-lattice-graph` | Show the `what/standard/index/graph.json` rendered as an org-mode tree |
| `SPC a n` | `adna/capture-session-note` | Use `template_session.md` to start a new file in `how/sessions/active/` |
| `SPC a i` | `adna/index-project` | Run `M-x adna-index-project` (rebuild graph.json) |
| `SPC a w` | `adna/follow-wikilink` | Resolve `[[Target]]` at point and open it |

Implementation: `keybindings.el` + `funcs.el`.

## Wikilink follow

Parse `[[Target]]` syntax in markdown buffers. Resolution algorithm:

1. Strip surrounding `[[` `]]`.
2. If `Target` contains a `/`, treat as relative path from current file's dir.
3. Otherwise, search for a matching filename anywhere under `<vault-root>/`. If multiple, prompt with helm/ivy.
4. If still not found, search for any file whose frontmatter `name:` field equals `Target`.
5. If still not found, offer to create at `<vault-root>/<heuristic-dir>/<Target>.md` with frontmatter scaffold.

Implementation: `funcs.el` — `adna/wikilink-resolve`, `adna/wikilink-follow`.

## Claude Code integration — `SPC c c`

Spawn (or attach to) a `vterm` session at the nearest `*.aDNA/` ancestor:

```elisp
(defun adna/spawn-claude-code ()
  (interactive)
  (let* ((root (adna/find-vault-root default-directory))
         (vterm-buffer-name (format "*claude:%s*" (file-name-nondirectory (directory-file-name root)))))
    (let ((default-directory root))
      (vterm))
    (vterm-send-string "claude")
    (vterm-send-return)))
```

Bound under `spacemacs/declare-prefix "c" "claude"` → `c c` for "claude code".

Implementation: `funcs.el`. Falls back to `eshell` if `vterm` not available; in pure-batch contexts (no GUI), errors gracefully.

## Obsidian round-trip

See `obsidian-coupling.md` for the full mechanism. Summary:

- **Spacemacs → Obsidian**: when the operator is in Spacemacs and runs `M-x adna/open-in-obsidian`, build an Advanced URI (`obsidian://adv-uri?vault=...&filepath=...`) and `browse-url` it. Obsidian (if running) jumps to the file.
- **Obsidian → Spacemacs**: install a small file-watcher (Phase 4 stub: just polling) on `<vault-root>/.obsidian/workspace.json` to detect Obsidian's "active file." If we have an Emacs server running and the operator wants this synced, the watcher tells Spacemacs to follow.

The watcher is opt-in via `(setq adna-obsidian-roundtrip-enabled t)` in `what/local/operator.private.el`.

## Context graph emitter — `M-x adna-index-project`

Walks the triad of the current vault, parses every `*.md` and `*.org` and `*.yaml` for frontmatter, and emits a JSON file at `<vault-root>/what/standard/index/graph.json`:

```json
{
  "version": "1.0",
  "vault": "spacemacs.aDNA",
  "generated": "2026-05-03T18:55:23Z",
  "nodes": [
    { "id": "what/decisions/adr/adr_000_vault_identity.md",
      "type": "decision",
      "tags": ["decision", "adr", "identity", ...],
      "created": "2026-05-03",
      "updated": "2026-05-03" },
    ...
  ],
  "edges": [
    { "from": "what/decisions/adr/adr_000_vault_identity.md",
      "to": "what/standard/LAYER_CONTRACT.md",
      "kind": "references" },
    ...
  ]
}
```

Edge kinds:
- `wikilink` — `[[Target]]` reference
- `references` — markdown link `[text](path)`
- `frontmatter_ref` — fields like `supersedes`, `superseded_by`, `pattern_spec`, `ratifies`
- `mission_objective` — mission file → objective
- `campaign_mission` — campaign → mission

Implementation:
- Elisp: `funcs.el` — `adna-index-project` interactive command
- Python CLI fallback: `what/standard/index/build_graph.py` — same logic for non-Emacs callers (CI, agents)

Both must produce byte-identical JSON for the same vault state.

## Health-check hook

`(adna/health-check)` is a function callable from `emacs --batch`. Returns non-nil on success; fails loud (signals an error printed to stderr) on:

- Layer load error
- Missing required dependencies (yaml, transient, vterm)
- Frontmatter parse failure on any file under `<vault-root>/`
- `adna-index-project` produces empty graph

Used by `skill_health_check` (Phase 3) and `skill_self_improve`'s dry-run gate (Phase 5).

## Files in `what/standard/layers/adna/`

| File | Purpose | Phase |
|------|---------|-------|
| `packages.el` | Spacemacs layer manifest (declares dependencies) | 4 |
| `config.el` | `defvar` and `defcustom` declarations | 4 |
| `funcs.el` | All elisp functions specified above | 4 |
| `keybindings.el` | Transient menu + leader bindings | 4 |
| `README.org` | Layer documentation (Spacemacs convention) | 2 (placeholder) |

## License

GPL-3.0 (matches Spacemacs upstream — see `who/upstreams/syl20bnr.md`).
