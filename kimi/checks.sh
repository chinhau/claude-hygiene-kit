#!/bin/bash
# Umbrella checks — run every immediate sub-project's checks.sh, failures named per project.
#
# Why this exists: kimi is launched from a parent directory holding many projects
# (e.g. ~/personal_project), so the global Stop gate's ./checks.sh resolves to THIS
# file, not a sub-project's. A project opts into gating by having its own checks.sh.
# No sub-project checks.sh found -> nothing gated -> exit 0.
#
# The gate's loop guard bounds repeats to once per distinct failure per session,
# so a red project costs at most one interruption per session — fix it or explain it.
status=0
for d in */; do
  [ -f "$d/checks.sh" ] || continue
  printf '== %s\n' "${d%/}"
  ( cd "$d" && bash checks.sh ) || status=1
done
exit $status
