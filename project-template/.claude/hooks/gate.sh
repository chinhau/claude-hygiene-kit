#!/bin/bash
# Stop gate: block ending the turn while the project's checks fail.
# Reads the Stop-hook JSON on stdin. Requires: bash, jq.
# Self-test: bash .claude/hooks/test-gate.sh (run from the project root).

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

# Fail loud, not open: without jq the gate cannot emit a block decision.
command -v jq >/dev/null 2>&1 || { echo "gate.sh: jq is required — install jq, or this gate cannot enforce anything" >&2; exit 2; }

input=$(cat)

# Loop guard: if we already blocked once this stop cycle, let the turn end.
if echo "$input" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  exit 0
fi

# No checks defined -> nothing to gate. Note: silence here does not mean "configured".
[ -f checks.sh ] || { echo "gate.sh: no checks.sh in $(pwd) — nothing gated" >&2; exit 0; }

if ! out=$(bash checks.sh 2>&1); then
  # Truncate in the shell BEFORE jq: a multi-MB failure log would exceed ARG_MAX,
  # kill the jq exec, and silently fail open.
  out=$(printf '%s' "$out" | tail -c 2000)
  jq -n --arg out "$out" \
    '{decision: "block", reason: ("checks.sh failed — fix (or explain why not) before closing:\n" + $out)}'
fi

exit 0
