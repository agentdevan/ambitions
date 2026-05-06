import XCTest
@testable import Ambitions

final class ExternalSurfaceSnapshotTests: XCTestCase {
    func testSnapshotGenerationSelectsNextActionAndRedactsUserEnteredTitles() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(formatter.date(from: "2026-04-15T08:00:00Z"))
        let sensitiveStepTitle = "Private Therapy Session"
        let goal = makeGoal(
            goalID: "goal-sensitive",
            goalTitle: "Very Personal Goal",
            stepID: "step-sensitive",
            stepTitle: sensitiveStepTitle,
            dueAt: "2026-04-16T09:00:00Z"
        )
        let builder = ExternalSurfaceSnapshotBuilder()

        let snapshot = builder.makeSnapshot(goals: [goal], now: now)
        let json = try XCTUnwrap(String(data: PersistenceCoding.encode(snapshot), encoding: .utf8))
        let widget = ExternalWidgetProjection(snapshot: snapshot)
        let activity = try XCTUnwrap(NextStepActivityAttributes.ContentState(snapshot: snapshot, now: now))
        let externalDisplayText = (
            [
                widget.title,
                widget.detail,
                widget.lockDetail,
                widget.privacySummary,
                widget.accessibilityLabel,
                activity.title,
                activity.detail,
                activity.privacyLabel,
                activity.stateLabel
            ] + widget.variants.flatMap { [$0.title, $0.privacySummary] }
        ).joined(separator: " ")

        XCTAssertEqual(snapshot.schemaVersion, ExternalSurfaceSnapshot.schemaVersion)
        XCTAssertEqual(snapshot.nextAction?.goalID, "goal-sensitive")
        XCTAssertEqual(snapshot.nextAction?.stepID, "step-sensitive")
        XCTAssertEqual(snapshot.nextAction?.display.templateKey, "next_tiny_step")
        XCTAssertEqual(snapshot.nextAction?.display.urgency, .soon)
        XCTAssertEqual(snapshot.nowState?.bestNextStep?.goalID, "goal-sensitive")
        XCTAssertEqual(snapshot.nowState?.bestNextStep?.stepID, "step-sensitive")
        XCTAssertEqual(snapshot.nowState?.todayPosture, .active)
        XCTAssertEqual(snapshot.nowState?.pressureLevel, .steady)
        XCTAssertEqual(snapshot.nowState?.openCaptureUrgency, ExternalSurfaceCaptureUrgency.none)
        XCTAssertEqual(snapshot.nowState?.ritualCue?.kind, .morningSetup)
        XCTAssertEqual(snapshot.nowState?.ritualCue?.templateKey, "ritual_morning_setup")
        XCTAssertEqual(snapshot.nowState?.supportedCommands.map(\.kind), [.complete, .snooze, .openGoal, .openToday, .openCapturesInbox, .openMemoryLens])
        XCTAssertEqual(snapshot.ambientState?.today.kind, .today)
        XCTAssertEqual(snapshot.ambientState?.focus.kind, .focus)
        XCTAssertEqual(snapshot.ambientState?.goal.privacySummary, "Goal names stay private here")
        XCTAssertEqual(snapshot.ambientState?.plan.action.tab, "plan")
        XCTAssertEqual(snapshot.continuity.syncHealth.state, .localFirst)
        XCTAssertEqual(snapshot.continuity.lease.freshnessLabel, "Updated recently")
        XCTAssertEqual(snapshot.privacy.defaultVisibility, .detailsHidden)
        XCTAssertEqual(snapshot.privacy.sensitiveDetailLabel, "Details stay private until you open Ambitions.")
        XCTAssertFalse(json.contains(sensitiveStepTitle))
        XCTAssertFalse(json.contains("Very Personal Goal"))
        XCTAssertFalse(externalDisplayText.contains(sensitiveStepTitle))
        XCTAssertFalse(externalDisplayText.contains("Very Personal Goal"))
        XCTAssertFalse(externalDisplayText.contains("goal-sensitive"))
        XCTAssertFalse(externalDisplayText.contains("step-sensitive"))
    }

    func testSnapshotSerializationRoundTrips() throws {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-1",
                stepID: "step-1",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .normal,
                    timing: .deadline
                )
            ),
            nowState: ExternalSurfaceNowState(
                todayPosture: .active,
                pressureLevel: .steady,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-1", stepID: "step-1"),
                activeFocus: nil,
                openCaptureUrgency: .none,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                ritualCue: ExternalSurfaceRitualCue(
                    kind: .middayReset,
                    templateKey: "ritual_midday_reset",
                    progressState: .needsReset,
                    primaryReference: ExternalSurfaceActionReference(goalID: "goal-1", stepID: "step-1")
                ),
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .complete, requiresGoalID: true, requiresStepID: true),
                    ExternalSurfaceCommandDescriptor(kind: .snooze, requiresGoalID: true, requiresStepID: true),
                ]
            )
        )

        let data = try PersistenceCoding.encode(snapshot)
        let decoded = try PersistenceCoding.decode(ExternalSurfaceSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
    }

    func testActiveFocusSnapshotFieldRemainsLegacyCompatible() throws {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: nil,
            nowState: ExternalSurfaceNowState(
                todayPosture: .active,
                pressureLevel: .steady,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-best", stepID: "step-best"),
                activeFocus: ExternalSurfaceActionReference(goalID: "goal-focus", stepID: "step-focus"),
                openCaptureUrgency: .none,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                ritualCue: nil,
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ]
            )
        )

        let data = try PersistenceCoding.encode(snapshot)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        let decoded = try PersistenceCoding.decode(ExternalSurfaceSnapshot.self, from: data)

        XCTAssertTrue(json.contains("\"activeFocus\""))
        XCTAssertEqual(decoded.nowState?.activeFocus?.goalID, "goal-focus")
        XCTAssertEqual(decoded.nowState?.activeFocus?.stepID, "step-focus")
        XCTAssertEqual(decoded.nowState?.bestNextStep?.goalID, "goal-best")
    }

    func testSnapshotUsesSharedPlanningNextStepSelectorForNowState() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(formatter.date(from: "2026-04-15T12:00:00Z"))
        let soon = makeGoal(goalID: "goal-soon", goalTitle: "Soon", stepID: "step-soon", stepTitle: "Soon step", dueAt: "2026-04-16T09:00:00Z")
        let later = makeGoal(goalID: "goal-later", goalTitle: "Later", stepID: "step-later", stepTitle: "Later step", dueAt: "2026-05-01T09:00:00Z")

        let expected = PlanningNextStepSelector().bestSelection(goals: [later, soon], now: now)
        let snapshot = ExternalSurfaceSnapshotBuilder().makeSnapshot(goals: [later, soon], now: now)

        XCTAssertEqual(snapshot.nextAction?.goalID, expected?.goal.id)
        XCTAssertEqual(snapshot.nextAction?.stepID, expected?.step.id)
        XCTAssertEqual(snapshot.nowState?.bestNextStep?.goalID, expected?.goal.id)
        XCTAssertEqual(snapshot.nowState?.bestNextStep?.stepID, expected?.step.id)
    }

    func testOldSnapshotWithoutEvaluationFieldsStillDecodes() throws {
        let json = """
        {"schemaVersion":"external_surface_snapshot.v1","generatedAt":"2026-04-15T12:00:00Z","nextAction":null}
        """

        let decoded = try PersistenceCoding.decode(ExternalSurfaceSnapshot.self, from: Data(json.utf8))

        XCTAssertNil(decoded.nextAction)
        XCTAssertNil(decoded.nowState)
        XCTAssertNil(decoded.ambientState)
        XCTAssertEqual(decoded.continuity.syncHealth.state, .localFirst)
        XCTAssertEqual(decoded.privacy, .safeDefault)
    }

    func testD22SnapshotPrivacyPolicyRoundTripsAndKeepsStaleUnavailableLabels() throws {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: nil,
            continuity: ExternalSurfaceContinuityState(
                lease: ExternalSurfaceNowStateLease(
                    status: .stale,
                    generatedAt: "2026-04-15T11:00:00Z",
                    freshnessLabel: "This may be behind",
                    staleActionLabel: "Open Ambitions to refresh"
                ),
                syncHealth: ExternalSurfaceSyncHealth(
                    state: .stale,
                    label: "Local state may be behind",
                    detail: "Open Ambitions before acting from this surface."
                ),
                receipt: ExternalSurfaceContinuityReceipt(origin: .widget, label: "Opened from widget")
            )
        )

        let decoded = try PersistenceCoding.decode(
            ExternalSurfaceSnapshot.self,
            from: PersistenceCoding.encode(snapshot)
        )

        XCTAssertEqual(decoded.privacy.defaultVisibility, .detailsHidden)
        XCTAssertEqual(decoded.privacy.unavailableLabel, "Open Ambitions to confirm the latest local state.")
        XCTAssertEqual(decoded.privacy.staleLabel, "This may be behind. Open Ambitions to refresh.")
        XCTAssertEqual(decoded.continuity.lease.status, .stale)
        XCTAssertEqual(decoded.continuity.syncHealth.state, .stale)
        XCTAssertEqual(decoded.continuity.receipt?.origin, .widget)
    }

    func testLiveActivityContentStatePrefersNowStateAndFallsBackToNextAction() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))
        let nextAction = ExternalSurfaceNextAction(
            goalID: "goal-old",
            stepID: "step-old",
            display: ExternalSurfaceDisplayMetadata(
                templateKey: "next_tiny_step",
                goalMode: .project,
                stepState: .planned,
                urgency: .soon,
                timing: .deadline
            )
        )
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: nextAction,
            nowState: ExternalSurfaceNowState(
                todayPosture: .active,
                pressureLevel: .elevated,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-now", stepID: "step-now"),
                activeFocus: nil,
                openCaptureUrgency: .none,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                ritualCue: nil,
                supportedCommands: []
            )
        )

        let state = try XCTUnwrap(NextStepActivityAttributes.ContentState(snapshot: snapshot, now: now))
        let legacyState = try XCTUnwrap(
            NextStepActivityAttributes.ContentState(
                snapshot: ExternalSurfaceSnapshot(generatedAt: "2026-04-15T12:00:00Z", nextAction: nextAction),
                now: now
            )
        )

        XCTAssertEqual(state.goalID, "goal-now")
        XCTAssertEqual(state.stepID, "step-now")
        XCTAssertEqual(state.pressureLevel, .elevated)
        XCTAssertEqual(state.title, "Focus step ready")
        XCTAssertEqual(state.leaseLabel, "Updated recently")
        XCTAssertEqual(state.privacyLabel, "Details stay private until you open Ambitions.")
        XCTAssertEqual(state.stateLabel, "Current focus window")
        XCTAssertEqual(state.deepLinkURLString, "ambitions://goal/goal-now?origin=live_activity")
        XCTAssertEqual(state.endsAt, "2026-04-15T13:00:00Z")
        XCTAssertEqual(legacyState.goalID, "goal-old")
        XCTAssertEqual(legacyState.stepID, "step-old")
        XCTAssertEqual(legacyState.pressureLevel, .steady)
    }

    func testD24LiveActivityContentStateCarriesStalePrivacyAndBoundedWindow() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T11:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-private",
                stepID: "step-private",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .soon,
                    timing: .window
                )
            ),
            continuity: ExternalSurfaceContinuityState(
                lease: ExternalSurfaceNowStateLease(
                    status: .stale,
                    generatedAt: "2026-04-15T11:00:00Z",
                    freshnessLabel: "This may be behind",
                    staleActionLabel: "Open Ambitions to refresh"
                ),
                syncHealth: ExternalSurfaceSyncHealth(
                    state: .stale,
                    label: "Local state may be behind",
                    detail: "Open Ambitions before acting from this surface."
                ),
                receipt: ExternalSurfaceContinuityReceipt(origin: .liveActivity, label: "Opened from Live Activity")
            )
        )

        let state = try XCTUnwrap(NextStepActivityAttributes.ContentState(snapshot: snapshot, now: now))

        XCTAssertEqual(state.title, "Open Ambitions to refresh")
        XCTAssertEqual(state.detail, "Confirm the latest local state in Ambitions.")
        XCTAssertEqual(state.privacyLabel, "This may be behind. Open Ambitions to refresh.")
        XCTAssertEqual(state.stateLabel, "Open Ambitions to refresh")
        XCTAssertEqual(state.deepLinkURLString, "ambitions://goal/goal-private?origin=live_activity")
        XCTAssertEqual(state.endsAt, "2026-04-15T13:00:00Z")
        XCTAssertFalse(state.title.contains("Private Tax Debt Goal"))
        XCTAssertFalse(state.detail.contains("private numbers"))
    }

    func testPFC16LiveActivitySuppressesPrivateAmbientCopyWhenSnapshotIsStale() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T11:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "private-goal-id",
                stepID: "private-step-id",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .soon,
                    timing: .window
                )
            ),
            ambientState: ExternalSurfaceAmbientState(
                today: ExternalSurfaceVariantState(
                    kind: .today,
                    title: "Private medical task",
                    detail: "Call the clinic",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .elevated
                ),
                focus: ExternalSurfaceVariantState(
                    kind: .focus,
                    title: "Private focus window",
                    detail: "Discuss protected details",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                goal: ExternalSurfaceVariantState(
                    kind: .goal,
                    title: "Private goal",
                    detail: "Sensitive goal",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                plan: ExternalSurfaceVariantState(
                    kind: .plan,
                    title: "Private plan",
                    detail: "Sensitive plan",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Plan", surface: .tab, tab: "plan"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                )
            ),
            continuity: ExternalSurfaceContinuityState(
                lease: ExternalSurfaceNowStateLease(
                    status: .stale,
                    generatedAt: "2026-04-15T11:00:00Z",
                    freshnessLabel: "This may be behind",
                    staleActionLabel: "Open Ambitions to refresh"
                ),
                syncHealth: ExternalSurfaceSyncHealth(
                    state: .stale,
                    label: "Local state may be behind",
                    detail: "Open Ambitions before acting from this surface."
                ),
                receipt: ExternalSurfaceContinuityReceipt(origin: .liveActivity, label: "Opened from Live Activity")
            )
        )

        let state = try XCTUnwrap(NextStepActivityAttributes.ContentState(snapshot: snapshot, now: now))

        XCTAssertEqual(state.title, "Open Ambitions to refresh")
        XCTAssertEqual(state.detail, "Confirm the latest local state in Ambitions.")
        XCTAssertFalse(state.accessibilitySummary.contains("Private focus window"))
        XCTAssertFalse(state.accessibilitySummary.contains("private-goal-id"))
        XCTAssertFalse(state.accessibilitySummary.contains("private-step-id"))
    }

    func testD24LiveActivityDoesNotStartWithoutAConcreteStep() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))

        XCTAssertNil(NextStepActivityAttributes.ContentState(snapshot: nil, now: now))
        XCTAssertNil(
            NextStepActivityAttributes.ContentState(
                snapshot: ExternalSurfaceSnapshot(generatedAt: "2026-04-15T12:00:00Z", nextAction: nil),
                now: now
            )
        )
    }

    func testPFC16LiveActivityLifecycleDecisionEndsWithoutConcreteStep() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))

        XCTAssertEqual(NextStepLiveActivityLifecycleDecision.evaluate(snapshot: nil, now: now), .end)
        XCTAssertEqual(
            NextStepLiveActivityLifecycleDecision.evaluate(
                snapshot: ExternalSurfaceSnapshot(generatedAt: "2026-04-15T12:00:00Z", nextAction: nil),
                now: now
            ),
            .end
        )
    }

    func testSnapshotRitualCueIsPrivacySafeAndBackwardDecodable() throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(formatter.date(from: "2026-04-15T13:00:00Z"))
        let goal = makeGoal(
            goalID: "goal-private",
            goalTitle: "Private Tax Debt Goal",
            stepID: "step-private",
            stepTitle: "Call the accountant about private numbers",
            dueAt: "2026-04-15T14:00:00Z"
        )
        let snapshot = ExternalSurfaceSnapshotBuilder().makeSnapshot(goals: [goal], now: now)
        let json = try XCTUnwrap(String(data: PersistenceCoding.encode(snapshot), encoding: .utf8))

        XCTAssertEqual(snapshot.nowState?.ritualCue?.kind, .middayReset)
        XCTAssertEqual(snapshot.nowState?.ritualCue?.primaryReference?.goalID, "goal-private")
        XCTAssertFalse(json.contains("Private Tax Debt Goal"))
        XCTAssertFalse(json.contains("Call the accountant"))

        let oldJSON = """
        {"schemaVersion":"external_surface_snapshot.v1","generatedAt":"2026-04-15T12:00:00Z","nextAction":null,"nowState":{"todayPosture":"active","pressureLevel":"steady","bestNextStep":null,"activeFocus":null,"openCaptureUrgency":"none","blockerSummary":{"waitingCount":0,"blockedCount":0},"supportedCommands":[]}}
        """
        let decoded = try PersistenceCoding.decode(ExternalSurfaceSnapshot.self, from: Data(oldJSON.utf8))
        XCTAssertNil(decoded.nowState?.ritualCue)
    }

    func testSnapshotRefreshingDecoratorsRefreshWriterAfterTodayAndGoalsMutations() async throws {
        let writer = RecordingSnapshotWriter()
        let goalsBase = RecordingGoalsService()
        let todayBase = RecordingTodayService()
        let goalsService = SnapshotRefreshingGoalsService(base: goalsBase, snapshotWriter: writer)
        let todayService = SnapshotRefreshingTodayService(base: todayBase, snapshotWriter: writer)

        _ = try await goalsService.createGoal(CreateGoalRequest(title: "Ship export layer"), now: .now)
        _ = try await goalsService.performAction(
            GoalDetailActionRequest(
                target: GoalRouteTarget(goalID: "goal-1", draftID: "draft-1"),
                kind: .complete,
                stepID: nil
            ),
            now: .now
        )
        _ = try await goalsService.submitClarificationAnswer(
            GoalClarificationAnswerRequest(
                target: GoalRouteTarget(goalID: "goal-1", draftID: "draft-1"),
                questionID: "q1",
                field: .successDefinition,
                answer: "Clear scope and ship v1."
            ),
            now: .now
        )
        _ = try await todayService.performAction(
            TodayInlineAction(
                kind: .complete,
                title: "Done",
                systemImage: "checkmark",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            now: .now
        )

        let refreshCount = await writer.refreshCount
        XCTAssertEqual(refreshCount, 4)
    }
}

private extension ExternalSurfaceSnapshotTests {
    func makeGoal(
        goalID: String,
        goalTitle: String,
        stepID: String,
        stepTitle: String,
        dueAt: String
    ) -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "Self", ownership: .self, roleLabel: nil, isPrimary: true)
        let timing = GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let actionability = StepActionability(
            action: "Do it",
            completionDefinition: "Done",
            evidenceOfCompletion: ["Done"],
            fallbackMicroStep: "Start",
            contextRequirements: []
        )
        let step = Step(
            id: stepID,
            sectionID: "section-1",
            title: stepTitle,
            summary: nil,
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: [],
            actionability: actionability
        )
        let section = PlanSection(
            id: "section-1",
            goalID: goalID,
            title: "Main",
            summary: nil,
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let plan = GoalPlan(
            id: "plan-1",
            goalID: goalID,
            version: 1,
            generatedAt: "2026-04-15T10:00:00Z",
            summary: "Test plan",
            strategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: goalID, planVersion: 1, isValid: true, issueCount: 0, issues: [])
        )

        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: goalID,
            revision: 1,
            createdAt: "2026-04-15T10:00:00Z",
            updatedAt: "2026-04-15T10:00:00Z",
            state: .active,
            title: goalTitle,
            summary: "Sensitive summary",
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 3,
                preferredSectionOrder: [.overview, .activeSteps, .review],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: true,
                preferShortSteps: true,
                revisitCadenceDays: 7
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: 3,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: plan
        )
    }
}

private actor RecordingSnapshotWriter: ExternalSurfaceSnapshotWriting {
    private(set) var refreshCount = 0

    func refresh(now: Date) async {
        _ = now
        refreshCount += 1
    }
}

private struct RecordingTodayService: TodayServicing {
    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return PreviewTodayScenarios.empty
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        return TodayActionResponse(message: nil)
    }
}

private struct RecordingGoalsService: GoalsServicing {
    func loadOverview() async throws -> GoalsOverview {
        PreviewGoalsScenarios.overview
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        if let scenario = PreviewGoalsScenarios.detailScenarios[target.id] {
            return scenario
        }
        return try XCTUnwrap(PreviewGoalsScenarios.detailScenarios.values.first)
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = request
        _ = now
        return CreateGoalResponse(
            target: GoalRouteTarget(goalID: "goal-1", draftID: "draft-1"),
            blueprint: GoalBlueprint(
                title: "Test goal",
                summary: nil,
                mode: .project,
                relationshipKind: .independent,
                actor: GoalActor(actorID: "self", displayName: "Self", ownership: .self, roleLabel: nil, isPrimary: true),
                parentGoalID: nil,
                tags: [],
                pace: .untimed,
                targetDate: nil,
                repeatEveryDays: nil,
                source: .manual
            )
        )
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }
}
