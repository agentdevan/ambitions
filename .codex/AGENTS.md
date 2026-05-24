# Ambitions .codex AGENTS

The `.codex` directory is local control-plane configuration.

- Hooks and rules are local command guardrails, not security substitutes.
- No secrets, API keys, credentials, or network calls in `.codex` scripts/config.
- All hook and rule behavior must be local-only and deterministic.
- Guardrails should be transparent, additive, and reversible.
- Hook bypasses and failures should be explicit and visible in final status reporting.

## Local Repo Intelligence

- iOS 26 train execution starts from `scripts/ios26-flagship-run-sequential.sh` unless explicitly directed otherwise.
- CodeGraph and Semble may be used only as advisory local developer tooling when already installed.
- Understand Anything is sandbox/human architecture context only; never proof, source truth, or a runner gate.
- Important advisory findings must resolve to concrete repo paths and be verified through direct file inspection, validation output, tests, or existing Ambitions proof artifacts.
- Never commit `.codegraph/`, `.understand-anything/`, `.codex/local-indexes/`, `.codex/repo-intelligence/tools/`, `.codex/repo-intelligence/generated/`, or `.codex/repo-intelligence/tmp/`.
