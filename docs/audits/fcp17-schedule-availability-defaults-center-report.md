# FCP17 Schedule Availability Defaults Center Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-05
Train: FCP01-FCP30 Flagship Completion Train
Batch: FCP17 Schedule / Availability / Defaults Center
Owner: You / Plan

## Summary

FCP17 implemented a bounded You-owned Availability Center. The center turns
PD16 planning setup depth into a flagship object with hard context, protected
pockets, planning defaults, automation trust controls, duration source proof,
and vacation/away behavior. It appears inside the existing Schedule &
Availability detail sheet and remains review/control-oriented.

No top-level tab, route/raw value, persistence/schema, sync/cloud/account,
calendar writer, permission-request, entitlement, workflow, dependency, AI
runtime, LDI runtime, release, legal/privacy, or public accessibility claim was
changed.

## Files Read

- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/audits/pd16-schedule-availability-planning-defaults-depth-report.md`
- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Domain/ProfilePlanningDefaultsModels.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfilePlanningDefaultsSectionCard.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileRootSurface.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`

## Files Changed

- `Native/Ambitions/Domain/ProfileModels.swift`
- `Native/Ambitions/Domain/ProfilePlanningDefaultsModels.swift`
- `Native/Ambitions/Features/Profile/ProfileAvailabilityCenterCard.swift`
- `Native/Ambitions/Features/Profile/ProfileFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsTests/Profile/ProfileFeatureServiceTests.swift`
- `docs/codex/batches/FCP17_Schedule_Availability_Defaults_Center_Prompt.md`
- `docs/audits/fcp17-schedule-availability-defaults-center-report.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Implementation

- Added `ProfileAvailabilityCenterState` and `ProfileAvailabilityCenterItem`
  as typed domain state.
- Added `ProfileAvailabilityCenterCard` as a small SwiftUI composition for the
  Schedule & Availability detail sheet.
- Projected Availability Center state from `RepositoryBackedProfileService`
  using existing calendar/reminder authorization labels, planning defaults,
  automation policy safety samples, duration source labels, and away behavior.
- Added a focused Profile test proving hard context, protected pockets, capacity
  lenses, Guided automation, confirmation boundaries, vacation/away behavior,
  and forbidden-copy avoidance.

## Product Decisions Preserved

- Top-level IA remains Today / Goals / Capture / Plan / You.
- You remains the Personal System Center; Profile remains internal
  compatibility.
- Calendar awareness remains Plan-owned.
- You does not request calendar/reminder permission.
- Open time is not automatically filled.
- Vacation is not free time unless marked available.
- Guided automation is default.
- Duration source is explicit.
- Day / Week / Month remain capacity lenses, not calendar modes.

## Accessibility / Reduced Motion

The new card uses combined accessibility rows with labels, values, and hints.
It does not add gesture-only controls, motion-only meaning, color-only meaning,
or animation-specific behavior. Public accessibility conformance remains
unclaimed without manual/device proof.

## Privacy / Trust

The Availability Center is explanatory and local. It does not request
permissions, write calendars, connect sync, expose private calendar detail, run
automation, or create receipts. Calendar writes remain confirmation-bound by
Plan policy.

## Repairs Attempted

- First focused compile failed because `ProfileDashboard`'s explicit initializer
  did not yet accept `availabilityCenter`, and duration labels were private to
  the sheet. Repaired by adding the initializer parameter and moving duration
  label helpers into `RepositoryBackedProfileService`.

## Validation Commands

- `xcodegen generate`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/ProfileFeatureServiceTests`
- `scripts/build-local.sh`
- `git diff --check`
- Touched-file trailing whitespace scan
- CQS scans for touched files
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- Focused Profile test lane: Pass after one repair loop. 24 tests, 0 failures.
- `scripts/build-local.sh`: Pass. Native simulator build succeeded for the app,
  widget extension, share extension, and app intent metadata extraction path.
- `git diff --check`: Pass.
- Touched-file trailing whitespace scan: Pass.
- CQS product drift scan: Accepted Yellow. The scan reported the existing
  internal `ProfileDashboard` type name; FCP17 did not introduce a user-facing
  dashboard surface or new top-level destination.
- CQS prompt-built smell scan on the new card: Pass with zero hits.
- CQS privacy/security claim scan: Pass with zero hits for the first touched
  scan root.
- CQS accessibility/motion scan on the new card: Accepted Yellow review hit.
  The card includes explicit accessibility labels/values/hints and text status
  labels; it adds no motion-only or color-only meaning.
- `scripts/run-doc-qa.sh || true`: Accepted Yellow advisory backlog. Lychee
  reported 650 OK and 0 errors. Existing repo-wide markdown and deprecated
  language advisories are not introduced by FCP17 production source changes.
- `scripts/batch-train-gate-check.sh || true`: Accepted Yellow dirty-tree hint
  before commit, expected while FCP17 files are uncommitted.

## Remaining Yellow Items

- Existing large Profile service/screen files remain a maintainability advisory.
- FCP17 does not implement Plan surface integration, calendar writing, reminder
  behavior, availability persistence UI, real-device proof, public accessibility
  conformance, TestFlight readiness, App Store readiness, release readiness, or
  legal/privacy compliance.
- FCP06 Receipt Drawer / Trust Layer remains next under global order.

## Hard Red Review

No Hard Red was found. FCP17 did not require route/raw-value edits, schema/data
changes, sync/account/cloud behavior, unsupported legal/privacy/release claims,
or weakening Ambitions canon.

## Rollback Path

Revert the FCP17 commit to remove the Availability Center model/card/service/test
changes and docs/train-state updates. No persistence, schema, route, entitlement,
workflow, dependency, sync, or release file changed.

## Next Eligible Batch

Under the highest-priority global full-stack order, the next eligible batch is
FCP06 Receipt Drawer / Trust Layer.
