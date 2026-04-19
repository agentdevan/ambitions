import Foundation

struct SharedLifeCoordinationService: Sendable {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func buildSnapshot(
        goals: [Goal],
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        now: Date
    ) -> SharedLifeCoordinationSnapshot {
        let activeGoals = goals.filter { $0.state == .active || $0.state == .paused }
        let goalSummaries = Dictionary(uniqueKeysWithValues: activeGoals.map { goal in
            (goal.id, summary(for: goal, within: activeGoals, evidence: evidence, feedback: feedback, now: now))
        })
        let orderedSummaries = goalSummaries.values.sorted { lhs, rhs in
            if lhs.pressureScore == rhs.pressureScore {
                return lhs.goalID < rhs.goalID
            }
            return lhs.pressureScore > rhs.pressureScore
        }
        let totalResponsibilities = orderedSummaries.reduce(0) { $0 + $1.responsibilitySummary.totalCount }
        let careGoalCount = orderedSummaries.filter(\.careContextActive).count
        let coordinationSignalCount = orderedSummaries.reduce(0) { $0 + $1.coordinationSignals.count }

        let headline: String
        if totalResponsibilities == 0 {
            headline = "No active shared-life responsibilities need coordination right now."
        } else if careGoalCount > 0 {
            headline = "Shared care and household responsibilities are visible across \(careGoalCount) active goal\(careGoalCount == 1 ? "" : "s")."
        } else {
            headline = "Shared responsibilities are visible across \(orderedSummaries.count) active goal\(orderedSummaries.count == 1 ? "" : "s")."
        }

        return SharedLifeCoordinationSnapshot(
            goalSummaries: goalSummaries,
            portfolioSummary: SharedLifePortfolioSummary(
                totalResponsibilityCount: totalResponsibilities,
                careGoalCount: careGoalCount,
                coordinationSignalCount: coordinationSignalCount,
                headline: headline
            )
        )
    }
}

private extension SharedLifeCoordinationService {
    func summary(
        for goal: Goal,
        within goals: [Goal],
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        now: Date
    ) -> SharedLifeGoalSummary {
        let base = LifeGraphResolver.sharedLifeSummary(for: goal, within: goals, now: now)
        let goalStepIDs = Set(goal.plan?.sections.flatMap(\.steps).map(\.id) ?? [])
        let recentWindowStart = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        let recentDelegatedUpdates = evidence.filter { item in
            item.goalID == goal.id &&
                item.evidenceKind == .delegatedUpdate &&
                (parseDate(item.capturedAt).map { $0 >= recentWindowStart } ?? false)
        }.count
        let recentFriction = feedback.filter { event in
            goalStepIDs.contains(event.stepID) &&
                isFriction(event) &&
                (parseDate(event.base.occurredAt).map { $0 >= recentWindowStart } ?? false)
        }.count

        var reasons = base.reasons
        if recentFriction > 0 {
            reasons.append("Recent friction suggests the shared coordination load needs a gentler next move.")
        }
        if base.delegatedSupportActive && recentDelegatedUpdates == 0 {
            reasons.append("Support coordination is active, but recent support updates are still thin.")
        }

        var pressure = base.pressureScore
        if recentFriction > 0 {
            pressure += min(0.12, Double(recentFriction) * 0.04)
        }
        if base.delegatedSupportActive && recentDelegatedUpdates == 0 {
            pressure += 0.05
        }
        if base.coordinationSignals.contains(where: \.needsPreparation) {
            pressure += 0.04
        }

        return SharedLifeGoalSummary(
            goalID: base.goalID,
            participantNames: base.participantNames,
            relationshipLabels: base.relationshipLabels,
            delegatedSupportActive: base.delegatedSupportActive,
            careContextActive: base.careContextActive,
            structuralSupportGoalCount: base.structuralSupportGoalCount,
            responsibilitySummary: base.responsibilitySummary,
            coordinationSignals: base.coordinationSignals,
            pressureScore: roundToTwoDecimals(min(max(pressure, 0.05), 0.95)),
            reasons: Array(reasons.prefix(3))
        )
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return DomainTimestamp.date(from: value)
    }

    func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
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
