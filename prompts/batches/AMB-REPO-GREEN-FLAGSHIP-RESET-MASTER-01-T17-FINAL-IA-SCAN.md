<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-duplicate_stable_id-17786025, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Final Tracked File IA Surface Scan

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T17-FINAL-IA-SCAN.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Prove zero forbidden active IA/surface ownership remains with a context-aware tracked-file scan.

## Active source truth to inspect
Truth files, T03/T04 ledgers, tracked files across source/tests/docs/frontend/.codex/.agents/prompts/project/package.

## Allowed scope
Final vocabulary ledger, scan script/report updates, small repairs for remaining forbidden hits if safe.

## Forbidden scope
No blind zero-token purge, no history deletion, no source behavior rewrite, no proof overclaim.

## Implementation requirements
Search tracked files for stale surface terms and variants, classify every hit, fail only active ownership, record allowed ordinary-language hits, and produce zero-forbidden proof.

## Visual proof expectations
Visual recipe IDs must be canonical if active; no screenshot claim.

## Accessibility expectations
Root accessibility identifiers must be canonical where active.

## Privacy / trust expectations
No data/network changes.

## Continuity expectations
Historical/supporting references remain labeled and cannot override truth.

## Validation expectations
Run tracked-file scans, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Stale active tab/route/feature/screen/shell/visual ID remains, unclassified hits, or false zero proof.

## Rollback expectations
Restore ledger/report/script and any narrow repairs from this train.

## Expected final report format
Forbidden count, allowed context count, ledger path, residual Yellow, validation, non-claims.

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
