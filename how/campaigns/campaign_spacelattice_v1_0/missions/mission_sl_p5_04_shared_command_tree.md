---
type: mission
mission_id: mission_sl_p5_04_shared_command_tree
campaign: campaign_spacelattice_v1_0
campaign_phase: 5
campaign_mission_number: 4
status: completed
mission_class: implementation
created: 2026-05-10
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [mission, completed, spacemacs, v1_0, p5, command_tree, shared, scripts, auto_discovery, mcp, adr_038]
blocked_by: []
---

# Mission — P5-04: Shared Human-Agent Command Tree

**Phase**: P5 — Polish + v1.0 release.
**Class**: implementation.

## Objective

Formalize the command tree as a **bidirectional, shared workspace** between human operators and agents. Currently, `SPC a x` is a stub transient that agents can extend via `operator.private.el`. This mission adds a `scripts/` directory pattern to the `adna` layer so that:

1. Operators write elisp scripts that agents can **discover and invoke** via `SPC a x`
2. Agents propose commands (via ADR) that operators **approve and promote** to standard
3. Scripts can be exposed to Claude Code as **MCP tools**, replacing token-heavy workflows with direct function calls
4. The command tree becomes a documented, growable shared capability space — not just a menu

This is the final integration of the "agent-extensible" vision from ADR-013 (2026-05-06) and `agent_command_tree.md` (2026-05-07).

## Deliverables

### 1. `what/standard/layers/adna/scripts/` directory
New directory seeded with:

**`README.md`** — The scripts directory contract:
- What belongs here: elisp files that add `SPC a x` sub-commands, expose Emacs functions as MCP tools, or automate operator workflows
- What doesn't belong: operator-specific scripts (those go in `what/local/scripts/`), full layer files (those go in `what/standard/layers/`)
- Promotion path: `what/local/scripts/` → `what/standard/layers/adna/scripts/` via `skill_layer_promote` (ADR-gated)
- Agent scripts: draft in `what/local/`, propose via session SITREP, promote after operator approval

**`adna-show-sitrep.el`** — Seed script (standard):
```elisp
(defun adna/show-sitrep ()
  "Open STATE.md and most recent active session file side-by-side.
Useful for starting a session: see current state + what was last worked on."
  (interactive)
  (let ((state (concat (adna/vault-root) "STATE.md"))
        (session (car (directory-files
                       (concat (adna/vault-root) "how/sessions/active/")
                       t "\\.md$"))))
    (find-file state)
    (when session
      (split-window-right)
      (other-window 1)
      (find-file session))))
```

**`adna-run-health-check.el`** — Seed script (standard):
```elisp
(defun adna/run-health-check ()
  "Run skill_health_check batch checks A-I from inside Emacs via vterm/eat."
  (interactive)
  (let ((vault (adna/vault-root)))
    (vterm-other-window)
    (vterm-send-string
     (format "cd %s && emacs --batch --load how/standard/skills/skill_health_check_runner.el 2>&1 | head -50\n"
             vault))))
```

**`adna-open-claude-with-layout.el`** — Seed script (standard):
```elisp
(defun adna/open-claude-with-layout ()
  "Activate agentic layout then start Claude Code for current project.
One-key workflow: layout + Claude in a single command."
  (interactive)
  (when (fboundp 'adna/layout-agentic-default)
    (adna/layout-agentic-default))
  (call-interactively #'claude-code-ide))
```

### 2. `adna/funcs.el` — auto-discovery loader
New function `adna/load-scripts`:
```elisp
(defun adna/load-scripts ()
  "Load all .el files from adna/scripts/ and what/local/scripts/ (if present).
Called from adna layer init so SPC a x sub-commands are auto-registered."
  (let ((std-scripts (expand-file-name "scripts/"
                       (file-name-directory (or load-file-name buffer-file-name ""))))
        (local-scripts (expand-file-name "what/local/scripts/" (adna/vault-root))))
    (dolist (dir (list std-scripts local-scripts))
      (when (file-directory-p dir)
        (dolist (f (directory-files dir t "\\.el$"))
          (load f nil t))))))
```
Call site: add `(adna/load-scripts)` to `adna/config.el` post-init hook.

### 3. `what/context/shared_command_space.md`
New context document — the conceptual anchor for this pattern:

**Sections:**
- **The pattern**: command tree as shared workspace, not just a menu
- **Bidirectional flow**:
  - Human → script → SPC a x: operator writes elisp in `what/local/scripts/`, reloads, appears in `SPC a x`
  - Agent → command → ADR → SPC a x: agent proposes in session SITREP, operator approves, ADR filed, promoted to `scripts/`
- **Scripts vs. skills**: skills are markdown agent recipes; scripts are live elisp functions. Both live in the same governance framework but serve different audiences
- **MCP tool exposure**: any script function can be wrapped as an MCP tool. Example: `adna/show-sitrep` registered as `read_vault_state` MCP tool gives Claude Code direct access to STATE.md without file-read tokens
- **Workflow automation**: instead of asking Claude to "read STATE.md and tell me what's next," bind `adna/open-claude-with-layout` to `SPC a x o` and let Claude get context directly from the live Emacs session via MCP
- **Token economy**: scripts that replace file-read roundtrips save context window. Design guideline: if an action happens >3x/session, script it

### 4. `agent_command_tree.md` update
Add section: **Scripts directory and auto-discovery**
- Link to `what/standard/layers/adna/scripts/`
- Discovery protocol: `adna/load-scripts` runs at init; `SPC a x` shows all loaded commands
- Agent workflow: draft in `what/local/scripts/` → appears in `SPC a x` immediately → propose via SITREP → promote via `skill_layer_promote` after operator approval

### 5. ADR-038
`what/decisions/adr/adr_038_shared_command_space.md`:
- Problem: `SPC a x` is a stub; no pattern for operator or agent to add durable scripts; no standard directory
- Decision: `scripts/` directory in adna layer; auto-discovery at init; `what/local/scripts/` for operator-private; promotion via `skill_layer_promote`
- MCP bridge: any script function can be wrapped via `claude-code-ide-make-tool`
- Consequence: `adna/load-scripts` called at layer init; adds startup cost proportional to number of scripts (negligible for typical use)

### 6. `LAYER_CONTRACT.md` update
Add clause covering `scripts/`:
- Scripts in `what/standard/layers/adna/scripts/` are subject to the same sanitization rules as all standard layer files (LAYER_CONTRACT §3)
- Scripts in `what/local/scripts/` are gitignored and may contain operator-specific paths

## Estimated effort

1 session.

## Dependencies

P5-02 (Claude Code integration — `adna/open-claude-with-layout` script depends on both layout system and claude-code-ide being wired).

## Reference

- `what/context/agent_command_tree.md` (update target + conceptual foundation)
- `what/standard/layers/adna/funcs.el` (add `adna/load-scripts`)
- `what/standard/layers/adna/config.el` (add load-scripts call site)
- `what/standard/LAYER_CONTRACT.md` (extend with scripts/ clause)
- ADR-013 (original keybinding/extensibility decision)
- ADR-034 (SPC a x stub — this mission fills it in properly)

---

## AAR — 2026-05-11

**Worked**: `scripts/` directory created, 3 seed scripts with interface contract (`provide` + `spacemacs/set-leader-keys`), `adna/load-scripts` in `funcs.el`, `adna--layer-dir` defvar in `config.el`, `spacemacs-post-user-config-hook` call site, `shared_command_space.md` context doc, `agent_command_tree.md` updated with seed table + discovery protocol + extension discipline, `LAYER_CONTRACT.md` Clause 8 added, ADR-038 accepted.

**Didn't work**: Nothing blocked. Minor: `adna/load-scripts` uses both `adna--layer-dir` and a `locate-library` fallback in case the defvar was nil — belt-and-suspenders for different install paths.

**Finding**: Spacemacs layer loading order (packages.el → config.el → funcs.el) means `load-file-name` must be captured in `config.el` at load time, not in `funcs.el` (already loaded by then). The `adna--layer-dir` defvar at the top of `config.el` is the correct capture point.

**Change**: Added `adna--layer-dir` defvar early in `config.el` (before buffer-local section); `adna/load-scripts` in `funcs.el` references it.

**Follow-up**: Live validation (SPC a x → seed commands appear in which-key) requires running Emacs. Defer to operator at next boot — run `SPC a x` and verify `s/h/o` appear.
