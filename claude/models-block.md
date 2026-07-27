## Models & effort — dated block, re-verify each major release (current: {{YYYY-MM}})
- Default: {{model}} at effort {{level}}. Reserve higher effort for capability-critical work.
- Subagents/workers: {{cheaper tier}}. Set `model:` explicitly on agent definitions — `inherit`
  silently bills at orchestrator rates.
- Fallback is automatic: set `fallbackModel: ["{{next-best}}", "default"]` in settings. If the
  swap engages, update this block's default line. Everything outside this block applies unchanged.
