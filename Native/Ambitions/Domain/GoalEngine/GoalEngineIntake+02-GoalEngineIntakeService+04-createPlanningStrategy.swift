import Foundation

extension GoalEngineIntakeService {

    func createPlanningStrategy(id: IntakePlanningStrategyID) -> PlanningStrategy {
        switch id {
        case .routineBuilder:
            return PlanningStrategy(strategyKind: .cadence, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .recurringRoutine, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .learningPath:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .resources, .review], defaultStepType: .learningCheckpoint, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .discoveryMap:
            return PlanningStrategy(strategyKind: .exploratory, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .supportingWork, .review], defaultStepType: .explorationExperiment, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 5)
        case .stabilizationPath:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: false, maxActiveSteps: 2, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .observationPrompt, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 4)
        case .guidedSupport:
            return PlanningStrategy(strategyKind: .supportive, allowParallelSteps: true, maxActiveSteps: 3, preferredSectionOrder: [.supportingWork, .activeSteps, .review], defaultStepType: .supportAction, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .lightweightTracking:
            return PlanningStrategy(strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 2, preferredSectionOrder: [.overview, .activeSteps, .review], defaultStepType: .reflectionPrompt, autoGenerateReviewSection: true, preferShortSteps: true, revisitCadenceDays: 7)
        case .milestonePlan:
            return PlanningStrategy(strategyKind: .sequential, allowParallelSteps: true, maxActiveSteps: 4, preferredSectionOrder: [.overview, .activeSteps, .upcoming, .review], defaultStepType: .actionUnit, autoGenerateReviewSection: true, preferShortSteps: false, revisitCadenceDays: 7)
        }
    }


    func createProgressStrategy(id: IntakeProgressStrategyID) -> ProgressStrategy {
        switch id {
        case .learning:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .weightedRatio, targetStepCount: 4, targetEvidenceCount: 8, targetMinutes: 240, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .exploration:
            return ProgressStrategy(metricKind: .observationLog, rollupMethod: .sum, targetStepCount: 4, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .maintenance:
            return ProgressStrategy(metricKind: .streak, rollupMethod: .streakLength, targetStepCount: nil, targetEvidenceCount: 5, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        case .delegatedSupport:
            return ProgressStrategy(metricKind: .evidenceCount, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 4, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: true, countsSupportGoals: true)
        case .observationalProgress:
            return ProgressStrategy(metricKind: .confidenceGain, rollupMethod: .latest, targetStepCount: 3, targetEvidenceCount: 6, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: true)
        case .timedExecution:
            return ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: 5, targetEvidenceCount: nil, targetMinutes: 300, supportsUntimedProgress: false, countsChildGoals: true, countsSupportGoals: true)
        case .untimedGrowth:
            return ProgressStrategy(metricKind: .timeInvested, rollupMethod: .ratio, targetStepCount: 4, targetEvidenceCount: nil, targetMinutes: 240, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        }
    }


    func classified<Value: Codable & Sendable & Equatable>(_ value: Value, confidence: Double, reason: String) -> ClassifiedValue<Value> {
        let bounded = max(0, min(1, confidence))
        let label: ClassificationConfidence = bounded >= 0.8 ? .high : (bounded >= 0.55 ? .medium : .low)
        return ClassifiedValue(value: value, metadata: InferenceMetadata(source: .derivedContract, inferred: true, confidence: bounded, label: label, reason: reason))
    }


    func firstMatch(in text: String, pattern: String) -> String? {
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }


    func deriveWindow(from text: String, referenceNow: String?) -> (start: String, end: String)? {
        let year = referenceYear(from: referenceNow)
        if text.contains("this summer") { return ("\(year)-06-01", "\(year)-08-31") }
        if text.contains("this fall") { return ("\(year)-09-01", "\(year)-11-30") }
        if text.contains("this quarter") { return ("\(year)-04-01", "\(year)-06-30") }
        if text.contains("this month") { return ("\(year)-04-01", "\(year)-04-30") }
        if text.contains("this week") { return ("\(year)-04-14", "\(year)-04-20") }
        return nil
    }


    func referenceYear(from referenceNow: String?) -> Int {
        guard let referenceNow, let date = ISO8601DateFormatter().date(from: referenceNow) else {
            return Calendar(identifier: .gregorian).component(.year, from: Date())
        }
        return Calendar(identifier: .gregorian).component(.year, from: date)
    }
}
