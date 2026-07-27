# Claude Code — install

The Claude side of the kit. Philosophy and the audit live at the repo root; this is the
wiring. Prerequisites: Claude Code, `bash`, `jq` (the gate refuses to run without it — loudly,
not silently).

## Quickstart

1. **Global contract** — `cp claude/CLAUDE.md ~/.claude/CLAUDE.md` (merge, don't overwrite, if
   one exists). Fill **all seven** `{{placeholders}}`: three working-style lines and the dated
   models block. Current model names live in the [model config docs](https://code.claude.com/docs/en/model-config) —
   deliberately not hardcoded here.
   (`claude/CLAUDE.md` is generated — to change the shared core, edit `shared/contract-core.md`;
   for the dated block, `claude/models-block.md`; then run `scripts/sync-contract.sh`.)
2. **Automatic model fallback** — in `~/.claude/settings.json` (create it if absent):
   ```json
   { "model": "<your-pin>", "fallbackModel": ["<next-best>", "default"] }
   ```
3. **Per project** — note the trailing `/.` (a `*` glob silently drops the hidden `.claude/`,
   and with it the enforcement):
   ```bash
   cp -r claude/project-template/. myproject/
   mv myproject/CLAUDE.md.template myproject/CLAUDE.md   # fill its placeholders
   # put your real verify command(s) in myproject/checks.sh, then prove the gate works:
   cd myproject && bash .claude/hooks/test-gate.sh        # expect: ALL PASS
   ```
   Silence from the gate means "checks green or nothing configured" — a `decision: block` JSON
   means the gate works and your checks currently fail. Both prove the wiring.
4. **Weekly capability watch** — run `/schedule` (or a local `/loop`) and paste the prompt from
   `claude/routines/capability-watch.md`, cadence weekly. See that file's note on cloud vs
   local execution, and MAINTENANCE.md for the launchd option.

## What goes where

| Source | Destination | What it is |
|---|---|---|
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | The one behavioral contract, every session |
| `claude/project-template/.` | `<your-project>/` | Thin CLAUDE.md + tested Stop gate + checks.sh |
| `shared/skills/harness-audit/` | `~/.claude/skills/` | The deletion auditor — the reason this kit exists |
| `claude/routines/capability-watch.md` | your scheduler | Weekly ACT / CONSIDER / IGNORE changelog triage |
| `../RECEIPTS.md` | (for humans) | Every rule with its evidence — not config |
