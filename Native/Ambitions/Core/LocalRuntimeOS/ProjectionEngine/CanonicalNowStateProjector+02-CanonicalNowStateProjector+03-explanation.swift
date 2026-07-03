import Foundation

extension CanonicalNowStateProjector {

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
