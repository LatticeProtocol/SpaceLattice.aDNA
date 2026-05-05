---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [peers, who, spacemacs, lattice]
---

# who/peers/

Other SpaceLattice.aDNA forks — peer operators who installed the battle station from `github.com/LatticeProtocol/SpaceLattice.aDNA` (Phase 7 publish target) and run it on their own machines.

Each peer entry captures:
- Who they are
- Hostname class (workstation / laptop / server)
- Which standard layers they extended or replaced
- ADRs they've contributed back to standard via `skill_layer_promote`
- Status of cross-fork lattice federation

Peer entries are voluntary — published via `skill_publish_lattice` when peers explicitly federate.

## Cross-fork federation (planned)

Peers can opt into `who/peers/federation.json` (deferred to Phase 7+) so `M-x adna-show-peer-graph` can render the network of standard-layer adoption. Pull-only model: no peer's machine sends data without explicit publish action.

## Initial state

No peers yet — this vault is **genesis** (2026-05-03).

## Lattice publishing

When `skill_publish_lattice` runs (Phase 7), it writes a publish receipt to `who/peers/published/<utc>.md` documenting tarball SHA, GitHub release tag, and the standard-layer manifest.
