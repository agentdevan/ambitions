<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-duplicate_stable_id-5337332, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_surface_multiple_active_batches-26899932

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Repo Architecture Organization Map

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T05-SOURCE-REFRACTOR-MAP.md`

## Objective
Create the target source ownership map for flagship object seams without moving files blindly.

## Active source truth to inspect
Read truth files, current source tree, `project.yml`, `Package.swift`, implementation map, audit UI-sprawl and cleanup reports.

## Allowed scope
`docs/audits/*source-refactor-map.md`, master report/JSON, optional read-only source inventory output.

## Forbidden scope
No source moves, empty folder creation, UI rewrite, project regeneration, or release claims in this train unless explicitly needed for map accuracy.

## Implementation requirements
Map `App`, `Domain`, `Services`, `Persistence`, feature seams, shared UI, tests, proof ownership, and object-local seams. Scope future extraction trains with risk and validation.

## Visual proof expectations
None.

## Accessibility expectations
Map accessibility ownership under `Native/Ambitions/UI/Accessibility` or current equivalent.

## Privacy / trust expectations
Map trust/data controls and local-first runtime ownership.

## Continuity expectations
Respect existing compatibility seams; identify moves as future trains.

## Validation expectations
Run source inventory scans, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Unplanned source movement, empty architecture theater, or source-present/release-ready overclaim.

## Rollback expectations
Restore map/report artifacts only.

## Expected final report format
Ownership map, next extraction trains, non-goals, proof gaps, validation.

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
