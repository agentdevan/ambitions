# Source Atlas Native Active Target Approval Gate - Train 26

Date: 2026-06-28
Linear: AMB-1512

## Status

Green for the bounded native active refresh target approval gate.

Overall Source Atlas remains Yellow.

## Scope Completed

- Added `missing_approval_artifact` as a native registry and lifecycle refresh issue.
- Required active registry entries to carry a non-empty public-safe review/approval artifact pointer before target selection.
- Normalized empty review artifact IDs to `nil`.
- Added registry metadata egress scanning for review artifact IDs and non-claims.
- Blocked private-looking approval artifact metadata before target selection.
- Changed the convenience `targets:` lifecycle initializer so direct target injection stays `review_required` instead of silently active.
- Preserved explicit registry-based active selection for approved public targets only.
- Added focused native tests for:
  - active target with approval remains selectable;
  - active target without approval is excluded before transport;
  - private approval artifact metadata is rejected before selection;
  - direct target initializer stays review-required and performs zero transport;
  - lifecycle refresh reports `missing_approval_artifact` and performs zero transport;
  - bundled review-required artifact and app-container defaults remain inactive.

## Files Changed

- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackRefreshTargetRegistry.swift`
- `Native/Ambitions/Core/Persistence/SourceAtlasPublicPackLifecycleRefreshService.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackRefreshTargetRegistryTests.swift`
- `Native/AmbitionsTests/Persistence/SourceAtlasPublicPackLifecycleRefreshServiceTests.swift`
- `docs/qa/source-atlas/native/source-atlas-native-active-target-approval-gate-train-26.md`
- `docs/qa/source-atlas/native/source-atlas-native-active-target-approval-gate-train-26.json`

## Product Law Preserved

- R2 remains public/reference/freshness infrastructure only.
- Native refresh target selection still emits no private user context.
- Missing approval, private-looking metadata, review-required status, unsafe targets, duplicate target IDs, and mode mismatches are excluded before transport.
- No goal text, capture text, schedule, proof payload, receipt payload, account ID, device ID, private context, private graph data, behavior history, inferred priority, or personalized segment is introduced.
- No final personalized plans, schedules, Step lists, priority order, recovery path, or proof interpretation are generated.
- Offline/no-account local planning remains unblocked.

## Final Architecture Tree

- Final Architecture Tree inspected: yes.
- Canonical owners touched: `Core/Persistence`.
- Non-canonical owners touched: none.
- Files moved or created: created Train 26 QA evidence only.
- Old/non-canonical paths removed: none.
- Compatibility shims left behind: none.
- Yellow architecture debt: no owner-approved active production target artifact, no production R2 promotion proof, no real background scheduler execution proof, and no device/offline release proof.
- Next repair train if debt remains: approved active target artifact plus live/staging transport proof under canonical ownership.
- No equivalent folder/path interpretation was used.

## Apple Platform Source Atlas

- No new Apple framework or runtime API was introduced.
- No new BackgroundTasks, networking framework, entitlement, or permission path was added.
- iOS 26 availability: no new iOS API availability claim.
- BackgroundTasks proof remains not run and not claimed.

## Validation Run

- XcodeBuildMCP focused XCTest:
  - Command: `test_sim -only-testing:AmbitionsTests/SourceAtlasPublicPackRefreshTargetRegistryTests -only-testing:AmbitionsTests/SourceAtlasPublicPackLifecycleRefreshServiceTests -only-testing:AmbitionsTests/SourceAtlasPublicPackRefreshTargetRegistryArtifactLoaderTests -only-testing:AmbitionsTests/AppContainerFactoryTests/testAppContainerExposesRuntimeWhilePreservingIPhoneServiceFacade`
  - Status: passed, 21 tests.
  - Log: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/logs/test_sim_2026-06-28T02-07-04-795Z_pid24471_392a2ba5.log`
  - Result: `/Users/devan/Library/Developer/XcodeBuildMCP/workspaces/ambitions-822bbc11acdf/result-bundles/test_sim_2026-06-28T02-07-04-795Z_pid24471_95655c7e.xcresult`
- `xcodegen generate` - passed.
- `python3 -m pytest tools/source-atlas/foundry tools/source-atlas/tests` - 130 passed.
- `python3 scripts/source-atlas-boundary-audit.py` - passed.
- `python3 scripts/source-atlas-no-private-graph-egress-audit.py` - passed.
- `python3 scripts/ambitions-green-standard-audit.py` - passed.
- `python3 scripts/ambitions-local-first-boundary-scan.py` - passed.
- `scripts/ambitions-xcode-build-for-testing.sh --batch green-standard` - passed.
  - Summary: `.codex/xcode-summaries/green-standard/20260628T021000Z/extract/summary.json`
- `git diff --check` - passed.

## Validation Not Run

- No owner-approved active production registry artifact population.
- No live public pack transport from an active target.
- No production R2 upload/readback.
- No stable-channel write.
- No physical-device/offline runtime proof.
- No visual, accessibility, TestFlight, App Store, or release readiness proof.
- No source-specific legal/terms approval.

## Proof Artifacts

- Focused XCTest log and result bundle listed above.
- Build-for-testing summary listed above.
- This closeout note and structured JSON proof ceiling.

## Additional Source Atlas Fields

- Source Atlas status ceiling: Green for Train 26 native active-target approval gating only; Yellow overall Source Atlas.
- R2 request privacy proof: no R2 request is emitted by the new missing-approval path; approved active target tests use public-safe request metadata only.
- No private graph egress proof: no-private egress audit passed; registry tests prove private approval artifact metadata is rejected before selection.
- License/terms proof: no new legal approval or source lane decision added.
- Restricted-source exclusion proof: no restricted source is admitted by this train.
- Provenance completeness proof: no claim graph or packable claim path changed.
- Freshness/revocation proof: no freshness or revocation claim is upgraded.
- LKG/rollback proof: no R2 object, stable pointer, LKG pointer, or rollback operation is changed.
- Native offline/no-account proof: focused lifecycle/app-container tests prove missing approval and review-required targets select no transport and keep local planning unblocked.
- Production non-claims: no production R2 readiness, no app runtime/release Green, no legal approval, no universal coverage, no active production registry target, no real BackgroundTasks execution proof.

## Authorization Boundary

The user authorized continued work toward production target, legal approval, live transport, R2 write, runtime/release Green, and governed coverage claims.

This authorization permits creating the next engineering and owner-approval artifacts. It does not itself prove:

- source-specific legal/terms approval;
- outside legal approval;
- production R2 credentials or successful production write/readback;
- device/offline release proof;
- Visual Green or Release Green;
- literal universal coverage.

## Known Risks

- This train gates active target selection but does not create an approved active production target.
- Approval artifact pointers prove deterministic gating only; they are not legal approval.
- Real background scheduling, live/staging transport, R2 stable promotion, and device/offline proof remain unproven.
- Existing worktree contains broader uncommitted Source Atlas trains; this Train 26 artifact only claims the files listed above.

## Follow-Up Required

- Create a source-specific approval packet format that separates owner approval, legal/terms approval, product approval, and security/privacy approval.
- Generate an approved active target artifact only when the relevant approval packet exists.
- Run live/staging transport proof against the approved target with no private context.
- Run R2 upload/readback/SHA-256/revocation/LKG/rollback proof only with current credentials and approval artifacts.

## Rollback Plan

- Remove `missing_approval_artifact` issue cases.
- Revert active-target approval artifact gating.
- Revert direct-target initializer back to its prior behavior if needed.
- Revert Train 26 native tests.
- Remove this Train 26 QA evidence.
- Retain the Train 25 bundled review-required artifact behavior.
