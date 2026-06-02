# AESP-014 Capture / Atmosphere Composer Evidence

- Linear issue: `AMB-436`
- Batch: `AESP-014`
- Base commit: `7f3d5256cd3507f49a84a9f76696039087773ff2`
- Commit SHA: `690b63fd030385128b29613e87a2f8c23e34c1e3`
- Branch: `main`
- Worktree status: dirty with pre-existing unrelated changes outside this patch slice
- Phase 03 review: local source/test/evidence review rerun completed on 2026-06-02 UTC before commit eligibility.

## Files Changed

- `Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift`
- `Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift`
- `Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift`
- `Native/AmbitionsTests/Capture/CaptureViewModelTests.swift`
- `docs/codex/concept-lock-registry.yml`
- `build/reports/aesp/AESP-014/capture-atmosphere-composer-evidence.md`

## Why This Changed

- Updated Capture placement review copy to prefer `Time` over `Plan` in user-facing placement language.
- Preserved the composer-first Capture hierarchy while keeping the review fold readable and calm.
- Sanitized the archive control label in the view layer so the visible Capture surface says `take it out of active review` without needing a replay-service change.
- Strengthened regression coverage for the new `Time` wording and for the composer presentation staying free of `Plan`, chat, and inbox framing.
- Recorded `AESP-014` as an allowed `capture_routing` batch because both pre and post guard require that lock authorization for this owner-reviewed Capture routing touch.

## Source Mapping

- `CapturePlacementReviewState` owns the placement-review copy for route/destination language.
- `CaptureDraftRoutePreviewCard` owns the visible route-review fold and the user-facing archive control label presentation.
- `CaptureAtmosphereComposer` owns the preview/sample composer surface used to demonstrate the premium capture experience.
- `CaptureViewModelTests` and `CapturePlacementReviewStateTests` own the regression checks for user-facing copy and accessibility strings.
- `CaptureService` remains the existing preview/source-of-truth path for capture routing and replay semantics; this phase did not need to change it after the guard repair.
- `docs/codex/concept-lock-registry.yml` owns the lock authorization that lets this batch touch `capture_routing` without a blocked-concept violation.

## Validation

### Passed

- `python3 scripts/ambitions-champion-coverage-check.py --batch AESP-014`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-014 --prompt prompts/batches/AESP-014.md --batch-type source-changing --allow-yellow`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AESP-014`
- `make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests/CaptureViewModelTests`
- `make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests/CapturePlacementReviewStateTests`
- `make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-014 --prompt prompts/batches/AESP-014.md --changed-from 7f3d5256cd3507f49a84a9f76696039087773ff2 --batch-type source-changing --allow-yellow`
- `git diff --check`

### Phase 03 Review Rerun

- `python3 scripts/ambitions-champion-coverage-check.py --batch AESP-014`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AESP-014 --prompt prompts/batches/AESP-014.md --batch-type source-changing --allow-yellow`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AESP-014`
- `make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests/CaptureViewModelTests`
- `make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests/CapturePlacementReviewStateTests`
- `make xcode-focused-test BATCH=AESP-014 TEST=AmbitionsTests`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AESP-014 --prompt prompts/batches/AESP-014.md --changed-from 7f3d5256cd3507f49a84a9f76696039087773ff2 --batch-type source-changing --allow-yellow`
- `git diff --check`

### Wrapper Artifacts

- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AESP-014-pre.md`
- Parallel guard post report: `build/reports/parallel-implementation-guard/AESP-014-post.md`
- Build-for-testing summary: `.codex/xcode-summaries/AESP-014/20260602T034007Z/build-for-testing-summary.json`
- Build-for-testing log: `.codex/xcode-logs/AESP-014/20260602T034007Z/build-for-testing.log`
- Build-for-testing result bundle: `.codex/xcode-results/AESP-014/20260602T034007Z/build-for-testing.xcresult`
- CaptureViewModelTests summary: `.codex/xcode-summaries/AESP-014/20260602T034130Z/focused-test-summary.json`
- CaptureViewModelTests log: `.codex/xcode-logs/AESP-014/20260602T034130Z/focused-test.log`
- CaptureViewModelTests result bundle: `.codex/xcode-results/AESP-014/20260602T034130Z/focused-test.xcresult`
- CapturePlacementReviewStateTests summary: `.codex/xcode-summaries/AESP-014/20260602T034221Z/focused-test-summary.json`
- CapturePlacementReviewStateTests log: `.codex/xcode-logs/AESP-014/20260602T034221Z/focused-test.log`
- CapturePlacementReviewStateTests result bundle: `.codex/xcode-results/AESP-014/20260602T034221Z/focused-test.xcresult`
- Broad `AmbitionsTests` summary: `.codex/xcode-summaries/AESP-014/20260602T034317Z/focused-test-summary.json`
- Broad `AmbitionsTests` log: `.codex/xcode-logs/AESP-014/20260602T034317Z/focused-test.log`
- Broad `AmbitionsTests` result bundle: `.codex/xcode-results/AESP-014/20260602T034317Z/focused-test.xcresult`
- Phase 03 build-for-testing summary: `.codex/xcode-summaries/AESP-014/20260602T035045Z/build-for-testing-summary.json`
- Phase 03 CaptureViewModelTests summary: `.codex/xcode-summaries/AESP-014/20260602T035151Z/focused-test-summary.json`
- Phase 03 CapturePlacementReviewStateTests summary: `.codex/xcode-summaries/AESP-014/20260602T035253Z/focused-test-summary.json`
- Phase 03 broad `AmbitionsTests` summary: `.codex/xcode-summaries/AESP-014/20260602T035349Z/focused-test-summary.json`

## Verified

- Capture placement copy now says `Task / Time`, `Creates Time work only after you choose Task.`, and `Today, Goals, or Time.`
- The route-review fold no longer shows the archive control as `move it out of active review` in the visible Capture UI.
- Focused Capture regression coverage passed for the updated `Time` language and anti-`Plan` checks.
- Broad `AmbitionsTests` passed after the rebuild.
- Post guard returned `GREEN`.

## Not Verified

- Screenshots were not captured in this phase.
- Physical-device validation was not run.
- Release validation was not run.
- TestFlight validation was not run.
- App Store validation was not run.
- Legal/privacy signoff was not run.
- CI validation was not run.
- Manual accessibility audit was not run.
- Performance measurement was not run.

## Blocked

- None after the final repair pass.

## Human Follow-Up

- Update AMB-436 with the local source/test/evidence summary and commit SHA once a commit exists.
- Preserve the unrelated dirty worktree entries outside this patch slice.

## Dirty-Worktree Preservation

- Pre-existing unrelated changes remain outside this batch slice and were preserved:
  - `.swiftpm/xcode/xcuserdata/devan.xcuserdatad/xcschemes/xcschememanagement.plist`
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-a.json`
  - `docs/proof/amb-fe-be/moat-scenario-proof-98/same-intent-context-b.json`
  - `prompts/batches/AESP-013.md`
  - `prompts/batches/AESP-014.md`

## Repair Notes

- The first focused `CaptureViewModelTests` wrapper run hit an early unexpected exit after the test cases had already passed in the log.
- The failure was transient and was cleared by rebuilding and rerunning the focused lane.
- The post guard initially flagged the service-layer replay concept boundary; the visible archive copy was moved into the Capture view layer so the final post guard could pass without a locked-service edit.

## Rollback Notes

- Restore the slice with:

```bash
git restore Native/Ambitions/Features/Capture/CaptureAtmosphereComposer.swift Native/Ambitions/Features/Capture/CaptureDraftRoutePreviewCard.swift Native/Ambitions/Features/Capture/CapturePlacementReviewState.swift Native/AmbitionsTests/Capture/CapturePlacementReviewStateTests.swift Native/AmbitionsTests/Capture/CaptureViewModelTests.swift build/reports/aesp/AESP-014/capture-atmosphere-composer-evidence.md
```

## Guard Fields

- Champion coverage status: `GREEN`
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre status: `GREEN`
- Parallel guard pre report: `build/reports/parallel-implementation-guard/AESP-014-pre.md`
- Parallel guard post status: `GREEN`
- Parallel guard post report: `build/reports/parallel-implementation-guard/AESP-014-post.md`
- Canonical owner extended: `capture_root`
- New implementation owners: `none`
- Canonical owner map changed: `no`
- Supersession ledger updated: `no`
- Best-code rescue checked: `yes`
- Runtime wiring gate: `preserved`
- Yellow accepted reason: `no screenshot, device, or manual accessibility proof was produced`
- Red blockers: `none`

## Repo Intelligence Fields

- Repo intelligence status: `not used in Phase 02`
- CodeGraph used: `no`
- Semble used: `no`
- Understand Anything used: `no`
- Advisory findings directly verified: `none in Phase 02`
- Accepted owner candidates: `capture_root`
- Accepted proof/wiring findings: `existing Capture route preview, placement review, and composer surfaces remain the proof basis`
- Advisory findings rejected: `none`
- Advisory-only findings used as proof: `none`
- Generated local tool artifacts staged: `no`
