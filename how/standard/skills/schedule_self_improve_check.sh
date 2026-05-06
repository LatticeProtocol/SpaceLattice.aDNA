#!/usr/bin/env bash
# schedule_self_improve_check.sh
#
# Invoked by Claude Code Stop hook at session end.
# Counts sessions accumulated since the last self-improve ADR event.
# Prints a one-line reminder when the session-count threshold is met.
#
# Configuration (env overrides):
#   SELF_IMPROVE_THRESHOLD  — sessions between self-improve passes (default: 5)
#
# Privacy: reads only session file timestamps and ADR frontmatter.
# No content is sent anywhere. Runs entirely local.

set -euo pipefail

VAULT=$(git -C "$(cd "$(dirname "$0")" && pwd)" rev-parse --show-toplevel 2>/dev/null) || exit 0
THRESHOLD="${SELF_IMPROVE_THRESHOLD:-5}"
SESSION_DIR="$VAULT/how/sessions/history"
ADR_DIR="$VAULT/what/decisions/adr"

# Find the most-recently-modified ADR that tags self_improve activity.
# This covers both accepted and proposed self-improve ADRs.
LAST_IMPROVE_ADR=$(grep -rl "self_improve\|skill_self_improve" "$ADR_DIR"/*.md 2>/dev/null \
    | sort -t_ -k3 -V | tail -1)

if [[ -n "$LAST_IMPROVE_ADR" ]]; then
    # Count session files newer than the most recent self-improve ADR
    COUNT=$(find "$SESSION_DIR" -name "session_*.md" -newer "$LAST_IMPROVE_ADR" 2>/dev/null | wc -l | tr -d ' ')
else
    # No self-improve ADR yet — count all session files
    COUNT=$(find "$SESSION_DIR" -name "session_*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if (( COUNT >= THRESHOLD )); then
    printf "\n[SpaceLattice] %d sessions since last self-improve pass (threshold: %d). Consider running skill_self_improve this session.\n" \
        "$COUNT" "$THRESHOLD"
fi
