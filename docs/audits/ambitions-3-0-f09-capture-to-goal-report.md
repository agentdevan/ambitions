# Ambitions 3.0 F09 Capture-to-Goal / Grow into Goal Report

Date: 2026-04-30
Result: Green with accepted background Yellow

## Scope

F09 made the Capture-to-Goal handoff explicit and traceable. The batch reused the existing capture-to-goal service and Create Goal flow, added visible `Grow into Goal` language, and verified that capture identity survives preview and submission. It did not build full Goal Mission Control.

## Changes

- Renamed the Capture handoff action from `New goal` to `Grow into Goal`.
- Added `CaptureGoalHandoffState` to `CreateGoalViewModel`.
- Added a Create Goal handoff card when a goal is seeded from Capture.
- The handoff card exposes the capture source, confirmation requirement, consequence, and local privacy posture.
- Added focused test coverage that preview and create requests preserve `captureID` and Capture entry source.

## Explicit Non-Goals

- No full Goal Mission Control implementation.
- No broad Goals architecture work.
- No Plan Life Suite behavior.
- No Shell/Meridian work.
- No global legacy identifier migration.
- No `.github/workflows` files, runtime dependencies, paid services, persistence contract changes, release claims, or FAANG handoff claims.

## Validation

- `scripts/build-local.sh` PASS on `iPhone 17`.
- `xcodebuild test -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/CreateGoalViewModelTests -only-testing:AmbitionsTests/CapturesViewModelTests -only-testing:AmbitionsTests/CaptureServiceTests/testTurnCaptureIntoGoalUsesExistingGoalCreationService` PASS, 16 tests.
- `scripts/swiftui-architecture-scan.sh` PASS/advisory. Current-scope files remained responsibility-review sized.
- Touched-path copy guard found only internal failure-state names and existing Capture `triage` taxonomy.
- `git diff --check` PASS.
- `.github/workflows` remained untouched.

## Gate Classification

Green:

- Build passed.
- Focused Capture, Create Goal, and capture-to-goal service tests passed.
- Touched-path copy guard introduced no user-facing inbox/backlog/chat/assistant/fake-AI language.
- Privacy/trust posture remained confirmation-based and local.
- No runtime dependency, workflow, Shell/Meridian, or release posture changes.
- Report and tracking docs were updated.

Accepted background Yellow, unchanged:

- Doc QA advisory backlog.
- Known full UI smoke failures outside current focused scope.
- Known legacy/internal identifier backlog outside F09.
- Known large files outside current touched scope.
- Known markdown/link backlog.

New Yellow/Red:

- None.

## Next Batch

F10 Plan Life Suite foundation should establish the Plan Life Suite/shape foundation without creating a calendar clone or silently changing calendar data.
