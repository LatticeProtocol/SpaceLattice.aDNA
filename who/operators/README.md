---
type: folder_note
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [operators, who, spacemacs]
---

# who/operators/

Per-operator profiles for this SpaceLattice.aDNA fork. Each operator who deploys this battle station to their machine writes a profile here capturing:

- Hostname(s) where they deploy
- Primary/preferred models (Claude variants, local llama, Ollama)
- Layer preferences (ML emphasis, language priorities, OS)
- Customizations carried in `what/local/` and `how/local/`

Operator profiles are committed to the vault git so peers can see who's running this battle station and how. **Real secrets never go here** — those live in `what/local/secrets.env` (gitignored). Profiles can opt out of git via `private: true` in frontmatter (then they're moved to `what/local/operators/` by skill_layer_promote's inverse).

This is part of `who/`, alongside `upstreams/` (Spacemacs maintainers + layer authors) and `peers/` (other SpaceLattice.aDNA forks).
