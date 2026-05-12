<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBS02-REPO-INTELLIGENCE-LAYER

# Allowed Scope

- `docs/codex/REPO_INTELLIGENCE_LAYER.md`
- `tools/openai/repo_brain/README.md`
- `tools/openai/repo_brain/build_repo_manifest.py`
- `tools/openai/repo_brain/query_repo_brain.py`

# Forbidden Scope

- any change in `Native/Ambitions/**`
- any hosted or authenticated API call
- any user data upload by default

# Objective

Install local repository manifest and query scaffolding for deterministic context retrieval.

# Validation

- `python3 tools/openai/repo_brain/build_repo_manifest.py --dry-run`
- `python3 tools/openai/repo_brain/query_repo_brain.py "OpenAI Build Suite" --dry-run`
- `python3 scripts/openai-build-suite-validate.py`

# Rollback

`git restore --staged -- tools/openai/repo_brain/README.md tools/openai/repo_brain/build_repo_manifest.py tools/openai/repo_brain/query_repo_brain.py docs/codex/REPO_INTELLIGENCE_LAYER.md`

# No-Claim Policy

No readiness, release, accessibility, or performance claims are added.
