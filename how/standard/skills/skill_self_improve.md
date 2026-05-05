---
type: skill
skill_type: agent
status: active
created: 2026-05-04
updated: 2026-05-04
last_edited_by: agent_init
category: improvement
trigger: "Periodically (operator may schedule via cron/launchd) or manually when operator notices recurring friction. Reads sessions, detects patterns, drafts ADR + diff + dry-run health-check, presents bundle."
phase_introduced: 5
tags: [skill, self_improve, adr, daedalus, gate]
requirements:
  tools: [git, python3, "PyYAML"]
  context:
    - how/sessions/history/
    - what/standard/
    - what/decisions/adr/
    - how/templates/template_adr.md
  permissions:
    - "read all of vault"
    - "write what/decisions/adr/"
    - "write to scratch worktree at /tmp/SpaceLattice.aDNA.dryrun-*"
    - "execute skill_health_check"
    - "NEVER auto-commit to what/standard/"
---

# skill_self_improve — closed loop with operator gate

## Purpose

Observe the operator's recurring frictions over recent sessions and across the vault state itself; draft an ADR + unified diff + dry-run health-check; present the bundle for approval. **The agent drafts. The operator decides. Hard rule.**

## The closed loop

```
1. READ      — recent session notes, recent ADRs, current vault state
2. DETECT    — friction signals (rules below)
3. DRAFT     — ADR proposing the change
4. DIFF      — unified diff against what/standard/ or what/local/
5. DRY-RUN   — apply diff in scratch worktree; run skill_health_check
6. PRESENT   — bundle (ADR + diff + dryrun.log) to operator
7. GATE      — operator: ACCEPT | REJECT | DEFER
```

## Step 1 — Read

Recent session notes:

```bash
# Last N session files (default N=10) sorted by name (chronological)
SESSION_FILES=$(find how/sessions/history -name "session_*.md" -type f \
                | sort -r | head -10)
[[ -z "$SESSION_FILES" ]] && echo "(no session history yet — first-run mode)"
```

Recent ADRs (to avoid re-proposing what's already been considered):

```bash
PROPOSED_ADRS=$(grep -l "^status: proposed" what/decisions/adr/*.md 2>/dev/null)
DEFERRED=$(grep -l "deferred_until: 2026" what/decisions/adr/*.md 2>/dev/null)
```

If an ADR proposes the change you're about to draft, **stop**. Don't redraft. Either operator already saw it or it's deferred.

## Step 2 — Detect (signals)

Run all detection rules. Each signal that fires gets weighed; the strongest signal becomes the ADR's primary subject.

### Rule A — Repeated manual fix in sessions

```python
# Pseudo-detection: find phrases like "had to manually X" or "fixed Y again"
# across last N sessions. If same phrase appears in ≥2 sessions, signal fires.
import pathlib, re
phrases = []
for f in pathlib.Path("how/sessions/history").rglob("session_*.md"):
    text = f.read_text()
    for m in re.finditer(r"(had to|manually|again|workaround)[^.]+\.", text, re.I):
        phrases.append((f, m.group()))
# Cluster by similarity; flag clusters with ≥2 occurrences
```

### Rule B — Missing layer / package error in install logs

```bash
ERRORS=$(grep -h -E "(Cannot open load file|package-not-available|fatal)" \
              how/local/machine_runbooks/last_install.log 2>/dev/null | sort -u)
[[ -n "$ERRORS" ]] && echo "RULE B fires: $ERRORS"
```

### Rule C — Slow operation

```bash
# Phrases like "slow" + a number; or build-time complaint
grep -h -E "(slow|takes too long|hangs)" \
        how/sessions/history/*.md 2>/dev/null | sort -u | head -5
```

### Rule D — Layer conflict (same key bound by ≥2 layers)

```python
import re, pathlib
from collections import Counter
files = list(pathlib.Path('what/standard/layers').rglob('keybindings.el'))
loc = {}  # key -> [(file, command)]
for f in files:
    for m in re.finditer(r'"([a-zA-Z]+)"\s+\'([a-zA-Z/_-]+)', f.read_text()):
        loc.setdefault(m.group(1), []).append((str(f), m.group(2)))
dups = {k: v for k, v in loc.items() if len(v) > 1 and len(set(c for _, c in v)) > 1}
if dups:
    for k, bindings in dups.items():
        print(f"RULE D fires: key '{k}' bound {len(bindings)}x — {bindings}")
```

### Rule E — Duplicated keybinding within one file

```python
import re, pathlib
from collections import Counter
for f in pathlib.Path('what/standard/layers').rglob('keybindings.el'):
    text = f.read_text()
    keys = [m.group(1) for m in re.finditer(r'"([a-zA-Z]+)"\s+\'', text)]
    counts = Counter(keys)
    dups = {k: c for k, c in counts.items() if c > 1}
    if dups:
        print(f"RULE E fires: in {f}, duplicated keys: {dups}")
```

### Rule F — Friction patterns elsewhere

Extensible — this list is alive. Phase 6+ will add rules for overlay drift, license violations, sanitization failures.

## Step 3 — Draft ADR

Use `~/lattice/.adna/how/templates/template_adr.md`. Path: `what/decisions/adr/adr_NNN_<slug>.md` where `NNN` is next sequence past the highest existing ADR id.

Frontmatter:

```yaml
type: decision
adr_id: adr_NNN
adr_number: NNN
title: "<one-line proposal>"
status: proposed
proposed_by: agent_<name>
target_layer: standard | local
target_files: [<list>]
detected_via:
  rule: <A|B|C|D|E|F>
  evidence: <one-sentence summary>
ratifies:
supersedes:
superseded_by:
tags: [decision, adr, self_improve, <topic>, proposed]
```

Body:

- **Context** — what was detected; cite session evidence or vault-state evidence
- **Decision** — what the diff proposes
- **Consequences** — what changes for operator daily use; what for peers
- **Alternatives considered** — other ways to fix; why this one
- **Reversibility** — how to roll back

## Step 4 — Diff

Save to `what/decisions/adr/adr_NNN.diff` alongside the ADR. Standard `git diff` output.

```bash
git diff > what/decisions/adr/adr_NNN.diff
git checkout -- .  # restore working tree; the diff is captured for dry-run
```

## Step 5 — Dry-run

```bash
SCRATCH=/tmp/SpaceLattice.aDNA.dryrun-$(date -u +%Y%m%dT%H%M%SZ)
cp -r . "$SCRATCH"
cd "$SCRATCH"
git apply <vault>/what/decisions/adr/adr_NNN.diff
bash how/standard/skills/skill_health_check.md > /tmp/_dryrun.log 2>&1
HEALTH=$?
cd <vault>
cp /tmp/_dryrun.log what/decisions/adr/adr_NNN.dryrun.log
[[ $HEALTH -ne 0 ]] && echo "DRY-RUN FAIL — see scratch + log"
```

If dry-run fails, **stop**. Don't present a broken proposal. Iterate the proposal until dry-run is green, OR mark the ADR `status: rejected_by_dryrun` with the failure reason and stop.

## Step 6 — Present

Output to the operator (via stdout, slack notification, or whatever surface):

```
============================================================
SELF-IMPROVEMENT PROPOSAL — adr_NNN_<slug>
============================================================

DETECTION:
  Rule: <A-F>
  Evidence: <one-line>

PROPOSAL:
  <ADR title>

DIFF SUMMARY:
  <files changed>
  <line counts>

DRY-RUN HEALTH-CHECK:
  Status: GREEN (exit 0)
  Log: what/decisions/adr/adr_NNN.dryrun.log

ARTIFACTS:
  ADR:     what/decisions/adr/adr_NNN_<slug>.md  (status: proposed)
  Diff:    what/decisions/adr/adr_NNN.diff
  Dry-run: what/decisions/adr/adr_NNN.dryrun.log
  Scratch: /tmp/SpaceLattice.aDNA.dryrun-<utc>/

OPERATOR DECISION:
  (a) ACCEPT  → apply diff, mark ADR accepted, commit, run skill_deploy
  (b) REJECT  → mark ADR rejected (with reason), commit only the ADR
  (c) DEFER   → leave ADR proposed; agent will not re-propose for 7 days
============================================================
```

## Step 7 — Operator gate

**ACCEPT**:

```bash
git apply what/decisions/adr/adr_NNN.diff
sed -i.bak 's/^status: proposed/status: accepted/' \
    what/decisions/adr/adr_NNN_<slug>.md
sed -i.bak '/^accepted_at:/d' what/decisions/adr/adr_NNN_<slug>.md
echo "accepted_at: $(date -u +%FT%TZ)" >> /tmp/_acc
sed -i.bak "/^status: accepted/r /tmp/_acc" \
    what/decisions/adr/adr_NNN_<slug>.md  # inserts after status line
rm -f what/decisions/adr/adr_NNN_<slug>.md.bak /tmp/_acc

git add what/decisions/adr/ \
        $(awk '/^target_files:/,/^[a-z_]+:/' \
             what/decisions/adr/adr_NNN_<slug>.md \
             | grep '^\s*-' | sed 's/^\s*-\s*//')
git commit -m "adr-NNN: <title>

$(grep -A2 '## Context' what/decisions/adr/adr_NNN_<slug>.md | tail -2)
"
bash how/standard/skills/skill_deploy.md  # materialize change in ~/.spacemacs
```

**REJECT**:

```bash
sed -i.bak 's/^status: proposed/status: rejected/' \
    what/decisions/adr/adr_NNN_<slug>.md
echo "rejected_at: $(date -u +%FT%TZ)" >> what/decisions/adr/adr_NNN_<slug>.md
echo "rejection_reason: \"$REASON\"" >> what/decisions/adr/adr_NNN_<slug>.md
rm -f what/decisions/adr/adr_NNN_<slug>.md.bak
git add what/decisions/adr/adr_NNN_<slug>.md \
        what/decisions/adr/adr_NNN.diff \
        what/decisions/adr/adr_NNN.dryrun.log
git commit -m "adr-NNN rejected: <title>

Reason: $REASON
"
```

**DEFER**:

```bash
echo "deferred_until: $(date -u -v+7d +%F)" >> what/decisions/adr/adr_NNN_<slug>.md
# Don't commit. The proposal stays pending for 7 days; agent re-checks via the
# PROPOSED_ADRS guard in Step 1.
```

## Hard rules

1. **Never auto-commit to `what/standard/`.** Operator gate is mandatory.
2. **Never bypass dry-run.** Health-check exit 0 is the precondition for presenting.
3. **One proposal per session.** If multiple frictions are detected, propose the strongest signal; queue others for next session (with `next_proposal:` field in operator profile).
4. **Cooldown.** Don't re-propose a rejected ADR for 30 days unless the rejection reason changes (operator can clear the cooldown manually).
5. **Read sessions before proposing.** First-run mode (no sessions yet) is allowed but should weight vault-state-only signals (Rules D/E/F) higher than session-derived (A/B/C).

## Demonstration (Phase 5 / DoD #5)

A worked example that exercises the full loop lives at:

- `what/decisions/adr/adr_001_demo_dedup_keybind.md` (frontmatter: `adr_kind: synthetic_demo`)
- `what/decisions/adr/adr_001.diff`
- `what/decisions/adr/adr_001.dryrun.log`

The demo synthesizes a duplicated keybinding in `what/standard/layers/adna/keybindings.el`, runs detection (Rule E fires), drafts the ADR, generates the diff, dry-runs in scratch worktree (health-check green), presents the bundle. The demo's commit lands the artifacts; the synthetic friction never enters committed history.

## Self-meta-improvement

If `skill_self_improve` itself produces noisy proposals, that's a signal to refine the detection rules. The skill's *own* detection logic is fair game for proposals — the recursion bottoms out when the operator is happy with the cadence.
