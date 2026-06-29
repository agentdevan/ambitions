# Source Atlas Native Review-Required Bundled Registry - Train 25

Date: 2026-06-28
Linear: AMB-1511

## Status

Green for the bounded native bundled review-required refresh registry artifact path.

Overall Source Atlas remains Yellow.

## Scope Completed

- Bundled the Train 24 generated review-required registry artifact into the Ambitions app resources at `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`.
- Updated `project.yml` so XcodeGen emits the asset catalog, privacy manifest, and Source Atlas registry artifact as explicit resources build-phase entries.
- Regenerated `Ambitions.xcodeproj` with a real `PBXResourcesBuildPhase` containing `source-atlas-public-refresh-targets.json`.
- Kept the default native loader pointed at the app artifact name `source-atlas-public-refresh-targets.json`.
- Added bundle lookup robustness for the default artifact resource while preserving missing-custom-resource fallback behavior.
- Proved the bundled artifact exactly matches the generated Train 24 fixture artifact.
- Proved the built simulator app contains `source-atlas-public-refresh-targets.json`.
- Added focused native tests proving the default bundled artifact loads as review-required, selects no target, emits no private egress findings, generates no final plan/schedule/Step list, and does not block local planning.
- Updated the app-container lifecycle test so startup offline refresh sees the review-required registry entry, selects no targets, and leaves core local behavior unblocked.

## Files Changed

- `project.yml`
- `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests.swift`
- `Native/AmbitionsTests/App/AppContainerFactoryTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-review-required-bundled-registry-train-25.md`
- `docs/qa/source-atlas/native/source-atlas-native-review-required-bundled-registry-train-25.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- The bundled artifact contains public pack routing metadata only.
- The bundled artifact is review-required and does not activate transport.
- No goal text, capture text, schedule, proof payload, receipt payload, account ID, device ID, private context, private graph data, behavior history, inferred priority, or personalized segment is introduced.
- No final personalized plans, schedules, Step lists, priority order, recovery path, or proof interpretation are generated.
- Missing owner-approved active targets leave Ambitions usable offline with no account.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Persistence` for artifact loading; app resource wiring through `project.yml`.
- Non-canonical owners touched: none.
- Files moved or created: created the app resource artifact and Train 25 QA evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: no owner-approved active registry target, no production R2 promotion proof, no real background scheduler execution proof, and no device/offline release proof.
- Next repair train if debt remains: owner-approved active target gating or native scheduling/device proof under canonical ownership.
- No equivalent folder/path interpretation was used.

## Apple Platform Source Atlas

- No new Apple framework or runtime API was introduced.
- XcodeGen now emits the app resource build phase for the existing resource set plus the Source Atlas registry artifact.
- iOS 26 availability: no new iOS API availability claim.
- BackgroundTasks proof remains not run and not claimed.

## Validation Run

- `xcodegen generate` - passed.
- Generated project resource proof - passed.
  - `PBXResourcesBuildPhase` present.
  - `source-atlas-public-refresh-targets` present in generated `.pbxproj`.
- `cmp -s Native/Ambitions/Resources/source-atlas-public-refresh-targets.json tools/source-atlas/generated/native-refresh-registry/train-24-fixture/source-atlas-public-refresh-targets.json` - passed.
- `python3 -m json.tool Native/Ambitions/Resources/source-atlas-public-refresh-targets.json` - passed.
- Built app resource proof - passed.
  - `output/DerivedData-XcodeBuildMCP/Build/Products/Debug-iphonesimulator/Ambitions.app/source-atlas-public-refresh-targets.json` exists.
- XcodeBuildMCP focused XCTest:
  - Command: `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests -only-testing:AmbitionsTests/AppContainerFactoryTests/testAppContainerExposesRuntimeWhilePreservingIPhoneServiceFacade`
  - Status: passed after the MCP call timed out while `xcodebuild` continued; the polled log shows `TEST EXECUTE SUCCEEDED`.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T01-45-12-348Z_pid24471_6fec78a5.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T01-45-12-348Z_pid24471_8a728c80.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 130 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260628T015522Z/extract/summary.json`
  - Result bundle: `.codex/xcode-results/green-standard/20260628T015522Z-bft-74413-18369/build-for-testing.xcresult`
  - Build output explicitly copied `source-atlas-public-refresh-targets.json`.
- `git diff --check` - passed.

## Validation Not Run

- No owner-approved active public registry target population.
- No live public pack transport from the bundled target.
- No production R2 upload/readback.
- No stable-channel write.
- No physical-device/offline runtime proof.
- No visual, accessibility, TestFlight, App Store, or release readiness proof.
- No new legal/terms approval.

## Proof Artifacts

- Bundled app resource: `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`
- Upstream generated source artifact: `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/source-atlas-public-refresh-targets.json`
- Focused XCTest log and result bundle listed above.
- Build-for-testing summary and result bundle listed above.
- This closeout note and structured JSON proof ceiling.

## Additional Source Atlas Fields

- Source Atlas status ceiling: Green for Train 25 native bundled review-required registry artifact path only; Yellow overall Source Atlas.
- R2 request privacy proof: no R2 request is emitted by this train; the bundled review-required artifact selects no target and carries public routing metadata only.
- No private graph egress proof: no-private egress audit passed; loader and lifecycle tests prove no private runtime context, final plan, final schedule, or Step list generation.
- License/terms proof: inherited from the Train 24 generated artifact and upstream publisher/pack artifacts; no new legal approval or source lane decision added.
- Restricted-source exclusion proof: inherited from upstream publisher/pack artifacts; this train does not re-admit excluded source data.
- Provenance completeness proof: inherited from upstream publisher and pack manifest; no new claim graph or packable claim path added.
- Freshness/revocation proof: no freshness or revocation claim is upgraded; review-required target remains inactive.
- LKG/rollback proof: no R2 object, stable pointer, LKG pointer, or rollback operation is changed.
- Native offline/no-account proof: focused app-container offline startup sees one review-required entry, selects no targets, and reports `coreLocalPlanningBlocked == false`.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no active registry target approval, no real BackgroundTasks execution proof.

## Known Risks

- The bundled artifact is review-required only; it does not prove active remote refresh.
- Real background scheduling and device/offline runtime proof remain unproven.
- Production R2 promotion, legal/terms approval, and app release readiness remain out of scope.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 25 artifact only claims the files listed above.

## Follow-Up Required

- Add owner-approved active target gating only after production/staging channel, legal/terms, source governance, and product approval are explicit.
- Add real scheduling/device/offline proof before any runtime or release Green claim.
- Keep the review-required bundled artifact inactive until approval artifacts exist.

## Rollback Plan

- Remove `Native/Ambitions/Resources/source-atlas-public-refresh-targets.json`.
- Revert the `project.yml` explicit resource build-phase entries to the prior resource wiring if needed.
- Revert the default loader bundle lookup robustness change.
- Revert Train 25 test expectation updates.
- Remove this Train 25 QA evidence.
- Retain prior Train 24 generated artifact and prior default fallback behavior.
