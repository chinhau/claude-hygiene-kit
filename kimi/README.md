# Kimi Code — the hygiene kit's second harness

Same three principles, different file locations. The contract content is tool-agnostic by
design; what changes is where things live and which mechanisms exist. Researched against the
official docs (kimi.com/code/docs/en/) 2026-07 — re-verify after major releases.

## What maps to what

| Claude Code | Kimi Code | Notes |
|---|---|---|
| `~/.claude/CLAUDE.md` | `~/.kimi-code/AGENTS.md` | Also honored: `~/.agents/AGENTS.md` (cross-tool). No auto-import |
| `settings.json` | `~/.kimi-code/config.toml` | Validate with `kimi doctor`; `/reload` applies without restart |
| settings.json hooks | `[[hooks]]` in config.toml | Same events (`Stop`, `PreToolUse`…), same exit codes (0 allow / 2 block / else fail-open) |
| per-project `.claude/settings.json` | **does not exist** | One global Stop gate defers to `./checks.sh`; under umbrella launches that's the `~/personal_project/checks.sh` dispatcher |
| `~/.claude/skills/` | `~/.kimi-code/skills/` | Same SKILL.md + frontmatter format, near drop-in |
| permissions allow/deny/ask | `[[permission.rules]]` | Ordered, first match wins |
| `fallbackModel` | **no equivalent** | Switch with `/model`; re-verify the dated block instead |
| subagent `model:` billing | `[secondary_model]` | Experimental, TUI ignores it — not wired |
| `stop_hook_active` loop guard | **no equivalent** | gate.sh uses a TMPDIR marker keyed on output hash + session_id |
| weekly routine via `/schedule` | session crons expire in 7 days | Real scheduling must be external: launchd + `kimi -p` (below) |

## Install

```bash
# 1. Global contract — fill the placeholders (3 working-style lines + date)
#    (AGENTS.md.template is generated: to change the shared core edit
#     shared/contract-core.md, for the dated block kimi/models-block.md,
#     then run scripts/sync-contract.sh)
cp kimi/AGENTS.md.template ~/.kimi-code/AGENTS.md

# 2. Stop gate
mkdir -p ~/.kimi-code/hooks
cp kimi/hooks/gate.sh ~/.kimi-code/hooks/ && chmod +x ~/.kimi-code/hooks/gate.sh
# then add to ~/.kimi-code/config.toml (absolute path — no ~ expansion):
#   [[hooks]]
#   event = "Stop"
#   command = "bash /Users/<you>/.kimi-code/hooks/gate.sh"
#   timeout = 300
# prove it: bash kimi/hooks/test-gate.sh   (expect: ALL PASS)

# 2b. Umbrella checks — sessions launch from ~/personal_project, so the gate's
#     ./checks.sh resolves there, not to a sub-project. This dispatcher runs
#     every sub-project's checks.sh; without it, nothing is ever gated:
cp kimi/checks.sh ~/personal_project/checks.sh && chmod +x ~/personal_project/checks.sh

# 3. Skills
cp -r kimi/skills/new-project ~/.kimi-code/skills/
cp -r kimi/skills/capability-watch ~/.kimi-code/skills/
# harness-audit (dual-harness, lives in shared/):
cp -r shared/skills/harness-audit ~/.kimi-code/skills/

# 4. Weekly capability watch — fill {{REPO_DIR}} and {{KIMI_BIN_DIR}} in the plist, then:
cp kimi/capability-watch/com.user.kimi-capability-watch.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.kimi-capability-watch.plist
# reports land in kimi/capability-watch/reports/ and are committed — read the weekly diff.
```

## Files

| Source | Destination | What it is |
|---|---|---|
| `AGENTS.md.template` | `~/.kimi-code/AGENTS.md` | The one behavioral contract, every session |
| `hooks/gate.sh` + `hooks/test-gate.sh` | `~/.kimi-code/hooks/` | Stop gate: blocks turn end while `checks.sh` fails |
| `checks.sh` | `~/personal_project/checks.sh` | Umbrella dispatcher: runs every sub-project's checks.sh |
| `skills/new-project/` | `~/.kimi-code/skills/` | Project scaffolder (thin AGENTS.md + checks.sh) |
| `skills/capability-watch/` | `~/.kimi-code/skills/` | Weekly ACT / CONSIDER / IGNORE triage of the Kimi changelog |
| `capability-watch/` + `doctor-live.sh` | launchd | L2 scheduled run + L1 live-wiring tripwire; reports committed under `reports/` |
