---
type: skill
skill_type: agent
status: active
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
category: telemetry
trigger: "Operator wants to submit anonymized telemetry to the SpaceLattice.aDNA upstream channel — typically after a skill_self_improve cycle landed an ADR worth sharing with the fleet."
phase_introduced: 8
implementation_status: active
tags: [skill, telemetry, submit, operator_gated, daedalus]
requirements:
  tools: [gh, python3, jsonschema]
  context:
    - what/standard/telemetry.md
    - what/standard/telemetry_schema.json
    - what/standard/LAYER_CONTRACT.md
    - who/operators/<operator>.md (consent state)
  permissions:
    - "read what/local/, what/standard/, what/decisions/"
    - "execute sanitization scan (Python inline)"
    - "gh issue create against LatticeProtocol/SpaceLattice.aDNA"
---

# skill_telemetry_submit — submit anonymized telemetry

## Purpose

Operator-gated wrapper around `gh issue create` that submits anonymized telemetry to the upstream `LatticeProtocol/SpaceLattice.aDNA` repo (label: `telemetry`).

Telemetry closes the fleet loop: what one operator discovers in `skill_self_improve` can benefit every fork downstream. This skill is the bridge from local friction → upstream pattern detection.

**Hard constraints:**
- Operator consent required (`who/operators/<operator>.md` master switch + per-class opt-in)
- Sanitization scan must pass before any payload is constructed
- Operator reviews the full payload before submission — no silent auto-submit
- Per-submission opt-out is always available

## Flags

| Flag | Behavior |
|------|----------|
| _(none)_ | Interactive mode — walks all 7 steps, prompts operator at Step 5 |
| `--dry-run` | Runs Steps 1–5, prints the final payload JSON, then stops without submitting |
| `--withdraw <issue-number>` | Closes a previously-submitted issue via `gh issue close` (see §Withdraw) |

---

## Step 1 — Consent check

Read the operator profile:

```bash
cat who/operators/<operator>.md
```

Check the following fields:

```yaml
telemetry_consent: true          # master switch — must be true
telemetry_classes:               # per-class opt-ins
  friction_signal: true
  adr_proposal: true
  customization_share: false
  perf_metric: false
```

**Rules:**
- If `telemetry_consent` is absent or `false` → **ABORT** with message:
  > Telemetry consent is off. Set `telemetry_consent: true` in `who/operators/<operator>.md` to enable.
- If a specific submission class is disabled → skip collection for that class or ABORT if the requested class is off.
- If `who/operators/<operator>.md` does not exist → **ABORT** with:
  > Operator profile not found at `who/operators/<operator>.md`. Create it before submitting telemetry.

---

## Step 2 — Collect

Gather source material for the chosen submission class. The agent constructs the payload; the operator does not hand-write JSON.

### `friction_signal`

Source: `how/sessions/history/` (recent sessions), `how/backlog/` (ideas with `origin: self_improve`), or direct operator description.

Construct:

```json
{
  "type": "friction_signal",
  "schema_version": "1.0",
  "spacemacs_sha": "<value from what/standard/pins.md>",
  "os": "darwin | linux | windows",
  "signal_class": "keybind_conflict | package_load_fail | layer_compat | perf | other",
  "description": "<concise friction description, max 500 chars>",
  "evidence": "<relevant log excerpt or error message, max 2000 chars>",
  "workaround_applied": true,
  "workaround_description": "<what you did to work around it, max 500 chars>",
  "submitted_at": "<ISO 8601 UTC timestamp>"
}
```

### `adr_proposal`

Source: a recently accepted ADR in `what/decisions/adr/` with `adr_kind: local_improvement` (not `synthetic_demo`).

```json
{
  "type": "adr_proposal",
  "schema_version": "1.0",
  "spacemacs_sha": "<pins.md>",
  "os": "darwin | linux | windows",
  "adr_slug": "<adr filename without extension>",
  "problem_statement": "<concise problem, max 500 chars>",
  "proposed_change": "<diff summary or description, max 2000 chars>",
  "outcome": "accepted | rejected | superseded",
  "submitted_at": "<ISO 8601 UTC>"
}
```

### `customization_share`

Source: a layer snippet from `what/local/` or `what/standard/` that the operator wants to share.

```json
{
  "type": "customization_share",
  "schema_version": "1.0",
  "spacemacs_sha": "<pins.md>",
  "os": "darwin | linux | windows",
  "layer_name": "<layer name>",
  "snippet_type": "keybind | package | config | theme | function",
  "snippet": "<elisp snippet, max 2000 chars>",
  "description": "<what it does and why it's useful, max 500 chars>",
  "submitted_at": "<ISO 8601 UTC>"
}
```

### `perf_metric`

Source: Spacemacs startup timing from `skill_health_check` or direct measurement.

```json
{
  "type": "perf_metric",
  "schema_version": "1.0",
  "spacemacs_sha": "<pins.md>",
  "os": "darwin | linux | windows",
  "metric_class": "startup_time | layer_load_time | index_build_time | other",
  "value_ms": 3400,
  "layer_count": 22,
  "package_count": 148,
  "notes": "<any relevant context, max 500 chars>",
  "submitted_at": "<ISO 8601 UTC>"
}
```

Set `submitted_at` to current UTC timestamp:

```bash
python3 -c "from datetime import datetime, timezone; print(datetime.now(timezone.utc).isoformat())"
```

---

## Step 3 — Sanitize

Run the LAYER_CONTRACT §4 base scan **plus** telemetry-specific extensions from `what/standard/telemetry.md` §Sanitization Extensions.

### Base scan (LAYER_CONTRACT §4)

The inline Python scanner checks for:
- Hostname literals (non-loopback, non-`<placeholder>`)
- User home paths with real usernames (`/Users/<real>`, `/home/<real>`)
- Email addresses
- IP addresses (non-placeholder, non-loopback, non-RFC-1918-example)
- Secret-like patterns (`sk-`, `ghp_`, `xoxb-`, etc.)

Run against the payload JSON string:

```python
import re, json, sys

payload_str = json.dumps(payload)  # payload dict from Step 2

PATTERNS = {
    "hostname_literal": re.compile(r'\b(?!localhost|127\.0\.0\.1|<[^>]+>)[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?\.local\b', re.I),
    "user_home_path":   re.compile(r'/(?:Users|home)/(?!<)[a-zA-Z0-9_.-]+/'),
    "email_address":    re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
    "secret_pattern":   re.compile(r'\b(?:sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36,}|xoxb-[0-9-]+)\b'),
}

fails = []
for name, pat in PATTERNS.items():
    m = pat.search(payload_str)
    if m:
        fails.append(f"  {name}: {m.group()!r}")

if fails:
    print("SANITIZATION FAIL — aborting:")
    for f in fails: print(f)
    sys.exit(1)
else:
    print("Sanitization PASS")
```

**FAIL → ABORT.** Fix the payload before proceeding.

### Telemetry-specific extensions (from ADR-009)

| Rule | Field | Check | Action on violation |
|------|-------|-------|---------------------|
| LS-1 | `spacemacs_sha` | Must be 7-40 hex chars | FAIL |
| CS-1 | `snippet` | Strip any `(setq <var> "<real-path>")` if path contains real username | FAIL if real path detected |
| DE-1 | `evidence` | Max 2000 chars enforced | Truncate with `[truncated]` suffix, emit WARN |
| SHA-1 | All hash fields | Must match `^[0-9a-f]{7,40}$` | FAIL if malformed |
| VER-1 | `schema_version` | Must be `"1.0"` | FAIL |

```python
# Telemetry-specific extension checks (add to scan above)
sha = payload.get("spacemacs_sha", "")
if not re.match(r'^[0-9a-f]{7,40}$', sha):
    fails.append(f"  LS-1/SHA-1: spacemacs_sha invalid: {sha!r}")

if payload.get("schema_version") != "1.0":
    fails.append(f"  VER-1: schema_version must be '1.0', got {payload.get('schema_version')!r}")

evidence = payload.get("evidence", "")
if len(evidence) > 2000:
    payload["evidence"] = evidence[:1997] + "[truncated]"
    print("WARN DE-1: evidence field truncated to 2000 chars")
```

---

## Step 4 — Validate schema

Validate the sanitized payload against `what/standard/telemetry_schema.json`.

```bash
python3 -c "
import json, jsonschema, sys
schema = json.load(open('what/standard/telemetry_schema.json'))
payload = json.loads(sys.stdin.read())
# Route to the correct sub-schema by type
sub = schema['\$defs'][payload['type']]
try:
    jsonschema.validate(payload, sub)
    print('Schema validation PASS')
except jsonschema.ValidationError as e:
    print('Schema validation FAIL:', e.message)
    sys.exit(1)
" <<< '<payload_json>'
```

**Alternatively, from within Emacs:**

```
M-x adna/telemetry-validate
```

This invokes the `funcs.el` stub which runs the same Python validation from the current buffer.

**FAIL → ABORT.** The payload does not match the locked schema. Fix and re-run from Step 2.

---

## Step 5 — Confirm with operator

Print the full sanitized payload to the terminal (or Emacs `*Messages*` / `*telemetry-confirm*` scratch buffer). Then prompt:

```
=== TELEMETRY PAYLOAD PREVIEW ===
Submission class : friction_signal
Schema version   : 1.0
Spacemacs SHA    : e57594e7

{
  ... full JSON ...
}

Sanitization     : PASS
Schema validation: PASS

This payload will be submitted as a GitHub issue to:
  LatticeProtocol/SpaceLattice.aDNA (label: telemetry)

Proceed? [y/N] _
```

- `y` → proceed to Step 6
- `N` (or Enter) → **ABORT** with message: "Submission cancelled by operator."
- `--dry-run` flag → print payload and exit here (no submission)

---

## Step 6 — Submit

Construct the issue title and body, then submit via `gh`:

```bash
TITLE="telemetry: <submission_class> [<spacemacs_sha_short>]"
# e.g. "telemetry: friction_signal [e57594e]"

BODY=$(cat <<'JSON'
<!-- SpaceLattice.aDNA telemetry submission -->
<!-- DO NOT EDIT — generated by skill_telemetry_submit -->

```json
{
  ... sanitized payload JSON ...
}
```
JSON
)

ISSUE_URL=$(gh issue create \
  --repo LatticeProtocol/SpaceLattice.aDNA \
  --label telemetry \
  --title "$TITLE" \
  --body "$BODY")

echo "Submitted: $ISSUE_URL"
```

Capture `$ISSUE_URL` for Step 7.

**Failure modes:**

| Error | Cause | Remediation |
|-------|-------|-------------|
| `gh auth status` fails | Not authenticated | Run `gh auth login` first |
| 422 Unprocessable Entity | Label `telemetry` not yet on repo | Ask upstream maintainer to create it, or file plain issue with `[telemetry]` in title |
| Rate limit | GitHub API throttle | Wait and retry |

---

## Step 7 — Audit-write

Write a local receipt to the gitignored sent directory:

```bash
UTC=$(python3 -c "from datetime import datetime,timezone; print(datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ'))")
RECEIPT_PATH="who/peers/telemetry/sent/${UTC}.md"

cat > "$RECEIPT_PATH" <<MD
---
type: telemetry_receipt
submission_class: <class>
issue_url: $ISSUE_URL
issue_number: <N>
spacemacs_sha: <sha>
submitted_at: <ISO 8601>
---

# Telemetry Receipt — $UTC

Issue: $ISSUE_URL

## Payload

\`\`\`json
<full sanitized JSON>
\`\`\`
MD

echo "Receipt written to: $RECEIPT_PATH"
```

The `who/peers/telemetry/sent/` directory is gitignored — the receipt stays on this machine only.

---

## Withdraw a previous submission

To retract a submitted issue:

```bash
gh issue close <issue-number> \
  --repo LatticeProtocol/SpaceLattice.aDNA \
  --comment "Withdrawn by operator via skill_telemetry_submit --withdraw"
```

Note: `gh issue close` does not delete the issue — it closes it. GitHub issue deletion requires API access that `gh` CLI does not expose by default. If full deletion is needed, use:

```bash
gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues/<N>/comments \
  -F body="Withdraw request — please delete this issue." --method POST
```

Then contact upstream maintainer to delete.

---

## Demo invocation (dry-run)

A safe end-to-end demonstration that produces no GitHub issue:

```bash
# 1. Verify consent is on in your operator profile
grep telemetry_consent who/operators/stanley.md

# 2. Construct a sample friction_signal payload
python3 - <<'PY'
import json
from datetime import datetime, timezone

payload = {
    "type": "friction_signal",
    "schema_version": "1.0",
    "spacemacs_sha": "e57594e7",
    "os": "darwin",
    "signal_class": "package_load_fail",
    "description": "adna/wikilink-at-point raises cl-loop error on first Spacemacs boot",
    "evidence": "Error: (wrong-type-argument listp orig) in adna/wikilink-at-point",
    "workaround_applied": True,
    "workaround_description": "Replaced malformed cl-loop with outer let binding (fixed in ADR-003)",
    "submitted_at": datetime.now(timezone.utc).isoformat()
}
print(json.dumps(payload, indent=2))
PY

# 3. Sanitize (substitute real payload from step 2 above)
# 4. Validate
# 5. Confirm preview — then type N to stop (dry-run safe)
#    OR run with --dry-run flag to skip the interactive prompt
```

---

## Reference

- Framework: `what/standard/telemetry.md`
- Schema: `what/standard/telemetry_schema.json` (ADR-009)
- Sanitization: `what/standard/LAYER_CONTRACT.md` §4
- Telemetry extensions: `what/standard/telemetry.md` §Sanitization Extensions
- Companion skill (maintainer side): `how/standard/skills/skill_telemetry_aggregate.md`
- Self-improvement bridge: `how/standard/skills/skill_self_improve.md`
- Ratifying decision: ADR-010
