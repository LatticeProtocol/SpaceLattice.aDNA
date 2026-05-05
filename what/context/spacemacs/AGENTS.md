---
type: agents_guide
status: active
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_init
tags: [agents, context, spacemacs, customization, reference]
---

# what/context/spacemacs/

Reference material on Spacemacs internals, customization surface, and the LatticeProtocol fork playbook. Load this directory's content when working on:

- Customization missions (v1.0 campaign Phase 3 — walking the 22 dimensions)
- Fork branding work (v1.0 campaign Phase 4 — implementing LP playbook in `LatticeProtocol/spacelattice`)
- Designing skill_layer_add or skill_overlay_consume changes
- Diagnosing emacs/Spacemacs issues that need internals knowledge

## Files

| File | Purpose | When to load |
|------|---------|--------------|
| `spacemacs_customization_reference.md` | Operator-supplied reference covering: dotfile entry points (5 functions × lifecycle), `dotspacemacs-*` variable enumeration (~85 variables across 9 groups), layer anatomy, `configuration-layer/` API surface, theme system, modeline, banner, startup buffer, lifecycle ordering, performance knobs, broad-survey of customization patterns, **and the full LatticeProtocol fork playbook** (touchpoint map + concrete file diffs + rebase strategy + namespace hygiene). ~30K tokens. | Whenever a mission references the customization surface or the fork playbook |

## Loading discipline

This is large reference material. Don't load the whole file unless the mission's context budget allows. The reference is structured so individual sections can be quoted:

- §1 — Customization Surface (object inventory)
- §2 — Dimensions of Variation
- §3 — Customizations in the Wild
- §4A — Concept-level Touchpoint Map (LP fork)
- §4B — Concrete Fork Playbook

Cite by section in mission docs (e.g., "M-Customize-03 walks §1.3 — `dotspacemacs-*` variables").

## Provenance

Operator-supplied 2026-05-05; verbatim text persisted as in-vault context. ADR 005 § "Decision 3" ratifies the reposition that motivated the doc's persistence.

## Related context

- `what/standard/fork-strategy.md` — high-level strategy (this dir's reference is the *spec*)
- `what/standard/lp-positioning.md` — LP-stack placement
- `what/standard/pins.md` — pinned Spacemacs SHA we build against
- `who/upstreams/spacelattice_fork.md` — fork provenance + rebase cadence
