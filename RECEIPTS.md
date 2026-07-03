# Receipts — every rule with its evidence

This file is for humans, not for Claude's context. No rule without evidence; dated items should
be re-verified each major model release. (Last verified: 2026-07.)

## Prompting & config
- **Brief intent + explicit boundaries beats enumeration.** Current models follow instructions
  literally; per-behavior rules written for weaker models degrade output — Anthropic's
  [Fable 5 prompting guidance](https://platform.claude.com/docs) says over-prescriptive prompts
  "cap its quality" and skills for prior models "can degrade output quality". Community version:
  [only 8 of 31 installed skills survived an audit](https://medium.com/data-science-collective/the-8-skills-every-claude-code-setup-needs-in-2026-eb7e72cbf91f);
  in one audited 54-skill setup, 11 accounted for all usage.
- **Skills under ~500 lines, ideally one screen.** Goal, rationale, boundaries, verification
  hook — not recipes. Unused skill descriptions are context tax charged every turn.
- **No pressure language.** "CRITICAL: you MUST" style over-triggers the instructed behavior
  (the model over-fires the tool or skill being emphasized) and doesn't improve compliance.
- **Never embed point-in-time state in durable files** (fixed checkpoint ranges, "already
  fixed, don't re-flag" lists, copied code snippets). They rot silently; point to the living source.
- **Effort: start at `high` and sweep upward only when the task demonstrably needs it.**
  `max` is documented as prone to overthinking. Orchestrators high, worker agents cheap — and
  set `model:` explicitly on agent definitions: omitted means
  [`inherit`](https://code.claude.com/docs/en/sub-agents), which silently bills workers at
  orchestrator rates.

## Enforcement
- **Hooks over prose.** A [Stop hook](https://code.claude.com/docs/en/hooks) that runs your
  checks blocks a bad close deterministically; a CLAUDE.md paragraph asking nicely does not.
- **Test the hook the day you write it.** "Hook not firing" is a large open-issue cluster
  ([#29767](https://github.com/anthropics/claude-code/issues/29767),
  [#37559](https://github.com/anthropics/claude-code/issues/37559),
  [#40029](https://github.com/anthropics/claude-code/issues/40029)) — and a hook you believe
  runs but doesn't is worse than none. This kit's gate ships with `test-gate.sh` covering
  pass, block, loop-guard, huge-output, and missing-jq paths.
- **Fail loud, never open.** The failure modes our own red-team found in a naive gate: missing
  `jq` (silent pass), multi-MB check output exceeding ARG_MAX (silent pass), wrong cwd (silent
  pass), CRLF checkout (blocks every stop). All five are covered by the shipped gate + tests +
  `.gitattributes`.
- **Permission deny rules for never-hand-edit files** — added where sessions actually *launch*
  from: project settings only load for sessions started in that directory.

## Resilience
- **`fallbackModel` in settings = automatic survival** of model retirement and outages
  ([settings docs](https://code.claude.com/docs/en/settings); shipped v2.1.166, June 2026).
  Manual swap instructions in a doc are what you have when you forget to set this.
- **One dated model block per file.** Everything else stays model-agnostic so a model ban or
  release day is a one-block edit.
- **In your own API code:** handle `stop_reason: "refusal"` (arrives as HTTP 200); on the
  newest models (Fable 5, Opus 4.7+, Sonnet 5) don't set `temperature`/`top_p` or use assistant
  prefill (HTTP 400) — older 4.6-generation models still accept temperature.

## Memory & state
- **One lesson per file, indexed, updated not duplicated, deleted when wrong.** An unindexed
  memory is invisible; a stale one is misinformation.
- **Session-end ritual:** if state changed or a lesson was learned, write it before closing.

## Against overload
- **Awareness on a schedule, not on impulse.** A weekly diff of the
  [official changelog](https://code.claude.com/docs/en/changelog) against your actual usage
  replaces doomscrolling. Ten minutes, three buckets: ACT / CONSIDER / IGNORE.
- **Adopt on evidence of need, not availability.** The question is never "is this capability
  good" — it's "which recurring task of mine does it remove." The creator of Claude Code
  [runs a near-vanilla setup](https://x.com/bcherny/status/2007179832300581177).
