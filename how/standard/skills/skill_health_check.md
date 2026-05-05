---
type: skill
skill_type: agent
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
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

# skill_health_check — green/red gate for spacemacs.aDNA

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
  emacs --batch -l ~/.spacemacs --eval '(message "spacemacs.aDNA boot OK")' 2>&1 | \
    grep -E "(Error|Warning|spacemacs.aDNA boot OK)" > /tmp/_health.log

  if grep -q "Error" /tmp/_health.log; then
    echo "RED: emacs batch boot reported errors:"
    cat /tmp/_health.log
    exit 40
  fi
  if ! grep -q "spacemacs.aDNA boot OK" /tmp/_health.log; then
    echo "RED: emacs batch boot did not reach completion message"
    cat /tmp/_health.log
    exit 41
  fi
  echo "OK: emacs batch boot green"
else
  echo "SKIP: ~/.emacs.d/ or ~/.spacemacs absent — emacs check skipped (vault-state-only mode)"
fi
```

### E. adna layer self-test (Phase 4 — when impl lands)

Phase 4 will add:

```bash
if [[ -d ~/.emacs.d/private/layers/adna ]]; then
  emacs --batch -l ~/.spacemacs --eval '(adna/health-check)' 2>&1 | \
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

## Phase 3 baseline

When this skill runs in Phase 3 (no emacs on host), checks A-C run; D-F skip with informational messages. Exit 0 means "vault state is healthy as far as we can tell without emacs."

When emacs becomes available in a later session, checks D-F come online. The skill auto-detects host capability.

## Self-improvement signal

If this skill exits non-zero, `skill_self_improve` notices and drafts an ADR proposing a fix.
