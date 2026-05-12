<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

OBS03-OPENAI-EVAL-QA-LAYER

# Allowed Scope

- `docs/codex/OPENAI_EVAL_QA_LAYER.md`
- `tools/openai/evals/README.md`
- `tools/openai/evals/README.md`
- `tools/openai/evals/datasets/*.jsonl`
- `tools/openai/evals/run_evals.py`
- `tools/openai/evals/score_reports.py`

# Forbidden Scope

- live Evals API calls
- runtime scoring claims without proof

# Objective

Add deterministic eval QA dataset shape validation and local scoring helpers.

# Validation

- `python3 tools/openai/evals/run_evals.py --dry-run`
- `python3 tools/openai/evals/score_reports.py tools/openai/evals/datasets/batch_quality.jsonl`
- `python3 scripts/openai-build-suite-validate.py`

# Rollback

`git restore --staged -- docs/codex/OPENAI_EVAL_QA_LAYER.md tools/openai/evals tools/openai/evals/datasets`

# No-Claim Policy

No automated quality or product acceptance claims without explicit proof outside this scaffolding.
