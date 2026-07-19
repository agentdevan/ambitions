import Foundation

let planningRuleCounterfactualDiffSchemaVersion = "planning_rule_counterfactual_diff.native.v1"

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
        inference: [String: InferenceMetadata] = [:],
        pathStateSummary: LifePathStateSummary? = nil,
        sharedLifeSummary: SharedLifeGoalSummary? = nil
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
        let pathRiskCount = pathRiskCount(from: pathStateSummary)
        let sharedLifeRiskCount = sharedLifeRiskCount(from: sharedLifeSummary)
        let score = feasibilityScore(
            pressure: pressure,
            fragility: fragility,
            assumptionsCount: assumptionsCount,
            warningCount: warningCount,
            confidenceInput: confidenceInput,
            incompleteSteps: incompleteSteps,
            pathRiskCount: pathRiskCount,
            sharedLifeRiskCount: sharedLifeRiskCount
        )
        let feasibility = feasibilityLevel(score: score, pressure: pressure, fragility: fragility, pathRiskCount: pathRiskCount + sharedLifeRiskCount)

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
                fragility: fragility,
                pathStateSummary: pathStateSummary,
                sharedLifeSummary: sharedLifeSummary
            )
        )
    }

    func pressureLevel(draft: GoalDraft, incompleteSteps: Int) -> PlanningPressureLevel {
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

    func effortPosture(draft: GoalDraft, pressure: PlanningPressureLevel, assumptionsCount: Int) -> PlanningEffortPosture {
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

    func fragilityLevel(
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

    func feasibilityScore(
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel,
        assumptionsCount: Int,
        warningCount: Int,
        confidenceInput: Double,
        incompleteSteps: Int,
        pathRiskCount: Int,
        sharedLifeRiskCount: Int
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
        let raw = confidenceInput - pressurePenalty - fragilityPenalty - Double(assumptionsCount) * 0.06 - Double(warningCount) * 0.05 - Double(max(incompleteSteps - 8, 0)) * 0.02 - Double(pathRiskCount) * 0.05 - Double(sharedLifeRiskCount) * 0.04
        return (raw * 100).rounded() / 100
    }

    func feasibilityLevel(
        score: Double,
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel,
        pathRiskCount: Int
    ) -> PlanningFeasibilityLevel {
        if score < 0.34 || (pressure == .high && fragility == .high) || pathRiskCount >= 2 { return .notBelievable }
        if score < 0.52 || fragility == .high { return .fragile }
        if score < 0.72 || pressure == .moderate || fragility == .moderate { return .tight }
        return .comfortable
    }

    func reasons(
        draft: GoalDraft,
        incompleteSteps: Int,
        assumptionsCount: Int,
        warningCount: Int,
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel,
        pathStateSummary: LifePathStateSummary?,
        sharedLifeSummary: SharedLifeGoalSummary?
    ) -> [String] {
        var output: [String] = []
        if let pathStateSummary {
            if let prerequisite = pathStateSummary.blockedPrerequisites.first {
                output.append("Path prerequisites are still blocking the current stage: \(prerequisite.title).")
            } else if let gap = pathStateSummary.readiness.gapSignals.first {
                output.append("Readiness gaps are still visible for the active path stage: \(gap.title).")
            }
        }
        if pressure == .high {
            output.append("Deadline pressure is high for the visible step count.")
        } else if draft.timing.tempo == .untimed {
            output.append("The plan is untimed, so pressure stays low.")
        } else {
            output.append("\(incompleteSteps) visible step\(incompleteSteps == 1 ? "" : "s") remain in the current plan.")
        }
        if let sharedLifeSummary, sharedLifeSummary.pressureScore >= 0.6 {
            output.append(sharedLifeSummary.reasons.first ?? "Shared responsibilities are materially shaping the plan.")
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

    func pathRiskCount(from pathStateSummary: LifePathStateSummary?) -> Int {
        guard let pathStateSummary else { return 0 }
        var count = 0
        if pathStateSummary.blockedPrerequisites.isEmpty == false {
            count += 1
        }
        if pathStateSummary.readiness.gapCount > 0 {
            count += 1
        }
        return count
    }

    func sharedLifeRiskCount(from sharedLifeSummary: SharedLifeGoalSummary?) -> Int {
        guard let sharedLifeSummary else { return 0 }
        var count = 0
        if sharedLifeSummary.careContextActive {
            count += 1
        }
        if sharedLifeSummary.pressureScore >= 0.7 || sharedLifeSummary.coordinationSignals.contains(where: \.isTimed) {
            count += 1
        }
        return count
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
}

struct PlanningNextStepCandidate: Codable, Sendable, Equatable {
    let goalID: String
    let stepID: String
    let score: Double
    let timingKey: String
    let evaluation: PlanningEvaluation
    let learnedFitScore: Double?
    let whyNow: WhyNowExplanationMetadata?
    let timelineRiskScore: Double?
    let energyFit: PlanningEnergyFitSummary?
    let energyLearning: PlanningEnergyLearningSummary?
    let ruleTrace: PlanningRuleTrace?
}

struct PlanningRuleTrace: Codable, Sendable, Equatable, Hashable {
    let id: String
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let contextVector: PlanningRuleContextVector
    let ruleReasons: [String]
    let fallbackReasonIDs: [String]
    let confidence: RecommendationConfidence
    let explanationSummary: String
    let controlVisibility: String
    let inspectionSurfaceTitle: String
    let localOnly: Bool

    var localFitLabel: String {
        [
            contextVector.timingFit,
            contextVector.feasibilityLevel.rawValue,
            contextVector.fragilityLevel.rawValue,
            contextVector.activeStepState.rawValue
        ]
        .joined(separator: "|")
    }
}

struct PlanningRuleContextVector: Codable, Sendable, Equatable, Hashable {
    let goalMode: GoalMode
    let timingFit: String
    let feasibilityLevel: PlanningFeasibilityLevel
    let fragilityLevel: PlanningFragilityLevel
    let activeStepState: StepLifecycleState
    let hasIncompleteDependencies: Bool
    let learnedFitScore: Double?
    let timelineRiskScore: Double?
    let energyLearningAdjustment: Double?
    let sharedLifePressureScore: Double?
    let preferredShortSteps: Bool
    let reviewCadenceDays: Int
}

struct PlanningNextStepSelection: Sendable, Equatable {
    let goal: Goal
    let step: Step
    let candidate: PlanningNextStepCandidate
}
