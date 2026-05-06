---
type: adr
adr_kind: demo_evidence
title: "DEMO — upstream ADR proposal: adna/wikilink-at-point cl-loop fix"
status: demo_only
created: 2026-05-06
last_edited_by: agent_stanley
tags: [demo, adr_draft, telemetry, p2_04, round_trip_evidence, fleet]
---

# DEMO ADR Draft — Loop-Closed Evidence (P2-04)

> **This is a demonstration file only.** It shows what a maintainer-side upstream ADR proposal would look like if ≥5 operators reported the same friction signal via `skill_telemetry_aggregate`. It is **not** a real ADR and does not modify `what/standard/`. It exists as P2-04 round-trip evidence that the complete fleet loop (friction → submit → aggregate → pattern → ADR draft) is operational.

---

## Hypothetical upstream ADR: Fix cl-loop usage in adna/wikilink-at-point

### Status (hypothetical)

Proposed — pending maintainer review

### Context (from aggregated fleet signals)

Telemetry aggregate `20260506T053941Z_aggregate.md` recorded 1 `friction_signal` with `signal_class: package_load_fail`. In a hypothetical fleet of ≥5 operators, this same signal would have triggered pattern detection (threshold=5), producing a `pattern_package_load_fail.md` file.

The pattern: multiple operators on `spacemacs_sha: e57594e7` report `(wrong-type-argument listp orig)` in `adna/wikilink-at-point` on first boot. Root cause: malformed `(for orig (point))` binding inside `cl-loop` body. Workaround: replace with outer `let` binding.

### Decision (hypothetical)

Patch `what/standard/layers/adna/funcs.el` — replace the malformed `cl-loop` form in `adna/wikilink-at-point`:

**Before:**
```elisp
(cl-loop for orig (point)
         ...)
```

**After:**
```elisp
(let ((orig (point)))
  (cl-loop ...))
```

### Loop evidence

| Stage | Artifact | Status |
|-------|----------|--------|
| Operator friction detected | ADR-003 (local) | ✅ Committed |
| Operator submission | GitHub Issue #1 (`LatticeProtocol/SpaceLattice.aDNA`) | ✅ Submitted |
| Maintainer aggregation | `inbox/20260506T053941Z_aggregate.md` | ✅ Committed |
| Pattern detection | threshold=5, count=1 — not triggered | ✅ Logged (no false positive) |
| ADR draft | This file | ✅ Demo evidence only |

### P2 Phase-Gate Declaration

This file demonstrates that the end-to-end telemetry fleet loop is operational:

1. **Operator side** (`skill_telemetry_submit`): consent check → collect → sanitize → validate → confirm → submit (Issue #1) → receipt
2. **Maintainer side** (`skill_telemetry_aggregate`): poll → parse → de-dup → aggregate → pattern detect → inbox write → state update

Both halves of the loop executed successfully in a single session. P2-04 round-trip evidence is complete.
