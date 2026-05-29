# F03.5 Today Architecture Hardening

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **codex-reference**
> AMB-291 note: This Codex reference supports process or execution, but active truth remains in docs/truth and current manifests.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

Path: docs/codex/batch-trains/F03_5_Today_Architecture_Hardening.md
Status: Active batch train manifest

## Purpose
Run before F04; single-batch train; required because TodayExecutionViewState.swift exceeds 1000 lines.

## Train Type
Quality Train / Architecture Hygiene

## Allowed Auto-Continue Behavior
Codex may continue only on Green. Yellow and Red stop. Architecture trains are planning-only unless explicitly approved.

## Batch List
- F03.5

## Owning Primitives
Golden Launch Loop primitives named by the active batch plan. F17 owns shell only after F01-F16.5 evidence is accepted.

## Owning Surfaces
Today, Capture, Plan, Goals, You, or Shell as named by the batch list. Do not add new top-level destinations.

## Dependencies
Read order: README.md; docs/README.md; docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md; docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md; docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md; docs/canon/Ambitions_3_0_Primitive_Architecture.md; docs/canon/Ambitions_3_0_Product_Language_System.md; docs/codex/BATCH_REGISTRY.md; docs/codex/CONTEXT_INDEX.md. Validate prerequisite batches before executing.

## Allowed Files
Only target feature files, focused tests/previews, batch reports, run-state files, and active docs explicitly named by the batch prompt.

## Forbidden Files
`.github/workflows/**`, runtime dependency manifests unless explicitly approved, unrelated surfaces, release-claim docs except truthful reports, generated artifacts, and F17 implementation unless this is the F17 approved planning/implementation run.

## Validation Packs
Batch train gate pack, continuation/stop pack as applicable, architecture hygiene pack, feature file responsibility pack, SwiftUI state contract pack for feature state work, release claim pack for any release wording.


## Green Gate
Codex may continue automatically only when the working tree was clean before the batch or contains expected staged changes only; the batch stayed within allowed files; no forbidden files, workflow files, runtime dependencies, or unapproved product surfaces were touched; build and focused tests pass; touched-scope copy, privacy, accessibility, UI-test-contract, architecture, and file-responsibility checks are acceptable; run state and batch-train state are updated; a report is written; a commit is created; and the next prompt exists and matches the manifest.

## Yellow Stop
Codex must stop, write a stop report, and generate a repair or decision prompt for doc-QA advisory backlog, known unrelated UI-smoke failures, full-suite failure with focused tests passing, minor canon ambiguity, non-blocking link/copy backlog, small out-of-scope test drift, touched files broader than expected, optional tool absence, file-responsibility warnings, feature state files exceeding soft thresholds, or conditional checkpoint triggers such as F13.5/F16.5.

## Red Stop
Codex stops immediately for build failure, focused-test failure, forbidden files touched, `.github/workflows` touched, runtime dependency added, shell/routing changed outside scope, privacy-sensitive leakage, forbidden user-facing copy, task-width escalation without approval, persistence/deep-link/App Intent breakage, merge conflict or unclear dirty state, commit failure, untrustworthy validation, skipped required architecture hardening, or human escalation trigger.


## Commit Strategy
Path-limited staging. One commit per Green batch. Stop if commit fails.

## Final Report Path
`docs/audits/ambitions-3-0-f03-5-today-architecture-hardening-report.md`

## Human Review Required
Required before skipped batches, Architecture Train implementation, workflow/dependency changes, release claims, privacy/memory ambiguity, or F17 implementation.

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
