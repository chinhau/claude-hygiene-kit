#!/bin/bash
# doctor-live.sh — tripwire for the LIVE machine's wiring, which CI cannot see.
#
# CI tests the kit's components in a clean checkout. It cannot test whether the
# installed harness on THIS machine still does what the docs claim — and that is
# where the broken-promise class lives (the gate passed every unit test while
# aiming ./checks.sh at a directory that never had one). This script is the
# integration test for the harness itself, run from the real launch context.
#
# Run weekly by capability-watch/run-capability-watch.sh (output lands in
# reports/doctor-<date>.txt; a failure appends a red banner to the week's report).
# Run by hand after ANY change to launch conventions: launch directory,
# KIMI_CODE_HOME, hook paths, skill copies. Usage: doctor-live.sh [LAUNCH_DIR [REPO_DIR]]
#
# Exit 0 = all pass; exit 1 with FAIL lines = enforcement may be inert.
set -u

LAUNCH_DIR="${1:-$HOME/personal_project}"
REPO_DIR="${2:-$HOME/personal_project/llm-hygiene-kit}"
KIMI_HOME="${KIMI_CODE_HOME:-$HOME/.kimi-code}"
fails=0
ok()  { echo "PASS: $1"; }
bad() { echo "FAIL: $1"; fails=$((fails+1)); }

# 0. The behavioral contract itself is on disk (missing = every session runs blind).
[ -f "$KIMI_HOME/AGENTS.md" ] && ok "contract present: $KIMI_HOME/AGENTS.md" \
  || bad "no $KIMI_HOME/AGENTS.md — sessions run without the global contract"

# 1. The Stop hook entry points at a script that exists (a wired hook to a dead path
#    fails open by design — Kimi treats hook errors as pass).
hook_cmd=$(grep -A2 '^\[\[hooks\]\]' "$KIMI_HOME/config.toml" 2>/dev/null | grep 'command' | head -1 || true)
hook_path=$(printf '%s' "$hook_cmd" | sed -n 's/.*bash \([^ ]*gate\.sh\).*/\1/p')
if [ -n "$hook_path" ] && [ -f "$hook_path" ]; then
  ok "Stop hook wired to existing $hook_path"
else
  bad "Stop hook: no [[hooks]] command in $KIMI_HOME/config.toml resolving to an existing gate.sh"
fi

# 2. The umbrella dispatcher exists at the real launch dir — without it the gate's
#    ./checks.sh resolves to nothing and nothing is ever gated (the original bug).
if [ -f "$LAUNCH_DIR/checks.sh" ]; then
  ok "umbrella checks.sh present at $LAUNCH_DIR"
else
  bad "no checks.sh at launch dir $LAUNCH_DIR — gate's ./checks.sh resolves to nothing; nothing is gated"
fi

# 3. Behavioral proof, from the real launch dir, exactly as Kimi fires the hook:
#    a fixture project with failing checks MUST produce exit 2. Exit 0 here is the
#    exact signature of the umbrella gap.
if [ -n "$hook_path" ] && [ -f "$hook_path" ]; then
  fx="$LAUNCH_DIR/doctor-fixture-$$"
  mkdir -p "$fx"
  trap 'rm -rf "$fx"' EXIT
  sid="doctor-$(date +%s)"

  printf '#!/bin/bash\necho doctor-fixture-failure\nexit 1\n' > "$fx/checks.sh"
  out=$(cd "$LAUNCH_DIR" && printf '{"hook_event_name":"Stop","session_id":"%s"}' "$sid" | bash "$hook_path" 2>&1)
  rc=$?
  if [ "$rc" = "2" ]; then
    if printf '%s' "$out" | grep -q 'doctor-fixture'; then
      ok "gate blocks from real launch dir (exit 2, failing project named)"
    else
      ok "gate blocks from real launch dir (exit 2)"
    fi
  else
    bad "gate from $LAUNCH_DIR with a failing sub-project: want exit 2, got exit $rc — enforcement inert: ${out:-<empty>}"
  fi

  # Green fixture: exit 0 expected, but a legitimately red REAL project also yields
  # exit 2 — that is correct behavior, so only fail if the fixture itself is blamed.
  printf '#!/bin/bash\nexit 0\n' > "$fx/checks.sh"
  out=$(cd "$LAUNCH_DIR" && printf '{"hook_event_name":"Stop","session_id":"%s-g"}' "$sid" | bash "$hook_path" 2>&1)
  rc=$?
  if [ "$rc" = "0" ]; then
    ok "gate silent on green fixture"
  elif [ "$rc" = "2" ] && ! printf '%s' "$out" | grep -q 'doctor-fixture'; then
    ok "gate clean on green fixture (blocks on other projects only — as designed)"
  else
    bad "gate on green fixture: got exit $rc: ${out:-<empty>}"
  fi
fi

# 4. Drift: live copies byte-match the repo's (an edit to one side only is how
#    "tested in the repo" stops meaning "running on the machine").
for pair in \
  "$KIMI_HOME/hooks/gate.sh:$REPO_DIR/kimi/hooks/gate.sh" \
  "$LAUNCH_DIR/checks.sh:$REPO_DIR/kimi/checks.sh" \
  "$KIMI_HOME/skills/new-project/SKILL.md:$REPO_DIR/kimi/skills/new-project/SKILL.md" \
  "$KIMI_HOME/skills/capability-watch/SKILL.md:$REPO_DIR/kimi/skills/capability-watch/SKILL.md" \
  "$KIMI_HOME/skills/harness-audit/SKILL.md:$REPO_DIR/shared/skills/harness-audit/SKILL.md"; do
  live="${pair%%:*}"; kit="${pair#*:}"
  [ -f "$kit" ] || { ok "skip drift (kit copy absent): $kit"; continue; }
  if [ -f "$live" ] && cmp -s "$live" "$kit"; then
    ok "drift: ${live#$HOME/} matches kit"
  else
    bad "drift: ${live#$HOME/} differs from ${kit#$HOME/} (or live missing) — sync one way"
  fi
done

# 5. Scheduled jobs actually loaded — a plist on disk is not a running schedule
#    (the Claude watch sat unloaded in ~/Library/LaunchAgents doing nothing).
for job in com.user.kimi-capability-watch com.chlim.capability-watch; do
  if launchctl list 2>/dev/null | grep -q "$job"; then
    ok "launchd: $job loaded"
  else
    bad "launchd: $job NOT loaded — the weekly run you think happens, doesn't"
  fi
done

echo "---"
if [ "$fails" -eq 0 ]; then
  echo "doctor-live: ALL PASS"
else
  echo "doctor-live: $fails FAILURE(S)"
  exit 1
fi
