---
type: mission
mission_id: mission_sl_p5_06_second_machine_install
campaign: campaign_spacelattice_v1_0
campaign_phase: 5
campaign_mission_number: 6
status: planned
mission_class: verification
created: 2026-05-05
updated: 2026-05-11
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p5, polish, second_machine, peer_install]
blocked_by: [mission_sl_p5_05_doc_pass]
---

# Mission — P5-02: Second-machine install validation (true peer scenario)

**Phase**: P5 — Polish + v1.0 release.
**Class**: verification.

## Objective

True peer-install validation on a second host (operator's secondary machine, or VM). Run `skill_install` end-to-end from a clean clone of the published v1.0 tarball or the GitHub repo. Health-check + adna index. Receipt to `deploy/<host>/`. This validates that the install procedure works for a peer operator, not just on the development host.

## Deliverables

- Clean-host install evidence: `deploy/<host>/<utc>.md` receipt
- `skill_health_check` output: green
- `M-x adna-index-project` output: graph.json populated (sane node + edge counts)
- Branding visible: banner + modeline + frame title (LP) confirmed via screenshot or first-boot output capture
- `~/.spacemacs` matches expected dotfile (per `dotspacemacs-template.el` LP defaults from P4-06)
- Cross-host parity confirmed: operator's two hosts share the install footprint

## Estimated effort

1 session.

## Dependencies

P5-01 closed.

## Reference

- `how/standard/skills/skill_install.md` (post-P4-08 update)
- `how/standard/skills/skill_health_check.md`
- `deploy/` directory convention (gitignored, hostname-scoped)
