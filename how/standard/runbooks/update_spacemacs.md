---
type: runbook
status: active
created: 2026-05-03
updated: 2026-05-06
last_edited_by: agent_stanley
audience: human
intent: "Bump the pinned Spacemacs SHA in what/standard/pins.md after upstream develop has moved."
time_estimate: "5–15 minutes"
phase_introduced: 3
tags: [runbook, pin, spacemacs, update, adr, daedalus]
---

# Runbook — update Spacemacs pin

## When to follow

- A new Spacemacs feature you want is on `develop` past your pinned SHA
- Upstream has fixed a bug you're hitting
- It's been ≥3 months since last pin update and you want to absorb general fixes

## Pre-conditions

- `~/.emacs.d/.git/` exists (you have a Spacemacs install to compare against)
- `what/standard/pins.md` lists the current pinned SHA
- Vault is in a clean git state (`git status` shows nothing uncommitted)

## Steps

### 1. See what's new upstream

```bash
cd ~/.emacs.d
git fetch origin develop
PIN=$(awk -F'`' '/Pinned SHA/ && /[0-9a-f]{7,}/ {print $2; exit}' \
                <vault-root>/what/standard/pins.md)

# Commits between current pin and develop tip
git log --oneline ${PIN}..origin/develop | head -50

# Anything that touches layer mechanism or core (high-attention items)
git log --oneline ${PIN}..origin/develop -- core/ layers/ spacemacs/
```

If the diff is very large or includes risky-looking changes (layer API rename, package mass-bump), proceed cautiously.

### 2. Open an ADR

In the vault:

```bash
cd <vault-root>
NN=$(ls what/decisions/adr/ | grep -oE '^adr_[0-9]+' | sort -V | tail -1 | sed 's/adr_//')
NEXT=$(printf "%03d" $((10#$NN + 1)))
cp how/templates/template_adr.md what/decisions/adr/adr_${NEXT}_bump_spacemacs_pin.md
```

Edit the ADR. Frontmatter:

```yaml
adr_id: adr_NNN
adr_number: NNN
title: "Bump Spacemacs pin to <new_SHA_short>"
status: proposed
proposed_by: agent_<name>
target_files:
  - what/standard/pins.md
ratifies:
  - spacemacs_sha: "<new_full_sha>"
  - pin_date: "2026-05-DD"
supersedes:
  - what/decisions/adr/adr_<previous_pin_bump>.md  # if any
```

Body:

- **Context** — why bump now. List notable upstream commits (link to commit URLs)
- **Decision** — new SHA, pin date, summary of changes absorbed
- **Consequences** — packages that may need re-install (clear ELPA cache?), layer breakage if any
- **Alternatives considered** — staying on current pin
- **Reversibility** — `git checkout <old_SHA>` in `~/.emacs.d/` and revert this ADR

### 3. Dry-run in scratch worktree

```bash
SCRATCH=/tmp/Spacemacs.aDNA.bumppin-$(date -u +%Y%m%dT%H%M%SZ)
cp -r . "$SCRATCH"
cd "$SCRATCH"

# Update pin in scratch
NEW_SHA="<new_full_sha>"
sed -i.bak "s/PIN PENDING/$NEW_SHA/" what/standard/pins.md  # if first set
# Or: sed -i.bak "s/$OLD_SHA/$NEW_SHA/" what/standard/pins.md
rm what/standard/pins.md.bak

# Run health check
bash how/standard/skills/skill_health_check.md
HEALTH=$?
cd <vault-root>
[[ $HEALTH -ne 0 ]] && { echo "DRY-RUN FAILED — see scratch worktree"; exit 1; }
```

If you want a deeper test, run `skill_install` against the scratch worktree's pin in a separate Emacs profile (`HOME=/tmp/scratch_home emacs`).

### 4. Update the pin in vault

```bash
sed -i.bak "s/PIN PENDING/$NEW_SHA/" what/standard/pins.md
# Or: sed -i.bak "s/$OLD_SHA/$NEW_SHA/" what/standard/pins.md
rm what/standard/pins.md.bak

# Update pin date in pins.md (manually edit)
# Mark ADR status accepted
sed -i.bak 's/^status: proposed/status: accepted/' what/decisions/adr/adr_${NEXT}_bump_spacemacs_pin.md
rm what/decisions/adr/adr_${NEXT}_bump_spacemacs_pin.md.bak
```

### 5. Commit the pin bump

```bash
git add what/standard/pins.md what/decisions/adr/adr_${NEXT}_bump_spacemacs_pin.md
git commit -m "adr-${NEXT}: bump Spacemacs pin to ${NEW_SHA:0:8}

See ADR for upstream commits absorbed and risk assessment.
"
```

### 6. Apply to your machine

```bash
bash how/standard/skills/skill_install.md
# (skill_install detects the pin change in pins.md, fetches/checkouts the new SHA)
```

### 7. Smoke test

Open Emacs. Verify:

- `SPC a` transient still works
- `M-x adna-index-project` still emits valid `graph.json`
- Languages you depend on still get LSP servers

If anything's broken: see `recover_from_breakage.md`.

## Post-conditions

- `what/standard/pins.md` carries new SHA + new pin date
- ADR `adr_NNN_bump_spacemacs_pin.md` is `status: accepted` and committed
- `~/.emacs.d/` HEAD matches new pin
- `deploy/<hostname>/<utc>.md` receipt records the bump
- Smoke test green

## Rollback

If smoke test fails:

```bash
cd <vault-root>
git revert HEAD  # reverts the pin bump commit
bash how/standard/skills/skill_install.md  # re-installs at OLD pin
```

The ADR stays in history with `status: superseded` (write a successor ADR documenting the rollback).

## Notes for peer operators

When you publish via `skill_publish_lattice` (Phase 7), the pin bump is part of the published commons. Peers who pull the new vault and run `skill_install` will pick up the new pin automatically. They get the same upstream commits you absorbed.

---

## Handling upstream rebase conflicts

This section provides concrete tools for when `git rebase upstream/develop` produces conflicts in the LP fork (`LatticeProtocol/spacelattice`). The patterns below detect and re-inject LP additions that rebase may clobber. All patterns run from the fork root.

> **When to use**: Run detection checks after every rebase (step 1 above). If any check fails, apply the corresponding re-injection pattern, then re-run `skill_health_check` before committing.

### File disposition heuristics

| File | Disposition | Rationale |
|------|-------------|-----------|
| `core/core-versions.el` | rebase-on-ours for LP defconst | `latticeprotocol-version` is purely additive; upstream version bump is always wanted — keep both |
| `core/core-spacemacs-buffer.el` | rebase-on-ours for `(require 'lp-branding)` | Single-line load at EOF; upstream banner logic may evolve; load line is additive |
| `core/core-spacemacs.el` | manual review | Hook insertion order is semantically significant; upstream lifecycle may shift |
| `core/templates/dotspacemacs-template.el` | manual review | Upstream adds vars we may want to expose; LP distribution default must survive |
| `layers/+distributions/spacemacs/packages.el` | rebase-on-ours for LP entries | LP package list is additive; upstream package changes are wanted |
| `core/core-configuration-layer.el` | track upstream | No LP-specific changes; always take upstream |
| `core/banners/` | rebase-on-ours | LP banner assets are owned by us; `.gitattributes merge=ours` recommended |

**Design principle**: minimize what we patch in upstream files. All branding lives in additive files (`core/lp-branding.el`); upstream files get at most a one-line load. The patterns below re-inject exactly those one-line insertions.

### Detection + re-injection patterns

Run all 5 checks after every rebase. Each check is idempotent — safe to run even when LP changes are intact.

#### Pattern 1 — `core/core-versions.el`: LP version constant

```bash
# Detect:
grep -q '(defconst latticeprotocol-version' core/core-versions.el \
  && echo "P1 OK" || echo "P1 MISSING — run re-injection"

# Re-inject (after upstream version bump clobbers our defconst):
sed -i.bak '/^(defconst spacemacs-version/a\
(defconst latticeprotocol-version "1.0.0"\
  "Spacemacs fork version.")' core/core-versions.el \
  && rm core/core-versions.el.bak
```

Update `latticeprotocol-version` value manually to match the vault's `CHANGELOG.md` entry for the release.

#### Pattern 2 — `core/core-spacemacs-buffer.el`: lp-branding load

```bash
# Detect:
grep -q "(require 'lp-branding)" core/core-spacemacs-buffer.el \
  && echo "P2 OK" || echo "P2 MISSING — run re-injection"

# Re-inject (rebase drops our EOF load line):
printf '\n;; Spacemacs.aDNA branding overlay\n(require '"'"'lp-branding)\n' \
  >> core/core-spacemacs-buffer.el
```

#### Pattern 3 — `core/core-spacemacs.el`: LP startup hook

```bash
# Detect:
grep -q "latticeprotocol-startup-hook" core/core-spacemacs.el \
  && echo "P3 OK" || echo "P3 MISSING — manual review required"

# Re-inject (find the spacemacs startup hook site and insert LP hook after it):
# NOTE: anchor line may shift across upstream versions — verify before applying.
sed -i.bak '/spacemacs-buffer-goto-link-line/a\
    (run-hooks '"'"'latticeprotocol-startup-hook)' core/core-spacemacs.el \
  && rm core/core-spacemacs.el.bak
```

> This is a manual-review file. Confirm the anchor line is still correct before applying. If it has moved, locate the equivalent line in the new upstream version and update the pattern.

#### Pattern 4 — `core/templates/dotspacemacs-template.el`: LP distribution default

```bash
# Detect:
grep -q "spacemacs-latticeprotocol" core/templates/dotspacemacs-template.el \
  && echo "P4 OK" || echo "P4 MISSING — run re-injection"

# Re-inject (upstream resets distribution to 'spacemacs):
sed -i.bak "s/dotspacemacs-distribution 'spacemacs$/dotspacemacs-distribution 'spacemacs-latticeprotocol/" \
  core/templates/dotspacemacs-template.el \
  && rm core/templates/dotspacemacs-template.el.bak
```

> Also verify LP-specific `dotspacemacs-lp-*` variables survived; those require manual review if upstream reordered the template body.

#### Pattern 5 — `layers/+distributions/spacemacs/packages.el`: LP package entries

```bash
# Detect:
grep -q "lp-branding" layers/+distributions/spacemacs/packages.el \
  && echo "P5 OK" || echo "P5 MISSING — run re-injection"

# Re-inject (LP entries after LP-owned sentinel comment):
# Prerequisite: P4 work adds "; Spacemacs.aDNA additions" comment as insertion anchor.
sed -i.bak '/;; Spacemacs.aDNA additions/,/lp-branding/{/lp-branding/!{/;; Spacemacs.aDNA additions/a\
  lp-branding\
  latticeprotocol-theme
}}' layers/+distributions/spacemacs/packages.el \
  && rm layers/+distributions/spacemacs/packages.el.bak
```

> If the sentinel comment is missing (early rebase before P4 lands), append the block manually at the end of the `spacemacs-packages` list, then add the comment as the anchor for future rebases.

### Running all detection checks at once

```bash
cd ~/lattice/spacelattice
FAIL=0
grep -q '(defconst latticeprotocol-version' core/core-versions.el           || { echo "FAIL P1 core-versions.el"; FAIL=1; }
grep -q "(require 'lp-branding)" core/core-spacemacs-buffer.el              || { echo "FAIL P2 core-spacemacs-buffer.el"; FAIL=1; }
grep -q "latticeprotocol-startup-hook" core/core-spacemacs.el               || { echo "FAIL P3 core-spacemacs.el (manual review)"; FAIL=1; }
grep -q "spacemacs-latticeprotocol" core/templates/dotspacemacs-template.el || { echo "FAIL P4 dotspacemacs-template.el"; FAIL=1; }
grep -q "lp-branding" layers/+distributions/spacemacs/packages.el           || { echo "FAIL P5 packages.el"; FAIL=1; }
[[ $FAIL -eq 0 ]] && echo "All LP injection points survived rebase."
```

Run this after every `git rebase upstream/develop`. Fix any failures before pushing.

### Dry-run validation

Simulate a conflict on pattern 1 without touching the real fork:

```bash
SCRATCH=$(mktemp -d)
# Create a minimal stub representing core-versions.el without our defconst:
cat > "$SCRATCH/core-versions.el" <<'EOF'
(defconst spacemacs-version "0.999.0" "Spacemacs version.")
EOF

# Apply pattern 1:
sed -i.bak '/^(defconst spacemacs-version/a\
(defconst latticeprotocol-version "1.0.0"\
  "Spacemacs fork version.")' "$SCRATCH/core-versions.el" \
  && rm "$SCRATCH/core-versions.el.bak"

# Verify:
grep -A2 'latticeprotocol-version' "$SCRATCH/core-versions.el"
# Expected output:
#   (defconst latticeprotocol-version "1.0.0"
#     "Spacemacs fork version.")

rm -rf "$SCRATCH"
```

### CI integration design

*Sketch — actual workflow file authored in P4-07 (`mission_sl_p4_07_ci_upstream_sync`).*

**GitHub Action: `.github/workflows/sync-upstream.yml`**

```
Trigger: schedule (weekly, Monday 06:00 UTC) + manual workflow_dispatch
Steps:
  1. Checkout LatticeProtocol/spacelattice (lp-develop branch)
  2. Add upstream remote (syl20bnr/spacemacs)
  3. Fetch upstream/develop
  4. Attempt: git rebase upstream/develop
  5. If rebase succeeds:
     a. Run all 5 detection checks (script above)
     b. If any fail: open PR with UPSTREAM_SYNC_CONFLICT_REPORT (see below)
     c. If all pass: push lp-develop; open "clean sync" PR for operator review
  6. If rebase fails:
     a. git rebase --abort
     b. Open PR with UPSTREAM_SYNC_CONFLICT_REPORT listing conflicting files
```

**PR template: `UPSTREAM_SYNC_CONFLICT_REPORT.md`**

```markdown
## Upstream sync conflict report

**Upstream commit**: <!-- SHA -->
**LP base**: <!-- SHA -->
**Conflict date**: <!-- date -->

### Conflicting files

| File | LP disposition | Suggested action |
|------|---------------|-----------------|
| <!-- file --> | <!-- heuristic --> | <!-- action --> |

### Detection check results

| Pattern | Status | Action |
|---------|--------|--------|
| P1 core-versions.el | <!-- OK/FAIL --> | <!-- re-inject/review --> |
| P2 core-spacemacs-buffer.el | <!-- OK/FAIL --> | <!-- re-inject/review --> |
| P3 core-spacemacs.el | <!-- OK/FAIL --> | <!-- manual review --> |
| P4 dotspacemacs-template.el | <!-- OK/FAIL --> | <!-- re-inject/review --> |
| P5 packages.el | <!-- OK/FAIL --> | <!-- re-inject/review --> |

### Resolution checklist

- [ ] Apply re-injection patterns for all FAILs
- [ ] Manual review for P3 and P4
- [ ] Run `skill_health_check` in vault — passes
- [ ] Push to lp-develop
- [ ] Operator approves + merges

### References

- Heuristics: `Spacemacs.aDNA/how/standard/runbooks/update_spacemacs.md` §Handling upstream rebase conflicts
- Health check: `Spacemacs.aDNA/how/standard/skills/skill_health_check.md`
```
