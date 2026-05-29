# FCP07 Reality Rail Continuity Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-23326226, AMB28-same_source_file_targeted_by_multiple_active_batches-3247698, AMB28-same_source_file_targeted_by_multiple_active_batches-37886007, AMB28-same_source_file_targeted_by_multiple_active_batches-38550372, AMB28-same_source_file_targeted_by_multiple_active_batches-52093959, AMB28-same_source_file_targeted_by_multiple_active_batches-77426110, AMB28-same_surface_multiple_active_batches-34058953, AMB28-stale_or_unknown_active_status-36632560

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Batch

FCP07 - Reality Rail Continuity.

## Train

FCP01-FCP30 Flagship Completion Train under the global full-stack order.

## Type

Implementation.

## Owner

Today.

## Source Truth

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- FCP05 Start Here Surface evidence
- FCP06 Receipt Drawer / Trust Layer evidence

## Goal

Make Start Here, Now/Next/Later, closure, proof, and pressure one continuous
Reality Rail object.

## Allowed Files

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- FCP07 audit/report docs
- train registry/context/run-state docs

## Forbidden Files

- Top-level tab/navigation route/raw-value files
- Persistence/schema/import/export files
- Sync/account/network/auth files
- AI/AOS/LDI runtime files
- CI/workflow/signing/entitlement/project configuration files
- Release/legal/privacy claim files

## Acceptance

- Start Here remains the primary Today decision point.
- Now / Next / Later remain ordered rail positions, not an agenda clone.
- Closure appears as a rail knot without silently mutating completion state.
- Proof appears as a marker/receipt boundary without creating persistence.
- Pressure remains visible as context and recovery posture.
- The rail has non-color text equivalents and privacy-safe labels.
- Focused Today tests pass.

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
