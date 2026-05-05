# PD05 Goals Mission Control Detail Architecture Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-04
Result: Green
Train: Product Depth
Batch: PD05 Goals Mission Control Detail Architecture

## Source Truth Used

- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Final_File_Boundary_Approval.md`
- `docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md`
- `docs/canon/Ambitions_Product_Depth_Plan.md`
- `docs/canon/PXOS_Product_Depth_And_Drilldown_Rules.md`
- `docs/codex/batches/PD05_Goals_Mission_Control_Detail_Architecture_Prompt.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_GATE_MATRIX.md`
- `docs/codex/BATCH_REGISTRY.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Inspected

- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift`
- `Native/Ambitions/Features/Goals/GoalMissionControlLanePrimitives.swift`
- `Native/Ambitions/PreviewSupport/PreviewGoalsScenarios.swift`
- `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift`
- Product Depth train, registry, context, global order, run-state, and source-truth docs listed above.

## Files Changed

- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/AmbitionsTests/Goals/GoalDetailStrategicPresentationTests.swift`
- `docs/audits/pd05-goals-mission-control-detail-architecture-report.md`
- `docs/canon/Ambitions_Product_Depth_Canon_Inventory_And_Ownership_Map.md`
- `docs/canon/Ambitions_Product_Depth_Plan.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`

## Product Experience Pack Decisions Preserved

- Top-level tabs remain `Today / Goals / Capture / Plan / You`.
- Goals remains the owner of LifePath View and Goal Detail depth.
- Goal Detail Mission Control visible lane order now follows `Completed -> Now -> Friction -> Next -> Horizon`.
- Proof remains evidence, not achievement.
- Source/trust language remains review-boundary language, not AI certification.
- No navigation, route, raw-value, persistence, sync/auth/network, AI/LDI runtime, CI/config, dependency, or release/platform files were edited.

## Caveats Preserved

- Accent taxonomy/default mismatch remains a separate Yellow conflict.
- Step Session depth is not broadened by this batch.
- Month LifeShape Lens calendar-clone risk is unchanged.
- You / Privacy / Memory / Receipts copy-density guard is unchanged.
- Candidate items remain Candidate unless their own named batch finalizes or defers them.
- Broad app implementation remains Red.

## Candidate Items

PD05 did not finalize Horizon Detail, alternate path detail, proof-history depth, decision-history depth, or any Candidate item. Horizon is represented only as the fifth visible Mission Control lane in Goal Detail and remains directional, not a roadmap or Gantt chart.

## Implementation Summary

PD05 updated the repository-backed Goal Detail Mission Control projection so the visible lane set is:

1. Completed
2. Now
3. Friction
4. Next
5. Horizon

The implementation preserves internal `GoalDetailMissionLaneKind` compatibility cases such as `.proof`, `.overview`, `.risks`, `.steps`, and `.path`. It does not rename enum raw values, routes, preview support, deep links, persistence, or external seams.

The first focused test attempt failed at compile time after an internal enum rename because preview scenarios still referenced the compatibility cases. The repair restored the internal enum cases and kept the locked Product Experience Pack language in visible lane state. The repaired run passed.

## Conflict Resolution

| Conflict | PD05 outcome |
| --- | --- |
| MissionControlTimeSpine order mismatch / unknown | Resolved for visible Goal Detail lane order. |
| Internal lane-kind compatibility | Preserved by keeping existing enum cases. |
| User-facing copy boundary | No new forbidden visible Goals Mission Control copy introduced. Existing internal scoring and ritual compatibility terms remain outside the PD05 visible lane-order change. |
| OKR / KPI / dashboard drift | Avoided. The lane order is a five-lane Goal Detail spine, not a dashboard or board. |

## Validation Commands Run

- `git status --short`
- `git diff --check`
- `xcodegen generate`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/GoalDetailStrategicPresentationTests`
- `scripts/build-local.sh`
- `grep -R "Product Depth.*started\|PD01.*complete\|PD18.*complete" docs .codex | cat || true`
- `grep -R "new top-level tab\|stacked cards\|calendar clone\|chatbot" docs/canon docs/codex .codex | cat || true`
- `grep -R "App Store ready\|TestFlight ready\|production ready\|physical device passed" README.md docs .codex | cat || true`
- `rg -n -i "Score may be stale|Sensitive info policy|AI confidence|AI verified|overdue|failed|streak|productivity loss|sensitive data detected|tracked|monitored|surveillance|habit|score" ... || true`
- `scripts/accessibility-ui-batch-readiness-scan.sh || true`
- `scripts/generic-product-drift-scan.sh || true`
- `scripts/no-unsupported-ai-claim-scan.sh || true`
- `scripts/si-file-size-scan.sh || true`
- `scripts/si-motion-reduce-motion-scan.sh || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`
- `scripts/changed-file-boundary-check.sh || true`

## Validation Results

- `git diff --check`: PASS.
- `xcodegen generate`: PASS.
- Focused Goal Detail presentation tests: PASS, 17 tests, 0 failures.
  - Passing xcresult: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.04_21-00-40--0400.xcresult`
- `scripts/build-local.sh`: PASS on `iPhone 17`.
  - Log: `output/logs/build-local-20260504-210243.log`
- Product Depth status grep: accepted Yellow. Hits are historical prompts, guardrail commands, and current status statements; no PD18 completion or broad Product Depth completion claim was added.
- Anti-sprawl / release-claim greps: accepted Yellow. Hits are guardrails, historical docs, and explicit non-claims.
- Touched-path copy scan: accepted Yellow. Hits are existing internal scoring variables, internal ritual compatibility terms, guardrail docs, and test guard strings; no new visible forbidden Mission Control lane copy was introduced.
- Accessibility, generic drift, unsupported-AI, file-size, and motion scans: accepted Yellow advisory backlog only. PD05 introduced no new motion or haptic behavior.
- `scripts/run-doc-qa.sh || true`: accepted Yellow advisory backlog; lychee reported 650 OK and 0 errors.
- `scripts/batch-train-gate-check.sh || true`: accepted Yellow before commit because the batch had uncommitted changes.
- `scripts/changed-file-boundary-check.sh || true`: accepted Yellow false-positive for PD05 because `Native/Ambitions/Features/Goals/**` and `Native/AmbitionsTests/**` are explicitly allowed by the PD05 prompt.

## Known Gaps

- PD05 did not implement lifecycle/path visualization, proof-history detail, decision-history detail, alternate path tradeoff depth, or visual screenshot proof.
- PD05 did not make public accessibility, physical-device, release, TestFlight, App Store, sync, persistence, AI, LDI, or AOS runtime claims.
- File-size advisory remains for large pre-existing Goals owner files.

## Next Eligible Batch

PD06 Goal Lifecycle and Path Visualization is the next direct Product Depth successor if PD05 commits, pushes, leaves a clean worktree, and train rules allow continuation. Global order marks PD06 as requiring PD05 Green.

