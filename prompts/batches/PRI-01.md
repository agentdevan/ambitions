<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# PRI-01 - Runtime Inspection

## Batch ID

PRI-01

## Runner command

```bash
scripts/ambitions-codex-train.sh PRI-01 prompts/batches/PRI-01.md
```

Equivalent:

```bash
make batch BATCH=PRI-01 PROMPT=prompts/batches/PRI-01.md
```

## Objective

Implement PRI-01 exactly as specified in `docs/codex/HISTORICAL_BASELINE_GLOBAL_TRAIN_MANIFEST.json` and `docs/codex/batch-trains/HBI00_RRE01_HISTORICAL_BASELINE_TRAIN.md`.

## Required source truth

Read the active truth files, the Historical Baseline overlay, the manifest, the train document, and `prompts/batches/HBI-10.md` before coding.

## Allowed scope

Batch-owned inspection receipt model/surface, source influence summary, comprehension fixtures, focused tests, and UI proof if user-facing UI changes.

## Forbidden scope

Noisy internals, hidden influence, source/proof loss, cloud-only runtime dependency, or release/readiness claims.

## Validation expectations

Run the comprehension fixtures and inspection tests named by the train manifest. Record true commands and exit codes.

## Visual proof expectations

Required for user-facing UI changes.

## Hard Red stop conditions

Stop on source influence opacity, provenance loss, review bypass, or missing visual proof for UI changes.

## Rollback expectations

Revert only PRI-01-owned files.

## Final report expectations

Create `docs/audits/pri-01-batch-closeout-report.md`.

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
