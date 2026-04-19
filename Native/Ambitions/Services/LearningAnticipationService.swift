import Foundation

struct LearningAnticipationService: Sendable {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func buildSnapshot(
        goals: [Goal],
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        now: Date
    ) -> LearningAnticipationSnapshot {
        let activeGoals = goals.filter { $0.state == .active || $0.state == .paused }
        let summaries = Dictionary(uniqueKeysWithValues: activeGoals.map { goal in
            (goal.id, summary(for: goal, evidence: evidence, feedback: feedback, now: now))
        })
        let underrepresented = underrepresentedSignals(goals: activeGoals, evidence: evidence, summaries: summaries, now: now)
        return LearningAnticipationSnapshot(goalSummaries: summaries, underrepresentedGoalSignals: underrepresented)
    }

    func learnedStepInsight(
        goal: Goal,
        step: Step,
        snapshot: LearningAnticipationSnapshot,
        now: Date
    ) -> LearnedStepInsight {
        guard let summary = snapshot.goalSummaries[goal.id] else {
            return LearnedStepInsight(
                fitScore: 0.5,
                confidence: .low,
                whyNow: WhyNowExplanationMetadata(
                    conciseReason: "Observed history is still limited, so Ambitions is using the current plan shape.",
                    reasons: ["Observed history is still limited."]
                )
            )
        }

        var fitScore = summary.historicalFit.score
        let nowBucket = bucket(for: now)
        if summary.focusWindowPattern.preferredWindow == nowBucket, summary.focusWindowPattern.confidence != .low {
            fitScore += 0.16
        }
        if summary.driftTriggers.contains(where: { $0.window == nowBucket && $0.occurrenceCount >= 2 }) {
            fitScore -= 0.18
        }
        fitScore = roundToTwoDecimals(min(max(fitScore, 0.05), 0.95))

        return LearnedStepInsight(
            fitScore: fitScore,
            confidence: summary.historicalFit.confidence,
            whyNow: whyNow(
                for: goal,
                summary: summary,
                underrepresented: snapshot.underrepresentedGoalSignals.first(where: { $0.goalID == goal.id }),
                nowBucket: nowBucket
            )
        )
    }
}

private extension LearningAnticipationService {
    func summary(
        for goal: Goal,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        now: Date
    ) -> GoalLearningSummary {
        let stepIDs = Set(goal.plan?.sections.flatMap(\.steps).map(\.id) ?? [])
        let goalEvidence = evidence.filter { $0.goalID == goal.id && isPositiveEvidence($0) }
        let goalFeedback = feedback.filter { stepIDs.contains($0.stepID) && isFriction($0) }
        let positiveBuckets = Dictionary(grouping: goalEvidence, by: { bucket(forTimestamp: $0.capturedAt) })
        let frictionBuckets = Dictionary(grouping: goalFeedback, by: { bucket(forTimestamp: $0.base.occurredAt) })

        return GoalLearningSummary(
            goalID: goal.id,
            energyFitPattern: energyFit(from: goalEvidence, frictionCount: goalFeedback.count),
            focusWindowPattern: focusWindowFit(positiveBuckets: positiveBuckets, frictionBuckets: frictionBuckets),
            historicalFit: historicalFit(
                evidenceCount: goalEvidence.count,
                frictionCount: goalFeedback.count,
                focusWindowPattern: focusWindowFit(positiveBuckets: positiveBuckets, frictionBuckets: frictionBuckets)
            ),
            driftTriggers: driftPatterns(goalID: goal.id, feedback: goalFeedback),
            timelineRisk: timelineRisk(for: goal, evidence: goalEvidence, feedback: goalFeedback, now: now),
            whyNow: nil
        )
    }

    func energyFit(from evidence: [ProgressEvidence], frictionCount: Int) -> EnergyFitPattern {
        guard evidence.count >= 3 else {
            return EnergyFitPattern(
                preferredSessionLength: nil,
                supportingEvidenceCount: evidence.count,
                frictionEventCount: frictionCount,
                confidence: .low,
                summary: "Observed history is still limited, so Ambitions is not claiming a session-length fit yet."
            )
        }

        let averageMinutes = Double(evidence.compactMap(\.minutesInvested).reduce(0, +)) / Double(max(evidence.count, 1))
        let preferred: LearningSessionLength
        switch averageMinutes {
        case ..<31:
            preferred = .short
        case ..<61:
            preferred = .medium
        default:
            preferred = .long
        }
        return EnergyFitPattern(
            preferredSessionLength: preferred,
            supportingEvidenceCount: evidence.count,
            frictionEventCount: frictionCount,
            confidence: .high,
            summary: "\(preferred.rawValue.capitalized) focused passes have the strongest observed fit."
        )
    }

    func focusWindowFit(
        positiveBuckets: [FocusWindowBucket?: [ProgressEvidence]],
        frictionBuckets: [FocusWindowBucket?: [GoalFeedbackEvent]]
    ) -> FocusWindowPattern {
        let positiveCount = positiveBuckets.values.reduce(0) { $0 + $1.count }
        let frictionCount = frictionBuckets.values.reduce(0) { $0 + $1.count }
        guard positiveCount >= 3 else {
            return FocusWindowPattern(
                preferredWindow: nil,
                supportingEvidenceCount: positiveCount,
                frictionEventCount: frictionCount,
                confidence: .low,
                summary: "Observed history is still limited, so Ambitions is not claiming a focus window yet."
            )
        }

        let ranked = [FocusWindowBucket.morning, .afternoon, .evening]
            .map { bucket -> (FocusWindowBucket, Int) in
                let positives = positiveBuckets[bucket]?.count ?? 0
                let frictions = frictionBuckets[bucket]?.count ?? 0
                return (bucket, positives - frictions)
            }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 { return lhs.0.rawValue < rhs.0.rawValue }
                return lhs.1 > rhs.1
            }

        guard let best = ranked.first, best.1 > 0 else {
            return FocusWindowPattern(
                preferredWindow: nil,
                supportingEvidenceCount: positiveCount,
                frictionEventCount: frictionCount,
                confidence: .low,
                summary: "Observed completions and friction are too mixed to claim a strong focus window."
            )
        }

        return FocusWindowPattern(
            preferredWindow: best.0,
            supportingEvidenceCount: positiveCount,
            frictionEventCount: frictionCount,
            confidence: best.1 >= 2 ? .high : .medium,
            summary: "\(best.0.rawValue.capitalized) attempts have landed more often than other observed windows."
        )
    }

    func historicalFit(
        evidenceCount: Int,
        frictionCount: Int,
        focusWindowPattern: FocusWindowPattern
    ) -> HistoricalFitSignal {
        guard evidenceCount + frictionCount >= 3 else {
            return HistoricalFitSignal(
                score: 0.5,
                confidence: .low,
                supportingEvidenceCount: evidenceCount,
                frictionEventCount: frictionCount,
                summary: "Observed history is still limited, so Ambitions is falling back to current heuristics."
            )
        }

        let ratio = Double(evidenceCount) / Double(max(evidenceCount + frictionCount, 1))
        let adjusted = roundToTwoDecimals(min(max(ratio + (focusWindowPattern.preferredWindow == nil ? 0 : 0.08), 0.05), 0.95))
        let descriptor = adjusted >= 0.7 ? "strong" : (adjusted <= 0.35 ? "low" : "mixed")
        return HistoricalFitSignal(
            score: adjusted,
            confidence: evidenceCount >= 3 ? .high : .medium,
            supportingEvidenceCount: evidenceCount,
            frictionEventCount: frictionCount,
            summary: "Recent completion fit is \(descriptor) in the observed history."
        )
    }

    func driftPatterns(goalID: String, feedback: [GoalFeedbackEvent]) -> [DriftTriggerPattern] {
        let grouped = Dictionary(grouping: feedback.compactMap { event -> (CauseOfDrift, FocusWindowBucket?)? in
            guard let cause = event.causeOfDrift else { return nil }
            return (cause, bucket(forTimestamp: event.base.occurredAt))
        }, by: { "\($0.0.rawValue)|\($0.1?.rawValue ?? "none")" })

        return grouped.compactMap { _, items -> DriftTriggerPattern? in
            guard let first = items.first, items.count >= 2 else { return nil }
            return DriftTriggerPattern(
                goalID: goalID,
                cause: first.0,
                window: first.1,
                occurrenceCount: items.count,
                summary: first.1.map { "Observed drift clusters in the \($0.rawValue)." } ?? "Observed drift is repeating without a stable window."
            )
        }
        .sorted { lhs, rhs in
            if lhs.occurrenceCount == rhs.occurrenceCount { return lhs.summary < rhs.summary }
            return lhs.occurrenceCount > rhs.occurrenceCount
        }
    }

    func timelineRisk(for goal: Goal, evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent], now: Date) -> TimelineRiskForecast {
        var risk: Double = 0.18
        var reasons: [String] = []

        if let due = parseDate(goal.timing.dueAt ?? goal.timing.targetBy ?? goal.timing.windowEnd) {
            let days = max(0, calendar.dateComponents([.day], from: now, to: due).day ?? 0)
            if days <= 3 {
                risk += 0.32
                reasons.append("The due window is close.")
            } else if days <= 7 {
                risk += 0.18
                reasons.append("The due window is approaching.")
            }
        }

        let delayCount = feedback.filter {
            if case .delayed = $0 { return true }
            return false
        }.count
        let skipCount = feedback.filter {
            if case .skipped = $0 { return true }
            return false
        }.count
        if delayCount + skipCount >= 2 {
            risk += 0.28
            reasons.append("Repeated delays or skips are compressing the remaining timeline.")
        }

        if let pathState = LifeGraphResolver.pathStateSummary(for: goal) {
            if pathState.blockedPrerequisites.isEmpty == false {
                risk += 0.2
                reasons.append("Path prerequisites are still blocked.")
            } else if pathState.readiness.gapCount > 0 {
                risk += 0.14
                reasons.append("Readiness gaps are still visible.")
            }
        }

        if evidence.isEmpty {
            risk += 0.08
            reasons.append("Recent visible evidence is still thin.")
        }

        let bounded = roundToTwoDecimals(min(max(risk, 0.05), 0.95))
        return TimelineRiskForecast(
            riskScore: bounded,
            confidence: (delayCount + skipCount >= 2 || reasons.count >= 2) ? .high : .medium,
            reasons: reasons.isEmpty ? ["The current timeline still looks manageable."] : reasons
        )
    }

    func underrepresentedSignals(
        goals: [Goal],
        evidence: [ProgressEvidence],
        summaries: [String: GoalLearningSummary],
        now: Date
    ) -> [UnderrepresentedGoalSignal] {
        let recentWindowStart = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let recentEvidence = evidence.filter { item in
            guard let captured = parseDate(item.capturedAt) else { return false }
            return captured >= recentWindowStart
        }
        let evidenceCounts = Dictionary(grouping: recentEvidence, by: \.goalID).mapValues(\.count)
        let average = goals.isEmpty ? 0 : Double(evidenceCounts.values.reduce(0, +)) / Double(max(goals.count, 1))

        return goals.compactMap { goal in
            let count = Double(evidenceCounts[goal.id] ?? 0)
            guard count < max(1, average * 0.5) else { return nil }
            guard let summary = summaries[goal.id], summary.timelineRisk.riskScore >= 0.3 else { return nil }
            let domain = LifeGraphResolver.primaryDomain(for: goal)
            let pressure = roundToTwoDecimals(min(0.95, max(0.35, 0.4 + (summary.timelineRisk.riskScore * 0.4) - (count * 0.08))))
            return UnderrepresentedGoalSignal(
                goalID: goal.id,
                domain: domain,
                pressureScore: pressure,
                summary: "\(domain.map { "\($0.rawValue.capitalized) work" } ?? "This goal") is underrepresented against the active portfolio."
            )
        }
        .sorted { lhs, rhs in
            if lhs.pressureScore == rhs.pressureScore { return lhs.goalID < rhs.goalID }
            return lhs.pressureScore > rhs.pressureScore
        }
    }

    func whyNow(
        for goal: Goal,
        summary: GoalLearningSummary,
        underrepresented: UnderrepresentedGoalSignal?,
        nowBucket: FocusWindowBucket?
    ) -> WhyNowExplanationMetadata {
        if summary.historicalFit.confidence != .low,
           summary.focusWindowPattern.preferredWindow == nowBucket {
            return WhyNowExplanationMetadata(
                conciseReason: "Recent completion fit is strongest in this window.",
                reasons: [summary.historicalFit.summary, summary.focusWindowPattern.summary]
            )
        }

        if let trigger = summary.driftTriggers.first(where: { $0.window == nowBucket }) {
            return WhyNowExplanationMetadata(
                conciseReason: "Observed drift often shows up in this window, so a smaller move now is safer.",
                reasons: [trigger.summary, summary.timelineRisk.reasons.first ?? "Timeline risk is rising."]
            )
        }

        if summary.timelineRisk.riskScore >= 0.65 {
            return WhyNowExplanationMetadata(
                conciseReason: "Timeline risk is rising, so protecting the path now matters.",
                reasons: Array(summary.timelineRisk.reasons.prefix(2))
            )
        }

        if let underrepresented {
            return WhyNowExplanationMetadata(
                conciseReason: "This goal is underrepresented in the recent portfolio.",
                reasons: [underrepresented.summary, summary.timelineRisk.reasons.first ?? "The current path still needs visible signal."]
            )
        }

        return WhyNowExplanationMetadata(
            conciseReason: "Observed history is still limited, so Ambitions is using the current plan shape.",
            reasons: [summary.historicalFit.summary]
        )
    }

    func isPositiveEvidence(_ evidence: ProgressEvidence) -> Bool {
        switch evidence.evidenceKind {
        case .stepCompleted, .habitCompletion, .habitMinimumVersion:
            return true
        case .habitQuickLog, .sessionLogged, .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
            return false
        }
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .delayed, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        case .completed, .edited, .tooEasy, .askedWhyThisMatters:
            return false
        }
    }

    func bucket(forTimestamp value: String) -> FocusWindowBucket? {
        guard let date = parseDate(value) else { return nil }
        return bucket(for: date)
    }

    func bucket(for date: Date) -> FocusWindowBucket {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<18:
            return .afternoon
        default:
            return .evening
        }
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return DomainTimestamp.date(from: value)
    }

    func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
