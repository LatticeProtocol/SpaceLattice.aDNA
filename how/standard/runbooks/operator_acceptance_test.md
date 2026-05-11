---
type: runbook
title: "Operator acceptance test — batch + boot validation checklist"
status: active
created: 2026-05-11
updated: 2026-05-11
last_edited_by: agent_stanley
phase_introduced: p5_03
tags: [runbook, acceptance, validation, batch, boot, checklist]
---

# Operator Acceptance Test

Structured checklist for validating a Spacemacs.aDNA install or deploy. Run in two stages: batch first (no running Emacs needed), then boot (requires live Emacs session).

Run after: `skill_install`, `skill_deploy`, any change to `what/standard/`.

---

## Stage 1 — Batch validation (no Emacs running)

```bash
# From vault root:

# 1a. Structural validation
python3 what/standard/index/validate_layers.py
# Expected: 7/7 checks passed

# 1b. Full health check (A-C + G + H; D/E/F/I SKIP if Emacs absent)
bash how/standard/skills/skill_health_check.md
# Or run the individual checks manually (see skill file)

# 1c. Byte-compile all layer elisp files
find what/standard/layers -name '*.el' -print0 \
  | xargs -0 emacs --batch -f batch-byte-compile 2>&1
# Expected: no Error lines (warnings for spacemacs/* stubs are expected and safe)
```

Stage 1 checklist:

```
BATCH VALIDATION
[ ] python3 validate_layers.py → 7/7 checks passed
[ ] skill_health_check A-C → all green
[ ] skill_health_check G → all LP layers byte-compile
[ ] skill_health_check H → validate_layers.py clean
[ ] skill_health_check I → layouts.el compiles + adna/layout-agentic-default defined
[ ] emacs --batch byte-compile → no Error lines
```

---

## Stage 2 — Boot validation (live Emacs session)

Start Spacemacs normally. Open any aDNA vault file to ensure adna-mode activates.

```
BOOT VALIDATION
[ ] Spacemacs starts without errors in *Messages*
[ ] adna layer loads: SPC a opens adna transient
[ ] SPC a h → MANIFEST.md opens
[ ] SPC a g → graph.json opens (or prompts to generate)

LAYOUT VALIDATION
[ ] SPC a l → layouts transient opens (a/v/c/r keys visible)
[ ] SPC a l a → agentic-default layout activates
    - treemacs on left
    - file buffer in center
    - Claude Code terminal on right (80-col)
[ ] SPC a l v → vault-navigation layout activates
[ ] SPC a l c → campaign-planning layout activates
[ ] SPC a l r → code-review layout activates
[ ] All 4 layouts cycle without errors in *Messages*

CLAUDE CODE INTEGRATION
[ ] SPC c c → Claude Code menu opens
[ ] SPC c s → Claude Code session starts in project root
[ ] Claude terminal appears on right side (80-col per ADR-036)
[ ] SPC c t → Claude window toggles hide/show
[ ] SPC a , s → adna/claude-project-switch runs (layout + session list)

AGENT COMMAND TREE
[ ] SPC a x → agent-extensions transient opens
[ ] SPC a x s → adna/show-sitrep runs (STATE.md + session side-by-side)
[ ] SPC a x h → adna/run-health-check opens vterm health check
[ ] SPC a x o → adna/open-claude-with-layout activates layout + Claude

GRAPH + INDEX
[ ] M-x adna-index-project → graph.json updated (N nodes, M edges in *Messages*)
[ ] graph.json mtime newer than before the command
```

---

## Stage 3 — Sign-off

When both stages pass, record the result in the deploy receipt (`deploy/<hostname>/<utc>.md`):

```yaml
acceptance_test: passed
acceptance_test_date: YYYY-MM-DD
batch_checks: 7/7
boot_checks: all-green
operator: stanley
```

If any check fails, diagnose before proceeding. See `how/standard/runbooks/recover_from_breakage.md` for repair playbook.
