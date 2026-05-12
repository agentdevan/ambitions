<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER

# Allowed Scope

- `docs/codex/PROMPT_REPAIR_LAYER.md`
- `docs/codex/BATCH_REPORT_LAYER.md`
- `tools/openai/prompt_repair/README.md`
- `tools/openai/prompt_repair/repair_batch_prompt.py`
- `tools/openai/batch_report/summarize_batch_report.py`
- `tools/openai/batch_report/classify_batch_result.py`

# Forbidden Scope

- queue/PK modifications outside OBS
- runtime dependency edits

# Objective

Complete prompt repair and batch report parsing scaffolds.

# Validation

- `python3 scripts/ambitions-prompt-queue-consistency.py PK28`
- `python3 tools/openai/prompt_repair/repair_batch_prompt.py prompts/batches/OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER.md --dry-run`
- `python3 tools/openai/batch_report/summarize_batch_report.py docs/audits/openai-build-suite-install-report.md`
- `python3 tools/openai/batch_report/classify_batch_result.py docs/audits/openai-build-suite-install-report.md`

# Rollback

`git restore --staged -- docs/codex/PROMPT_REPAIR_LAYER.md docs/codex/BATCH_REPORT_LAYER.md tools/openai/prompt_repair tools/openai/batch_report`

# No-Claim Policy

No claims on completeness of app behavior are introduced here.
