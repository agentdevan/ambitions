# FCP05 — Start Here Surface Prompt

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-23326226, AMB28-same_source_file_targeted_by_multiple_active_batches-3247698, AMB28-same_source_file_targeted_by_multiple_active_batches-37886007, AMB28-same_source_file_targeted_by_multiple_active_batches-38550372, AMB28-same_source_file_targeted_by_multiple_active_batches-52093959, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-77426110, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-985987

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, status-expedite, terminology-quarantine
> Dispositions: clarify-status-before-use, merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Purpose

Implement the Today-owned Start Here surface as the primary Reality Rail
decision object, using the completed FCP06 Receipt Drawer / Source Fold trust
foundation. This batch replaces the old Hero Step card posture with a
source-grounded Start Here surface without creating a new tab, route, feed,
surface, AI runtime, persistence change, or broad Today rewrite.

## Source Truth

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `docs/canon/Ambitions_Found_Life_Layer.md`
- `docs/canon/Ambitions_Codex_Quality_System.md`
- FCP06 Receipt Drawer / Trust Layer implementation evidence.

## Allowed Files

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- FCP05 audit, registry, context, train-state, and global-order docs.

## Required Behavior

- Start Here must include Context Edge, Time Fit Proof, Goal Thread, source
  quality, because line, primary action, secondary action, privacy-safe copy,
  stale/source-review posture, and a Receipt Drawer seam.
- Proof remains evidence, not achievement.
- Receipts remain consequence and review path, not notification/feed posture.
- Source remains freshness/review boundary, not AI certification.
- Privacy remains user control and private projection, not surveillance.
- Reduced Motion and Dynamic Type must be preserved by relying on existing
  adaptive layout and non-motion-only meaning.

## Forbidden

- Do not create a surface, feed, generic task card, calendar clone, chatbot
  wrapper, proof signal, hidden mutation, or silent automation.
- Do not edit routes, tabs, raw values, persistence/schema, sync/cloud,
  network/auth, AI/AOS/LDI runtime, signing, CI, legal/privacy, or release
  claim files.
- Do not claim real-device, public accessibility, App Store, TestFlight, or
  release readiness.

## Validation

- `xcodegen generate`
- Focused Today unit test lane for `TodayViewModelTests`
- `scripts/build-local.sh`
- CQS advisory scans on touched owner files
- `git diff --check`
- touched-file trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

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
