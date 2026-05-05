---
type: skill
skill_type: agent
status: active
created: 2026-05-03
updated: 2026-05-03
last_edited_by: agent_init
category: layer_management
trigger: "Operator wants to add a Spacemacs layer to the standard set in what/standard/layers.md."
phase_introduced: 3
tags: [skill, layer, spacemacs, adr, dry_run, daedalus]
requirements:
  tools: [git, "emacs (>=29.0)", python3]
  context:
    - what/standard/layers.md
    - what/standard/dotfile.spacemacs.tmpl
    - what/decisions/adr/
    - how/templates/template_adr.md
  permissions:
    - "write what/decisions/adr/"
    - "draft edits to what/standard/layers.md"
    - "write to scratch worktree"
    - "execute skill_health_check"
---

# skill_layer_add — add a Spacemacs layer to the standard set

## Purpose

Add a layer to `what/standard/` through the ADR + diff + dry-run + operator-approval gate. Never auto-commits.

## Trigger

Operator says "add the `csv` layer" or "add `org-roam` to standard." Skill takes over.

## Steps

### Step 1 — Capture intent

Ask operator (if not already specified):

- Layer name (e.g., `csv`, `latex`, `org-roam`)
- Why (one sentence — drives the ADR's "Context" section)
- Variables to set (if any) — like `(csv :variables csv-default-separator ?,)`
- Should this layer replace any existing layer (e.g., switching `helm` → `ivy`)?

If any answer is unclear, **don't proceed** — ask operator. Layer additions are commits to the commons; precision matters.

### Step 2 — Conflict scan

```bash
# Layer already in standard?
grep -q "^| \`$LAYER\`" what/standard/layers.md && echo "ALREADY_IN_STANDARD: $LAYER"

# Layer in operator's local?
grep -q "$LAYER" what/local/operator.private.el 2>/dev/null && echo "IN_LOCAL: $LAYER"

# Keybinding conflict — check the layer's known prefix against existing
# (heuristic: most layers under SPC prefix; conflict is rare for new official layers)
```

If `IN_LOCAL`, propose **promotion** path instead: `skill_layer_promote` is the right skill.

### Step 3 — Draft ADR

Use `how/templates/template_adr.md`. Path: `what/decisions/adr/adr_NNN_<layer>_layer.md` where `NNN` is next free sequence.

Frontmatter:

```yaml
type: decision
adr_id: adr_NNN
adr_number: NNN
title: "Add the `<layer>` Spacemacs layer to standard"
status: proposed
proposed_by: agent_<name>
target_layer: standard
target_files:
  - what/standard/layers.md
  - what/standard/dotfile.spacemacs.tmpl
ratifies:
supersedes:
superseded_by:
tags: [decision, adr, layer, spacemacs, <layer>, proposed]
```

Body sections:

- **Context** — operator's "why" + any conflict-scan findings
- **Decision** — what the layer adds, what variables, what keybindings it owns
- **Consequences** — packages installed, ELPA repos, byte-compile time impact
- **Alternatives considered** — closest existing layer, why this one
- **Reversibility** — how to roll back (just remove from layers.md + dotfile.tmpl + redeploy)

### Step 4 — Generate diff

Two files change:

- `what/standard/layers.md` — append a row to the appropriate section table
- `what/standard/dotfile.spacemacs.tmpl` — add the layer (with `:variables` if any) to `dotspacemacs-configuration-layers`

Save the unified diff alongside the ADR: `what/decisions/adr/adr_NNN.diff`.

### Step 5 — Dry-run in scratch worktree

```bash
SCRATCH=/tmp/SpaceLattice.aDNA.dryrun-$(date -u +%Y%m%dT%H%M%SZ)
cp -r . "$SCRATCH"
cd "$SCRATCH"
git apply <vault>/what/decisions/adr/adr_NNN.diff
# Render template + skill_health_check (without ~/.emacs.d/ — vault-only checks)
bash how/standard/skills/skill_health_check.md > /tmp/_dryrun.log 2>&1
HEALTH=$?
cd <vault>
cp /tmp/_dryrun.log what/decisions/adr/adr_NNN.dryrun.log
[[ $HEALTH -ne 0 ]] && {
  echo "Dry-run health-check FAILED. Operator: review $SCRATCH and adr_NNN.dryrun.log"
  exit 1
}
```

### Step 6 — Present to operator

Output:

```
Layer add proposal: <layer>
ADR: what/decisions/adr/adr_NNN_<layer>_layer.md (status: proposed)
Diff: what/decisions/adr/adr_NNN.diff
Dry-run: what/decisions/adr/adr_NNN.dryrun.log (exit 0 — green)
Scratch worktree: /tmp/SpaceLattice.aDNA.dryrun-<utc>/

Operator decision required:
  (a) ACCEPT  → apply diff, set ADR status: accepted, commit, run skill_deploy
  (b) REJECT  → set ADR status: rejected with reason, commit only the ADR
  (c) DEFER   → leave ADR status: proposed; agent will not re-propose for 7 days
```

### Step 7 — Operator-gated commit

**Only on explicit ACCEPT:**

```bash
git apply what/decisions/adr/adr_NNN.diff
sed -i.bak 's/^status: proposed/status: accepted/' what/decisions/adr/adr_NNN_<layer>_layer.md
rm what/decisions/adr/adr_NNN_<layer>_layer.md.bak
git add what/standard/layers.md what/standard/dotfile.spacemacs.tmpl what/decisions/adr/
git commit -m "adr-NNN: add ${LAYER} Spacemacs layer to standard

$(grep -A2 '## Context' what/decisions/adr/adr_NNN_<layer>_layer.md | tail -2)
"
# Then run skill_deploy to materialize the change in ~/.spacemacs
bash how/standard/skills/skill_deploy.md
```

On REJECT: only commit the ADR with `status: rejected` + the rejection reason.

On DEFER: don't commit anything; leave the ADR file with `status: proposed`.

## Hard rules

1. **Never bypass the ADR.** Even for "obviously useful" layers.
2. **Never bypass the dry-run.** Health-check exit 0 is the gate.
3. **Never auto-commit on dry-run failure.** That's the whole point of the gate.
4. **Operator chooses ACCEPT/REJECT/DEFER.** Agent never decides.

## Self-improvement loop

If multiple operators repeatedly add the same layer locally without promoting, `skill_self_improve` notices and proposes adding it to standard via this same workflow.
