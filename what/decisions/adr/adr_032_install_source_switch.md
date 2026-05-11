---
type: adr
adr_number: 032
title: "Install source switch: syl20bnr/spacemacs → LatticeProtocol/spacelattice"
status: accepted
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
supersedes:
superseded_by:
tags: [adr, decision, install, fork, pin, p4_08]
---

# ADR-032: Install source switch — syl20bnr/spacemacs → LatticeProtocol/spacelattice

## Status

Accepted

## Context

`skill_install` Step 3 currently clones Spacemacs from `https://github.com/syl20bnr/spacemacs.git` (upstream). With the vault-only layer model in place (ADR-024) and CI upstream monitoring live (ADR-031), LP now controls the full distribution chain:

- LP-specific layers live in `what/standard/layers/` (ADR-024 — no fork commits required)
- `LatticeProtocol/spacelattice` is a clean fork of `syl20bnr/spacemacs:develop` tracking upstream
- CI `upstream-sync` workflow (ADR-031) detects and reports pin drift weekly

Cloning from upstream directly bypasses LP's controlled distribution point. Operators who clone from upstream get an unmonitored SHA and skip any future LP-level pins or release gates.

Simultaneously, the initial Spacemacs pin (ADR-002, SHA `e57594e7`, captured 2026-05-04) is stale — upstream develop has moved to `37e2a32b` (2026-05-10). This ADR delivers the first pin bump alongside the install source switch.

## Decision

1. **Install source**: `skill_install` Step 3 clone target changes from `syl20bnr/spacemacs` → `LatticeProtocol/spacelattice`. All future installs clone from the LP-controlled fork.

2. **Pin bump**: `what/standard/pins.md` updated:
   - Old SHA: `e57594e7aa1d459d3428b9b116bb84b344aa6084`
   - New SHA: `37e2a32b95d548a8e4c37996df408ec02e3f22f6`
   - Pin date: 2026-05-10

3. **Fork repo field**: `pins.md` gains a `fork_repo: LatticeProtocol/spacelattice` entry as the LP-controlled distribution source.

4. **`skill_update_pin.md`** introduced as the ADR-gated procedure for future pin bumps (see `how/standard/skills/skill_update_pin.md`).

## Consequences

### Positive
- Operators clone from LP's controlled distribution point, not upstream directly
- Pin bumps now follow a documented, ADR-gated procedure (`skill_update_pin`)
- `pins.md` explicitly distinguishes upstream repo from LP fork repo
- CI drift monitoring (ADR-031) creates a closed loop: detect drift → pin bump ADR → `skill_update_pin` → receipt

### Negative
- Adds one hop to the install path (fork must track upstream; CI detects if it drifts)
- Operators must trust LP fork is current — mitigated by CI monitoring + this ADR trail

### Neutral
- Fork carries no LP commits (vault-only model per ADR-024) — cloning fork vs upstream produces identical `~/.emacs.d/` content at the pinned SHA

## References

- ADR-002: Initial Spacemacs pin (`e57594e7`, 2026-05-04)
- ADR-024: Vault-only layer model (fork archived, no LP commits)
- ADR-031: CI + upstream monitor (drift detection workflow)
- `how/standard/skills/skill_update_pin.md`: ADR-gated pin-bump procedure
- `how/standard/runbooks/rebase_log_2026_05_10T000000Z.md`: First pin-bump receipt
