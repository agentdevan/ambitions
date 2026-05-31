import AmbitionsWidgetUI
import Foundation

protocol StartupServicing: Sendable {
    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession
}

protocol TodayServicing: Sendable {
    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience
    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse
    func recordActionClosure(_ closure: TodayActionClosureSheetState, outcome: TodayActionClosureOutcomeState, now: Date) async throws -> TodayActionResponse
}

extension TodayServicing {
    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        try await loadTodayExperience(userDisplayName: userDisplayName, now: now, entryContext: .standard)
    }

    func recordActionClosure(_ closure: TodayActionClosureSheetState, outcome: TodayActionClosureOutcomeState, now: Date) async throws -> TodayActionResponse {
        _ = closure
        _ = outcome
        _ = now
        return TodayActionResponse(
            message: TodayInlineMessage(
                title: "Receipt not saved",
                body: "The current Today service cannot persist closure receipts from this preview path.",
                state: .warning
            )
        )
    }
}

protocol GoalsServicing: Sendable {
    func loadOverview() async throws -> GoalsOverview
    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation
    func previewCreateGoal(_ request: CreateGoalPreviewRequest, now: Date) async throws -> CreateGoalPreviewState
    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse
    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse
    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse
    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse
}

protocol GoalCreationPreparing: Sendable {
    func prepareGoalCreation(_ request: CreateGoalRequest, now: Date) async throws -> PreparedGoalCreation
    func didCommitPreparedGoalCreation(now: Date) async
}

extension GoalCreationPreparing {
    func didCommitPreparedGoalCreation(now: Date) async {
        _ = now
    }
}

extension GoalsServicing {
    func submitExplainabilityCorrection(_ request: GoalExplainabilityCorrectionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        return GoalDetailActionResponse(message: nil)
    }
}

protocol HabitsServicing: Sendable {
    func loadDashboard(now: Date) async throws -> HabitsDashboard
    func performAction(_ request: HabitActionRequest, now: Date) async throws -> HabitActionResponse
}

protocol TimeServicing: Sendable {
    func loadTimeDashboard(now: Date) async throws -> TimeDashboard
    func loadWeeklyReviewDashboard(now: Date) async throws -> WeeklyReviewDashboard
    func makeTimeCalendarAware(now: Date) async throws -> TimeDashboard
}

extension TimeServicing {
    func makeTimeCalendarAware(now: Date) async throws -> TimeDashboard {
        try await loadTimeDashboard(now: now)
    }
}

protocol InsightsServicing: Sendable {
    func loadInsightsDashboard() async throws -> InsightsDashboard
}

/// A service protocol that acts as the coordinator and model producer for the 'You' (system settings & trust center) domain.
///
/// `YouServicing` consolidates all on-device configurations, local preference states, calendar boundaries,
/// notification schedules, and trust-sensitive parameters into a single unified `YouDashboard` view model.
///
/// Conforms to `Sendable` to guarantee safe thread execution across Swift 6 concurrency boundaries.
protocol YouServicing: Sendable {
    
    /// Compiles and returns a complete, immutable snapshot of the user's local operating system settings,
    /// trust center metrics, data map boundaries, and visual appearance preferences.
    ///
    /// - Returns: A complete, structured `YouDashboard` containing active state and visual configuration metrics.
    /// - Throws: An error if persistence retrieval fails or system permissions cannot be resolved.
    func loadYouDashboard() async throws -> YouDashboard
    
    /// Persists visual accent and functional preference updates to on-device storage and returns the updated dashboard model.
    ///
    /// - Parameter preferences: The preference patch containing requested changes to appearance, cadence, and tab configurations.
    /// - Returns: The updated, immutable `YouDashboard` reflecting the newly applied preferences.
    /// - Throws: An error if storage persistence fails.
    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard
}


protocol CaptureServicing: Sendable {
    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture
    func listCaptures() async throws -> [Capture]
    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture?
    func updateCaptureRoute(_ request: CaptureRouteUpdateRequest, now: Date) async throws -> Capture?
    func markAsOneTimeCommitment(id: String, deadlineText: String?, contextLensHint: NowContextLens?, now: Date) async throws -> Capture?
    func markAsDeadlineTask(id: String, deadlineText: String, contextLensHint: NowContextLens?, now: Date) async throws -> Capture?
    func markAsGoalSeed(id: String, now: Date) async throws -> Capture?
    func markAsGoalSupportingTask(id: String, goalID: String?, now: Date) async throws -> Capture?
    func markAsDeliverableSeed(id: String, deliverableHint: String?, now: Date) async throws -> Capture?
    func markAsWaiting(id: String, waitingMetadata: CaptureWaitingMetadata?, now: Date) async throws -> Capture?
    func markAsOptionalSomeday(id: String, now: Date) async throws -> Capture?
    func routeToTimeSeed(id: String, now: Date) async throws -> Capture?
    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding?
    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding?
    func markCaptureProcessed(id: String, now: Date) async throws -> Capture?
    func markCaptureArchived(id: String, now: Date) async throws -> Capture?
}

protocol MemoryLensServicing: Sendable {
    func search(query: String, seedIntent: ShellCommandIntent?) async -> [MemoryLensResult]
}

protocol AppActionRouting {
    func handle(_ action: WidgetAction) async
}

struct DefaultStartupService: StartupServicing {
    let preferencesStore: any AppPreferencesStore
    let appStateRepository: (any AppStateRepository)?

    func prepareSession(source: AppSession.BootstrapSource) async throws -> AppSession {
        let preferences = try await preferencesStore.loadPreferences()
        let forceOnboarding = ProcessInfo.processInfo.environment["AMBITIONS_FORCE_ONBOARDING"] == "1"
        var shouldShowOnboarding = false
        if let appStateRepository {
            var state = try await appStateRepository.loadState()
            shouldShowOnboarding = forceOnboarding || (source == .live && state.hasCompletedOnboarding == false)
            state.hasCompletedBootstrap = true
            state.lastBootstrapSource = source
            state.lastBootstrapAt = ISO8601DateFormatter().string(from: .now)
            try await appStateRepository.saveState(state)
        }
        return AppSession(
            source: source,
            userDisplayName: preferences.userDisplayName,
            initialTab: preferences.preferredTab,
            appearancePreference: preferences.appearancePreference,
            accentFamily: preferences.accentFamily,
            launchedAt: Date(),
            startupNote: startupNote(for: source),
            shouldShowOnboarding: shouldShowOnboarding
        )
    }

    private func startupNote(for source: AppSession.BootstrapSource) -> String {
        switch source {
        case .preview:
            return "Preview bootstrap uses isolated in-memory fixtures."
        case .demo:
            return "Demo bootstrap uses isolated in-memory seeded data."
        case .live:
            return "Live bootstrap is persistence-backed and starts from the user's actual on-device data."
        }
    }
}

struct StubHabitsService: HabitsServicing {
    let dashboard: HabitsDashboard
    let actionResponse: HabitActionResponse?

    init(dashboard: HabitsDashboard, actionResponse: HabitActionResponse? = nil) {
        self.dashboard = dashboard
        self.actionResponse = actionResponse
    }

    func loadDashboard(now: Date) async throws -> HabitsDashboard {
        _ = now
        return dashboard
    }

    func performAction(_ request: HabitActionRequest, now: Date) async throws -> HabitActionResponse {
        _ = request
        _ = now
        return actionResponse ?? HabitActionResponse(message: nil)
    }
}

struct StubTimeService: TimeServicing {
    let dashboard: TimeDashboard
    let weeklyReviewDashboard: WeeklyReviewDashboard

    func loadTimeDashboard(now: Date) async throws -> TimeDashboard {
        _ = now
        return dashboard
    }

    func loadWeeklyReviewDashboard(now: Date) async throws -> WeeklyReviewDashboard {
        _ = now
        return weeklyReviewDashboard
    }

    func makeTimeCalendarAware(now: Date) async throws -> TimeDashboard {
        _ = now
        return dashboard
    }
}

#if DEBUG
struct StubInsightsService: InsightsServicing {
    let fixtures: PreviewFixtures
    func loadInsightsDashboard() async throws -> InsightsDashboard { fixtures.insightsDashboard }
}

struct StubYouService: YouServicing {
    let fixtures: PreviewFixtures
    func loadYouDashboard() async throws -> YouDashboard { fixtures.youDashboard }
    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard {
        _ = preferences
        return fixtures.youDashboard
    }
}
#endif

struct StubCaptureService: CaptureServicing {
    let captures: [Capture]

    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture {
        Capture(
            id: "preview-capture-created",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: request.rawText,
            sourceType: request.sourceType,
            status: .actionable,
            linkedGoalID: request.linkedGoalID,
            kind: request.kind ?? .raw,
            route: request.route ?? .captureInbox,
            triageStatus: request.triageStatus ?? .needsTriage,
            commitmentKind: request.commitmentKind,
            deadlineText: request.deadlineText,
            deadlineKind: request.deadlineKind,
            contextLensHint: request.contextLensHint,
            priorityHints: request.priorityHints,
            goalRelationship: request.goalRelationship,
            deliverableHint: request.deliverableHint,
            scopeItemHint: request.scopeItemHint,
            waitingMetadata: request.waitingMetadata,
            assumptionSummary: request.assumptionSummary,
            recommendationExplanationIDs: request.recommendationExplanationIDs
        )
    }

    func listCaptures() async throws -> [Capture] {
        captures
    }

    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == request.id })
    }

    func updateCaptureRoute(_ request: CaptureRouteUpdateRequest, now: Date) async throws -> Capture? {
        _ = request
        _ = now
        return captures.first
    }

    func markAsOneTimeCommitment(id: String, deadlineText: String?, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        _ = deadlineText
        _ = contextLensHint
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markAsDeadlineTask(id: String, deadlineText: String, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        _ = deadlineText
        _ = contextLensHint
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markAsGoalSeed(id: String, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markAsGoalSupportingTask(id: String, goalID: String?, now: Date) async throws -> Capture? {
        _ = goalID
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markAsDeliverableSeed(id: String, deliverableHint: String?, now: Date) async throws -> Capture? {
        _ = deliverableHint
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markAsWaiting(id: String, waitingMetadata: CaptureWaitingMetadata?, now: Date) async throws -> Capture? {
        _ = waitingMetadata
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func markAsOptionalSomeday(id: String, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func routeToTimeSeed(id: String, now: Date) async throws -> Capture? {
        _ = now
        return captures.first(where: { $0.id == id })
    }

    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        _ = now
        guard let capture = captures.first(where: { $0.id == request.captureID }) else {
            return nil
        }
        return CaptureGoalBinding(capture: capture, target: GoalRouteTarget(goalID: request.goalID, draftID: nil))
    }

    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        _ = now
        guard let capture = captures.first(where: { $0.id == request.captureID }) else {
            return nil
        }
        return CaptureGoalBinding(capture: capture, target: GoalRouteTarget(goalID: "preview-goal-created", draftID: "preview-draft-created"))
    }
}

@MainActor
struct DefaultAppActionRouter: AppActionRouting {
    let navigation: AppNavigationModel

    func handle(_ action: WidgetAction) async {
        switch action.identity.family {
        case .insightStats, .weeklyTrend, .recentActivity:
            navigation.selectTab(.you) // Insights/History is now part of the You domain or a sibling, but usually You for profile/settings
        case .profileSummary, .settingsGroup:
            navigation.selectTab(.you)
        case .habitSummary, .streak:
            navigation.openHabits()
        case .dailyTargets, .focusNow, .freeTime, .milestonePrompt, .goalsList, .celebration:
            navigation.selectTab(.today)
        }
    }
}
