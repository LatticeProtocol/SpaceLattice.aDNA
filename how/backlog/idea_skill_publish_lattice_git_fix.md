---
type: backlog
idea_id: idea_skill_publish_lattice_git_fix
status: ready
priority: high
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
tags: [backlog, upstream, publish, git, skill, adna_template, infrastructure]
target_phase: upstream
upstream_campaign: campaign_adna_v2_infrastructure
upstream_vault: aDNA.aDNA
promoted_to_mission: mission_adna_infra_planning_01
---

# Idea — Fix skill_publish_lattice: proper git remote instead of rsync clone

## Origin

Surfaced during P3-02 §1.3.6 session wind-down (2026-05-07). The Spacemacs vault has no
configured git remote because `skill_publish_lattice` uses a detached `.publish-clone/` workaround
instead of configuring the vault's own git repo as the origin.

## Problem

The current `skill_publish_lattice` (in `how/standard/skills/skill_publish_lattice.md` and the
aDNA template at `.adna/how/skills/skill_publish_lattice.md`) uses:
- `rsync` to copy filtered vault content to a temp directory
- A separate `.publish-clone/` git repo that gets pushed to GitHub
- The vault itself has no `git remote` — normal git ops don't work

This is wrong for a maintained distribution. The vault IS the git repo. Normal `git push`
should be the publish operation.

## Root Cause

The rsync approach was designed to handle private-file exclusion. But `.gitignore` already
handles this — `what/local/`, `how/local/`, `who/operators/`, `deploy/` are all gitignored.
The rsync step solves a problem that doesn't exist.

## Fix (upstream — aDNA template level)

This is a template-level fix that benefits ALL vaults using the publish skill:

1. **`skill_publish_lattice.md` rewrite**: First-use: `git remote add origin <url>`. Subsequent
   use: `git push`. Sanitization scan becomes a pre-push hook (not a manual step).

2. **New `skill_git_remote_setup.md`**: Handles first-time remote configuration — creates
   GitHub repo via `gh`, configures remote, sets branch, pushes.

3. **Pre-push sanitization hook**: `how/standard/hooks/pre-push-sanitize.sh` — runs the
   LAYER_CONTRACT §4 scan on staged content before each push. Hook installed by skill_install.

4. **Tarball as optional artifact**: Tarball generation extracted to `skill_publish_tarball.md`
   for operators who want offline-shipping artifacts. Not the primary publish mechanism.

## Impact

- All vaults using `skill_publish_lattice` get maintainable git origins
- Spacemacs can then `git remote add origin github.com/LatticeProtocol/Spacemacs.aDNA`
  and use normal git ops for all maintenance
- `.publish-clone/` pattern eliminated from the template

## Upstream campaign

Being addressed by `campaign_adna_v2_infrastructure` M04 in `aDNA.aDNA/`.
Track progress there. This backlog item can be closed when the aDNA template ships the fix
and Spacemacs updates its instance.
