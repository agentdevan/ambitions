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
        XCTAssertEqual(snapshot.ambientState?.plan.action.tab, "time")
        XCTAssertEqual(snapshot.ambientState?.currentStep?.kind, .currentStep)
        XCTAssertEqual(snapshot.ambientState?.currentStep?.title, "Recommended step ready")
        XCTAssertEqual(snapshot.ambientState?.todayPressure?.kind, .todayPressure)
        XCTAssertEqual(snapshot.ambientState?.todayPressure?.privacySummary, "Pressure uses local counts only")
        XCTAssertEqual(snapshot.ambientState?.protectedTime?.kind, .protectedTime)
        XCTAssertEqual(snapshot.ambientState?.protectedTime?.action.tab, "time")
        XCTAssertEqual(snapshot.ambientState?.captureEntry?.kind, .captureEntry)
        XCTAssertEqual(snapshot.ambientState?.captureEntry?.privacySummary, "Capture text never appears here")
        XCTAssertEqual(snapshot.ambientState?.recovery?.kind, .recovery)
        XCTAssertEqual(snapshot.ambientState?.recovery?.action.tab, "today")
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
        XCTAssertFalse(externalDisplayText.localizedCaseInsensitiveContains("travel radius"))
        XCTAssertFalse(externalDisplayText.localizedCaseInsensitiveContains("eligibility"))
        XCTAssertFalse(externalDisplayText.localizedCaseInsensitiveContains("injury note"))
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

    func testAFRI032OldAmbientSnapshotDecodesWithoutFlagshipVariants() throws {
        let json = """
        {
          "schemaVersion": "external_surface_snapshot.v1",
          "generatedAt": "2026-04-15T12:00:00Z",
          "nextAction": null,
          "ambientState": {
            "today": { "kind": "today", "title": "Today has a next step", "detail": "Open Today.", "privacySummary": "Glance-safe", "action": { "title": "Open Today", "surface": "tab", "tab": "today" }, "reference": null, "prominence": "standard" },
            "focus": { "kind": "focus", "title": "Focus ready", "detail": "Open Today.", "privacySummary": "Private", "action": { "title": "Open Focus", "surface": "tab", "tab": "today" }, "reference": null, "prominence": "standard" },
            "goal": { "kind": "goal", "title": "1 active goal", "detail": "Open Goals.", "privacySummary": "Private", "action": { "title": "Open Goals", "surface": "tab", "tab": "goals" }, "reference": null, "prominence": "standard" },
            "plan": { "kind": "plan", "title": "Week is holding", "detail": "Open Time.", "privacySummary": "Private", "action": { "title": "Open Time", "surface": "tab", "tab": "time" }, "reference": null, "prominence": "standard" }
          }
        }
        """

        let decoded = try PersistenceCoding.decode(ExternalSurfaceSnapshot.self, from: Data(json.utf8))

        XCTAssertEqual(decoded.ambientState?.today.kind, .today)
        XCTAssertNil(decoded.ambientState?.currentStep)
        XCTAssertNil(decoded.ambientState?.todayPressure)
        XCTAssertNil(decoded.ambientState?.protectedTime)
        XCTAssertNil(decoded.ambientState?.captureEntry)
        XCTAssertNil(decoded.ambientState?.recovery)
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
        XCTAssertEqual(state.proofLabel, "Receipt-backed local snapshot")
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
        XCTAssertEqual(state.proofLabel, "Stale snapshot; open before acting")
        XCTAssertEqual(state.deepLinkURLString, "ambitions://goal/goal-private?origin=live_activity")
        XCTAssertEqual(state.endsAt, "2026-04-15T13:00:00Z")
        XCTAssertFalse(state.title.contains("Private Tax Debt Goal"))
        XCTAssertFalse(state.detail.contains("private numbers"))
        XCTAssertFalse(state.privacyLabel.localizedCaseInsensitiveContains("travel radius"))
        XCTAssertFalse(state.accessibilitySummary.localizedCaseInsensitiveContains("injury"))
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
                    action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
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
        XCTAssertFalse(state.accessibilitySummary.localizedCaseInsensitiveContains("travel radius"))
        XCTAssertFalse(state.accessibilitySummary.localizedCaseInsensitiveContains("eligibility pathway"))
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

    func testSnapshotWriterRecordsExternalSnapshotSuccessInSideEffectLedger() async {
        let goal = makeGoal(
            goalID: "goal-success",
            goalTitle: "System title",
            stepID: "step-success",
            stepTitle: "Complete task",
            dueAt: "2026-04-16T09:00:00Z"
        )
        let sideEffectLedger = InMemorySideEffectLedgerRepository()
        let repositories = StaticSnapshotWriterRepositories(goals: [goal])
        let now = Date(timeIntervalSince1970: 1_712_779_200)
        let writer = ExternalSurfaceSnapshotWriter(
            repositories: AppRepositories(
                goals: repositories,
                drafts: repositories,
                evidence: repositories,
                feedback: repositories,
                captures: repositories,
                teaching: repositories,
                eventLedger: InMemoryEventLedgerRepository(),
                sideEffectLedger: sideEffectLedger,
                appState: repositories
            ),
            sink: NoopExternalSurfaceSnapshotDataSink()
        )

        await writer.refresh(now: now)

        let record = try? await sideEffectLedger.fetchRecord(id: "externalSnapshot.recorded_local_only.1712779200")

        XCTAssertEqual(record?.effectKind, .externalSnapshot)
        XCTAssertEqual(record?.status, .recordedLocalOnly)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.sourceDomain, .system)
        XCTAssertEqual(record?.actionKind, .noOp)
        XCTAssertEqual(record?.occurredAt, DomainTimestamp.string(from: now))
    }

    func testSnapshotWriterRecordsFailedWriteFailureInSideEffectLedger() async {
        let sideEffectLedger = InMemorySideEffectLedgerRepository()
        let repositories = StaticSnapshotWriterRepositories()
        let now = Date(timeIntervalSince1970: 1_712_779_200)
        let writer = ExternalSurfaceSnapshotWriter(
            repositories: AppRepositories(
                goals: repositories,
                drafts: repositories,
                evidence: repositories,
                feedback: repositories,
                captures: repositories,
                teaching: repositories,
                eventLedger: InMemoryEventLedgerRepository(),
                sideEffectLedger: sideEffectLedger,
                appState: repositories
            ),
            sink: ThrowingExternalSurfaceSnapshotDataSink()
        )

        await writer.refresh(now: now)

        let record = try? await sideEffectLedger.fetchRecord(id: "externalSnapshot.failed_safely.1712779200")

        XCTAssertEqual(record?.effectKind, .externalSnapshot)
        XCTAssertEqual(record?.status, .failedSafely)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.sourceDomain, .system)
        XCTAssertTrue(record?.degradedFacts.contains("External snapshot refresh/write did not complete.") ?? false)
    }
}

private actor StaticSnapshotWriterRepositories: GoalRepository, GoalDraftRepository, ProgressEvidenceRepository, FeedbackEventRepository, CaptureRepository, GoalTeachingSignalRepository, EventLedgerRepository, AppStateRepository {
    private let goals: [Goal]

    init(goals: [Goal] = []) {
        self.goals = goals
    }

    func listGoals() async throws -> [Goal] {
        goals
    }

    func listHabitGoals() async throws -> [Goal] {
        goals
    }

    func goal(id: String) async throws -> Goal? {
        goals.first { $0.id == id }
    }

    func saveGoals(_ goals: [Goal]) async throws {
        _ = goals
    }

    func deleteGoal(id: String) async throws {
        _ = id
    }

    func listActionableSteps() async throws -> [Step] {
        goals.flatMap { $0.plan?.sections.flatMap { $0.steps } ?? [] }
    }

    func listSteps(goalID: String) async throws -> [Step] {
        goals
            .first(where: { $0.id == goalID })?
            .plan?
            .sections
            .flatMap { $0.steps } ?? []
    }

    func listDrafts() async throws -> [PersistedGoalDraft] {
        []
    }

    func draft(id: String) async throws -> PersistedGoalDraft? {
        _ = id
        return nil
    }

    func saveDrafts(_ drafts: [PersistedGoalDraft]) async throws {
        _ = drafts
    }

    func deleteDraft(id: String) async throws {
        _ = id
    }

    func listEvidence(goalID: String?) async throws -> [ProgressEvidence] {
        _ = goalID
        return []
    }

    func saveEvidence(_ evidence: [ProgressEvidence]) async throws {
        _ = evidence
    }

    func listEvents(goalID: String?) async throws -> [GoalFeedbackEvent] {
        _ = goalID
        return []
    }

    func saveEvents(_ events: [GoalFeedbackEvent], goalID: String) async throws {
        _ = events
        _ = goalID
    }

    func listSignals(goalID: String?) async throws -> [GoalTeachingSignal] {
        _ = goalID
        return []
    }

    func saveSignals(_ signals: [GoalTeachingSignal]) async throws {
        _ = signals
    }

    func listCaptures() async throws -> [Capture] {
        []
    }

    func capture(id: String) async throws -> Capture? {
        _ = id
        return nil
    }

    func saveCaptures(_ captures: [Capture]) async throws {
        _ = captures
    }

    func append(_ event: EventLedgerEntry) async throws {
        _ = event
    }

    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry] {
        _ = limit
        return []
    }

    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry] {
        _ = goalID
        return []
    }

    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry] {
        _ = captureID
        return []
    }

    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry] {
        _ = kind
        return []
    }

    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry] {
        _ = start
        _ = end
        return []
    }

    func redactEvent(id: String, at timestamp: String) async throws {
        _ = id
        _ = timestamp
    }

    func deleteEvent(id: String) async throws {
        _ = id
    }

    func loadState() async throws -> AppStateSnapshot {
        .default
    }

    func saveState(_ state: AppStateSnapshot) async throws {
        _ = state
    }
}

private struct NoopExternalSurfaceSnapshotDataSink: ExternalSurfaceSnapshotDataSink {
    func write(_ data: Data) throws {
        _ = data
    }
}

private struct ThrowingExternalSurfaceSnapshotDataSink: ExternalSurfaceSnapshotDataSink {
    struct SnapshotWriteError: Error {}

    func write(_ data: Data) throws {
        _ = data
        throw SnapshotWriteError()
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
