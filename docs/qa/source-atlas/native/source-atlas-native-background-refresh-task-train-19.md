# Source Atlas Native Background Refresh Task Contract - Train 19

Date: 2026-06-27
Linear: AMB-1505

## Status

Green for the bounded native Source Atlas background refresh task contract.

Overall Source Atlas remains Yellow.

## Scope Completed

- Added `SourceAtlasPublicPackBackgroundRefreshTask` under `Core/Persistence`.
- Added a static public task identifier allow-list for Source Atlas public pack refresh.
- Added task metadata validation before any remote transport or repository mutation.
- Constructed only anonymous public Source Atlas manifest requests from task input.
- Delegated accepted task input to the existing `SourceAtlasPublicPackAppRefreshCoordinator`.
- Proved offline/no-account cached public fallback remains non-blocking.
- Proved online public refresh still passes through existing manifest/hash/cache gates.
- Proved unsafe task identifiers, private manifest metadata, and private target pack metadata stop before transport or persistence.

## Files Changed

- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackBackgroundRefreshTask.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackBackgroundRefreshTaskTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-background-refresh-task-train-19.md`
- `docs/qa/source-atlas/native/source-atlas-native-background-refresh-task-train-19.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- No private user goal, capture, schedule, proof, account, device, or private graph context is added to Source Atlas requests.
- The task contract does not generate final plans, final schedules, Step lists, or personalized cloud output.
- The offline/no-account path remains usable and does not block local planning.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Persistence`.
- Files moved or created: created a persistence-owned task contract and test.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: actual BackgroundTasks/App lifecycle registration is not implemented in this train. No `Core/Background` owner exists in the live Final Architecture Tree, so this train keeps the deterministic refresh contract in `Core/Persistence`.
- Next repair train if debt remains: app lifecycle/background scheduling integration only after canonical ownership is approved and can be tested.
- No equivalent folder/path interpretation was used.

## Validation Run

- `xcodegen generate` - passed.
- XcodeBuildMCP focused XCTest: `AmbitionsTests/SourceAtlasPublicPackBackgroundRefreshTaskTests` - 5 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T23-47-34-930Z_pid24471_97230978.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T23-47-34-930Z_pid24471_0e3d6b50.xcresult`
- XcodeBuildMCP adjacent public-pack persistence suites - 39 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-27T23-50-25-907Z_pid24471_f685360b.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-27T23-50-25-907Z_pid24471_922496be.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 125 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260627T235243Z/extract/summary.json`
- `git diff --check` - passed.

## Validation Not Run

- No real `BGTaskScheduler` registration or launch lifecycle test.
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

- Source Atlas status ceiling: Green for Train 19 native task contract only; Yellow overall Source Atlas.
- R2 request privacy proof: task input validates task identifier/domain/channel/schema/app version/locale/target pack metadata before transport; tests prove private-looking task and pack metadata stop before remote fetch.
- No private graph egress proof: no-private audit passed; focused tests assert unsafe metadata has zero transport calls.
- License/terms proof: unchanged; no new source lane, legal registry, or pack eligibility decision added.
- Restricted-source exclusion proof: unchanged; no restricted source path added.
- Provenance completeness proof: unchanged; no claim graph or packable claim path added.
- Freshness/revocation proof: delegated to existing public-pack fetch/cache/revocation path; adjacent suites passed.
- LKG/rollback proof: delegated to existing public-pack fetch/cache path; no new production LKG pointer behavior added.
- Native offline/no-account proof: focused test proves cached public pack can be used without transport and without blocking local planning.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no real BackgroundTasks registration.

## Known Risks

- The app still needs a separately scoped, architecture-approved train for actual background task registration and lifecycle invocation.
- Device/offline behavior still needs real-device proof before any release claim.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 19 artifact only claims the files listed above.

## Follow-Up Required

- Decide canonical owner for actual app background scheduling before implementing `BGTaskScheduler` registration.
- Wire the task contract into app startup/background lifecycle only with request-shape tests and no-private-egress proof.

## Rollback Plan

- Remove `SourceAtlasPublicPackBackgroundRefreshTask.swift`.
- Remove `SourceAtlasPublicPackBackgroundRefreshTaskTests.swift`.
- Remove this Train 19 QA evidence.
- Retain existing app refresh/cache/fetch/revocation behavior from earlier trains.
