---
type: pins
status: pending_first_install
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
tags: [pins, standard, spacemacs, version]
---

# Pins — Spacemacs, Emacs, OS

This file is the **single source of truth for what we build on**. Every install or deploy compares the host state against these pins; mismatch aborts with a diff.

## Spacemacs

| Field | Value | Notes |
|-------|-------|-------|
| Repo | `https://github.com/syl20bnr/spacemacs` | Upstream — see `who/upstreams/syl20bnr.md` |
| Branch | `develop` | Build target per ADR 000 + the brief |
| Pinned SHA | **PIN PENDING** | First `skill_install` will set this; operator validates current develop tip |
| Pin date | — | Set when pin lands |

When pin is `PIN PENDING`, `skill_install` on first run does the following:

1. Clone `develop` to `~/.emacs.d/`.
2. Capture `git rev-parse HEAD` from the cloned repo.
3. Write the SHA back to this file (operator confirms).
4. From then on, `skill_install` aborts with a diff if upstream `develop` has moved past the pin.

## Emacs

| Field | Value | Notes |
|-------|-------|-------|
| Minimum version | `29.0` | Spacemacs `develop` requires modern Emacs |
| Recommended | `29.4` or newer | Native compilation + tree-sitter |
| GUI | Required for full `SPC a` transient experience | TUI works but transient menus degrade |

`skill_install` step 1 verifies `emacs --version | head -1` parses to ≥29.0.

## Operating Systems

| OS | Status | Notes |
|----|--------|-------|
| macOS (Darwin) | **Primary** | Apple Silicon and Intel; tested on Darwin 25.x |
| Linux | Supported | Ubuntu 22.04+, Fedora 38+, Arch (rolling) |
| WSL2 | Supported with caveats | Document GUI display setup; Emacs in WSL2 needs WSLg or X server |
| Windows native | **Out of scope** | Use WSL2 instead |

## Required system tooling

`skill_install` aborts if any of these are missing:

| Tool | Why | Install hint |
|------|-----|--------------|
| `git` | Clone Spacemacs + vault git | OS package manager |
| `python3` | Run `build_graph.py` for context graph | OS package manager |
| `node` | Some LSP servers + treesitter helpers | nvm or OS package manager |
| `ripgrep` (`rg`) | Spacemacs file-search performance | `brew install ripgrep` / apt install ripgrep |
| `fd` | File-finding performance | `brew install fd` / apt install fd-find |

## Update protocol

When upstream Spacemacs has notable changes that the vault wants to absorb, run `how/standard/runbooks/update_spacemacs.md`:

1. Check `git log` on Spacemacs `develop` since the pinned SHA
2. Read changelog for breaking changes
3. Propose pin update via successor ADR (referencing this file)
4. Run `skill_health_check` against the new SHA in a scratch worktree
5. On approval: update the SHA + pin date in this file; commit with `adr-NNN: bump spacemacs pin`

## Reproducibility note

This file's pin discipline is what allows another operator to clone `spacemacs.aDNA` from the LatticeProtocol mirror (Phase 7), run `skill_install`, and arrive at the same battle station as the original. Pin drift breaks reproducibility.
