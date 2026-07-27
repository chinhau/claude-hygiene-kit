---
name: capability-watch
description: Weekly Kimi Code changelog triage — fetch the official changelog since the last run, compare it against the current ~/.kimi-code setup, and produce an ACT / CONSIDER / IGNORE report. Use when asked to run the weekly capability watch, check what changed in Kimi Code, or review the setup for drift against new releases.
---

# Capability watch (Kimi Code)

The anti-FOMO mechanism: awareness arrives on a schedule, decisions take ten minutes, nothing
else changes. Normally run weekly by the launchd job (see `kimi/capability-watch/` in the
hygiene-kit repo); can also be run by hand in any session.

Once per run:

1. Fetch the official changelog entries since the last run (the caller gives you the previous
   report's path; its date is the cutoff — if none, cover the last 30 days):
   - https://www.kimi.com/code/docs/en/kimi-code-cli/release-notes/changelog.html
   - https://www.kimi.com/code/docs/en/kimi-code/whats-new.html
2. Read the user's current setup: `~/.kimi-code/AGENTS.md` (the dated models block),
   `~/.kimi-code/config.toml` (models, `[[hooks]]`, `[[permission.rules]]`), and the list of
   skills in `~/.kimi-code/skills/`.
3. Produce a report with exactly three sections, hardest-filtered first:
   - **ACT** (rare): a change that breaks or invalidates current config — a config key renamed,
     hook event semantics changed, a pinned model retired, quota model shifted. Include the
     one-block edit to make.
   - **CONSIDER** (max 3): new capabilities that remove a recurring task the user demonstrably
     has. Name the task it removes. If you cannot name one, it goes in the last section.
   - **IGNORE** (everything else): one line each, so the user knows what they are deliberately
     not adopting. This section exists to kill FOMO, not to create it.
4. Also flag reverse-drift: anything in the user's setup the changelog has made redundant
   (a hand-rolled mechanism now covered natively — e.g. if `[secondary_model]` ships for real,
   the prose-intent line in the models block becomes a config edit). Propose the deletion.

Do not install, edit, or enable anything. The report is the deliverable; the human decides.
