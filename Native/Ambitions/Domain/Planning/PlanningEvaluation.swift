import Foundation

enum PlanningFeasibilityLevel: String, Codable, Sendable {
    case comfortable
    case tight
    case fragile
    case notBelievable = "not_believable"
}

enum PlanningPressureLevel: String, Codable, Sendable {
    case low
    case moderate
    case high
}

enum PlanningFragilityLevel: String, Codable, Sendable {
    case low
    case moderate
    case high
}

enum PlanningEffortPosture: String, Codable, Sendable {
    case gentle
    case steady
    case push
}

struct PlanningEvaluation: Codable, Sendable, Equatable {
    static let schemaVersion = "planning_evaluation.v1"

    let schemaVersion: String
    let feasibilityScore: Double
    let feasibilityLevel: PlanningFeasibilityLevel
    let recommendationConfidence: RecommendationConfidence
    let pressureLevel: PlanningPressureLevel
    let fragilityLevel: PlanningFragilityLevel
    let effortPosture: PlanningEffortPosture
    let reasons: [String]

    init(
        schemaVersion: String = PlanningEvaluation.schemaVersion,
        feasibilityScore: Double,
        feasibilityLevel: PlanningFeasibilityLevel,
        recommendationConfidence: RecommendationConfidence,
        pressureLevel: PlanningPressureLevel,
        fragilityLevel: PlanningFragilityLevel,
        effortPosture: PlanningEffortPosture,
        reasons: [String]
    ) {
        self.schemaVersion = schemaVersion
        self.feasibilityScore = feasibilityScore
        self.feasibilityLevel = feasibilityLevel
        self.recommendationConfidence = recommendationConfidence
        self.pressureLevel = pressureLevel
        self.fragilityLevel = fragilityLevel
        self.effortPosture = effortPosture
        self.reasons = Array(reasons.prefix(3))
    }
}

struct PlanningEvaluator: Sendable {
    func evaluate(
        draft: GoalDraft,
        plan: GoalPlan,
        inference: [String: InferenceMetadata] = [:]
    ) -> PlanningEvaluation {
        let steps = plan.sections.flatMap(\.steps)
        let incompleteSteps = steps.filter { $0.state != .completed && $0.state != .cancelled }.count
        let warningCount = plan.lint.issues.filter { $0.severity != .info }.count
        let assumptionsCount = plan.assumptions.count
        let confidenceInput = inference.isEmpty
            ? 0.78
            : inference.values.map(\.confidence).reduce(0, +) / Double(max(inference.count, 1))

        let pressure = pressureLevel(draft: draft, incompleteSteps: incompleteSteps)
        let effort = effortPosture(draft: draft, pressure: pressure, assumptionsCount: assumptionsCount)
        let fragility = fragilityLevel(assumptionsCount: assumptionsCount, warningCount: warningCount, pressure: pressure, confidenceInput: confidenceInput)
        let score = feasibilityScore(
            pressure: pressure,
            fragility: fragility,
            assumptionsCount: assumptionsCount,
            warningCount: warningCount,
            confidenceInput: confidenceInput,
            incompleteSteps: incompleteSteps
        )
        let feasibility = feasibilityLevel(score: score, pressure: pressure, fragility: fragility)

        return PlanningEvaluation(
            feasibilityScore: score,
            feasibilityLevel: feasibility,
            recommendationConfidence: RecommendationConfidence.label(for: confidenceInput - Double(assumptionsCount) * 0.08 - Double(warningCount) * 0.06),
            pressureLevel: pressure,
            fragilityLevel: fragility,
            effortPosture: effort,
            reasons: reasons(
                draft: draft,
                incompleteSteps: incompleteSteps,
                assumptionsCount: assumptionsCount,
                warningCount: warningCount,
                pressure: pressure,
                fragility: fragility
            )
        )
    }

    private func pressureLevel(draft: GoalDraft, incompleteSteps: Int) -> PlanningPressureLevel {
        switch draft.timing.tempo {
        case .deadlineBased:
            guard let due = date(from: draft.timing.dueAt ?? draft.timing.targetBy ?? draft.timing.windowEnd),
                  let reference = DomainTimestamp.date(from: draft.timing.startsOn ?? "") ?? date(from: draft.timing.suggestedNextAt ?? "") else {
                return incompleteSteps >= 6 ? .high : .moderate
            }
            let days = Calendar(identifier: .gregorian).dateComponents([.day], from: reference, to: due).day ?? 0
            if days <= 7 || incompleteSteps >= max(6, days / 2) { return .high }
            if days <= 21 || incompleteSteps >= 4 { return .moderate }
            return .low
        case .targetWindow:
            return incompleteSteps >= 6 ? .moderate : .low
        case .ongoing:
            return incompleteSteps >= 5 ? .moderate : .low
        case .untimed:
            return .low
        }
    }

    private func effortPosture(draft: GoalDraft, pressure: PlanningPressureLevel, assumptionsCount: Int) -> PlanningEffortPosture {
        if [.learning, .exploration, .recovery, .delegatedSupport].contains(draft.mode), pressure != .high {
            return .gentle
        }
        if assumptionsCount > 0 {
            return .gentle
        }
        switch pressure {
        case .low:
            return .steady
        case .moderate:
            return .steady
        case .high:
            return .push
        }
    }

    private func fragilityLevel(
        assumptionsCount: Int,
        warningCount: Int,
        pressure: PlanningPressureLevel,
        confidenceInput: Double
    ) -> PlanningFragilityLevel {
        if warningCount >= 2 || assumptionsCount >= 2 || (pressure == .high && confidenceInput < 0.75) {
            return .high
        }
        if warningCount > 0 || assumptionsCount > 0 || pressure == .high || confidenceInput < 0.7 {
            return .moderate
        }
        return .low
    }

    private func feasibilityScore(
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel,
        assumptionsCount: Int,
        warningCount: Int,
        confidenceInput: Double,
        incompleteSteps: Int
    ) -> Double {
        let pressurePenalty: Double = {
            switch pressure {
            case .low: return 0.04
            case .moderate: return 0.18
            case .high: return 0.34
            }
        }()
        let fragilityPenalty: Double = {
            switch fragility {
            case .low: return 0.04
            case .moderate: return 0.18
            case .high: return 0.34
            }
        }()
        let raw = confidenceInput - pressurePenalty - fragilityPenalty - Double(assumptionsCount) * 0.06 - Double(warningCount) * 0.05 - Double(max(incompleteSteps - 8, 0)) * 0.02
        return (raw * 100).rounded() / 100
    }

    private func feasibilityLevel(
        score: Double,
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel
    ) -> PlanningFeasibilityLevel {
        if score < 0.34 || (pressure == .high && fragility == .high) { return .notBelievable }
        if score < 0.52 || fragility == .high { return .fragile }
        if score < 0.72 || pressure == .moderate || fragility == .moderate { return .tight }
        return .comfortable
    }

    private func reasons(
        draft: GoalDraft,
        incompleteSteps: Int,
        assumptionsCount: Int,
        warningCount: Int,
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel
    ) -> [String] {
        var output: [String] = []
        if pressure == .high {
            output.append("Deadline pressure is high for the visible step count.")
        } else if draft.timing.tempo == .untimed {
            output.append("The plan is untimed, so pressure stays low.")
        } else {
            output.append("\(incompleteSteps) visible step\(incompleteSteps == 1 ? "" : "s") remain in the current plan.")
        }
        if assumptionsCount > 0 {
            output.append("Starter assumptions reduce confidence.")
        }
        if warningCount > 0 {
            output.append("Plan lint found \(warningCount) risk signal\(warningCount == 1 ? "" : "s").")
        }
        if output.count < 2 {
            output.append(fragility == .low ? "No major fragility signals are present." : "Fragility is visible and should stay explicit.")
        }
        return output
    }

    private func date(from value: String?) -> Date? {
        guard let value else { return nil }
        if let full = DomainTimestamp.date(from: value) { return full }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}

struct PlanningNextStepCandidate: Codable, Sendable, Equatable {
    let goalID: String
    let stepID: String
    let score: Double
    let timingKey: String
    let evaluation: PlanningEvaluation
}

struct PlanningNextStepSelection: Sendable, Equatable {
    let goal: Goal
    let step: Step
    let candidate: PlanningNextStepCandidate
}

struct PlanningNextStepSelector: Sendable {
    private let evaluator = PlanningEvaluator()

    func rankedSelections(goals: [Goal], now: Date) -> [PlanningNextStepSelection] {
        let activeGoals = goals.filter { $0.state == .active || $0.state == .paused }
        let selections = activeGoals.flatMap { goal -> [PlanningNextStepSelection] in
            guard let plan = goal.plan else { return [] }
            let draft = GoalDraft(
                schemaVersion: goal.schemaVersion,
                source: .derived,
                title: goal.title,
                summary: goal.summary,
                mode: goal.mode,
                relationshipKind: goal.relationshipKind,
                actor: goal.actor,
                parentGoalID: goal.parentGoalID,
                tags: goal.tags,
                timing: goal.timing,
                planningStrategy: goal.planningStrategy,
                progressStrategy: goal.progressStrategy
            )
            let evaluation = plan.evaluation ?? evaluator.evaluate(draft: draft, plan: plan)
            return plan.sections.flatMap(\.steps)
                .filter { $0.state != .completed && $0.state != .cancelled }
                .map { step in
                    PlanningNextStepSelection(
                        goal: goal,
                        step: step,
                        candidate: PlanningNextStepCandidate(
                            goalID: goal.id,
                            stepID: step.id,
                            score: score(goal: goal, step: step, evaluation: evaluation, now: now),
                            timingKey: timingKey(for: step.timing, goalMode: goal.mode),
                            evaluation: evaluation
                        )
                    )
                }
        }

        return selections.sorted { lhs, rhs in
            if lhs.candidate.score != rhs.candidate.score { return lhs.candidate.score > rhs.candidate.score }
            if lhs.candidate.timingKey != rhs.candidate.timingKey { return lhs.candidate.timingKey < rhs.candidate.timingKey }
            if lhs.goal.id != rhs.goal.id { return lhs.goal.id < rhs.goal.id }
            return lhs.step.id < rhs.step.id
        }
    }

    func bestSelection(goals: [Goal], now: Date) -> PlanningNextStepSelection? {
        rankedSelections(goals: goals, now: now).first
    }

    private func score(goal: Goal, step: Step, evaluation: PlanningEvaluation, now: Date) -> Double {
        var value = 0.5
        switch evaluation.feasibilityLevel {
        case .comfortable:
            value += 0.24
        case .tight:
            value += 0.16
        case .fragile:
            value += 0.08
        case .notBelievable:
            value -= 0.12
        }
        switch step.state {
        case .active:
            value += 0.16
        case .blocked:
            value -= 0.18
        case .planned, .completed, .cancelled:
            break
        }
        switch urgency(for: step.timing, now: now) {
        case .overdue:
            value += 0.18
        case .soon:
            value += 0.12
        case .normal:
            value += 0.04
        case .anytime:
            value += goal.mode == .learning || goal.mode == .exploration ? 0.03 : 0
        }
        if goal.mode == .delegatedSupport {
            value -= 0.04
        }
        return (value * 100).rounded() / 100
    }

    private enum SelectorUrgency {
        case overdue
        case soon
        case normal
        case anytime
    }

    private func urgency(for timing: GoalTiming, now: Date) -> SelectorUrgency {
        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return timing.tempo == .untimed ? .anytime : .normal
        }

        let delta = reference.timeIntervalSince(now)
        if delta < 0 { return .overdue }
        if delta <= 48 * 60 * 60 { return .soon }
        return .normal
    }

    private func timingKey(for timing: GoalTiming, goalMode: GoalMode? = nil) -> String {
        if goalMode == .delegatedSupport {
            return timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
        }
        return timing.dueAt ?? timing.targetBy ?? timing.windowStart ?? timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        if let date = DomainTimestamp.date(from: value) { return date }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}
