# Ambitions Hook Policy

This directory defines local repository guardrails via `.codex/hooks` and registers them through `.codex/hooks.json`.

## Hooks

- `session_start_context.py` adds run context for runner-first and no-cost boundaries.
- `user_prompt_submit_guard.py` blocks high-risk Ambitions control-plane prompts that are not runner-gated.
- `pre_tool_use_policy.py` blocks forbidden commands for Bash before execution.
- `permission_request_guard.py` mirrors high-risk denial for requested permissions.
- `post_tool_use_review.py` injects reminders when risky tooling runs or failures occur.
- `stop_gate.py` validates final report shape before completion.

## Activation

Hooks are enabled via `.codex/config.toml` under `[features]` with `hooks = true`. Hook handlers are declared in `.codex/hooks.json`, which points to the repo-local Python scripts.

## Operational notes

- Hooks are best-effort guardrails; they do not replace `scripts/ambitions-codex-os-validate.py` and proof reporting.
- Hooks are local-only; they do not call external services or write outside `.codex` and repo root.
- Do not treat a passed hook as proof of compliance.
