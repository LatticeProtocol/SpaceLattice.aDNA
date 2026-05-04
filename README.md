# spacemacs.aDNA

> Agentic battle station — a Spacemacs-based IDE governed by the aDNA knowledge architecture, optimized for serious ML ops, agentic coding, and aDNA context-graph navigation.
>
> Persona: **Daedalus** — master craftsman of the Labyrinth, maker of adaptive wings.

## 60-second orientation

This vault IS an aDNA project. Spacemacs is the *subject* it governs, not a wrapper around it. Three filesystem-level layers are enforced:

```
overlay/   third-party Spacemacs distros        (consumed via skill, ADR-gated)
   ↓
standard/  shared, deterministic, reproducible  (the published commons)
   ↓
local/     per-operator, gitignored             (your machine; never published)
```

After install, you get:

- Spacemacs with the **`adna` layer** — auto-activates inside any `*.aDNA/` directory, surfaces a `SPC a` transient menu (open MANIFEST, jump to triad root, run nearest skill, render lattice graph), parses YAML frontmatter into buffer-local variables.
- **`SPC c c`** — spawns a Claude Code session pinned to the nearest aDNA root.
- **`M-x adna-index-project`** — emits a JSON context graph of the current vault.
- **Round-trip with Obsidian** — Spacemacs ↔ Obsidian via the Advanced URI plugin.
- **Self-improvement loop** — the agent observes session friction, drafts an ADR + diff + dry-run, and presents it through an operator approval gate. Never auto-commits to standard.

## Install

> ⚠️ **Genesis state (2026-05-03).** The `skill_install` procedure is being authored in **Phase 3** of the genesis plan. This README documents the planned UX. The vault repo on GitHub is published in **Phase 7**.

When Phase 3 + 7 land, install will be:

```bash
git clone https://github.com/LatticeProtocol/spacemacs.aDNA.git ~/lattice/spacemacs.aDNA
cd ~/lattice/spacemacs.aDNA
# Run skill_install (Phase 3) — checks deps, backs up ~/.emacs.d/ + ~/.spacemacs,
# clones Spacemacs at pinned SHA, renders templates, first-boots Emacs in batch,
# runs skill_health_check, writes deploy receipt to deploy/<hostname>/<utc>.md.
```

Until then, the vault is being scaffolded interactively — see the plan at `~/.claude/plans/please-read-the-claude-md-splendid-boole.md` (on the originating operator's machine) for current state.

## Layout

```
spacemacs.aDNA/
├── MANIFEST.md, CLAUDE.md, STATE.md, AGENTS.md, README.md
├── who/
│   ├── operators/     who runs this battle station
│   ├── upstreams/     Spacemacs maintainers + layer authors
│   └── peers/         other spacemacs.aDNA forks
├── what/
│   ├── standard/      shared commons (pins, layers, dotfile, adna layer source, specs)
│   ├── local/         your machine (gitignored except .example templates + README)
│   ├── overlay/       third-party Spacemacs distros consumed via skill
│   └── decisions/adr/ every standard/ change documented here
├── how/
│   ├── standard/skills/    install, deploy, self-improve, health-check, etc.
│   ├── standard/runbooks/  fresh-machine, update-spacemacs, recover-from-breakage
│   └── local/             your machine's runbooks + install logs (gitignored)
└── (inherited from .adna template: contexts, lattices, sessions, missions, campaigns, templates)
```

## Where to go next

| If you want to... | Read |
|---|---|
| Understand the architecture | [`MANIFEST.md`](MANIFEST.md) |
| Operate this vault as agent | [`CLAUDE.md`](CLAUDE.md) |
| See current operational state | [`STATE.md`](STATE.md) |
| Understand the layered contract | [`what/standard/LAYER_CONTRACT.md`](what/standard/LAYER_CONTRACT.md) |
| Read the foundational decision | [`what/decisions/adr/adr_000_vault_identity.md`](what/decisions/adr/adr_000_vault_identity.md) |
| See the planned skills | [`how/standard/skills/README.md`](how/standard/skills/README.md) |
| Explore the Spacemacs `adna` layer spec | [`what/standard/adna-bridge.md`](what/standard/adna-bridge.md) |

## License

GPL-3.0 — matches upstream Spacemacs to maintain compatibility. Vault content (markdown, ADRs, specs) is also GPL-3.0 unless individual files specify otherwise.

## Status

**Genesis v0.1.0** — 2026-05-03. Forked from the [Agentic-DNA](https://github.com/LatticeProtocol/Agentic-DNA) base template. Phases 1-2 complete; phases 3-7 + DoD pending.
