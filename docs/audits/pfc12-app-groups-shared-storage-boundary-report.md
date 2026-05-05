# PFC12 App Groups Shared Storage Boundary Report
<!-- markdownlint-disable MD013 -->

Result: Green
Date: 2026-05-05
Train: PFC01-PFC40 Platform / Framework / Compliance Completion
Batch: PFC12 App Groups / Shared Storage Boundary
Owner: Platform / Privacy

## Summary

PFC12 closes the shared-storage boundary as evidence-backed platform planning and
focused proof. The repo already has a bounded app group container,
`group.com.ambitions.shared`, shared by the app, widget extension, and share
extension. Existing contracts keep the app group limited to lightweight external
surface snapshots and share-extension creation requests.

No production Swift, entitlement, signing, project, workflow, dependency,
schema, sync, account, CloudKit, server, notification, StoreKit, release,
privacy manifest, or legal file was changed.

## Files Inspected

- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`
- `project.yml`
- `Native/Ambitions/Support/Ambitions.entitlements`
- `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements`
- `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements`
- `Native/Ambitions/ExternalSnapshots/SharedExternalSnapshotStore.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalCreationContracts.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotContracts.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceVerificationChecklistTests.swift`
- `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift`

## Files Changed

- `docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md`
- `docs/audits/pfc12-app-groups-shared-storage-boundary-report.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## App Group Evidence

| Evidence | Finding |
| --- | --- |
| App entitlement | `Native/Ambitions/Support/Ambitions.entitlements` declares `group.com.ambitions.shared`. |
| Widget entitlement | `Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements` declares the same group. |
| Share extension entitlement | `Native/AmbitionsShareExtension/AmbitionsShareExtension.entitlements` declares the same group. |
| Shared snapshot store | `SharedExternalSnapshotStore` writes `ExternalSnapshots/external-snapshot.v1.json` inside the app group when available, with Application Support / temporary fallback. |
| External creation queue | `SharedExternalCreationStore` writes `ExternalCreations/external-creations.v1.json` for share-extension capture requests. |
| External surface contracts | `ExternalSurfaceContractRegistry` requires minimized content, sensitive-detail hiding, stale/unavailable labels, shared command pipeline use, receipts for mutation, and confirmation for sensitive destructive effects. |

## Shared Data Map

| Shared data | Direction | Allowed use | Boundary |
| --- | --- | --- | --- |
| External surface snapshot | Main app to widget / Live Activity readers | Glanceable local snapshot with privacy policy, stale state, safe route targets, and continuity labels. | Not a database, sync feed, analytics log, proof ledger, receipt store, or source of truth. |
| External creation request queue | Share extension to main app | User-initiated text/URL capture request with source and landing intent. | Does not silently place, upgrade, schedule, mutate goals, or bypass Capture review. |
| App group identifier | App / widget / share extension | Local extension continuity and handoff. | Does not prove real-device installed container behavior or platform readiness. |

## Privacy And Trust Boundary

- External surfaces remain privacy-projected and minimized.
- Private details stay hidden by default.
- Stale/unavailable states require opening Ambitions to refresh or confirm.
- Mutation-capable external actions must use command pipeline and receipt /
  confirmation posture where sensitive.
- Shared storage is not CloudKit, server sync, account sync, or backup.
- Shared storage is not a separate receipt history, proof ledger, source record,
  analytics stream, or hidden automation path.

## Claim Boundary

PFC12 proves source and simulator-test evidence for the local app group contract.
It does not claim real-device installed app-group I/O, rendered widget gallery
behavior, Dynamic Island / Lock Screen Live Activity lifecycle, notification
delivery, Shortcuts/Siri invocation, App Store readiness, TestFlight readiness,
public accessibility conformance, legal compliance, privacy-label correctness,
or production release readiness.

## Validation Commands

- `git status --short`
- `git diff --check`
- Touched-doc trailing whitespace scan
- `xcodegen generate && xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/ExternalSurfaceVerificationChecklistTests -only-testing:AmbitionsTests/ExternalCreationImportServiceTests`
- `scripts/cqs-privacy-security-claim-scan.sh docs/codex/batches/PFC12_App_Groups_Shared_Storage_Boundary_Prompt.md docs/audits/pfc12-app-groups-shared-storage-boundary-report.md || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git diff --check`: Pass.
- Touched-doc trailing whitespace scan: Pass.
- Focused shared-container/external-creation test lane: Pass.
  `ExternalSurfaceVerificationChecklistTests` and
  `ExternalCreationImportServiceTests` executed 7 tests with 0 failures.
- Focused test command also regenerated the Xcode project through XcodeGen and
  left no tracked generated project diff.
- Focused simulator logs included expected unsigned app-group container messages
  (`NOT_CODESIGNED`) under `CODE_SIGNING_ALLOWED=NO`. This is accepted Yellow
  and reinforces that PFC12 does not claim real-device installed app-group I/O
  proof.
- CQS privacy/security claim scan: Pass with zero hits for the PFC12 prompt scan
  root.
- `scripts/run-doc-qa.sh || true`: Accepted Yellow advisory backlog. Lychee
  reported 650 OK and 0 errors. Existing repo-wide markdown and deprecated
  language advisories are not introduced by PFC12 production source changes.
- `scripts/batch-train-gate-check.sh || true`: Accepted Yellow dirty-tree hint
  before commit, expected while the PFC12 docs and train-state files are
  uncommitted.

## Remaining Yellow Items

- Real-device installed app-group I/O proof remains future/human-device evidence.
- Widget gallery rendering, Live Activity lifecycle, Shortcuts/Siri invocation,
  notification delivery, TestFlight readiness, App Store readiness, public
  accessibility conformance, privacy-label correctness, and legal compliance
  remain unclaimed.
- PFC13/PFC15/PFC17/PFC19 own later platform-surface strategies.

## Hard Red Review

No Hard Red was found. PFC12 did not require entitlement/signing changes,
physical-device proof, App Store/TestFlight action, privacy/legal compliance
claims, schema/data-loss risk, sensitive external data exposure, CloudKit/server
sync implementation, or a new platform surface decision.

## Rollback Path

Revert the PFC12 commit to remove the docs-only prompt, audit report, and
train-state updates. No production source, entitlement, project, workflow,
schema, sync, or platform runtime file changed.

## Next Eligible Batch

Under the highest-priority full-stack global order, the next eligible batch
after PFC12 is FCP17 Schedule / Availability / Defaults Center.
