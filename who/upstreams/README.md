---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [upstreams, who, spacemacs]
---

# who/upstreams/

Spacemacs maintainers, layer authors, and elisp library maintainers whose work this vault depends on.

Each entry documents:
- Who they are
- What they maintain
- Where their canonical source lives
- How we engage (issues upstream, contribute back, mirror selectively)

## Upstream engagement model

When `skill_self_improve` proposes a change that would improve an upstream package itself rather than just our local config, the resulting ADR includes a `target: upstream` field; the diff is filed as a PR to the upstream repo (after operator approval). Credit flows up, contributions flow down.
