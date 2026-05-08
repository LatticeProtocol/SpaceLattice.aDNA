---
type: adr
adr_number: 022
title: "Change frame-title-format to buffer + project"
status: accepted
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, p3, frame-title, presentation]
---

# ADR-022: Change frame-title-format to Buffer + Project

## Status

Accepted

## Context

P3-04 customization walk — §1.9 frame title. The current standard default is `"%I@%S"` (buffer-size indicator + hostname). This format is designed for multi-machine identification but provides little context in a single-operator setup. Operators running across multiple projects benefit more from seeing *which buffer* and *which project* they're in, especially when switching between Spacemacs windows on macOS (Cmd+Tab shows the title bar).

The operator selected the buffer + project format during the P3-04 walk.

## Decision

Change `dotspacemacs-frame-title-format` in `what/standard/dotfile.spacemacs.tmpl` from:

```elisp
dotspacemacs-frame-title-format "%I@%S"
```

to:

```elisp
dotspacemacs-frame-title-format '("%b [" (:eval (projectile-project-name)) "]")
```

This produces titles like `init.el [Spacemacs.aDNA]`. It requires projectile to be active (always true — projectile is a core Spacemacs dependency). Falls back gracefully to `"No Project"` when outside a projectile project.

## Consequences

### Positive
- Frame title shows buffer name + project root — immediately useful when Alt-Tab switching
- Self-documenting at a glance: no need to check the mode-line for current project context
- Works on all platforms (no icon fonts required)

### Negative
- Drops hostname identifier from title — operators using remote emacs over SSH must rely on other signals (terminal title, modeline) for host identification
- `(:eval ...)` introduces a minor recomputation on every frame title update (negligible cost)

### Neutral
- Operators who prefer the old format can revert in `operator.private.el`: `(setq frame-title-format "%I@%S")`
