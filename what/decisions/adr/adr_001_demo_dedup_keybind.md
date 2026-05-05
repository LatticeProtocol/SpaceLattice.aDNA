---
type: decision
adr_id: adr_001
adr_number: 1
title: "Remove duplicated `SPC a h` binding in adna layer keybindings"
status: accepted
adr_kind: synthetic_demo
proposed_by: agent_init
target_layer: standard
target_files:
  - what/standard/layers/adna/keybindings.el
detected_via:
  rule: E
  evidence: "key 'ah' bound 2 times in what/standard/layers/adna/keybindings.el (line 28: adna/health-check; line 37: adna/help-redundant)"
demonstrates: skill_self_improve closed loop (DoD #5)
created: 2026-05-04
updated: 2026-05-04
last_edited_by: agent_init
ratifies:
supersedes:
superseded_by:
tags: [decision, adr, self_improve, dedup, keybind, synthetic_demo, daedalus]
---

# ADR 001 (synthetic demo) — Remove duplicated `SPC a h` binding

## Status

**Accepted** at 2026-05-04 as part of the Phase 5 / DoD #5 demonstration.

> **Note**: This ADR is a synthetic demonstration produced by `skill_self_improve` against a deliberately-injected friction. The friction never enters committed history; this ADR + accompanying diff + dry-run log are the *evidence* that the closed loop works end-to-end.

## Context

`skill_self_improve` ran a routine vault-state check and Rule E (duplicated keybindings within a single `keybindings.el`) fired:

```
RULE E FIRES in what/standard/layers/adna/keybindings.el:
  key 'ah' bound 2 times
    line 28: "ah" -> adna/health-check
    line 37: "ah" -> adna/help-redundant
```

Two separate `(spacemacs/set-leader-keys ...)` calls bind `SPC a h`. The first (line 28) binds it to `adna/health-check` — the canonical health-check entry point. The second (line 37) binds it to a non-existent function `adna/help-redundant`. The second binding wins on the last-call-wins semantics of `spacemacs/set-leader-keys`, leaving `SPC a h` unusable.

This is exactly the friction class the loop is designed to catch. The synthetic injection at line 37 mimics the kind of accident an operator might commit during a hasty layer addition — adding a binding without checking whether the key was already taken.

## Decision

Remove line 37 (the `(spacemacs/set-leader-keys "ah" 'adna/help-redundant)` injection plus its preceding comment). `SPC a h` reverts to `adna/health-check` as documented in `adna-bridge.md`.

The diff is at `what/decisions/adr/adr_001.diff`.

## Consequences

- `SPC a h` is rebound to `adna/health-check` — matches `adna-bridge.md` § Capabilities table.
- Layer Contract clause 1 (standard is the commons) is restored.
- No operator-visible behavior change beyond `SPC a h` actually working.

## Alternatives considered

1. **Keep both bindings** — would require renaming the second to a different key. Rejected: `adna/help-redundant` doesn't exist as a function; it was injected as friction, not as a real feature. Real future work that needs a new binding goes through `skill_layer_add` with its own ADR.
2. **Keep the second binding (last-write-wins)** — accept the override. Rejected: implicit overrides via key-collision are the kind of brittleness the layer contract exists to prevent.
3. **Leave both, document the conflict** — Rejected: documentation doesn't fix the broken `SPC a h`.

## Reversibility

Trivial — the diff is one hunk. To revert, apply the inverse:

```bash
cd <vault-root>
git revert <commit-sha-of-this-adr-acceptance>
```

## Demonstration evidence (DoD #5)

- ADR (this file): `what/decisions/adr/adr_001_demo_dedup_keybind.md`
- Diff: `what/decisions/adr/adr_001.diff`
- Dry-run health-check log: `what/decisions/adr/adr_001.dryrun.log` (exit 0 — green)
- Detection script run inline; output captured above in § Context

The closed loop ran end-to-end: detect → draft → diff → dry-run → present → operator accept → commit. The duplicated `ah` binding never reached committed history; the injection was applied to the working tree, the ADR + diff produced, the dry-run validated the proposal, the operator accepted, and the apply step removed the injection in the same commit that landed this ADR.

## References

- Skill: `how/standard/skills/skill_self_improve.md`
- Detection rule: § "Rule E — Duplicated keybinding within one file"
- Spec: `what/standard/adna-bridge.md` § "Transient menu — `SPC a`"
