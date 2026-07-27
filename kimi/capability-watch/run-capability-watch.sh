#!/bin/bash
# Weekly capability-watch runner (L2: one scheduled agent run per week).
# Invoked by launchd (com.user.kimi-capability-watch.plist) — not by hand; for a manual run,
# use the /capability-watch skill in a Kimi session instead.
# Prints the report path on success; launchd stdout/stderr land in reports/*.log.
set -u

KIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPORTS="$KIT_DIR/capability-watch/reports"
mkdir -p "$REPORTS"

stamp=$(date +%F)
prev=$(ls -1 "$REPORTS"/2*.md 2>/dev/null | tail -1 || true)

prompt="Read $KIT_DIR/skills/capability-watch/SKILL.md and follow it for a scheduled weekly run. \
Today's date: $stamp. Previous report: ${prev:-none — cover the last 30 days}. \
Write the new report as Markdown to $REPORTS/$stamp.md (overwrite if it exists). \
Your final message: one line with the ACT / CONSIDER / IGNORE item counts."

cd "$KIT_DIR" || exit 1

# L1 local tripwire first: the live machine's wiring, which CI cannot see. Its verdict
# is appended to the week's report below — on failure, a red banner the human ten
# minutes cannot miss. Output: reports/doctor-<date>.txt (committed with the reports).
doctor_out="$REPORTS/doctor-$stamp.txt"
doctor_rc=0
bash "$KIT_DIR/doctor-live.sh" > "$doctor_out" 2>&1 || doctor_rc=$?

kimi -p "$prompt"
kimi_rc=$?

{
  if [ "$doctor_rc" -ne 0 ]; then
    printf '\n---\n\n## LIVE-WIRING DOCTOR FAILED (reports/doctor-%s.txt)\n\n' "$stamp"
    printf 'Enforcement or scheduling may be inert — fix this before trusting anything else this week:\n\n```\n'
    cat "$doctor_out"
    printf '```\n'
  else
    printf '\n---\n\n_Live-wiring doctor: ALL PASS (reports/doctor-%s.txt)_\n' "$stamp"
  fi
} >> "$REPORTS/$stamp.md" 2>/dev/null || true

exit $kimi_rc
