# IOS26-T04H-B02 Dependencies, Deadlines, And Priority

Status: Yellow
Batch: IOS26-T04H-B02
Train: TRAIN_04H / Project Step Operations / Todoist Things Replacement

## Scope

- Represent dependency and priority pressure in the local receipt/replay contract without introducing scoring or ranking gimmicks.
- Keep project-step evidence local, inspectable, and replayable.
- Preserve the current `Today / Goals / Capture / Time / You` product canon.

## Source behavior present

- `ActionReceiptChangedFactKind` carries qualitative dependency and priority-pressure facts.
- `ActionReceipt.dependencyBlockedReceipt(...)` records a blocked dependency chain as a local receipt with a review-goal next action.
- `ActionReceipt.priorityPressureChangedReceipt(...)` records priority pressure changes as a local receipt without any numeric score surface.
- `IOS26TodoistP0ContractHarnessTests` exercises dependency and priority receipts alongside the existing source, receipt, and replay boundary.

## Proof points

- Dependency state stays explicit in the receipt model instead of being hidden in a generic task list.
- Priority changes remain qualitative and source-tied.
- The batch keeps local proof/replay semantics intact through `ActionReceiptProofLedgerEntry` and `ReplayableDecisionTrace`.

## Validation run

- `git diff --check -- Native/Ambitions/Domain/ActionClosureReceiptModels.swift Native/AmbitionsTests/Domain/ActionClosureReceiptModelsTests.swift Native/AmbitionsTests/Domain/IOS26TodoistP0ContractHarnessTests.swift`
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04H-B02`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04H-B02`
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04H-B02 --lane focused-test --test AmbitionsTests/Domain/IOS26TodoistP0ContractHarnessTests`
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04H-B02 --lane build-for-testing`

## Validation results

- `git diff --check` passed.
- IOS26 flagship preflight passed.
- IOS26 core replacement proof shape check passed, with the expected note that the batch report file was not present before this closeout pass.
- The focused-test lane failed at simulator install time with `Missing bundle ID` for `.codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app`.
- The build-for-testing lane failed with `build.db is locked`, which indicates another live build is using the same derived-data path.

## Validation not run

- A clean build-for-testing and a clean focused-test result bundle were not produced in this turn because the shared derived-data build database was already in use by another live build.
- Device, accessibility, performance, CI, TestFlight, App Store, and release validation remain unproven.

## Proof artifacts

- `build/reports/project-step-operations/IOS26-T04H-B02.md`
- `build/reports/project-step-operations/dependencies-deadlines-priority.md`

## Claims allowed

- Source-level dependency and priority-pressure receipts.
- Local proof-shape validation and truth-file validation.
- The Todoist replacement harness boundary remains wired in source.
- The Xcode failure mode is identified and recorded.

## Claims forbidden

- Build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, or release claims.
- Any claim that the focused Xcode lanes completed in this turn.

## Yellow items

- Focused Xcode validation did not complete in this turn.
- The batch remains source-level and proof-shape validation only in this turn.

## Red items

- None.
