---
type: contract
status: active
created: 2026-05-03
updated: 2026-05-04
last_edited_by: agent_init
ratified_by: what/decisions/adr/adr_000_vault_identity.md
supersedes_stub: 2026-05-03
tags: [contract, layers, standard, local, overlay, governance, normative]
---

# LAYER_CONTRACT

The normative contract for the three-layer architecture introduced by ADR 000 and enforced throughout the vault. Every skill that touches `what/standard/`, `what/local/`, or `what/overlay/` references this contract.

## 1. Three layers

```
overlay/   third-party Spacemacs distros        (proposes via ADR; never silently overwrites)
   ↓
standard/  shared, deterministic, reproducible  (the published commons)
   ↓
local/     per-operator, gitignored             (private; never published unless explicitly promoted)
```

**Render order at deploy time** (`skill_deploy` step 4): `standard/` first, then accepted `overlay/` choices, then `local/` last. Final artifacts: `~/.spacemacs` and `$SPACEMACSDIR/private/`.

## 2. Clauses

### Clause 1 — Standard is the commons

Every file in `what/standard/` and `how/standard/` MUST:

| Requirement | Verification |
|-------------|--------------|
| Build on a fresh machine with no `what/local/` present | `skill_install` step 6 batch boot; CI dry-run if available |
| Contain no operator names, hostnames, machine paths, or secrets | Sanitization scan (§ 4); `skill_health_check` check C |
| Pass `skill_health_check` (all applicable classes) | Gate before commit |
| License: GPL-3.0 (matches Spacemacs upstream) | `who/upstreams/syl20bnr.md` documents this; new files inherit |

Changes to `what/standard/` MUST be made via ADR (`what/decisions/adr/`). Self-improvement (`skill_self_improve`) drafts ADRs but never commits without operator approval.

### Clause 2 — Local is private

Every file matching `what/local/*` and `how/local/*` (excepting tracked exemptions) is gitignored:

```
/what/local/*
!/what/local/*.example
!/what/local/README.md
!/what/local/.gitkeep
/how/local/*
!/how/local/*.example
!/how/local/README.md
!/how/local/.gitkeep
```

| Requirement | Verification |
|-------------|--------------|
| `git ls-files` returns NO real secrets, private elisp, or machine pins | `skill_health_check` check C; CI assertion `git ls-files \| grep -E '(/secrets\.env$\|\.private\.el$)'` empty |
| Operators may add committable templates only via the `*.example` suffix or `README.md` | `.gitignore` negation rules enforce |
| Promotion `local/` → `standard/` is a ritual, not an accident | `skill_layer_promote` is the sole sanctioned path |

### Clause 3 — Overlay is third-party

Every file in `what/overlay/<name>/` represents content sourced from an external upstream:

| Requirement | Verification |
|-------------|--------------|
| Provenance is documented: upstream URL + pinned SHA + license | `what/overlay/<name>/PROVENANCE.md` (created by `skill_overlay_consume`) |
| Each overlay layer has an ADR proposing per-layer disposition | `what/decisions/adr/adr_NNN_overlay_<name>_<layer>.md` |
| Disposition is one of: `merge into standard` / `hold in overlay` / `reject` | ADR's `disposition:` frontmatter field |
| License compatibility with GPL-3.0 verified | `skill_overlay_consume` step 4 |

**Strict invariant**: overlays NEVER silently overwrite `standard/`. If an overlay layer has the same name as a standard layer, the ADR must explicitly choose: replace, merge, or reject. Default disposition (no ADR) is reject.

### Clause 4 — Promotion ritual

`local/` → `standard/` requires:

1. **Successor ADR** authored via `skill_layer_promote`
2. **Sanitization scan** passing (§ 4 below)
3. **Dry-run health-check** in scratch worktree (exit 0)
4. **Operator approval** (gate)

The skill never auto-promotes. Operator commits with `adr-NNN: promote <thing>` message format.

### Clause 5 — License interlock

| Source | License | Compatibility |
|--------|---------|---------------|
| Spacemacs upstream | GPL-3.0 | Authoritative |
| `what/standard/layers/adna/` (this vault's elisp) | GPL-3.0 | Inherits |
| `what/standard/index/build_graph.py` (this vault's Python) | GPL-3.0 | Inherits |
| `what/standard/` markdown / specs / runbooks | GPL-3.0 | Inherits |
| Overlays (`what/overlay/<name>/`) | Per overlay | Must be GPL-3.0 compatible (GPL-3.0 / GPL-2.0+ / Apache-2.0 / MIT / BSD acceptable; AGPL or proprietary REJECT) |
| Operator local (`what/local/`) | Operator's choice | Never published — license irrelevant for vault git |

`skill_overlay_consume` step 4 verifies overlay license. Incompatible overlays are rejected before consumption.

### Clause 6 — Sanitization scan

A script that scans for patterns that should NEVER appear in `standard/`:

| Pattern | Example shape | Action |
|---------|---------------|--------|
| Hostname literals | `<machine>.<local-suffix>` where local-suffix is `local` / `internal` / `lan` / `home` | Fail |
| Operator-name literals | `/Users/<name>/` or `/home/<name>/` or `C:\Users\<name>\` | Fail (replace with `~/` or `$HOME`) |
| Email addresses (other than upstream attribution) | `<user>@<domain>.<tld>` | Warn, prompt |
| Known secret patterns | Anthropic / GitHub / AWS key formats | Fail |
| IP addresses (private ranges) | RFC 1918 ranges (10.x / 192.168.x / 172.16-31.x) | Warn |
| Internal URL fragments | `<host>.internal`, `localhost:<port>` (unless a documented example) | Warn |

Implementation: inline in `skill_layer_promote` step 2 (Python with regex). No separate tool — keeps the contract self-contained. Operators can extend the pattern list per-vault by editing this file (which is itself a `standard/` change → ADR).

## 3. Verification (skill_health_check checks C)

`skill_health_check` runs these assertions on every gate:

```bash
# C1: no real secrets in tracked files
git ls-files | grep -E '(/secrets\.env$|\.private\.el$)' && exit 30

# C2: deploy receipts not tracked
git ls-files | grep -E '^deploy/' && exit 31

# C3: graph.json (regenerated artifact) not tracked
git ls-files | grep -E '/index/graph\.json$' && exit 32  # (added Phase 4)

# C4: hostname literals (Mac/Linux/WSL2 patterns)
git ls-files what/standard/ how/standard/ \
  | xargs grep -l -E '/(Users|home)/[a-z][a-z0-9_-]+/' 2>/dev/null \
  && exit 33
```

C4 is the strictest — it would fail if any standard-layer file has a literal user-home path. Operators wanting to reference paths use `~/` or `$HOME` or environment variables.

## 4. Sanitization scan implementation

Used by `skill_layer_promote` step 2 + `skill_overlay_consume` step 5. The canonical implementation:

```python
import re, sys, pathlib

PATTERNS = [
    ("hostname literal",       r"(?<![.\w])[a-z][a-z0-9-]+\.(local|internal|lan|home)\b(?![.\w])",   "FAIL"),
    ("user home path",         r"/(Users|home)/[a-z][a-z0-9_-]+/",                                     "FAIL"),
    ("Windows user path",      r"[Cc]:\\\\[Uu]sers\\\\[A-Za-z][A-Za-z0-9_]+\\\\",                      "FAIL"),
    ("Anthropic API key",      r"\bsk-ant-[A-Za-z0-9_-]{20,}",                                         "FAIL"),
    ("GitHub PAT",             r"\bghp_[A-Za-z0-9]{30,}",                                              "FAIL"),
    ("AWS access key",         r"\bAKIA[A-Z0-9]{16}\b",                                                "FAIL"),
    ("private IPv4",           r"\b(10\.\d+\.\d+\.\d+|192\.168\.\d+\.\d+|172\.(1[6-9]|2\d|3[01])\.\d+\.\d+)\b", "WARN"),
    ("email address",          r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}",                      "WARN"),
]

def scan(paths):
    findings = []
    for p in paths:
        if not p.is_file():
            continue
        try:
            text = p.read_text(encoding="utf-8")
        except Exception:
            continue
        for name, pat, level in PATTERNS:
            for m in re.finditer(pat, text):
                # Compute line number
                line_no = text[:m.start()].count("\n") + 1
                findings.append((level, name, str(p), line_no, m.group()))
    return findings

def main(targets):
    paths = []
    for t in targets:
        p = pathlib.Path(t)
        if p.is_dir():
            paths.extend(p.rglob("*"))
        else:
            paths.append(p)
    findings = scan(paths)
    fails = [f for f in findings if f[0] == "FAIL"]
    warns = [f for f in findings if f[0] == "WARN"]
    for f in fails:
        print(f"FAIL {f[1]:<25} {f[2]}:{f[3]}: {f[4]!r}")
    for f in warns:
        print(f"WARN {f[1]:<25} {f[2]}:{f[3]}: {f[4]!r}")
    if fails:
        sys.exit(70)
    if warns:
        # Operator must acknowledge warnings
        print(f"\n{len(warns)} warning(s) — operator must acknowledge before commit.")
        sys.exit(0)
    print("sanitization clean")
    sys.exit(0)

if __name__ == "__main__":
    main(sys.argv[1:] or ["what/standard/", "how/standard/"])
```

This script is referenced (not embedded) by both `skill_layer_promote` and `skill_overlay_consume`. To run as standalone:

```bash
python3 -c "$(awk '/^```python/,/^```$/' what/standard/LAYER_CONTRACT.md | grep -v '^```')" \
       what/standard/ how/standard/
```

(Or extract to a real `.py` if needed — the inline form keeps the contract single-source-of-truth.)

## 5. Phase 6 deliverables

This file (this contract) supersedes the Phase 2 stub. Phase 6 also delivers:

- `how/standard/skills/skill_layer_promote.md` — promotion ritual
- `how/standard/skills/skill_overlay_consume.md` — overlay consumption

Both reference this contract by section number.

## 6. Self-improvement loop interaction

`skill_self_improve` (Phase 5) treats this contract as authoritative. If it detects a clause violation in `standard/` (e.g., a hostname literal slipped through), it drafts an ADR proposing the fix. The operator gates as usual.

Friction observed in the contract itself (e.g., a pattern that's too aggressive and rejects legitimate content) is also fair game for ADR proposals — the contract is alive, not frozen.

## 7. Reversibility

Each clause can be amended via successor ADR. The supersession chain preserves audit history. Removing a clause requires an ADR with `pattern_spec_change: clause_<N>_removed` and explicit consequences analysis.
