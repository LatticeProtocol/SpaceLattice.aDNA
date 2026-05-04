---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [local, how, private, gitignored, machine]
---

# how/local/

Per-operator/per-machine operational state — gitignored by default. This README is tracked (per `.gitignore` negation rules); everything else stays on the operator's machine.

## What lives here

| Sub-path | Purpose | Tracked? |
|----------|---------|----------|
| `README.md` | This file | ✅ |
| `machine_runbooks/` | Per-machine variations of standard runbooks | ❌ |
| `last_install.log` | Captured stdout/stderr from last `skill_install` boot | ❌ |
| `*.example` | Templates (none currently — added if needed) | ✅ |

## Why this exists

Some operations are inherently machine-specific:

- The exact symlink layout if `$SPACEMACSDIR` differs from `~/.emacs.d/`
- A WSL2 operator's display setup (X server, WSLg)
- An air-gapped machine's package mirror configuration
- The operator's `cron`/`launchd` jobs that run `skill_self_improve` periodically

These don't belong in `how/standard/runbooks/` (commons) but should be tracked locally for the operator's own future reference.

## Promotion to standard

Same protocol as `what/local/` — `skill_layer_promote` with ADR + sanitization scan. Promote when a runbook's value is general enough to help peers.
