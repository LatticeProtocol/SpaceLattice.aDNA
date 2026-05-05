---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
implementation_phase: 6
tags: [overlay, what, third_party, contract]
---

# what/overlay/

The **overlay layer** — third-party Spacemacs distributions or substantial layer collections that an operator wants to consume without losing track of provenance. Examples:

- A custom "eMac" Spacemacs distribution from someone else's GitHub
- A theme pack with multiple coordinated layers
- An institution's standardized Spacemacs config

Overlays sit between `standard/` (commons) and `local/` (private) in two senses:

1. **Provenance**: an overlay clearly came from somewhere (we track the upstream URL and pinned SHA).
2. **Decision-making**: each overlay layer goes through ADR-gated per-layer disposition before it can affect deploy.

## Consumption protocol

`how/standard/skills/skill_overlay_consume.md` (Phase 6) is the only sanctioned path. Workflow:

1. Operator names the overlay + provides upstream URL.
2. Skill clones into `what/overlay/<name>/` and pins the SHA.
3. Skill enumerates the overlay's layers (parsing the overlay's own layer manifest if present).
4. Skill emits an ADR proposing per-layer disposition:
   - **`merge into standard`** — copy the layer's behavior into `what/standard/layers/<layer>/`, attribute upstream
   - **`hold in overlay`** — keep here, deploy reads from this dir, don't merge
   - **`reject`** — don't deploy, archive
5. Operator approves per-layer choices.
6. Skill updates `what/standard/dotfile.spacemacs.tmpl`'s layer list according to dispositions.

## Strict invariant

**Overlays NEVER silently overwrite standard.** If an overlay layer has the same name as a standard layer, the ADR must explicitly choose: replace (full override), merge (combine variables/keybindings), or reject. Default is reject.

## Phase 6 deliverables

This README is the Phase 2 placeholder. Phase 6 will add:

- `skill_overlay_consume.md`
- License-compatibility scanner (ensure overlay license is GPL-3.0 compatible)
- A worked example consuming a hypothetical "eMac" distribution

## Currently consumed overlays

None yet — this vault is genesis (2026-05-03).
