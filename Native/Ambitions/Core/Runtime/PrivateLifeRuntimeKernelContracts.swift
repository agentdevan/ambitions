import Foundation

protocol PrivateLifeRuntimeKernelContracting: Sendable {
    var boundary: PrivateLifeRuntimeBoundary { get }

    func evaluate(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionOutput
    func makeDecisionRecord(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionRecord?
}

struct PrivateLifeRuntimeKernelTraceContext: Sendable {
    let runtimeContext: RuntimeContextSnapshot
    let goalIntelligenceContext: RuntimeGoalIntelligenceContext?
    let lifeContextProjection: LifeContextRuntimeProjection?
    let goalText: String?

    init(
        runtimeContext: RuntimeContextSnapshot,
        goalIntelligenceContext: RuntimeGoalIntelligenceContext? = nil,
        lifeContextProjection: LifeContextRuntimeProjection? = nil,
        goalText: String? = nil
    ) {
        self.runtimeContext = runtimeContext
        self.goalIntelligenceContext = goalIntelligenceContext
        self.lifeContextProjection = lifeContextProjection
        self.goalText = goalText?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PrivateLifeRuntimeKernelDecisionInput: Sendable {
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let decisionKey: String
    let goalText: String?
    let recommendationTrace: RecommendationTrace?

    init(
        traceContext: PrivateLifeRuntimeKernelTraceContext,
        decisionKey: String,
        goalText: String? = nil,
        recommendationTrace: RecommendationTrace? = nil
    ) {
        self.traceContext = traceContext
        self.decisionKey = decisionKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.goalText = goalText?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recommendationTrace = recommendationTrace
    }
}

enum PrivateLifeRuntimeLifeContextReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case review
    case clarification
}

struct PrivateLifeRuntimeLifeContextEffect: Codable, Sendable, Equatable, Hashable {
    let readiness: PrivateLifeRuntimeLifeContextReadiness
    let goalText: String?
    let startHereTitle: String
    let startHereExplanation: String
    let cadence: String
    let urgency: String
    let milestone: String
    let pathwayLabels: [String]
    let sourceFreshnessStates: [String]
    let historyFactIDs: [String]
    let excludedHistoryFactIDs: [String]
    let excludedHistoryReasons: [String]
    let missingContextQuestionIDs: [String]
    let opportunityAnchorIDs: [String]
}

struct PrivateLifeRuntimeKernelDecisionRecord: Sendable {
    let id: String
    let decisionKey: String
    let goalText: String?
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let recommendationTrace: RecommendationTrace
    let personalizationFactorLedger: PersonalizationFactorLedger
    let boundary: PrivateLifeRuntimeBoundary
    let canDriveRecommendation: Bool
    let traceShape: String
    let lifeContextEffect: PrivateLifeRuntimeLifeContextEffect
    let lifeContextSignature: String

    var source: RecommendationTraceSource {
        recommendationTrace.source
    }

    var reason: RecommendationTraceReason {
        recommendationTrace.reason
    }

    var fit: RecommendationTraceFit {
        recommendationTrace.fit
    }

    var uncertainty: RecommendationTraceUncertainty {
        recommendationTrace.uncertainty
    }

    var control: RecommendationTraceControl {
        recommendationTrace.control
    }

    var receiptBehavior: RecommendationTraceReceiptBehavior {
        recommendationTrace.receiptBehavior
    }
}

struct PrivateLifeRuntimeKernelDecisionOutput: Sendable, Equatable {
    let decisionID: String
    let boundary: PrivateLifeRuntimeBoundary
    let canDriveRecommendation: Bool
    let hasRecommendationTrace: Bool
    let traceShape: String?
    let recordID: String?
    let personalizationFactorLedger: PersonalizationFactorLedger
    let lifeContextEffect: PrivateLifeRuntimeLifeContextEffect
    let lifeContextSignature: String

    var isLocalOnly: Bool {
        boundary.isLocalOnly
    }
}
