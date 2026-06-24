# SCG-006 Root Cause Map

Issue: `AMB-1289 / SCG-006`
Branch: `main`
HEAD: `da113a78122394f0b6e0663e88ac3cc8920ca569`
Generated: `2026-06-24T01:07:22Z`
Status: `Yellow`

This map groups every Yellow/Unknown flow gap from `FLOW_TRACE_AUDIT` into root-cause candidates. It does not open repairs or implementation issues.

## Summary

- Root causes generated: `10`
- B0 count: `0`
- B1 count: `0`
- B2 count: `0`
- B3 count: `9`
- B4 count: `1`
- Known-issues updates: none; no new Red/B0/B1/B2 flow finding discovered.

| ID | Severity | Status | Affected flows | Known issue | Owner train |
| --- | --- | --- | --- | --- | --- |
| RC-SCG006-001 | B3 | Open - Yellow | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 | AMB-ISSUE-0014; AMB-ISSUE-0807; AMB-ISSUE-1801; AMB-ISSUE-1802 | Final proof/accessibility/runtime proof train; not SCG-006 |
| RC-SCG006-002 | B3 | Open - Yellow | SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F12 | AMB-ISSUE-0003; AMB-ISSUE-0008; AMB-ISSUE-0012; AMB-ISSUE-1101; AMB-ISSUE-1102; AMB-ISSUE-1103; AMB-ISSUE-1104; AMB-ISSUE-1105; AMB-ISSUE-1106; AMB-ISSUE-1107 | Capture composer owner train; not SCG-006 |
| RC-SCG006-003 | B3 | Open - Yellow | SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F13 | AMB-ISSUE-1301; AMB-ISSUE-1302; AMB-ISSUE-1303; AMB-ISSUE-1304; AMB-ISSUE-1309; AMB-ISSUE-0004; AMB-ISSUE-0005 | Goals/Today runtime proof owner train; not SCG-006 |
| RC-SCG006-004 | B3 | Open - Yellow | SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F13, SCG006-F14 | AMB-ISSUE-0004; AMB-ISSUE-0005; AMB-ISSUE-1001; AMB-ISSUE-1002; AMB-ISSUE-1003; AMB-ISSUE-1004; AMB-ISSUE-1005; AMB-ISSUE-1006; AMB-ISSUE-1007; AMB-ISSUE-0014; AMB-ISSUE-0807; AMB-ISSUE-1801; AMB-ISSUE-1802 | Today/closure/runtime proof owner train; not SCG-006 |
| RC-SCG006-005 | B3 | Open - Yellow | SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F16 | AMB-ISSUE-0009; AMB-ISSUE-0501; AMB-ISSUE-0502; AMB-ISSUE-0503; AMB-ISSUE-0506; AMB-ISSUE-0507; AMB-ISSUE-0913; AMB-ISSUE-1401; AMB-ISSUE-1402; AMB-ISSUE-1403; AMB-ISSUE-1404 | Time native Life Calendar / Today coupling proof train; not SCG-006 |
| RC-SCG006-006 | B3 | Open - Yellow | SCG006-F12, SCG006-F13 | AMB-ISSUE-0701; AMB-ISSUE-1601; AMB-ISSUE-1602; AMB-ISSUE-1603; AMB-ISSUE-1604; AMB-ISSUE-1605 | Search Find / Act / Inspect proof train; not SCG-006 |
| RC-SCG006-007 | B3 | Open - Yellow | SCG006-F08, SCG006-F10, SCG006-F11, SCG006-F14 | AMB-ISSUE-0014; AMB-ISSUE-1801; AMB-ISSUE-1802 | Runtime/Trust/Undo owner train; not SCG-006 |
| RC-SCG006-008 | B3 | Open - Unknown risk carried | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16 | none - governance Yellow carried in SCG artifacts | SCG governance/schema/intake train; not SCG-006 unless explicitly scoped |
| RC-SCG006-009 | B3 | Open - Yellow | SCG006-F15, SCG006-F16 | AMB-ISSUE-0014 | Privacy/local-first/offline proof train; not SCG-006 |
| RC-SCG006-010 | B4 | Open - Yellow | SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16 | AMB-ISSUE-0806; AMB-ISSUE-0807; AMB-ISSUE-1706; AMB-ISSUE-1709; AMB-ISSUE-1801; AMB-ISSUE-1802 | Visual/accessibility proof owner train; not SCG-006 |

## RC-SCG006-001 - Current runtime/device proof is missing for traced flows

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Stage, Composer/Capture, Surfaces/Today, Surfaces/Goals, Surfaces/Time, Trust, Core/Persistence, Core/Permissions
- Evidence: RELEASE_TRUTH forbids runtime, visual, accessibility, offline, account, and release claims without current proof.; KNOWN_ISSUES current release verdict records Runtime Yellow / Visual Yellow-Red / Accessibility Yellow / Release Red-Yellow.
- Source artifact: docs/truth/RELEASE_TRUTH.md; docs/qa/KNOWN_ISSUES.md; docs/quality/senior-review/SENIOR_CODE_REVIEW_SUMMARY.md
- Linked known issue: AMB-ISSUE-0014; AMB-ISSUE-0807; AMB-ISSUE-1801; AMB-ISSUE-1802
- Likely owner train: Final proof/accessibility/runtime proof train; not SCG-006
- Required repair: Produce current executable runtime/device proof for each flow after owning repairs land.
- Required tests: Flow-specific UI/runtime tests plus current screenshot or device evidence where visible behavior is claimed.
- Required proof: Current logs, screenshots/video where relevant, accessibility notes, and artifact index tied to commit.

## RC-SCG006-002 - Capture save and keyboard/full-screen composer proof remains pending

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F12
- Affected files/layers: Composer/Capture, Stage overlay, AppShellActivatedCaptureSeam, Core/Runtime CaptureService
- Evidence: CaptureViewModel and DefaultCaptureService provide local save, route preview, event ledger, and accessibility announcements, but known issues still require full-screen composer, keyboard, receipt, and device proof.; SCG-004 SwiftUICompositionAudit flags CaptureContinuityLine as a B4 composition review candidate.
- Source artifact: docs/qa/KNOWN_ISSUES.md; docs/quality/senior-review/AUTOMATED_FINDINGS.json; Native/Ambitions/Composer/Capture/CaptureViewModel.swift
- Linked known issue: AMB-ISSUE-0003; AMB-ISSUE-0008; AMB-ISSUE-0012; AMB-ISSUE-1101; AMB-ISSUE-1102; AMB-ISSUE-1103; AMB-ISSUE-1104; AMB-ISSUE-1105; AMB-ISSUE-1106; AMB-ISSUE-1107
- Likely owner train: Capture composer owner train; not SCG-006
- Required repair: Prove global full-screen composer states and save/proposal/receipt behavior, then repair any failed UI/runtime links.
- Required tests: Capture save before/action/after tests, keyboard/full-screen UI test, accessibility announcement test, route correction test.
- Required proof: Blank, focused keyboard, proposal, saved receipt, and correction screenshots plus focused test log.

## RC-SCG006-003 - Goal creation to Today coupling is source-backed but not device/runtime closed

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F13
- Affected files/layers: Surfaces/Goals, Projection/SurfaceLenses, Surfaces/Today, Core/Persistence
- Evidence: CreateGoalViewModel submits through GoalsService and TodayFreshGoalVisibilityTests prove created goal visibility in Today against in-memory repositories.; Known issues keep Goals visual/runtime proof pending, including Goals plus/no-crash and clipped/dock-overlap proof.
- Source artifact: Native/Ambitions/Surfaces/Goals/CreateGoalViewModel.swift; Native/AmbitionsTests/Today/TodayFreshGoalVisibilityTests.swift; docs/qa/KNOWN_ISSUES.md
- Linked known issue: AMB-ISSUE-1301; AMB-ISSUE-1302; AMB-ISSUE-1303; AMB-ISSUE-1304; AMB-ISSUE-1309; AMB-ISSUE-0004; AMB-ISSUE-0005
- Likely owner train: Goals/Today runtime proof owner train; not SCG-006
- Required repair: After SCG intake, prove create goal, route to goal detail, Today feed, and Start here selection on current runtime.
- Required tests: Create goal UI path, persistence reload, Today recommendation, Goal Detail route, no-crash plus tests.
- Required proof: Current simulator/device flow capture with focused test logs and known-issues reconciliation.

## RC-SCG006-004 - Today Start/Close/Move mutation links are partial and proof-pending

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F13, SCG006-F14
- Affected files/layers: Surfaces/Today, Interaction, Projection/SurfaceLenses, Core/Runtime ClosureEngine, EventLedger
- Evidence: TodayViewModel refreshes after actions and TodayCommandActionHandler emits event ledger entries for new feedback/evidence/captures.; Known issues still require before/action/after mutation proof, root action gating proof, and proof/undo artifacts.
- Source artifact: Native/Ambitions/Surfaces/Today/TodayViewModel.swift; Native/Ambitions/Interaction/TodayCommandActionHandler.swift; docs/qa/KNOWN_ISSUES.md
- Linked known issue: AMB-ISSUE-0004; AMB-ISSUE-0005; AMB-ISSUE-1001; AMB-ISSUE-1002; AMB-ISSUE-1003; AMB-ISSUE-1004; AMB-ISSUE-1005; AMB-ISSUE-1006; AMB-ISSUE-1007; AMB-ISSUE-0014; AMB-ISSUE-0807; AMB-ISSUE-1801; AMB-ISSUE-1802
- Likely owner train: Today/closure/runtime proof owner train; not SCG-006
- Required repair: Prove Start now, Still counts, Move it, inspection, and undo paths with real persisted Step state.
- Required tests: Before/action/after Today tests, closure stage mutation tests, route/inspection tests, undo availability tests.
- Required proof: Current screenshots or video plus event ledger/proof artifact IDs after each mutation.

## RC-SCG006-005 - Time mutation and Today recompute have focused tests but remain visual/device proof pending

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F14, SCG006-F16
- Affected files/layers: Surfaces/Time, Projection/Mutations, Projection/SurfaceLenses/TodayLens, Core/Runtime ScheduleInstallKernel, Core/Permissions
- Evidence: TimeTodayCouplingTests prove place/protect/correction recompute Today and require time cause proof.; SCG-004 TimeCorrectnessAudit flags direct Date() in StageReducer and other files; known issues keep Time proof pending.
- Source artifact: Native/AmbitionsTests/Time/TimeTodayCouplingTests.swift; docs/quality/senior-review/AUTOMATED_FINDINGS.json; docs/qa/KNOWN_ISSUES.md
- Linked known issue: AMB-ISSUE-0009; AMB-ISSUE-0501; AMB-ISSUE-0502; AMB-ISSUE-0503; AMB-ISSUE-0506; AMB-ISSUE-0507; AMB-ISSUE-0913; AMB-ISSUE-1401; AMB-ISSUE-1402; AMB-ISSUE-1403; AMB-ISSUE-1404
- Likely owner train: Time native Life Calendar / Today coupling proof train; not SCG-006
- Required repair: Prove visible Time mutation, Today recompute, permission-denied fallback, and undo in current runtime.
- Required tests: Time mutation UI tests, injected-clock regression, permission-denied fallback tests, Today recompute tests.
- Required proof: Current Time mutation screenshots/video, accessibility announcements, and focused test logs.

## RC-SCG006-006 - Search / Memory Lens is local-source-backed but device route proof is pending

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F12, SCG006-F13
- Affected files/layers: Core/Runtime MemoryLensService, Stage overlays, ShellCommandRouter, Trust
- Evidence: DefaultMemoryLensService reads local repositories and MemoryLensServiceTests cover steps, goals, proof, teaching, learning, source confidence, and trust decay.; Known issues keep Search runtime/device visual acceptance pending.
- Source artifact: Native/Ambitions/Core/Runtime/MemoryLensService.swift; Native/AmbitionsTests/App/MemoryLensServiceTests.swift; docs/qa/KNOWN_ISSUES.md
- Linked known issue: AMB-ISSUE-0701; AMB-ISSUE-1601; AMB-ISSUE-1602; AMB-ISSUE-1603; AMB-ISSUE-1604; AMB-ISSUE-1605
- Likely owner train: Search Find / Act / Inspect proof train; not SCG-006
- Required repair: Prove search overlay route, result action, inspection handoff, and local-only behavior on current runtime.
- Required tests: Memory Lens UI route tests, result action tests, local-only/privacy tests, visual hierarchy tests.
- Required proof: Search overlay screenshots/video plus route-depth and local-index evidence.

## RC-SCG006-007 - Undo is implemented for Time visible mutations but uneven across closure/destructive/runtime flows

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F08, SCG006-F10, SCG006-F11, SCG006-F14
- Affected files/layers: Projection/Mutations, Core/Runtime ClosureEngine, Trust/Receipt, You memory controls
- Evidence: TimeFieldMutationCoordinator.undo restores previous Time state and creates undo visible mutation.; You memory controls explicitly block broad destructive memory actions until confirmation, receipt, and undo coverage are proven.; SCG-004 RuntimeMutationProofAudit flags mutation/action candidates without local proof/receipt/undo markers.
- Source artifact: Native/Ambitions/Projection/Mutations/TimeFieldMutationCoordinator.swift; Native/Ambitions/Projection/SurfaceLenses/YouFeatureServiceMemoryVaultProjection.swift; docs/quality/senior-review/AUTOMATED_FINDINGS.json
- Linked known issue: AMB-ISSUE-0014; AMB-ISSUE-1801; AMB-ISSUE-1802
- Likely owner train: Runtime/Trust/Undo owner train; not SCG-006
- Required repair: Inventory mutation paths by owner and add uniform undo/correction contracts where safe.
- Required tests: Undo contract tests for Time, closure, capture route changes, and blocked destructive actions.
- Required proof: Receipt/undo artifact IDs plus user-visible before/after evidence.

## RC-SCG006-008 - SCG governance unknowns and missing review ledger schema remain unresolved input risk

- Severity: `B3`
- Status: Open - Unknown risk carried
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F15, SCG006-F16
- Affected files/layers: Docs, Legacy/Unknown, Quality, SCG control plane
- Evidence: SCG-005 carries 117 Unknown file-review entries and 361 Yellow entries.; docs/quality/senior-review/schemas/review_ledger.schema.json remains a missing required input.; SCG-004 StaleReviewAudit flagged FILE_INVENTORY freshness as accepted Yellow.
- Source artifact: docs/quality/senior-review/SENIOR_CODE_REVIEW_LEDGER.json; docs/quality/senior-review/AUTOMATED_FINDINGS.json
- Linked known issue: none - governance Yellow carried in SCG artifacts
- Likely owner train: SCG governance/schema/intake train; not SCG-006 unless explicitly scoped
- Required repair: Resolve owner/schema/staleness governance in a future SCG governance slice without altering production behavior.
- Required tests: Schema validation and deterministic inventory/ledger regression tests.
- Required proof: Schema file present or explicit accepted-Yellow waiver, refreshed inventories, and validation logs.

## RC-SCG006-009 - Offline/no-account and local-first posture is source-present but release proof is absent

- Severity: `B3`
- Status: Open - Yellow
- Affected flows: SCG006-F15, SCG006-F16
- Affected files/layers: AppContainerFactory, Core/Persistence, Core/Runtime, Core/Permissions, Privacy boundary
- Evidence: AppContainerFactory live configuration uses persistent SwiftData repositories and local runtime services.; RELEASE_TRUTH explicitly states offline with no account behavior is not release-proven.; SCG-004 PrivacyLocalFirstAudit flags network/cloud/privacy-sensitive candidates for later proof.
- Source artifact: Native/Ambitions/App/AppContainerFactory.swift; docs/truth/RELEASE_TRUTH.md; docs/quality/senior-review/AUTOMATED_FINDINGS.json
- Linked known issue: AMB-ISSUE-0014
- Likely owner train: Privacy/local-first/offline proof train; not SCG-006
- Required repair: Prove no-account launch, offline core flows, and request-shape privacy boundaries after owner scope is opened.
- Required tests: Offline launch/use tests, account-absent tests, privacy boundary/request-shape tests, permission-denied tests.
- Required proof: Current test logs and device/simulator proof with network/account disabled.

## RC-SCG006-010 - Static accessibility/visual composition findings remain relevant to visible flow proof

- Severity: `B4`
- Status: Open - Yellow
- Affected flows: SCG006-F01, SCG006-F02, SCG006-F03, SCG006-F04, SCG006-F05, SCG006-F06, SCG006-F07, SCG006-F08, SCG006-F09, SCG006-F10, SCG006-F11, SCG006-F12, SCG006-F13, SCG006-F14, SCG006-F16
- Affected files/layers: Composer/Capture, Surfaces/Goals, Surfaces/You, Stage/Chrome, DesignSystem
- Evidence: SCG-004 AccessibilityStaticAudit flags YouRootDetailSheet; SwiftUICompositionAudit flags Capture/Goals/You composition candidates.; Known issues keep visual/device/accessibility proof gaps open.
- Source artifact: docs/quality/senior-review/AUTOMATED_FINDINGS.json; docs/qa/KNOWN_ISSUES.md
- Linked known issue: AMB-ISSUE-0806; AMB-ISSUE-0807; AMB-ISSUE-1706; AMB-ISSUE-1709; AMB-ISSUE-1801; AMB-ISSUE-1802
- Likely owner train: Visual/accessibility proof owner train; not SCG-006
- Required repair: Review flagged composition/accessibility files when owning visual/accessibility trains are opened.
- Required tests: Rendered hierarchy/frame tests, accessibility semantics tests, Dynamic Type and reduced-motion checks.
- Required proof: Reviewable screenshots, target-versus-actual critique, and manual accessibility proof where required.
