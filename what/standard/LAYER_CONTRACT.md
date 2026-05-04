---
type: contract
status: stub
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
implementation_phase: 6
ratified_by: what/decisions/adr/adr_000_vault_identity.md
tags: [contract, layers, standard, local, overlay, governance]
---

# LAYER_CONTRACT

> **Phase 2 stub.** Full contract authored in **Phase 6**. This file establishes the placeholder so all other Phase 2 references resolve.

## Overview

The vault enforces three filesystem-level configuration layers with strict precedence at deploy time:

```
overlay/  (third-party Spacemacs distros — proposes via ADR; never silently overwrites)
   ↓
standard/ (shared, deterministic, reproducible — the published commons)
   ↓
local/    (per-operator, gitignored — never published unless explicitly promoted)
```

## Phase 6 will formalize

Each clause will become a numbered, normative requirement with verification mechanism:

1. **Standard is the commons** — must build on a fresh machine with no `local/` present; contains no secrets/hostnames/operator-paths; passes `skill_health_check`.
2. **Local is private** — `.gitignore` enforces; `git ls-files | grep -E '(local/|secrets|\.private\.)'` must return empty as a CI/health-check assertion.
3. **Overlay is third-party** — `skill_overlay_consume` is the only consumption path; per-layer ADR-gated disposition (merge-into-standard | hold-in-overlay | reject); no silent overwrites.
4. **Promotion ritual** — `local/` → `standard/` requires successor ADR + sanitization scan + operator approval.
5. **License interlock** — standard layer follows GPL-3.0 (matches Spacemacs upstream); contributions to `what/standard/layers/adna/` follow same.
6. **Sanitization scan** — script that scans for hostname patterns, common path-prefix patterns, and known-secret patterns. Defined in Phase 6.

## Until Phase 6 lands

Operators changing `what/standard/` content should:

1. Open an ADR in `what/decisions/adr/`
2. Run `skill_health_check` mentally (Phase 3 will give it teeth)
3. Avoid committing anything operator-specific to `standard/`

The full contract supersedes this stub when written.
