---
type: skill
skill_type: agent
status: active
created: 2026-05-03
updated: 2026-05-11
last_edited_by: agent_stanley
category: verification
trigger: "Run before any commit to what/standard/. Run after every install or deploy. Run as gate inside skill_self_improve's dry-run."
phase_introduced: 3
tags: [skill, health_check, verification, gate, daedalus]
requirements:
  tools: [emacs (>=29.0), python3, git]
  context:
    - what/standard/layers/adna/
    - what/standard/index/
  permissions:
    - "read what/standard/"
    - "execute emacs --batch"
    - "read git ls-files"
---

# skill_health_check — green/red gate for Spacemacs.aDNA

## Purpose

Single source of truth for "is the vault + Spacemacs install healthy?" Used as a gate by:

- `skill_install` step 7 — after first batch boot
- `skill_deploy` step 7 — after re-render
- `skill_layer_add` — dry-run validation in scratch worktree
- `skill_layer_promote` — dry-run before promotion commit
- `skill_self_improve` — dry-run before presenting ADR to operator

Output: exit 0 (green) or exit non-zero (red, with reason).

## Checks

### A. Vault structure

```bash
test -f MANIFEST.md          || { echo "RED: MANIFEST.md missing"; exit 11; }
test -f CLAUDE.md            || { echo "RED: CLAUDE.md missing"; exit 12; }
test -f STATE.md             || { echo "RED: STATE.md missing"; exit 13; }
test -d what/standard        || { echo "RED: what/standard missing"; exit 14; }
test -d how/standard/skills  || { echo "RED: how/standard/skills missing"; exit 15; }
test -f what/decisions/adr/adr_000_vault_identity.md || { echo "RED: ADR 000 missing"; exit 16; }
```

### B. Frontmatter parses on every tracked content file

```bash
python3 - <<'PY'
import yaml, subprocess, sys, pathlib
files = subprocess.check_output(['git', 'ls-files']).decode().splitlines()
content_files = [f for f in files if f.endswith(('.md', '.org', '.tmpl')) and not f.startswith('.obsidian/')]
errors = []
for f in content_files:
    try:
        text = pathlib.Path(f).read_text()
    except Exception as e:
        errors.append(f"{f}: read failed: {e}")
        continue
    if text.startswith('---\n') or text.startswith('---\r\n'):
        end = text.find('\n---\n', 4)
        if end == -1:
            errors.append(f"{f}: frontmatter open without close")
            continue
        try:
            yaml.safe_load(text[4:end])
        except yaml.YAMLError as e:
            errors.append(f"{f}: YAML parse error: {e}")
if errors:
    print("RED: frontmatter errors:")
    for e in errors:
        print(f"  - {e}")
    sys.exit(20)
print(f"OK: {len(content_files)} content files, all frontmatter valid")
PY
```

(Some files like `*.org` and `*.tmpl` may legitimately not have YAML frontmatter — adjust the filter as the convention solidifies. For Phase 3, this check is informational.)

### C. Layer Contract assertions

```bash
# C1: no real secrets in tracked files
SECRETS=$(git ls-files | grep -E '(/secrets\.env$|\.private\.el$)' || true)
if [[ -n "$SECRETS" ]]; then
  echo "RED: tracked files violate Layer Contract clause 2 (local is private):"
  echo "$SECRETS"
  exit 30
fi

# C2: deploy receipts not tracked
DEPLOY=$(git ls-files | grep -E '^deploy/' || true)
if [[ -n "$DEPLOY" ]]; then
  echo "RED: deploy/ should be gitignored (clause: machine-specific receipts not commons):"
  echo "$DEPLOY"
  exit 31
fi
```

### D. Emacs batch boot (only when ~/.emacs.d/ is present)

```bash
if [[ -d ~/.emacs.d/.git ]] && [[ -f ~/.spacemacs ]]; then
  emacs --batch -l ~/.emacs.d/init.el --eval '(message "Spacemacs.aDNA boot OK")' 2>&1 | \
    grep -E "(Error|Warning|Spacemacs.aDNA boot OK)" > /tmp/_health.log

  if grep -q "Error" /tmp/_health.log; then
    echo "RED: emacs batch boot reported errors:"
    cat /tmp/_health.log
    exit 40
  fi
  if ! grep -q "Spacemacs.aDNA boot OK" /tmp/_health.log; then
    echo "RED: emacs batch boot did not reach completion message"
    cat /tmp/_health.log
    exit 41
  fi
  echo "OK: emacs batch boot green"
else
  echo "SKIP: ~/.emacs.d/ or ~/.spacemacs absent — emacs check skipped (vault-state-only mode)"
fi
```

### D+. Live state assertions (when running Spacemacs + emacsclient available)

Extends Check D: if an Emacs server socket is found, query the **running instance** and assert Spacemacs standard values. This catches configuration bugs that batch-boot cannot detect (wrong variable values, filter not firing, layer not activating).

```bash
EMACS_SOCK=$(find /var/folders -name "server" \
  -path "*/emacs$(id -u)/*" -type s 2>/dev/null | head -1)

if [[ -n "$EMACS_SOCK" ]]; then
  LIVE=$(emacsclient -s "$EMACS_SOCK" --eval '
(format "%s|%s|%s|%s"
  (face-attribute (quote default) :height)
  (if (member "*" centaur-tabs-excluded-prefixes) "star-ok" "star-MISSING")
  (if doom-modeline-mode "doom-ok" "doom-OFF")
  (if projectile-project-search-path "proj-ok" "proj-MISSING"))
' 2>/dev/null | tr -d '"')

  FONT=$(echo "$LIVE" | cut -d'|' -f1)
  TABS=$(echo "$LIVE" | cut -d'|' -f2)
  DOOM=$(echo "$LIVE" | cut -d'|' -f3)
  PROJ=$(echo "$LIVE" | cut -d'|' -f4)

  LIVE_FAIL=0
  [[ "$FONT" != "150" ]] && { echo "RED D+: font height $FONT (want 150)"; LIVE_FAIL=1; }
  [[ "$TABS" != "star-ok" ]] && { echo "RED D+: centaur-tabs star filter missing"; LIVE_FAIL=1; }
  [[ "$DOOM" != "doom-ok" ]] && { echo "RED D+: doom-modeline not active"; LIVE_FAIL=1; }
  [[ "$PROJ" != "proj-ok" ]] && { echo "RED D+: projectile-project-search-path not set"; LIVE_FAIL=1; }
  [[ $LIVE_FAIL -eq 1 ]] && exit 70

  echo "OK: live assertions green (font=${FONT}, tabs=${TABS}, doom=${DOOM}, proj=${PROJ})"
else
  echo "SKIP: no emacs server socket — live assertions skipped (Spacemacs not running)"
fi
```

Full live inspection with screenshot: call `skill_inspect_live` (wraps this check with Step 2-5 for visual output).

### E. adna layer self-test (Phase 4 — when impl lands)

Phase 4 will add:

```bash
if [[ -d ~/.emacs.d/private/layers/adna ]]; then
  emacs --batch -l ~/.emacs.d/init.el --eval '(adna/health-check)' 2>&1 | \
    grep -E "adna/health-check: (OK|FAIL)" > /tmp/_adna.log

  grep -q "adna/health-check: FAIL" /tmp/_adna.log && {
    echo "RED: adna layer health-check failed"; cat /tmp/_adna.log; exit 50
  }
fi
```

For Phase 3, this check is a placeholder — `(adna/health-check)` doesn't exist yet.

### F. Index emission (Phase 4 — when impl lands)

```bash
if command -v python3 >/dev/null && [[ -f what/standard/index/build_graph.py ]]; then
  python3 what/standard/index/build_graph.py --validate
  GRAPH_EXIT=$?
  if [[ $GRAPH_EXIT -ne 0 ]]; then
    echo "RED: graph emission self-validate failed"
    exit 60
  fi
fi
```

For Phase 3, the script doesn't exist yet — skip.

### G. All LP layers byte-compile individually

```bash
for layer in what/standard/layers/*/; do
  layer_name=$(basename "$layer")
  for el in "${layer}"*.el; do
    [[ -f "$el" ]] || continue
    result=$(emacs --batch \
      --eval '(setq load-prefer-newer t)' \
      --eval "(byte-compile-file \"${el}\")" 2>&1)
    if echo "$result" | grep -q "Error"; then
      echo "RED G: byte-compile failed: ${el}"
      echo "$result"
      exit 85
    fi
  done
  echo "OK G: ${layer_name}/ all .el files byte-compile clean"
done
```

Warnings for `spacemacs/*` API stubs are expected (Spacemacs APIs load at boot, not in batch) — only `Error` lines fail this check.

### H. Layer structure validation

```bash
if command -v python3 >/dev/null && [[ -f what/standard/index/validate_layers.py ]]; then
  python3 what/standard/index/validate_layers.py
  if [[ $? -ne 0 ]]; then
    echo "RED H: validate_layers.py reported failures"
    exit 86
  fi
  echo "OK H: validate_layers.py all checks passed"
else
  echo "SKIP H: validate_layers.py not found — structural check skipped"
fi
```

### I. layouts.el byte-compile + symbol check

```bash
if [[ -f what/standard/layers/adna/layouts.el ]]; then
  emacs --batch \
    --eval '(setq load-prefer-newer t)' \
    --eval "(byte-compile-file \"what/standard/layers/adna/layouts.el\")" \
    2>&1 | tee /tmp/_layouts.log

  if grep -q "Error" /tmp/_layouts.log; then
    echo "RED: layouts.el byte-compile failed"
    cat /tmp/_layouts.log
    exit 80
  fi

  SYMS=$(emacs --batch \
    --eval "(load-file \"what/standard/layers/adna/layouts.el\")" \
    --eval '(princ (if (fboundp (quote adna/layout-agentic-default)) "ok" "missing"))' \
    2>/dev/null)
  if [[ "$SYMS" != "ok" ]]; then
    echo "RED: adna/layout-agentic-default not defined after loading layouts.el"
    exit 80
  fi
  echo "OK: layouts.el byte-compiles; adna/layout-agentic-default defined"
else
  echo "SKIP: layouts.el not present — layout check skipped"
fi
```

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | All green |
| 11-19 | Vault structure violations |
| 20-29 | Frontmatter parse failures |
| 30-39 | Layer Contract violations |
| 40-49 | Emacs batch boot errors |
| 50-59 | adna layer health-check failures (Phase 4+) |
| 60-69 | Graph emission failures (Phase 4+) |
| 70-79 | Live state assertion failures (D+ check, Phase 3+) |
| 80 | layouts.el compile/symbol failures (Check I) |
| 85 | LP layer byte-compile failures (Check G) |
| 86 | validate_layers.py structural failures (Check H) |

## Phase 3 baseline

When this skill runs in Phase 3 (no emacs on host), checks A-C run; D-F skip with informational messages. Exit 0 means "vault state is healthy as far as we can tell without emacs."

When emacs becomes available in a later session, checks D-F come online. The skill auto-detects host capability.

## Self-improvement signal

If this skill exits non-zero, `skill_self_improve` notices and drafts an ADR proposing a fix.
