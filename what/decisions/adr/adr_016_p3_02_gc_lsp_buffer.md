---
type: adr
adr_id: "016"
adr_kind: standard_config
title: "GC threshold + LSP read buffer: dotspacemacs-gc-cons 200 MB, dotspacemacs-read-process-output-max 4 MB"
status: accepted
created: 2026-05-07
updated: 2026-05-07
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, performance, gc, lsp, dotfile, p3, p3_02]
---

# ADR-016: GC Threshold + LSP Read Buffer Defaults

## Status

Accepted

## Context

P3-02 §1.3.2 (ELPA / version / dump) walk revealed that `dotspacemacs-gc-cons` and
`dotspacemacs-read-process-output-max` were absent from `dotfile.spacemacs.tmpl`,
meaning the template relied on Spacemacs upstream defaults:

- `dotspacemacs-gc-cons`: `'(100000000 0.1)` — 100 MB threshold, 10% trigger
- `dotspacemacs-read-process-output-max`: `(* 1024 1024)` — 1 MB LSP chunk size

The standard template already includes the `lsp` layer targeting Python, TypeScript, Rust,
Go, and JavaScript — all of which benefit from a larger LSP read buffer. The SpaceLattice
operator profile (ML ops, biomedical pipelines, agentic coding across multiple vaults) makes
heavy LSP use the expected baseline, not an edge case.

The friction signal: hitting GC pauses or LSP throughput degradation on large codebases while
Spacemacs silently uses defaults that Spacemacs's own documentation recommends increasing for
heavy LSP use.

## Decision

Add both variables to the `dotspacemacs/init` `setq-default` block in
`what/standard/dotfile.spacemacs.tmpl`:

```elisp
dotspacemacs-gc-cons '(200000000 0.1)
dotspacemacs-read-process-output-max (* 4 1024 1024)
```

**`dotspacemacs-gc-cons '(200000000 0.1)`** — 200 MB threshold (2× default), 10% trigger
unchanged. Applied after startup (Spacemacs uses a much higher transient value during init).
Spacemacs documentation recommends increasing for heavy LSP use. 200 MB is conservative on
modern hardware; power users run 512 MB.

**`dotspacemacs-read-process-output-max (* 4 1024 1024)`** — 4 MB per LSP output chunk (4×
default). The Emacs default of 4096 bytes is tiny; Spacemacs already bumps to 1 MB. For large
Python/TypeScript/Rust projects, 4 MB is the widely-recommended sweet spot. The expression form
`(* 4 1024 1024)` is kept for readability.

Both values are standard-template changes (not operator-private) because the LSP layer is
already in the standard template and these values benefit all SpaceLattice operators, not just
Stanley.

## Consequences

**Positive:**
- LSP throughput improves on large codebases without any per-operator configuration
- GC pauses during active coding sessions become rare
- Values are explicit in the template — operators can see and override them

**Negative / Trade-offs:**
- 200 MB GC threshold means GC runs less often but takes slightly longer when it does run;
  negligible on machines with ≥8 GB RAM
- No operator-private override needed — both values are appropriate defaults for the target
  use case

**Scope:**
- Modified: `what/standard/dotfile.spacemacs.tmpl` (2 lines added to `dotspacemacs/init`)

## Dry-run result

Template edit applied. `skill_health_check` (emacs --batch layer load) is the gate; runs on
next `skill_deploy` cycle. Syntactically valid elisp — both expressions are literal values with
no external dependencies.

## Operator approval

Accepted at P3-02 §1.3.2 session (2026-05-07). Operator confirmed all recommendations.
