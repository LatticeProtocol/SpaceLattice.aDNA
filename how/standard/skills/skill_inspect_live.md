---
type: skill
skill_type: agent
status: active
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
category: verification
trigger: "After any deploy or dotfile change, before reporting changes as complete. Also callable standalone to inspect current IDE state without user screenshots."
phase_introduced: 3
tags: [skill, inspect, emacsclient, validation, live_check, screenshot, daedalus]
requirements:
  tools: [emacsclient, screencapture, python3]
  context:
    - what/standard/dotfile.spacemacs.tmpl
  permissions:
    - "read ~/.spacemacs"
    - "execute emacsclient"
    - "execute screencapture"
---

# skill_inspect_live — closed-loop live IDE state inspection

## Purpose

Inspect the **running Spacemacs instance** directly, without requiring the operator to take screenshots. Uses the Emacs server (always enabled via `dotspacemacs-enable-server t`) to query variable values and functional state, plus `screencapture` for visual verification.

This closes the edit→validate loop:

```
Template edit → render → batch-boot → [operator restarts] → skill_inspect_live
                                                              ↓
                                              live state report + screenshot
                                              no user screenshot needed
```

Called automatically by `skill_deploy` Step 9 when emacsclient is available.

## Pre-conditions

| Check | If fails |
|-------|----------|
| Running Spacemacs GUI instance | Inspection skipped; batch-boot check is the gate |
| `dotspacemacs-enable-server t` in dotfile | Add it; it is standard in `dotfile.spacemacs.tmpl` |
| emacsclient in PATH | `brew install emacs-plus@29` bundles it |

## Steps

### Step 1 — Find server socket

```bash
EMACS_SOCK=$(find /var/folders -name "server" \
  -path "*/emacs$(id -u)/*" -type s 2>/dev/null | head -1)

if [[ -z "$EMACS_SOCK" ]]; then
  echo "SKIP: no emacs server socket found — Spacemacs not running or server disabled"
  exit 0
fi
echo "Socket: $EMACS_SOCK"
```

The socket path is session-specific (macOS puts it under `/var/folders/<hash>/T/emacs<uid>/server`). Always discover dynamically — never hardcode.

### Step 2 — Query live state

Run a single emacsclient eval that returns all key settings as a structured string:

```bash
REPORT=$(emacsclient -s "$EMACS_SOCK" --eval '
(format
  "font-height: %s\ncentaur-excluded-prefixes-has-star: %s\ncentaur-visible-tabs: %s\nprojectile-search-path: %S\ndoom-modeline-active: %s\nbuffer-list: %S\nadna-setup-called: %s"
  (face-attribute (quote default) :height)
  (if (member "*" centaur-tabs-excluded-prefixes) "YES" "NO")
  (condition-case nil
    (format "%S" (mapcar (lambda (tab) (buffer-name (car tab)))
                         (centaur-tabs--current-tabs)))
    (error "unavailable"))
  projectile-project-search-path
  (if doom-modeline-mode "YES" "NO")
  (mapcar (quote buffer-name) (buffer-list))
  (if (fboundp (quote adna/setup-global-hooks)) "YES (fn exists)" "NO"))
' 2>&1)

echo "$REPORT"
```

### Step 3 — Assert expected values

Parse the report and assert Spacemacs standard values:

```python
import subprocess, sys, re

sock = subprocess.check_output(
    'find /var/folders -name "server" -path "*/emacs%d/*" -type s 2>/dev/null | head -1' % __import__('os').getuid(),
    shell=True).decode().strip()

if not sock:
    print("SKIP: no server socket")
    sys.exit(0)

report = subprocess.check_output(
    ['emacsclient', '-s', sock, '--eval', '''
(format "%s|%s|%s|%s"
  (face-attribute (quote default) :height)
  (if (member "*" centaur-tabs-excluded-prefixes) "star-ok" "star-MISSING")
  (if doom-modeline-mode "doom-ok" "doom-OFF")
  (if projectile-project-search-path "proj-ok" "proj-MISSING"))
'''], capture_output=True, text=True).stdout.strip().strip('"')

parts = report.split('|')
results = []

# Font height: expect 150 (15pt)
height = int(parts[0]) if parts[0].isdigit() else 0
results.append(('font-height', height == 150,
                f'{height} (want 150 = 15pt)'))

# centaur-tabs: "*" in excluded-prefixes
results.append(('centaur-tabs-star-filter', parts[1] == 'star-ok',
                parts[1]))

# doom-modeline active
results.append(('doom-modeline', parts[2] == 'doom-ok',
                parts[2]))

# projectile search path set
results.append(('projectile-search-path', parts[3] == 'proj-ok',
                parts[3]))

all_green = True
for name, ok, detail in results:
    icon = '✓' if ok else '✗'
    print(f'  {icon} {name}: {detail}')
    if not ok:
        all_green = False

if all_green:
    print('\nLIVE CHECK: GREEN — all assertions passed')
else:
    print('\nLIVE CHECK: RED — see failures above')
    sys.exit(1)
```

### Step 4 — Visual capture

```bash
screencapture -x /tmp/spacemacs_inspect_$(date +%Y%m%dT%H%M%S).png
echo "Screenshot: /tmp/spacemacs_inspect_$(date +%Y%m%dT%H%M%S).png"
```

Then Read the screenshot file in Claude Code context for visual inspection. No user screenshot needed.

```
# In Claude Code context:
Read /tmp/spacemacs_inspect_<timestamp>.png
```

### Step 5 — Report

Combine assertion results + screenshot read into a structured status report:

```
LIVE INSPECTION REPORT — <timestamp>
=====================================
Assertions:
  ✓ font-height: 150 (15pt)
  ✓ centaur-tabs-star-filter: star-ok
  ✓ doom-modeline: doom-ok
  ✓ projectile-search-path: proj-ok

Visual: [attached screenshot read]

Status: GREEN / RED
```

## Reload type reference

Not all changes require `SPC q r`. Use this table to pick the minimum disruptive reload:

| Change type | Reload needed |
|-------------|---------------|
| `dotspacemacs/user-config` body (font, modeline, centaur-tabs, eww) | `SPC f e R` (hot reload) |
| `dotspacemacs/init` variables (font declaration, theme, banner) | `SPC q r` (full restart) |
| New layer added to `dotspacemacs-configuration-layers` | `SPC q r` (full restart) |
| `dotspacemacs/user-init` body | `SPC q r` (full restart) |
| New package in `dotspacemacs-additional-packages` | `SPC q r` + package install |
| adna layer elisp changes (`funcs.el`, `keybindings.el`) | `SPC f e R` (hot reload) |

## Integration with skill_deploy

`skill_deploy` Step 9 calls this skill automatically. If the inspection fails (RED):

1. The deploy is marked RED in the receipt
2. The agent investigates the failing assertion(s)
3. Fixes the template, re-renders, and re-deploys
4. Does NOT report the change as "done" until inspection is GREEN

## Idempotency

Read-only. Safe to run multiple times. Screenshots accumulate in `/tmp/`; old ones can be deleted at any time.

## Failure modes

| Failure | Cause | Fix |
|---------|-------|-----|
| `no emacs server socket` | Spacemacs not running | Start Spacemacs first |
| `Connection refused` | Server socket stale | Restart Spacemacs |
| `Symbol void` on centaur-tabs var | centaur-tabs not loaded | Check if tabs layer is in dotfile |
| Font height wrong | `set-face-attribute` not firing | Check paren balance in user-config |
