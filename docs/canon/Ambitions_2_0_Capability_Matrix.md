# Ambitions 2.0 Capability Matrix

Batch 61 verified repo truth after Batch 60. Batch 65 updates this matrix only where the Memory / Event Ledger foundation changed current repo truth.

Status values are restricted to: Verified complete, Partially implemented, Missing, Stale / legacy, Unknown until deeper implementation batch, Deferred by Ambitions 2.0 scope, Blocked by missing foundation, Needs manual platform verification.

## Executive Summary

### What is definitely implemented

- The native iOS project structure exists and is wired through XcodeGen: `project.yml`, `Native/Ambitions/`, `Native/AmbitionsTests/`, `Native/AmbitionsUITests/`, `Native/AmbitionsWidgetExtension/`, `Native/AmbitionsShareExtension/`, `Sources/`, and `AppUI/Sources/`.
- Batch 60 through Batch 65 are recorded as complete for planning in `docs/codex/BATCH_REGISTRY.md`.
- The Ambitions 2.0 canon package is present: master plan, product architecture, systems architecture, visual system, roadmap, batch plan, accessibility nutrition, and decision log.
- Capture persistence is implemented for the current app model through `DefaultCaptureService`, SwiftData repositories, and capture/persistence tests.

### What appears partial

- Today, Goals, Plan, Reviews, recommendation explanation, memory, command routing, external snapshots, EventKit, portable export/import, App Intents, widgets, Live Activities, and path intelligence all have real code, but they do not yet match the full Ambitions 2.0 architecture.
- Rich panel/design-system readiness exists through Batch 63 shared primitives, semantic states, panel tokens, and tests, but later surface batches still need to consume the system.
- Accessibility support is present across primitives and screens, and Batch 64 added an internal Accessibility Nutrition checklist model; user-facing Accessibility Nutrition Facts are not implemented or manually verified.
- The Batch 65 local Memory / Event Ledger foundation now exists with a canonical domain model, taxonomy, repository boundary, SwiftData/in-memory persistence, and adapter helpers from current evidence, feedback, and teaching-signal fragments. Its taxonomy also includes future-safe hooks for priority/reality changes, commitment capture/routing, Context Lens changes/inferences, goal scope items, deliverables, deadlines, scheduling displacement, and priority-conflict recovery without implementing those behaviors.

### What appears missing

- The locked Ambitions 2.0 top-level shell now exists after Batch 62 implementation. Current top-level tabs are Today, Goals, Capture, Plan, and You.
- Apple-first sync is not implemented; the repo currently exposes a local-only sync capability.
- Full long-range Path Builder UI, Plan-owned calendar permission UX, and a unified Canonical Now State are not complete.

### What is unknown

- Whether current external surfaces behave correctly on-device requires manual platform verification.
- Migration risk for replacing the current shell, demoting Insights, absorbing Habits, adding sync, and consolidating memory/events remains unknown until the owning implementation batches.
- The exact final conflict policy for Apple-first sync is unknown until Batch 78.

### What should not be touched until later

- Do not implement shell IA before Batch 62.
- Do not redesign product surfaces as part of Batch 64 accessibility nutrition work.
- Do not move calendar permission flows before Batch 70.
- Do not build sync/export-import product flows before Batch 78.
- Do not expand widgets, Live Activities, App Intents, or shared-container behavior before Batches 79-80.
- Do not build full Path Intelligence UI before Batches 81-82.

## Capability Matrix

| Capability | Current status | Evidence | Product implication | Risk | Related Ambitions 2.0 batch | Recommended next action |
| --- | --- | --- | --- | --- | --- | --- |
| Repo / project structure | Verified complete | Code/config: `project.yml` defines app, tests, widget, share extension, Swift packages; source folders under `Native/Ambitions/`, `Native/AmbitionsTests/`, `Native/AmbitionsUITests/`, `Sources/`, `AppUI/Sources/`. | Repo has the expected native foundation for Ambitions 2.0 work. | If wrong, future batches target the wrong source tree or project generator. | 61 | Keep XcodeGen as the project truth; no feature work in Batch 61. |
| Batch registry and post-Batch-60 status | Verified complete | Registry/docs: `docs/codex/BATCH_REGISTRY.md` records Batch 60 through Batch 65 complete for planning. | Batch 66 remains queued until explicitly started. | If wrong, work could skip a required hardening or canon step. | 61, 62, 63, 64, 65 | Leave registry history intact; only start Batch 66 after Batch 65 closeout. |
| Current tab shell | Verified complete for Batch 62 shell IA | Code/tests: `Native/Ambitions/App/AppTab.swift` `AppTab.allCases` returns Today, Goals, Capture, Plan, You; `AmbitionsRootView` builds those tabs; `AppShellNavigationTests` and focused `AmbitionsUITests` validate the shell. | Locked Ambitions 2.0 IA is now the active app shell, while deeper 2.0 surfaces remain deferred. | If overclaimed, later batches may skip Capture 2.0, You 2.0, Reviews, or contextual insights work. | 62 | Preserve the shell; defer surface redesign and workflow expansion to owning batches. |
| Today surface | Partially implemented | Code/tests: `TodayScreen`, `TodayViewModel`, `TodayFeatureService.makeExperience`, `nextHeroItem`, `TodayFreshGoalVisibilityTests`, `TodayShellIntegrationTests`, `TodayViewModelTests`. | Today exists and has recommendation/recovery behavior, but it is not yet the final 2.0 rich-panel execution surface. | If overclaimed, Batch 73 may skip needed IA and explanation work. | 73 | Preserve current behavior until Batch 73; audit shell placement in Batch 62 only. |
| Goals surface | Partially implemented | Code/tests: `GoalsScreen`, `GoalDetailScreen`, `GoalsFeatureService.loadDetail`, `GoalDetailPresentation`, `GoalExplainabilityProjectionTests`, `GoalDetailStrategicPresentationTests`. | Goals and detail surfaces exist with explainability and planning logic, but not final 2.0 goal-detail composition. | If overclaimed, confidence/believability and long-range path work may be missed. | 74 | Keep current Goals surface; defer redesign/detail expansion to Batch 74. |
| Capture surface | Partially implemented | Code/tests: `CapturesScreen`, `CapturesViewModel`, `DefaultCaptureService`, `CaptureServiceTests`; shell evidence: `AppTab.captures` is now the singular top-level Capture tab. | Capture IA ownership exists, but the final Capture 2.0 workflow is still missing. | If overclaimed, Batch 69 may skip inbox, triage, seed, waiting, and archive work. | 62, 69 | Keep Batch 62 shell placement stable; Batch 69 should implement Capture 2.0 behavior. |
| Plan surface | Partially implemented | Code/tests: `PlanScreen`, `PlanFeatureService`, `PlanRealityHeroState`, `PlanBelievabilityState`, `WeeklyReviewDashboard`, `PlanFeatureServiceTests`. | Plan exists and owns support routes, but not full 2.0 calendar-aware planning. | If overclaimed, calendar and believability foundation could be skipped. | 75 | Keep Plan stable until calendar/reality model and shell batches land. |
| You/Profile surface | Partially implemented | Code/tests: `ProfileScreen`, `ProfileFeatureService`, `AppTab.profile`; shell label is now You while internal Profile behavior remains preserved. | You is now the shell destination, but final You 2.0 reviews/memory/trust content is still missing. | If treated as final, Reviews and Accessibility Nutrition placement may drift. | 62, 76 | Keep top-level You label/route; Batch 76 should build You content. |
| Insights surface | Demoted from top-level shell | Code/tests: `InsightsScreen`, `InsightsMonthlyReviewScreen`, `InsightsHistoryScreen`, `InsightsFeatureServiceTests`; shell evidence: `AppTab.insights` remains decodable but normalizes under You/Profile support routing. | Existing Insights logic is preserved for future reviews/contextual insight work without remaining a top-level tab. | If overclaimed, Batch 77 may skip contextual redistribution and review-system work. | 62, 77 | Keep Insights out of top-level navigation; redistribute insights in Batch 77. |
| Habits surface | Stale / legacy | Code/tests: `HabitsScreen`, `HabitsFeatureService`, `HabitsViewModel`, `HabitsFeatureServiceTests`; Plan route `PlanRouteTarget.habits`. Docs: Habits must be absorbed. | Habits is no longer top-level, but still exists as a standalone routed surface. | If expanded now, it deepens a legacy feature boundary. | 75, 77 | Keep as support route until Plan/Reviews absorption work. |
| Navigation / routing | Partially implemented | Code/tests: `AppNavigation`, `PlanRouteTarget`, `InsightsRouteTarget`, `AppExternalRouting`, `ShellCommandRouter`, `AppShellNavigationTests`, `ExternalRoutingTests`. | Routing supports the Batch 62 shell and compatibility routes, but later command/external routing hardening remains deferred. | If overclaimed, Batches 68/79 may skip deeper command and external surface work. | 62, 68, 79 | Keep shell routes stable; Batch 68/79 should harden command/external routing. |
| Drill-down/detail architecture | Partially implemented | Code/tests: `GoalDetailScreen`, `WeeklyReviewScreen`, `InsightsMonthlyReviewScreen`, `MemoryLensScreen`, `GoalDetailExplainabilityActionTests`. | Detail screens exist and can support denser 2.0 surfaces. | If wrong, future batches may assume unavailable detail seams. | 74, 75, 76, 77 | Reuse existing detail architecture, but update content only in owning batches. |
| Design system / theme system | Partially implemented | Code/tests: `Sources/Theme/AmbitionTheme.swift`, `Sources/Components/RichPanelPrimitives.swift`, `InformationPrimitives.swift`, `SurfacePrimitives.swift`, `ControlPrimitives.swift`, `AppearancePreferenceTests`, `RichPanelDesignSystemTests`. | Shared theme, panel tokens, semantic states, and primitives exist; later surface batches still need to consume them consistently. | If overclaimed, future surface work may assume screens were already redesigned. | 63 | Preserve shared primitives; transform product surfaces only in owning batches. |
| Rich panel readiness | Partially implemented | Code/tests: `Sources/Components/RichPanelPrimitives.swift`, `Sources/Theme/AmbitionTheme.swift`, `AppUI/Sources/WidgetFoundation.swift`, `RichPanelDesignSystemTests`; docs: 2.0 visual system and design-system spec Batch 63 notes. | Foundation exists for rich panels across app and widgets, but broad Today/Goals/Capture/Plan/You redesign remains deferred. | If wrong, later batches may duplicate primitives or overclaim surface completion. | 63 | Convert app surfaces to canon panels only in scheduled UI batches. |
| Dark mode support | Partially implemented | Code/tests: `AppearancePreference`, `preferredColorScheme`, `AmbitionTheme`, `AppearancePreferenceTests`; docs: warm charcoal/blue-black dark mode required. | The app supports appearance preference, but 2.0 dark visual warmth needs audit. | If overclaimed, dark mode may remain cold or inconsistent. | 63 | Batch 63 should verify color tokens and visual contrast in dark mode. |
| Light mode support | Partially implemented | Code/tests: `AppearancePreference`, `AmbitionTheme`, `AppearancePreferenceTests`; docs: light mode needs warm off-white priority. | Light mode exists but needs equal 2.0 design treatment. | If overclaimed, light mode may be treated as secondary. | 63 | Batch 63 should give light mode explicit token and surface review. |
| Accessibility support | Partially implemented | Code: `.accessibilityIdentifier` usage across feature screens; `ambitionPanelAccessibility` in `SurfacePrimitives`; semantic accessibility verification states in `RichPanelPrimitives`; tests include shell/feature accessibility identifiers and checklist model coverage. | Accessibility hooks and an internal checklist model exist, but full verified accessibility nutrition is not complete. | If overclaimed, public accessibility claims may be inaccurate. | 64, 85 | Use Batch 64 checklist for internal audits; Batch 85 should verify public summary. |
| Accessibility Nutrition docs/readiness | Partially implemented | Docs: `docs/canon/Ambitions_2_0_Accessibility_Nutrition.md`, `docs/canon/Ambitions_Accessibility_Nutrition_Labels_Audit.md`; code/tests: `Sources/Accessibility/AccessibilityNutrition.swift`, `Native/AmbitionsTests/App/AccessibilityNutritionChecklistTests.swift`; no final You-facing screen. | Internal canon, checklist, audit template, verification states, and code-backed model exist; user-facing facts are not shipped. | If wrong, Batch 85 could publish unverified claims. | 64, 85 | Keep user-facing summary deferred until Batch 85 evidence promotes claims from unverified. |
| Empty states | Partially implemented | Code: `AsyncViewState.empty`, `AsyncStateCard`, `EmptyStateCard`, feature screens using empty branches. | Empty states exist across current surfaces but need 2.0 copy/panel alignment. | If overclaimed, onboarding/returning-user states may remain uneven. | 84 | Batch 84 should audit all empty states after IA settles. |
| Error states | Partially implemented | Code: `AsyncViewState.failed`, `AsyncStateCard.error`, feature view models with failure states. | Error state primitives exist, but coverage quality varies by feature. | If wrong, release hardening may miss user-facing failures. | 84, 86 | Re-check after feature batches; keep Batch 61 docs-only. |
| Loading states | Partially implemented | Code: `AsyncViewState.loading`, `LoadingSkeletonCard`, `AsyncStateCard.loading`, feature loading branches. | Loading states exist for current surfaces. | If overclaimed, new panels may ship without loading behavior. | 84, 86 | Require loading proof in each surface batch. |
| Today recommendation / best next move logic | Partially implemented | Code/tests: `TodayFeatureService.nextHeroItem`, `makeExperience`, `TodayViewModelTests`, `TodayFreshGoalVisibilityTests`. | Best-next behavior exists but is not yet backed by final Now State/Command Pipeline. | If overclaimed, Batch 73 may miss foundation dependency. | 67, 68, 73 | Reconnect Today recommendations after Now State and Command Pipeline stabilize. |
| Goal planning / goal detail logic | Partially implemented | Code/tests: `GoalsFeatureService.makeDetail`, `GoalDetailPresentation`, `GoalPlanningLens`, `GoalDetailStrategicPresentationTests`. | Goal detail planning exists and can feed 2.0 goal detail. | If overclaimed, goal health/path needs may be hidden. | 71, 74 | Batch 71 should define health/confidence; Batch 74 should reshape detail UI. |
| Believability / goal health / confidence labels | Partially implemented | Code/tests: `GoalConfidenceState`, `PlanBelievabilityState`, `GoalExplainabilityState`, `GoalExplainabilityProjectionTests`, `PlanFeatureServiceTests`. | Confidence and believability concepts exist, but final 2.0 goal health model is incomplete. | If wrong, users may see misleading confidence labels. | 71 | Batch 71 should make labels and thresholds canonical. |
| Recovery logic | Partially implemented | Code/tests: `TodayRecoveryBloomState`, `TodayFeatureService.makeRecoveryBloom`, `GoalFeedbackEvent` recovery events, Today/goal tests. | Recovery behavior exists but is not full 2.0 execution resilience. | If overclaimed, stuck/later/waiting flows may remain fragmented. | 72, 73 | Batch 72 should consolidate recovery actions before Today redesign. |
| Smaller / later / stuck / waiting actions | Partially implemented | Code: `GoalFeedbackEvent.askedForSmallerVersion`, `askedWhyThisMatters`, Today actions `protectLater`, `askForSmallerStep`; Plan blockers/open captures. | Some resilience actions exist; full stuck/waiting command model is incomplete. | If wrong, Command Pipeline may not support all user escape hatches. | 68, 72 | Define commands in Batch 68 and UX behavior in Batch 72. |
| Capture persistence | Verified complete | Code/tests: `DefaultCaptureService`, `Capture`, `CaptureStatus`, `SwiftDataRepositories`, `CaptureServiceTests`, `PersistenceRepositoryTests`. | Current capture persistence is real and tested. | If wrong, Capture 2.0 could build on a faulty storage assumption. | 69 | Reuse existing persistence while updating Capture IA and triage. |
| Capture triage | Partially implemented | Code/tests: `CaptureTriageDestination`, `CaptureTriageMetadata`, `CapturesViewModel`, `CaptureServiceTests`. | Triage states/actions exist but are not final 2.0 Capture workflow. | If overclaimed, Seed Vault and Plan intake may be underbuilt. | 69 | Batch 69 should canonicalize inbox, triage, and command outcomes. |
| Seed Vault | Partially implemented | Code: `CaptureStatus.seed`, `saveAsSeed`, demo seed data, capture repository tests. | Seed concept exists, but a full Seed Vault surface/system is not complete. | If overclaimed, Capture 2.0 may lack trusted holding behavior. | 69 | Build only inside Capture 2.0 batch. |
| Waiting-on / blockers | Partially implemented | Code/tests: `PlanFeatureService` blocker/open-capture pressure, `GoalBlockersLens`, `PlanFeatureServiceTests`. | Blocker signals exist, but waiting-on is not a unified system. | If wrong, Plan may misrepresent real constraints. | 70, 72, 75 | Fold into Reality Model, resilience, and Plan batches. |
| Calendar write integration | Partially implemented | Code/tests: `EventKitIntegrationService.createCalendarEvent`, `EventKitIntegrationServiceTests`, `CalendarReminderActionFlowTests`; current calls from Today/Goal Detail. | Calendar write exists, but permission/action placement conflicts with 2.0 Plan-only permission direction. | If overclaimed, app could request calendar access in the wrong context. | 70 | Batch 70 should move permission UX under Plan and preserve local-first explanation. |
| Calendar read integration | Partially implemented | Code/tests: `EventKitIntegrationService.detectConflicts`, `CalendarConflictReport`, `EventKitIntegrationServiceTests`. | Conflict read support exists, but no final Plan-owned calendar-aware planning model. | If wrong, Plan may assume unavailable open-window intelligence. | 70 | Batch 70 should implement local-first read model and explicit user action gates. |
| Reminder integration | Partially implemented | Code/tests: `EventKitIntegrationService.createReminder`, `CalendarRemindersScope.reminders`, `CalendarReminderActionFlowTests`. | Reminder write support exists; its Ambitions 2.0 role is secondary to calendar/Plan. | If wrong, reminders may distract from Plan foundation. | 70 | Keep behavior stable; revisit only with calendar/reality model work. |
| EventKit permission handling | Stale / legacy | Code/tests: `CalendarRemindersAuthorizationState`, `requestAuthorization`, Today/Goal Detail action flows; docs lock calendar permission to Plan user action. | Authorization exists but current placement conflicts with canon. | If wrong, privacy UX may violate locked direction. | 70 | Do not alter in Batch 61; fix in Batch 70. |
| Local-first calendar-derived data handling | Unknown until deeper implementation batch | Code: EventKit conflict reports are transient; docs: `Ambitions_2_0_Systems_Architecture.md` and product architecture require local-first calendar-derived explanation. | Policy exists, but durable data boundaries need implementation audit. | If overclaimed, sync/privacy behavior may be unsafe. | 70, 78 | Batch 70 must define storage/derivation boundaries before broader use. |
| Apple-first sync | Missing | Code/tests: `LocalOnlySyncCapability` in `SyncCapabilityContracts.swift`; `SyncCapabilityTests`; `rg` found no CloudKit/iCloud implementation. | Current app is local-only from a sync standpoint. | If overclaimed, users may trust unavailable cross-device behavior. | 78 | Implement Apple-first sync only after conflict/export policy is ready. |
| Export/import | Partially implemented | Code/tests: `PortableSnapshotContracts`, `PortableSnapshotService`, `PortableSnapshotServiceTests`. | Trust fallback exists at service level, but 2.0 product flow and sync relationship need hardening. | If overclaimed, recovery/export UI may be assumed complete. | 78 | Batch 78 should pair export/import with sync and conflict policy. |
| Memory / Event Ledger | Partially implemented | Code/tests: `EventLedgerEntry`, `EventLedgerKind`, `EventLedgerRepository`, `SwiftDataEventLedgerRepository`, `InMemoryEventLedgerRepository`, `EventLedgerModelsTests`, `EventLedgerRepositoryTests`, plus existing `ProgressEvidence`, `GoalFeedbackEvent`, `GoalTeachingSignal`, repositories, and `MemoryLensService`. | Batch 65 adds the canonical local ledger foundation and adapters, including future-safe taxonomy coverage for priority/reality, commitment capture/routing, Context Lens, scope/deliverable/deadline, scheduling displacement, and priority-conflict recovery events; current feature flows are not broadly migrated to emit or read ledger events. | If overclaimed, future surfaces may assume every historical event is already recorded in the ledger. | 65, 66, 67, 68, 76, 78, 83 | Future batches should migrate writes through Command Pipeline/feature seams deliberately and decide when portable snapshot/sync export includes ledger rows. |
| Recommendation Explanation Model | Partially implemented | Code/tests: `GoalExplainabilityProjector`, `GoalExplainabilityState`, `GoalWhyThisState`, `GoalExplainabilityProjectionTests`. | Goal explanations exist; shared explanation model across surfaces is incomplete. | If overclaimed, Why This/Why Changed surfaces may become inconsistent. | 66 | Batch 66 should extract shared explanation contract. |
| Why This / Why Changed UI | Partially implemented | Code: Goal Detail why/explainability panels, Today `askWhyThisMatters`; no dedicated `WhyChanged` surface found. | Why This exists in places; Why Changed is not complete. | If wrong, users may lack transparent change explanations. | 66, 73, 74, 75 | Build shared sheet behavior after explanation model is defined. |
| Canonical Now State | Partially implemented | Code/tests: `ExternalSurfaceNowState`, `ExternalSurfaceSnapshotBuilder`, `ExternalSurfaceSnapshotTests`; no final internal Canonical Now State service. | External snapshot foundation exists, but app-wide Now State is incomplete. | If overclaimed, widgets/commands/Today may disagree. | 67 | Batch 67 should define single Now State contract. |
| Command Pipeline | Partially implemented | Code/tests: `ShellCommandModels`, `ShellCommandRouter`, `ExternalActionCommandService`, `ShellCommandRouterTests`, `ExternalActionCommandServiceTests`. | Command routing exists, but final validated pipeline/event emission is incomplete. | If wrong, external actions and Today actions may fork behavior. | 68 | Batch 68 should centralize command execution and logging. |
| Search | Partially implemented | Code/tests: `MemoryLensService.search`, `MemoryLensScreen`, `MemoryLensServiceTests`. | Search exists through Memory Lens, not as full app-wide Search. | If overclaimed, future UI may rely on unavailable global search affordances. | 76, 77, 83 | Keep Memory Lens as current search-like surface; expand only when scheduled. |
| App Intents | Needs manual platform verification | Code/tests: `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`, `AppIntentRoutingTests`, external routing tests. | App Intent code exists, but system presentation and shortcut behavior need device/simulator verification. | If overclaimed, Siri/Shortcuts entry points may fail outside tests. | 79 | Verify and harden in Batch 79. |
| Shared container | Partially implemented | Code/config: app group entitlements, `SharedExternalSnapshotStore.appGroupIdentifier`, `ExternalCreationContracts`, widget/share extension targets. | Shared container boundary exists for extensions. | If wrong, widgets/share extension may not exchange data reliably. | 79, 80 | Re-verify entitlements and app-group IO before external-surface expansion. |
| Widgets | Needs manual platform verification | Code/config: `AmbitionsWidgetExtension`, `NextStepWidget`, `WidgetSnapshotProvider`, `WidgetFamilies`; docs/registry Batch 60 completion note. | Widget code exists, but platform rendering/update behavior is not Batch 61-verified. | If overclaimed, production widgets may be blank or stale. | 80 | Manual platform verification and Now State dependency check in Batch 80. |
| Live Activities | Needs manual platform verification | Code/config: `NextStepLiveActivityWidget`, `NextStepLiveActivityService`, `NextStepActivityAttributes`, ActivityKit import. | Live Activity code exists, but runtime presentation and lifecycle need platform proof. | If overclaimed, ActivityKit behavior may fail in production. | 80 | Verify only after Now State and Command Pipeline are stable. |
| Path Intelligence foundation | Partially implemented | Code/tests: `GoalPathCompilerService`, `GoalDomainPackService`, `GoalResourceGraphService`, `GoalEnergyFitService`, related domain tests. | Substantial path/goal intelligence exists, but not full Ambitions 2.0 long-range system. | If overclaimed, long-range roadmap may ship on narrow assumptions. | 81 | Batch 81 should formalize full foundation against 2.0 requirements. |
| Long-range path UI | Partially implemented | Code: Goal Detail path/explainability panels; no full Path Builder/long-range UI found. | Some path presentation exists; full long-range path UI is not complete. | If wrong, Batch 82 may duplicate or miss current affordances. | 82 | Audit existing goal detail path UI before building Path Builder. |
| Reviews | Partially implemented | Code/tests: `WeeklyReviewScreen`, `WeeklyReviewDashboard`, `InsightsMonthlyReviewScreen`, `InsightsHistoryScreen`, review-related tests. | Reviews exist across Plan/Insights, not yet You-owned Reviews. | If overclaimed, Insights may remain incorrectly top-level. | 76, 77 | Move/reshape reviews after shell and You tab work. |
| Learning / anticipation | Partially implemented | Code/tests: `LearningAnticipationService`, `LearningAnticipationServiceTests`, teaching signal repositories. | Learning signals exist, but final anticipation behavior is future work. | If overclaimed, recommendations may seem smarter than they are. | 83 | Batch 83 should connect learning to Now State and explanations. |
| Self-reported energy or non-HealthKit personalization | Partially implemented | Code/tests: `GoalEnergyFitService`, `GoalEnergyLearningService`, energy-related tests; docs defer HealthKit. | Non-HealthKit personalization exists through app signals, but explicit self-report UX is incomplete. | If wrong, app may personalize without user clarity. | 71, 83 | Keep HealthKit out; refine app-local energy signals in scheduled batches. |
| Tests | Partially implemented | Tests: `Native/AmbitionsTests/` includes domain, feature, routing, EventKit, sync, widget snapshot tests; not run during Batch 61. | Strong unit coverage exists, but Batch 61 did not execute full test suite. | If overclaimed, stale tests or environment failures may be hidden. | 61, 86 | Run targeted tests in implementation batches; keep Batch 61 lightweight. |
| UI tests | Partially implemented | Tests/config: `Native/AmbitionsUITests/AmbitionsUITests.swift`, scheme includes UI tests; CI workflow only runs `AmbitionsTests`. | UI test target exists but is not part of normal CI proof. | If wrong, shell redesign regressions may go unnoticed. | 62, 86 | Add focused UI proof when shell work begins; evaluate CI inclusion later. |
| CI / GitHub Actions | Partially implemented | CI: `.github/workflows/ios-validate.yml` runs XcodeGen, package resolve, build, unit tests, unsigned archive/IPA; UI tests not run. | CI protects build/unit/release packaging, not full UI behavior. | If overclaimed, visual/navigation regressions may pass CI. | 86 | Keep CI expectations truthful; expand only during release hardening. |
| Release docs | Partially implemented | Docs: `docs/native-build-and-release.md`, `docs/codex/Launch_Operator_Runbook.md`, `Release_Candidate_Review_Checklist.md`. | Release process docs exist, but 2.0 release criteria depend on future batches. | If overclaimed, launch readiness may be asserted too early. | 86 | Reconcile release docs after 2.0 implementation batches. |
| App Store / launch docs | Partially implemented | Docs: `docs/canon/Ambitions_App_Store_Release_Compliance.md`, `docs/canon/Ambitions_Launch_Master_Checklist.md`, privacy manifest. | Store/launch docs exist as historical/launch support, not final 2.0 launch proof. | If wrong, compliance claims may go stale. | 86 | Re-audit before release candidate. |
| Migration risks | Unknown until deeper implementation batch | Evidence: current shell/routes/storage differ from locked 2.0 IA and future sync/ledger plans; no full 2.0 migration plan found. | IA, memory, sync, and calendar changes may require migrations. | If ignored, user data or route continuity may break. | 62, 65, 78, 86 | Each owning batch should document migration impact before edits. |
| Privacy / memory controls | Partially implemented | Code/docs: `PrivacyInfo.xcprivacy`, Profile/Trust Center surfaces, local-first docs, memory lens services, `EventLedgerPrivacyClassification`, ledger local-only defaults, and redaction/delete repository methods. | Privacy foundation exists and the ledger carries local-only/privacy metadata, but final memory controls and sync behavior are not shipped. | If overclaimed, future sync/memory UX may violate trust posture. | 65, 76, 78, 85 | Tie memory controls to You, sync, export/import, and Accessibility Nutrition work before user-facing claims. |
| Sync conflict policy | Partially implemented | Code/tests: `PortableSnapshotService.mergeWithConflictReport`, `PortableConflict`, `PortableSnapshotServiceTests`; no Apple sync conflict policy. | Conflict handling exists for portable import, not Apple-first sync. | If overclaimed, multi-device conflicts may be undefined. | 78 | Batch 78 should define Apple sync conflict policy and keep export/import fallback. |
| Canon readiness | Verified complete | Docs: all requested `docs/canon/Ambitions_2_0_*.md` files exist and are indexed by `docs/codex/CONTEXT_INDEX.md`. | Batch 62+ can use the new 2.0 canon stack. | If wrong, future batches may miss critical locked direction. | 61 | Keep new canon files in read order; do not remove historical docs. |
| Deferred Ambitions 2.0 scope | Deferred by Ambitions 2.0 scope | Docs: user-locked direction and `Ambitions_2_0_Decision_Log.md` defer HealthKit, food/calorie sync, household/shared life, non-phone hardware prototype. Code contains historical shared-life/device concepts. | Deferred areas should not drive 2.0 implementation decisions. | If ignored, Codex may revive out-of-scope work. | 61, future | Treat as explicit no-drift guardrails until the canon changes. |

## Source-of-Truth Conflicts

| Conflict | Evidence | Recommended resolution |
| --- | --- | --- |
| Locked 2.0 tabs are Today, Goals, Capture, Plan, You; Batch 62 has now implemented this shell while older preserved docs may still describe historical shells. | Docs: `Ambitions_2_0_Product_Architecture.md`; code/tests: `AppTab.allCases`, `AmbitionsRootView`, `AppShellNavigationTests`, focused `AmbitionsUITests`. | Keep the Batch 62 shell as active truth; do not use older historical shell docs to reintroduce Insights/Profile top-level tabs. |
| Insights is demoted from top-level shell, but preserved Insights screens and routes still exist for support/history paths. | Code: `InsightsScreen`, `InsightsMonthlyReviewScreen`, `InsightsHistoryScreen`, `AppTab.insights`, `InsightsRouteTarget`. | Preserve existing logic; redistribute review/explanation surfaces in Batches 76-77. |
| Habits must be absorbed, but a standalone Habits feature and Plan route still exist. | Code: `HabitsScreen`, `HabitsFeatureService`, `PlanRouteTarget.habits`. | Keep current route stable until Plan/Reviews absorption in Batches 75 and 77. |
| Calendar permission should be requested inside Plan after user action, but current calendar/reminder actions can originate from Today and Goal Detail. | Code/tests: `TodayFeatureService`, `GoalsFeatureService`, `CalendarReminderActionFlowTests`, `EventKitIntegrationService`. | Batch 70 should move permission UX to Plan-owned flows and preserve explicit local-first explanation. |
| Apple-first sync is in 2.0 scope, but current sync code is local-only. | Code/tests: `LocalOnlySyncCapability`, `SyncCapabilityTests`; docs: 2.0 roadmap Batch 78. | Treat sync as missing until Batch 78; keep export/import fallback truthful. |
| Widgets and Live Activities have code targets, but Batch 61 did not manually verify platform behavior. | Code/config: `AmbitionsWidgetExtension`, ActivityKit files, shared snapshot store. | Mark as needs manual platform verification; do not expand before Batch 80. |
| Dedicated device runtime and shared-life concepts exist historically, while 2.0 defers active non-phone hardware and household/shared life. | Code/docs: historical runtime/shared-life services; user-locked direction and decision log. | Treat these as architecture/history only unless future canon reactivates them. |
| Older product spec still documents the current shipping shell, while the new canon supersedes future direction. | Docs: `MASTER_PRODUCT_SPEC.md` current shipping truth; `Ambitions_2_0_*` files future canon. | Use shipping spec for current behavior and 2.0 canon for future batch direction; do not silently rewrite historical docs. |

## Active Batch Recommendation

Batch 62 should remain **Ambitions 2.0 Shell IA**.

Repo truth supports the planned sequence: the main blocker is the stale top-level shell. Capture, Plan, You/Profile, Insights, and Habits ownership should be corrected before deeper visual, calendar, review, sync, widget, or path-intelligence work.

## No-Drift Warnings

- Do not build or redesign top-level surfaces before Batch 62 defines the 2.0 shell.
- Do not turn Insights into a new destination; demote it through the scheduled IA/review batches.
- Do not absorb Habits opportunistically; Plan and Reviews need their owning batches.
- Do not expand calendar read/write before Batch 70 defines Plan-owned permission and local-first derived data.
- Do not build Apple-first sync before Batch 78 defines export/import and conflict policy.
- Do not expand App Intents/shared container/widgets/Live Activities before Batches 79-80 and after Now State/Command Pipeline proof.
- Do not build long-range Path Builder UI before Batches 81-82.
- Do not revive HealthKit, food/calorie sync, household/shared life, or non-phone hardware prototype work in Ambitions 2.0.

## Verification Log

### Commands run

- `pwd`
- `git remote -v`
- `git branch --show-current`
- `git status -sb`
- `git fetch origin --prune`
- `git log --oneline --decorate --graph --max-count=12 --all`
- `git pull --ff-only origin main`
- `find . -maxdepth 3 -type d`
- `rg --files`
- `sed -n ...` on required canon, registry, project, source, test, and workflow files
- `rg -n ...` for tabs, services, EventKit, sync, widgets, Live Activities, App Intents, tests, CI, accessibility, design primitives, and 2.0 canon references

### Files inspected

- `AGENTS.md`
- `MASTER_PRODUCT_SPEC.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/MASTER_CODEX_SYSTEM.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/Ambitions_2_0_Codex_Execution_Guide.md`
- `docs/canon/Ambitions_2_0_Master_Plan.md`
- `docs/canon/Ambitions_2_0_Product_Architecture.md`
- `docs/canon/Ambitions_2_0_Systems_Architecture.md`
- `docs/canon/Ambitions_2_0_Visual_System.md`
- `docs/canon/Ambitions_2_0_Roadmap.md`
- `docs/canon/Ambitions_2_0_Batch_Plan.md`
- `docs/canon/Ambitions_2_0_Accessibility_Nutrition.md`
- `docs/canon/Ambitions_2_0_Decision_Log.md`
- `docs/canon/Ambitions_OS_Master_Roadmap.md`
- `docs/canon/Ambitions_Surgical_Execution_Plan.md`
- `docs/canon/Ambitions_Codex_Batch_Plan.md`
- `docs/canon/design/README.md`
- `project.yml`
- `.github/workflows/ios-validate.yml`
- Representative files under `Native/Ambitions/App`, `Native/Ambitions/Features`, `Native/Ambitions/Domain`, `Native/Ambitions/Services`, `Native/Ambitions/Integrations`, `Native/Ambitions/Persistence`, `Native/AmbitionsWidgetExtension`, `Native/AmbitionsShareExtension`, `Sources/`, `AppUI/Sources/`, `Native/AmbitionsTests`, and `Native/AmbitionsUITests`.

### Tests run or intentionally skipped

- No Swift tests were run. Batch 61 is a documentation/audit batch, and the user requested lightweight validation only.
- Full iOS build was intentionally skipped because no Swift or project configuration files were changed.
- `xcodegen generate` was intentionally skipped because no XcodeGen/project configuration changed.
- Markdown lint availability was checked; no repo-documented markdown lint script/config was found, so `git diff --check` was used as the lightweight formatting guard.
