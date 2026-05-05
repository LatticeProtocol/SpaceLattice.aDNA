---
type: skill
skill_type: agent
status: active
created: 2026-05-04
updated: 2026-05-04
last_edited_by: agent_init
category: layer_management
trigger: "Operator points at a third-party Spacemacs distribution / layer collection (e.g., a custom 'eMac' fork on GitHub) and wants to consume it without losing provenance or risking standard-layer pollution."
phase_introduced: 6
tags: [skill, overlay, third_party, license, sanitization, daedalus, gate]
requirements:
  tools: [git, python3, "PyYAML"]
  context:
    - what/standard/LAYER_CONTRACT.md
    - what/overlay/
    - what/decisions/adr/
  permissions:
    - "git clone third-party repos"
    - "write what/overlay/"
    - "write what/decisions/adr/"
    - "draft edits in what/standard/"
    - "execute skill_health_check"
    - "NEVER auto-commit to what/standard/"
---

# skill_overlay_consume — absorb a third-party Spacemacs distribution

## Purpose

Bring a third-party Spacemacs distribution or layer collection (e.g., a custom "eMac" fork) into the vault as an *overlay*. Per LAYER_CONTRACT § 3, overlays NEVER silently overwrite `standard/`. Each overlay layer goes through ADR-gated per-layer disposition: merge into standard, hold in overlay, or reject.

## When to use

- Operator has a friend's Spacemacs distribution they want to absorb selectively
- An institutional Spacemacs config (e.g., a research group's shared setup)
- A community layer pack with multiple coordinated layers

NOT for: a single Spacemacs layer from upstream (use `skill_layer_add` instead — that's not really an overlay, just a layer addition).

## Steps

### Step 1 — Capture intent

Operator provides:

- Overlay name (slugged, lowercase: `acme-emacs`, `research-lab-spacemacs`)
- Upstream URL (`https://github.com/...`)
- Specific branch/tag/SHA to pin (recommended: pin a commit, not a moving branch)
- License (operator confirms; verified in Step 4)

### Step 2 — Clone overlay

```bash
OVERLAY=<name>
URL=<upstream_url>
PIN=<branch_or_sha>
mkdir -p what/overlay/$OVERLAY
cd what/overlay/$OVERLAY
git clone $URL .
git checkout $PIN
PIN_SHA=$(git rev-parse HEAD)
cd <vault>
```

Note: the overlay's `.git/` is *kept* (we want provenance). `what/overlay/<name>/.git/` is fine — it's not part of the vault's git (the parent vault gitignores `.git` of nested clones via standard rules).

Actually — verify. The vault's `.gitignore` ignores `.git` directories anywhere?

```bash
git status what/overlay/$OVERLAY/.git 2>&1
```

If git tries to track the nested `.git`, add it to `.gitignore`:

```bash
echo "what/overlay/$OVERLAY/.git/" >> .gitignore
```

### Step 3 — Write PROVENANCE.md

```bash
cat > what/overlay/$OVERLAY/PROVENANCE.md <<EOF
---
type: overlay_provenance
status: active
created: $(date -u +%F)
updated: $(date -u +%F)
last_edited_by: agent_<name>
overlay: $OVERLAY
upstream_url: $URL
pinned_sha: $PIN_SHA
pinned_at: $(date -u +%F)
license: <license>
tags: [overlay, provenance, $OVERLAY, third_party]
---

# $OVERLAY — provenance

## Source

- URL: $URL
- Pinned SHA: $PIN_SHA
- Pinned at: $(date -u +%F)

## License

<license + compatibility note per LAYER_CONTRACT § 5>

## Layer manifest (parsed by skill_overlay_consume)

(filled in step 5)
EOF
```

### Step 4 — License compatibility check

```bash
LICENSE_FILE=$(ls what/overlay/$OVERLAY/{LICENSE,LICENSE.md,LICENSE.txt,COPYING} 2>/dev/null | head -1)
[[ -z "$LICENSE_FILE" ]] && {
  echo "LICENSE file not found in overlay. Operator must confirm license manually."
  exit 1
}

# Parse: GPL-3.0 / Apache-2.0 / MIT / BSD = compatible
# AGPL / proprietary = reject
LICENSE_TYPE=$(grep -m1 -E "(GPL|MIT|Apache|BSD|AGPL|proprietary)" "$LICENSE_FILE" | head -1)
echo "Detected license signal: $LICENSE_TYPE"
```

Per LAYER_CONTRACT § 5:

| License | Action |
|---------|--------|
| GPL-3.0 | Compatible — proceed |
| GPL-2.0+ | Compatible — proceed |
| Apache-2.0 | Compatible — proceed |
| MIT, BSD-2/3 | Compatible — proceed |
| AGPL | REJECT — abort |
| Proprietary / no license | REJECT — abort (no implicit license = all rights reserved) |
| Other / ambiguous | Operator decision |

If REJECT: cleanup `what/overlay/<name>/` and stop.

### Step 5 — Parse layer manifest

If the overlay follows Spacemacs layer conventions, layers live at `<overlay>/layers/+*/<name>/`. Enumerate them:

```bash
LAYERS=$(find what/overlay/$OVERLAY/layers -mindepth 2 -maxdepth 2 -type d \
         | sed "s|what/overlay/$OVERLAY/layers/||")
echo "Detected layers: $LAYERS"
```

For each layer, capture:

- Name
- Owns which keybinding prefixes (parse `keybindings.el` if present)
- Conflicts with our standard? (compare against `what/standard/layers.md`)
- License (inherits overlay license unless overridden)

Update `PROVENANCE.md`'s "Layer manifest" section with the parsed table.

### Step 6 — Sanitization scan

Same as `skill_layer_promote` step 2 — but applied to the overlay tree:

```bash
python3 -c "$(awk '/^```python/,/^```$/' what/standard/LAYER_CONTRACT.md \
                | sed '1d;$d')" \
       what/overlay/$OVERLAY/
```

Overlays often contain operator-specific paths (the original author's home dir). The scan flags these. The operator decides per-finding:

- Replace with `~/` / `$HOME` (preferred)
- Move that file to operator's local layer (so the overlay stays clean)
- Leave the finding (with WARN, not FAIL) if it's a documented example

### Step 7 — Draft per-layer ADRs

For each layer detected in Step 5, draft an ADR proposing disposition:

```yaml
adr_id: adr_NNN
title: "Overlay <name>: layer <layer> disposition"
overlay: <name>
overlay_layer: <layer>
disposition: merge | hold | reject
target_layer: standard | overlay | none
target_files: <list>
```

| Disposition | What it means |
|-------------|---------------|
| `merge` | Copy layer's contents into `what/standard/layers/<layer>/`, attribute upstream in PROVENANCE.md, add to standard layer list |
| `hold` | Keep at `what/overlay/<name>/layers/<layer>/`, deploy reads from there, don't merge |
| `reject` | Don't deploy this layer; archive in `what/overlay/<name>/REJECTED/<layer>/` |

If the overlay has 5 layers, this step produces 5 ADRs (each independent).

### Step 8 — Diff + dry-run

The combined diff (one ADR's worth of changes) is generated and dry-run via the standard mechanism:

```bash
# For each accepted disposition:
SCRATCH=/tmp/...
cp -r . $SCRATCH
cd $SCRATCH
git apply <vault>/what/decisions/adr/adr_NNN.diff
bash how/standard/skills/skill_health_check.md
```

### Step 9 — Present + gate (per layer)

Each per-layer ADR is presented separately. Operator may ACCEPT some, REJECT others. The bundle is:

```
============================================================
OVERLAY DISPOSITION — adr_NNN — overlay/<name>/<layer>
============================================================

DISPOSITION:  merge | hold | reject

LAYER:        <name>/<layer>
LICENSE:      <inherited>
KEYBINDINGS:  <list of prefixes>
CONFLICTS:    <none | with standard layer X (rule R fired)>

DRY-RUN:      GREEN | RED (with reason)

OPERATOR DECISION:
  (a) ACCEPT   → apply
  (b) REJECT   → archive layer, mark ADR rejected
  (c) DEFER    → leave proposed
============================================================
```

### Step 10 — Apply (operator-gated)

Standard ACCEPT/REJECT/DEFER pattern (same as `skill_layer_promote` step 7).

For `merge` ACCEPT:

```bash
cp -r what/overlay/$OVERLAY/layers/$LAYER what/standard/layers/$LAYER
# Add attribution comment to each file
# Update what/standard/layers.md with the new entry
# Mark ADR accepted, commit
```

For `hold` ACCEPT:

```bash
# No copy needed — layer stays in what/overlay/$OVERLAY/layers/$LAYER
# Update dotfile.spacemacs.tmpl's dotspacemacs-configuration-layer-path to
# include the overlay path
# Mark ADR accepted, commit
```

For `reject`:

```bash
mkdir -p what/overlay/$OVERLAY/REJECTED
mv what/overlay/$OVERLAY/layers/$LAYER what/overlay/$OVERLAY/REJECTED/$LAYER
# Mark ADR rejected with reason, commit
```

## Hard rules (LAYER_CONTRACT § 3 enforcement)

1. **Provenance is mandatory.** PROVENANCE.md tracks upstream URL + pinned SHA + license.
2. **License must be GPL-3.0 compatible.** Per § 5.
3. **Per-layer ADR.** Bulk dispositions are not allowed — each layer's choice is its own ADR.
4. **No silent overwrites.** Overlay layer with same name as standard layer requires explicit `replace` disposition (rare).
5. **Sanitization applies to overlays too.** § 4 patterns are not waived.
6. **Operator gates every disposition.**

## Periodic re-evaluation

When the overlay's upstream releases a new version:

```bash
cd what/overlay/$OVERLAY
git fetch && git log <pinned>..origin/<branch>
```

If notable changes, run `skill_overlay_consume` again with the new pin. Each new layer or substantive change requires a successor ADR.

## Self-improvement signal

If `skill_self_improve` notices that an overlay layer held in `overlay/` is being read by deploy on every install (i.e., the operator effectively treats it as standard), it proposes promotion: ADR to merge into `standard/`. Operator decides.
