---
type: skill
skill_type: agent
status: stub_with_parser
created: 2026-05-05
updated: 2026-05-06
last_edited_by: agent_stanley
category: telemetry
trigger: "Maintainer-side: periodic poll of upstream LatticeProtocol/SpaceLattice.aDNA telemetry-labeled issues. Aggregates fleet signals into who/peers/telemetry/inbox/ for cross-fleet pattern analysis."
phase_introduced: 8
implementation_status: stub_design_pending_v1_0_p2_mission
tags: [skill, telemetry, aggregate, maintainer, upstream, agentic_sre, stub, daedalus]
requirements:
  tools: [gh, python3, "PyYAML"]
  context:
    - what/standard/telemetry.md
  permissions:
    - "gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues (read-only against the upstream)"
    - "write who/peers/telemetry/inbox/"
    - "(does not submit ADRs; companion skill skill_self_improve_aggregate proposes those, also TBD)"
---

# skill_telemetry_aggregate — aggregate fleet telemetry (STUB)

## Purpose (stub)

Maintainer-side skill that polls the upstream `LatticeProtocol/SpaceLattice.aDNA` repo's telemetry-labeled issues, aggregates them into `who/peers/telemetry/inbox/<utc>.md` audit-trail files, and surfaces cross-fleet patterns to drive upstream ADR proposals.

The fleet-loop counterpart of operator-side `skill_telemetry_submit`.

## Status

**STUB** — full procedure designed by M-Planning-01 (v1.0 campaign Phase 0) and implemented in Phase 2.

## Outline (placeholder for full implementation)

### Steps (intent only — full procedure in Phase 2)

1. **Poll issues**: `gh api repos/LatticeProtocol/SpaceLattice.aDNA/issues?labels=telemetry&state=all --paginate`
2. **Parse and validate each issue body** — see § Maintainer parser snippet below
3. **Validate schema**: skip malformed (log and label `telemetry-malformed` for human review)
4. **Aggregate** by signal class, time window, signal count
5. **Write audit batch**: `who/peers/telemetry/inbox/<utc>_aggregate.md` with frontmatter:
   ```yaml
   type: telemetry_aggregate
   batch_window: <ISO8601_start>/<ISO8601_end>
   issue_count: <N>
   signals_by_class: {...}
   patterns_detected: [...]
   ```
6. **Pattern detection**: if N+ operators hit the same friction signal, surface as `pattern_<id>.md` in inbox
7. **Hand off to `skill_self_improve_aggregate`** (companion skill, also TBD): drafts upstream ADR proposing fleet-level fix

## Maintainer parser snippet

The following Python snippet implements steps 2–3 above. It parses a GitHub issue body (structured JSON payload inside a fenced code block), validates the `type` field, routes to a per-class handler, and rejects malformed payloads. Used at P2-04 round-trip test and by the full skill implementation.

```python
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

KNOWN_TYPES = {"friction_signal", "adr_proposal", "customization_share", "perf_metric"}

def extract_json_payload(issue_body: str) -> dict | None:
    """Extract the first JSON block from a GitHub issue body."""
    # GitHub issue bodies may wrap the payload in a fenced code block
    pattern = re.compile(r"```json\s*\n(.*?)\n```", re.DOTALL)
    m = pattern.search(issue_body)
    raw = m.group(1) if m else issue_body.strip()
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return None

def validate_type(payload: dict) -> str | None:
    """Return submission type if valid, else None."""
    t = payload.get("type")
    if t not in KNOWN_TYPES:
        return None
    return t

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

def process_issue(issue: dict, rejected_dir: Path) -> dict | None:
    """Parse one GitHub API issue object. Returns structured record or None."""
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
    handler = HANDLERS[submission_type]
    return handler(payload, issue_id)

def _write_rejected(rejected_dir: Path, issue_id: int, reason: str, raw) -> None:
    """Append rejected issue to who/peers/telemetry/inbox/rejected/ audit trail."""
    rejected_dir.mkdir(parents=True, exist_ok=True)
    utc = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    out = rejected_dir / f"{utc}_issue_{issue_id}.json"
    out.write_text(json.dumps({"issue_id": issue_id, "reason": reason, "raw": raw},
                               indent=2))
    print(f"REJECTED issue #{issue_id}: {reason} → {out}", file=sys.stderr)
```

Usage in the full skill (step 2):
```python
import subprocess, json
from pathlib import Path

issues_json = subprocess.check_output([
    "gh", "api",
    "repos/LatticeProtocol/SpaceLattice.aDNA/issues",
    "--field", "labels=telemetry",
    "--field", "state=all",
    "--paginate"
])
issues = json.loads(issues_json)
rejected_dir = Path("who/peers/telemetry/inbox/rejected")
records = [r for issue in issues
             if (r := process_issue(issue, rejected_dir)) is not None]
print(f"Parsed {len(records)} valid records from {len(issues)} issues")
```

### Hard rules (stub)

1. **Read-only against upstream.** Doesn't modify telemetry issues; doesn't auto-close them.
2. **Audit trail symmetric.** Aggregate output is committed (not gitignored) so peers can verify what's been aggregated.
3. **De-dup by issue ID.** Re-running the skill processes only new issues since last batch.
4. **Maintainer gates the next step.** This skill aggregates; ADR proposals from aggregates require maintainer approval.

## Reference

- Framework: `what/standard/telemetry.md`
- Companion skill: `how/standard/skills/skill_telemetry_submit.md` (operator side)
- Bridge to self-improve: future `skill_self_improve_aggregate` (upstream version of self-improve, fleet-aware)
- Implementation timeline: v1.0 campaign Phase 2 (designed by M-Planning-01)

## Implementation note for the planning mission

This skill's full implementation should:

1. Run idempotently — re-runs catch up from last batch
2. Track last-processed issue ID in `who/peers/telemetry/inbox/_state.json` (gitignored)
3. Provide cross-fleet correlation primitives (group by spacemacs_sha + os + signal_class)
4. Emit pattern_*.md files with severity scoring (P+M operators see same friction → priority bumps)
5. Include opt-in for maintainer to ping operators if their issue needs more info (via issue comment, not separate channel)
