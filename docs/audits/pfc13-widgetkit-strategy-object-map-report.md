# PFC13 WidgetKit Strategy And Object Map Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion
Batch: PFC13 WidgetKit Strategy And Object Map
Owner: Widgets / Platform / Privacy

## Summary

PFC13 creates the WidgetKit strategy and object map for Ambitions. It defines
which product objects may appear in widgets, what each may expose, and which
privacy, accessibility, Reduced Motion, performance, and claim boundaries must
hold before PFC14 implementation or repair work.

PFC13 is docs/product/platform planning. It does not edit production Swift,
widget extension source, entitlements, signing, project generation, workflows,
privacy manifests, persistence/schema, sync/account, AI/LDI runtime, App Store
metadata, or release files.

## Files Inspected

- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/canon/Ambitions_10_10_Flagship_Completion_Plan.md`
- `docs/handoff/Ambitions_Product_Experience_Pack_Source_Truth_Packet.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `docs/audits/pfc12-app-groups-shared-storage-boundary-report.md`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalWidgetProjection.swift`
- `Native/Ambitions/Support/ExternalSurfaceVerificationChecklist.swift`
- `Native/AmbitionsWidgetExtension/NextStepWidget.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceVerificationChecklistTests.swift`

## Files Changed

- `docs/canon/Ambitions_WidgetKit_Strategy_And_Object_Map.md`
- `docs/codex/batches/PFC13_WidgetKit_Strategy_And_Object_Map_Prompt.md`
- `docs/audits/pfc13-widgetkit-strategy-object-map-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Object Map Summary

| Object | PFC13 status | Widget role |
| --- | --- | --- |
| Today / Reality Rail | Allowed primary | Current local next-step posture and rail orientation. |
| Start Here | Allowed primary | Recommended user-startable step. |
| Receipt Drawer / Proof | Allowed secondary | Receipt/proof state or in-app review cue. |
| Source Fold | Allowed secondary | Stale/conflict/review boundary. |
| Plan / LifeShape | Allowed secondary | Capacity or plan posture only. |
| Capture | Allowed entry | Text-first capture/open action. |
| Goals / LifePath | Allowed secondary | One safe goal reference or progress posture. |
| You / Personal System Center | Allowed limited | Trust/privacy/defaults status after explicit future scope. |
| MissionControlTimeSpine | Deferred | Blocked until FCP10 resolves lane implementation. |
| Memory Lens | Deferred | Blocked until FCP23/PFC strategy approves privacy-safe memory exposure. |

## Privacy Matrix Summary

- Sensitive goal/step details: hidden by default.
- Stale snapshots: show stale label and ask the user to open Ambitions.
- Unavailable snapshots: fall back to Today.
- Protected blocks: glanceable only, no raw calendar/event details.
- Proof/receipts: summary only, no trophy/feed posture.
- Capture: entry only; placement waits for content.
- Plan capacity: summary only, no calendar clone or automatic reschedule claim.
- Goal references: safe route only, with names hidden when privacy requires.

## Existing Repo Alignment

- `ExternalSurfaceContractRegistry.contract(for: .widgets)` already limits
  widgets to Now, Next Step, protected block, plan status, and stale state.
- `ExternalWidgetProjection` already hides sensitive detail by default, carries
  stale/unavailable copy, uses safe widget-origin deep links, and falls back to
  Today.
- `NextStepWidget` already uses the shared projection across supported widget
  families.
- `ExternalSurfaceVerificationChecklist` already marks rendered widget gallery,
  Lock Screen/accessory rendering, and device proof as manual verification
  gates.

## Product Decisions Preserved

- Widgets remain external mirrors, not new top-level destinations.
- Ambitions remains Today / Goals / Capture / Plan / You.
- Widgets must not become dashboards, feeds, inboxes, calendars, AI confidence
  surfaces, or hidden automation channels.
- Capture remains text-first.
- Plan remains LifeShape/capacity-first.
- Proof remains evidence and receipts remain consequence/reversibility.
- Source states remain freshness/conflict/review boundaries.
- Privacy remains user control and detail minimization.

## Validation Results

- `xcodegen generate`: passed.
- Focused widget/platform tests: passed, 8 tests, 0 failures.
  Result bundle:
  `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.05_13-33-14--0400.xcresult`.
- `git status --short`: dirty before commit with only PFC13 docs/state changes.
- `git diff --check`: passed.
- Touched-doc trailing whitespace scan: passed.
- CQS privacy/security claim scan: advisory hits only inside explicit
  privacy-boundary and forbidden-risk table rows.
- CQS product drift scan: advisory hits only inside explicit anti-drift and
  forbidden-risk table rows.
- `scripts/run-doc-qa.sh || true`: advisory backlog; lychee reported 650 OK
  and 0 errors, with existing markdownlint/stale-guidance/deprecated-language
  findings.
- `scripts/batch-train-gate-check.sh || true`: advisory dirty-tree hint before
  commit; no Hard Red.

## Remaining Yellow Items

- Rendered widget gallery/device behavior is not proven.
- Lock Screen/accessory rendering is not manually verified.
- Public accessibility conformance is not claimed.
- App Store/TestFlight/release readiness is not claimed.
- PFC14 still owns any widget implementation/repair.
- FVQ01 must run next because the remote order inserted it while local PFC13 was
  already active.
- PFC15/PFC17/PFC19 still own Live Activities, App Intents, and notifications
  strategies after FVQ01 closes.

## Hard Red Review

No Hard Red was found. PFC13 did not require production Swift edits,
entitlement/signing changes, new widget runtime behavior, external credentials,
privacy/legal/release claims, schema/data-loss risk, or a product decision
outside existing source truth.

## Rollback Path

Revert the PFC13 commit to remove the WidgetKit strategy doc, PFC13 prompt,
audit report, and train-state updates. No production source, entitlement,
project, workflow, schema, sync, or platform runtime file changed.

## Next Eligible Batch

Under `GLOBAL_FULL_STACK_COMPLETION_ORDER.md`, the next eligible batch after
PFC13 is FVQ01 Rendered Visual Freshness And Flagship Gate because FVQ01 was
inserted remotely while local PFC13 was already active. PFC15 follows after
FVQ01 closes Green or accepted Yellow.
