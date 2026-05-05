---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [standard, what, commons, spacemacs]
---

# what/standard/

The **standard layer** — the published commons. Every file here:

1. Builds on a fresh machine with no `what/local/` present.
2. Contains no secrets, no hostnames, no operator names, no machine-specific paths.
3. Passes `skill_health_check` in CI (or local dry-run if no CI).

Every change here requires an ADR (`what/decisions/adr/`). Self-improvement (`how/standard/skills/skill_self_improve`) drafts ADRs but never commits to standard without operator approval.

## Contents

| File / dir | Purpose |
|------------|---------|
| `pins.md` | Spacemacs SHA, Emacs minimum version, OS matrix |
| `layers.md` | Canonical Spacemacs layer set |
| `dotfile.spacemacs.tmpl` | Template rendered to `~/.spacemacs` |
| `packages.el.tmpl` | Template for `~/.emacs.d/private/packages.el` |
| `adna-bridge.md` | Spec for the `adna` Spacemacs layer (impl in Phase 4) |
| `model-routing.md` | Claude / local-llama / API model precedence policy |
| `obsidian-coupling.md` | Round-trip wikilink + Advanced URI integration |
| `LAYER_CONTRACT.md` | Formal contract for standard / local / overlay |
| `index/` | Context graph emitted by `M-x adna-index-project` |
| `layers/adna/` | The `adna` Spacemacs layer (elisp source) |

See also: `what/local/` (private), `what/overlay/` (third-party).
