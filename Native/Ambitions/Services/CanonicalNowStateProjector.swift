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
    private let selector: PlanningNextStepSelector

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

private extension CanonicalNowStateProjector {
    struct DatedStep {
        let goal: Goal
        let step: Step
        let date: Date
        let pressure: NowPressureLevel
    }

    func bestAction(
        from selection: PlanningNextStepSelection?,
        explanations: [RecommendationExplanation]
    ) -> NowAction? {
        guard let selection else { return nil }
        let explanation = explanation(forGoalID: selection.goal.id, stepID: selection.step.id, explanations: explanations)
        return action(
            goal: selection.goal,
            step: selection.step,
            kind: selection.step.state == .blocked ? .wait : .focus,
            state: selection.step.state == .blocked ? .blocked : .ready,
            explanationID: explanation?.id
        )
    }

    func action(
        goal: Goal,
        step: Step,
        kind: NowActionKind,
        state: NowActionState,
        explanationID: String?
    ) -> NowAction {
        NowAction(
            id: "now.action.\(goal.id).\(step.id)",
            kind: kind,
            state: state,
            title: step.title,
            subtitle: goal.title,
            contextLens: lens(for: goal),
            commitmentKind: commitmentKind(goal: goal, step: step),
            reference: NowActionReference(goalID: goal.id, stepID: step.id),
            explanationID: explanationID
        )
    }

    func upcomingDatedSteps(goals: [Goal], now: Date) -> [DatedStep] {
        let horizon = now.addingTimeInterval(7 * 24 * 60 * 60)
        return goals.flatMap { goal in
            (goal.plan?.sections.flatMap(\.steps) ?? []).compactMap { step -> DatedStep? in
                guard step.state != .completed && step.state != .cancelled,
                      let date = date(from: step.timing.dueAt ?? step.timing.targetBy ?? step.timing.windowEnd ?? step.timing.suggestedNextAt),
                      date <= horizon else {
                    return nil
                }
                return DatedStep(goal: goal, step: step, date: date, pressure: pressure(for: date, now: now))
            }
        }.sorted {
            if $0.date != $1.date { return $0.date < $1.date }
            if $0.goal.id != $1.goal.id { return $0.goal.id < $1.goal.id }
            return $0.step.id < $1.step.id
        }
    }

    func schedulePressure(from datedSteps: [DatedStep]) -> NowPressureSummary {
        let count = datedSteps.count
        let level: NowPressureLevel
        switch count {
        case 0:
            level = .none
        case 1...2:
            level = .low
        case 3...4:
            level = .moderate
        case 5...6:
            level = .elevated
        default:
            level = .high
        }
        return NowPressureSummary(
            level: level,
            itemCount: count,
            summary: count == 0
                ? "No local schedule pressure is visible."
                : "\(count) local dated item\(count == 1 ? "" : "s") can shape the next seven days."
        )
    }

    func deadlinePressure(from urgentSteps: [DatedStep]) -> NowPressureSummary {
        let strongest = urgentSteps.map(\.pressure).max(by: pressureSort) ?? .none
        return NowPressureSummary(
            level: strongest,
            itemCount: urgentSteps.count,
            summary: urgentSteps.isEmpty
                ? "No urgent deadline pressure is visible."
                : "\(urgentSteps.count) deadline-bound item\(urgentSteps.count == 1 ? "" : "s") need attention soon."
        )
    }

    func captureUrgency(openCaptures: [Capture]) -> NowPressureSummary {
        let count = openCaptures.count
        let level: NowPressureLevel
        switch count {
        case 0:
            level = .none
        case 1...2:
            level = .low
        case 3...4:
            level = .moderate
        default:
            level = .elevated
        }
        return NowPressureSummary(
            level: level,
            itemCount: count,
            summary: count == 0
                ? "No open captures are asking for attention."
                : "\(count) capture\(count == 1 ? "" : "s") still need a destination."
        )
    }

    func blockersWaitingSummary(
        blockedSteps: [(Goal, Step)],
        waitingCaptures: [Capture]
    ) -> NowBlockersWaitingSummary {
        let references = blockedSteps.map { goal, step in
            NowActionReference(goalID: goal.id, stepID: step.id)
        } + waitingCaptures.map { capture in
            NowActionReference(captureID: capture.id)
        }
        let blockedCount = blockedSteps.count
        let waitingCount = waitingCaptures.count
        let summary: String
        if blockedCount == 0 && waitingCount == 0 {
            summary = "No blockers or waiting items are visible."
        } else {
            summary = "\(blockedCount) blocked and \(waitingCount) waiting item\(blockedCount + waitingCount == 1 ? "" : "s") are visible."
        }
        return NowBlockersWaitingSummary(
            blockedCount: blockedCount,
            waitingCount: waitingCount,
            summary: summary,
            references: references
        )
    }

    func goalPressureSummaries(
        goals: [Goal],
        selections: [PlanningNextStepSelection],
        kind: NowGoalPressureKind,
        now: Date,
        explanations: [RecommendationExplanation]
    ) -> [NowGoalPressureSummary] {
        goals.map { goal in
            let selection = selections.first { $0.goal.id == goal.id }
            let duePressure = pressure(for: date(from: goal.timing.dueAt ?? goal.timing.targetBy ?? goal.timing.windowEnd), now: now)
            let blockedCount = goal.plan?.sections.flatMap(\.steps).filter { $0.state == .blocked }.count ?? 0
            let level = maxPressure([duePressure, blockedCount > 0 ? .elevated : .none, kind == .activeGoal ? .moderate : .low])
            let explanation = explanation(forGoalID: goal.id, stepID: selection?.step.id, explanations: explanations)
            let nextAction = selection.map {
                action(goal: $0.goal, step: $0.step, kind: .focus, state: .ready, explanationID: explanation?.id)
            }
            return NowGoalPressureSummary(
                id: "now.goal-pressure.\(kind.rawValue).\(goal.id)",
                kind: kind,
                level: level,
                goalID: goal.id,
                title: goal.title,
                summary: summary(goal: goal, kind: kind, duePressure: duePressure, blockedCount: blockedCount),
                nextAction: nextAction,
                explanationID: explanation?.id,
                eventLedgerEntryIDs: explanations.flatMap(\.relations.eventLedgerEntryIDs)
            )
        }
    }

    func priorityReality(
        schedulePressure: NowPressureSummary,
        deadlinePressure: NowPressureSummary,
        activeGoalPressure: [NowGoalPressureSummary],
        passiveGoalPressure: [NowGoalPressureSummary],
        recovery: NowRecoveryState
    ) -> NowPriorityRealitySummary {
        let activeLevel = maxPressure(activeGoalPressure.map(\.level))
        let passiveLevel = maxPressure(passiveGoalPressure.map(\.level))
        let capacity = schedulePressure.level == .high ? NowPressureLevel.elevated : schedulePressure.level
        let recoveryPressure: NowPressureLevel = {
            switch recovery {
            case .stable:
                return .none
            case .watch:
                return .moderate
            case .needsRecovery, .recovering:
                return .elevated
            case .blocked:
                return .high
            }
        }()
        let overall = maxPressure([deadlinePressure.level, activeLevel, capacity, recoveryPressure])
        return NowPriorityRealitySummary(
            overallPressure: overall,
            importance: activeLevel,
            urgency: maxPressure([deadlinePressure.level, schedulePressure.level]),
            deadline: deadlinePressure.level,
            consequence: deadlinePressure.level == .critical || deadlinePressure.level == .high ? .high : .low,
            effort: schedulePressure.level,
            contextFit: passiveLevel == .low && rank(activeLevel) > rank(passiveLevel) ? .moderate : .low,
            goalRelationship: maxPressure([activeLevel, passiveLevel]),
            userPreference: .none,
            capacity: capacity,
            recoveryState: recovery,
            summary: overall == .none
                ? "No priority pressure is visible yet."
                : "Priority pressure reflects active goals, dated work, capacity pressure, and recovery state."
        )
    }

    func outsideLensSummary(
        activeLens: NowContextLens,
        selections: [PlanningNextStepSelection],
        now: Date
    ) -> NowUrgentOutsideLensSummary {
        guard activeLens != .all else {
            return NowUrgentOutsideLensSummary(level: .none, summary: "All lenses are visible.")
        }
        let items = selections.compactMap { selection -> NowOutsideLensItem? in
            let lens = lens(for: selection.goal)
            guard lens != activeLens && lens != .all else { return nil }
            let pressure = pressure(for: date(from: selection.step.timing.dueAt ?? selection.step.timing.targetBy ?? selection.step.timing.windowEnd), now: now)
            guard pressure == .critical || pressure == .high || pressure == .elevated else { return nil }
            return NowOutsideLensItem(
                id: "now.outside-lens.\(selection.goal.id).\(selection.step.id)",
                title: selection.step.title,
                lens: lens,
                pressure: pressure,
                reference: NowActionReference(goalID: selection.goal.id, stepID: selection.step.id)
            )
        }
        return NowUrgentOutsideLensSummary(
            level: maxPressure(items.map(\.pressure)),
            summary: items.isEmpty
                ? "No urgent outside-lens items are visible."
                : "\(items.count) urgent item\(items.count == 1 ? "" : "s") outside this lens should stay visible.",
            items: items
        )
    }

    func todayPosture(
        activeGoals: Int,
        blockedCount: Int,
        openCaptureCount: Int,
        schedulePressure: NowPressureLevel,
        recovery: NowRecoveryState,
        bestAction: NowAction?
    ) -> NowPosture {
        if activeGoals == 0 && openCaptureCount == 0 { return .lowData }
        if recovery == .needsRecovery || recovery == .recovering { return .recovering }
        if blockedCount > 0 && bestAction == nil { return .waiting }
        if schedulePressure == .high || schedulePressure == .critical { return .overloaded }
        if schedulePressure == .elevated || openCaptureCount >= 5 { return .tight }
        if bestAction == nil { return .lowData }
        return .steady
    }

    func recoveryState(blockedCount: Int, feedback: [GoalFeedbackEvent]) -> NowRecoveryState {
        if blockedCount >= 3 { return .blocked }
        if blockedCount > 0 { return .needsRecovery }
        let recentFriction = feedback.filter { event in
            switch event {
            case .skipped, .delayed, .tooBig, .askedForSmallerVersion:
                return true
            default:
                return false
            }
        }.count
        if recentFriction >= 3 { return .watch }
        return .stable
    }

    func explanation(
        forGoalID goalID: String,
        stepID: String?,
        explanations: [RecommendationExplanation]
    ) -> RecommendationExplanation? {
        explanations.first { explanation in
            explanation.relations.goalIDs.contains(goalID) &&
            (stepID == nil || explanation.metadata["stepID"] == stepID)
        } ?? explanations.first { $0.relations.goalIDs.contains(goalID) }
    }

    func evidenceSummaries(from explanations: [RecommendationExplanation]) -> [NowEvidenceSummary] {
        explanations.flatMap { explanation in
            explanation.evidence.map { evidence in
                NowEvidenceSummary(
                    id: "now.evidence.\(explanation.id).\(evidence.id)",
                    title: evidence.title,
                    summary: evidence.summary,
                    source: explanation.source,
                    eventLedgerEntryID: evidence.eventLedgerEntryID,
                    explanationID: explanation.id
                )
            }
        }
    }

    func privacy(
        from entries: [EventLedgerEntry],
        explanations: [RecommendationExplanation]
    ) -> EventLedgerPrivacyClassification {
        if entries.contains(where: { $0.privacy == .privateUserText }) || explanations.contains(where: { $0.privacy == .privateUserText }) {
            return .privateUserText
        }
        if entries.contains(where: { $0.privacy == .calendarDerived }) || explanations.contains(where: { $0.privacy == .calendarDerived }) {
            return .calendarDerived
        }
        return .standard
    }

    func lens(for goal: Goal) -> NowContextLens {
        guard let domain = goal.lifeGraph?.domains.sorted(by: { $0.priority > $1.priority }).first?.domain else {
            if goal.mode == .learning || goal.mode == .exploration { return .creative }
            if goal.mode == .maintenance || goal.mode == .recovery { return .recovery }
            return .all
        }
        switch domain {
        case .career, .education:
            return .work
        case .finance, .home:
            return .admin
        case .creativity:
            return .creative
        case .health, .relationships, .personalGrowth:
            return .personal
        }
    }

    func commitmentKind(goal: Goal, step: Step) -> NowCommitmentKind {
        if step.state == .blocked { return .waiting }
        if step.isRepeatable || goal.mode == .habit || goal.timing.tempo == .ongoing { return .recurring }
        if step.timing.dueAt != nil || step.timing.targetBy != nil { return .oneTime }
        if goal.state == .paused || step.isOptional { return .optionalSomeday }
        return .goalSupporting
    }

    func summary(goal: Goal, kind: NowGoalPressureKind, duePressure: NowPressureLevel, blockedCount: Int) -> String {
        if blockedCount > 0 {
            return "\(blockedCount) blocked step\(blockedCount == 1 ? "" : "s") need attention before this goal can move cleanly."
        }
        if duePressure == .critical || duePressure == .high || duePressure == .elevated {
            return "This goal has deadline pressure now."
        }
        switch kind {
        case .activeGoal:
            return "Active goal pressure is visible but not urgent."
        case .passiveGoal:
            return "Passive goal pressure is preserved without crowding urgent work."
        default:
            return "Goal pressure is visible."
        }
    }

    func pressure(for date: Date?, now: Date) -> NowPressureLevel {
        guard let date else { return .none }
        let seconds = date.timeIntervalSince(now)
        if seconds < 0 { return .critical }
        if seconds <= 24 * 60 * 60 { return .high }
        if seconds <= 3 * 24 * 60 * 60 { return .elevated }
        if seconds <= 7 * 24 * 60 * 60 { return .moderate }
        return .low
    }

    func date(from value: String?) -> Date? {
        guard let value else { return nil }
        if let full = DomainTimestamp.date(from: value) { return full }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    func confidence(for score: Double?) -> RecommendationConfidence {
        RecommendationConfidence.label(for: min(max(score ?? 0.35, 0), 1))
    }

    func maxPressure(_ values: [NowPressureLevel]) -> NowPressureLevel {
        values.max(by: pressureSort) ?? .none
    }

    func pressureSort(lhs: NowPressureLevel, rhs: NowPressureLevel) -> Bool {
        rank(lhs) < rank(rhs)
    }

    func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none: 0
        case .low: 1
        case .moderate: 2
        case .elevated: 3
        case .high: 4
        case .critical: 5
        }
    }

    func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}
