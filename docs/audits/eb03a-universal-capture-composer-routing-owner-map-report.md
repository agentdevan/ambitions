# EB03A Universal Capture Composer Routing Owner Map

<!-- markdownlint-disable MD013 -->

Date: 2026-05-03

Result: PASS WITH YELLOW

Starting HEAD: `c59cc90f63b755796bcbad679a46203ccf5e26c7`

Batch status: EB03 remains blocked as a broad implementation batch. EB03A is the owner-map repair package. EB03B is the first eligible implementation batch only after this owner map is committed and the train points to EB03B.

App behavior changed: no.

Production Swift touched: no.

Route/raw values changed: no.

Persistence/schema changed: no.

Release/App Store/production readiness claim allowed: no.

## Source Truth Read

- `docs/canon/SOURCE_OF_TRUTH_MAP.md`
- `docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md`
- `docs/canon/Ambitions_4_0_External_Brain_Cross_Kernel_Primitives_And_Dependencies.md`
- `docs/audits/eb03-universal-capture-composer-routing-blocked-report.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md`
- `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md`
- Current Capture, Smart Attachment, persistence, preview, and focused test files listed below.

## EB03A Owner Map

| Concern | Owner file(s) | Secondary file(s) | Why this is the owner | Evidence |
|---|---|---|---|---|
| Universal capture composer entry | `Native/Ambitions/Features/Captures/CapturesScreen.swift` | `Native/Ambitions/Features/Captures/CapturesViewModel.swift`; `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift` | `CapturesScreen` owns the top-level Capture surface, bottom `CaptureAtmosphereComposer`, `CaptureComposer`, submit/mic affordances, prompt copy, route preview display, and Capture previews. | `CapturesScreen.swift` contains `CapturesScreen`, `CaptureAtmosphereComposer`, `CaptureComposer`, composer accessibility identifiers, and `#Preview("Capture Empty")`, `#Preview("Capture Route Suggestions")`, `#Preview("Capture Receipt")`, `#Preview("Capture Light")`. |
| Composer view state and quick-capture orchestration | `Native/Ambitions/Features/Captures/CapturesViewModel.swift` | `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`; `Native/Ambitions/Services/CaptureService.swift` | The view model owns draft text, selected draft route, preview refresh, `createQuickCapture`, and conversion from route decision to persisted capture request. | `CapturesViewModel` contains `draftText`, `draftRoutePreview`, `selectDraftRoute`, `createQuickCapture`, `routingDecision(for:)`, `preview(from:)`, and active-goal candidate building. |
| Routing and destination resolution | `Native/Ambitions/Services/SmartAttachmentService.swift` | `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`; `Native/Ambitions/Domain/SmartAttachmentModels.swift` | `DefaultSmartAttachmentService` is the deterministic router. It infers route type, ranks local candidates, handles Needs a Place, produces clarification, and returns route results. | `SmartAttachmentRouting.route(...)`, `DefaultSmartAttachmentService.route(...)`, `inferRouteType(from:)`, `rankCandidates(...)`, `needsPlaceCandidate(...)`, and `clarification(for:)` are present. |
| Route-to-capture adapter | `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift` | `Native/Ambitions/Domain/CaptureModels.swift`; `Native/Ambitions/Services/CaptureService.swift` | The adapter bridges Smart Attachment routing into `CreateCaptureRequest` without changing persistence or broad domain behavior. | `SmartAttachmentCaptureDecision.createCaptureRequest(...)` maps `SmartAttachmentResult` to capture kind, route, triage status, assumption summary, privacy, and source context. |
| Raw capture representation | `Native/Ambitions/Domain/CaptureModels.swift` | `Native/Ambitions/Services/CaptureService.swift`; `Native/Ambitions/Persistence/SwiftDataRepositories.swift` | Capture raw representation, route taxonomy, triage status, correction actions, privacy/local-only flags, and Codable defaults live in the domain model. | File defines `CaptureSourceType`, `CaptureStatus`, `CaptureTriageDestination`, `CaptureKind`, `CaptureTriageStatus`, `CaptureRoute`, `CaptureTriageMetadata`, `Capture`, and decode defaults for compatibility. |
| Smart Attachment raw/receipt representation | `Native/Ambitions/Domain/SmartAttachmentModels.swift` | `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`; `Native/Ambitions/Services/SmartAttachmentService.swift` | Smart Attachment route types, candidate targets, result states, confidence bands, privacy projections, action labels, and receipt projection live here. | File defines `SmartAttachmentRouteType`, `SmartAttachmentRouteTarget`, `SmartAttachmentResult`, `captureKind`, `captureRoute`, `captureAssumptionSummary`, `receiptProjection`, and action receipt mapping. |
| Placement/context understanding | `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift` | `Native/Ambitions/Services/SmartAttachmentService.swift`; `Native/Ambitions/Features/Captures/CapturesViewModel.swift`; `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift` | Placement preview converts route results into user-facing post-input state, destination, object type, consequence, privacy, and actions. | `SmartAttachmentResult.placementPreview` and `SmartAttachmentPlacementPreview` expose Suggested Place / Needs a Decision / Needs a Place, Today impact, consequence, privacy, and Place/Change/Decide Later controls. |
| Persistence/storage touchpoints | `Native/Ambitions/Services/CaptureService.swift`; `Native/Ambitions/Persistence/PersistenceContracts.swift`; `Native/Ambitions/Persistence/SwiftDataModels.swift`; `Native/Ambitions/Persistence/SwiftDataRepositories.swift` | `Native/Ambitions/Persistence/PreviewCaptureRepository.swift`; `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`; `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift` | `CaptureService` owns create/update service behavior; persistence contracts/models/repositories own durable storage and snapshot round-trip. | `CaptureRepository` protocol, `CaptureRecord`, `RepositoryMapping.captureRecord(from:)`, `RepositoryMapping.capture(from:)`, `SwiftDataCaptureRepository`, and `DefaultCaptureService.createCapture/updateCaptureRoute` are present. |
| Accessibility-sensitive behavior | `Native/Ambitions/Features/Captures/CapturesScreen.swift`; `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`; `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift` | `Sources/Accessibility/AccessibilityNutrition.swift`; `Native/AmbitionsTests/Captures/CapturesViewModelTests.swift` | The UI files own accessibility identifiers/labels/hints; the adapter owns route-preview accessibility text. | Composer, preview card, and screen identifiers exist; `SmartAttachmentCaptureDecision` exposes `accessibilityLabel`, `accessibilityValue`, and `accessibilityHint`; AccessibilityNutrition points Capture to `CapturesScreen.swift`. |
| Preview fixtures and preview scenarios | `Native/Ambitions/Features/Captures/CapturesScreen.swift`; `Sources/Previews/DynamicAdaptiveVisualPreviews.swift` | `Native/Ambitions/Features/Captures/CapturesViewModel.swift`; `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift` | Capture-specific SwiftUI previews live on the screen; DAV12 preview gallery carries named top-level scenario coverage. | Capture previews include empty, route suggestions, receipt, and light modes; DAV gallery includes `empty-capture` and `routed-capture` scenarios plus Dynamic Type and Reduce Motion scenarios. |
| Focused route and service tests | `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`; `Native/AmbitionsTests/Captures/CapturesViewModelTests.swift`; `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`; `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`; `Native/AmbitionsTests/Domain/SmartAttachmentModelsTests.swift`; `Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift` | `Native/AmbitionsTests/App/ExternalCreationImportServiceTests.swift`; `Native/AmbitionsTests/App/ShellCommandRouterTests.swift` | These tests already cover Smart Attachment routing, adapter-to-request mapping, Capture view-model quick capture, service persistence, raw values, command routing, and external creation import adjacency. | Test files contain existing assertions for route results, Needs a Place fallback, manual route choice, request mapping, capture persistence, raw source/status compatibility, command capture execution, and external import capture behavior. |

## Explicit Out-of-Scope Map

| File / area | Why it is not owned by EB03A | Risk if touched |
|---|---|---|
| `Native/Ambitions/Domain/CaptureModels.swift` | EB03A is documentation/owner-map repair only. Domain raw values and Codable defaults are owner evidence for EB03B, not edit targets now. | Route/raw compatibility drift, import/export fallback risk, and persistence migration ambiguity. |
| `Native/Ambitions/Domain/SmartAttachmentModels.swift` | Owner evidence only in EB03A. Any raw enum or receipt change belongs to EB03B with focused raw/receipt tests. | Breaks Smart Attachment result-state compatibility and receipt/user-control semantics. |
| `Native/Ambitions/Services/SmartAttachmentService.swift` | Owner evidence only. EB03A must not change routing logic. | Hidden behavior change in deterministic routing without route proof. |
| `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift` | Owner evidence only. EB03A must not change route-to-capture mapping. | Capture requests may persist new route/kind/status combinations without proof. |
| `Native/Ambitions/Services/CaptureService.swift` | Owner evidence only. EB03A must not alter create/update persistence behavior. | Event ledger or capture state transitions could drift without service/persistence proof. |
| `Native/Ambitions/Persistence/**` | Persistence touchpoints are identified only. EB03A forbids schema/model/repository changes. | SwiftData schema, snapshot, import/export, and migration risk. |
| `Native/Ambitions/Features/Captures/**` production Swift | EB03A does not implement UI behavior. Capture Swift may be touched only by EB03B after this map. | Broad Capture UI implementation could repeat the EB03 scope Red. |
| `Native/Ambitions/App/**` shell/navigation | EB03B should preserve top-level IA and existing routes unless a separate compatibility batch owns route proof. | Top-level tab or route/raw compatibility break. |
| `Native/Ambitions/Features/Goals/**`, `Plan/**`, `Today/**`, `Profile/**` | They may supply candidate context or destinations later, but EB03A owns no cross-surface behavior. | Turns EB03 into broad cross-product behavior instead of Capture routing. |
| `Native/Ambitions/Assets.xcassets/**` | Photo/reference assets and production asset changes are out of scope. | Shipping reference/deck assets or visual identity drift. |
| `.github/workflows/**`, dependency manifests, signing, TestFlight/App Store files | EB03A/EB03B do not own workflow, dependency, signing, or release operations. | Unsupported operational/release claims. |

## EB03B Safe Implementation Boundary

Allowed change areas:

- `Native/Ambitions/Features/Captures/CapturesScreen.swift` only for the universal composer route-display and accessibility presentation.
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift` only for draft routing state, explicit user route selection, route receipt state, and preview state needed by the composer.
- `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift` only for route-preview presentation if needed.
- `Native/Ambitions/Services/SmartAttachmentService.swift` only for deterministic route inference/ranking refinements proved by focused tests.
- `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift` only for route-to-`CreateCaptureRequest` mapping refinements proved by focused tests.
- `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift` only for non-persistent preview/consequence text needed by the route lane.
- Focused tests named in this report.
- Capture previews named in this report.
- EB03B audit/run-state updates.

Forbidden change areas:

- Persistence schema changes, `CaptureRecord` schema changes, or migration behavior.
- Route/raw enum case deletion, rename, or raw-value change.
- Top-level tab changes or new destination routes.
- Broad Goals/Plan/Today/You behavior changes.
- Network, sync, account, cloud, inference, or durable memory behavior.
- Production asset catalog changes.
- Dependency, workflow, signing, TestFlight, App Store, or release-readiness changes.
- Claims of screenshots, physical-device proof, human VoiceOver review, production readiness, App Store readiness, or full accessibility compliance unless actually proven.

Dependency assumptions:

- EB13 Trust/Privacy/User Control and EB25 Accessibility/Cognitive Load gates remain prerequisites for any intelligent routing behavior.
- Existing Smart Attachment routing remains local, deterministic, and correctable.
- Existing `CaptureRepository` / `SwiftDataCaptureRepository` snapshot persistence remains the storage seam; EB03B may prove non-change but should not alter schema.
- Existing top-level IA remains `Today / Goals / Capture / Plan / You`.

Needs evidence:

- Whether EB03B should add a distinct `SmartAttachmentCaptureAdapterTests.swift` file or continue using `SmartAttachmentServiceTests.swift`.
- Whether UI screenshots are available in the local environment. If not produced, EB03B must record named previews only.
- Whether any focused UI test exists for the Capture composer route lane. If not, EB03B must either add one under the existing UI-test convention or mark human/rendered proof Yellow.

## Required Tests

Minimum focused tests before EB03B can be considered valid:

- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`
  - Add/update route tests for task, goal seed, proof attachment, waiting, plan/This Week, weak input Needs a Place, and deterministic candidate ranking.
  - Add/update proof that no network/account/calendar candidate is required.
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift` or new `Native/AmbitionsTests/Services/SmartAttachmentCaptureAdapterTests.swift`
  - Prove each EB03B route result maps to the expected `CreateCaptureRequest.kind`, `route`, `triageStatus`, `assumptionSummary`, privacy/local-only posture, and correction actions.
- `Native/AmbitionsTests/Captures/CapturesViewModelTests.swift`
  - Add/update composer tests for typed draft preview, manual route choice, save behavior, failed save preserving draft, receipt/action message, active goal candidate filtering, and no inbox/backlog/AI jargon in visible copy.
- `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`
  - Add/update service tests proving created captures persist the expected route/kind/status and event-ledger entries without schema changes.
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
  - Add/update round-trip proof only if EB03B changes any persisted capture field or serialization expectation. If no persistence code changes occur, record non-change proof and rerun existing capture repository tests.
- `Native/AmbitionsTests/Domain/SmartAttachmentModelsTests.swift`
  - Add/update raw-value and receipt-projection tests only if EB03B touches Smart Attachment models.
- `Native/AmbitionsTests/Services/AmbitionsCommandExecutorTests.swift`
  - Run/update only if EB03B changes command capture routing or shared capture import behavior.

Focused command lane for EB03B, adjusted after actual touched files:

- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/SmartAttachmentServiceTests -only-testing:AmbitionsTests/CapturesViewModelTests -only-testing:AmbitionsTests/CaptureServiceTests -only-testing:AmbitionsTests/PersistenceRepositoryTests | xcbeautify`
- If test identifiers differ, EB03B must record the exact substitute command and result.
- `scripts/build-local.sh` is required if production Swift is touched.

## Required Preview / Fixture Lane

Grounded preview files/seams:

- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
  - Existing previews: `Capture Empty`, `Capture Route Suggestions`, `Capture Receipt`, `Capture Light`.
  - EB03B should add or update named previews for normal routed composer, setup/empty composer, weak input Needs a Place, manual route correction, receipt after save, high Dynamic Type, and Reduce Motion where the repo preview convention supports it.
- `Sources/Previews/DynamicAdaptiveVisualPreviews.swift`
  - Existing DAV scenarios: `empty-capture`, `routed-capture`, `high-dynamic-type`, and `reduce-motion`.
  - EB03B should update labels/evidence only if UI behavior changes require the global scenario gallery to stay accurate.
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
  - Existing preview factory in `CapturesScreen.swift` uses view-model state. EB03B can expand the local factory without persistence changes.

Needs evidence:

- Rendered screenshot export support for these previews. If EB03B does not produce screenshots, it must state “screenshots not produced” and list preview names as evidence only.

## Rollback Plan

If EB03B route split is wrong:

1. Revert EB03B changes in `Native/Ambitions/Features/Captures/CapturesScreen.swift`, `CapturesViewModel.swift`, and `CaptureDraftRoutePreviewCard.swift` to restore prior composer/preview behavior.
2. Revert EB03B changes in `Native/Ambitions/Services/SmartAttachmentService.swift` and `SmartAttachmentCaptureAdapter.swift` to restore deterministic routing and route-to-request mapping.
3. Revert any EB03B change in `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift` and `SmartAttachmentModels.swift`; if any raw value or Codable field was touched, stop and require compatibility/migration proof before merge.
4. Do not revert unrelated completed DAV/EB work.
5. Revert or update only EB03B-focused tests/previews that were added for the failed behavior.
6. Preserve EB03A owner-map docs and train split unless the split itself is proven wrong; EB03 remains blocked rather than returning to broad implementation.

## Global Batch Train Update Plan

| Train artifact | Required update | Why it must change | Evidence | Status |
|---|---|---|---|---|
| `docs/codex/BATCH_REGISTRY.md` | Record EB03 as split/blocked; record EB03A as complete owner-map repair after this commit; record EB03B as next eligible implementation gate. | The registry is operational status truth and currently names EB03 as active queued without the split. | Current registry contains “Active Planned / Queued: EB03...” and current reports name the EB03A/EB03B repair path. | Updated in this batch. |
| `docs/codex/GLOBAL_FUTURE_BATCH_EXECUTION_ORDER.md` | Replace the single EB03 row with EB03A/EB03B suborder entries under global 075 and keep EB04 at 076. | The global order must not route Codex back into broad EB03 after the scope Red. | Current row 075 points to EB03; blocked report says proceeding requires EB03A owner map then EB03B implementation. | Updated in this batch. |
| `docs/codex/batch-trains/EB01_EB40_EXTERNAL_BRAIN_FOUNDATION_TRAIN.md` | Mark EB03 as split into EB03A/EB03B; EB03A complete as repair evidence; EB03B next implementation gate; no app behavior claimed. | EB train manifest must preserve the parent EB03 identity while preventing broad implementation. | EB train currently lists EB03 as active planned/queued and allows later Capture composer/routing. | Updated in this batch. |
| `.codex/reports/current-run-state.md` | Update current batch to EB03A complete / EB03B next eligible and preserve no Swift/app behavior claim. | Next-session handoff must not restart EB03 or completed DAV/EB batches. | Current run state says EB03 blocked and owner-map repair is required. | Updated in this batch. |
| `.codex/reports/current-batch-train-state.md` | Mirror current-run-state split and next eligible EB03B. | Batch train state is the immediate train handoff. | Current train state matches current-run-state blocker. | Updated in this batch. |
| `scripts/global-train-next-batch.sh` | Teach deterministic next-batch calculation to output EB03A before EB03B and EB03B before EB04. | The script previously fell through to broad EB03 after EB24. | Script loop ended at EB24 and fallback printed EB03. | Updated in this batch. |
| `docs/codex/batches/EB03_Universal_Capture_Composer_And_Routing_Prompt.md` | Do not run as direct implementation prompt until EB03B prompt is created or this prompt is narrowed from EB03A evidence. | Current prompt allowed broad production families and caused the blocker. | Blocked report and current-run-state identify missing exact owners/tests/previews/rollback/proof. | Not updated; EB03B draft below is the next input. |

## EB03B Prompt Draft

Title: EB03B Universal Capture Composer Routing Implementation

Mission:

Implement the first safely scoped EB03 production behavior pass using the EB03A owner map. Do not restart broad EB03. Do not touch persistence schema, route/raw values, top-level tabs, dependencies, workflows, signing, production assets, or unrelated surfaces.

Required read order:

1. `docs/audits/eb03a-universal-capture-composer-routing-owner-map-report.md`
2. `docs/audits/eb03-universal-capture-composer-routing-blocked-report.md`
3. `docs/canon/Ambitions_4_0_External_Brain_Foundation_Index.md`
4. `docs/canon/Ambitions_4_0_External_Brain_Cross_Kernel_Primitives_And_Dependencies.md`
5. `Native/Ambitions/Features/Captures/CapturesScreen.swift`
6. `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
7. `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
8. `Native/Ambitions/Services/SmartAttachmentService.swift`
9. `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
10. `Native/Ambitions/Domain/CaptureModels.swift`
11. `Native/Ambitions/Domain/SmartAttachmentModels.swift`
12. `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
13. Focused tests listed in EB03A.

Allowed files:

- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Captures/CapturesViewModel.swift`
- `Native/Ambitions/Features/Captures/CaptureDraftRoutePreviewCard.swift`
- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/Ambitions/Services/SmartAttachmentCaptureAdapter.swift`
- `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
- `Native/AmbitionsTests/Services/SmartAttachmentServiceTests.swift`
- `Native/AmbitionsTests/Captures/CapturesViewModelTests.swift`
- `Native/AmbitionsTests/Persistence/CaptureServiceTests.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`
- `Native/AmbitionsTests/Domain/SmartAttachmentModelsTests.swift` only if Smart Attachment model behavior is touched
- `Sources/Previews/DynamicAdaptiveVisualPreviews.swift` only if scenario evidence must be updated
- `docs/audits/eb03b-universal-capture-composer-routing-implementation-report.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

Forbidden files:

- `Native/Ambitions/Persistence/SwiftDataModels.swift` unless EB03B stops and produces migration/compatibility proof first.
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift` unless EB03B stops and produces persistence proof first.
- `Native/Ambitions/App/**` unless a route compatibility owner batch is created.
- Any file outside Capture, Smart Attachment, focused tests, previews, and evidence without a written owner-map amendment.

Required implementation target:

- Make the Capture composer’s route suggestion lane clearer, correctable, and evidence-bound using existing Smart Attachment routing.
- Preserve local deterministic behavior.
- Preserve raw capture text.
- Preserve existing route/raw enum values.
- Preserve “Needs a Place” fallback.
- Preserve user correction/change path.
- Preserve no-calendar/no-network/no-hidden-automation posture.

Required proof before merge:

- Route proof for task, goal seed, proof attachment, plan, waiting, idea/Needs a Place, weak input, and manual correction.
- Raw representation proof for `CaptureKind`, `CaptureRoute`, `CaptureTriageStatus`, and `SmartAttachmentRouteType` if touched.
- Persistence non-change proof and focused capture-service persistence tests.
- Accessibility non-regression proof: labels, values, hints, Dynamic Type notes, Reduce Motion notes, non-color meaning, and tap-target notes.
- Preview proof: named Capture previews, plus screenshot status honestly marked produced or not produced.
- Rollback proof: list exact EB03B files to revert.

Validation:

- `git status --short`
- `git diff --check`
- `scripts/eb-active-train-integration-gate.sh || true`
- `scripts/eb-no-unsupported-claim-scan.sh || true`
- `scripts/eb-no-5-version-drift-scan.sh || true`
- `scripts/no-fake-proof-gate.sh || true`
- `scripts/canon-language-drift-scan.sh || true`
- `scripts/release-claim-safety-scan.sh || true`
- Focused tests named by actual touched files
- `scripts/build-local.sh` if production Swift is touched
- `scripts/batch-train-gate-check.sh || true`

Commit message:

`Implement EB03B universal capture composer routing`

Next safe path:

If EB03B passes Green or accepted Yellow, update the train to EB04. If EB03B is Yellow due to missing rendered screenshot/human device proof only, own it explicitly. If route/raw/persistence/accessibility proof is missing, stop Red and repair before EB04.

## Validation Results

Recorded by EB03A after edits:

- `git status --short`: showed only EB03A docs/script changes.
- `git diff --check`: PASS.
- `bash -n scripts/global-train-next-batch.sh scripts/eb-active-train-integration-gate.sh scripts/batch-train-gate-check.sh`: PASS.
- `scripts/global-train-next-batch.sh || true`: repaired to report EB03B after EB03A completion.
- `scripts/eb-active-train-integration-gate.sh || true`: PASS for required EB active-train evidence; no hard failure.
- `scripts/eb-no-unsupported-claim-scan.sh || true`: advisory hits from existing claim-boundary docs/scripts; no EB03A unsupported claim.
- `scripts/eb-no-5-version-drift-scan.sh || true`: advisory existing backlog; no EB03A 5.0 status claim.
- `scripts/no-fake-proof-gate.sh || true`: advisory existing backlog; EB03A does not claim screenshots, device proof, VoiceOver proof, Instruments, battery proof, production readiness, or release readiness.
- `scripts/canon-language-drift-scan.sh || true`: advisory existing backlog; no EB03A user-facing product copy change.
- `scripts/release-claim-safety-scan.sh || true`: advisory existing backlog; EB03A adds only non-claim boundaries.
- `scripts/run-doc-qa.sh || true`: advisory; docs QA completed with existing markdownlint/deprecated-language backlog and lychee OK.
- `scripts/batch-train-gate-check.sh || true`: PASS with expected `YELLOW_HINT working tree has changes` during validation; `git diff --check` passed.

Yellow advisories:

- EB03B screenshot/rendered visual proof is not produced by EB03A and remains future-owned.
- EB03B human/device/VoiceOver review is not produced by EB03A and remains future-owned.
- EB03 remains not implemented as app behavior until EB03B or a later scoped batch changes code and proves it.

Red issues:

- Prior broad EB03 scope Red is repaired by this owner map and train split. No remaining EB03A Red after final validation.
