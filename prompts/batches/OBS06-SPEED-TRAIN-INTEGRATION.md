<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBS06-SPEED-TRAIN-INTEGRATION

# Allowed Scope

- `Makefile` (add OpenAI docs/tooling targets)
- `docs/codex/CODEX_OS_INDEX.md` (tooling index note)
- `docs/audits/openai-build-suite-install-report.md`
- `scripts/openai-build-suite-validate.py`
- `scripts/openai-build-suite-dry-run.py`

# Forbidden Scope

- any PK28 implementation files
- hosted AI runtime integration
- signed/CI/readiness behavior changes

# Objective

Add safe make targets and finalize validation/report updates for OpenAI build suite install.

# Validation

- `make batch-self-check`
- `make prompt-audit`
- `python3 -m py_compile scripts/openai-build-suite-validate.py scripts/openai-build-suite-dry-run.py scripts/ambitions-prompt-queue-consistency.py tools/openai/repo_brain/build_repo_manifest.py tools/openai/repo_brain/query_repo_brain.py tools/openai/evals/run_evals.py tools/openai/evals/score_reports.py tools/openai/prompt_repair/repair_batch_prompt.py tools/openai/batch_report/summarize_batch_report.py tools/openai/batch_report/classify_batch_result.py tools/openai/visual_critique/critique_visual_packet.py tools/openai/launch_docs/generate_launch_packet.py`
- `python3 scripts/openai-build-suite-validate.py`
- `python3 scripts/openai-build-suite-dry-run.py`
- `python3 scripts/ambitions-prompt-queue-consistency.py PK28`

# Rollback

`git restore --staged -- Makefile docs/codex/CODEX_OS_INDEX.md docs/audits/openai-build-suite-install-report.md`

# No-Claim Policy

No global-train completion, accessibility, privacy/legal, or release readiness claims.
