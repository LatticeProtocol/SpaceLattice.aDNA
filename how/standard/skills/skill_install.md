---
type: skill
skill_type: agent
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
category: install
trigger: "Operator wants to install Spacemacs.aDNA on a fresh machine, or machine state shows ~/.emacs.d/ is empty/missing, or first deploy after fork."
phase_introduced: 3
tags: [skill, install, spacemacs, deploy, idempotent, daedalus]
requirements:
  tools: [git, "emacs (>=29.0)", python3, "node (>=20)", ripgrep, fd]
  context:
    - what/standard/pins.md
    - what/standard/layers.md
    - what/standard/dotfile.spacemacs.tmpl
    - what/standard/packages.el.tmpl
    - what/standard/layers/adna/
    - what/local/ (optional, may not exist on first run)
  permissions:
    - "write ~/.emacs.d/"
    - "write <vault-root>/init.el"
    - "write <shell-rc> (~/.zshrc or ~/.bashrc) — SPACEMACSDIR export"
    - "write deploy/"
    - "read what/standard/"
    - "read what/local/ if present"
---

# skill_install — install Spacemacs.aDNA on a fresh machine

## Purpose

Take a host from "no Spacemacs" to "working Spacemacs.aDNA battle station with the `adna` layer loaded and the `SPC a` transient available." Idempotent: rerunning produces the same end state without destroying prior work.

## Pre-conditions

| Check | If fails |
|-------|----------|
| `git --version` works | Abort with deps list |
| `emacs --version` parses to ≥29.0 | Abort with version diff |
| `python3 --version` works | Abort with deps list |
| `node --version` parses to ≥20 | Abort with version diff |
| `rg --version` works (ripgrep) | Abort with deps list |
| `fd --version` works (or `fdfind` on Debian/Ubuntu) | Abort with deps list |
| Current dir has `MANIFEST.md` with `subject: spacemacs` | Abort — operator is not in the vault root |

The pre-condition check writes its findings to `how/local/machine_runbooks/last_preflight.log` (gitignored).

## Steps

### Step 1 — Host verification

```bash
cd <vault-root>  # where MANIFEST.md lives
mkdir -p how/local/machine_runbooks deploy
LOG=how/local/machine_runbooks/last_install.log
echo "=== preflight $(date -u +%FT%TZ) ===" > "$LOG"
git --version           >> "$LOG" 2>&1 || { echo "MISSING: git"; exit 1; }
emacs --version | head -1 >> "$LOG" 2>&1 || { echo "MISSING: emacs"; exit 1; }
python3 --version       >> "$LOG" 2>&1 || { echo "MISSING: python3"; exit 1; }
node --version          >> "$LOG" 2>&1 || { echo "MISSING: node"; exit 1; }
rg --version | head -1  >> "$LOG" 2>&1 || { echo "MISSING: ripgrep"; exit 1; }
( fd --version || fdfind --version ) | head -1 >> "$LOG" 2>&1 || { echo "MISSING: fd"; exit 1; }
```

If any tool missing, abort with the OS-specific install hint from `what/standard/pins.md` § "Required system tooling."

### Step 2 — Backup existing dotfiles

```bash
UTC=$(date -u +%Y%m%dT%H%M%SZ)

# Detect prior Spacemacs.aDNA installation (marker in vault's init.el)
SPACEMACS_OURS=0
if [[ -f "$VAULT/init.el" ]]; then
  if grep -q "Spacemacs.aDNA standard dotfile" "$VAULT/init.el"; then
    SPACEMACS_OURS=1
  fi
fi

if [[ -d ~/.emacs.d ]] && [[ $SPACEMACS_OURS -eq 0 ]]; then
  mv ~/.emacs.d ~/.emacs.d.bak.$UTC
  echo "Backup: ~/.emacs.d.bak.$UTC" >> "$LOG"
fi
```

If the backup `mv` fails (disk full, permission), abort. Don't proceed with a half-state.

### Step 3 — Clone Spacemacs at pinned SHA

```bash
PIN_SHA=$(awk -F'`' '/Pinned SHA/ && /[0-9a-f]{7,}/ {print $2; exit}' what/standard/pins.md || echo "")

if [[ ! -d ~/.emacs.d/.git ]]; then
  git clone https://github.com/syl20bnr/spacemacs.git ~/.emacs.d
fi
cd ~/.emacs.d
git fetch origin develop
if [[ -z "$PIN_SHA" || "$PIN_SHA" == "PIN PENDING" ]]; then
  # First-run pin capture — checkout latest develop
  git checkout develop
  CAPTURED=$(git rev-parse HEAD)
  echo "[FIRST-RUN] Captured Spacemacs SHA: $CAPTURED" >> "<vault-root>/$LOG"
  echo "Operator: confirm and update what/standard/pins.md with this SHA"
else
  if ! git checkout "$PIN_SHA" 2>>"<vault-root>/$LOG"; then
    echo "PIN MISMATCH: pinned $PIN_SHA not present in develop. See $LOG"
    exit 1
  fi
fi
cd <vault-root>
```

(The `<vault-root>` substitution is the actual absolute path of the Spacemacs.aDNA vault — set as `VAULT=$(pwd)` at start.)

### Step 3.5 — Set SPACEMACSDIR in shell profile

Spacemacs resolves the dotfile location by checking `$SPACEMACSDIR/init.el` first (§1.2). Write the export to the operator's shell rc so it persists across sessions, and export it now for the current process.

```bash
# Determine shell rc file
if [[ -f "$HOME/.zshrc" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
  SHELL_RC="$HOME/.bashrc"
else
  SHELL_RC=""
  echo "WARNING: no .zshrc or .bashrc found; set SPACEMACSDIR=$VAULT manually" >> "$LOG"
fi

SPACEMACS_EXPORT="export SPACEMACSDIR=\"$VAULT\""
if [[ -n "$SHELL_RC" ]]; then
  if ! grep -q "SPACEMACSDIR" "$SHELL_RC"; then
    printf '\n# Spacemacs.aDNA — vault-resident dotfile\n%s\n' "$SPACEMACS_EXPORT" >> "$SHELL_RC"
    echo "SPACEMACSDIR written to $SHELL_RC" >> "$LOG"
  else
    echo "SPACEMACSDIR already in $SHELL_RC — skipping" >> "$LOG"
  fi
fi

# Export for the current session so subsequent steps can use it
export SPACEMACSDIR="$VAULT"
```

Idempotent: if `SPACEMACSDIR` is already present in the rc, this step is a no-op.

### Step 4 — Render templates

```bash
mkdir -p ~/.emacs.d/private

# Render dotfile.spacemacs.tmpl → <vault-root>/init.el
# Spacemacs finds it via $SPACEMACSDIR (set in Step 3.5).
# Most paths now use dotspacemacs-directory at runtime — only LOCAL_LAYER_LIST
# remains as a static substitution (empty by default).
python3 - "$VAULT" <<'PY'
import sys, pathlib
vault = pathlib.Path(sys.argv[1])
tmpl = (vault / "what/standard/dotfile.spacemacs.tmpl").read_text()

substitutions = {
    "{{LOCAL_LAYER_LIST}}": "",  # operator-added layer names; edit to add private layers
}
for k, v in substitutions.items():
    tmpl = tmpl.replace(k, v)
(vault / "init.el").write_text(tmpl)
print(f"Rendered {vault}/init.el from dotfile.spacemacs.tmpl")
PY

# Render packages.el.tmpl → ~/.emacs.d/private/packages.el
python3 - "$VAULT" <<'PY'
import sys, pathlib
vault = pathlib.Path(sys.argv[1])
tmpl = (vault / "what/standard/packages.el.tmpl").read_text()
tmpl = tmpl.replace("{{LOCAL_PACKAGES_LIST}}", "")
out = pathlib.Path("~/.emacs.d/private/packages.el").expanduser()
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(tmpl)
print(f"Rendered {out}")
PY
```

If template rendering fails, abort. The host now has bare Spacemacs but no rendered dotfile — recoverable by re-running this step.

### Step 5 — Install adna layer

```bash
mkdir -p ~/.emacs.d/private/layers
ADNA_SRC="$VAULT/what/standard/layers/adna"
ADNA_DST=~/.emacs.d/private/layers/adna

if [[ -L "$ADNA_DST" ]]; then
  # Existing symlink — verify it points to our source; if not, replace
  CUR=$(readlink "$ADNA_DST")
  [[ "$CUR" != "$ADNA_SRC" ]] && rm "$ADNA_DST"
fi
[[ ! -e "$ADNA_DST" ]] && ln -s "$ADNA_SRC" "$ADNA_DST"
```

Idempotent: re-running keeps the same symlink.

### Step 6 — First batch boot (validates layers load)

```bash
emacs --batch -l ~/.emacs.d/init.el > "$LOG" 2>&1
EMACS_EXIT=$?
if [[ $EMACS_EXIT -ne 0 ]]; then
  echo "Emacs batch boot failed ($EMACS_EXIT). See $LOG"
  exit $EMACS_EXIT
fi
```

> **Important**: load `~/.emacs.d/init.el` (Spacemacs's bootstrap), NOT `~/.spacemacs`. `emacs --batch` does NOT auto-load `user-init-file`; loading `.spacemacs` alone only defines the `dotspacemacs/*` functions without triggering bootstrap. See ADR 003.
>
> Also: redirect to file via `> "$LOG" 2>&1`, NOT `| tee | tail` — the latter SIGPIPE-kills emacs in some sequences. The operator can `tail "$LOG"` interactively after the run.

Spacemacs's first boot installs the layer packages from ELPA/MELPA. This step takes 2-10 minutes on a fresh machine; ~3.5 min observed on Apple Silicon. The output goes to the install log; agent can grep for "Error" or "package-not-available" markers.

### Step 7 — Run skill_health_check

```bash
bash how/standard/skills/skill_health_check.md  # the skill itself is callable; see that file
HEALTH_EXIT=$?
if [[ $HEALTH_EXIT -ne 0 ]]; then
  echo "Health check failed; see $LOG"
  exit $HEALTH_EXIT
fi
```

(`skill_health_check.md` carries the executable contract; the agent follows its steps. See that file for what "green" means.)

### Step 8 — Write deploy receipt

```bash
HOST=$(hostname)
mkdir -p deploy/$HOST
RECEIPT=deploy/$HOST/$UTC.md
cat > "$RECEIPT" <<EOF
---
type: deploy_receipt
host: $HOST
utc: $UTC
emacs_version: $(emacs --version | head -1)
spacemacs_sha: $(cd ~/.emacs.d && git rev-parse HEAD)
adna_layer: $ADNA_DST -> $ADNA_SRC
health_status: green
preflight_log: how/local/machine_runbooks/last_install.log
tags: [deploy_receipt, $HOST, install]
last_edited_by: agent_init
created: $(date -u +%F)
updated: $(date -u +%F)
---

# Deploy receipt — $HOST @ $UTC

skill_install completed end-to-end. See preflight log for tooling versions and Emacs batch-boot output.

## What was installed

- ~/.emacs.d/ → Spacemacs at SHA $(cd ~/.emacs.d && git rev-parse HEAD)
- $VAULT/init.el ← rendered from \`what/standard/dotfile.spacemacs.tmpl\` (gitignored)
- SPACEMACSDIR=$VAULT written to shell rc
- ~/.emacs.d/private/packages.el ← rendered from \`what/standard/packages.el.tmpl\`
- ~/.emacs.d/private/layers/adna → symlink to vault's \`what/standard/layers/adna/\`

## Health check result

green
EOF
echo "Deploy receipt: $RECEIPT"
```

## Post-conditions

After successful run:

- `~/.emacs.d/` is a Spacemacs clone at the pinned SHA
- `<vault>/init.el` is rendered from this vault's template (gitignored)
- `SPACEMACSDIR=<vault>` exported in shell rc — Spacemacs finds `<vault>/init.el` on next launch
- `~/.emacs.d/private/layers/adna/` is a symlink to `<vault>/what/standard/layers/adna/`
- `how/local/machine_runbooks/last_install.log` captures the install transcript (gitignored)
- `deploy/<hostname>/<utc>.md` records the receipt (gitignored)

## Failure modes — abort cleanly

| Failure | What's left in place | Recovery |
|---------|----------------------|----------|
| Pre-condition fail | No changes | Install missing tools, re-run |
| Backup fail | Original `~/.emacs.d/` + `~/.spacemacs` intact | Free disk; re-run |
| Clone fail | Backup taken; `~/.emacs.d/` may be partial | `rm -rf ~/.emacs.d`; re-run |
| Pin mismatch | Backup taken; `~/.emacs.d/` at wrong SHA | Update `pins.md` (via ADR) or re-run with corrected pin |
| Template render fail | Backup taken; `~/.emacs.d/` cloned but `<vault>/init.el` missing | Re-run from Step 4 |
| Batch boot fail | Everything in place but Emacs errored | Read log, fix layer config, re-run from Step 4 |
| Health check fail | Everything in place but unhealthy | Read `recover_from_breakage.md`, possibly restore from backup |

## Idempotency

Re-running on an already-installed machine:

- Step 1 — same checks, fast
- Step 2 — detects `Spacemacs.aDNA` marker in `<vault>/init.el`; skips backup
- Step 3.5 — detects `SPACEMACSDIR` already in shell rc; skips write
- Step 3 — `git fetch` + `git checkout` to pinned SHA (no-op if already there)
- Step 4 — re-renders templates (overwrites; safe)
- Step 5 — symlink check; no-op if correct
- Step 6 — re-runs batch boot (cheap on subsequent runs since packages cached)
- Step 7 — health check (always runs)
- Step 8 — new receipt

## OS-specific notes

| OS | Notes |
|----|-------|
| macOS | Homebrew is the assumed package manager. `brew install emacs ripgrep fd python3 node` covers deps. |
| Linux (Debian/Ubuntu) | `apt install emacs ripgrep fd-find python3 nodejs git`. `fd` may install as `fdfind` — alias or symlink to `fd`. |
| Linux (Arch) | `pacman -S emacs ripgrep fd python git nodejs`. |
| WSL2 | All Linux deps + ensure WSLg or X server running for GUI Emacs. Document in `how/local/machine_runbooks/wsl2_notes.md` if needed. |
| Windows native | Out of scope — use WSL2. |

## Reproducibility pact

The pin discipline in `what/standard/pins.md` is what allows another operator to clone this vault and arrive at the same battle station. Don't bypass pins; if upstream has moved past your pin in a way you want to absorb, run `how/standard/runbooks/update_spacemacs.md` (ADR-gated).

## Self-improvement hooks

`skill_self_improve` (Phase 5) reads `how/local/machine_runbooks/last_install.log` looking for repeated friction (slow boot, package not found, layer load error). If it sees a pattern across 2+ installs, it drafts an ADR proposing a fix.
