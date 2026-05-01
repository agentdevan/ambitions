# Ambitions 3.0 F12 Reflow / Recovery / Decisions Report

Date: 2026-05-01

Result: Green

## Scope

F12 added a focused Plan-owned decision foundation for reflow and recovery. It does not silently rearrange the day, write calendar data, change Today, add persistence/sync/backend assumptions, add dependencies, touch workflows, or implement Shell/Meridian.

## Files Changed

- `Native/Ambitions/Features/Plan/PlanReflowDecisionState.swift`
- `Native/Ambitions/Features/Plan/PlanReflowDecisionCard.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureModels.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreenContractSnapshot.swift`
- `Native/Ambitions/PreviewSupport/PreviewPlanScenarios.swift`
- `Native/AmbitionsTests/Plan/PlanFeatureServiceTests.swift`

## Implementation

- Added `PlanReflowDecisionState`, `PlanReflowDecisionOptionState`, and `PlanReflowDecisionProjector`.
- Added user-owned decision options: Keep plan, Make smaller, Move later, Review plan, Protect time, and Recover.
- Added `PlanReflowDecisionCard` as a focused SwiftUI render surface with source and trust labels.
- Wired `PlanDashboard.reflowDecision` from existing `PlanRealityReflowState`, `PlanRecoveryEntryState`, `PlanSaveTheDayState`, and `PlanReflowReceiptPreviewState`.
- Updated Plan previews with deterministic reflow decision fixtures.
- Added focused test coverage proving user-owned decision options, no silent changes, no mutation, and privacy/trust source labels.

## Trust / Privacy / Accessibility

- Trust labels: `Based on your plan` and `No silent changes`.
- Receipt label includes no-silent-rescheduling and no-calendar-write boundaries.
- The card has stable accessibility identifier `plan.reflow-decision`.
- F12 added no hidden personalization, no sync, no export, no backend, no account, no paid service, and no model-confidence language.

## Architecture

- `PlanFeatureModels.swift`: 667 lines after F12, up from 666; only one dashboard field was added.
- `PlanFeatureService.swift`: 2394 lines after F12, up from 2387; only narrow projector wiring was added.
- `PlanScreen.swift`: 1978 lines after F12, up from 1966; only a card hook and route handler were added.
- New focused files: `PlanReflowDecisionState.swift` at 176 lines and `PlanReflowDecisionCard.swift` at 109 lines.
- Existing large-file warnings remain accepted background Yellow and were not converted into new logic ownership.

## Validation

- Build: `scripts/build-local.sh` PASS on iPhone 17.
- Focused tests: `PlanFeatureServiceTests` PASS, 28 tests, 0 failures.
- New F12 test: `testF12ReflowDecisionProjectsUserOwnedOptionsWithoutSilentAutomation` PASS.
- Architecture scan: advisory only; pre-existing large-file warnings remain.
- Doc QA: advisory only from known stale-guidance, markdownlint, deprecated-language, and lychee backlog.
- Copy guard: touched-path scan found only existing/internal failure-state names and the pre-existing `missedDay` enum.
- Diff whitespace: `git diff --check` PASS.

## Gate

F12 gate result: Green, pending commit.

F13 may proceed only after F12 final gate commands pass, the F12 commit is created, and `main` is pushed.
