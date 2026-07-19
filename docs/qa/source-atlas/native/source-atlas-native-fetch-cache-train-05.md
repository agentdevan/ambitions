# Source Atlas Native Fetch/Cache/Verify Train 05

Date: 2026-06-27

Status: Green for deterministic native public pack fetch/cache/verify boundary / Yellow overall Source Atlas

Linear: AMB-1491

## Scope Completed

- Added a deterministic native public manifest request model for Source Atlas reference packs.
- Added a native public pack fetch pipeline that accepts injected manifest and pack bytes, validates request privacy, decodes public manifests, selects the requested public pack, verifies SHA-256 through the existing local pack cache, quarantines unsafe artifacts, and falls back to bundled or last-known-good public references.
- Added focused XCTest coverage for accepted public downloads, hash mismatch quarantine, private manifest request blocking, offline/no-account LKG fallback, and revoked manifest quarantine.
- Regenerated the Xcode project locally with XcodeGen so the new source and test files are visible to the scheme.

## Files Changed

- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackFetchPipeline.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackFetchPipelineTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-fetch-cache-train-05.md`
- `docs/qa/source-atlas/native/source-atlas-native-fetch-cache-train-05.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- No user goal text, capture text, schedules, proof, receipts, account identifiers, device identifiers, private graph data, or personalization context are accepted in manifest or pack request shapes.
- The pipeline does not perform live network I/O and does not introduce hosted planning, personalization, entitlement, account, or Source Atlas product-center behavior.
- Core local planning remains unblocked even when Source Atlas references are unavailable, unsafe, stale-critical, revoked, or quarantined.

## Validation Run

- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath output/DerivedData-XcodeBuildMCP -only-testing:AmbitionsTests/SourceAtlasPublicPackFetchPipelineTests test CODE_SIGNING_ALLOWED=NO`
  - Result: passed, 5 tests, 0 failures.
  - Result bundle: `output/DerivedData-XcodeBuildMCP/Logs/Test/Test-Ambitions-2026.06.27_15-30-28--0400.xcresult`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -derivedDataPath output/DerivedData-XcodeBuildMCP -only-testing:AmbitionsTests/SourceAtlasPublicPackFetchPipelineTests -only-testing:AmbitionsTests/SourceAtlasLocalPackCacheTests -only-testing:AmbitionsTests/SourceAtlasPublicArtifactPrivacyBoundaryTests -only-testing:AmbitionsTests/SourceAtlasNoPrivateGraphEgressAuditTests -only-testing:AmbitionsTests/SourceAtlasAccessBoundaryTests -only-testing:AmbitionsTests/SourceAtlasOfflineNoAccountScenarioTests test-without-building CODE_SIGNING_ALLOWED=NO`
  - Result: passed, 28 tests, 0 failures.
  - Result bundle: `output/DerivedData-XcodeBuildMCP/Logs/Test/Test-Ambitions-2026.06.27_15-40-01--0400.xcresult`
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
  - Summary: `.codex/xcode-summaries/green-standard/20260627T194202Z/extract/summary.json`
- `git diff --check`
  - Result: passed.

## Validation Not Run

- No live R2 fetch.
- No production R2 upload, readback, stable pointer update, revocation publish, or rollback drill.
- No physical device proof.
- No rendered source-inspection UI proof.
- No App Store, TestFlight, entitlement, account, or release-readiness proof.
- No outside legal review.

## Proof Artifacts

- Native request-shape proof: `SourceAtlasPublicManifestRequest` serializes only domain, channel, schema version, app version, public route, and optional public locale.
- Native pack-request proof: `SourceAtlasPublicPackRequest.publicPack` is created from the public manifest entry only after manifest request validation passes.
- Hash/quarantine proof: `testDownloadedHashMismatchQuarantinesDownloadedPackAndUsesBundledFallback`.
- Private-egress proof: `testPrivateManifestRequestBlocksBeforePackRequestOrCacheLoad`.
- LKG/offline/no-account proof: `testCachedManifestCanUseLastKnownGoodWhenOfflineWithoutAccount`.
- Revocation proof: `testRevokedManifestQuarantinesPackAndDoesNotUseReferenceForCurrentPlanning`.
- Boundary regression proof: existing Source Atlas cache/privacy/access/offline suites passed alongside the new pipeline tests.

## Known Risks

- This is a deterministic orchestration boundary, not a live HTTP client or production downloader.
- Production R2 behavior still depends on separately proven public object keys, upload/readback SHA-256, revocation manifests, stable channel pointers, and rollback controls.
- License/terms posture is consumed from pack and governance artifacts; this native train does not create legal approval.
- The full build-for-testing run still emits unrelated pre-existing Swift concurrency/deprecation warnings in older tests, but the script exited successfully.

## Follow-Up Required

- Add a live-network adapter only after request-shape privacy, cache-control, retry, and R2 endpoint rules are scoped.
- Wire the native pipeline to a product-approved freshness fetch point behind local-first and privacy gates.
- Add rendered source-inspection proof only when UI is touched.
- Run production R2 promotion only with explicit owner approval and credentials.

## Rollback Plan

- Remove `SourceAtlasPublicPackFetchPipeline.swift` and `SourceAtlasPublicPackFetchPipelineTests.swift`.
- Regenerate `Ambitions.xcodeproj` with XcodeGen.
- Continue using the existing `SourceAtlasLocalPackCache`, access boundary, bundled fallback, and offline/no-account behavior.

## Required Closeout Fields

- Source Atlas status ceiling: Yellow overall; Green only for deterministic native public pack fetch/cache/verify boundary.
- R2 request privacy proof: manifest and pack request models use public reference fields only and are audited before cache load.
- No private graph egress proof: focused test blocks `goal_text` in manifest request before pack request/cache resolution; no-private-egress audit passed.
- License/terms proof: not expanded in this train; native code requires manifest/cache artifacts and does not approve redistribution.
- Restricted-source exclusion proof: not expanded in this train; restricted source blocking remains governed by Source Atlas registry and pack production gates.
- Provenance completeness proof: not expanded in this train; native code consumes pack artifacts and does not create claims.
- Freshness/revocation proof: revoked manifest entry quarantines current pack; stale-critical behavior remains covered by existing cache tests.
- LKG/rollback proof: cached manifest plus last-known-good payload can be selected offline without account when safe.
- Native offline/no-account proof: focused offline/no-account suite passed and new LKG test keeps core local planning unblocked.
- Production non-claims: no production R2 readiness, no live fetch readiness, no legal approval, no release readiness, no universal coverage, no hosted personalization, no final plan/schedule/Step generation.

## Architecture Closeout

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Persistence`; tests under `Native/AmbitionsTests/Persistence`.
- Files moved or created: created the native pipeline and focused tests listed above.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: none introduced by this train; live network wiring remains unscoped.
- Next repair train if debt remains: scope a separate native live-fetch integration train after endpoint and privacy proof are approved.
- Confirmation: no equivalent folder/path interpretation was used.
