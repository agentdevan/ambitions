# Source Atlas Local Composition/Inspection Train 06

Date: 2026-06-27

Status: Green for deterministic local composition/source inspection proof boundary / Yellow overall Source Atlas

Linear: AMB-1492

## Scope Completed

- Added a deterministic local reference composition proof model that converts a verified local Source Atlas cache resolution into a public-reference-only runtime proof.
- Added source inspection presentation mapping for local reference composition states without creating a Source Atlas product center.
- Added focused XCTest coverage for current public references, private-looking local label redaction, last-known-good stale context, revoked reference blocking, and review-required inspection state.
- Regenerated the Xcode project locally with XcodeGen so the new source and test files are visible to the scheme.

## Files Changed

- `Native/Ambitions/Core/Runtime/SourceAtlasLocalReferenceCompositionProof.swift`
- `Native/Ambitions/Trust/SourceInspectionLocalReferenceComposition.swift`
- `Native/AmbitionsTests/Runtime/SourceAtlasLocalReferenceCompositionProofTests.swift`
- `docs/qa/source-atlas/native/source-atlas-local-composition-train-06.md`
- `docs/qa/source-atlas/native/source-atlas-local-composition-train-06.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- Source Atlas provides public reference context only; it does not generate final personalized plans, final schedules, final Steps, final priority order, or final recovery paths.
- Local proof explicitly records that Ambitions runtime owns fit, timing, and priority.
- Private-looking local match and public entity labels are redacted before proof or inspection presentation output.
- Core local planning remains unblocked when a reference is unavailable, stale-critical, conflicted, revoked, unsupported, or review-required.
- No hosted planning, server-side personalization, account service, entitlement service, live network path, or Source Atlas root surface was introduced.

## Validation Run

- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath output/DerivedData-XcodeBuildMCP -only-testing:AmbitionsTests/SourceAtlasLocalReferenceCompositionProofTests test CODE_SIGNING_ALLOWED=NO`
  - Result: passed, 5 tests, 0 failures.
  - Result bundle: `output/DerivedData-XcodeBuildMCP/Logs/Test/Test-Ambitions-2026.06.27_15-55-14--0400.xcresult`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath output/DerivedData-XcodeBuildMCP -only-testing:AmbitionsTests/SourceAtlasLocalReferenceCompositionProofTests -only-testing:AmbitionsTests/SourceInspectionPresentationTests -only-testing:AmbitionsTests/SourceInspectionAccessibilityProofTests -only-testing:AmbitionsTests/SourceAtlasLocalCompositionFallbackTests -only-testing:AmbitionsTests/SourceAtlasLocalPackCacheTests -only-testing:AmbitionsTests/SourceAtlasPublicPackFetchPipelineTests -only-testing:AmbitionsTests/SourceAtlasNoPrivateGraphEgressAuditTests test-without-building CODE_SIGNING_ALLOWED=NO`
  - Result: passed, 31 tests, 0 failures.
  - Result bundle: `output/DerivedData-XcodeBuildMCP/Logs/Test/Test-Ambitions-2026.06.27_15-58-12--0400.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests`
  - Result: passed, 106 tests.
- `python3 scripts/source-atlas-boundary-audit.py`
  - Result: PASS, 40 targets.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py`
  - Result: PASS.
- `python3 scripts/ambitions-green-standard-audit.py`
  - Result: GREEN.
- `python3 scripts/ambitions-local-first-boundary-scan.py`
  - Result: GREEN.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard`
  - Result: Test Build Succeeded.
  - Summary: `.codex/xcode-summaries/green-standard/20260627T200015Z/extract/summary.json`
  - Result bundle: `.codex/xcode-results/green-standard/20260627T200015Z-bft-95579-3464/build-for-testing.xcresult`
- `git diff --check`
  - Result: passed.

## Validation Not Run

- No live R2 fetch.
- No production R2 upload, readback, stable pointer update, revocation publish, or rollback drill.
- No physical device proof.
- No rendered source-inspection UI proof.
- No App Store, TestFlight, entitlement, account, or release-readiness proof.
- No outside legal review.
- No universal coverage or broad domain production proof.

## Proof Artifacts

- Local-only composition proof: `SourceAtlasLocalReferenceCompositionProofBuilder` records `"Matched locally on this device."` and keeps `runtimeOwnsFitTimingPriorityProof` true while `sourceAtlasOwnsFinalUserSteps` and `createsFinalSchedule` are false.
- Private-egress proof: `testPrivateLocalMatchTextIsRedactedBeforeProofOrInspection` blocks private-looking goal/context labels from proof and inspection text.
- Source inspection proof: `SourceInspectionPresentation.make(localReferenceProof:)` maps local reference state to inspection state, public detail, use context, and review action.
- Freshness/revocation proof: stale, stale-critical, conflicted, revoked, unsupported, unavailable, and review-required states map from existing cache/fetch issues into bounded inspection states.
- LKG proof: `testLastKnownGoodMapsToStaleInspectionWithoutCurrentUseClaim` treats last-known-good as older context and does not claim current use.
- Revocation proof: `testRevokedManifestMapsToBlockedSourceInspectionAndLocalPlanningContinues` blocks revoked references while preserving local planning.
- Copy guard proof: focused tests run `SourceInspectionCopyAudit` against generated presentations.

## Known Risks

- This is a deterministic local composition and inspection presentation boundary, not rendered UI proof.
- Production R2 behavior still depends on separately proven public object keys, upload/readback SHA-256, revocation manifests, stable channel pointers, and rollback controls.
- License/terms posture is consumed from pack and governance artifacts; this native train does not create legal approval.
- The full build-for-testing run still emits unrelated pre-existing Swift concurrency/deprecation warnings in older tests, but the script exited successfully.

## Follow-Up Required

- Wire this proof model into a product-approved UI surface only when rendered UI, accessibility, and snapshot/device proof are scoped.
- Add live-network fetch only after request-shape privacy, cache-control, retry, and R2 endpoint rules are scoped.
- Keep broad domain expansion behind source governance, claim provenance, legal posture, R2 operation proof, and native runtime proof gates.

## Rollback Plan

- Remove `SourceAtlasLocalReferenceCompositionProof.swift`, `SourceInspectionLocalReferenceComposition.swift`, and `SourceAtlasLocalReferenceCompositionProofTests.swift`.
- Regenerate `Ambitions.xcodeproj` with XcodeGen.
- Continue using the existing native Source Atlas cache, access boundary, fetch pipeline, source inspection presentation model, bundled fallback, and offline/no-account behavior.

## Required Closeout Fields

- Source Atlas status ceiling: Yellow overall; Green only for deterministic local composition/source inspection proof boundary.
- R2 request privacy proof: no new R2 request path; composition consumes local cache/fetch resolution and public pack metadata only.
- No private graph egress proof: private-looking local match and public entity labels are redacted before proof or inspection output; no-private-egress audit passed.
- License/terms proof: not expanded in this train; local composition consumes governed pack/source artifacts and does not approve redistribution.
- Restricted-source exclusion proof: not expanded in this train; restricted source blocking remains governed by Source Atlas registry and pack production gates.
- Provenance completeness proof: composition consumes selected provenance source IDs and public source records; it does not create new claims.
- Freshness/revocation proof: cache/fetch issues map into stale, stale-critical, conflicted, revoked, unsupported, unavailable, and review-required states.
- LKG/rollback proof: last-known-good maps to stale inspection and no current-use claim.
- Native offline/no-account proof: core local planning remains unblocked; no account or network path was introduced.
- Production non-claims: no production R2 readiness, no live fetch readiness, no legal approval, no release readiness, no universal coverage, no hosted personalization, no final plan/schedule/Step generation.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Runtime`, `Trust`; tests under `Native/AmbitionsTests/Runtime`.
- Files moved or created: created the local composition proof, Trust inspection bridge, and focused tests listed above.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: none introduced by this train; rendered UI wiring remains unscoped.
- Next repair train if debt remains: scope a separate rendered source-inspection train only after the UI owner, accessibility proof, and visual/device proof gates are approved.
- Confirmation: no equivalent folder/path interpretation was used.
