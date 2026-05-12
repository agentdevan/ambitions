# OpenAI Build Suite Install Report

## Status

STATUS: YELLOW

## Files Created/Updated

- docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md
- docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md
- docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md
- docs/codex/REPO_INTELLIGENCE_LAYER.md
- docs/codex/OPENAI_EVAL_QA_LAYER.md
- docs/codex/PROMPT_REPAIR_LAYER.md
- docs/codex/BATCH_REPORT_LAYER.md
- docs/codex/VISUAL_CRITIQUE_LAYER.md
- docs/codex/LAUNCH_DOCUMENTATION_LAYER.md
- docs/codex/CODEX_OS_INDEX.md
- tools/openai/README.md
- tools/openai/config/ambitions_openai_build_policy.json
- tools/openai/config/redaction_rules.json
- tools/openai/config/codex_agent_roles.json
- tools/openai/repo_brain/README.md
- tools/openai/repo_brain/build_repo_manifest.py
- tools/openai/repo_brain/query_repo_brain.py
- tools/openai/evals/datasets/batch_quality.jsonl
- tools/openai/evals/datasets/claim_safety.jsonl
- tools/openai/evals/datasets/visual_canon.jsonl
- tools/openai/evals/README.md
- tools/openai/evals/run_evals.py
- tools/openai/evals/score_reports.py
- tools/openai/prompt_repair/README.md
- tools/openai/prompt_repair/repair_batch_prompt.py
- tools/openai/batch_report/README.md
- tools/openai/batch_report/summarize_batch_report.py
- tools/openai/batch_report/classify_batch_result.py
- tools/openai/visual_critique/README.md
- tools/openai/visual_critique/rubrics/ambitions_visual_canon.json
- tools/openai/visual_critique/critique_visual_packet.py
- tools/openai/launch_docs/README.md
- tools/openai/launch_docs/generate_launch_packet.py
- scripts/openai-build-suite-validate.py
- scripts/openai-build-suite-dry-run.py
- scripts/ambitions-prompt-queue-consistency.py
- prompts/batches/OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM.md
- prompts/batches/OBS02-REPO-INTELLIGENCE-LAYER.md
- prompts/batches/OBS03-OPENAI-EVAL-QA-LAYER.md
- prompts/batches/OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER.md
- prompts/batches/OBS05-VISUAL-CRITIQUE-LAUNCH-DOCS-LAYER.md
- prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md
- Makefile

## Policy Summary

- Dev-only OpenAI usage is supported.
- Native runtime remains OpenAI-free.
- No key material is added in OBS scope files.
- No app networking calls or SDK runtime adoption in this batch.

## Validation Commands and Exit Codes

```text
1) git status --short                                                       : 0
2) git diff --check                                                         : 0
3) make batch-self-check                                                    : 0
4) make prompt-audit                                                        : 0
5) python3 -m json.tool tools/openai/config/ambitions_openai_build_policy.json >/tmp/ambitions-openai-build-policy-check.json : 0
6) python3 -m json.tool tools/openai/config/redaction_rules.json >/tmp/ambitions-openai-redaction-rules-check.json : 0
7) python3 -m json.tool tools/openai/config/codex_agent_roles.json >/tmp/ambitions-openai-agent-roles-check.json : 0
8) python3 -m json.tool tools/openai/visual_critique/rubrics/ambitions_visual_canon.json >/tmp/ambitions-visual-canon-rubric-check.json : 0
9) python3 -m py_compile scripts/openai-build-suite-validate.py scripts/openai-build-suite-dry-run.py scripts/ambitions-prompt-queue-consistency.py tools/openai/repo_brain/build_repo_manifest.py tools/openai/repo_brain/query_repo_brain.py tools/openai/evals/run_evals.py tools/openai/evals/score_reports.py tools/openai/prompt_repair/repair_batch_prompt.py tools/openai/batch_report/summarize_batch_report.py tools/openai/batch_report/classify_batch_result.py tools/openai/visual_critique/critique_visual_packet.py tools/openai/launch_docs/generate_launch_packet.py : 0
10) python3 scripts/openai-build-suite-validate.py                             : 0
11) python3 scripts/openai-build-suite-dry-run.py                              : 0
12) python3 scripts/ambitions-prompt-queue-consistency.py PK28                 : 0
13) python3 tools/openai/repo_brain/build_repo_manifest.py --dry-run             : 0
14) python3 tools/openai/evals/run_evals.py --dry-run                          : 0
15) python3 tools/openai/visual_critique/critique_visual_packet.py --rubric tools/openai/visual_critique/rubrics/ambitions_visual_canon.json --dry-run : 0
16) python3 tools/openai/launch_docs/generate_launch_packet.py --dry-run         : 0
17) python3 scripts/ambitions-unsupported-claim-scan.py docs prompts .codex      : 1
```

## Failure Notes (known)

- `openai-build-suite-validate` now treats existing local-control-plane key-name references under `.codex/hooks`, `prompts/ambitions`, and `scripts/ambitions-codex-os-validate.py` as allowed tooling/prompt references, skips generated `build/` output, and still blocks app-runtime OpenAI usage and likely key material.
- Unsupported-claim scan returns many legacy findings in `.codex` and historical docs; it is intentionally broad and was not scoped to OBS.

## Repair Verification

- `python3 tools/openai/evals/score_reports.py tools/openai/evals/datasets/batch_quality.jsonl`: 0
- `python3 tools/openai/repo_brain/query_repo_brain.py "OpenAI Build Suite" --dry-run`: 0
- `python3 tools/openai/batch_report/summarize_batch_report.py docs/audits/openai-build-suite-install-report.md`: 0
- `python3 tools/openai/batch_report/classify_batch_result.py docs/audits/openai-build-suite-install-report.md`: 0
- `make openai-build-suite-validate`: 0
- `make openai-build-suite-dry-run`: 0

## No-Claim Boundaries

- No OpenAI app-runtime dependency claim.
- No release/TestFlight/App Store readiness claim.
- No accessibility/physical-device/privacy/legal proof claim.
- No PK28 implementation completion claim.

## Rollback

Use scoped cleanup for this layer only:

- `git restore --staged -- Makefile docs/codex/CODEX_OS_INDEX.md docs/codex/OPENAI_BUILD_SUITE_USAGE_POLICY.md docs/codex/OPENAI_BUILD_SUITE_ADOPTION_MATRIX.md docs/codex/CODEX_MULTI_AGENT_BUILD_SYSTEM.md docs/codex/REPO_INTELLIGENCE_LAYER.md docs/codex/OPENAI_EVAL_QA_LAYER.md docs/codex/PROMPT_REPAIR_LAYER.md docs/codex/BATCH_REPORT_LAYER.md docs/codex/VISUAL_CRITIQUE_LAYER.md docs/codex/LAUNCH_DOCUMENTATION_LAYER.md`
- `git restore -- docs/audits/openai-build-suite-install-report.md docs/audits/openai-build-suite-install-report.md`
- `git clean -fd -- tools/openai scripts/openai-build-suite-validate.py scripts/openai-build-suite-dry-run.py scripts/ambitions-prompt-queue-consistency.py prompts/batches/OBS01-CODEX-MULTI-AGENT-BUILD-SYSTEM.md prompts/batches/OBS02-REPO-INTELLIGENCE-LAYER.md prompts/batches/OBS03-OPENAI-EVAL-QA-LAYER.md prompts/batches/OBS04-PROMPT-REPAIR-BATCH-REPORT-LAYER.md prompts/batches/OBS05-VISUAL-CRITIQUE-LAUNCH-DOCS-LAYER.md prompts/batches/OBS06-SPEED-TRAIN-INTEGRATION.md`

## Next Recommended Command

`make openai-build-suite-validate && make openai-build-suite-dry-run && make speed-status && MAX_BATCHES=10 make speed-train`
