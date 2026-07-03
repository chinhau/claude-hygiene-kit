#!/bin/bash
# The project's deterministic "done" check. Exit non-zero to block session close via the Stop gate.
# UNCONFIGURED = always green: until you replace the echo below, the gate has nothing to enforce.
# Fill in the real command(s), e.g.:
#   uv run pytest -q
#   npm test && npm run build
set -e

echo "checks.sh: no checks defined yet — replace this with the project's verify command(s)"
