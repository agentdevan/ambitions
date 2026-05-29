# Champion Merge Runbook

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof
> Dispositions: merge-before-proof, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Status: Installed, not run.

Run after `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` and before feature trains that touch locked duplicate concepts.

```bash
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-OWNER-REVIEW-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-OWNER-REVIEW-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-TODAY-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TODAY-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-CAPTURE-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-CAPTURE-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-RUNTIME-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-RUNTIME-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-PROOF-RECEIPT-REPLAY-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-PROOF-RECEIPT-REPLAY-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-TIME-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TIME-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-GOALS-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-GOALS-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-YOU-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-YOU-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-DESIGN-SYSTEM-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-DESIGN-SYSTEM-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01.md
```

Stop on Red. Continue on Yellow only with owner, reason, no-claim boundary, follow-up gate, affected canonical owner, and ledger update.

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
