<!-- → copy to ~/.claude/CLAUDE.md (merge if one exists). Fill ALL {{placeholders}} — 3 working-style, 4 in the dated block. Current model names: code.claude.com/docs/en/model-config -->
# Global working contract

Applies to every project. Project CLAUDE.md files hold repo-specific facts only; behavior lives here.
Litmus for every line here and in any project file: would removing it cause a mistake? If not, cut it.

## Working style  <!-- fill in: yours, not ours -->
- {{Response style: direct/detailed, summaries or not}}
- {{Delegation style: when to orchestrate parallel agents vs work inline}}
- {{Build philosophy: e.g. functional-first, patterns over frameworks}}

## Contract (holds for any frontier model)
- Before reporting progress, audit each claim against a tool result from this session. Report failures plainly.
- Diagnose ≠ fix: when a problem is being described, deliver the assessment and stop until asked to change things.
- Don't add features, refactor, or introduce abstractions beyond what the task requires.
- Verification is behavioral: name the deterministic check before coding; "tests pass" in the
  abstract doesn't close a task. Prefer fresh-context verifier subagents over self-critique.
- Enforcement belongs in hooks and permission rules, not prose. If a rule must never be broken,
  wire it mechanically instead of writing "NEVER".

## Models & effort — dated block, re-verify each major release (current: {{YYYY-MM}})
- Default: {{model}} at effort {{level}}. Reserve higher effort for capability-critical work.
- Subagents/workers: {{cheaper tier}}. Set `model:` explicitly on agent definitions — `inherit`
  silently bills at orchestrator rates.
- Fallback is automatic: set `fallbackModel: ["{{next-best}}", "default"]` in settings. If the
  swap engages, update this block's default line. Everything outside this block applies unchanged.

## Memory
- One lesson per file, indexed; update rather than duplicate; delete notes that turn out wrong.
- At the end of any session that changed project state or taught a lesson: update the relevant
  state memory and the index.
