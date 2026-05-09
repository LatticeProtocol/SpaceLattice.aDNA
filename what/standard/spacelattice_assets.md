---
type: standard
title: "Spacelattice — LP Asset Specification"
status: active
created: 2026-05-08
updated: 2026-05-08
last_edited_by: agent_stanley
tags: [standard, assets, banner, branding, p4]
---

# Spacelattice Asset Specification

Vault-side catalogue of LatticeProtocol Spacemacs distribution visual assets. Governs asset sources, deployment paths, derivation procedures, and license posture.

See ADR-028 for the rationale behind asset choices.

---

## Asset Inventory

| Asset | Path (vault) | Format | Status |
|-------|-------------|--------|--------|
| LP logo SVG | `what/standard/layers/spacemacs-latticeprotocol/banners/latticeprotocol.svg` | SVG source | ✅ live |
| LP logo PNG | derived from SVG | PNG 256×256 | derived at install |
| LP logo ICNS | derived from PNG | ICNS macOS | derived at install (macOS only) |
| ASCII banner 1 | `what/standard/layers/spacemacs-latticeprotocol/banners/lp-banner-1.txt` | plain text | ✅ live |
| ASCII banner 2 | `what/standard/layers/spacemacs-latticeprotocol/banners/lp-banner-2.txt` | plain text | ✅ live |
| ASCII banner 3 | `what/standard/layers/spacemacs-latticeprotocol/banners/lp-banner-3.txt` | plain text | ✅ live |
| ASCII banner 4 | `what/standard/layers/spacemacs-latticeprotocol/banners/lp-banner-4.txt` | plain text | ✅ live |

---

## Deployment Paths

`skill_install` Step 5 symlinks the vault's `what/standard/layers/spacemacs-latticeprotocol/` directory into `~/.emacs.d/private/layers/spacemacs-latticeprotocol/`. The `banners/` subdirectory is included.

| Asset | Deployed path |
|-------|--------------|
| SVG source | `~/.emacs.d/private/layers/spacemacs-latticeprotocol/banners/latticeprotocol.svg` |
| PNG (derived) | `~/.emacs.d/private/layers/spacemacs-latticeprotocol/banners/latticeprotocol.png` |
| ICNS (derived, macOS) | `~/.emacs.d/private/layers/spacemacs-latticeprotocol/banners/latticeprotocol.icns` |
| ASCII banners 1-4 | `~/.emacs.d/private/layers/spacemacs-latticeprotocol/banners/lp-banner-{1..4}.txt` |

---

## Derivation Procedures

PNG and ICNS are build-time outputs derived from the SVG source. Run these after `skill_install` deploys the layer.

### PNG from SVG

```bash
# Requires: rsvg-convert (brew install librsvg)
BANNERS_DIR=~/.emacs.d/private/layers/spacemacs-latticeprotocol/banners
rsvg-convert -w 256 -h 256 \
  "$BANNERS_DIR/latticeprotocol.svg" \
  -o "$BANNERS_DIR/latticeprotocol.png"
```

### ICNS from PNG (macOS only)

```bash
# Requires: macOS sips + iconutil
BANNERS_DIR=~/.emacs.d/private/layers/spacemacs-latticeprotocol/banners
ICONSET="$BANNERS_DIR/lp.iconset"
mkdir -p "$ICONSET"
for size in 16 32 64 128 256; do
  sips -z $size $size \
    "$BANNERS_DIR/latticeprotocol.png" \
    --out "$ICONSET/icon_${size}x${size}.png"
done
iconutil -c icns "$ICONSET" -o "$BANNERS_DIR/latticeprotocol.icns"
rm -rf "$ICONSET"
```

---

## Spacemacs Banner Override

The distribution layer's `config.el` sets `dotspacemacs-startup-banner` to the deployed ASCII banner path (safe default, works in terminals without image support):

```elisp
(setq dotspacemacs-startup-banner
      (expand-file-name
       "private/layers/spacemacs-latticeprotocol/banners/lp-banner-1.txt"
       spacemacs-start-directory))
```

To use the PNG image banner (requires derivation step above):

```elisp
;; In what/local/operator.private.el — after running derivation step
(setq dotspacemacs-startup-banner
      (expand-file-name
       "private/layers/spacemacs-latticeprotocol/banners/latticeprotocol.png"
       spacemacs-start-directory))
```

---

## License Posture

All LP banner assets are original works created for this distribution.

| Asset | License | Notes |
|-------|---------|-------|
| `latticeprotocol.svg` | GPL-3.0 | Original work; matches Spacemacs upstream license |
| `lp-banner-*.txt` | GPL-3.0 | Original work |
| Derived PNG + ICNS | GPL-3.0 | Derived from GPL-3.0 SVG source |

No Spacemacs logo assets (CC BY-SA 4.0) are used or adapted. The LP logo is a wholly original design using a lattice grid motif.

---

## ASCII Banner Design Notes

Four variants are provided for `'random` startup rotation or direct operator selection:

| File | Style | Description |
|------|-------|-------------|
| `lp-banner-1.txt` | Lattice grid | Dot-and-dash grid frame with spaced LP name |
| `lp-banner-2.txt` | Minimal mark | Small `[LP]` box mark with wordmark and tagline |
| `lp-banner-3.txt` | Full box | Single-rule box containing full name + subtitle |
| `lp-banner-4.txt` | Wings motif | Daedalus wings / LP triangle motif (thematic) |

All variants are ≤75 columns wide (Spacemacs banner display requirement).
