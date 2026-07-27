---
name: harness-audit
description: Audit an existing Claude Code or Kimi Code setup and report what to DELETE or fix — stale model references, prescriptive boilerplate, unwired enforcement, dead permissions, orphaned memories. Use when the user asks to clean up, review, or modernize their Claude/Kimi config, or feels their setup is bloated.
---

# Harness audit

Most setups accrete: rules written for older models, hooks documented but never wired,
permissions from dead one-off sessions. This skill finds what to remove. It covers both
harnesses (Claude Code and Kimi Code) — including drift *between* them, which neither tool
can see alone. Output is a ranked report (assessment first — do not edit anything until asked).

## Sweep, in order

1. **Inventory.** Every instruction file (CLAUDE.md / AGENTS.md, user-level and per-project),
   every tool config (`~/.claude/`: settings.json, settings.local.json, skills, hooks, commands;
   `~/.kimi-code/`: config.toml, skills/, hooks/, mcp.json; project `.claude/` and `.kimi-code/`),
   the memory directory and its index. Note line counts — they calibrate severity.
2. **Reality check (highest-value finding).** For every claim a doc makes about machinery —
   "a hook enforces X", "agents live in Y", "run harness Z" — verify the file exists and is
   wired (`settings.json` for Claude, `[[hooks]]` in `config.toml` for Kimi). Existence and
   wiring are necessary but **not sufficient**: then prove behavior from the context sessions
   actually launch in. Pipe-test the hook from the real working directory with a failing
   fixture and assert the block fires. A gate can be wired, tested, and firing on every Stop
   while its `./checks.sh` lookup resolves to nothing — because the launch convention changed
   after the gate was built (this kit shipped exactly that: per-project assumption, umbrella
   launches, total silence). Schedules get the same treatment: a plist on disk is not a loaded
   job (`launchctl list`). Documented-but-nonexistent enforcement is the #1 finding class: it
   teaches false confidence. Also the reverse: hooks that run but are re-described at length
   in prose (delete the prose, keep the hook).
3. **Staleness.** Model IDs and prices vs the current lineup — check the official model docs
   of whichever vendor the setup pins rather than trusting your own training-data memory of
   model names (which is the exact rot this step hunts); frozen point-in-time state in
   durable files (fixed checkpoint ranges, "already fixed, don't re-flag" lists, copied code
   snippets that drift from source); dates older than the last major model release.
4. **Weak-model boilerplate.** ALWAYS/NEVER caps, "CRITICAL: you MUST", step-by-step recipes,
   "think step by step", token-budget countdowns, temperature/prefill references. These degrade
   current models' output — flag for deletion, with the line quoted.
5. **Skills usage.** For each skill (both tools' skills dirs): is it referenced by
   commands/docs, or orphaned? If session transcripts are available (`~/.claude/projects/`,
   `~/.kimi-code/sessions/`), sample recent ones rather than scanning everything.
   Over ~500 lines is a smell; frozen exclusion lists inside skills are rot.
6. **Permissions.** Dead one-offs in allow lists (`settings.local.json` permissions,
   `[[permission.rules]]` in config.toml): specific PIDs, session-scoped tmp paths,
   malformed entries. For deny rules protecting files: check they exist at the directory
   sessions actually launch from.
7. **Memory.** Files missing from the index (invisible), state files contradicted by newer ones,
   design docs that belong in the repo, duplicates.
8. **Cross-harness drift.** The two contracts (working style, shared rules) should say the same
   thing in both tools; the dated models blocks may legitimately differ. Flag contradictions
   outside the dated blocks — e.g. a rule tightened in one contract and forgotten in the other.

## Report format

Ranked list, most damaging first. Per finding: file:line, what's wrong, the one-line fix,
severity (BROKEN-PROMISE / DEGRADES-OUTPUT / ROT / CRUFT). End with a deletion tally —
"X lines removable" is the headline metric of this skill.
