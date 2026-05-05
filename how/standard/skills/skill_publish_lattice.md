---
type: skill
skill_type: agent
status: active
created: 2026-05-04
updated: 2026-05-04
last_edited_by: agent_init
category: publishing
trigger: "Operator wants to share standard-layer changes with peers via LatticeProtocol GitHub org. Or a periodic milestone (e.g., monthly publish cadence)."
phase_introduced: 7
tags: [skill, publish, lattice, federation, daedalus, gate]
requirements:
  tools: [git, rsync, tar, python3, "PyYAML", "gh CLI (optional, for first-time repo create)"]
  context:
    - what/standard/
    - how/standard/
    - what/standard/LAYER_CONTRACT.md
    - .gitignore
  permissions:
    - "read all of vault"
    - "write dist/"
    - "write who/peers/published/"
    - "execute skill_health_check"
    - "execute sanitization scan from LAYER_CONTRACT.md"
    - "git push to github.com/LatticeProtocol/SpaceLattice.aDNA (REQUIRES OPERATOR CONFIRMATION)"
---

# skill_publish_lattice — share standard layer with peers

## Purpose

Produce a clean, sanitized tarball of `standard/` content + governance + structure, suitable for peer operators to clone, install, and arrive at the same battle station. Mirror to `github.com/LatticeProtocol/SpaceLattice.aDNA` per ADR 000.

## Two artifact paths

| Artifact | Purpose | Lifecycle |
|----------|---------|-----------|
| Tarball at `dist/<utc>.tar.gz` | Offline shipping; reproducible build | Gitignored; rebuilt on each publish |
| GitHub mirror at `github.com/LatticeProtocol/SpaceLattice.aDNA` | Public commons; canonical for peer operators | Push-only (we never pull from mirror back into vault) |

## What's published vs what's withheld

### Published (the commons)

- All governance: `MANIFEST.md`, `CLAUDE.md`, `STATE.md`, `README.md`, `CHANGELOG.md`, `AGENTS.md`, `adna.md`, `CONTRIBUTING.md`, `.gitignore`
- All of `what/standard/` (the standard layer — pins, layers, templates, specs, contract, adna source)
- All of `how/standard/` (skills + runbooks)
- All of `how/templates/` and `how/skills/` (inherited from .adna template — useful to peers)
- `what/decisions/` (ADRs are the audit trail; peers should see them)
- `what/context/`, `what/docs/`, `what/lattices/`, `what/ontology.md` (inherited context library)
- `who/upstreams/` (Spacemacs maintainers + layer authors — credit + provenance)
- `who/peers/` (federation roster — empty until first peer publishes)
- `.obsidian/` (shared config — workspace.json/graph.json/plugins/themes already gitignored)

### Withheld (private)

- `what/local/` (operator/machine private — only the `*.example` templates and README are tracked; everything else is gitignored anyway)
- `how/local/` (per-machine state; only README tracked)
- `who/operators/` (operator profiles — peers don't need names)
- `deploy/` (deploy receipts with hostnames)
- `dist/` (tarballs themselves — not published into the next tarball)
- `how/sessions/active/` (in-flight session state)
- `.git/` (the publish creates a fresh repo or fast-forwards an existing one)

## Steps

### Step 1 — Clean state check

```bash
git status --porcelain | grep -v '^??' && {
  echo "Refusing to publish with uncommitted changes."
  echo "Commit first, then re-run."
  exit 1
}
```

### Step 2 — Build publish tree

```bash
UTC=$(date -u +%Y%m%dT%H%M%SZ)
PUBLISH=/tmp/SpaceLattice.aDNA.publish-$UTC
mkdir -p $PUBLISH

rsync -a \
  --exclude='.git/' \
  --exclude='/what/local/' \
  --exclude='/how/local/' \
  --exclude='/who/operators/' \
  --exclude='/deploy/' \
  --exclude='/dist/' \
  --exclude='/.publish-clone/' \
  --exclude='/how/sessions/active/' \
  --exclude='*.dryrun.log' \
  --exclude='/tmp/' \
  ./ $PUBLISH/

echo "Publish tree at $PUBLISH"
find $PUBLISH -maxdepth 2 -type d | head -20
```

### Step 3 — Sanitize the publish tree

Run the sanitization scan from `what/standard/LAYER_CONTRACT.md` § 4 against the publish tree:

```bash
python3 -c "$(awk '/^\`\`\`python/,/^\`\`\`$/' \
                  what/standard/LAYER_CONTRACT.md | sed '1d;$d')" \
       $PUBLISH/
SCAN_EXIT=$?

[[ $SCAN_EXIT -ne 0 ]] && {
  echo "Sanitization scan failed. Publish ABORTED."
  echo "Fix violations in vault, commit, re-run."
  exit 70
}
```

If the scan fails with WARN-level only, operator must acknowledge before proceeding. FAIL aborts unconditionally.

### Step 4 — Create tarball

```bash
mkdir -p dist
TARBALL=dist/SpaceLattice.aDNA-$UTC.tar.gz
tar -czf $TARBALL -C /tmp SpaceLattice.aDNA.publish-$UTC
echo "Tarball: $TARBALL"
ls -la $TARBALL
```

The tarball preserves the publish tree's name (`SpaceLattice.aDNA.publish-<utc>`) when extracted. Operator runs `tar -tzf` to inspect contents.

### Step 5 — Health check the tarball

Extract to a fresh dir and run `skill_health_check` against the extracted state:

```bash
EXTRACT=/tmp/SpaceLattice.aDNA.tarball-test-$UTC
mkdir -p $EXTRACT
tar -xzf $TARBALL -C $EXTRACT
cd $EXTRACT/SpaceLattice.aDNA.publish-$UTC

# Run the structural checks (A, B, C) — D-F may not run without emacs
bash how/standard/skills/skill_health_check.md
HEALTH=$?
cd <vault>

[[ $HEALTH -ne 0 ]] && {
  echo "Tarball extracted state failed health check. Publish ABORTED."
  exit 1
}
```

### Step 6 — Push to GitHub mirror (REQUIRES OPERATOR CONFIRMATION)

**This step is hard-to-reverse.** A public push is visible to the world; even a force-push afterwards leaves traces (GitHub event log, mirrors). The skill MUST prompt the operator before executing.

```bash
echo "About to push to github.com/LatticeProtocol/SpaceLattice.aDNA"
echo "Tarball SHA-256: $(shasum -a 256 $TARBALL | cut -d' ' -f1)"
echo "Continue? [y/N]"
read -r CONFIRM
[[ "$CONFIRM" != "y" ]] && { echo "Aborted."; exit 0; }
```

#### First-time publish

```bash
# Create the public repo via gh (requires GH_TOKEN with repo scope, or interactive auth)
gh repo create LatticeProtocol/SpaceLattice.aDNA --public \
  --description "Agentic battle station — Spacemacs governed by aDNA. Persona: Daedalus." \
  --homepage "https://github.com/LatticeProtocol/SpaceLattice.aDNA"

# Initialize the publish working clone
mkdir -p .publish-clone
cd .publish-clone
git init
git remote add origin https://github.com/LatticeProtocol/SpaceLattice.aDNA.git
rsync -a --delete \
  --exclude='.git/' \
  $PUBLISH/ ./
git add .
git commit -m "Initial publish: SpaceLattice.aDNA $UTC

From vault commit: $(cd .. && git rev-parse HEAD)
Genesis: 2026-05-03
Persona: Daedalus
Pattern: project (informal)
"
git branch -M main
git push -u origin main
git tag v0.1.0-genesis
git push origin v0.1.0-genesis
cd ..
```

#### Subsequent publishes

```bash
cd .publish-clone
git fetch origin
git reset --hard origin/main
rsync -a --delete \
  --exclude='.git/' \
  $PUBLISH/ ./
git add .
git diff --cached --stat
git commit -m "Publish: SpaceLattice.aDNA $UTC

From vault commit: $(cd .. && git rev-parse HEAD)
"
git push origin main
git tag v<N>
git push origin v<N>
cd ..
```

### Step 7 — Write publish receipt

```bash
HOST=$(hostname)
mkdir -p who/peers/published
RECEIPT=who/peers/published/$UTC.md
cat > $RECEIPT <<EOF
---
type: publish_receipt
status: complete
utc: $UTC
publisher: $HOST
publisher_user: \$(id -un)
tarball: $TARBALL
tarball_sha256: $(shasum -a 256 $TARBALL | cut -d' ' -f1)
vault_commit: $(git rev-parse HEAD)
github_target: github.com/LatticeProtocol/SpaceLattice.aDNA
github_tag: v<N>
sanitization_scan: clean
health_check: green
created: $(date -u +%F)
updated: $(date -u +%F)
last_edited_by: agent_init
tags: [publish_receipt, lattice, $UTC]
---

# Publish receipt — $UTC

## Artifacts

- Tarball: $TARBALL ($(stat -f%z $TARBALL 2>/dev/null || stat -c%s $TARBALL) bytes)
- SHA-256: $(shasum -a 256 $TARBALL | cut -d' ' -f1)

## Pre-publish gates

- ✅ Clean git state
- ✅ Sanitization scan (LAYER_CONTRACT § 4)
- ✅ Tarball extracted health-check (skill_health_check A/B/C)

## Vault state at publish

- Commit: $(git rev-parse HEAD)
- Branch: $(git branch --show-current)
- ADRs accepted to date: $(grep -l '^status: accepted' what/decisions/adr/*.md 2>/dev/null | wc -l)
EOF
git add $RECEIPT
git commit -m "publish receipt: $UTC

Tarball SHA-256: $(shasum -a 256 $TARBALL | cut -d' ' -f1)
"
```

## Hard rules

1. **Sanitization scan is the gate.** No FAIL → no publish.
2. **Health check on extracted tarball.** A peer who clones the tarball must arrive at a working vault.
3. **Operator confirms the push.** Public publish is hard-to-reverse.
4. **Receipts are tracked.** `who/peers/published/<utc>.md` is part of the audit trail.
5. **Tarballs are gitignored.** `dist/` is local; the published artifact is the GitHub repo, not the tarball.

## Failure modes

| Failure | Recovery |
|---------|----------|
| Uncommitted vault state | Commit first, re-run |
| Sanitization scan FAIL | Fix violations in vault (probably needs an ADR), commit, re-run |
| Tarball extracted health-check fails | Diagnose; the tarball is broken — figure out which exclusion left out something needed, fix the rsync exclude list (this is itself a `standard/` change → ADR) |
| `gh` not authenticated | Operator runs `gh auth login`, re-runs |
| First-time `gh repo create` fails (already exists) | Switch to subsequent-publish path |
| Push rejected (non-fast-forward) | Investigate; force-push only with explicit operator approval (and DO NOT do this without confirmation) |

## Self-improvement signal

If `skill_self_improve` notices the publish cadence is slow (months between publishes) or fast (multiple per day), it suggests adjusting the trigger. The cadence is itself a `standard/` policy → ADR.

## DoD #6

The brief's DoD #6: "skill_publish_lattice produces a shareable artifact whose extracted contents pass skill_install on a clean reference environment."

Phase 7 partial validation (no emacs on the originating machine):

- ✅ Tarball produced (Step 4)
- ✅ Tarball extracted to clean ref dir (Step 5)
- ✅ skill_health_check A/B/C passed against extracted tree
- ⏸ skill_install run on extracted tree → DEFERRED until emacs is available on a clean ref env

The deferral is documented; full DoD #6 satisfaction requires `skill_install` succeeding from extracted tarball on a fresh machine. That's the canonical peer-operator workflow.
