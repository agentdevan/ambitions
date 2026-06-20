import Foundation

struct NowStateProjectionInput: Sendable, Equatable {
    let now: Date
    let activeContextLens: NowContextLens
    let lensSource: NowContextLensSource
    let availableContextLenses: [NowContextLens]
    let isManualLensOverrideActive: Bool
    let goals: [Goal]
    let captures: [Capture]
    let progressEvidence: [ProgressEvidence]
    let feedbackEvents: [GoalFeedbackEvent]
    let eventLedgerEntries: [EventLedgerEntry]
    let recommendationExplanations: [RecommendationExplanation]
    let currentAction: NowAction?
    let activeFocus: NowActionReference?

    init(
        now: Date,
        activeContextLens: NowContextLens = .all,
        lensSource: NowContextLensSource = .systemDefault,
        availableContextLenses: [NowContextLens] = NowContextLens.allCases,
        isManualLensOverrideActive: Bool = false,
        goals: [Goal] = [],
        captures: [Capture] = [],
        progressEvidence: [ProgressEvidence] = [],
        feedbackEvents: [GoalFeedbackEvent] = [],
        eventLedgerEntries: [EventLedgerEntry] = [],
        recommendationExplanations: [RecommendationExplanation] = [],
        currentAction: NowAction? = nil,
        activeFocus: NowActionReference? = nil
    ) {
        self.now = now
        self.activeContextLens = activeContextLens
        self.lensSource = lensSource
        self.availableContextLenses = availableContextLenses
        self.isManualLensOverrideActive = isManualLensOverrideActive
        self.goals = goals
        self.captures = captures
        self.progressEvidence = progressEvidence
        self.feedbackEvents = feedbackEvents
        self.eventLedgerEntries = eventLedgerEntries
        self.recommendationExplanations = recommendationExplanations
        self.currentAction = currentAction
        self.activeFocus = activeFocus
    }
}

protocol NowStateProjecting: Sendable {
    func project(input: NowStateProjectionInput) -> CanonicalNowState
}

struct CanonicalNowStateProjector: NowStateProjecting {
    let selector: PlanningNextStepSelector

    init(selector: PlanningNextStepSelector = PlanningNextStepSelector()) {
        self.selector = selector
    }

    func project(input: NowStateProjectionInput) -> CanonicalNowState {
        let generatedAt = DomainTimestamp.string(from: input.now)
        let activeGoals = input.goals.filter { $0.state == .active }
        let passiveGoals = input.goals.filter { goal in
            goal.state == .paused || goal.timing.tempo == .untimed || goal.mode == .learning || goal.mode == .exploration
        }
        let rankedSelections = selector.rankedSelections(
            goals: input.goals,
            evidence: input.progressEvidence,
            feedback: input.feedbackEvents,
            now: input.now
        )
        let bestAction = bestAction(from: rankedSelections.first, explanations: input.recommendationExplanations)
        let blockedSteps = input.goals.flatMap { goal in
            (goal.plan?.sections.flatMap(\.steps) ?? []).map { (goal, $0) }
        }.filter { _, step in
            step.state == .blocked
        }
        let openCaptures = input.captures.filter { $0.status != .archived }
        let waitingCaptures = input.captures.filter { $0.status == .delegated }
        let datedSteps = upcomingDatedSteps(goals: input.goals, now: input.now)
        let urgentDeadlineSteps = datedSteps.filter { $0.pressure == .critical || $0.pressure == .high || $0.pressure == .elevated }
        let recovery = recoveryState(blockedCount: blockedSteps.count, feedback: input.feedbackEvents)
        let schedulePressure = schedulePressure(from: datedSteps)
        let deadlinePressure = deadlinePressure(from: urgentDeadlineSteps)
        let captureUrgency = captureUrgency(openCaptures: openCaptures)
        let blockersWaiting = blockersWaitingSummary(blockedSteps: blockedSteps, waitingCaptures: waitingCaptures)
        let activeGoalPressure = goalPressureSummaries(
            goals: activeGoals,
            selections: rankedSelections,
            kind: .activeGoal,
            now: input.now,
            explanations: input.recommendationExplanations
        )
        let passiveGoalPressure = goalPressureSummaries(
            goals: passiveGoals,
            selections: rankedSelections,
            kind: .passiveGoal,
            now: input.now,
            explanations: input.recommendationExplanations
        )
        let priorityPressure = priorityReality(
            schedulePressure: schedulePressure,
            deadlinePressure: deadlinePressure,
            activeGoalPressure: activeGoalPressure,
            passiveGoalPressure: passiveGoalPressure,
            recovery: recovery
        )
        let urgentOutsideLens = outsideLensSummary(
            activeLens: input.activeContextLens,
            selections: rankedSelections,
            now: input.now
        )
        let posture = todayPosture(
            activeGoals: activeGoals.count,
            blockedCount: blockedSteps.count,
            openCaptureCount: openCaptures.count,
            schedulePressure: schedulePressure.level,
            recovery: recovery,
            bestAction: bestAction
        )

        let evidenceSummaries = evidenceSummaries(from: input.recommendationExplanations)
        let explanationIDs = normalized(
            input.recommendationExplanations.map(\.id) +
            [bestAction?.explanationID].compactMap { $0 } +
            activeGoalPressure.compactMap(\.explanationID) +
            passiveGoalPressure.compactMap(\.explanationID)
        )
        let eventIDs = normalized(
            input.eventLedgerEntries.map(\.id) +
            input.recommendationExplanations.flatMap(\.relations.eventLedgerEntryIDs) +
            [bestAction?.eventLedgerEntryIDs ?? []].flatMap { $0 }
        )

        return CanonicalNowState(
            id: "now.\(generatedAt)",
            generatedAt: generatedAt,
            activeContextLens: input.activeContextLens,
            lensSource: input.lensSource,
            availableContextLenses: input.availableContextLenses,
            isManualLensOverrideActive: input.isManualLensOverrideActive,
            todayPosture: posture,
            currentAction: input.currentAction,
            bestNextAction: bestAction,
            nextActionConfidence: bestAction == nil ? .low : confidence(for: rankedSelections.first?.candidate.score),
            nextActionExplanationID: bestAction?.explanationID,
            schedulePressure: schedulePressure,
            priorityPressure: priorityPressure,
            deadlinePressure: deadlinePressure,
            activeFocus: input.activeFocus,
            captureUrgency: captureUrgency,
            blockersWaiting: blockersWaiting,
            recoveryState: recovery,
            urgentOutsideLens: urgentOutsideLens,
            activeGoalPressure: activeGoalPressure,
            passiveGoalPressure: passiveGoalPressure,
            eventLedgerEntryIDs: eventIDs,
            recommendationExplanationIDs: explanationIDs,
            evidenceSummaries: evidenceSummaries,
            privacy: privacy(from: input.eventLedgerEntries, explanations: input.recommendationExplanations),
            localOnly: true
        )
    }
}

struct RepositoryBackedNowStateProjectionService: Sendable {
    let repositories: AppRepositories
    let projector: any NowStateProjecting

    init(
        repositories: AppRepositories,
        projector: any NowStateProjecting = CanonicalNowStateProjector()
    ) {
        self.repositories = repositories
        self.projector = projector
    }

    func loadNowState(
        now: Date,
        activeContextLens: NowContextLens = .all,
        lensSource: NowContextLensSource = .systemDefault,
        availableContextLenses: [NowContextLens] = NowContextLens.allCases,
        isManualLensOverrideActive: Bool = false
    ) async throws -> CanonicalNowState {
        async let goals = repositories.goals.listGoals()
        async let captures = repositories.captures.listCaptures()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let eventLedger = repositories.eventLedger.fetchRecent(limit: 20)

        return try await projector.project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: activeContextLens,
                lensSource: lensSource,
                availableContextLenses: availableContextLenses,
                isManualLensOverrideActive: isManualLensOverrideActive,
                goals: goals,
                captures: captures,
                progressEvidence: evidence,
                feedbackEvents: feedback,
                eventLedgerEntries: eventLedger
            )
        )
    }
}
