---
type: skill
skill_type: agent
status: active
created: 2026-05-10
updated: 2026-05-10
last_edited_by: agent_stanley
category: maintenance
trigger: "Upstream Spacemacs develop has moved past the pinned SHA and operator wants to absorb the update; or CI upstream-sync workflow opened a pin-drift issue."
phase_introduced: 4
tags: [skill, pin, update, spacemacs, adr, maintenance, daedalus]
requirements:
  tools: [git, emacs]
  context:
    - what/standard/pins.md
    - how/standard/runbooks/update_spacemacs.md
  permissions:
    - "read what/standard/pins.md"
    - "write what/standard/pins.md"
    - "write what/decisions/adr/"
    - "write how/standard/runbooks/"
    - "read ~/.emacs.d/ (for batch health-check)"
---

# skill_update_pin — ADR-gated Spacemacs pin bump

## Purpose

Absorb upstream Spacemacs `develop` changes by bumping the pinned SHA in `what/standard/pins.md`. Every pin bump is ADR-gated and documented in a dated rebase receipt. This skill is triggered by a CI drift issue (ADR-031) or operator decision.

## When to use

- CI `upstream-sync` workflow opened a pin-drift GitHub issue
- Operator wants to absorb upstream changes after reviewing the changelog
- Pin date is >30 days old (soft threshold; hard gate is operator decision)

## Pre-conditions

| Check | If fails |
|-------|----------|
| `what/standard/pins.md` exists and has a `Pinned SHA` row | Abort — pin file missing or malformed |
| `git ls-remote https://github.com/syl20bnr/spacemacs.git refs/heads/develop` returns a SHA | Abort — network error or upstream unavailable |
| Emacs ≥29.0 available for health-check | Warn and defer health-check to next machine with Emacs |

## Steps

### Step 1 — Fetch upstream develop HEAD

```bash
NEW_SHA=$(git ls-remote https://github.com/syl20bnr/spacemacs.git refs/heads/develop | awk '{print $1}')
echo "Upstream HEAD: $NEW_SHA"
```

### Step 2 — Read current pinned SHA

```bash
OLD_SHA=$(awk -F'`' '/Pinned SHA/ && /[0-9a-f]{7,}/ {print $2; exit}' what/standard/pins.md)
echo "Current pin:   $OLD_SHA"
```

If `OLD_SHA == NEW_SHA`, upstream has not moved — no update needed. Log and exit cleanly.

### Step 3 — Review changelog (human step)

Operator reads `https://github.com/syl20bnr/spacemacs/compare/<OLD_SHA>...<NEW_SHA>` (browser) or:

```bash
# If you have a local Spacemacs clone:
git -C ~/.emacs.d log --oneline "${OLD_SHA}..${NEW_SHA}" -- CHANGELOG.org
```

Flag any breaking changes in the ADR (Step 5). If breaking changes are unacceptable, abort.

### Step 4 — Write rebase receipt

```bash
UTC=$(date -u +%Y%m%dT%H%M%SZ)
RECEIPT="how/standard/runbooks/rebase_log_${UTC}.md"

cat > "$RECEIPT" <<EOF
---
type: runbook_artifact
artifact_type: rebase_receipt
created: $(date -u +%F)
updated: $(date -u +%F)
last_edited_by: agent_stanley
tags: [rebase_receipt, pin_bump]
---

# Rebase receipt — ${UTC}

| Field | Value |
|-------|-------|
| Date | $(date -u +%F) |
| Old SHA | \`${OLD_SHA}\` |
| New SHA | \`${NEW_SHA}\` |
| Delta commits | (count from GitHub compare) |
| Breaking changes | none / see notes below |
| Conflict notes | clean (vault-only model — no LP commits in fork) |
| Operator | stanley |

## Notes

Vault-only model (ADR-024): \`LatticeProtocol/spacelattice\` fork carries no LP commits.
Rebase is a pin-only operation — no conflict resolution required.
EOF

echo "Receipt written: $RECEIPT"
```

### Step 5 — Author ADR (proposal)

Use `how/templates/template_adr.md`. The ADR:
- States the old → new SHA
- Notes any breaking changes reviewed in Step 3
- References ADR-002 (initial pin) and this skill as the update protocol
- Status: `accepted` after operator approval

### Step 6 — Update pins.md

Update `what/standard/pins.md`:
- Bump `Pinned SHA` row to `NEW_SHA`
- Update `Pin date` row to today
- Append `ratified_by:` reference to the new ADR number

Do NOT update without operator approval of the ADR from Step 5.

### Step 7 — Health-check (if Emacs available)

```bash
emacs --batch -l ~/.emacs.d/init.el > /tmp/pin_health_check.log 2>&1
if [[ $? -ne 0 ]]; then
  echo "Batch boot failed after pin bump — see /tmp/pin_health_check.log"
  echo "Consider reverting pins.md to OLD_SHA and filing a blocker."
  exit 1
fi
echo "Batch boot: OK"
```

If Emacs is not available on the current host, note this in the ADR and defer health-check to next `skill_install` run.

### Step 8 — Commit

```bash
git add what/standard/pins.md what/decisions/adr/adr_NNN_pin_bump_<date>.md "how/standard/runbooks/rebase_log_${UTC}.md"
git commit -m "adr-NNN: bump spacemacs pin $(echo $OLD_SHA | cut -c1-7)→$(echo $NEW_SHA | cut -c1-7)"
```

## Failure modes

| Failure | Recovery |
|---------|----------|
| Network error at Step 1 | Retry; check GitHub status |
| Breaking change flagged at Step 3 | Abort pin bump; track in backlog until upstream fixes or vault adapts |
| Batch boot fails at Step 7 | Revert `pins.md` change; file blocker issue; wait for upstream fix or LP layer adaptation |
| Operator rejects ADR at Step 5 | Abort; keep current pin; add note to CI drift issue |

## Cadence

The CI `upstream-sync` workflow (ADR-031) opens a GitHub issue when it detects pin drift every Monday. This skill is the human-gated response to that issue. Typical latency: 1-2 weeks between drift detection and pin absorption (operator decides when to absorb).

## Relationship to other skills

- `skill_install` — consumes `pins.md` pinned SHA to clone at correct version
- `skill_health_check` — called at Step 7 to validate the new pin loads cleanly
- `skill_self_improve` — may notice stale pins via Rule F (date-based detection) and propose a bump
