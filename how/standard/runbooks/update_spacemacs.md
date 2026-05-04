---
type: runbook
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
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
SCRATCH=/tmp/spacemacs.aDNA.bumppin-$(date -u +%Y%m%dT%H%M%SZ)
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
