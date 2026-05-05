# PD16 Schedule, Availability, and Planning Defaults Depth Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: Product Depth
Batch ID: PD16

## Result

PD16 completed as a bounded You/Profile implementation batch. You now exposes a typed planning-defaults center that explains why schedule, availability, planning defaults, away time, and automation posture matter to Plan recommendations without requesting permissions, claiming unsupported calendar/reminder behavior, or pressuring setup completion.

## Files Read

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/batches/PD16_Schedule_Availability_And_Planning_Defaults_Depth_Prompt.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileRootSurface.swift`
- `Native/Ambitions/Features/Profile/ProfileTrustHistoryCenterCard.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`

## Files Changed

- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Domain/ProfilePlanningDefaultsModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfilePlanningDefaultsSectionCard.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- `docs/audits/pd16-schedule-availability-planning-defaults-depth-report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Implementation Summary

- Added `ProfilePlanningDefaultsCenterState` and section/preference models for You-owned planning setup depth.
- Projected Schedule & Availability, Planning Defaults, Vacation / Away Time, and Automation & Trust from `RepositoryBackedProfileService`.
- Replaced static planning-detail sheet content with a typed reusable `ProfilePlanningDefaultsSectionCard`.
- Added a focused Profile service test proving the planning-defaults center explains usefulness without setup pressure, unsupported calendar/reminder claims, or forbidden AI/productivity copy.

## Product Decisions Preserved

- Top-level tabs remain `Today / Goals / Capture / Plan / You`.
- You remains trust/control-first and Profile remains an internal compatibility seam.
- Calendar awareness remains Plan-owned and does not request permission from this You setup surface.
- Guided automation remains the default.
- Open time is not automatically filled.
- Away time is protected by default unless the user explicitly chooses otherwise.
- Receipts remain consequence/review posture, not notification/feed posture.

## Caveats Preserved

- This batch does not implement FCP17 Schedule / Availability / Defaults Center.
- This batch does not add calendar/reminder integration behavior, calendar writes, permission prompts, persistence/schema changes, route/raw-value changes, sync/account behavior, AOS runtime, or LDI runtime.
- Product Depth is not complete until PD18 closes.
- Public accessibility conformance, physical-device proof, TestFlight readiness, App Store readiness, legal/privacy compliance, and release readiness remain unclaimed.
- Existing large Profile files remain a maintainability advisory; PD16 mitigated new growth by adding small model/card files, but later ME/FCP work should continue extraction.

## Candidate Items

No Candidate items were finalized. PD16 did not promote future Schedule / Availability / Defaults Center behavior beyond the named Product Depth scope.

## Conflicts Found

No unrecoverable conflicts. The known Product Experience Pack caveats remain:

- Accent taxonomy/default mismatch remains Yellow and out of scope.
- MissionControlTimeSpine order was not touched.
- User-facing copy remediation remains staged.
- Month LifeShape calendar-clone risk was not touched.

## Validation

Commands run:

- `git status --short`
- `xcodegen generate`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/ProfileFeatureServiceTests`

Initial repair loop:

- First focused test attempt did not pass because the new model file needed
  `AmbitionsDesignSystem`.
- Second focused test attempt did not pass because semantic state cases were
  used where `AmbitionVisualState` was required.
- Both issues were repaired in scope and the focused Profile test lane was rerun.

Focused result:

- `ProfileFeatureServiceTests`: 22 tests, 0 failures.

Additional validation:

- `scripts/build-local.sh`: PASS.
- `git diff --check`: PASS.
- Product Depth prompt scans: PASS WITH YELLOW. Hits are historical guardrails,
  forbidden-claim lists, and current train-state truth.
- Touched-path copy/accessibility/product-drift scans: PASS WITH YELLOW. Hits
  are existing internal enum/state names or test guard assertions; no new
  user-facing forbidden copy was introduced.
- Touched-doc trailing whitespace scan: PASS.
- `scripts/run-doc-qa.sh || true`: PASS WITH ADVISORY. Lychee returned 650 OK
  and 0 errors; markdown/stale/deprecated-language backlog remains pre-existing.
- `scripts/batch-train-gate-check.sh || true`: PASS WITH YELLOW. The only
  current hint is expected dirty-worktree state before commit.

## Remaining Yellow Items

- Existing Profile implementation files are large. PD16 touched `ProfileFeatureService.swift` and `ProfileScreen.swift` narrowly and added extracted files for new state/card ownership, but broader file-size repair belongs to a later maintainability or FCP objectization batch.

## Rollback Path

Revert the PD16 commit to remove the planning-defaults center model, Profile service projection, detail-card wiring, focused test, audit report, and train-state documentation updates.

## Next Eligible Batch

PD17 Cross-Surface Proof And Review Integration is next if PD16 commits, pushes, the worktree is clean, and global/Product Depth continuation gates allow it.
