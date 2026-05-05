# FCP05 Start Here Surface Report

## Result

Green.

## Batch

FCP05 — Start Here Surface.

## Train

FCP01-FCP30 Flagship Completion Train under the global full-stack order.

## Files Read

- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/FLAGSHIP_COMPLETION_OBJECT_SCORECARD.md`
- `docs/codex/FLAGSHIP_COMPLETION_GATE_MATRIX.md`
- `docs/codex/FLAGSHIP_COMPLETION_FILE_BOUNDARY_MAP.md`
- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`

## Files Changed

- `Native/Ambitions/Features/Today/DayRailViewState.swift`
- `Native/Ambitions/Features/Today/DayRailProjection.swift`
- `Native/Ambitions/Features/Today/TodayExecutionProjector.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `docs/codex/batches/FCP05_Start_Here_Surface_Prompt.md`
- `docs/audits/fcp05-start-here-surface-report.md`
- `docs/codex/batch-trains/FCP01_FCP30_FLAGSHIP_COMPLETION_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## What Changed

Start Here is now a Today-owned Reality Rail surface rather than a renamed Hero
Step card. The rail hero state carries Context Edge, Time Fit Proof, Goal
Thread, source quality, a because line, primary and secondary actions, and a
FCP06 Receipt Drawer seam. The surface uses non-color text labels for every
semantic fact and keeps the existing Start now / Step Detail / Step Session
handoffs.

The proof slot no longer claims the receipt peek is future-only. It now keeps
no-silent-change posture while the Start Here surface owns the visible receipt
seam. No proof ledger persistence, route, tab, schema, sync, AI runtime, LDI
runtime, or release/privacy claim was added.

## Product Decisions Preserved

- Top-level tabs remain Today / Goals / Capture / Plan / You.
- Today remains Reality Rail owned.
- Start Here does not become a dashboard, feed, generic task card, or chatbot.
- Proof remains evidence.
- Receipts remain consequence and review path.
- Source remains freshness/review boundary.
- Privacy remains private projection and user control.

## Repairs Attempted

- A first focused test run found one new assertion mismatch for the case of
  "receipt seam" wording. The implementation was already projecting the
  receipt seam; the test was tightened to assert the exact projected Start Here
  receipt seam wording.
- A rerun hit local Xcode DerivedData disk pressure. Generated
  `~/Library/Developer/Xcode/DerivedData/Ambitions-*` artifacts were removed,
  then the focused Today test lane was rerun successfully.
- `scripts/build-local.sh` then hit the same local disk-pressure class during
  linking. Generated `output/DerivedData-*` and Ambitions DerivedData artifacts
  were removed, then the local build was rerun successfully.

## Tests Run

- `xcodegen generate`
- `git diff --check`
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/Today/TodayViewModelTests`
- `scripts/build-local.sh`
- `scripts/cqs-product-drift-scan.sh ... || true`
- `scripts/cqs-prompt-built-smell-scan.sh ... || true`
- `scripts/cqs-privacy-security-claim-scan.sh ... || true`
- `scripts/cqs-accessibility-motion-scan.sh ... || true`
- touched-file trailing whitespace scan
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Result

Focused Today unit tests passed after the bounded assertion repair and local
generated-artifact cleanup. Full local build passed after the same
generated-artifact cleanup. CQS scans remained advisory only. Doc QA and batch
gate checks retain the known accepted Yellow advisory backlog and dirty-tree
warning before commit.

## Remaining Yellow Items

- Start Here now has a Receipt Drawer seam, but broader Reality Rail continuity
  remains owned by FCP07.
- Action Closure Diamond remains owned by FCP13A.
- Real-device, rendered accessibility, App Store, TestFlight, and release
  readiness remain unclaimed.

## Red Classification

No Hard Red occurred.

## Rollback Path

Revert the FCP05 commit to restore the prior Day Rail hero projection and
reserved proof-slot posture. No persistence/schema or route migration is
required.

## Next Eligible Batch

FCP07 — Reality Rail Continuity.
