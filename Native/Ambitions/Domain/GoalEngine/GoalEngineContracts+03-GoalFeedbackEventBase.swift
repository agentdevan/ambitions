import Foundation

struct GoalFeedbackEventBase: Codable, Sendable, Equatable {
    static let schemaVersion = "goal_feedback_event.v1"

    let id: String
    let stepID: String
    let occurredAt: String
    let note: String?
}

enum GoalFeedbackEvent: Sendable, Equatable {
    case completed(base: GoalFeedbackEventBase, actualDuration: Int?, effortLevel: GoalFeedbackEffortLevel, confidenceDelta: Double?)
    case skipped(base: GoalFeedbackEventBase, reasonCode: GoalStepSkipReasonCode)
    case delayed(base: GoalFeedbackEventBase, timingAdjustment: GoalTimingAdjustment, date: String?)
    case edited(base: GoalFeedbackEventBase, rewrittenText: String)
    case confused(base: GoalFeedbackEventBase, confusionType: GoalConfusionType)
    case tooBig(base: GoalFeedbackEventBase)
    case tooEasy(base: GoalFeedbackEventBase)
    case notRelevant(base: GoalFeedbackEventBase)
    case askedForSmallerVersion(base: GoalFeedbackEventBase)
    case askedWhyThisMatters(base: GoalFeedbackEventBase)

    var base: GoalFeedbackEventBase {
        switch self {
        case let .completed(base, _, _, _),
             let .skipped(base, _),
             let .delayed(base, _, _),
             let .edited(base, _),
             let .confused(base, _),
             let .tooBig(base),
             let .tooEasy(base),
             let .notRelevant(base),
             let .askedForSmallerVersion(base),
             let .askedWhyThisMatters(base):
            return base
        }
    }

    var stepID: String { base.stepID }

    var kind: GoalHistoryEventKind {
        switch self {
        case .completed:
            return .completed
        case .skipped:
            return .skipped
        case .delayed:
            return .delayed
        case .edited:
            return .edited
        case .confused:
            return .confused
        case .tooBig:
            return .tooBig
        case .tooEasy:
            return .tooEasy
        case .notRelevant:
            return .notRelevant
        case .askedForSmallerVersion:
            return .askedForSmallerVersion
        case .askedWhyThisMatters:
            return .askedWhyThisMatters
        }
    }

    var causeOfDrift: CauseOfDrift? {
        switch self {
        case let .skipped(_, reasonCode):
            switch reasonCode {
            case .avoidance, .tooHard:
                return .avoidance
            case .blockedExternal:
                return .externalDependency
            case .notReady:
                return .notReady
            case .notNow:
                return .timingPressure
            case .forgot:
                return .missingContext
            }
        case .delayed:
            return .timingPressure
        case let .confused(_, confusionType):
            switch confusionType {
            case .unclearAction, .unclearWhy:
                return .unclearAction
            case .missingContext:
                return .missingContext
            case .missingEvidence:
                return .missingEvidence
            }
        case .tooBig, .askedForSmallerVersion:
            return .oversizedStep
        case .notRelevant:
            return .wrongPlanFit
        case .completed, .edited, .tooEasy, .askedWhyThisMatters:
            return nil
        }
    }
}

extension GoalFeedbackEvent {
    var searchTitle: String {
        switch self {
        case .completed:
            return "Completed step feedback"
        case .skipped:
            return "Skipped step feedback"
        case .delayed:
            return "Delayed step feedback"
        case .edited:
            return "Edited step feedback"
        case .confused:
            return "Confusion feedback"
        case .tooBig:
            return "Too big feedback"
        case .tooEasy:
            return "Too easy feedback"
        case .notRelevant:
            return "Not relevant feedback"
        case .askedForSmallerVersion:
            return "Asked for smaller version"
        case .askedWhyThisMatters:
            return "Asked why this matters"
        }
    }

    var searchSummary: String {
        switch self {
        case let .completed(_, actualDuration, effortLevel, confidenceDelta):
            return [
                "Completed",
                actualDuration.map { "\($0) min" },
                effortLevel.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                confidenceDelta.map { "confidence \($0)" }
            ]
            .compactMap { $0 }
            .joined(separator: " · ")
        case let .skipped(_, reasonCode):
            return "Skipped because \(reasonCode.rawValue.replacingOccurrences(of: "_", with: " "))."
        case let .delayed(_, timingAdjustment, date):
            return [
                "Delayed",
                timingAdjustment.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                date
            ]
            .compactMap { $0 }
            .joined(separator: " · ")
        case let .edited(_, rewrittenText):
            return rewrittenText
        case let .confused(_, confusionType):
            return "Confused about \(confusionType.rawValue.replacingOccurrences(of: "_", with: " "))."
        case .tooBig:
            return "Too big to start as written."
        case .tooEasy:
            return "Too easy to matter as written."
        case .notRelevant:
            return "Not relevant to the owning goal."
        case .askedForSmallerVersion:
            return "Asked for a smaller version."
        case .askedWhyThisMatters:
            return "Asked why this matters."
        }
    }

    var searchFreshness: YouMemoryFreshness {
        .current
    }
}

struct GoalFeedbackSignalSnapshot: Codable, Sendable, Equatable {
    enum ConfidenceTrend: String, Codable, Sendable {
        case improving
        case eroding
        case flat
    }

    let avoidanceCount: Int
    let tooBigCount: Int
    let confusedCount: Int
    let notRelevantCount: Int
    let delayedCount: Int
    let askedWhyCount: Int
    let confidenceScore: Double
    let confidenceTrend: ConfidenceTrend
    let frictionScore: Double
    let executionMode: ExecutionMode
    let narrativeMomentum: NarrativeMomentum
    let primaryCauseOfDrift: CauseOfDrift?
    let recommendationConfidence: RecommendationConfidence
    let toneDriftDetected: Bool
    let rigidityDetected: Bool
}

struct WhyStepMattersExplanationHook: Codable, Sendable, Equatable {
    let prompt: String
    let explanation: String
}

enum GoalReplanRecommendationKind: String, Codable, Sendable {
    case noChange = "no_change"
    case reviseStep = "revise_step"
    case shrinkStep = "shrink_step"
    case relaxTiming = "relax_timing"
    case requestReclarification = "request_reclarification"
    case adjustPlanTone = "adjust_plan_tone"
    case suggestMicroStep = "suggest_micro_step"
    case suggestAlternatePath = "suggest_alternate_path"
}

struct GoalEngineOrchestrationContext: Codable, Sendable, Equatable {
    let goalID: String?
    let actorName: String?
    let preferredPlanningStrictness: GoalPlanningStrictness
    let goalOwnerRole: String?
    let supportScope: GoalSupportScope?
    let deadlineHints: [String]
    let existingGoalReferences: [String]
    let sourceScreen: String?
    let sourceFlow: String?
    let clarifiedFields: [MissingFieldKey: String]
    let referenceNow: String?
    let knowledgeContext: GoalUnderstandingKnowledgeContext?
    let evidence: [ProgressEvidence]
    let feedbackHistory: [GoalFeedbackEvent]

    init(
        goalID: String? = nil,
        actorName: String? = nil,
        preferredPlanningStrictness: GoalPlanningStrictness = .balanced,
        goalOwnerRole: String? = nil,
        supportScope: GoalSupportScope? = nil,
        deadlineHints: [String] = [],
        existingGoalReferences: [String] = [],
        sourceScreen: String? = nil,
        sourceFlow: String? = nil,
        clarifiedFields: [MissingFieldKey: String] = [:],
        referenceNow: String? = nil,
        knowledgeContext: GoalUnderstandingKnowledgeContext? = nil,
        evidence: [ProgressEvidence] = [],
        feedbackHistory: [GoalFeedbackEvent] = []
    ) {
        self.goalID = goalID
        self.actorName = actorName
        self.preferredPlanningStrictness = preferredPlanningStrictness
        self.goalOwnerRole = goalOwnerRole
        self.supportScope = supportScope
        self.deadlineHints = deadlineHints
        self.existingGoalReferences = existingGoalReferences
        self.sourceScreen = sourceScreen
        self.sourceFlow = sourceFlow
        self.clarifiedFields = clarifiedFields
        self.referenceNow = referenceNow
        self.knowledgeContext = knowledgeContext
        self.evidence = evidence
        self.feedbackHistory = feedbackHistory
    }

    enum CodingKeys: String, CodingKey {
        case goalID
        case actorName
        case preferredPlanningStrictness
        case goalOwnerRole
        case supportScope
        case deadlineHints
        case existingGoalReferences
        case sourceScreen
        case sourceFlow
        case clarifiedFields
        case referenceNow
        case knowledgeContext
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        goalID = try container.decodeIfPresent(String.self, forKey: .goalID)
        actorName = try container.decodeIfPresent(String.self, forKey: .actorName)
        preferredPlanningStrictness = try container.decodeIfPresent(GoalPlanningStrictness.self, forKey: .preferredPlanningStrictness) ?? .balanced
        goalOwnerRole = try container.decodeIfPresent(String.self, forKey: .goalOwnerRole)
        supportScope = try container.decodeIfPresent(GoalSupportScope.self, forKey: .supportScope)
        deadlineHints = try container.decodeIfPresent([String].self, forKey: .deadlineHints) ?? []
        existingGoalReferences = try container.decodeIfPresent([String].self, forKey: .existingGoalReferences) ?? []
        sourceScreen = try container.decodeIfPresent(String.self, forKey: .sourceScreen)
        sourceFlow = try container.decodeIfPresent(String.self, forKey: .sourceFlow)
        clarifiedFields = try container.decodeIfPresent([MissingFieldKey: String].self, forKey: .clarifiedFields) ?? [:]
        referenceNow = try container.decodeIfPresent(String.self, forKey: .referenceNow)
        knowledgeContext = try container.decodeIfPresent(GoalUnderstandingKnowledgeContext.self, forKey: .knowledgeContext)
        evidence = []
        feedbackHistory = []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(goalID, forKey: .goalID)
        try container.encodeIfPresent(actorName, forKey: .actorName)
        try container.encode(preferredPlanningStrictness, forKey: .preferredPlanningStrictness)
        try container.encodeIfPresent(goalOwnerRole, forKey: .goalOwnerRole)
        try container.encodeIfPresent(supportScope, forKey: .supportScope)
        try container.encode(deadlineHints, forKey: .deadlineHints)
        try container.encode(existingGoalReferences, forKey: .existingGoalReferences)
        try container.encodeIfPresent(sourceScreen, forKey: .sourceScreen)
        try container.encodeIfPresent(sourceFlow, forKey: .sourceFlow)
        try container.encode(clarifiedFields, forKey: .clarifiedFields)
        try container.encodeIfPresent(referenceNow, forKey: .referenceNow)
        try container.encodeIfPresent(knowledgeContext, forKey: .knowledgeContext)
    }
}

struct GoalEngineOrchestrationInputSnapshot: Codable, Sendable, Equatable {
    let rawInput: String
    let normalizedInput: String
}
