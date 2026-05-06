---
type: skill
skill_type: agent
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
category: deploy
trigger: "Operator changed something in what/standard/ or what/local/ and wants the change reflected in their running ~/.emacs.d/. Skip the clone phase."
phase_introduced: 3
tags: [skill, deploy, spacemacs, idempotent, daedalus]
requirements:
  tools: [git, "emacs (>=29.0)", python3]
  context:
    - what/standard/dotfile.spacemacs.tmpl
    - what/standard/packages.el.tmpl
    - what/standard/layers/adna/
    - what/local/ (optional)
  permissions:
    - "write ~/.spacemacs"
    - "write ~/.emacs.d/private/"
    - "write deploy/"
---

# skill_deploy — re-apply standard + local without re-cloning Spacemacs

## Purpose

Faster cousin of `skill_install`. When `~/.emacs.d/` is already present and at the pinned SHA, just re-render templates, refresh the adna layer symlink, restart Emacs, and write a new receipt.

Use cases:

- Operator edited `what/standard/dotfile.spacemacs.tmpl` and wants the change live
- Operator added a layer to `what/local/operator.private.el` and wants it loaded
- Operator promoted something from `local/` to `standard/` (via `skill_layer_promote`) — deploy reflects the merged state

## Pre-conditions

| Check | If fails |
|-------|----------|
| `~/.emacs.d/.git/` exists | Run `skill_install` instead |
| `~/.emacs.d/` HEAD matches `what/standard/pins.md` SHA | Run `update_spacemacs.md` runbook or `skill_install` |
| Current dir has `MANIFEST.md` with `subject: spacemacs` | Operator is not in the vault root |

## Steps

This skill is **steps 4-8 of `skill_install`**, executed unchanged. See `skill_install.md` for the full step contracts. Briefly:

| # | Action |
|---|--------|
| 4 | Re-render `dotfile.spacemacs.tmpl` → `~/.spacemacs` and `packages.el.tmpl` → `~/.emacs.d/private/packages.el` |
| 5 | Refresh `~/.emacs.d/private/layers/adna` symlink |
| 6 | Batch boot: `emacs --batch -l ~/.spacemacs` (cheaper than first install — packages cached) |
| 7 | Run `skill_health_check` (checks A-D+) |
| 8 | Write deploy receipt to `deploy/<hostname>/<utc>.md` |
| 9 | Determine reload type; instruct operator; run `skill_inspect_live` after reload |

**Step 9 — Reload type + live inspection**

After batch-boot and health-check pass, determine the minimum reload needed based on what changed:

| Changed in template | Operator action | Live check |
|---------------------|----------------|------------|
| `dotspacemacs/user-config` body only | `SPC f e R` (hot reload — ~3s) | Run `skill_inspect_live` |
| `dotspacemacs/init` vars, new layer, new package | `SPC q r` (full restart — ~20s) | Run `skill_inspect_live` |
| `dotspacemacs/user-init` body | `SPC q r` (full restart) | Run `skill_inspect_live` |

After the operator reloads (or if Spacemacs was already running with the new config), run `skill_inspect_live` to confirm live state matches expectations. A deploy is not complete until `skill_inspect_live` reports GREEN.

## Post-conditions

Same as `skill_install` post-conditions, except `~/.emacs.d/` is unchanged (still at the pinned SHA).

## Failure modes

If batch boot fails after a deploy:

1. The deploy left `~/.spacemacs` in a bad state but didn't touch `~/.emacs.d/`
2. The fix is to revert `what/standard/dotfile.spacemacs.tmpl` (or the local-layer change) and re-deploy
3. Or restore `~/.spacemacs` from the previous deploy's backup file

`skill_deploy` does NOT take a fresh backup of `~/.spacemacs` since `skill_install` already created the canonical backup. If the operator needs a deploy-time backup, they invoke `skill_install` instead (which always backs up if the marker check fails).

## Idempotency

Same as `skill_install` for steps 4-8. Re-running produces the same end state; receipts accumulate.

## When to prefer `skill_install` over `skill_deploy`

| Situation | Use |
|-----------|-----|
| Brand new machine | `skill_install` |
| Pin updated in `what/standard/pins.md` | `update_spacemacs.md` runbook (which calls `skill_install` after fetching new pin) |
| Just edited a template | `skill_deploy` |
| Adding/removing a Spacemacs layer | `skill_layer_add` (which calls `skill_deploy` after ADR approval) |
| Recovering from breakage | `recover_from_breakage.md` runbook (likely → `skill_install`) |
