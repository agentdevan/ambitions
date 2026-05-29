<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-81554362

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
