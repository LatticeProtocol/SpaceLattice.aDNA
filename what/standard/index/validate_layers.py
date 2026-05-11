#!/usr/bin/env python3
# validate_layers.py — structural validation for what/standard/layers/
#
# License: GPL-3.0
# Part of Spacemacs.aDNA (https://github.com/LatticeProtocol/Spacemacs.aDNA)
#
# Usage:  python3 what/standard/index/validate_layers.py
# Exit:   0 = all checks pass   1 = one or more failures
#
# Run from the vault root. CI job calls this with no arguments.

import re
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except Exception as e:
        return ""


def find_layers_dir(vault_root: Path) -> Path:
    return vault_root / "what" / "standard" / "layers"


def iter_layers(layers_dir: Path):
    """Yield layer directories, skipping Spacemacs category dirs (+ prefix)."""
    for entry in sorted(layers_dir.iterdir()):
        if not entry.is_dir():
            continue
        # Spacemacs uses +category/ dirs as groupings, not layers themselves
        if entry.name.startswith("+"):
            continue
        yield entry


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def check_packages_el(layers_dir: Path) -> list[str]:
    """Each layer directory must contain packages.el."""
    failures = []
    for layer in iter_layers(layers_dir):
        if not (layer / "packages.el").exists():
            failures.append(f"  FAIL [check 1] {layer.name}/: missing packages.el")
    return failures


def check_layers_el(layers_dir: Path) -> list[str]:
    """Each layer directory must contain layers.el."""
    failures = []
    for layer in iter_layers(layers_dir):
        if not (layer / "layers.el").exists():
            failures.append(f"  FAIL [check 2] {layer.name}/: missing layers.el")
    return failures


def check_layer_dependencies(layers_dir: Path) -> list[str]:
    """Each layers.el must call configuration-layer/declare-layer-dependencies."""
    failures = []
    for layer in iter_layers(layers_dir):
        layers_el = layer / "layers.el"
        if not layers_el.exists():
            continue  # already caught by check 2
        text = read(layers_el)
        if "configuration-layer/declare-layer-dependencies" not in text:
            failures.append(
                f"  FAIL [check 3] {layer.name}/layers.el: "
                f"missing configuration-layer/declare-layer-dependencies call"
            )
    return failures


def check_adna_extensions_menu(layers_dir: Path) -> list[str]:
    """adna/keybindings.el must define adna/extensions-menu (SPC a x stub)."""
    failures = []
    kb = layers_dir / "adna" / "keybindings.el"
    if not kb.exists():
        failures.append("  FAIL [check 4] adna/keybindings.el: file missing")
        return failures
    text = read(kb)
    if "adna/extensions-menu" not in text:
        failures.append(
            "  FAIL [check 4] adna/keybindings.el: "
            "'adna/extensions-menu' not defined (SPC a x stub missing)"
        )
    return failures


def check_claude_code_ide_bindings(layers_dir: Path) -> list[str]:
    """claude-code-ide/keybindings.el must wire SPC c bindings."""
    failures = []
    kb = layers_dir / "claude-code-ide" / "keybindings.el"
    if not kb.exists():
        failures.append("  FAIL [check 5] claude-code-ide/keybindings.el: file missing")
        return failures
    text = read(kb)
    # SPC c bindings use spacemacs/set-leader-keys with "c" prefix
    if '"c' not in text and '"cc' not in text:
        failures.append(
            "  FAIL [check 5] claude-code-ide/keybindings.el: "
            "no SPC c bindings found (spacemacs/set-leader-keys \"c...\" expected)"
        )
    return failures


def check_agentic_layout(layers_dir: Path) -> list[str]:
    """adna/layouts.el must define adna/layout-agentic-default."""
    failures = []
    layouts = layers_dir / "adna" / "layouts.el"
    if not layouts.exists():
        failures.append("  FAIL [check 6] adna/layouts.el: file missing")
        return failures
    text = read(layouts)
    if "adna/layout-agentic-default" not in text:
        failures.append(
            "  FAIL [check 6] adna/layouts.el: "
            "'adna/layout-agentic-default' not defined"
        )
    return failures


def check_no_operator_paths(vault_root: Path) -> list[str]:
    """No file in what/standard/ may contain operator home paths."""
    failures = []
    standard = vault_root / "what" / "standard"
    # Match /Users/<name>/ or /home/<name>/ where name is a plausible username
    pattern = re.compile(r"/(Users|home)/[a-z][a-z0-9_-]+/")
    for f in sorted(standard.rglob("*")):
        if not f.is_file():
            continue
        text = read(f)
        if not text:
            continue
        for m in pattern.finditer(text):
            line_no = text[: m.start()].count("\n") + 1
            rel = f.relative_to(vault_root)
            failures.append(
                f"  FAIL [check 7] {rel}:{line_no}: "
                f"operator home path {m.group()!r} — use ~/ or $HOME"
            )
    return failures


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------

def main() -> int:
    vault_root = Path.cwd()
    layers_dir = find_layers_dir(vault_root)

    if not layers_dir.exists():
        print(f"ERROR: layers directory not found at {layers_dir}")
        print("Run from vault root (the directory containing what/standard/layers/).")
        return 1

    all_failures: list[str] = []

    checks = [
        ("Layer has packages.el",                 check_packages_el(layers_dir)),
        ("Layer has layers.el",                   check_layers_el(layers_dir)),
        ("layers.el declares layer dependencies",  check_layer_dependencies(layers_dir)),
        ("adna/extensions-menu defined",          check_adna_extensions_menu(layers_dir)),
        ("claude-code-ide SPC c bindings",        check_claude_code_ide_bindings(layers_dir)),
        ("adna/layout-agentic-default defined",   check_agentic_layout(layers_dir)),
        ("No operator home paths in standard/",   check_no_operator_paths(vault_root)),
    ]

    passed = 0
    for name, failures in checks:
        if failures:
            print(f"FAIL  {name}")
            for f in failures:
                print(f)
            all_failures.extend(failures)
        else:
            print(f"OK    {name}")
            passed += 1

    total = len(checks)
    print(f"\n{passed}/{total} checks passed", end="")
    if all_failures:
        print(f" — {len(all_failures)} failure(s)")
        return 1
    else:
        print()
        return 0


if __name__ == "__main__":
    sys.exit(main())
