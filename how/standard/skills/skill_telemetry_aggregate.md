---
type: skill
skill_type: agent
status: active
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
category: telemetry
trigger: "Maintainer-side: periodic poll of upstream LatticeProtocol/SpaceLattice.aDNA telemetry-labeled issues. Aggregates fleet signals into who/peers/telemetry/inbox/ for cross-fleet pattern analysis."
phase_introduced: 8
implementation_status: active
tags: [skill, telemetry, aggregate, maintainer, upstream, agentic_sre, daedalus]
requirements:
  tools: [gh, python3, "PyYAML"]
  context:
    - what/standard/telemetry.md
    - what/standard/telemetry_schema.json
  permissions:
    - "gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues (read-only)"
    - "write who/peers/telemetry/inbox/"
    - "write who/peers/telemetry/inbox/_state.json (gitignored)"
---

# skill_telemetry_aggregate — aggregate fleet telemetry

## Purpose

Maintainer-side skill that polls the upstream `LatticeProtocol/SpaceLattice.aDNA` repo's telemetry-labeled issues, parses and validates each payload, de-duplicates against previously-processed issues, aggregates fleet signals into a committed audit batch, and surfaces cross-fleet patterns that may trigger upstream ADR proposals.

The fleet-loop counterpart of operator-side `skill_telemetry_submit`.

**Hard constraints:**

- **Read-only against upstream.** Never modifies, closes, or labels telemetry issues autonomously.
- **Audit trail committed.** Aggregate output lands in `who/peers/telemetry/inbox/` and is committed — peers can verify what has been aggregated.
- **De-dup by issue ID.** `_state.json` (gitignored) tracks the last-processed issue ID; re-runs are idempotent.
- **Maintainer gates the next step.** This skill aggregates and surfaces patterns; ADR proposals from patterns require maintainer review and approval.

## Flags

| Flag | Behavior |
|------|----------|
| _(none)_ | Full run — poll, parse, dedup, aggregate, detect patterns, write inbox, update state |
| `--dry-run` | Runs Steps 1–4, prints parsed records and any pattern detections, stops without writing to inbox or updating `_state.json` |
| `--since <iso8601>` | Filter issues created after the given ISO 8601 timestamp (overrides `_state.json` for the batch window) |

---

## Step 1 — Poll

Fetch all telemetry-labeled issues from the upstream repo, paginating to catch large fleets:

```bash
gh api "repos/LatticeProtocol/SpaceLattice.aDNA/issues?labels=telemetry&state=all" \
  --paginate \
  > /tmp/telemetry_issues.json

echo "Fetched $(python3 -c "import json; print(len(json.load(open('/tmp/telemetry_issues.json'))))" ) issues"
```

If the `telemetry` label does not exist on the upstream repo:

```bash
gh label create telemetry \
  --repo LatticeProtocol/SpaceLattice.aDNA \
  --color 0075ca \
  --description "Fleet telemetry submission from SpaceLattice.aDNA operators"
```

---

## Step 2 — Parse and validate

Run the parser against each issue. The parser extracts the JSON payload from the issue body (wrapped in a fenced code block by `skill_telemetry_submit`), validates the `type` field, routes to a per-class handler, and rejects malformed payloads to a separate rejected/ audit trail.

```python
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

KNOWN_TYPES = {"friction_signal", "adr_proposal", "customization_share", "perf_metric"}

def extract_json_payload(issue_body: str) -> dict | None:
    """Extract the first JSON block from a GitHub issue body."""
    pattern = re.compile(r"```json\s*\n(.*?)\n```", re.DOTALL)
    m = pattern.search(issue_body)
    raw = m.group(1) if m else issue_body.strip()
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None

def validate_type(payload: dict) -> str | None:
    t = payload.get("type")
    return t if t in KNOWN_TYPES else None

def handle_friction_signal(payload: dict, issue_id: int) -> dict:
    return {"issue_id": issue_id, "class": "friction_signal",
            "rule": payload.get("detected_via_rule"),
            "signal": payload.get("signal_class"),
            "count": payload.get("signal_count", 1),
            "sha": payload.get("spacemacs_sha"),
            "os": payload.get("os")}

def handle_adr_proposal(payload: dict, issue_id: int) -> dict:
    return {"issue_id": issue_id, "class": "adr_proposal",
            "title": payload.get("title"),
            "decision": payload.get("operator_decision"),
            "target_layer": payload.get("target_layer")}

def handle_customization_share(payload: dict, issue_id: int) -> dict:
    return {"issue_id": issue_id, "class": "customization_share",
            "target": payload.get("target"),
            "hash": payload.get("content_hash")}

def handle_perf_metric(payload: dict, issue_id: int) -> dict:
    return {"issue_id": issue_id, "class": "perf_metric",
            "boot_ms": payload.get("boot_time_ms"),
            "packages": payload.get("package_count"),
            "layers": payload.get("layer_count"),
            "os": payload.get("os")}

HANDLERS = {
    "friction_signal": handle_friction_signal,
    "adr_proposal": handle_adr_proposal,
    "customization_share": handle_customization_share,
    "perf_metric": handle_perf_metric,
}

def _write_rejected(rejected_dir: Path, issue_id: int, reason: str, raw) -> None:
    rejected_dir.mkdir(parents=True, exist_ok=True)
    utc = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out = rejected_dir / f"{utc}_issue_{issue_id}.json"
    out.write_text(json.dumps({"issue_id": issue_id, "reason": reason, "raw": raw}, indent=2))
    print(f"REJECTED issue #{issue_id}: {reason} → {out}", file=sys.stderr)

def process_issue(issue: dict, rejected_dir: Path) -> dict | None:
    issue_id = issue.get("number", 0)
    body = issue.get("body", "")
    payload = extract_json_payload(body)
    if payload is None:
        _write_rejected(rejected_dir, issue_id, "json_parse_error", body)
        return None
    submission_type = validate_type(payload)
    if submission_type is None:
        _write_rejected(rejected_dir, issue_id, "unknown_type", payload)
        return None
    return HANDLERS[submission_type](payload, issue_id)
```

Usage:

```python
issues = json.load(open("/tmp/telemetry_issues.json"))
rejected_dir = Path("who/peers/telemetry/inbox/rejected")
records = [r for issue in issues
             if (r := process_issue(issue, rejected_dir)) is not None]
print(f"Parsed {len(records)} valid records from {len(issues)} issues")
```

---

## Step 3 — De-dup

Load `who/peers/telemetry/inbox/_state.json` (gitignored) to find the last-processed issue ID. Skip issues with `issue_id ≤ last_processed_id`.

```python
import json
from pathlib import Path

STATE_PATH = Path("who/peers/telemetry/inbox/_state.json")

def load_state() -> dict:
    if STATE_PATH.exists():
        return json.loads(STATE_PATH.read_text())
    return {"last_processed_issue_id": 0, "last_run_utc": None}

state = load_state()
last_id = state["last_processed_issue_id"]
new_records = [r for r in records if r["issue_id"] > last_id]
print(f"De-dup: {len(records)} parsed, {len(new_records)} new (last_id={last_id})")
```

If `new_records` is empty, the skill exits cleanly: "No new telemetry issues since last run."

---

## Step 4 — Aggregate

Group records by submission class and count. Build the aggregate metadata:

```python
from collections import Counter

by_class = Counter(r["class"] for r in new_records)
max_issue_id = max(r["issue_id"] for r in new_records) if new_records else last_id

utc_now = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
batch_start = state.get("last_run_utc") or "epoch"
batch_end = datetime.now(timezone.utc).isoformat()

aggregate = {
    "batch_window": f"{batch_start}/{batch_end}",
    "issue_count": len(new_records),
    "signals_by_class": dict(by_class),
    "new_issue_ids": [r["issue_id"] for r in new_records],
    "records": new_records,
}
print(f"Aggregate: {aggregate['signals_by_class']}")
```

---

## Step 5 — Pattern detection

For each `friction_signal` record, group by `signal` (signal_class value). If ≥5 records share the same signal, emit a pattern file:

```python
PATTERN_THRESHOLD = 5

friction = [r for r in new_records if r["class"] == "friction_signal"]
signal_counts = Counter(r["signal"] for r in friction)

patterns_detected = []
for signal_class, count in signal_counts.items():
    if count >= PATTERN_THRESHOLD:
        pattern_id = f"pattern_{signal_class}"
        pattern_file = Path(f"who/peers/telemetry/inbox/{pattern_id}.md")
        pattern_content = f"""---
type: telemetry_pattern
pattern_id: {pattern_id}
signal_class: {signal_class}
occurrence_count: {count}
detected_at: {utc_now}
threshold: {PATTERN_THRESHOLD}
status: pending_maintainer_review
---

# Pattern Detected: {signal_class}

{count} operators reported `{signal_class}` friction. Exceeds threshold of {PATTERN_THRESHOLD}.

## Affected issues

{chr(10).join(f"- Issue #{r['issue_id']} (SHA: {r.get('sha', 'unknown')}, OS: {r.get('os', 'unknown')})" for r in friction if r["signal"] == signal_class)}

## Recommended next step

Review issues above and draft an upstream ADR via `skill_self_improve` (fleet-aware) or manually.
"""
        pattern_file.write_text(pattern_content)
        patterns_detected.append(pattern_id)
        print(f"PATTERN: {pattern_id} — {count} occurrences (threshold {PATTERN_THRESHOLD})")

if not patterns_detected:
    print("No pattern threshold exceeded — no pattern files emitted")

aggregate["patterns_detected"] = patterns_detected
```

---

## Step 6 — Write audit batch (committed)

Write the aggregate batch file to `who/peers/telemetry/inbox/` and commit it:

```python
inbox_file = Path(f"who/peers/telemetry/inbox/{utc_now}_aggregate.md")
inbox_content = f"""---
type: telemetry_aggregate
batch_window: {aggregate['batch_window']}
issue_count: {aggregate['issue_count']}
signals_by_class: {json.dumps(aggregate['signals_by_class'])}
patterns_detected: {json.dumps(aggregate['patterns_detected'])}
aggregated_at: {utc_now}
---

# Telemetry Aggregate — {utc_now}

**Batch window**: `{aggregate['batch_window']}`
**Issues processed**: {aggregate['issue_count']}
**By class**: {aggregate['signals_by_class']}
**Patterns detected**: {aggregate['patterns_detected'] or 'none'}

## Records

"""
for r in aggregate["records"]:
    inbox_content += f"- Issue #{r['issue_id']} — `{r['class']}`: {r}\n"

inbox_file.write_text(inbox_content)
print(f"Inbox batch written: {inbox_file}")
```

Then commit the inbox entry and any pattern files:

```bash
git add who/peers/telemetry/inbox/
git commit -m "telemetry: aggregate batch $UTC_NOW ($N issues, classes: $CLASSES)"
```

---

## Step 7 — Update `_state.json` (gitignored)

Record the highest processed issue ID and run timestamp so the next invocation de-dups correctly:

```python
new_state = {
    "last_processed_issue_id": max_issue_id,
    "last_run_utc": datetime.now(timezone.utc).isoformat(),
}
STATE_PATH.write_text(json.dumps(new_state, indent=2))
print(f"State updated: last_processed_issue_id={max_issue_id}")
```

`_state.json` is gitignored — it tracks machine-local idempotency state and is not part of the committed audit trail.

---

## Demo invocation (dry-run)

A safe end-to-end demonstration that does not write to inbox or update state:

```bash
# 1. Fetch issues
gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues \
  --field labels=telemetry --field state=all --paginate > /tmp/telemetry_issues.json

# 2. Parse (Python from Step 2 above)
python3 - <<'PY'
import json
from pathlib import Path
# ... paste Steps 2-4 code here with dry_run=True ...
issues = json.load(open("/tmp/telemetry_issues.json"))
print(f"Would process {len(issues)} issues")
# Step 3 dedup, Step 4 aggregate — print only, no writes
PY

# 3. No inbox write, no _state.json update
echo "Dry-run complete — no files written"
```

---

## Reference

- Framework: `what/standard/telemetry.md`
- Schema: `what/standard/telemetry_schema.json` (ADR-009)
- Sanitization: `what/standard/LAYER_CONTRACT.md` §4
- Companion skill (operator side): `how/standard/skills/skill_telemetry_submit.md`
- Self-improvement bridge: `how/standard/skills/skill_self_improve.md` (local); future `skill_self_improve_aggregate` (fleet-aware, post-v1.0)
- Ratifying decision: ADR-011
- Implementation mission: `mission_sl_p2_04_telemetry_aggregate_skill_and_round_trip`
