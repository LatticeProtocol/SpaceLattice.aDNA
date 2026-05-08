---
type: aar
mission_id: mission_sl_p3_02_dotspacemacs_variables
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
status: completed
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
sessions: [session_stanley_20260507T_campaign_review, session_2026_05_08_p3_02_finish]
tags: [aar, p3, p3_02, dotspacemacs_variables, customization]
---

# AAR — P3-02: dotspacemacs-* variables walk

**Mission**: Walk all ~85 `dotspacemacs-*` variables across 10 sub-groups; operator confirms or
changes each; decisions recorded in operator profile; changes land in template (ADR-gated).

**Completed**: 2026-05-08 across 2 sessions (2026-05-07 §1.3.1–§1.3.6, 2026-05-08 §1.3.7–§1.3.10).

---

## Scorecard

| Sub-group | Variables | Result | Changes | ADRs |
|-----------|-----------|--------|---------|------|
| §1.3.1 Layer / package mgmt | 4 | CONFIRMED | 0 | — |
| §1.3.2 ELPA / version / dump | 8 | CONFIRMED + 2 changes | gc-cons 200 MB, LSP buffer 4 MB | ADR-016 |
| §1.3.3 Editing style & leaders | 8 | CONFIRMED | 0 | — |
| §1.3.4 Startup buffer / banner / lists | 13 | CONFIRMED | 0 | — |
| §1.3.5 Themes / modeline / fonts / cursor | 5 | CONFIRMED | 0 | — |
| §1.3.6 Layouts / sessions | 4 | CONFIRMED | 0 | — |
| §1.3.7 Files / autosave / rollback | 4 | CONFIRMED | 0 | — |
| §1.3.8 which-key / cycling / windowing | 8 | CONFIRMED | 0 | — |
| §1.3.9 Frame appearance | 12 | CONFIRMED + 1 change | background-transparency 100 | ADR-020 |
| §1.3.10 Editing knobs | 19 | CONFIRMED | 0 | — |
| **TOTAL** | **85** | | **3 changes** | **ADR-016, ADR-020** |

---

## Five-Line AAR

**Worked**: 7-step operator-in-the-loop protocol scaled cleanly to 10 sub-groups across 2
sessions. One group per round kept cognitive load manageable. Operator confirmed with high
signal-to-noise — most variables were already set correctly in the template from prior missions.

**Didn't**: The reference doc (`spacemacs_customization_reference.md`) and the template
(`dotfile.spacemacs.tmpl`) were out of sync — 10 new variables present in the reference were
absent from the template. This gap was not surfaced at mission open, forcing inline
cross-referencing that slowed each sub-group pass.

**Finding**: `dotspacemacs-background-transparency` is a commonly overlooked variable distinct
from `active-transparency`/`inactive-transparency`. Setting it explicitly to 100 (opaque
background) is the right default for code-focused setups — the upstream default of 90 causes
compositor bleed-through that degrades readability.

**Change**: Future P3-02-style walks should include a template vs. reference variable-count
cross-check at mission open. Detecting gaps before the walk begins (rather than inline) would
reduce per-sub-group friction and allow pre-drafting ADRs for known additions.

**Follow-up**: None blocking P3-03. `skill_health_check` on next `skill_deploy` validates
ADR-020 template edit. Operator profile §1.3.7–§1.3.10 decisions are recorded. P3-03
(layer anatomy / API) is next.

---

## Changes landed

| File | Change | ADR |
|------|--------|-----|
| `what/standard/dotfile.spacemacs.tmpl` | Added `dotspacemacs-gc-cons '(200000000 0.1)` | ADR-016 |
| `what/standard/dotfile.spacemacs.tmpl` | Added `dotspacemacs-read-process-output-max (* 4 1024 1024)` | ADR-016 |
| `what/standard/dotfile.spacemacs.tmpl` | Added `dotspacemacs-background-transparency 100` | ADR-020 |
| `who/operators/stanley.md` | §1.3.1–§1.3.10 decisions recorded (full variable table per sub-group) | — |
| `what/decisions/adr/adr_020_p3_02_background_transparency.md` | ADR filed and accepted | ADR-020 |
