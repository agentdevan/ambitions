<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM

# Allowed Scope

- `docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md`
- `tools/openai/config/codex_agent_roles.json`

# Forbidden Scope

- `Native/Ambitions/**`
- `Package.swift`
- `project.yml`
- `OpenAI` runtime dependency in app targets

# Objective

Finalize local multi-agent build orchestration documentation and role model.

# Validation

- `make batch-self-check`
- `make prompt-audit`
- `python3 scripts/openai-build-suite-validate.py`
- `python3 tools/openai/repo_brain/build_repo_manifest.py --dry-run`

# Rollback

`git restore --staged -- docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md tools/openai/config/codex_agent_roles.json` and keep the run clean.

# No-Claim Policy

No core runtime, release, accessibility, privacy, performance, or TestFlight claims.
