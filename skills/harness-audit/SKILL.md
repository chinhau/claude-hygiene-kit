---
name: harness-audit
description: Audit an existing Claude Code setup and report what to DELETE or fix — stale model references, prescriptive boilerplate, unwired enforcement, dead permissions, orphaned memories. Use when the user asks to clean up, review, or modernize their Claude config, or feels their setup is bloated.
---

# Harness audit

Most Claude setups accrete: rules written for older models, hooks documented but never wired,
permissions from dead one-off sessions. This skill finds what to remove. Output is a ranked
report (assessment first — do not edit anything until asked).

## Sweep, in order

1. **Inventory.** Every CLAUDE.md (user-level and per-project), every `.claude/` directory
   (settings, skills, agents, hooks, commands), the memory directory and its index. Note line
   counts — they calibrate severity.
2. **Reality check (highest-value finding).** For every claim a doc makes about machinery —
   "a hook enforces X", "agents live in Y", "run harness Z" — verify the file exists and is
   wired in settings. Documented-but-nonexistent enforcement is the #1 finding class: it teaches
   false confidence. Also the reverse: hooks that run but are re-described at length in prose
   (delete the prose, keep the hook).
3. **Staleness.** Model IDs and prices vs the current lineup — check the official model docs
   for the lineup rather than trusting your own training-data memory of model names (which is
   the exact rot this step hunts); frozen point-in-time state in
   durable files (fixed checkpoint ranges, "already fixed, don't re-flag" lists, copied code
   snippets that drift from source); dates older than the last major model release.
4. **Weak-model boilerplate.** ALWAYS/NEVER caps, "CRITICAL: you MUST", step-by-step recipes,
   "think step by step", token-budget countdowns, temperature/prefill references. Per current
   Anthropic guidance these degrade output — flag for deletion, with the line quoted.
5. **Skills usage.** For each skill: is it referenced by commands/docs, or orphaned? If session
   transcripts are available (`~/.claude/projects/<project>/`), sample recent ones rather than
   scanning everything. Over ~500 lines is a smell; frozen exclusion lists inside skills are rot.
6. **Permissions.** Dead one-offs in allow lists (specific PIDs, session-scoped tmp paths,
   malformed entries). For deny rules protecting files: check they exist at the directory
   sessions actually launch from.
7. **Memory.** Files missing from the index (invisible), state files contradicted by newer ones,
   design docs that belong in the repo, duplicates.

## Report format

Ranked list, most damaging first. Per finding: file:line, what's wrong, the one-line fix,
severity (BROKEN-PROMISE / DEGRADES-OUTPUT / ROT / CRUFT). End with a deletion tally —
"X lines removable" is the headline metric of this skill.
