---
type: upstream
name: "Sylvain Benner (syl20bnr)"
role: spacemacs_maintainer
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
repo: https://github.com/syl20bnr/spacemacs
license: GPL-3.0
default_branch: develop
tags: [upstream, spacemacs, maintainer, syl20bnr]
---

# Sylvain Benner (syl20bnr)

## Role

Original creator and lead maintainer of [Spacemacs](https://github.com/syl20bnr/spacemacs). The `develop` branch is the canonical build target for `spacemacs.aDNA`; the SHA we pin lives in `what/standard/pins.md`.

## What we depend on

- Spacemacs core (`spacemacs/`, `core/`)
- Layer mechanism (`layers/`)
- Configuration system (`~/.spacemacs` rendered from `what/standard/dotfile.spacemacs.tmpl`)

## Engagement model

- **Pin-and-track.** We pin a SHA, run on it, periodically run the `update_spacemacs` runbook to fast-forward the pin.
- **Issues upstream.** Bugs in Spacemacs core go to `syl20bnr/spacemacs` issues. The vault does not carry patches that should be upstream.
- **Layers stay separate.** Custom layers in `what/standard/layers/` (notably `adna/`) live in our vault. They follow Spacemacs layer conventions so they could be upstreamed if useful.

## Licensing interlock

Spacemacs is GPL-3.0. The `adna` layer's elisp follows GPL-3.0 to remain compatible. See `what/standard/LAYER_CONTRACT.md` for the full interlock.
