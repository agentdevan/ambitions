# Source Atlas Native Public Refresh Registry Artifact Loader - Train 23

Date: 2026-06-28
Linear: AMB-1509

## Status

Green for the bounded native public refresh registry artifact loader.

Overall Source Atlas remains Yellow.

## Scope Completed

- Added `SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader` under canonical `Core/Persistence` ownership.
- Added a schema-versioned public registry artifact envelope with artifact ID, creation date, public-reference-only flag, embedded registry, and non-claims.
- Added deterministic load resolutions that expose artifact issues, registry findings, egress findings, fallback state, and explicit non-generation flags for private/final-plan/schedule/Step output.
- Default app registry loading now reads a bundled public registry artifact when present and fails closed to the empty default registry when the artifact is missing, unreadable, malformed, unsupported, non-public, private-looking, or unsafe.
- Artifact metadata is scanned before registry use for private-looking R2 key, user/account/device, goal/capture/schedule/proof, private graph, hosted personalization, final plan, final schedule, and Step-list language.
- Registry entries are resolved through the existing target registry before lifecycle transport; duplicate, unsafe, private, and unsafe-request findings reject the artifact.
- Inactive and mode-disallowed findings remain non-critical for the artifact itself; they are still excluded by lifecycle-mode resolution.
- `AppContainer` and `AppContainerFactory` now build lifecycle refresh from `SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.defaultAppRegistry()`.
- Default app behavior remains no-network-by-default until a public registry artifact is explicitly bundled and approved.
- Focused tests cover valid artifact loading, missing bundle fallback, invalid JSON fallback, unsupported/non-public fallback, private metadata rejection, unsafe registry rejection, and app-factory zero-transport fallback.

## Files Changed

- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.swift`
- `Native/Ambitions/App/AppContainer.swift`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests.swift`
- `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-public-refresh-registry-artifact-loader-train-23.md`
- `docs/qa/source-atlas/native/source-atlas-native-public-refresh-registry-artifact-loader-train-23.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- The loader accepts only public registry artifact metadata and public pack routing fields.
- No goal text, capture text, schedule, proof, receipt, account ID, device ID, private context, private graph data, behavior history, inferred priority, or personalized segment is introduced.
- No final personalized plans, schedules, Step lists, priority order, recovery path, or proof interpretation are generated.
- Missing or unsafe app registry artifacts fall back to an empty local registry and do not block offline/no-account local planning.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `App`, `Core/Persistence`.
- Files moved or created: created `SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.swift`, `SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests.swift`, and Train 23 QA evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: no owner-approved public registry artifact is bundled or populated yet; real `BGTaskScheduler` registration and identifier proof remain deferred.
- Next repair train if debt remains: add owner-approved public target artifact population and/or real background task registration proof under canonical ownership.
- No equivalent folder/path interpretation was used.

## Apple Platform Source Atlas

- No new Apple framework or API was introduced.
- The train touches app startup/maintenance wiring and local persistence configuration only.
- iOS 26 availability: no new iOS API availability claim.
- BackgroundTasks proof remains not run and not claimed.

## Validation Run

- `xcodegen generate` - passed.
- XcodeBuildMCP focused XCTest: `SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests`, `SourceAtlasPublicPackRefreshTargetRegistryTests`, `SourceAtlasPublicPackLifecycleRefreshServiceTests`, and `AppContainerFactoryTests/testAppContainerExposesRuntimeWhilePreservingIPhoneServiceFacade` - 15 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T00-57-33-580Z_pid24471_0b7a1087.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T00-57-33-580Z_pid24471_aa733957.xcresult`
- XcodeBuildMCP adjacent Source Atlas public-pack persistence suites - 56 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T01-01-43-646Z_pid24471_c4c06073.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T01-01-43-646Z_pid24471_5b47456d.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 125 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260628T010700Z/extract/summary.json`
- `git diff --check` - passed after QA evidence write.

## Validation Not Run

- No owner-approved public registry artifact population.
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

- Source Atlas status ceiling: Green for Train 23 native public refresh registry artifact loader only; Yellow overall Source Atlas.
- R2 request privacy proof: artifact loading validates metadata and resolves registry target request shapes before lifecycle refresh transport.
- No private graph egress proof: no-private egress audit passed; focused tests prove private-looking artifact metadata and unsafe registry targets fall back to the empty registry before transport.
- License/terms proof: unchanged; no new source lane, legal registry, source claim, or pack eligibility decision added.
- Restricted-source exclusion proof: unchanged; the loader can reject unsafe target artifacts but this train does not add a restricted-source source lane.
- Provenance completeness proof: unchanged; no claim graph or packable claim path added.
- Freshness/revocation proof: unchanged; loaded registry targets still delegate to existing public pack refresh/fetch/cache validation paths; adjacent public-pack persistence suites passed.
- LKG/rollback proof: unchanged; this train does not add production LKG pointer or rollback behavior.
- Native offline/no-account proof: focused tests prove missing, malformed, unsupported, non-public, private-looking, and unsafe default artifacts fail closed to an empty registry with zero transport and no local planning block.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no real BackgroundTasks registration, no approved production registry artifact population.

## Known Risks

- Public registry artifact population remains a separate owner/legal/product approval step.
- Real background scheduling remains unproven.
- Device/offline proof remains required before release claims.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 23 artifact only claims the files listed above.

## Follow-Up Required

- Add an owner-approved bundled public registry artifact only after production/staging channel, legal/terms, source governance, and product approval are explicit.
- Add real `BGTaskScheduler` registration/identifier proof under canonical ownership once scoped.
- Run physical-device/offline proof before any release or runtime Green claim.

## Rollback Plan

- Remove `SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.swift`.
- Restore `AppContainer` and `AppContainerFactory` lifecycle service defaults to `SourceAtlasPublicPackRefreshTargetRegistry.defaultAppRegistry()`.
- Remove Train 23 XCTest additions and QA evidence.
- Retain prior Train 22 empty-registry behavior and prior public-pack cache/fetch/background task paths.
