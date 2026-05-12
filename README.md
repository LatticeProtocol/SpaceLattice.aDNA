# Spacemacs.aDNA

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

```bash
git clone https://github.com/LatticeProtocol/Spacemacs.aDNA.git ~/lattice/Spacemacs.aDNA
cd ~/lattice/Spacemacs.aDNA
# Read how/standard/skills/skill_install.md and follow the steps.
# Checks deps, backs up ~/.emacs.d/ + ~/.spacemacs, clones Spacemacs at pinned SHA,
# renders templates, first-boots Emacs in batch, runs skill_health_check,
# writes deploy receipt to deploy/<hostname>/<utc>.md.
```

## Layout

```
Spacemacs.aDNA/
├── MANIFEST.md, CLAUDE.md, STATE.md, AGENTS.md, README.md
├── who/
│   ├── operators/     who runs this battle station
│   ├── upstreams/     Spacemacs maintainers + layer authors
│   └── peers/         other Spacemacs.aDNA forks
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
| See available skills | [`how/standard/skills/README.md`](how/standard/skills/README.md) |
| Explore the Spacemacs `adna` layer spec | [`what/standard/adna-bridge.md`](what/standard/adna-bridge.md) |

## License

GPL-3.0 — matches upstream Spacemacs to maintain compatibility. Vault content (markdown, ADRs, specs) is also GPL-3.0 unless individual files specify otherwise.

## Status

**v1.0.0** — 2026-05-11. Forked from the [Agentic-DNA](https://github.com/LatticeProtocol/Agentic-DNA) base template. 41 missions, 34 ADRs, all skills live. See [CHANGELOG.md](CHANGELOG.md) for full release history.
