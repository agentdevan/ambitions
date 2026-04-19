import Foundation

struct RitualOrchestrationInput: Sendable {
    let goals: [Goal]
    let captures: [Capture]
    let evidence: [ProgressEvidence]
    let feedback: [GoalFeedbackEvent]
    let learningSnapshot: LearningAnticipationSnapshot?
    let now: Date

    init(
        goals: [Goal],
        captures: [Capture],
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        learningSnapshot: LearningAnticipationSnapshot? = nil,
        now: Date
    ) {
        self.goals = goals
        self.captures = captures
        self.evidence = evidence
        self.feedback = feedback
        self.learningSnapshot = learningSnapshot
        self.now = now
    }
}

struct RitualOrchestrationService: Sendable {
    private let calendar: Calendar
    private let selector: PlanningNextStepSelector

    init(
        calendar: Calendar = RitualOrchestrationService.utcCalendar,
        selector: PlanningNextStepSelector = PlanningNextStepSelector()
    ) {
        var configured = calendar
        configured.timeZone = calendar.timeZone
        self.calendar = configured
        self.selector = selector
    }

    func makePlan(input: RitualOrchestrationInput) -> RitualPlan {
        let activeGoals = input.goals.filter { $0.state == .active || $0.state == .paused }
        let bestSelection = selector.bestSelection(
            goals: activeGoals,
            evidence: input.evidence,
            feedback: input.feedback,
            now: input.now
        )
        let summary = signalSummary(input: input, activeGoals: activeGoals)
        let kind = ritualKind(now: input.now)
        let recommendation = recommendation(
            kind: kind,
            selection: bestSelection,
            summary: summary,
            hasAnySignal: activeGoals.isEmpty == false || summary.openCaptureCount > 0
        )

        return RitualPlan(
            activeRecommendation: recommendation,
            signalSummary: summary,
            dayThesis: dayThesis(summary: summary, selection: bestSelection),
            weekThesis: weekThesis(summary: summary, learningSnapshot: input.learningSnapshot)
        )
    }
}

private extension RitualOrchestrationService {
    static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    func ritualKind(now: Date) -> RitualKind {
        let weekday = calendar.component(.weekday, from: now)
        let hour = calendar.component(.hour, from: now)
        if weekday == 2, hour < 12 {
            return .weeklyReset
        }
        switch hour {
        case 5..<12:
            return .morningSetup
        case 12..<18:
            return .middayReset
        default:
            return .eveningClose
        }
    }

    func signalSummary(input: RitualOrchestrationInput, activeGoals: [Goal]) -> RitualSignalSummary {
        let dayStart = calendar.startOfDay(for: input.now)
        let weekStart = calendar.date(byAdding: .day, value: -6, to: dayStart) ?? dayStart
        let completedToday = input.evidence.filter { evidence in
            guard let date = DomainTimestamp.date(from: evidence.capturedAt) else { return false }
            guard calendar.isDate(date, inSameDayAs: input.now) else { return false }
            switch evidence.evidenceKind {
            case .stepCompleted, .habitCompletion, .habitMinimumVersion:
                return true
            case .habitQuickLog, .sessionLogged, .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
                return false
            }
        }.count
        let frictionToday = input.feedback.filter { event in
            guard let date = DomainTimestamp.date(from: event.base.occurredAt) else { return false }
            return calendar.isDate(date, inSameDayAs: input.now) && isFriction(event)
        }.count
        let frictionThisWeek = input.feedback.filter { event in
            guard let date = DomainTimestamp.date(from: event.base.occurredAt) else { return false }
            return date >= weekStart && date <= input.now && isFriction(event)
        }.count
        let openCaptures = input.captures.filter { $0.status != .archived }.count

        return RitualSignalSummary(
            activeGoalCount: activeGoals.count,
            openCaptureCount: openCaptures,
            completedTodayCount: completedToday,
            frictionTodayCount: frictionToday,
            frictionThisWeekCount: frictionThisWeek,
            pressureLevel: pressureLevel(activeGoals: activeGoals, frictionThisWeek: frictionThisWeek)
        )
    }

    func recommendation(
        kind: RitualKind,
        selection: PlanningNextStepSelection?,
        summary: RitualSignalSummary,
        hasAnySignal: Bool
    ) -> RitualRecommendation {
        guard hasAnySignal else {
            return RitualRecommendation(
                kind: kind,
                progressState: .unavailable,
                title: title(for: kind),
                body: "Add a real goal or capture before Ambitions suggests a repeat loop.",
                stateLabel: "Waiting on signal",
                primaryAction: nil
            )
        }

        let reference = selection.map { selection in
            RitualActionReference(
                kind: actionKind(for: kind, summary: summary),
                goalID: selection.goal.id,
                stepID: selection.step.id
            )
        }

        return RitualRecommendation(
            kind: kind,
            progressState: progressState(for: kind, summary: summary),
            title: title(for: kind),
            body: body(for: kind, summary: summary, hasSelection: selection != nil),
            stateLabel: stateLabel(for: kind, summary: summary),
            primaryAction: reference
        )
    }

    func actionKind(for kind: RitualKind, summary: RitualSignalSummary) -> RitualActionKind {
        switch kind {
        case .morningSetup, .weeklyReset:
            return .openDetail
        case .middayReset:
            return summary.frictionTodayCount > 0 || summary.completedTodayCount == 0 ? .askForSmallerStep : .openDetail
        case .eveningClose:
            return .quickLog
        }
    }

    func progressState(for kind: RitualKind, summary: RitualSignalSummary) -> RitualProgressState {
        switch kind {
        case .morningSetup, .weeklyReset:
            return summary.activeGoalCount == 0 && summary.openCaptureCount == 0 ? .unavailable : .ready
        case .middayReset:
            return summary.frictionTodayCount > 0 || summary.completedTodayCount == 0 ? .needsReset : .ready
        case .eveningClose:
            return summary.completedTodayCount > 0 ? .complete : .ready
        }
    }

    func title(for kind: RitualKind) -> String {
        switch kind {
        case .morningSetup:
            return "Morning setup"
        case .middayReset:
            return "Midday reset"
        case .eveningClose:
            return "Evening close"
        case .weeklyReset:
            return "Weekly reset"
        }
    }

    func body(for kind: RitualKind, summary: RitualSignalSummary, hasSelection: Bool) -> String {
        switch kind {
        case .morningSetup:
            if summary.openCaptureCount > 0 {
                return hasSelection ? "Pick one next move and keep open captures visible." : "Start by clearing the open capture signal."
            }
            return "Pick one next move before the day gets noisy."
        case .middayReset:
            if summary.frictionTodayCount > 0 {
                return "Use a smaller next move before pressure turns into drift."
            }
            if summary.completedTodayCount == 0 {
                return "Choose a visible minimum pass for the afternoon."
            }
            return "Keep the afternoon pointed at the same believable next move."
        case .eveningClose:
            if summary.completedTodayCount > 0 {
                return "Close the loop by logging what changed and leaving tomorrow lighter."
            }
            if summary.frictionTodayCount > 0 {
                return "Respect the friction signal and leave a smaller restart point."
            }
            return "Leave one clean note for the next return."
        case .weeklyReset:
            return "Review the week around active goals, friction, and one believable next move."
        }
    }

    func stateLabel(for kind: RitualKind, summary: RitualSignalSummary) -> String {
        switch progressState(for: kind, summary: summary) {
        case .unavailable:
            return "Waiting"
        case .ready:
            return summary.pressureLevel == .high ? "Tight" : "Ready"
        case .needsReset:
            return "Reset needed"
        case .complete:
            return "Progress landed"
        }
    }

    func dayThesis(summary: RitualSignalSummary, selection: PlanningNextStepSelection?) -> String {
        if summary.activeGoalCount == 0 && summary.openCaptureCount == 0 {
            return "No day thesis yet because Ambitions has no live signal."
        }
        if selection != nil {
            return "Anchor the day around one next move."
        }
        if summary.openCaptureCount > 0 {
            return "Start by turning open captures into clearer plan signal."
        }
        return "Keep the day light until the next move is clear."
    }

    func weekThesis(summary: RitualSignalSummary, learningSnapshot: LearningAnticipationSnapshot?) -> String {
        if summary.activeGoalCount == 0 {
            return "No active goals are shaping the week yet."
        }
        let goalLabel = "\(summary.activeGoalCount) active goal\(summary.activeGoalCount == 1 ? "" : "s")"
        if let signal = learningSnapshot?.underrepresentedGoalSignals.first {
            let domain = signal.domain?.rawValue.replacingOccurrences(of: "_", with: " ") ?? "one domain"
            return "\(goalLabel), with underrepresented pressure visible in \(domain)."
        }
        if summary.frictionThisWeekCount > 0 {
            return "\(goalLabel), with \(summary.frictionThisWeekCount) friction signal\(summary.frictionThisWeekCount == 1 ? "" : "s") worth respecting."
        }
        return "\(goalLabel), with pressure kept \(summary.pressureLevel.rawValue)."
    }

    func pressureLevel(activeGoals: [Goal], frictionThisWeek: Int) -> PlanningPressureLevel {
        let planPressure = activeGoals
            .compactMap { $0.plan?.evaluation?.pressureLevel }
        if planPressure.contains(.high) || activeGoals.count >= 6 || frictionThisWeek >= 4 {
            return .high
        }
        if planPressure.contains(.moderate) || activeGoals.count >= 3 || frictionThisWeek > 0 {
            return .moderate
        }
        return .low
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .delayed, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        case .completed, .edited, .tooEasy, .askedWhyThisMatters:
            return false
        }
    }
}
