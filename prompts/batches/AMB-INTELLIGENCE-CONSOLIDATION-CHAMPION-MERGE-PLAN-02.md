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

# AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02

Batch type: guard-repair

Mission: install Champion Merge execution system after champion selection guard installation.

Allowed scope:

- `scripts/ambitions-champion-merge-planner.py`
- `scripts/ambitions-parallel-implementation-guard.py`
- `docs/codex/CHAMPION_MERGE_EXECUTION_PROTOCOL.md`
- `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml`
- `docs/codex/CHAMPION_MERGE_RUNBOOK.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md`
- `prompts/batches/champion-merge/**`
- `prompts/trains/ios26-flagship/support/CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION_SUPPORT.md`
- `build/reports/intelligence-consolidation/champion-merge-plan.*`
- `build/reports/parallel-implementation-guard/*CHAMPION-MERGE-PLAN-02*`

Accepted Yellow boundary:

- owner: Ambitions repo/process owner
- reason: Champion Merge planner creates initial locks and queue from bootstrap ledgers; source merge is deferred to dedicated batches
- no-claim boundary: does not merge source, does not delete duplicates, does not prove runtime consolidation
- follow-up gate: run Champion Merge queue batches before feature trains touching locked concepts
- canonical owner affected: all locked concepts in `docs/codex/concept-lock-registry.yml`

Required outcome:

- Champion Merge protocol installed
- merge queue generated
- concept lock registry generated
- planner script installed
- merge train/runbook/prompts installed
- parallel guard reads concept locks

STATUS: YELLOW

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
