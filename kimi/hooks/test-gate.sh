#!/bin/bash
# Pipe-tests for the Kimi Stop gate: no-checks / green / red / loop-guard / new-failure /
# huge-output / marker-cleared-on-green. Runs in a mktemp scratch project — safe anywhere.
#   bash test-gate.sh
set -u
GATE="$(cd "$(dirname "$0")" && pwd)/gate.sh"
fails=0

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work" || exit 1
export TMPDIR="$work/tmp"   # keep loop-guard markers inside the scratch dir
mkdir -p "$TMPDIR"

# run_gate <stdin-json> -> sets rc, err
run_gate() {
  err=$(printf '%s' "$1" | bash "$GATE" 2>&1 >/dev/null)
  rc=$?
}

t() { # <name> <want-rc> <expect-substring-in-stderr (empty = expect silence)>
  local name="$1" want_rc="$2" expect="$3"
  if [ "$rc" != "$want_rc" ]; then
    echo "FAIL: $name (exit $rc, want $want_rc)"; fails=$((fails+1)); return
  fi
  if [ -n "$expect" ]; then
    if printf '%s' "$err" | grep -q "$expect"; then echo "PASS: $name"
    else echo "FAIL: $name (want stderr to contain '$expect', got: ${err:-<empty>})"; fails=$((fails+1)); fi
  else
    if [ -z "$err" ]; then echo "PASS: $name"
    else echo "FAIL: $name (expected silence, got: $err)"; fails=$((fails+1)); fi
  fi
}

STDIN='{"hook_event_name":"Stop","session_id":"test-session","cwd":"'"$work"'"}'

rm -f checks.sh
run_gate "$STDIN"; t "no checks.sh -> exit 0, silent" 0 ""

printf 'exit 0\n' > checks.sh
run_gate "$STDIN"; t "green checks -> exit 0, silent" 0 ""

printf 'echo boom; exit 1\n' > checks.sh
run_gate "$STDIN"; t "red checks -> exit 2 + reason" 2 "checks.sh failed"

run_gate "$STDIN"; t "same failure again -> loop guard, exit 0" 0 ""

printf 'echo boom2; exit 1\n' > checks.sh
run_gate "$STDIN"; t "different failure -> blocks again" 2 "boom2"

printf 'seq 1 200000; exit 1\n' > checks.sh
run_gate "$STDIN"; t "huge output -> still blocks" 2 "checks.sh failed"

printf 'exit 0\n' > checks.sh
run_gate "$STDIN"   # green clears the marker
printf 'echo boom3; exit 1\n' > checks.sh
run_gate "$STDIN"; t "green clears marker -> next red blocks" 2 "boom3"

if [ "$fails" -eq 0 ]; then echo "gate self-test: ALL PASS"; else echo "gate self-test: $fails FAILURE(S)"; exit 1; fi
