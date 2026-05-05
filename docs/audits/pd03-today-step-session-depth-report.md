# PD03 Today Step Session Depth Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-04
Result: Accepted Yellow
Batch: PD03 - Today Step Session Depth

## Source Truth Used

- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md`
- `docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md`
- `docs/canon/Ambitions_Product_Depth_Plan.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/codex/batches/PD03_Today_Step_Session_Depth_Prompt.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- Current Today source and tests.

## Files Inspected

- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Today/TodayActionClosureSheet.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- Product Depth train, registry, context, roadmap, and run-state docs.

## Files Changed

- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `Native/Ambitions/Features/Today/TodayFeatureModels.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/AmbitionsTests/Today/TodayViewModelTests.swift`
- `docs/audits/pd03-today-step-session-depth-report.md`
- `docs/canon/Ambitions_4_0_Execution_Program.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md`
- `docs/canon/Ambitions_Product_Depth_Plan.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`

## Implementation Summary

PD03 deepened Step Session inside the Today owner boundary. `TodayStepSessionState`
now carries explicit session context, goal connection, optional timer copy,
pause/stop/close controls, receipt/proof boundary copy, and visible-copy
coverage for copy scans. `TodayStepSessionCard` now renders those session
requirements with text labels and existing Ambitions button styling. `TodayScreen`
handles pause and stop locally without creating a new destination, route, or
proof mutation.

The timer remains secondary through the `Timer optional` label. Closing the loop
still opens the existing closure sheet and receipt preview path instead of
silently changing proof. Stopping the session returns to Today posture without
claiming persistence, runtime intelligence, sync, AI/LDI, or background work.

## Product Decisions Preserved

- Today remains owned by Reality Rail.
- Step Session remains behind Today / Step Detail and does not become a top-level tab.
- Step Session is step-first, not timer-first.
- Proof remains evidence and is not gamified.
- Receipt remains consequence and reversibility, not a notification feed.
- Source and privacy semantics are unchanged.
- Capture, Plan, Goals, You, navigation, persistence, sync/auth/network, AI/LDI runtime, CI/config, and design tokens were not edited.

## Caveats And Candidate Preservation

- Accent taxonomy/default mismatch remains Yellow and untouched.
- MissionControlTimeSpine order remains Yellow and untouched.
- Month LifeShape calendar-clone risk remains untouched.
- You / Privacy / Memory / Receipts copy-density caveat remains untouched.
- Candidate items were not finalized.
- Broad app implementation remains Red.

## Conflicts Found

No new Product Experience Pack conflict was introduced. Existing advisory
backlog remains accepted Yellow. The changed-file boundary script still flags
Today implementation files as forbidden by generic docs-only rules, but PD03
explicitly authorizes Today feature and Today test edits.

## Validation Results

- `git diff --check`: passed.
- `xcodegen generate`: passed.
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/TodayViewModelTests`: passed, 34 tests, 0 failures.
- `scripts/build-local.sh`: passed; log
  `output/logs/build-local-20260504-202432.log`.
- Touched-path forbidden-copy scan: accepted Yellow for existing internal/test
  guard terms only; no new user-facing Step Session copy uses forbidden terms.
- `scripts/accessibility-ui-batch-readiness-scan.sh || true`: accepted Yellow
  for existing context and explicit non-claims.
- `scripts/generic-product-drift-scan.sh || true`: accepted Yellow for
  existing guardrail/context hits.
- `scripts/no-unsupported-ai-claim-scan.sh || true`: accepted Yellow for
  context and explicit non-claims.
- `scripts/si-file-size-scan.sh || true`: accepted Yellow for existing large
  files and Today owner-file watches.
- `scripts/si-motion-reduce-motion-scan.sh || true`: accepted Yellow for
  existing motion/Reduce Motion inventory; PD03 introduced no new animation.
- `scripts/run-doc-qa.sh || true`: advisory backlog remains; lychee reported
  `650 OK` and `0 Errors`.
- `scripts/batch-train-gate-check.sh || true`: accepted Yellow for expected
  uncommitted work before commit.
- `scripts/changed-file-boundary-check.sh || true`: accepted Yellow because
  generic docs-only boundary rules flag Today files, while PD03 explicitly
  authorizes `Native/Ambitions/Features/Today/**` and Today tests.

## Known Gaps

- No screenshot/rendered visual proof was produced in PD03.
- No human VoiceOver, Dynamic Type, Reduce Motion, or physical-device pass was run.
- The implementation does not claim persistent session state, background timer behavior, proof persistence, AI/LDI runtime, sync, auth, network, release readiness, or accessibility conformance.

## Next Eligible Batch

PD04 - Today Recovery and Closure Depth, only if PD03 commits, pushes, leaves a
clean worktree, and Product Depth continuation gates allow accepted Yellow
continuation.
