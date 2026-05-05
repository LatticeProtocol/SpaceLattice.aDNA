---
type: runbook
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
audience: human
intent: "Take a new machine from zero to working SpaceLattice.aDNA battle station."
time_estimate: "10–25 minutes (mostly Spacemacs first-boot package install)"
phase_introduced: 3
tags: [runbook, install, fresh, human, daedalus]
---

# Runbook — fresh machine

## When to follow

- Brand new laptop / VM / Linux box
- Existing machine where you want SpaceLattice.aDNA but Spacemacs is not yet installed
- Recovery after `recover_from_breakage.md` decided to start over

## Pre-conditions

| Thing | How to check |
|-------|--------------|
| OS is supported (macOS / Linux / WSL2) | See `what/standard/pins.md` § Operating Systems |
| You have shell access (zsh or bash) | `echo $SHELL` |
| You have admin rights or sudo | Required to install system tools if missing |
| You can clone from GitHub | `git clone https://github.com/syl20bnr/spacemacs.git /tmp/_test && rm -rf /tmp/_test` |

## Steps

### 1. Install system dependencies

**macOS** (Homebrew assumed):

```bash
brew install emacs-plus@29 ripgrep fd python@3.12 node git
brew link --force emacs-plus@29
```

**Linux (Debian/Ubuntu)**:

```bash
sudo apt update
sudo apt install -y emacs ripgrep fd-find python3 nodejs git
# fd-find installs as `fdfind`; alias to `fd`:
sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
```

**Linux (Arch)**:

```bash
sudo pacman -S emacs ripgrep fd python nodejs git
```

**WSL2 (Ubuntu)**: Same as Debian/Ubuntu, plus install Windows X server (VcXsrv) or use WSLg if Win11.

Verify:

```bash
emacs --version | head -1   # ≥ 29.0
git --version
python3 --version
node --version              # ≥ 20.0
rg --version | head -1
fd --version
```

### 2. Clone the SpaceLattice.aDNA vault

```bash
mkdir -p ~/lattice
cd ~/lattice
git clone https://github.com/LatticeProtocol/SpaceLattice.aDNA.git
cd SpaceLattice.aDNA
```

> Note: the GitHub repo is published in **Phase 7** of the genesis plan. Until then, copy the vault directory directly from the originating machine.

### 3. Run skill_install

The skill is at `how/standard/skills/skill_install.md`. Inline-execute its steps:

```bash
# Either run inside Claude Code (it will read the skill and execute):
claude
# > Please run skill_install for SpaceLattice.aDNA on this machine.

# Or follow the steps in skill_install.md by hand.
```

The skill backs up any existing `~/.emacs.d/` and `~/.spacemacs`, clones Spacemacs at the pinned SHA, renders templates, symlinks the `adna` layer, batch-boots Emacs (slow first time — 2-10 min), and runs `skill_health_check`.

### 4. First Emacs launch (GUI)

```bash
emacs &
```

You should see Spacemacs's startup buffer. Hit `SPC f f` to open file picker. Try opening `~/lattice/SpaceLattice.aDNA/CLAUDE.md`. The `adna-mode` minor mode should activate (visible in mode-line as `aDNA`). Hit `SPC a` — the transient menu should appear.

If `SPC a` doesn't bind: layer didn't load. Check the install log at `how/local/machine_runbooks/last_install.log`.

### 5. Wire Claude Code

```bash
# Claude Code config (if not already set up):
mkdir -p ~/.claude
# (Claude Code's own setup procedures — see https://www.anthropic.com/claude-code)

# In Spacemacs: SPC c c
# Spawns vterm in the current aDNA root and runs `claude`
```

### 6. Wire Obsidian (optional)

```bash
# Open ~/lattice/SpaceLattice.aDNA/ in Obsidian as a vault
# Install the Advanced URI community plugin
# In what/local/operator.private.el (after creating from .example):
#   (setq adna-obsidian-roundtrip-enabled t)
# Re-deploy: bash how/standard/skills/skill_deploy.md
```

### 7. Bootstrap your local layer

```bash
cd ~/lattice/SpaceLattice.aDNA/what/local
for f in *.example; do
  target="${f%.example}"
  [[ -f "$target" ]] || cp "$f" "$target"
done
# Edit operator.private.el with personal preferences, secrets.env with API keys, etc.
```

After editing local files, rerun `skill_deploy` to apply.

## Post-conditions

| Check | Expected |
|-------|----------|
| `emacs` opens with Spacemacs startup | ✅ |
| `SPC a` shows transient menu | ✅ |
| `SPC c c` spawns Claude Code vterm | ✅ |
| `M-x adna-index-project` writes `what/standard/index/graph.json` | ✅ (Phase 4+) |
| `deploy/<hostname>/<utc>.md` receipt exists | ✅ |
| `~/.spacemacs.bak.<utc>` exists if there was a prior Spacemacs install | ✅ |

## Rollback

If something went wrong:

```bash
# Restore prior Spacemacs (if backup exists):
[[ -d ~/.emacs.d.bak.* ]] && {
  rm -rf ~/.emacs.d
  mv ~/.emacs.d.bak.* ~/.emacs.d
  mv ~/.spacemacs.bak.* ~/.spacemacs
}

# Or: nuke and start over:
rm -rf ~/.emacs.d ~/.spacemacs
# (your data is in ~/lattice/SpaceLattice.aDNA/, untouched by ~/.emacs.d/ ops)
```

## Time breakdown (typical)

| Phase | macOS (Apple Silicon) | Linux | WSL2 |
|-------|------------------------|-------|------|
| System deps install | 3-5 min | 1-2 min | 1-2 min |
| Clone Spacemacs | 30 sec | 20 sec | 30 sec |
| First batch boot (package install) | 5-12 min | 4-10 min | 6-15 min |
| Health check + receipt | 30 sec | 30 sec | 1 min |

## OS-specific notes

- **macOS Sequoia (Darwin 25.x)**: `emacs-plus@29` is the recommended formula. `brew install emacs` (without `-plus`) sometimes ships an older version.
- **Linux**: System Emacs may be older than 29. Build from source or use `flatpak` if needed.
- **WSL2**: GUI Emacs requires display setup. Document specifics in `how/local/machine_runbooks/wsl2_<your_distro>.md` (your machine's local layer).

## When this runbook fails

If `skill_install` aborts:

1. Read `how/local/machine_runbooks/last_install.log` — the abort reason is there
2. Most failures are missing system deps — install them, re-run
3. Pin mismatch: see `update_spacemacs.md` runbook
4. Persistent boot failure: see `recover_from_breakage.md`
