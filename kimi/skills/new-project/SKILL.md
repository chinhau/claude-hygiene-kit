---
name: new-project
description: Scaffold a new (or existing) project with the standard structure — thin AGENTS.md, checks.sh wired to the global Stop gate, shared memory. Use when the user says "new project", "start a project", or asks to apply the standard structure to a folder.
---

# New-project scaffold (Kimi Code)

Stamps the layered docs architecture onto a project: global contract (`~/.kimi-code/AGENTS.md`)
→ thin project AGENTS.md (repo facts only) → checks.sh + the global Stop gate for enforcement
→ shared memory for state. Ask only for what's missing: project name/path, stack, and the
**verify command** — the single command that proves the project works (tests, build, or both).

Key difference from the Claude version: Kimi has no project-level settings file. The Stop gate
is one global `[[hooks]]` entry (already installed); a project opts in simply by having a
`checks.sh`. Nothing per-project to wire. One integration detail: sessions launch from
`~/personal_project`, so the gate's `./checks.sh` resolves to the umbrella dispatcher there
(`~/personal_project/checks.sh`, installed once from this kit's `kimi/checks.sh`), which runs
every sub-project's `checks.sh`. A sub-project's checks reach the gate only through that
dispatcher — if it's missing, nothing is gated.

## Steps

1. Create the directory under `~/personal_project` (or use the existing one). `git init` unless
   told otherwise.
2. Copy from this skill's `templates/` directory and fill in:
   - `AGENTS.md.template` → `<project>/AGENTS.md` — purpose, commands, hard rules. Under 50
     lines, repo facts only; no behavioral prose (that's the global contract's job). Litmus:
     would removing this line cause a mistake? If not, cut it.
   - `checks.sh` → `<project>/checks.sh` (`chmod +x`; put the real verify command(s) in it).
3. Verify the wiring before calling it done: run `bash checks.sh` once for real, then pipe-test
   the gate from the project root:
   `printf '{"hook_event_name":"Stop","session_id":"manual-test","cwd":"%s"}' "$PWD" | bash ~/.kimi-code/hooks/gate.sh`
   — it must stay silent (exit 0) on green checks, and exit 2 with the failure output on stderr
   when checks fail. Note the loop guard: an identical failure blocks only once per session;
   change the failure text when re-testing a block.
4. If the project has generated artifacts that must never be hand-edited, add a deny rule to
   `[[permission.rules]]` in `~/.kimi-code/config.toml` (user-level — there is no project
   scope, so make the pattern path-specific, e.g. `Edit(*/<project>/<file>)`).
5. Create a `<project>-state` memory with purpose and status; add its line to MEMORY.md.
6. Report what was created and note the convention: launch `kimi` from `~/personal_project`
   so sessions share one scope; the umbrella `checks.sh` there dispatches to every sub-project,
   so a project is gated the moment it has a real checks.sh. If the umbrella dispatcher is
   missing, install it once: `cp kimi/checks.sh ~/personal_project/checks.sh`.
