<!-- Produced with this kit's harness-audit skill (skills/harness-audit/SKILL.md), 2026-07-03.
     Reproducible: findings quote file:line against the pinned commit below. -->

# Harness Audit: SuperClaude_Framework (v4.3.0)

**Repo:** github.com/SuperClaude-Org/SuperClaude_Framework, cloned at commit `226c45c` (2026-04-26).

## Methodology

Sweep per `harness-audit` SKILL.md: inventory → reality check → staleness → boilerplate → usage signals → frozen state. Scope is the shipped Claude-context payload only (plugin + pip-installed markdown/JSON), not installer source. Model-ID staleness was checked by grep across the full payload: **no Claude model IDs or prices are pinned anywhere**, so there was nothing to compare against the current lineup — a point in the framework's favor. Note on framing: volume ≠ malice — most of this content predates current anti-scaffolding guidance, and the observed patterns (symbol compression, MANDATORY caps, behavioral rulebooks) were mainstream practice when written.

## Inventory (plugin payload — the primary install path)

| Component | Files | Lines | Loaded by plugin.json? |
|---|---|---|---|
| `commands/` | 30 .md | 4,604 | Yes (on invocation) |
| `agents/` | 20 .md | 2,134 | Yes |
| `skills/` | 6 skills | 659 | Yes |
| `hooks/hooks.json` + `scripts/` | 2 | 233 | Yes |
| `.mcp.json` | 1 | 12 | Yes (2 servers) |
| `core/` (RULES, PRINCIPLES, FLAGS, …) | 6 .md | 1,412 | **No** |
| `modes/` (7 MODE_*.md) | 7 .md | 714 | **No** |
| `mcp/` (8 MCP_*.md + 8 configs) | 16 | 582 | **No** |
| `examples/` | 1 .md | 494 | **No** |
| **Total** | ~87 | **~10,400** | |

The pip path (`superclaude install`) installs only commands, agents, skills, and opt-in MCP configs (`src/superclaude/cli/main.py`, `install_commands.py`) — it, too, never installs `core/`, `modes/`, or `mcp/*.md`.

## Findings

### BROKEN-PROMISE

1. **`core/`, `modes/`, `mcp/*.md`, `examples/` are shipped but unreachable in every install path** (~3,200 lines, 22 md files). `plugin.json` declares only `commands/agents/skills/hooks/mcpServers`; the pip installer copies neither directory; and zero commands/agents/skills reference them (grep for `RULES.md|PRINCIPLES.md|FLAGS.md|MODE_|RESEARCH_CONFIG` across the load path returns nothing). Yet `plugin.json:5` sells them: `"description": "…30 commands, 20 agents, 7 modes, confidence checks…"`. The 7 modes cannot activate. Fix: delete or wire via skills.
2. **Auto-activation claims no machinery supports.** `agents/pm-agent.md:10`: `- **Session Start (MANDATORY)**: ALWAYS activates to restore context from Serena MCP memory` — Claude Code agents are invoked, they do not self-activate at session start, and Serena is not among the two servers `.mcp.json` configures. Same claim in `commands/pm.md:15` and `skills/pm/SKILL.md:3` ("Auto-activates at session start").
3. **Commands depend on MCP servers the plugin doesn't ship.** `plugins/superclaude/.mcp.json` configures only `context7` and `sequential-thinking`, but commands reference Serena 51×, Magic 40×, Morphllm 22×, Playwright 25×, Tavily 6× — e.g. `commands/load.md:24`: `1. **Initialize**: Establish Serena MCP connection and session context management`. Fix: state the dependency as optional per command, or add the servers.
4. **`src/superclaude/hooks/hooks.json` can't run and has drifted from its twin.** It registers `"command": "./scripts/session-init.sh"` — a cwd-relative path that resolves nowhere for an installed user — and the pip installer never installs hooks at all. `hooks/README.md` promises: `Both locations must stay in sync` — they are not: the plugin copy adds `Stop` and `PostToolUse` hooks and uses `${CLAUDE_PLUGIN_ROOT}`; timeouts differ (10 vs 10000).
5. **Dead frontmatter machinery.** 41 commands declare `personas: [architect, frontend, backend, security, qa-specialist]` and `mcp-servers: […]` (e.g. `commands/implement.md:6-7`) — neither is a Claude Code command frontmatter field, and no agent files named `architect`/`frontend`/`qa-specialist` exist (agents are `backend-architect` etc.).
6. **`session-init.sh` reports unverified status.** It unconditionally prints `✅ Confidence Check (pre-implementation validation)… ✅ Deep Research… ✅ Repository Index` at every session start with no check that any of these are installed.

### DEGRADES-OUTPUT

7. **`commands/recommend.md` — 1,005 lines of pseudo-executable decision machinery.** Includes a fake Python `detect_language_and_translate()` (lines 46-57) and a `turkish_keywords` map whose values are English words (lines 23-30). None of it executes; it is prompt text.
8. **Imperative-caps boilerplate throughout.** `core/RULES.md:57`: `**Batch Operations**: ALWAYS parallel tool calls by default, sequential ONLY for dependencies`; `RULES.md:53`: `Maintain ≥90% understanding across operations` (unmeasurable); 8 commands carry identical `## CRITICAL BOUNDARIES` blocks; every command opens with a 5-step `## Behavioral Flow` recipe (25 occurrences).
9. **Token-budget/compression language.** `modes/MODE_Token_Efficiency.md:14`: `30-50% token reduction while preserving ≥95% information quality`, plus a 3-table symbol-substitution legend (`∴`, `∵`, `»`); `commands/help.md`: `--think … (~4K tokens)`, `--ultrathink … (~32K tokens)` — no mechanism maps these flags to thinking budgets.

### ROT

10. **`src/` and `plugins/` are diverging duplicates.** 14 command files already differ between the two full copies of the payload; the drift contradicts the README's sync requirement (finding 4).
11. **Frozen point-in-time claims in durable files.** `skills/confidence-check/SKILL.md:14`: `**Test Results** (2025-10-21): Precision: 1.000… 8/8 test cases passed` and `:124`: `**Success Rate**: 100% precision and recall in production testing` — a frozen 8-case result stated as a permanent guarantee. `core/RULES.md:229` hardcodes `"Today is 2025-08-15"` inside a rule about *not* assuming dates.
12. **`/sc:help` is stale against the shipped set.** It lists 24 commands; 30 ship. Missing: `agent`, `index-repo`, `pm`, `recommend`, `research`, `sc`.
13. **Repo-root state files are frozen** (contributor-facing; loaded only on clone): `TASK.md:8` `Last Updated: 2025-11-12`, `TASK.md:345` `Next Review Date: 2025-11-19`, `PROJECT_INDEX.md:3` `Generated: 2025-10-29` — all ~8 months old.

### CRUFT

14. `skills/confidence-check/confidence.ts` — "reference" TypeScript shipped inside the skill; the runtime implementation is Python (`src/superclaude/pm_agent/confidence.py`). Four copies of `confidence.ts` exist in the repo.
15. `plugins/superclaude/mcp/configs/*.json` (8 files) — consumed only by the pip CLI; dead weight in the plugin copy.
16. Root drift artifacts shipped in the package: `DELETION_RATIONALE.md`, `QUALITY_COMPARISON.md`, `PARALLEL_INDEXING_PLAN.md`, `PR_DOCUMENTATION.md`, `TEST_PLUGIN.md`.

## What's genuinely good

- **No pinned model IDs or prices anywhere in the payload** — the single most common staleness failure, fully avoided.
- **The 6 plugin skills are the right shape**: `skills/pm/SKILL.md` (54 lines), `brainstorm` (44), `troubleshoot` (40) are concise, trigger-described, and correctly use `$ARGUMENTS` — they do in ~330 lines what `core/` + `modes/` attempt in 2,100.
- **Commands and agents load lazily** (invocation-time), so the 6,700 lines of commands/agents are not a per-session context tax.
- **`RULES.md:150`** bans marketing language ("Never use 'blazingly fast', '100% secure'") — sound guidance, even though `README.md` and the confidence-check skill's own "100% precision" claim don't follow it.
- The plugin copy of `hooks.json` uses `${CLAUDE_PLUGIN_ROOT}` correctly, and the `Stop`/`PostToolUse` prompt hooks are reasonable uses of the hook system.

## Deletion tally

**≈3,200 of ~10,400 plugin-payload lines (31%) are unreachable by any install path — 22 markdown components unreferenced** (`core/` 1,412, `modes/` 714, `mcp/*.md` 498, `examples/` 494, plus 8 orphaned config JSONs). Beyond that, ~1,400 loaded-on-invocation lines are flagged DEGRADES-OUTPUT for trimming (`recommend.md` 1,005; repeated CRITICAL BOUNDARIES / Behavioral Flow blocks; token-compression tables), and the entire `src/`↔`plugins/` duplication doubles maintenance surface. Net: roughly **4,600 lines removable or consolidable without losing any wired behavior**.
