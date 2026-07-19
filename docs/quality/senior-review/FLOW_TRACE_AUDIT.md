# SCG-006 Flow Trace Audit

Issue: `AMB-1289 / SCG-006`
Branch: `main`
HEAD: `da113a78122394f0b6e0663e88ac3cc8920ca569`
Generated: `2026-06-24T01:07:22Z`
Status: `Yellow`

This artifact traces the requested Ambitions product flows from SCG-001 through SCG-005 inputs and live source/test inspection. It does not repair production code, does not create implementation issues, does not start SCG-007, and does not claim senior-readiness.

## Summary

- Flows traced: `16`
- Green flow count: `0`
- Yellow flow count: `16`
- Red flow count: `0`
- Unknown flow count: `0`
- Root causes generated: `10`
- Known-issues updates: none; no new real Red/B0/B1/B2 flow finding discovered.
- SCG-005 Yellow files carried forward: `361`
- SCG-005 Unknown entries carried forward: `117`
- SCG-004 real Yellow findings carried forward: `13`
- SCG-004 fixture-only findings: `16` fixture proof only
- `SCG-BG-001`: resolved and preserved as resolved.
- Missing `review_ledger.schema.json`: carried forward as governance Yellow.

## Flow Matrix

| Flow | Name | Status | Root causes | Known issues | Missing links |
| --- | --- | --- | --- | --- | --- |
| SCG006-F01 | App launch | Yellow | RC-SCG006-001, RC-SCG006-008, RC-SCG006-010 | AMB-ISSUE-0014, AMB-ISSUE-0016, AMB-ISSUE-0807 | No current build/launch/device proof; AmbitionsStageHost SCG-005 Yellow; release truth forbids launch readiness claims. |
| SCG006-F02 | Surface switch | Yellow | RC-SCG006-001, RC-SCG006-008, RC-SCG006-010 | AMB-ISSUE-0806, AMB-ISSUE-1701, AMB-ISSUE-1702, AMB-ISSUE-1703, AMB-ISSUE-1706 ... | Known shell/dock overlap and full route-depth proof gaps remain; no current screenshot proof in SCG-006. |
| SCG006-F03 | Capture save | Yellow | RC-SCG006-002, RC-SCG006-001, RC-SCG006-008, RC-SCG006-010 | AMB-ISSUE-0003, AMB-ISSUE-0008, AMB-ISSUE-0012, AMB-ISSUE-1101, AMB-ISSUE-1102 ... | SCG-004 composition/mutation findings and known Capture full-screen/keyboard/receipt proof gaps remain. |
| SCG006-F04 | Capture expand with keyboard | Yellow | RC-SCG006-002, RC-SCG006-001, RC-SCG006-010 | AMB-ISSUE-0003, AMB-ISSUE-0008, AMB-ISSUE-0012, AMB-ISSUE-1101, AMB-ISSUE-1102 ... | Known AMB-ISSUE-0008/0012/1101 require full-screen keyboard/proposal/receipt screenshots. |
| SCG006-F05 | Create goal | Yellow | RC-SCG006-003, RC-SCG006-001, RC-SCG006-008, RC-SCG006-010 | AMB-ISSUE-1301, AMB-ISSUE-1302, AMB-ISSUE-1303, AMB-ISSUE-1304, AMB-ISSUE-1309 | Known Goals plus/no-crash and visual acceptance remain pending. |
| SCG006-F06 | Goal thread feeds Today | Yellow | RC-SCG006-003, RC-SCG006-004, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003 ... | Device/runtime proof for Today feed and no-step valid state remains pending in known issues. |
| SCG006-F07 | Start recommended step | Yellow | RC-SCG006-004, RC-SCG006-003, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003 ... | Known Today before/action/after proof and action gating still pending. |
| SCG006-F08 | Close step | Yellow | RC-SCG006-004, RC-SCG006-007, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003 ... | Known AMB-ISSUE-0004 and proof rows require before/action/after proof/undo artifact. |
| SCG006-F09 | Move step | Yellow | RC-SCG006-004, RC-SCG006-005, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003 ... | Known Today/Time runtime proof and fake placement proof gaps remain pending. |
| SCG006-F10 | Protect window | Yellow | RC-SCG006-005, RC-SCG006-007, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0009, AMB-ISSUE-0501, AMB-ISSUE-0502, AMB-ISSUE-0503, AMB-ISSUE-0506 ... | Known Time protected-window and device proof rows pending. |
| SCG006-F11 | Time correction recomputes Today | Yellow | RC-SCG006-005, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0009, AMB-ISSUE-0501, AMB-ISSUE-0502, AMB-ISSUE-0503, AMB-ISSUE-0506 ... | Known Time device screenshot and injected clock/audit Yellow gaps remain. |
| SCG006-F12 | Search / Memory Lens | Yellow | RC-SCG006-006, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0701, AMB-ISSUE-1601, AMB-ISSUE-1602, AMB-ISSUE-1603, AMB-ISSUE-1604 ... | Known Search runtime/device proof pending; SCG-004 fixture-only search not repo finding. |
| SCG006-F13 | Inspection / Why this? | Yellow | RC-SCG006-004, RC-SCG006-006, RC-SCG006-007, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0014, AMB-ISSUE-0807, AMB-ISSUE-1801, AMB-ISSUE-1802, AMB-ISSUE-0701 ... | Proof/accessibility/inspection known issues and SCG-004 mutation proof findings remain. |
| SCG006-F14 | Undo | Yellow | RC-SCG006-007, RC-SCG006-005, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0014, AMB-ISSUE-0807, AMB-ISSUE-1801, AMB-ISSUE-1802 | Undo is not uniformly proven for closure/capture/destructive flows; SCG-004 RuntimeMutationProofAudit applies. |
| SCG006-F15 | Offline / no account | Yellow | RC-SCG006-009, RC-SCG006-001, RC-SCG006-008 | AMB-ISSUE-0014 | Release Truth says offline with no account not validated; SCG-004 privacy-local findings remain. |
| SCG006-F16 | Permission denied fallback | Yellow | RC-SCG006-005, RC-SCG006-009, RC-SCG006-001, RC-SCG006-008, RC-SCG006-010 | AMB-ISSUE-0014, AMB-ISSUE-0807, AMB-ISSUE-1801, AMB-ISSUE-1802 | No current permission-denied runtime proof; known accessibility/manual proof gaps remain. |

## SCG006-F01 - App launch

- Status: `Yellow`
- User intent: Open Ambitions into the local-first Stage.
- Entry surface: System / app icon / external URL
- Control / trigger: App process start, onOpenURL, lifecycle active
- Interaction owner: App, DesignSystem launch gate, AppContainerFactory
- Command: AmbitionsApp -> AmbitionsRootScene -> LaunchGateView -> AppBootstrapper.start -> AppContainerFactory.make -> AmbitionsStageHost
- Validation: Bootstrap configuration selects persistent store for live; LaunchGate handles idle/loading/ready/failed; app feature flag/deep-link validation asserts in Stage.
- Runtime mutation: Creates AppContainer, repositories, runtime services, StageStore initial surface, notification/runtime refresh.
- Persistence / proof: SwiftData repositories and runtime snapshot writer are wired; proof readiness not claimed.
- Projection: AmbitionsStage renders selected root surface and shell chrome.
- Visible UI mutation: Launch gate transitions loading/failure/ready; Stage host receives accessibility label.
- Motion event: Stage motion configured on appear and reduce-motion changes update StageOwner.
- Accessibility: StageHost accessibility label Ambitions; launch failure includes retry; manual accessibility proof not current.
- Undo / fallback: Failure view offers Retry; external routes can fallback to Today.
- Tests: AppContainerFactoryTests; AppReleaseConfigurationTests; current xcode build not run in SCG-006.
- Proof artifacts: SCG inputs, source inspection only; no launch runtime proof generated.
- Missing links: No current build/launch/device proof; AmbitionsStageHost SCG-005 Yellow; release truth forbids launch readiness claims.
- Root causes: RC-SCG006-001, RC-SCG006-008, RC-SCG006-010
- Related automated-audit findings: SCG-004-001, SCG-004-009, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0014, AMB-ISSUE-0016, AMB-ISSUE-0807
- Related file-review findings: 7 inspected rows; statuses {'Green': 6, 'Yellow': 1}

## SCG006-F02 - Surface switch

- Status: `Yellow`
- User intent: Move between Today, Goals, Time, and You without creating a fifth root surface.
- Entry surface: Root shell dock / contextual route
- Control / trigger: Root dock icon tap or selected-surface state change
- Interaction owner: StageStore, StageReducer, Stage Chrome
- Command: StageStore.selectRootSurfaceFromDock -> StageReducer.selectSurface/selectToday -> StageEffect.surfaceChanged
- Validation: AmbitionsSurface canonicalTopLevelTab and StagePathStore root dock policy gate overlays/drilldowns.
- Runtime mutation: StageState.selectedSurface and path/overlay state mutate; route depth may reset on reselection.
- Persistence / proof: StageEffect proofArtifact stage.surface.*; command history can record route context.
- Projection: AmbitionsRootStageSurfaceHost switches NavigationStack host for Today/Goals/Time/You.
- Visible UI mutation: Selected surface changes, dock visibility follows root/drilldown/overlay policy.
- Motion event: Stage morph/effect runner records transition/focus plans.
- Accessibility: StageEffect accessibility announcement names selected surface; dock labels are VoiceOver available.
- Undo / fallback: Overlay dismissed or current surface reselection scrolls/returns root.
- Tests: ShellCommandRouterTests; StageMotionRoutingTests; shell UI tests exist but visual proof remains pending.
- Proof artifacts: SCG source trace plus SCG-004 ChromeSafeArea/VisualProof findings.
- Missing links: Known shell/dock overlap and full route-depth proof gaps remain; no current screenshot proof in SCG-006.
- Root causes: RC-SCG006-001, RC-SCG006-008, RC-SCG006-010
- Related automated-audit findings: SCG-004-001, SCG-004-009, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0806, AMB-ISSUE-1701, AMB-ISSUE-1702, AMB-ISSUE-1703, AMB-ISSUE-1706, AMB-ISSUE-1709
- Related file-review findings: 7 inspected rows; statuses {'Green': 4, 'Yellow': 3}

## SCG006-F03 - Capture save

- Status: `Yellow`
- User intent: Save user input locally without making Capture a root tab.
- Entry surface: Global Capture composer overlay
- Control / trigger: Capture action, quick capture, typed input submit
- Interaction owner: Stage overlay, Composer/Capture, CaptureService
- Command: StageStore.presentCommandSheet/presentTypedCaptureComposer -> CaptureViewModel.createQuickCapture -> CaptureService.createCapture
- Validation: CaptureViewModel blocks empty text; AmbitionsCommandValidator validates quickCapture text; route preview requires user review before placement.
- Runtime mutation: Capture record created/updated with route/status/kind/priority/privacy localOnly fields.
- Persistence / proof: SwiftDataCaptureRepository through AppContainerFactory; EventLedger capture event when available.
- Projection: Capture list reloads; actionMessage receipt visible; overlay remains global.
- Visible UI mutation: Composer clears draft, presents proposal/receipt, announces saved state.
- Motion event: Stage overlay proof artifact and Capture action receipt; no root Capture surface.
- Accessibility: UIAccessibility announcement from CaptureActionMessage; input alternatives are described in tests.
- Undo / fallback: Empty draft says Write one real thing first; save errors surface Save did not finish.
- Tests: CaptureViewModelTests; ShellCommandRouterTests; CaptureRuntimeReceiptTests.
- Proof artifacts: Source/tests inspected; no current device composer proof generated.
- Missing links: SCG-004 composition/mutation findings and known Capture full-screen/keyboard/receipt proof gaps remain.
- Root causes: RC-SCG006-002, RC-SCG006-001, RC-SCG006-008, RC-SCG006-010
- Related automated-audit findings: SCG-004-004, SCG-004-005, SCG-004-006, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0003, AMB-ISSUE-0008, AMB-ISSUE-0012, AMB-ISSUE-1101, AMB-ISSUE-1102, AMB-ISSUE-1103, AMB-ISSUE-1104, AMB-ISSUE-1105, AMB-ISSUE-1106, AMB-ISSUE-1107
- Related file-review findings: 7 inspected rows; statuses {'Green': 5, 'Yellow': 2}

## SCG006-F04 - Capture expand with keyboard

- Status: `Yellow`
- User intent: Expand Capture into focused full-screen composing while preserving keyboard and accessibility fallback.
- Entry surface: Global Capture overlay
- Control / trigger: Focus text field / activated quick Capture composer
- Interaction owner: Stage overlay seam, CaptureObjectView, CaptureComposerSurface
- Command: AmbitionsStage.shellActivatedCaptureComposerSeam -> AppShellActivatedCaptureSeam/CaptureComposerSurface -> CaptureObjectView binding
- Validation: Overlay isActivatedCaptureComposer gate selects full-screen seam instead of sheet; input alternatives keep dictation honest.
- Runtime mutation: Draft text state updates and route preview recalculates; no persistence until save/submit.
- Persistence / proof: None until save; local source/receipt summary shown in preview.
- Projection: Root dock hidden by overlay policy; composer fills Stage seam.
- Visible UI mutation: Keyboard/focus expected to show composer as primary object; current device proof absent.
- Motion event: Reduced motion animation path present; Stage overlay transition opacity.
- Accessibility: CaptureAccessibility and tests cover keyboard dictation-only language; manual proof missing.
- Undo / fallback: Blank text blocks proposal and keeps safe fallback Decide later/route correction.
- Tests: CaptureViewModelTests FCP21 keyboard/dictation assertions; UI proof pending.
- Proof artifacts: Source/tests only.
- Missing links: Known AMB-ISSUE-0008/0012/1101 require full-screen keyboard/proposal/receipt screenshots.
- Root causes: RC-SCG006-002, RC-SCG006-001, RC-SCG006-010
- Related automated-audit findings: SCG-004-005, SCG-004-008, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0003, AMB-ISSUE-0008, AMB-ISSUE-0012, AMB-ISSUE-1101, AMB-ISSUE-1102, AMB-ISSUE-1103, AMB-ISSUE-1104, AMB-ISSUE-1105, AMB-ISSUE-1106, AMB-ISSUE-1107
- Related file-review findings: 7 inspected rows; statuses {'Green': 5, 'Yellow': 2}

## SCG006-F05 - Create goal

- Status: `Yellow`
- User intent: Create a local Goal from Goals or Capture context.
- Entry surface: Goals surface or Capture-to-goal overlay
- Control / trigger: Goals create button / Capture grow into Goal
- Interaction owner: Stage create-goal overlay, Goals service, SwiftData goal unit of work
- Command: StageStore.presentCreateGoal -> AppShellOverlayView/CreateGoalScreen -> CreateGoalViewModel.submit -> GoalsService.createGoal
- Validation: Title required; preview clarifies missing/blocked states; capture handoff states require confirmation.
- Runtime mutation: Goal/draft/plan/steps saved; capture can attach to created goal after creation.
- Persistence / proof: SwiftData goal repositories and optional goalCreationUnitOfWork/capturePromotionUnitOfWork receipt.
- Projection: On success, AmbitionsStage handles created goal and selects Goals/open detail depending result kind.
- Visible UI mutation: Create Goal screen moves from preview/loading to created message; no runtime screenshot proof in SCG-006.
- Motion event: Creation routes through Stage overlay and continuity receipt, not Capture tab.
- Accessibility: Text fields/buttons have identifiers; manual dynamic type/VoiceOver proof pending.
- Undo / fallback: Submit disabled without title; failure message Goal setup paused; capture attach failure remains nonfatal.
- Tests: CreateGoalViewModelTests; GoalsShellIntegrationTests; TodayFreshGoalVisibilityTests.
- Proof artifacts: Source/tests inspected; no new proof generated.
- Missing links: Known Goals plus/no-crash and visual acceptance remain pending.
- Root causes: RC-SCG006-003, RC-SCG006-001, RC-SCG006-008, RC-SCG006-010
- Related automated-audit findings: SCG-004-004, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-1301, AMB-ISSUE-1302, AMB-ISSUE-1303, AMB-ISSUE-1304, AMB-ISSUE-1309
- Related file-review findings: 7 inspected rows; statuses {'Green': 4, 'Yellow': 3}

## SCG006-F06 - Goal thread feeds Today

- Status: `Yellow`
- User intent: A created or active Goal exposes a recommended Step/Start here candidate in Today.
- Entry surface: Today after Goal creation or refresh
- Control / trigger: Create goal completion / return to Today / Today activation
- Interaction owner: Goals service, Today service, TodayLens
- Command: GoalsService.createGoal -> repositories.goals -> RepositoryBackedTodayService.loadTodayExperience -> TodayExecutionProjector/TodayLens
- Validation: Today service loads snapshot and selector chooses next actionable Step; tests assert active mode and hero action.
- Runtime mutation: Today read model recomputes from persisted goals/steps; no direct mutation unless action performed.
- Persistence / proof: Goal and step persisted; proof comes from source records/event ledger where action occurs.
- Projection: Today root displays Start here / recommended Step and support commitments.
- Visible UI mutation: Hero updates with goal title/action after refresh in tests.
- Motion event: Motion behavior can route back to Today via StageMotionCoordinator.
- Accessibility: TodayStageScene maps Open step/Start now/Move it labels and accessibility summaries.
- Undo / fallback: If no step, Today shows calm no-step state; blocked/waiting visible where present.
- Tests: TodayFreshGoalVisibilityTests created goal appears in Today targets and focus.
- Proof artifacts: In-memory source test proof only; no device proof generated.
- Missing links: Device/runtime proof for Today feed and no-step valid state remains pending in known issues.
- Root causes: RC-SCG006-003, RC-SCG006-004, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-006, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003, AMB-ISSUE-1004, AMB-ISSUE-1005, AMB-ISSUE-1006, AMB-ISSUE-1007, AMB-ISSUE-1301, AMB-ISSUE-1302, AMB-ISSUE-1303, AMB-ISSUE-1304, AMB-ISSUE-1309
- Related file-review findings: 13 inspected rows; statuses {'Yellow': 6, 'Green': 7}

## SCG006-F07 - Start recommended step

- Status: `Yellow`
- User intent: Begin work from the recommended Step that fits now.
- Entry surface: Today Start here
- Control / trigger: Start now / Open step primary action
- Interaction owner: TodaySurface, TodayViewModel, TodayCommandActionHandler
- Command: TodaySurface.handleAction -> TodayViewModel.handle -> TodayService.performAction -> TodayCommandHandler/TodayCommandActionHandler
- Validation: AmbitionsCommandValidator requires goalID and stepID for startStepSession/complete/delay/split.
- Runtime mutation: For actionable command paths, feedback/evidence/capture deltas are checked and command execution can be persisted.
- Persistence / proof: EventLedger entries emitted for new feedback/evidence/captures; commandExecutionRecords optional.
- Projection: Today refresh reloads experience after action and transient message appears.
- Visible UI mutation: Start here token or detail sheet changes; source/device proof pending.
- Motion event: StageEffect/StageMotion can announce visible mutation; haptics metadata recorded in command result.
- Accessibility: TodayStageScene labels Start now; accessibility summary derives from receipt item.
- Undo / fallback: Missing targets block safely; action not available message when persisted step missing.
- Tests: TodayFreshGoalVisibilityTests; TodayCommandHandlerTests; command execution tests.
- Proof artifacts: Source/test trace only.
- Missing links: Known Today before/action/after proof and action gating still pending.
- Root causes: RC-SCG006-004, RC-SCG006-003, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-006, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003, AMB-ISSUE-1004, AMB-ISSUE-1005, AMB-ISSUE-1006, AMB-ISSUE-1007
- Related file-review findings: 7 inspected rows; statuses {'Yellow': 3, 'Green': 4}

## SCG006-F08 - Close step

- Status: `Yellow`
- User intent: Record that a Step still counts / completed / closure outcome with proof.
- Entry surface: Today closure sheet
- Control / trigger: Still counts / closure outcome confirmation
- Interaction owner: TodaySurface closure sheet, TodayViewModel, ClosureEngine/projection mutation
- Command: TodayActionClosureSheet -> TodayViewModel.confirmActionClosure -> TodayService.recordActionClosure -> applies TodayClosureStageMutation
- Validation: Closure requires a selected closure state; command validation and closure outcome policy distinguish undo availability.
- Runtime mutation: Feedback/evidence/closure state mutates selected Step and Today experience applies closure mutation.
- Persistence / proof: ProgressEvidence/EventLedger/ClosureStageMutation are intended proof path; exact current end-to-end proof pending.
- Projection: Today refresh and closure mutation update visible state/transient receipt.
- Visible UI mutation: Closure sheet dismisses; user sees success/warning message and proof state if present.
- Motion event: ClosureStageMutation includes motion event and undo posture where available.
- Accessibility: Closure overlay mirrors accessibility outcome, undo, proof, and recovery in projection.
- Undo / fallback: Failure shows Closure could not be saved; action not available if target missing.
- Tests: ClosureRecoveryPrimitiveFamilyTests; Today flow tests; source-only SCG trace.
- Proof artifacts: No current closure before/action/after artifact generated.
- Missing links: Known AMB-ISSUE-0004 and proof rows require before/action/after proof/undo artifact.
- Root causes: RC-SCG006-004, RC-SCG006-007, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003, AMB-ISSUE-1004, AMB-ISSUE-1005, AMB-ISSUE-1006, AMB-ISSUE-1007, AMB-ISSUE-0014, AMB-ISSUE-0807, AMB-ISSUE-1801, AMB-ISSUE-1802
- Related file-review findings: 12 inspected rows; statuses {'Yellow': 3, 'Green': 9}

## SCG006-F09 - Move step

- Status: `Yellow`
- User intent: Move/defer/split a Step without shame and preserve recommendation continuity.
- Entry surface: Today or Time
- Control / trigger: Move it / defer / reschedule / Time placement correction
- Interaction owner: Today feedback action, Time mutation coordinator
- Command: TodayService.performFeedbackAction defer/reschedule or TimeFieldMutationCoordinator.perform place/correct
- Validation: Today requires goalID/stepID; Time placeStep requires real placementCandidate/stepID and rejects missing real Step.
- Runtime mutation: Step timing/summary can shift; Time buckets can change; Today recompute generated for Time mutation.
- Persistence / proof: Feedback events and event ledger entries for Today; RuntimeMutation proof for Time.
- Projection: Today refreshes; Time state updates with visibleTimeMutation; Today recompute fields generated.
- Visible UI mutation: Move/pressure softened/transient messages or Time mutation banner.
- Motion event: Stage mutation motion event generated by RuntimeMutation; reduced motion policy exists.
- Accessibility: Accessibility announcement for Time mutation; Today labels Move it.
- Undo / fallback: Missing real step returns warning/missingEligibleStep; scheduling remains deferred if unsupported.
- Tests: TimeTodayCouplingTests; TodayFreshGoalVisibilityTests; TimeFieldMutationCoordinatorTests.
- Proof artifacts: Source/test trace only.
- Missing links: Known Today/Time runtime proof and fake placement proof gaps remain pending.
- Root causes: RC-SCG006-004, RC-SCG006-005, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-007, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0004, AMB-ISSUE-0005, AMB-ISSUE-1001, AMB-ISSUE-1002, AMB-ISSUE-1003, AMB-ISSUE-1004, AMB-ISSUE-1005, AMB-ISSUE-1006, AMB-ISSUE-1007, AMB-ISSUE-0009, AMB-ISSUE-0501, AMB-ISSUE-0502, AMB-ISSUE-0503, AMB-ISSUE-0506, AMB-ISSUE-0507, AMB-ISSUE-0913, AMB-ISSUE-1401, AMB-ISSUE-1402, AMB-ISSUE-1403, AMB-ISSUE-1404
- Related file-review findings: 14 inspected rows; statuses {'Yellow': 6, 'Green': 8}

## SCG006-F10 - Protect window

- Status: `Yellow`
- User intent: Protect a time window and ensure Today avoids it.
- Entry surface: Time or Today protection flow
- Control / trigger: Protect window / Protect this block
- Interaction owner: TimeSurface, TimeFieldMutationCoordinator, ScheduleInstallKernel, TodayLens
- Command: TimeObjectView onMutationAction -> TimeViewModel.performLifeShapeMutation -> TimeMutation.protectWindow -> TodayLens.recomputeAfterTimeMutation
- Validation: Command validation requires timeID; ScheduleInstallKernel requires selected window, decision receipt, source/receipt/inspection route, protected time proof for protected windows.
- Runtime mutation: LifeShapeBucket changes to protected, recommended step removed from affected window.
- Persistence / proof: RuntimeMutation has proof/receipt/undo surface; ScheduleInstallReceipt requires proof routes.
- Projection: Time field updates; Today recompute avoids protected window in tests.
- Visible UI mutation: Protected bucket/banner visible in Time object; device proof pending.
- Motion event: RuntimeMutation motion event and Time accessibility announcement.
- Accessibility: Protected accessibility summary generated; permission denied fallback still manual planning.
- Undo / fallback: Missing selected window/proof produces kernel issues; missing target rejects command.
- Tests: TimeTodayCouplingTests; ScheduleInstallKernelTests.
- Proof artifacts: Source/test trace only.
- Missing links: Known Time protected-window and device proof rows pending.
- Root causes: RC-SCG006-005, RC-SCG006-007, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-007, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0009, AMB-ISSUE-0501, AMB-ISSUE-0502, AMB-ISSUE-0503, AMB-ISSUE-0506, AMB-ISSUE-0507, AMB-ISSUE-0913, AMB-ISSUE-1401, AMB-ISSUE-1402, AMB-ISSUE-1403, AMB-ISSUE-1404
- Related file-review findings: 13 inspected rows; statuses {'Yellow': 4, 'Green': 9}

## SCG006-F11 - Time correction recomputes Today

- Status: `Yellow`
- User intent: Correct a Time window and recompute Today recommendations.
- Entry surface: Time LifeShape Field
- Control / trigger: Needs more time / not usable / keep clear / make today lighter / add buffer
- Interaction owner: Time mutation projection, TodayLens
- Command: TimeFieldMutationCoordinator.perform -> TimeMutation.make -> TodayLens.recomputeAfterTimeMutation
- Validation: Command validation requires correctionKind in accepted set and timeID.
- Runtime mutation: LifeShapeProjection afterProjection changes buckets; TodayTimeCouplingRecompute records before/after Start here and affected IDs.
- Persistence / proof: RuntimeMutation contains timeMutation and proof labels; undo available for visible Time mutation.
- Projection: Time state applies updated LifeSuite; Today recompute metadata exists in mutation.
- Visible UI mutation: Time mutation banner and accessibility announcement.
- Motion event: Stage mutation motion event names visible change.
- Accessibility: Accessibility announcement message contains change label; manual proof absent.
- Undo / fallback: Unsupported correction kind/missing time target/missing bucket rejected.
- Tests: TimeTodayCouplingTests cover needsMoreTime, notUsable, keepClear, makeTodayLighter, addBuffer.
- Proof artifacts: Focused source/test evidence only.
- Missing links: Known Time device screenshot and injected clock/audit Yellow gaps remain.
- Root causes: RC-SCG006-005, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-007, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0009, AMB-ISSUE-0501, AMB-ISSUE-0502, AMB-ISSUE-0503, AMB-ISSUE-0506, AMB-ISSUE-0507, AMB-ISSUE-0913, AMB-ISSUE-1401, AMB-ISSUE-1402, AMB-ISSUE-1403, AMB-ISSUE-1404
- Related file-review findings: 7 inspected rows; statuses {'Yellow': 3, 'Green': 4}

## SCG006-F12 - Search / Memory Lens

- Status: `Yellow`
- User intent: Find local goals, steps, captures, proof, settings, and act/inspect without cloud search.
- Entry surface: Search / Memory Lens overlay
- Control / trigger: Search utility action / Memory Lens query / result tap
- Interaction owner: Stage overlay, DefaultMemoryLensService, ShellCommandRouter
- Command: StageStore.presentMemoryLens -> QuietCommandMemoryLensOverlay -> DefaultMemoryLensService.search -> ShellCommandRouter.route(searchResult)
- Validation: Search reads local repositories and ranks by seed intent/origin; allowsMemoryClaim is false.
- Runtime mutation: No mutation on search; result action routes to Goals/Time/You/Capture overlay.
- Persistence / proof: Source evidence is local repository records; continuity receipt can record search handoff.
- Projection: Search overlay fills Stage; result route mutates selected surface/overlay/path.
- Visible UI mutation: Search results list changes by query and selected route opens target; device proof pending.
- Motion event: Stage overlay transition; Search opened continuity receipt.
- Accessibility: Memory Lens results include source confidence/trust decay metadata; overlay accessibility not device-proven.
- Undo / fallback: No result can fall back to Capture-from-query or no-op safe state; cloud path absent in source.
- Tests: MemoryLensServiceTests; ShellCommandRouterTests; CommandSearchObviousnessGauntletTests.
- Proof artifacts: Source/test trace only.
- Missing links: Known Search runtime/device proof pending; SCG-004 fixture-only search not repo finding.
- Root causes: RC-SCG006-006, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0701, AMB-ISSUE-1601, AMB-ISSUE-1602, AMB-ISSUE-1603, AMB-ISSUE-1604, AMB-ISSUE-1605
- Related file-review findings: 5 inspected rows; statuses {'Green': 4, 'Yellow': 1}

## SCG006-F13 - Inspection / Why this?

- Status: `Yellow`
- User intent: Explain why a Step/result/recommendation appears and expose source/proof/receipt/privacy.
- Entry surface: Today, Search, You trust detail
- Control / trigger: Why this? / Inspect / proof or receipt action
- Interaction owner: Trust, Today service, Memory Lens, ProofLedger
- Command: Today askWhyThisMatters action -> TodayService.performAction -> explainability projector; Trust InspectionSurface for proof/source/privacy/history/receipt
- Validation: AskWhy validates explanationID or destination; trust inspection state is built by RuntimeExplanationPolicy.
- Runtime mutation: Usually no mutation; may record feedback that user asked why.
- Persistence / proof: ProofLedger carries eventLedgerEntryIDs and recommendationExplanationIDs; InspectionSurface names local boundary.
- Projection: Inline message, trust detail, or Search inspect affordance becomes visible.
- Visible UI mutation: Explanation/inspection opens detail or overlay; no device route proof in SCG-006.
- Motion event: StageMotionCoordinator can route proof/receipt/thread actions to Memory Lens overlay.
- Accessibility: InspectionSurface has accessibility label/value/hint; manual proof pending.
- Undo / fallback: Missing explanation target blocks; trust claim boundary says not release proof.
- Tests: TodayFreshGoalVisibilityTests askWhyThisMatters; MemoryLensServiceTests proof/whyNow; trust tests.
- Proof artifacts: Source/test trace only.
- Missing links: Proof/accessibility/inspection known issues and SCG-004 mutation proof findings remain.
- Root causes: RC-SCG006-004, RC-SCG006-006, RC-SCG006-007, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-006, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0014, AMB-ISSUE-0807, AMB-ISSUE-1801, AMB-ISSUE-1802, AMB-ISSUE-0701, AMB-ISSUE-1601, AMB-ISSUE-1602, AMB-ISSUE-1603, AMB-ISSUE-1604, AMB-ISSUE-1605
- Related file-review findings: 15 inspected rows; statuses {'Yellow': 2, 'Green': 13}

## SCG006-F14 - Undo

- Status: `Yellow`
- User intent: Reverse supported local mutations without pretending every action is reversible.
- Entry surface: Time mutation banner / receipt detail / trust route
- Control / trigger: Undo button where available
- Interaction owner: Projection/Mutations, Trust/Receipt, ClosureEngine
- Command: TimeObjectView onUndoMutation -> TimeViewModel.undoLastLifeShapeMutation -> TimeFieldMutationCoordinator.undo -> RuntimeMutation.undoVisibleMutation
- Validation: Undo only when last mutation exists and stage mutation undoAvailability is available.
- Runtime mutation: Time state restored to previousTimeState; undo visible mutation generated.
- Persistence / proof: Undo proof artifact and receipt ID generated by RuntimeMutation.undoVisibleMutation.
- Projection: Time field restores previous state and shows Undo applied.
- Visible UI mutation: User-visible banner/announcement says Time and Today returned to prior shape.
- Motion event: Motion event stage.motion.time.mutation_undone.
- Accessibility: Accessibility announcement says Undo applied; manual proof pending.
- Undo / fallback: If no last mutation, no action; broad destructive memory deletion remains blocked until safe confirmation/undo proof exists.
- Tests: TimeFieldMutationCoordinatorTests; You memory control tests; source trace.
- Proof artifacts: Source/test trace only.
- Missing links: Undo is not uniformly proven for closure/capture/destructive flows; SCG-004 RuntimeMutationProofAudit applies.
- Root causes: RC-SCG006-007, RC-SCG006-005, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-004, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0014, AMB-ISSUE-0807, AMB-ISSUE-1801, AMB-ISSUE-1802
- Related file-review findings: 11 inspected rows; statuses {'Green': 8, 'Yellow': 3}

## SCG006-F15 - Offline / no account

- Status: `Yellow`
- User intent: Use core app locally without account or network dependency.
- Entry surface: Launch and all core surfaces
- Control / trigger: No account / offline runtime condition
- Interaction owner: AppContainerFactory, SwiftData repositories, PrivateLifeRuntime
- Command: AppContainerFactory.live persistent store -> SwiftData repositories -> local runtime services; no account gate observed in launch path
- Validation: No account gate in inspected launch/container path; localOnly defaults present in commands/proof/captures.
- Runtime mutation: Local repositories mutate goals/captures/evidence/feedback; runtime boundary defaults localOnly.
- Persistence / proof: SwiftData model container/repositories; EventLedger and ProofLedger localOnly fields.
- Projection: Core surfaces load from local services where data exists.
- Visible UI mutation: Offline/no-account visible proof not generated; no network-disabled run.
- Motion event: No Motion dependency on network.
- Accessibility: Accessibility unaffected by account absence in source; manual proof missing.
- Undo / fallback: Unavailable repositories fail explicitly; Release Truth forbids offline validation claim without evidence.
- Tests: LocalOnlyProofHarnessTests; privacy-boundary tests; not run in SCG-006.
- Proof artifacts: Source posture only; no offline runtime proof.
- Missing links: Release Truth says offline with no account not validated; SCG-004 privacy-local findings remain.
- Root causes: RC-SCG006-009, RC-SCG006-001, RC-SCG006-008
- Related automated-audit findings: SCG-004-010, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0014
- Related file-review findings: 6 inspected rows; statuses {'Green': 5, 'Yellow': 1}

## SCG006-F16 - Permission denied fallback

- Status: `Yellow`
- User intent: Keep core value when Calendar/Reminders/Notifications/Speech permissions are denied or unavailable.
- Entry surface: Time / You / notification or reminder action
- Control / trigger: Denied permission state / user-initiated request attempt
- Interaction owner: Core/Permissions, Time projection, Today reminder action
- Command: CalendarPermission.lifeShapeFallback -> Time projection fallback; Today createReminder requests authorization and returns warning when unavailable
- Validation: PermissionRequestDecision only requests from contextual user action; write requires confirmed block.
- Runtime mutation: No private mutation when denied; fallback keeps local manual planning/reminders.
- Persistence / proof: Permission state and side-effect ledgers record boundaries where wired.
- Projection: Time shows calendar unavailable/manual planning; Today reminder warning appears.
- Visible UI mutation: Denied state changes visible fallback copy/status; current device proof absent.
- Motion event: No special motion required; fallback should avoid surprise system prompts.
- Accessibility: PermissionState carries fallbackSummary/inspectionSummary; manual accessibility proof missing.
- Undo / fallback: Denied/restricted/unavailable block system access and preserve local fallback.
- Tests: CorePermissionsCanonicalOwnershipTests; CalendarReminderActionFlowTests; Time denied scenarios.
- Proof artifacts: Source/test trace only.
- Missing links: No current permission-denied runtime proof; known accessibility/manual proof gaps remain.
- Root causes: RC-SCG006-005, RC-SCG006-009, RC-SCG006-001, RC-SCG006-008, RC-SCG006-010
- Related automated-audit findings: SCG-004-010, SCG-004-011, SCG-004-013
- Related QA/known-issues entries: AMB-ISSUE-0014, AMB-ISSUE-0807, AMB-ISSUE-1801, AMB-ISSUE-1802
- Related file-review findings: 13 inspected rows; statuses {'Green': 9, 'Yellow': 4}

## Non-Claims

- senior-readiness
- production repair
- implementation issue creation
- build success
- runtime readiness
- visual readiness
- accessibility readiness
- privacy approval
- offline validation
- account readiness
- performance readiness
- TestFlight readiness
- App Store readiness
- release readiness
