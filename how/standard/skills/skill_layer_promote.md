---
type: skill
skill_type: agent
status: active
created: 2026-05-04
updated: 2026-05-04
last_edited_by: agent_init
category: layer_management
trigger: "Operator says 'promote my <X> from local to standard' or skill_self_improve detects that multiple operators have the same local-only customization."
phase_introduced: 6
tags: [skill, promote, layer, sanitization, daedalus, gate]
requirements:
  tools: [git, python3, "PyYAML"]
  context:
    - what/standard/LAYER_CONTRACT.md
    - what/local/
    - what/decisions/adr/
    - how/templates/template_adr.md
  permissions:
    - "read what/local/"
    - "draft edits in what/standard/"
    - "write what/decisions/adr/"
    - "execute skill_health_check"
    - "NEVER auto-commit to what/standard/"
---

# skill_layer_promote — promote `local/` content to `standard/`

## Purpose

Move operator-private content (in `what/local/` or `how/local/`) into the published commons (`what/standard/` or `how/standard/`). Per LAYER_CONTRACT § 4, the *only* sanctioned path. Sanitization-scanned, ADR-gated, dry-run-validated, operator-approved.

## When to use

- Operator built a layer customization in `what/local/operator.private.el` and now wants peers to benefit
- A local runbook (`how/local/machine_runbooks/...`) generalized into something hosts-of-class-X all need
- `skill_self_improve` detected the same `local/` pattern across multiple operators (when peer federation is live, Phase 7+)

## Steps

### Step 1 — Capture intent

Operator names what's being promoted:

- Source path (must be inside `what/local/` or `how/local/`)
- Target path in `standard/` (suggested by skill, confirmed by operator)
- Reason — one sentence for ADR's Context section

### Step 2 — Sanitization scan

Per LAYER_CONTRACT § 4. Inline Python or extracted script:

```bash
python3 -c "$(awk '/^```python/,/^```$/' what/standard/LAYER_CONTRACT.md \
                | sed '1d;$d')" \
       <source_path>
SCAN_EXIT=$?
```

| Exit | Meaning |
|------|---------|
| 0 | Clean — proceed to Step 3 |
| 70 | FAIL — patterns matched (hostname / user path / secret); abort with message; operator must clean source first |
| Other | Script error — diagnose |

If FAIL, the skill prints all findings and stops. The operator either edits source to remove the offending content, or chooses not to promote.

### Step 3 — Draft ADR

Path: `what/decisions/adr/adr_NNN_promote_<source-base>.md`

Frontmatter:

```yaml
type: decision
adr_id: adr_NNN
adr_number: NNN
title: "Promote `<source>` to `<target>`"
status: proposed
proposed_by: agent_<name>
target_layer: standard
target_files: [<target_path>]
detected_via:
  rule: promotion_intent
  evidence: "operator-initiated promote of <source>"
sanitization_scan: clean
ratifies:
supersedes:
superseded_by:
tags: [decision, adr, promote, layer, <topic>, proposed]
```

Body:

- **Context** — what's being promoted, why now
- **Decision** — exact source → target mapping; any rename / restructure
- **Consequences** — what changes for the standard layer; what changes for the operator's local layer (typically: source moved or `*.example`-ified)
- **Alternatives considered** — keep in local; promote partially; promote-and-deprecate
- **Reversibility** — successor ADR to demote

### Step 4 — Generate diff

The diff should describe:

- File copy/move from `what/local/` to `what/standard/`
- Optional `*.example` template left in `what/local/` (for new operators bootstrapping)
- Updates to any related index files (e.g., adding the new layer to `what/standard/layers.md`)

```bash
# Stage the move + index updates in working tree
mkdir -p $(dirname <target>)
cp <source> <target>
# Edit what/standard/layers.md or similar if applicable
git diff > what/decisions/adr/adr_NNN.diff
git checkout -- .  # restore working tree; diff is captured
```

### Step 5 — Dry-run

```bash
SCRATCH=/tmp/spacemacs.aDNA.dryrun-$(date -u +%Y%m%dT%H%M%SZ)
cp -r . "$SCRATCH"
cd "$SCRATCH"
git apply <vault>/what/decisions/adr/adr_NNN.diff
bash how/standard/skills/skill_health_check.md > /tmp/_dryrun.log 2>&1
HEALTH=$?
cd <vault>
cp /tmp/_dryrun.log what/decisions/adr/adr_NNN.dryrun.log
[[ $HEALTH -ne 0 ]] && { echo "DRY-RUN FAIL"; exit 1; }
```

### Step 6 — Present

```
============================================================
LAYER PROMOTION PROPOSAL — adr_NNN_promote_<source-base>
============================================================

SOURCE:    <source path in what/local/>
TARGET:    <target path in what/standard/>

SANITIZATION SCAN:  clean (no FAIL patterns)
                    <N> warnings: <list>

DRY-RUN:   GREEN
LOG:       what/decisions/adr/adr_NNN.dryrun.log

ARTIFACTS:
  ADR:     what/decisions/adr/adr_NNN_promote_<source-base>.md
  Diff:    what/decisions/adr/adr_NNN.diff

OPERATOR DECISION:
  (a) ACCEPT   → apply, commit with adr-NNN: promote message; optionally
                 leave .example template at original location
  (b) REJECT   → mark ADR rejected with reason; commit only ADR
  (c) DEFER    → leave proposed; cooldown 7 days
============================================================
```

### Step 7 — Operator gate

**ACCEPT**:

```bash
git apply what/decisions/adr/adr_NNN.diff
sed -i.bak 's/^status: proposed/status: accepted/' \
    what/decisions/adr/adr_NNN_promote_*.md
echo "accepted_at: $(date -u +%FT%TZ)" >> what/decisions/adr/adr_NNN_promote_*.md

# If operator chose to leave a .example at source, copy it
if [[ "$LEAVE_EXAMPLE" == "yes" ]]; then
  cp <target> <source>.example
fi

git add what/decisions/adr/adr_NNN_*.* <target> <source>.example
git rm <source> 2>/dev/null  # if source-and-example pattern not used
git commit -m "adr-NNN: promote <source> -> <target>

$(grep -A2 '## Context' what/decisions/adr/adr_NNN_promote_*.md | tail -2)
"
bash how/standard/skills/skill_deploy.md
```

**REJECT** / **DEFER**: same patterns as `skill_self_improve` step 7.

## Hard rules (LAYER_CONTRACT § 4 enforcement)

1. **Sanitization scan must pass.** No FAIL patterns. WARNs require operator acknowledgment.
2. **Dry-run health-check must be green.** Non-zero exit aborts.
3. **ADR is mandatory.** No diff applies without an accepted ADR file present.
4. **Operator gates the apply.** Never auto-commit.
5. **Source rename rule.** When promoting, the operator chooses one of:
   - **Move** — source moved to target; nothing left in `what/local/`
   - **Move + leave example** — target lives in standard; `.example` template left in `what/local/` for future operators bootstrapping their local layer
   - **Copy** — both files exist (rare; use only when source diverges in operator's machine)

## Anti-patterns

- **Promoting without scan.** Hostnames in standard layer are a contract violation.
- **Promoting one operator's preference.** If "operator's preferred theme color" is being promoted to standard, the ADR must justify why ALL operators want this — not just this one. Prefer the `*.example` pattern instead.
- **Promoting half a layer.** If a customization references three files and you only promote one, the standard layer is broken. Promote atomically.

## Self-improvement signal

`skill_self_improve` (Phase 5) Rule F can detect promotion candidates:

- Same `local/` content across ≥3 operators (when peer federation is live, Phase 7+)
- Same edit happening repeatedly in different sessions
- Operator manually says "I keep doing this, can we promote?"

In each case, `skill_self_improve` drafts an ADR proposing promotion via this skill. Operator decides as usual.
