import Foundation

enum FocusWindowBucket: String, Sendable, Equatable {
    case morning
    case afternoon
    case evening
}

enum LearningSessionLength: String, Sendable, Equatable {
    case short
    case medium
    case long
}

struct EnergyFitPattern: Sendable, Equatable {
    let preferredSessionLength: LearningSessionLength?
    let supportingEvidenceCount: Int
    let frictionEventCount: Int
    let confidence: RecommendationConfidence
    let summary: String
}

struct FocusWindowPattern: Sendable, Equatable {
    let preferredWindow: FocusWindowBucket?
    let supportingEvidenceCount: Int
    let frictionEventCount: Int
    let confidence: RecommendationConfidence
    let summary: String
}

struct HistoricalFitSignal: Sendable, Equatable {
    let score: Double
    let confidence: RecommendationConfidence
    let supportingEvidenceCount: Int
    let frictionEventCount: Int
    let summary: String
}

struct UnderrepresentedGoalSignal: Sendable, Equatable {
    let goalID: String
    let domain: LifeDomainKey?
    let pressureScore: Double
    let summary: String
}

struct DriftTriggerPattern: Sendable, Equatable {
    let goalID: String
    let cause: CauseOfDrift
    let window: FocusWindowBucket?
    let occurrenceCount: Int
    let summary: String
}

struct TimelineRiskForecast: Sendable, Equatable {
    let riskScore: Double
    let confidence: RecommendationConfidence
    let reasons: [String]

    init(riskScore: Double, confidence: RecommendationConfidence, reasons: [String]) {
        self.riskScore = min(max(riskScore, 0), 1)
        self.confidence = confidence
        self.reasons = Array(reasons.prefix(3))
    }
}

struct WhyNowExplanationMetadata: Codable, Sendable, Equatable {
    let conciseReason: String
    let reasons: [String]

    init(conciseReason: String, reasons: [String]) {
        self.conciseReason = conciseReason
        self.reasons = Array(reasons.prefix(2))
    }
}

struct GoalLearningSummary: Sendable, Equatable {
    let goalID: String
    let energyFitPattern: EnergyFitPattern
    let focusWindowPattern: FocusWindowPattern
    let historicalFit: HistoricalFitSignal
    let driftTriggers: [DriftTriggerPattern]
    let timelineRisk: TimelineRiskForecast
    let whyNow: WhyNowExplanationMetadata?
}

struct LearnedStepInsight: Sendable, Equatable {
    let fitScore: Double
    let confidence: RecommendationConfidence
    let whyNow: WhyNowExplanationMetadata
}

struct LearningAnticipationSnapshot: Sendable, Equatable {
    let goalSummaries: [String: GoalLearningSummary]
    let underrepresentedGoalSignals: [UnderrepresentedGoalSignal]

    static let empty = LearningAnticipationSnapshot(goalSummaries: [:], underrepresentedGoalSignals: [])
}
