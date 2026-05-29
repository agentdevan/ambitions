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
# Final Repo Green Report

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T18-FINAL-GREEN-REPORT

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T18-FINAL-GREEN-REPORT prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T18-FINAL-GREEN-REPORT.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Produce the final controlled Green / accepted Yellow / Red report without overclaiming.

## Active source truth to inspect
Truth files, all reset-master train closeouts, final vocabulary ledger, validation proof, git status, branch/SHA, source maps, reports.

## Allowed scope
`docs/audits/*final-green-report.md`, master report files, final JSON, validation proof updates.

## Forbidden scope
No source/product changes, no historical deletion, no late proof fabrication, no release/TestFlight/App Store/accessibility/performance/privacy/legal claims without current evidence.

## Implementation requirements
Separate source-present, configured, wired, scaffolded, preview-backed, tested, validated, unproven, not found, historical, supporting, deleted, moved, renamed, deferred. Final JSON must parse at the prompt-required build report path.

## Visual proof expectations
Summarize visual proof only if current artifacts exist.

## Accessibility expectations
Summarize accessibility proof only if current artifacts exist.

## Privacy / trust expectations
Summarize privacy/local-first posture without legal/privacy approval claims.

## Continuity expectations
Record rollback and next eligible trains for Yellow/Red.

## Validation expectations
Run all required validators, final JSON parse, final tracked-file IA scan proof, `git diff --check`, `git status --short`, and build/package/test commands if environment allows.

## Hard Red stop conditions
Missing/invalid JSON, stale active IA remains, required validator missing while expected, false Green, or release proof overclaim.

## Rollback expectations
Restore final report/JSON artifacts from this train only.

## Expected final report format
Executive verdict, branch/SHA, files changed/moved/deleted/created, authority repairs, source refactors, vocabulary repairs, governance repairs, validation run/not run, accepted Yellow, remaining Red, rollback notes, non-claims, next recommended trains.

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
