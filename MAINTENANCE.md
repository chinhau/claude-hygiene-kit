# How this kit stays current — three layers, ten human minutes a week

The failure mode to design against is documented in [our own audit](audits/superclaude-2026-07.md):
frozen "Last Updated" stamps, sync promises nobody kept, ✅ status nobody verified. "Fully
automatic, zero-human" maintenance is how repos die politely. The goal instead: everything is
either a deterministic tripwire or agent-prepared; the human only reads one small diff a week.

## Layer 1 — deterministic tripwires (zero human, zero LLM)

- `.github/workflows/test.yml` — the gate's five pipe-tests on every push, Ubuntu + macOS.
- `.github/workflows/freshness.yml` — weekly: every evidence URL in README/RECEIPTS must still
  resolve, and the RECEIPTS "Last verified" stamp must be under 60 days old. A failure emails
  the owner. **Staleness is a failing test, not a dashboard** — that is all the metric tracking
  this needs. (If published: stars/issues are GitHub's job, don't build anything.)

## Layer 2 — one scheduled agent run per week

`routines/capability-watch.md` diffs the official changelog against the setup in use and returns
ACT / CONSIDER / IGNORE (+ reverse-drift deletions). Scheduling options:
- **macOS launchd** (durable, local — recommended): a runner script that unsets any stale
  `ANTHROPIC_API_KEY`, invokes `claude -p "$(cat routines/capability-watch.md)"` with read/write
  + web tools, and saves a dated report. Verify headless auth once (`claude -p "Reply OK"`)
  before trusting the schedule.
- `/schedule` cloud routines — only if the config the routine reads is committed to a repo the
  cloud can see.
- Session-scoped crons (any tool that dies with the session) are NOT maintenance — they're the
  broken-promise pattern with extra steps.

## Layer 3 — the human ten minutes

Read the weekly report. Merge or reject the proposed one-block edits. Bump the RECEIPTS stamp
when you re-verify. That's the whole job — and it is deliberately not automated: the audit
severity taxonomy exists because judgment about what to trust cannot be a cron job.
