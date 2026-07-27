#!/bin/bash
# Stop gate (Kimi Code): block ending the turn while the project's checks fail.
# Wired as a [[hooks]] entry (event = "Stop") in ~/.kimi-code/config.toml — Kimi has no
# project-level config, so this one global hook defers to ./checks.sh in whatever project
# the session is running in. No checks.sh -> nothing gated -> silent exit 0.
# Umbrella note: when kimi is launched from a parent directory holding many projects,
# ./checks.sh is that parent's umbrella dispatcher (kimi/checks.sh in this repo), which
# runs each sub-project's checks.sh — sub-project checks reach the gate only through it.
#
# Differences from the Claude Code original (project-template/.claude/hooks/gate.sh):
# - No jq: Kimi runs hook commands with cwd = the session's project directory, so there is
#   nothing to dig out of the stdin JSON except session_id (for the loop guard), and that
#   extraction is best-effort, never fatal.
# - Loop guard: Kimi's Stop payload has no stop_hook_active field, so we hash the failing
#   output and refuse to block twice on the identical failure. Marker lives in TMPDIR
#   (keyed by project path + session), never in the repo.
# Blocking protocol: exit 2 with the reason on stderr; anything else exits 0 (fail-open is
# Kimi's default on errors/timeouts — keep this script boring).
# Self-test: bash test-gate.sh (same directory).

input=$(cat)
sid=$(printf '%s' "$input" | sed -n 's/.*"session_id": *"\([^"]*\)".*/\1/p' | head -1)
[ -n "$sid" ] || sid="nosession"

MARKER="${TMPDIR:-/tmp}/kimi-gate-$(printf '%s' "$PWD" | cksum | awk '{print $1}')-$sid"

# No checks defined -> nothing to gate. Note: silence here does not mean "configured".
[ -f checks.sh ] || exit 0

if out=$(bash checks.sh 2>&1); then
  rm -f "$MARKER"   # green: clear any stale marker so the next failure blocks fresh
  exit 0
fi

# Truncate in the shell: a multi-MB failure log belongs nowhere near a hook's stderr.
out=$(printf '%s' "$out" | tail -c 2000)
hash=$(printf '%s' "$out" | cksum | awk '{print $1}')

# Loop guard: already blocked once on this exact failure -> let the turn end.
[ -f "$MARKER" ] && [ "$(cat "$MARKER")" = "$hash" ] && exit 0

printf '%s' "$hash" > "$MARKER"
printf 'checks.sh failed — fix (or explain why not) before closing:\n%s' "$out" >&2
exit 2
