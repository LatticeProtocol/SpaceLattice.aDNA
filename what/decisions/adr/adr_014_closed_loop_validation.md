---
type: adr
adr_id: "014"
adr_kind: standard_config
title: "Closed-loop validation: skill_inspect_live + skill_health_check D+ + skill_deploy Step 9"
status: accepted
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, validation, emacsclient, inspect, health_check, deploy, p3]
---

# ADR-014: Closed-Loop Validation Infrastructure

## Status

Accepted

## Context

Through P3 pre-flight (visual layer configuration), the edit-validate loop required the operator to take screenshots and share them because the agent had no direct access to the running IDE's state. This created a slow and error-prone feedback cycle:

- Changes were applied to `dotfile.spacemacs.tmpl` and rendered to `~/.spacemacs`
- `emacs --batch` validated load-time correctness only
- Font size was wrong (15pt rendering as ~8pt) for multiple iterations before the integer-vs-float root cause was found
- centaur-tabs filter was applied with incorrect API (`defun` override vs `excluded-prefixes` list) and went undetected because batch-boot doesn't exercise runtime tab state
- Each cycle required operator restart + screenshot + agent re-analysis

Root cause: `emacs --batch` loads the dotfile in headless mode and exits. It can detect syntax errors and missing packages, but cannot validate runtime state: variable values, face attributes, minor-mode activation, tab rendering.

The Emacs server has been running the entire time (`dotspacemacs-enable-server t` in `dotfile.spacemacs.tmpl`). `emacsclient` can connect to it and eval arbitrary elisp, giving the agent full read access to the running IDE's state — including font height, tab filter lists, doom-modeline activation, projectile paths, and buffer lists. macOS `screencapture` provides visual capture without requiring the operator to share screenshots.

Operator explicitly requested this improvement: "we need you to be able to inspect/run/validate the changes to the SpaceLattice.aDNA context graph system and the version of spacemacs that it builds/operates/runs yourself so that we won't need to be taking screen shots and having you double check."

## Decision

Add a closed-loop validation layer to the SpaceLattice.aDNA skill stack:

**1. `skill_inspect_live` (new skill)** — Standalone live inspection using emacsclient + screencapture:
- Dynamically discovers the emacs server socket (`/var/folders/.../emacs<uid>/server`)
- Queries running instance for: font height, centaur-tabs excluded-prefixes, doom-modeline activation, projectile search path, buffer list
- Asserts expected standard values (font=150, tabs star-filter, doom active, proj path set)
- Takes a screenshot via `screencapture -x` and reads it back into Claude Code context
- Reports GREEN or RED with per-assertion detail

**2. `skill_health_check` Check D+ extension** — Live assertions added as Check D+:
- Runs after Check D (batch boot) when emacsclient is available
- Asserts same four values as skill_inspect_live
- Exits 70-79 on live assertion failure
- Skips gracefully when Spacemacs is not running

**3. `skill_deploy` Step 9** — Post-deploy reload guidance + inspection:
- Determines reload type from what changed (user-config edits → `SPC f e R`; layer/init changes → `SPC q r`)
- Instructs operator with the minimum disruptive reload
- Runs `skill_inspect_live` after operator reloads
- A deploy is not marked done until `skill_inspect_live` is GREEN

**4. Reload-type annotations in `dotfile.spacemacs.tmpl`** — Comment at top of `dotspacemacs/user-config` explaining the hot-reload vs full-restart boundary.

## Consequences

**Positive:**
- Agent can validate most configuration changes without operator screenshots
- Faster iteration: identify root cause in minutes rather than restart cycles
- centaur-tabs, font, doom-modeline, projectile all become directly inspectable
- Visual capture via screencapture closes the visual feedback loop

**Negative / Trade-offs:**
- `skill_inspect_live` requires Spacemacs to be running; cannot replace batch-boot for cold validation
- Screenshot capture adds ~1s; the image read adds context window cost (small)
- emacsclient socket path is session-specific on macOS (find by uid, not hardcoded)
- `SPC f e R` hot-reload does not reload `dotspacemacs/init` — changes there still need full restart

**Scope:**
- No changes to `what/standard/dotfile.spacemacs.tmpl` configuration logic
- New files: `how/standard/skills/skill_inspect_live.md`
- Modified files: `how/standard/skills/skill_health_check.md`, `how/standard/skills/skill_deploy.md`
- Template annotation: comment-only change in `dotfile.spacemacs.tmpl`

## Dry-run result

Live inspection executed in the session immediately preceding this ADR:

```
font-height: 150 ✓
centaur-tabs-excluded-prefixes has "*": YES ✓
doom-modeline-mode: t ✓
projectile-project-search-path: ("/Users/stanley/lattice/") ✓
VISIBLE-TABS: nil ✓
```

Screenshot captured, read into context, visual state confirmed without operator screenshot.

## Operator approval

Accepted by operator command "Make it so." (2026-05-06, P3-00 session).
