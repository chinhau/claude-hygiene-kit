#!/bin/bash
# Pipe-tests for gate.sh: pass / block / loop-guard / huge-output / missing-jq.
# Run from the project root: bash .claude/hooks/test-gate.sh
set -u
GATE=".claude/hooks/gate.sh"
fails=0

t() { # name  expected-substring(empty=expect silence)  stdin-json  checks.sh-body
  local name="$1" expect="$2" stdin="$3" body="$4" out
  printf '%s\n' "$body" > checks.sh
  out=$(printf '%s' "$stdin" | bash "$GATE" 2>/dev/null)
  if [ -n "$expect" ]; then
    if printf '%s' "$out" | grep -q "$expect"; then echo "PASS: $name"; else echo "FAIL: $name (got: ${out:-<empty>})"; fails=$((fails+1)); fi
  else
    if [ -z "$out" ]; then echo "PASS: $name"; else echo "FAIL: $name (expected silence, got: $out)"; fails=$((fails+1)); fi
  fi
}

[ -f checks.sh ] && cp checks.sh checks.sh.bak

t "green checks -> silence"       ""        '{}'                          'exit 0'
t "red checks -> block decision"  '"block"' '{}'                          'echo boom; exit 1'
t "loop guard -> silence"         ""        '{"stop_hook_active": true}'  'echo boom; exit 1'
t "huge output -> still blocks"   '"block"' '{}'                          'seq 1 200000; exit 1'

# missing jq -> exit 2 (blocks loudly instead of failing open)
rc=$(PATH="$(dirname "$(command -v bash)")" bash "$GATE" </dev/null >/dev/null 2>&1; echo $?)
if [ "$rc" = "2" ]; then echo "PASS: missing jq -> exit 2"; else echo "FAIL: missing jq (exit $rc, want 2)"; fails=$((fails+1)); fi

if [ -f checks.sh.bak ]; then mv checks.sh.bak checks.sh; else rm -f checks.sh; fi

if [ "$fails" -eq 0 ]; then echo "gate self-test: ALL PASS"; else echo "gate self-test: $fails FAILURE(S)"; exit 1; fi
