---
type: mission
mission_id: mission_sl_p3_10_layer_expansion_audit
campaign: campaign_spacelattice_v1_0
campaign_phase: 3
campaign_mission_number: 10
status: planned
mission_class: implementation
created: 2026-05-06
updated: 2026-05-06
last_edited_by: agent_stanley
tags: [mission, planned, spacelattice, v1_0, p3, layers, audit, expansion]
blocked_by: [mission_sl_p3_08_languages_keys_perf]
---

# Mission — P3-10: Layer Expansion Audit

**Phase**: P3 — Customization walkthrough.
**Class**: implementation (operator-gated per layer).

## Objective

Systematically audit every layer in the expansion list — one by one — for: inclusion/exclusion decision, configuration variables, external dependency requirements, context representation in the vault, and integration into the Spacemacs operational pattern. Each layer that passes audit gets added to the dotfile (standard or local) via `skill_layer_add` (ADR-gated). Each rejected layer gets a documented rationale.

## Background

The operator provided a comprehensive list of layers to evaluate (2026-05-06). Research validated all layers against the official Spacemacs layer list. Tier 1 additions were made immediately to the dotfile (see `dotfile.spacemacs.tmpl` this session). This mission covers the remaining Tier 2+ layers that require deliberation, external dependencies, or configuration decisions.

## Layers to audit (Tier 2 — needs deliberation)

| Layer | Spacemacs name | Category | Key decision point |
|-------|---------------|----------|--------------------|
| `slack` (emacs-slack) | `slack` | `+chat/slack` | Credentials — must NOT be in dotfile; gitignored config only |
| `typography` | `typography` | `+emacs/typography` | typo-mode; does it conflict with org? |
| `emoji` | `emoji` | `+misc/emoji` | Already have unicode-fonts; decide if emoji-cheat-sheet layer adds value |
| `csv` | `csv` | `+lang/csv` | Already added in Tier 1 dotfile — validate config |
| `csharp` | `csharp` | `+lang/csharp` | Needs `dotnet` CLI + `csharp-ls` or `omnisharp` LSP |
| `swift` | `swift` | `+lang/swift` | Needs Xcode CLI tools; limited Emacs tooling maturity |
| `solidity` | `solidity` | `+lang/solidity` | Blockchain dev; include if operator uses it |
| `conda` | `conda` | `+lang/conda` | Python env mgmt; may overlap with pyenv/direnv already in use |
| `ipython-notebook` | `ipython-notebook` | `+lang/ipython-notebook` | EIN layer; needs running Jupyter kernel |
| `theming` | `theming` | `+themes/theming` | Per-theme face overrides — add if customizing face colors |
| `themes-megapack` | `themes-megapack` | `+themes/themes-megapack` | ~100 themes incl. doom-*; adds load time |
| `kubernetes` | `kubernetes` | `+tools/kubernetes` | kubectl UI; need `kubectl` CLI |
| `terraform` | `terraform` | `+tools/terraform` | .tf file support; low risk |
| `nginx` | `nginx` | `+tools/nginx` | nginx.conf syntax; low risk |
| `systemd` | `systemd` | `+tools/systemd` | systemd unit file syntax; macOS only via Lima/colima |
| `prettier` | `prettier` | `+tools/prettier` | Replaces web-beautify; ADR needed (web-beautify already excluded) |
| `pass` | `pass` | `+tools/pass` | Unix password-store CLI; add if using pass for secrets |
| `imenu-list` | `imenu-list` | `+emacs/imenu-list` | Already added Tier 1 — validate |
| `rebox` | `rebox` | `+emacs/rebox` | Box comment reformatting; low risk |
| `web-beautify` | `web-beautify` | `+tools/web-beautify` | **SUPERSEDED by prettier** — exclude with rationale |
| `cmake` | `cmake` | `+lang/cmake` | CMakeLists.txt syntax; add if doing C/C++ |
| `c-c++` | `c-c++` | `+lang/c-c++` | Needs clangd LSP; include for systems programming |
| `evil-snipe` | `evil-snipe` | `+vim/evil-snipe` | 2-char motion on `s`; conflicts with avy-goto-char-timer on `s` — ADR needed |

## Additional packages to audit (not official layers)

| Package | Purpose | Install | Key decision |
|---------|---------|---------|-------------|
| `whisper` (`natrys/whisper.el`) | Voice transcription | MELPA | Needs whisper.cpp or OpenAI API key |
| `aider` (via `aider` layer) | AI pair programming (Aider CLI) | official layer | Complements claude-code; ADR if both |
| `github-copilot` (official layer) | Inline completion + chat | official layer | Conflicts with copilot.el; ADR needed |
| `xwwp` | Vimium hints for xwidget-webkit | MELPA | Only if `--with-xwidgets` compiled |
| `popper` | Popup buffer management | MELPA | Reduces popup clutter |
| `dirvish` | Better dired | MELPA | via ranger layer `:variables ranger-override-dired 'dirvish` |

## Per-layer audit protocol (for each layer)

For each layer listed above, execute in order:

1. **Research phase** (5 min): Read Spacemacs layer README + check external deps
2. **Install decision**: Include in standard / include in local / exclude with rationale
3. **Config**: Record key variables and their recommended values
4. **External deps**: Document brew installs needed in `fresh_machine.md` runbook
5. **skill_layer_add**: If including in standard → run `skill_layer_add` (ADR + health-check)
6. **Context update**: Add a one-liner to `what/standard/layers.md`
7. **Context doc**: If the layer is complex or agentic-relevant, create a context file in `what/context/spacemacs/`

## Deliverables

For each audited layer:
- Include/exclude decision with rationale recorded in this mission file
- ADR filed if included in standard (via `skill_layer_add`)
- `what/standard/layers.md` entry updated
- External deps added to `how/standard/runbooks/fresh_machine.md` if needed
- Context doc created for complex/agentic-relevant layers

Campaign-level deliverable:
- `dotfile.spacemacs.tmpl` updated with all accepted layers
- `fresh_machine.md` updated with all new external deps

## Estimated effort

4-6 sessions (2-3 layers per session, operator gates each).

## Dependencies

P3-08 complete (language stack + keybinding philosophy established before adding more layers).

## Reference

- Tier 1 layers (already added): `osx`, `unicode-fonts`, `nav-flash`, `ibuffer`, `tabs`, `imenu-list`, `go`, `javascript`, `react`, `epub`, `pdf`, `restclient`, `docker`, `dap`, `tree-sitter`, `claude-code`, `llm-client`
- Research: `what/context/spacemacs/spacemacs_customization_reference.md` §3.4
- Layer add protocol: `how/standard/skills/skill_layer_add.md`
- Layer contract: `what/standard/LAYER_CONTRACT.md`
