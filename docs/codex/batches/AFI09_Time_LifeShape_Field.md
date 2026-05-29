# AFI09 Time LifeShape Field

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19756138, AMB28-same_source_file_targeted_by_multiple_active_batches-69194013, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-66075429

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

<!-- markdownlint-disable MD013 -->

Status: Complete / Accepted Yellow
Date: 2026-05-08

## Purpose

Complete Time as Shape Time / LifeShape Field in the active AFI lane while
preserving the existing internal `.plan` route and Plan implementation seams as
compatibility-only names.

## Source Truth

- `docs/AmbitionsCanon/03_Signature_Object_Specs.md`
- `docs/AmbitionsCanon/10_Ambitions_Flagship_Interface_Canon.md`
- `docs/AmbitionsCanon/15_AFI_Implementation_Lane.md`
- `docs/AmbitionsCanon/16_Surface_Identity_And_Signature_Moments.md`
- `docs/codex/AMBITIONS_CANON_UI_COMPLETION_INSERTION_OVERLAY.md`

## Scope

- Keep Time as the fourth active top-level destination.
- Present the Time surface as Shape Time / LifeShape Field.
- Show open time, goal time, protected time, pressure, and capacity truth.
- Keep Calendar permission/request posture explicit and manual; Time must work
  without Calendar access.
- Preserve `.plan`, Plan file paths, Plan route targets, and legacy deep-link
  compatibility as internal implementation seams.

## Forbidden

- Do not restore Plan as a top-level destination.
- Do not turn Time into a calendar clone, agenda, schedule surface, analytics
  surface, or red-alert pressure surface.
- Do not silently schedule, write calendar/reminder data, mutate goals, or hide
  manual fallback controls.
- Do not change route raw values, persistence schema, package boundaries,
  signing, entitlements, hosted workflows, sync/cloud behavior, or release
  posture.

## Validation

- `xcodegen generate`
- Focused Time/contract/reality lane:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/PlanFeatureServiceTests -only-testing:AmbitionsTests/ScreenContractRegistryTests -only-testing:AmbitionsTests/TopLevelSurfaceCompositionTests -only-testing:AmbitionsTests/LoadingDegradedStateDesignSystemTests -only-testing:AmbitionsTests/InteractionMotionHapticsDesignSystemTests -only-testing:AmbitionsTests/CalendarRealityServiceTests -only-testing:AmbitionsTests/RealityModelsTests -only-testing:AmbitionsTests/RealityIntegrationAdaptersTests -only-testing:AmbitionsTests/CalendarReminderActionFlowTests test CODE_SIGNING_ALLOWED=NO`
- `./scripts/build-local.sh`
- `python3 -m py_compile scripts/ai/acx_visual_packet.py`
- `python3 scripts/ai/acx_visual_packet.py Time <changed Time files>`
- `python3 scripts/ai/acx_accessibility_packet.py Time <changed Time files>`
- `git diff --check`

## Closeout

Result: Accepted Yellow. Focused tests and local build passed. Rendered
screenshot proof, manual accessibility traversal, full UI test suite,
physical-device proof, signed archive proof, and public accessibility
conformance remain unclaimed.

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
