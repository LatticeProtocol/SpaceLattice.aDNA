---
type: runbook
status: active
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [runbook, claude_code, acceptance_test, live_validation, p5_02]
---

# Claude Code Acceptance Test — Operator Runbook

**Purpose**: Verify the `adna` + `claude-code-ide` layer integration is functional after a fresh install, deploy, or upgrade. Covers the full operator flow from boot to multi-project session management.

**When to run**: After `skill_install`, `skill_deploy`, or any change to `what/standard/layers/adna/` or `what/standard/layers/claude-code-ide/`.

**Prerequisites**:
- Spacemacs fully loaded (not in early-init)
- `claude` CLI available in PATH (`which claude` returns a path)
- At least one `*.aDNA/` vault open or reachable

---

## Step 1 — Boot and layer load

Open Spacemacs. Navigate to any file inside a `*.aDNA/` vault.

**Verify**:
- Mode line shows ` aDNA` indicator
- `M-x describe-variable adna-vault-root` returns the vault path (not nil)

**Pass criterion**: Both visible within 5 seconds of file open.

---

## Step 2 — Transient menu

Press `SPC a`.

**Verify**:
- Transient menu opens with groups: Navigate, Skills & Graph, Links & Sessions, Layouts & LP
- All keys listed in the menu are visible and properly labeled

**Pass criterion**: Menu renders without error; no `Symbol's function definition is void` messages in `*Messages*`.

---

## Step 3 — Agentic layout

Press `SPC a l a` (`adna/layout-agentic-default`).

**Verify**:
- treemacs opens on the far-left (≈35 cols)
- Main window occupies center
- Claude Code terminal opens on the right (≈80 cols), showing the Claude CLI prompt or session start
- Focus returns to the center edit window

**Pass criterion**: Three-zone layout visible; no window overflow; frame width ≥ 160 cols recommended.

---

## Step 4 — Claude Code session start

Press `SPC c s` (`claude-code-ide`).

**Verify**:
- Claude Code session starts in the vault root directory
- Terminal buffer named `*claude-code-ide:<vault-name>*` appears in the right zone
- `claude` CLI prompt visible in the terminal

**Pass criterion**: Session starts without error; buffer name contains the vault directory.

---

## Step 5 — Open a file via Claude

In the Claude terminal, ask: `Open STATE.md and summarize the current phase.`

**Verify**:
- Claude opens `STATE.md` in the center edit area
- The file contents appear in the edit buffer, not a new frame

**Pass criterion**: File opens in the correct zone; no new Emacs frame spawned.

---

## Step 6 — Toggle Claude window

Press `SPC c t` (`claude-code-ide-toggle`).

**Verify**:
- Claude terminal window hides; center edit area expands to fill
- Press `SPC c t` again — Claude terminal reappears in the right zone at 80 cols

**Pass criterion**: Two-state toggle works cleanly; window does not reopen at wrong width.

---

## Step 7 — Session list and project switch

Press `SPC a , s` or `SPC a x p` (`adna/claude-project-switch`).

**Verify**:
- Agentic layout re-activates (or remains intact)
- Session list appears (completion or transient), showing `*claude-code-ide:<vault-name>*`
- Selecting the session brings it back to the right zone

**Pass criterion**: Project switch completes without error; session reattaches to layout.

---

## Step 8 — Wikilink and MANIFEST open

Navigate to a `.md` file with a `[[wikilink]]`. Position point inside the link.

Press `SPC a w` (`adna/follow-wikilink`). Then press `SPC a m` (`adna/open-manifest`).

**Verify**:
- `SPC a w` opens the wikilink target in the center edit area
- `SPC a m` opens `MANIFEST.md` from the vault root

**Pass criterion**: Both navigation commands resolve without "Wikilink target not found" or file-not-found errors.

---

## Failure paths

| Symptom | Likely cause | Resolution |
|---------|-------------|------------|
| ` aDNA` absent from mode line | `adna/setup-global-hooks` not called in `user-config` | Add `(adna/setup-global-hooks)` to `dotspacemacs/user-config` |
| `SPC a` does nothing | `adna` layer not in `dotspacemacs-configuration-layers` | Add `adna` to the layer list; restart |
| Claude terminal overflow | Frame width < 160 cols | Widen frame; or reduce `claude-code-ide-window-width` below 80 in `operator.private.el` |
| `claude-code-ide` commands missing | `claude-code-ide` layer not loaded | Add `claude-code-ide` to layer list alongside `adna` |
| `adna/claude-project-switch` not found | Stale byte-compiled funcs.elc | `M-x byte-recompile-directory` on `what/standard/layers/adna/` |

## Related

- `what/context/spacemacs/multi_project_claude.md` — multi-project workflow
- `what/standard/adna-bridge.md` — full layer spec and keybinding table
- `how/standard/skills/skill_health_check.md` — batch validation (complementary to this live runbook)
- ADR-036 — window contract decision
