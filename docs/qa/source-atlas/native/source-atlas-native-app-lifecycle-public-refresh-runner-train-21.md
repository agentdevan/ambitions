# Source Atlas Native App Lifecycle Public Refresh Runner - Train 21

Date: 2026-06-28
Linear: AMB-1507

## Status

Green for the bounded native app lifecycle public refresh runner.

Overall Source Atlas remains Yellow.

## Scope Completed

- Added `SourceAtlasPublicPackLifecycleRefreshService` as an app-safe runner for configured public Source Atlas pack refresh targets.
- Added lifecycle refresh mode, target, input, resolution, and issue models for startup, active lifecycle, and future background entrypoints.
- Validated configured refresh target metadata and manifest request shape before any transport call.
- Rejected private-looking lifecycle targets before transport.
- Added a default app cache repository rooted under the app caches directory.
- Exposed the lifecycle refresh service through `AppContainer` and `AppPlatformCapability`.
- Invoked the refresh runner from app maintenance reconciliation with the default empty target set, preserving no-network-by-default behavior.
- Added focused XCTest coverage for empty configuration, offline latest cached public pack recovery, and private target rejection before transport.
- Added factory coverage proving the default container exposes the refresh runner without blocking core local planning.

## Files Changed

- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackLifecycleRefreshService.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackCacheFileRepository.swift`
- `Native/Ambitions/App/AppBootstrapper.swift`
- `Native/Ambitions/App/AppCapabilities.swift`
- `Native/Ambitions/App/AppContainer.swift`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift`
- `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-app-lifecycle-public-refresh-runner-train-21.md`
- `docs/qa/source-atlas/native/source-atlas-native-app-lifecycle-public-refresh-runner-train-21.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- Lifecycle targets contain public domain, channel, schema, app version, optional public locale, target pack ID, and environment metadata only.
- No goal text, capture text, schedule, proof, receipt, account ID, device ID, private context, private graph data, or personalized segment is sent to Source Atlas/R2.
- No final personalized plans, schedules, Step lists, priority order, recovery path, or proof interpretation are generated.
- Empty default configuration performs no transport and does not block offline/no-account local planning.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `App`, `Core/Persistence`.
- Files moved or created: created `SourceAtlasPublicPackLifecycleRefreshService.swift` and Train 21 QA evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: real `BGTaskScheduler` registration and identifier proof remain deferred because product truth does not currently name `Core/Background` as a canonical owner; this train only adds the app-safe lifecycle runner and active maintenance hook.
- Next repair train if debt remains: add explicit background task registration/identifier proof or a public refresh target configuration registry under canonical ownership.
- No equivalent folder/path interpretation was used.

## Apple Platform Source Atlas

- Consulted BackgroundTasks Atlas sections 11.1 through 11.5.
- Approved background task job class used: Source Atlas public/reference pack refresh.
- This train does not claim real `BGTaskScheduler`, `Scene.backgroundTask`, background launch, or device background execution proof.

## Validation Run

- `xcodegen generate` - passed.
- XcodeBuildMCP focused XCTest: `SourceAtlasPublicPackLifecycleRefreshServiceTests` and `AppContainerFactoryTests/testAppContainerExposesRuntimeWhilePreservingIPhoneServiceFacade` - 4 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T00-25-02-105Z_pid24471_6b490bf3.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T00-25-02-105Z_pid24471_fc7cff54.xcresult`
- XcodeBuildMCP adjacent public-pack persistence suites - 45 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T00-27-11-984Z_pid24471_4bd87e65.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T00-27-11-984Z_pid24471_0fb5ec8e.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 125 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260628T003045Z/extract/summary.json`
- `git diff --check` - passed before QA evidence write.

## Validation Not Run

- No real `BGTaskScheduler` registration, identifier, launch, or background execution proof.
- No production R2 upload/readback.
- No physical-device/offline runtime proof.
- No visual, accessibility, TestFlight, App Store, or release readiness proof.
- No legal/terms approval beyond existing stored registry artifacts.

## Proof Artifacts

- Focused XCTest log and result bundle listed above.
- Adjacent persistence XCTest log and result bundle listed above.
- Build-for-testing summary listed above.
- This closeout note and structured JSON proof ceiling.

## Additional Source Atlas Fields

- Source Atlas status ceiling: Green for Train 21 native app lifecycle public refresh runner only; Yellow overall Source Atlas.
- R2 request privacy proof: lifecycle target validation rejects private-looking metadata and unsafe public manifest request shapes before transport.
- No private graph egress proof: no-private egress audit passed; focused test proves a private-looking lifecycle target performs zero transport.
- License/terms proof: unchanged; no new source lane, legal registry, source claim, or pack eligibility decision added.
- Restricted-source exclusion proof: unchanged; no restricted source path added.
- Provenance completeness proof: unchanged; no claim graph or packable claim path added.
- Freshness/revocation proof: lifecycle runner delegates to the existing background refresh task and repository-backed public pack validation paths; adjacent public-pack persistence suites passed.
- LKG/rollback proof: unchanged; this train does not add production LKG pointer or rollback behavior.
- Native offline/no-account proof: focused test proves configured public lifecycle refresh can select a latest cached public pack offline with zero transport; empty default configuration performs no transport and does not block local planning.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no real BackgroundTasks registration.

## Known Risks

- Real background scheduling remains unproven.
- Default runtime has no configured lifecycle refresh targets, so this train proves the runner and hook, not production pack freshness.
- Device/offline proof remains required before release claims.
- `SourceAtlasPublicPackCacheFileRepository` is marked `@unchecked Sendable` for actor-backed lifecycle refresh use; its mutable collaborator is a `FileManager`, so future concurrent repository expansion should keep file operations deterministic and covered.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 21 artifact only claims the files listed above.

## Follow-Up Required

- Add an approved public refresh target configuration registry.
- Add real `BGTaskScheduler` registration/identifier proof under canonical ownership once scoped.
- Run physical-device/offline proof before any release or runtime Green claim.

## Rollback Plan

- Remove `SourceAtlasPublicPackLifecycleRefreshService.swift`.
- Remove the lifecycle refresh service from `AppContainer`, `AppPlatformCapability`, and `AppContainerFactory`.
- Remove the app maintenance refresh invocation from `AppBootstrapper`.
- Remove Train 21 XCTest additions and QA evidence.
- Retain prior public-pack cache, fetch, background task, and repository-backed refresh paths from earlier trains.
