## Models & effort — dated block, re-verify each major release (current: {{YYYY-MM}})
- Default: {{model alias from config.toml}} at effort {{level}}. Reserve cheaper tiers (`/model`
  or `-m`) for routine work; raise effort only for capability-critical work.
- No automatic fallback: Kimi Code has no `fallbackModel` equivalent. If the default model is
  unavailable or flagged, switch manually with `/model` and update this block's default line.
  Everything outside this block applies unchanged.
- Subagent cheap-tier wiring (`[secondary_model]`) is experimental and ignored by the interactive
  TUI — prose intent only; revisit each release.
