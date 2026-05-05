---
type: mission
mission_id: mission_sl_p4_06_news_welcome_dotfile
campaign: campaign_spacelattice_v1_0
campaign_phase: 4
campaign_mission_number: 6
status: planned
mission_class: implementation
created: 2026-05-05
updated: 2026-05-05
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p4, fork_branding, news, welcome, dotfile_template]
blocked_by: [mission_sl_p4_05_banner_assets]
---

# Mission — P4-06: News + welcome widget + dotfile template

**Phase**: P4 — Fork branding (LP playbook execution).
**Class**: implementation.

## Objective

Author 3 fork-side artifacts: (a) `core/news/news-1.0.0.org` (LP release note for the v1.0 tag, ships at P5-03); (b) `layers/+distributions/spacelattice/local/lp-welcome/lp-welcome.el` (welcome widget per customization reference §4B.3 example); (c) `core/templates/dotspacemacs-template.el` patch with LP-specific defaults (default distribution, default themes, default frame-title-format).

## Deliverables

- `core/news/news-1.0.0.org` — release note (final content updated at P5-03)
- `lp-welcome.el` — version-gated welcome buffer (per `customization_reference.md` §4B.3 reference implementation)
- `core/templates/dotspacemacs-template.el` patch:
  - `dotspacemacs-distribution 'spacelattice` (default)
  - `dotspacemacs-themes '(latticeprotocol-dark latticeprotocol-light spacemacs-dark)`
  - `dotspacemacs-frame-title-format "%I@%S [LP]"`
- Vault-side: `what/standard/spacelattice_dotfile_template_overrides.md` documenting the patch
- ADR: `adr_017_<slug>.md` ratifying the template patch

## Estimated effort

1-2 sessions.

## Dependencies

P4-05 closed.

## Reference

- `what/context/spacemacs/spacemacs_customization_reference.md` §4A.6 + §4A.10 + §4B.3 (welcome + dotfile template + news)
- P3-08 operator profile (default-layer set decisions feed dotfile template)
