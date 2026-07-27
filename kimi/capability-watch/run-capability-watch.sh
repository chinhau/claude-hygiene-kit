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
kimi -p "$prompt"
