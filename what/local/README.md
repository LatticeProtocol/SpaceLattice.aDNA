---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [local, what, private, gitignored]
---

# what/local/

The **local layer** — operator-private, gitignored by default. This README and any `*.example` templates ARE tracked (so future operators can bootstrap their local layer); everything else here stays on the operator's machine.

## What lives here

| File | Purpose | Tracked? |
|------|---------|----------|
| `README.md` | This file | ✅ |
| `operator.private.el.example` | Template for elisp loaded last by `dotspacemacs/user-init` | ✅ |
| `operator.private.el` | Real operator-private elisp (created from .example) | ❌ |
| `machine.pins.md.example` | Template for per-machine pins (OS-specific Spacemacs SHA, etc.) | ✅ |
| `machine.pins.md` | Real machine-specific pins | ❌ |
| `secrets.env.example` | Template for env vars (API keys, etc.) | ✅ |
| `secrets.env` | Real secrets — **never commit** | ❌ |

## Bootstrap on a fresh machine

After `skill_install` clones the vault for the first time, run:

```bash
cd <vault-root>/what/local
for f in *.example; do
  target="${f%.example}"
  [[ -f "$target" ]] || cp "$f" "$target"
done
```

Then edit each non-`.example` file to fit the machine. `skill_install` does this automatically; the manual command is for recovery.

## Promotion to standard

If something here turns out to be useful for *all* operators (not just this machine), promote it via `how/standard/skills/skill_layer_promote.md`. Promotion requires:

1. ADR in `what/decisions/adr/` justifying the promotion
2. Sanitization scan: no hostnames, no operator names, no machine paths, no secrets
3. Operator approval

The agent never auto-promotes.

## Layer contract reference

Full contract: `what/standard/LAYER_CONTRACT.md` (Phase 6).
