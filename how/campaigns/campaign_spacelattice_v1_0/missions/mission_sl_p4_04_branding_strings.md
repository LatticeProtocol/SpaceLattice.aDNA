---
type: mission
mission_id: mission_sl_p4_04_branding_strings
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 4
status: completed
mission_class: implementation
created: 2026-05-05
updated: 2026-05-09
completed: 2026-05-09
last_edited_by: agent_stanley
tags: [mission, completed, spacelattice, v1_0, p4, fork_branding, strings]
blocked_by: []
---

# Mission — P4-04: Branding strings (logo title, buffer name, version, repository constants)

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Patch fork core files to apply LP branding strings: `core/core-spacemacs-buffer.el` (logo-title + buffer-name + banner-image-path lookup), `core/core-versions.el` (add `latticeprotocol-version` defconst preserving `spacemacs-version`), `core/core-spacemacs.el` (repository constants for self-hosted update-check). Per customization reference §4B.3 diffs. Prefer additive changes via a `core/lp-branding.el` module per fork-strategy mitigation strategy (reduce rebase conflict surface).

## Deliverables

- `core/lp-branding.el` (new additive module) loaded via single-line patch upstream of relevant `core/core-*.el` files
- `latticeprotocol-version` defconst at "0.1.0" (or matching fork tag at this point)
- `spacemacs-buffer-logo-title` → `"[L A T T I C E   P R O T O C O L]"`
- `spacemacs-buffer-name` → `"*spacelattice*"` (matches repo name)
- Repository constants → `LatticeProtocol/spacelattice` + `lp-stable` branch
- Vault-side: `what/standard/spacelattice_branding_patch_spec.md` cataloguing all string locations + replacement values
- ADR: `adr_015_<slug>.md` ratifying the patch set + rebase mitigation strategy

## Estimated effort

1 session.

## Dependencies

P4-03 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §4A.5 + §4B.3 (branding strings + version-string changes)
- `what/standard/fork-strategy.md` § Mitigations (additive overrides)

---

## AAR (2026-05-09)

**Worked**: All 5 branding overrides applied via `setq`/`defconst` in `config.el` per vault-only model (ADR-024); `spacelattice_branding_patch_spec.md` + ADR-027 filed; 1 session as estimated.

**Didn't**: Original mission spec described `core/lp-branding.el` fork patching — that approach was never applicable given ADR-024 was accepted the same day the mission was created.

**Finding**: Mission deliverables list referenced `adr_015_<slug>` as the ADR to file, but ADR-015 was already taken (vault deployment model). Branding ADR landed as ADR-027. Future missions should leave ADR number as TBD at creation time.

**Change**: `config.el` already had a stub `latticeprotocol-version "0.1.0-alpha"` — updated to `"0.1.0"` to match the mission spec; the `setq` overrides were uncommented and corrected (stub had wrong values).

**Follow-up**: P4-05 (banner assets) must supply `img/latticeprotocol.png` and wire the `spacemacs-buffer//choose-banner` path override (item 7 in branding spec, currently deferred).
