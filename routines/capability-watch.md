# Capability watch — weekly scheduled routine template

Run weekly. This is the anti-FOMO mechanism: awareness arrives on a schedule, decisions take
ten minutes, nothing else changes.

**Execution note:** steps 2 reads your local `~/.claude/` files, so the routine must run where
those files live — use a local mechanism (`/loop`, a local cron invoking `claude -p`, or a
desktop scheduled task). Cloud routines via `/schedule` can't see your local config unless you
point step 2 at a repo-committed copy. Keep the last-run date in a `LAST-RUN` line at the top
of this file (the routine updates it) so "since the last run" has real state.

## Prompt for the routine agent

You maintain a Claude Code setup. Once a week:

1. Read the official changelog (code.claude.com/docs/en/changelog and the anthropics/claude-code
   CHANGELOG.md) for entries since the last run.
2. Read the user's current setup: `~/.claude/CLAUDE.md` (the dated models block), settings.json,
   the list of skills/hooks/routines in use.
3. Produce a report with exactly three sections, hardest-filtered first:
   - **ACT** (rare): a change that breaks or invalidates current config — model default changed,
     API behavior changed, a pinned model deprecated, pricing shifted enough to change the
     worker-tier choice. Include the one-block edit to make.
   - **CONSIDER** (max 3): new capabilities that remove a recurring task the user demonstrably
     has. Name the task it removes. If you cannot name one, it goes in the last section.
   - **IGNORE** (everything else): one line each, so the user knows what they are deliberately
     not adopting. This section exists to kill FOMO, not to create it.
4. Also flag reverse-drift: anything in the user's setup the changelog has made redundant
   (a hand-rolled mechanism now covered natively). Propose the deletion.

Do not install, edit, or enable anything. The report is the deliverable; the human decides.
