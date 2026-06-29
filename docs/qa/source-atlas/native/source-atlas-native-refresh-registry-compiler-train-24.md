# Source Atlas Native Refresh Registry Compiler - Train 24

Date: 2026-06-28
Linear: AMB-1510

## Status

Green for the bounded Foundry native refresh registry artifact compiler.

Overall Source Atlas remains Yellow.

## Scope Completed

- Added `tools/source-atlas/foundry/native_refresh_registry.py`.
- Added the `native-refresh-registry` Foundry CLI command.
- Compiled validated public R2 publisher reports into the Train 23 native artifact shape: `SourceAtlasPublicPackRefreshTargetRegistryArtifact`.
- Generated deterministic artifact output at `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/source-atlas-public-refresh-targets.json`.
- Generated deterministic compiler report and closeout under `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/`.
- Default generated targets are `review_required`, not active.
- Active targets require an explicit approval artifact.
- Unsafe publisher reports, private object keys, invalid reports, and non-public pointer posture are blocked before registry target emission.
- Artifact-level non-claims are native-loader-safe and avoid private-metadata scanner tokens.
- Added Python tests for default review-required generation, active approval gating, active approval recording, private publisher report blocking, and invalid publisher report blocking.
- Added Swift compatibility coverage proving the generated Train 24 artifact decodes through the native Train 23 loader and selects no refresh target while review-required.

## Files Changed

- `tools/source-atlas/foundry/native_refresh_registry.py`
- `tools/source-atlas/foundry/cli.py`
- `tools/source-atlas/foundry/tests/test_native_refresh_registry_train_24.py`
- `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/source-atlas-public-refresh-targets.json`
- `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/native-refresh-registry-report.json`
- `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/closeout.md`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-refresh-registry-compiler-train-24.md`
- `docs/qa/source-atlas/native/source-atlas-native-refresh-registry-compiler-train-24.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- Generated registry artifacts contain public pack routing metadata only.
- No goal text, capture text, schedule, proof payload, receipt payload, account ID, device ID, private context, private graph data, behavior history, inferred priority, or personalized segment is introduced.
- No final personalized plans, schedules, Step lists, priority order, recovery path, or proof interpretation are generated.
- Review-required default prevents silent native refresh activation.
- Missing owner-approved active target artifacts still leave Ambitions usable offline with no account.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: none in app source; test coverage exercises `Core/Persistence`.
- Non-canonical owners touched: none.
- Files moved or created: created Foundry compiler/test/generated artifacts and Train 24 QA evidence; updated existing native loader test.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: no owner-approved bundled active registry artifact; no real `BGTaskScheduler` registration, identifier, launch, or background execution proof.
- Next repair train if debt remains: owner-approved public registry artifact population or real background registration proof under canonical ownership.
- No equivalent folder/path interpretation was used.

## Apple Platform Source Atlas

- No new Apple framework or API was introduced.
- The only native change is XCTest compatibility coverage for an existing `Core/Persistence` loader.
- iOS 26 availability: no new iOS API availability claim.
- BackgroundTasks proof remains not run and not claimed.

## Validation Run

- `python3 -m pytest tools/source-atlas/foundry/tests/test_native_refresh_registry_train_24.py -q` - 5 passed.
- `python3 tools/source-atlas/source-atlas-foundry.py native-refresh-registry --publisher-report tools/source-atlas/generated/r2-publisher/train-10-civic-local-simulation/r2-publisher-report.json --output-root tools/source-atlas/generated/native-refresh-registry/train-24-fixture --created-at 2026-06-28T00:00:00Z --app-version 1.0 --public-locale en-US` - passed.
- `xcodegen generate` - passed.
- XcodeBuildMCP focused XCTest: `SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests` - 7 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T01-20-31-703Z_pid24471_153f8590.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T01-20-31-703Z_pid24471_f0de7dc1.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 130 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260628T012255Z/extract/summary.json`
- `git diff --check` - passed after QA evidence write.

## Validation Not Run

- No owner-approved active public registry artifact population.
- No real `BGTaskScheduler` registration, identifier, launch, or background execution proof.
- No production R2 upload/readback.
- No physical-device/offline runtime proof.
- No visual, accessibility, TestFlight, App Store, or release readiness proof.
- No legal/terms approval beyond existing stored registry artifacts.

## Proof Artifacts

- Generated artifact: `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/source-atlas-public-refresh-targets.json`
- Compiler report: `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/native-refresh-registry-report.json`
- Compiler closeout: `tools/source-atlas/generated/native-refresh-registry/train-24-fixture/closeout.md`
- Focused XCTest log and result bundle listed above.
- Build-for-testing summary listed above.
- This closeout note and structured JSON proof ceiling.

## Additional Source Atlas Fields

- Source Atlas status ceiling: Green for Train 24 Foundry native refresh registry artifact compiler only; Yellow overall Source Atlas.
- R2 request privacy proof: compiler emits only domain, channel, schema version, app version, optional public locale, target pack ID, and environment; object keys from publisher reports are checked before target emission.
- No private graph egress proof: Source Atlas no-private audit passed; private publisher report test proves private object keys emit no native targets.
- License/terms proof: inherited from validated publisher and pack artifacts; no new legal approval or source lane decision added.
- Restricted-source exclusion proof: inherited from upstream publisher/pack artifacts; this compiler does not re-admit excluded source data.
- Provenance completeness proof: inherited from upstream publisher and pack manifest; no new claim graph or packable claim path added.
- Freshness/revocation proof: target routing points at current-pointer/freshness infrastructure from validated publisher output; no freshness claim is upgraded.
- LKG/rollback proof: inherited from publisher report; this compiler does not publish or roll back R2 objects.
- Native offline/no-account proof: generated fixture decodes through the native loader as review-required and selects no refresh target; local planning remains unblocked.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no real BackgroundTasks registration, no approved active registry artifact population.

## Known Risks

- Active native registry artifacts remain blocked without owner/legal/product approval.
- Real background scheduling remains unproven.
- Device/offline proof remains required before release claims.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 24 artifact only claims the files listed above.

## Follow-Up Required

- Add an owner-approved bundled active public registry artifact only after production/staging channel, legal/terms, source governance, and product approval are explicit.
- Add real `BGTaskScheduler` registration/identifier proof under canonical ownership once scoped.
- Run physical-device/offline proof before any release or runtime Green claim.

## Rollback Plan

- Remove `tools/source-atlas/foundry/native_refresh_registry.py`.
- Remove the `native-refresh-registry` CLI command.
- Remove `tools/source-atlas/foundry/tests/test_native_refresh_registry_train_24.py`.
- Remove generated Train 24 native refresh registry artifacts.
- Remove the Train 24 Swift compatibility test case and QA evidence.
- Retain prior Train 23 loader behavior and prior public-pack cache/fetch/background task paths.
