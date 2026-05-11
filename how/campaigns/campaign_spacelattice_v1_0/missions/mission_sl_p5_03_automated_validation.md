---
type: mission
mission_id: mission_sl_p5_03_automated_validation
campaign: campaign_spacelattice_v1_0
campaign_phase: 5
campaign_mission_number: 3
status: planned
mission_class: implementation
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
tags: [mission, planned, spacemacs, v1_0, p5, validation, testing, health_check, ci, adr_037]
blocked_by: [mission_sl_p5_00_strategic_aar_gap_analysis]
---

# Mission — P5-03: Automated Testing/Validation Infrastructure

**Phase**: P5 — Polish + v1.0 release.
**Class**: implementation.

## Objective

Expand the automated validation infrastructure so that the full layer stack can be verified without a running Emacs session. Currently CI byte-compiles all `.el` files, but has no structural validation. This mission adds a layer structure validator, extends `skill_health_check`, updates CI, and produces an operator acceptance test runbook that covers what batch testing cannot.

**Honest scope statement**: Full UI validation (layout rendering, Claude Code window placement, which-key output) requires a running Emacs session and operator sign-off. Automated checks cover: byte-compilation, layer structure, key function definitions, vault structure. This is the right split of concerns.

## Deliverables

### 1. `what/standard/index/validate_layers.py`
New Python script that validates layer structure without Emacs:

```python
# Checks run by validate_layers.py:
# 1. Each dir in what/standard/layers/ has packages.el
# 2. Each dir has layers.el
# 3. Each layers.el contains 'spacemacs-bootstrap' (load-order declaration)
# 4. adna/keybindings.el defines 'adna/extensions-menu' (SPC a x stub live)
# 5. claude-code-ide/keybindings.el defines SPC c bindings
# 6. adna/layouts.el defines 'adna/layout-agentic-default' (after P5-01)
# 7. No file in what/standard/ contains operator home paths (~/<name>/ or /Users/<name>/)
#    (sanitization check, mirrors LAYER_CONTRACT.md §3)
# Exit 0 = all checks pass; exit 1 = failures reported to stdout
```

Run: `python3 what/standard/index/validate_layers.py`

### 2. `skill_health_check.md` expansion
Add three new checks to the existing A-F battery:

**Check G — All LP layers byte-compile**:
```bash
for layer in what/standard/layers/*/; do
  emacs --batch --eval "(byte-compile-file \"${layer}keybindings.el\")" 2>&1
done
# Exit 0 = all clean (warnings for spacemacs/* APIs expected and ignored)
```

**Check H — Layer structure validation**:
```bash
python3 what/standard/index/validate_layers.py
# Exit 0 = structure valid
```

**Check I — Graph freshness** (soft check, warn-only):
```bash
# Check that graph.json is newer than the newest .md file in the vault
# Warn if stale; do not fail (graph rebuild is operator-triggered)
python3 what/standard/index/build_graph.py --validate
```

### 3. `.github/workflows/ci.yml` update
Add `validate_layers` job alongside existing `byte-compile` matrix:

```yaml
validate:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-python@v5
      with: { python-version: '3.11' }
    - run: python3 what/standard/index/validate_layers.py
```

CI now has two gates: byte-compile (existing, multi-Emacs-version) + structure validation (new, Python, no Emacs needed).

### 4. `how/standard/runbooks/operator_acceptance_test.md`
Structured checklist for what the operator validates at first boot (covers what batch cannot):

```
LAYER VALIDATION (batch — run before boot):
[ ] emacs --batch byte-compile: all layers pass
[ ] python3 validate_layers.py: all structure checks pass
[ ] skill_health_check A-I: all green

BOOT VALIDATION (live — operator verifies at first Emacs session):
[ ] Spacemacs starts without errors in *Messages*
[ ] adna layer loads: SPC a opens transient
[ ] SPC a l available: layouts transient opens
[ ] SPC a l a: agentic-default layout activates (treemacs + file buffer + Claude area)
[ ] SPC c c: Claude Code menu opens
[ ] SPC c s: Claude Code session starts in project root
[ ] Claude terminal appears in expected window position (right side)
[ ] SPC c t: Claude window toggles hide/show
[ ] SPC a x: agent-extensions transient opens
[ ] SPC a h: MANIFEST.md opens
[ ] M-x adna-index-project: graph.json updated (N nodes, M edges printed)
[ ] SPC a x opens — placeholder entry visible

LAYOUT VALIDATION (live):
[ ] SPC a l v: vault-navigation layout activates
[ ] SPC a l c: campaign-planning layout activates
[ ] SPC a l r: code-review layout activates
[ ] All layouts cycle cleanly (no errors in *Messages*)
```

### 5. ADR-037
`what/decisions/adr/adr_037_automated_validation_expansion.md`:
- Problem: CI only byte-compiles; no structural validation; no operator acceptance checklist
- Decision: add `validate_layers.py` + health check G/H/I + CI job + operator acceptance runbook
- Scope of automation: layer structure, function existence, sanitization; NOT UI rendering
- Handoff: batch checks → CI gate; UI validation → operator runbook at each major install

## Estimated effort

1 session.

## Dependencies

P5-00 (gap register may add specific checks to validate_layers.py). Can run in parallel with P5-01/P5-02 since it doesn't depend on layouts.el existing — but check I is conditional.

## Reference

- `.github/workflows/ci.yml` (existing byte-compile CI to extend)
- `how/standard/skills/skill_health_check.md` (existing A-F checks)
- `what/standard/index/build_graph.py` (pattern for Python validator)
- `what/standard/LAYER_CONTRACT.md` (sanitization rules for check H §3)
- ADR-014 (closed-loop validation decision)
