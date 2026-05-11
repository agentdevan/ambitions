# Ambitions .codex AGENTS

The `.codex` directory is local control-plane configuration.

- Hooks and rules are local command guardrails, not security substitutes.
- No secrets, API keys, credentials, or network calls in `.codex` scripts/config.
- All hook and rule behavior must be local-only and deterministic.
- Guardrails should be transparent, additive, and reversible.
- Hook bypasses and failures should be explicit and visible in final status reporting.
