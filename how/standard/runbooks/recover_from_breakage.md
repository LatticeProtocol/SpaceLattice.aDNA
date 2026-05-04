---
type: runbook
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
audience: human
intent: "Restore a working spacemacs.aDNA install after ~/.emacs.d/ or ~/.spacemacs is broken."
time_estimate: "5–20 minutes depending on damage"
phase_introduced: 3
tags: [runbook, recovery, breakage, backup, daedalus]
---

# Runbook — recover from breakage

## When to follow

- Emacs won't start
- Emacs starts but Spacemacs throws errors during boot
- Layers stopped loading
- `~/.emacs.d/` looks corrupted (incomplete clone, accidental rm, etc.)
- A pin bump went bad (smoke test failed)

## Diagnostic first — what kind of breakage?

```bash
emacs --batch -l ~/.spacemacs 2>&1 | head -50
```

| Output pattern | Likely cause | Section |
|----------------|--------------|---------|
| `Error: Cannot open load file: ...` | Missing package or broken symlink | A |
| `dotspacemacs/...: Symbol's value as variable is void` | Template render glitch — bad placeholder substitution | B |
| `Cloning into '~/.emacs.d/'... fatal: ...` | Spacemacs clone is corrupt | C |
| Hangs on first boot >5 min | Package mirror down; ELPA timeout | D |
| `(adna/...): Symbol's function definition is void` | adna layer broken | E |
| Process killed | OOM (Emacs running out of memory during package install) | F |

## A — Missing package or broken symlink

```bash
# Check the adna layer symlink
ls -la ~/.emacs.d/private/layers/adna
# If broken: re-create
rm -f ~/.emacs.d/private/layers/adna
ln -s <vault-root>/what/standard/layers/adna ~/.emacs.d/private/layers/adna

# Check ELPA cache integrity
rm -rf ~/.emacs.d/.cache/elpa  # forces re-download on next boot
emacs --batch -l ~/.spacemacs   # will re-fetch packages
```

If a specific package is missing and unfetchable from upstream: open an ADR proposing pin bump or layer change. Do not bypass ADR.

## B — Template render glitch

```bash
# Re-render templates from scratch
bash <vault-root>/how/standard/skills/skill_deploy.md

# If still broken: open the rendered files and look for {{...}} placeholders that didn't substitute
grep -E '\{\{[A-Z_]+\}\}' ~/.spacemacs ~/.emacs.d/private/packages.el
# If you see unsubstituted placeholders, the renderer in skill_install Step 4 has a bug — file an ADR
```

## C — Corrupt Spacemacs clone

```bash
# Most aggressive: nuke and re-clone
[[ -d ~/.emacs.d ]] && mv ~/.emacs.d ~/.emacs.d.broken.$(date -u +%Y%m%dT%H%M%SZ)
bash <vault-root>/how/standard/skills/skill_install.md
```

If `mv` to broken-archive feels excessive: try `cd ~/.emacs.d && git status` and `git fsck` first. If the working tree is messy, `git clean -fdx && git reset --hard <pin_sha>` puts it back. If `.git` itself is corrupt, archive-and-re-clone is faster than recovery.

## D — Package mirror timeout

```bash
# Check what mirror Spacemacs is using
grep -A2 dotspacemacs-elpa-https ~/.spacemacs

# Switch to a more reliable mirror (operator-local override):
# In what/local/operator.private.el:
#   (setq-default configuration-layer-elpa-archives
#       '(("melpa" . "https://melpa.org/packages/")
#         ("gnu"   . "https://elpa.gnu.org/packages/")
#         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

bash <vault-root>/how/standard/skills/skill_deploy.md
```

## E — adna layer broken

```bash
# Phase 4+: temporarily disable adna layer to isolate
# Edit ~/.spacemacs, comment out `adna` in dotspacemacs-configuration-layers
# Re-run emacs --batch
# If emacs boots clean without adna, the layer has a bug — file an ADR

# Phase 3: layer is mostly stub. Skip to next remediation.
```

## F — OOM during package install

```bash
# Free memory, close other apps. Then:
rm -rf ~/.emacs.d/.cache/elpa-async
bash <vault-root>/how/standard/skills/skill_install.md

# If persistently OOM on a low-RAM machine, install layers in waves:
# - First wave: just `auto-completion`, `better-defaults`, `helm`, `git`
# - After boot succeeds, add the language layers one at a time via skill_layer_add
```

## Restoring from backup

If you ran `skill_install` previously and have a backup:

```bash
ls -dt ~/.emacs.d.bak.* ~/.spacemacs.bak.* 2>/dev/null
# Most recent backup:
LATEST_DIR=$(ls -dt ~/.emacs.d.bak.* | head -1)
LATEST_FILE=$(ls -t ~/.spacemacs.bak.* | head -1)

# Restore (will overwrite current broken state)
[[ -d ~/.emacs.d ]] && mv ~/.emacs.d ~/.emacs.d.broken.$(date -u +%Y%m%dT%H%M%SZ)
[[ -f ~/.spacemacs ]] && mv ~/.spacemacs ~/.spacemacs.broken.$(date -u +%Y%m%dT%H%M%SZ)
mv "$LATEST_DIR" ~/.emacs.d
mv "$LATEST_FILE" ~/.spacemacs
```

The backup state is whatever was on the machine before the last `skill_install` ran. If the breakage post-dates that backup, this won't help — restart from `fresh_machine.md`.

## Last resort — fresh install

```bash
mv ~/.emacs.d ~/.emacs.d.giveup.$(date -u +%Y%m%dT%H%M%SZ)
mv ~/.spacemacs ~/.spacemacs.giveup.$(date -u +%Y%m%dT%H%M%SZ)
bash <vault-root>/how/standard/skills/skill_install.md
```

You don't lose vault data — all your real work is in `~/lattice/spacemacs.aDNA/`. Only the install state on this machine resets.

## After recovery — record the incident

This is important. Add a note to your operator profile:

```bash
cat >> who/operators/<your-name>.md <<EOF

## Incident — $(date -u +%F)

Breakage type: <A/B/C/D/E/F or other>
Root cause: <one sentence>
Resolution: <which section of recover_from_breakage.md fixed it>
Follow-up ADR: (if any)
EOF
```

`skill_self_improve` reads operator profile incident notes. If a pattern emerges (e.g., 3 OOMs in a month on this host class), the agent proposes a standard-layer change or runbook update.
