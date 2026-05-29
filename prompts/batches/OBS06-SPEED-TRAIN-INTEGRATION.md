<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-24854560, AMB28-same_source_file_targeted_by_multiple_active_batches-81554362, AMB28-same_source_file_targeted_by_multiple_active_batches-82439366

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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
