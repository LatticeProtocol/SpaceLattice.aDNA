---
type: decision
adr_id: adr_003
adr_number: 3
title: "Fix skill_install + skill_health_check batch-boot invocation + SIGPIPE-prone pipe"
status: accepted
proposed_by: agent_init
target_layer: standard
target_files:
  - how/standard/skills/skill_install.md
  - how/standard/skills/skill_health_check.md
detected_via:
  rule: live_install_observation
  evidence: "Phase 8 first-install attempt completed in 0 seconds with empty log; emacs --batch -l ~/.spacemacs only DEFINES dotspacemacs/* functions and exits — Spacemacs bootstrap requires -l ~/.emacs.d/init.el"
ratifies:
  invocation_change: "-l ~/.spacemacs -> -l ~/.emacs.d/init.el"
  pipe_change: "| tee -a $LOG -> > $LOG 2>&1"
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
ratifies_for_aar: how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md
tags: [decision, adr, skill, install, health_check, bug_fix, batch_mode, daedalus]
---

# ADR 003 — Fix skill_install + skill_health_check batch-boot invocation

## Status

**Accepted** — fix applied in same commit. Captured in genesis AAR as Gap Register #2/#3/#4.

## Context

Phase 8 of genesis (2026-05-04) installed emacs via `brew install emacs-plus@29` and ran `skill_install` end-to-end against the host. Two real bugs in the skill's documented procedure surfaced:

### Bug 1 — Wrong batch invocation

`skill_install.md` step 6 documented:

```bash
emacs --batch -l ~/.spacemacs 2>&1 | tee -a "$LOG"
```

`emacs --batch` does NOT auto-load `user-init-file`. Loading `~/.spacemacs` directly only DEFINES the `dotspacemacs/*` functions; it does not trigger Spacemacs's bootstrap. The bootstrap is in `~/.emacs.d/init.el`. The result of the documented command: emacs starts, loads .spacemacs (defines functions), exits cleanly with empty output. No packages installed. No bootstrap triggered.

Live evidence: when I ran the documented command, emacs returned in the same second with empty log. The actual bootstrap requires:

```bash
emacs --batch -l ~/.emacs.d/init.el
```

`skill_health_check.md` checks D (line 108) and E (line 133) carry the same wrong invocation.

### Bug 2 — SIGPIPE-prone pipe

After fixing bug 1, my live test attempted:

```bash
emacs --batch -l ~/.emacs.d/init.el 2>&1 | tee -a "$LOG" | tail -30
```

`tail -30` exits as soon as it has 30 lines OR EOF. Once `tail` exits, the upstream `tee` and `emacs` get SIGPIPE. In some sequences emacs caught the SIGPIPE and aborted before completing the bootstrap.

The reliable pattern is to redirect stdout+stderr to a file directly:

```bash
emacs --batch -l ~/.emacs.d/init.el > "$LOG" 2>&1
```

The operator can `tail $LOG` interactively after the run if they want to scan output.

## Decision

Fix both files:

### `skill_install.md` step 6

```diff
- emacs --batch -l ~/.spacemacs 2>&1 | tee -a "$LOG"
- EMACS_EXIT=${PIPESTATUS[0]}
+ emacs --batch -l ~/.emacs.d/init.el > "$LOG" 2>&1
+ EMACS_EXIT=$?
```

### `skill_health_check.md` check D

```diff
- emacs --batch -l ~/.spacemacs --eval '(message "SpaceLattice.aDNA boot OK")' 2>&1 | \
+ emacs --batch -l ~/.emacs.d/init.el --eval '(message "SpaceLattice.aDNA boot OK")' 2>&1 | \
    grep -E "(Error|Warning|SpaceLattice.aDNA boot OK)" > /tmp/_health.log
```

### `skill_health_check.md` check E

```diff
- emacs --batch -l ~/.spacemacs --eval '(adna/health-check)' 2>&1 | \
+ emacs --batch -l ~/.emacs.d/init.el --eval '(adna/health-check)' 2>&1 | \
    grep -E "adna/health-check: (OK|FAIL)" > /tmp/_adna.log
```

(Note: the `| grep` patterns in skill_health_check are NOT SIGPIPE-prone because `grep` reads to EOF without `-m N`. Only the `| tail` pattern in skill_install was risky.)

## Consequences

- Peer operators following `skill_install.md` verbatim no longer hit the silent-no-op bug
- Install logs capture full bootstrap output (8000+ lines for first install) at `how/local/machine_runbooks/last_install.log`
- `skill_health_check` checks D + E correctly trigger the bootstrap before evaluating

## Alternatives considered

1. **Use `emacs --batch -u $USER`** — `-u` sets user. Indirect; relies on `$USER`'s home matching. Rejected.
2. **Use `--load` instead of `-l`** — alias for the same flag. Cosmetic. Rejected.
3. **Fall back to `emacs --batch` with no args** — Emacs may auto-load init.el in batch mode in some configurations, but my live test shows `user-init-file` is `nil` in `--batch`. Unreliable. Rejected.
4. **Add a wrapper script** at `how/standard/skills/_emacs_batch.sh`. Cleaner long-term but heavier than necessary. Deferred to future ADR if multiple skills need the same invocation.

## Reversibility

Trivial — successor ADR + revert this commit's edits.

## References

- AAR: `how/missions/artifacts/aar_genesis_2026_05_03_to_2026_05_05.md` § Gap Register #2/#3/#4
- Live evidence: Phase 8 commit `c3d51c0` (vterm fix), commit `63eaac8` (Phase 8 main)
- Skills affected: `how/standard/skills/skill_install.md`, `how/standard/skills/skill_health_check.md`
