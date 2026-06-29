# Source Atlas Native Public Refresh Target Registry - Train 22

Date: 2026-06-28
Linear: AMB-1508

## Status

Green for the bounded native public refresh target registry.

Overall Source Atlas remains Yellow.

## Scope Completed

- Added `SourceAtlasPublicPackRefreshTargetRegistry` under canonical `Core/Persistence` ownership.
- Added registry entry, status, issue, finding, and resolution models for governed public lifecycle refresh targets.
- Registry entries declare public domain, channel, schema version, app version, optional public locale, target pack ID, environment, allowed lifecycle modes, review/activation status, review artifact, and non-claims.
- Registry selection is deterministic and stable ordered by target ID.
- Registry selection includes only active entries allowed for the requested lifecycle mode.
- Registry validation rejects duplicate target IDs, disabled/review-required/blocked targets, mode-disallowed targets, unsafe targets, private-looking target metadata, and unsafe manifest request shapes.
- `SourceAtlasPublicPackLifecycleRefreshService` now consumes registry resolution at refresh time and keeps legacy direct target initialization as an active-entry compatibility path for tests and narrow call sites.
- `AppContainer` and `AppContainerFactory` now build the lifecycle refresh service from `SourceAtlasPublicPackRefreshTargetRegistry.defaultAppRegistry()`.
- Default app registry remains empty until a public target is explicitly approved, preserving no-network-by-default local behavior.
- Focused tests cover active target selection, inactive/mode-blocked exclusion, private target rejection before selection, duplicate ID rejection, Codable stability, registry-backed lifecycle service behavior, and app-factory wiring.

## Files Changed

- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRefreshTargetRegistry.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackLifecycleRefreshService.swift`
- `Native/Ambitions/App/AppContainer.swift`
- `Native/Ambitions/App/AppContainerFactory.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRefreshTargetRegistryTests.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift`
- `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-train-22.md`
- `docs/qa/source-atlas/native/source-atlas-native-public-refresh-target-registry-train-22.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- Registry target metadata is limited to public pack routing fields.
- No goal text, capture text, schedule, proof, receipt, account ID, device ID, private context, private graph data, behavior history, inferred priority, or personalized segment is introduced.
- No final personalized plans, schedules, Step lists, priority order, recovery path, or proof interpretation are generated.
- Empty default app registry performs no transport and does not block offline/no-account local planning.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `App`, `Core/Persistence`.
- Files moved or created: created `SourceAtlasPublicPackRefreshTargetRegistry.swift`, `SourceAtlasPublicPackRefreshTargetRegistryTests.swift`, and Train 22 QA evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: the default app registry contains no approved production target entries yet; real `BGTaskScheduler` registration and identifier proof remain deferred.
- Next repair train if debt remains: add owner-approved public target entries and/or real background task registration/identifier proof under canonical ownership.
- No equivalent folder/path interpretation was used.

## Apple Platform Source Atlas

- No new Apple framework or API was introduced.
- The train touches app startup/maintenance wiring and local persistence configuration only.
- iOS 26 availability: no new iOS API availability claim.
- BackgroundTasks proof remains not run and not claimed.

## Validation Run

- `xcodegen generate` - passed.
- XcodeBuildMCP focused XCTest: `SourceAtlasPublicPackRefreshTargetRegistryTests`, `SourceAtlasPublicPackLifecycleRefreshServiceTests`, and `AppContainerFactoryTests/testAppContainerExposesRuntimeWhilePreservingIPhoneServiceFacade` - 9 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T00-41-21-729Z_pid24471_72dbadb1.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T00-41-21-729Z_pid24471_f9d3d8b3.xcresult`
- XcodeBuildMCP adjacent public-pack persistence suites - 50 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T00-45-41-396Z_pid24471_a11ed9e6.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T00-45-41-396Z_pid24471_0d615176.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 125 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260628T004800Z/extract/summary.json`
- `git diff --check` - passed before QA evidence write.

## Validation Not Run

- No owner-approved production target registry population.
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

- Source Atlas status ceiling: Green for Train 22 native public refresh target registry only; Yellow overall Source Atlas.
- R2 request privacy proof: registry resolution validates target metadata and manifest request shape before lifecycle refresh transport.
- No private graph egress proof: no-private egress audit passed; focused tests prove private-looking registry targets are excluded before selection and transport.
- License/terms proof: unchanged; no new source lane, legal registry, source claim, or pack eligibility decision added.
- Restricted-source exclusion proof: unchanged; registry can block unapproved targets but this train does not add a restricted-source source lane.
- Provenance completeness proof: unchanged; no claim graph or packable claim path added.
- Freshness/revocation proof: unchanged; selected targets still delegate to existing public pack refresh/fetch/cache validation paths; adjacent public-pack persistence suites passed.
- LKG/rollback proof: unchanged; this train does not add production LKG pointer or rollback behavior.
- Native offline/no-account proof: focused tests prove the default app registry is empty, zero-transport, and non-blocking; registry-backed lifecycle refresh can also use offline public-pack paths without private context.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no real BackgroundTasks registration, no approved production target population.

## Known Risks

- Public target population remains a separate owner/legal/product approval step.
- Real background scheduling remains unproven.
- Device/offline proof remains required before release claims.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 22 artifact only claims the files listed above.

## Follow-Up Required

- Add an owner-approved public target entry only after production/staging channel, legal/terms, and product approval are explicit.
- Add real `BGTaskScheduler` registration/identifier proof under canonical ownership once scoped.
- Run physical-device/offline proof before any release or runtime Green claim.

## Rollback Plan

- Remove `SourceAtlasPublicPackRefreshTargetRegistry.swift`.
- Restore `SourceAtlasPublicPackLifecycleRefreshService` to direct target-list storage only.
- Restore `AppContainer` and `AppContainerFactory` lifecycle service defaults to direct empty target initialization.
- Remove Train 22 XCTest additions and QA evidence.
- Retain prior Train 21 lifecycle runner behavior and prior public-pack cache/fetch/background task paths.
