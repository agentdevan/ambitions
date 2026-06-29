# Source Atlas Native Latest Cached Public Pack Lookup - Train 20

Date: 2026-06-28
Linear: AMB-1506

## Status

Green for the bounded native latest cached public pack lookup.

Overall Source Atlas remains Yellow.

## Scope Completed

- Added public-safe latest cached manifest lookup to `SourceAtlasPublicPackCacheFileRepository`.
- Latest lookup validates pack ID metadata against no-private-graph egress rules before scanning cache indexes.
- Latest lookup scans only hashed public cache index artifacts under the Source Atlas public-pack cache namespace.
- Latest lookup filters to verified indexes whose cached manifest can still pass readback/hash/decode validation.
- Latest lookup chooses the most recently committed verified index deterministically.
- `SourceAtlasPublicPackBackgroundRefreshTask` now uses latest cached public manifest lookup when no explicit cached manifest lookup is supplied.
- Offline/no-account background refresh can recover a latest verified cached public pack without remote transport and without caller-provided manifest version/SHA.
- Private-looking pack IDs do not produce latest cache lookups.

## Files Changed

- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackCacheFileRepository.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackBackgroundRefreshTask.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackCacheFileRepositoryTests.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackBackgroundRefreshTaskTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-latest-cached-public-pack-lookup-train-20.md`
- `docs/qa/source-atlas/native/source-atlas-native-latest-cached-public-pack-lookup-train-20.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- Latest lookup uses public pack ID metadata only.
- No goal text, capture text, schedule, proof, account ID, device ID, private context, or private graph data is introduced.
- No final plans, schedules, Step lists, or personalized paths are generated.
- Offline/no-account behavior remains non-blocking for local planning.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Persistence`.
- Files moved or created: no source file moves; created Train 20 QA evidence.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: actual app lifecycle/BGTaskScheduler registration remains deferred; this train closes the cache discovery prerequisite.
- Next repair train if debt remains: architecture-approved app lifecycle/background scheduling integration using the latest cached public lookup.
- No equivalent folder/path interpretation was used.

## Validation Run

- `xcodegen generate` - passed.
- XcodeBuildMCP focused XCTest: `SourceAtlasPublicPackCacheFileRepositoryTests` and `SourceAtlasPublicPackBackgroundRefreshTaskTests` - 15 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T00-02-53-094Z_pid24471_4fdc9691.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T00-02-53-094Z_pid24471_4e429bf8.xcresult`
- XcodeBuildMCP adjacent public-pack persistence suites - 42 passed.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T00-05-04-879Z_pid24471_2e7292ab.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T00-05-04-879Z_pid24471_1c732c57.xcresult`
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 125 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260628T000720Z/extract/summary.json`
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

- Source Atlas status ceiling: Green for Train 20 native latest cached public pack lookup only; Yellow overall Source Atlas.
- R2 request privacy proof: lookup uses public pack ID metadata only and rejects private-looking pack IDs before selecting cache metadata.
- No private graph egress proof: no-private audit passed; focused tests cover private pack ID rejection and zero-transport offline cache recovery.
- License/terms proof: unchanged; no new source lane, legal registry, or pack eligibility decision added.
- Restricted-source exclusion proof: unchanged; no restricted source path added.
- Provenance completeness proof: unchanged; no claim graph or packable claim path added.
- Freshness/revocation proof: cached manifest selection still flows through existing manifest/hash/decode validation; adjacent suites passed.
- LKG/rollback proof: unchanged; this train does not add production LKG pointer behavior.
- Native offline/no-account proof: focused test proves background refresh can discover latest cached public pack without explicit manifest lookup or transport.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no real BackgroundTasks registration.

## Known Risks

- Actual app lifecycle/background scheduling remains separate and unproven.
- Device/offline proof remains required before release claims.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 20 artifact only claims the files listed above.

## Follow-Up Required

- Wire lifecycle/startup/background invocation to the refresh task using public configuration only.
- Add request-shape proof for configured public endpoint and pack target lists.
- Keep physical-device/background execution proof separate from source-level proof.

## Rollback Plan

- Remove `latestManifestLookup(packID:)` from `SourceAtlasPublicPackCacheFileRepository`.
- Remove the implicit latest lookup fallback from `SourceAtlasPublicPackBackgroundRefreshTask`.
- Remove the Train 20 test additions and QA evidence.
- Retain explicit cached-manifest lookup behavior from prior trains.
