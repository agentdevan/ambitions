import Foundation

struct GoalEngineOrchestrationContextSnapshot: Codable, Sendable, Equatable {
    let goalID: String?
    let actorName: String?
    let preferredPlanningStrictness: GoalPlanningStrictness
    let goalOwnerRole: String?
    let supportScope: GoalSupportScope?
    let deadlineHints: [String]
    let existingGoalReferences: [String]
    let sourceScreen: String?
    let sourceFlow: String?
    let clarifiedFields: [String: String]
    let referenceNow: String?
    let knowledgeContext: GoalUnderstandingKnowledgeContext?
    let evidence: [ProgressEvidence]
    let feedbackHistory: [GoalFeedbackEvent]

    init(
        goalID: String?,
        actorName: String?,
        preferredPlanningStrictness: GoalPlanningStrictness,
        goalOwnerRole: String?,
        supportScope: GoalSupportScope?,
        deadlineHints: [String],
        existingGoalReferences: [String],
        sourceScreen: String?,
        sourceFlow: String?,
        clarifiedFields: [String: String],
        referenceNow: String?,
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
        preferredPlanningStrictness = try container.decode(GoalPlanningStrictness.self, forKey: .preferredPlanningStrictness)
        goalOwnerRole = try container.decodeIfPresent(String.self, forKey: .goalOwnerRole)
        supportScope = try container.decodeIfPresent(GoalSupportScope.self, forKey: .supportScope)
        deadlineHints = try container.decodeIfPresent([String].self, forKey: .deadlineHints) ?? []
        existingGoalReferences = try container.decodeIfPresent([String].self, forKey: .existingGoalReferences) ?? []
        sourceScreen = try container.decodeIfPresent(String.self, forKey: .sourceScreen)
        sourceFlow = try container.decodeIfPresent(String.self, forKey: .sourceFlow)
        clarifiedFields = try container.decodeIfPresent([String: String].self, forKey: .clarifiedFields) ?? [:]
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

struct GoalOrchestrationClarification: Codable, Sendable, Equatable {
    let readiness: PlanningReadiness
    let questions: [ClarificationQuestion]
    let missingFields: [MissingField]
    let contradictions: [GoalInputContradiction]
    let analysis: GoalClarificationAnalysis
}

struct GoalOrchestrationInferenceSnapshot: Codable, Sendable, Equatable {
    let mode: ClassifiedValue<GoalMode>
    let tempo: ClassifiedValue<GoalTempo>
    let relationshipKind: ClassifiedValue<GoalRelationshipKind>
    let executionOwnership: ClassifiedValue<ExecutionOwnership>
    let userRole: ClassifiedValue<UserExecutionRole>
    let strictDeadlinesAppropriate: ClassifiedValue<Bool>
    let planningStrategyID: ClassifiedValue<IntakePlanningStrategyID>
    let progressStrategyID: ClassifiedValue<IntakeProgressStrategyID>
    let actorDisplayName: String
    let actorRoleLabel: String?
    let timing: GoalTiming
}

struct GoalOrchestrationPlannerMetadata: Codable, Sendable, Equatable {
    let attempted: Bool
    let resultKind: GoalPlannerResultKind?
    let blockers: [GoalPlanningBlocker]
    let lint: PlanLintResult?
    let evaluation: PlanningEvaluation?

    init(
        attempted: Bool,
        resultKind: GoalPlannerResultKind?,
        blockers: [GoalPlanningBlocker],
        lint: PlanLintResult?,
        evaluation: PlanningEvaluation? = nil
    ) {
        self.attempted = attempted
        self.resultKind = resultKind
        self.blockers = blockers
        self.lint = lint
        self.evaluation = evaluation
    }
}

struct GoalOrchestrationReasoningMetadata: Codable, Sendable, Equatable {
    let readiness: PlanningReadiness
    let clarificationNeeded: Bool
    let starterPlanSafe: Bool
    let missingFields: [MissingField]
    let contradictions: [GoalInputContradiction]
    let assumptions: [PlanAssumption]
    let inference: [String: InferenceMetadata]
}

struct GoalOrchestrationMetadata: Codable, Sendable, Equatable {
    let input: GoalEngineOrchestrationInputSnapshot
    let context: GoalEngineOrchestrationContextSnapshot
    let inference: GoalOrchestrationInferenceSnapshot
    let clarification: GoalOrchestrationClarification
    let planner: GoalOrchestrationPlannerMetadata
    let reasoning: GoalOrchestrationReasoningMetadata
    let understanding: GoalUnderstanding
    let compiledPath: GoalCompiledPath
    let resourceGraph: GoalResourceGraph
    let energyModel: GoalEnergyModel
    let contradictionReport: GoalContradictionReport

    init(
        input: GoalEngineOrchestrationInputSnapshot,
        context: GoalEngineOrchestrationContextSnapshot,
        inference: GoalOrchestrationInferenceSnapshot,
        clarification: GoalOrchestrationClarification,
        planner: GoalOrchestrationPlannerMetadata,
        reasoning: GoalOrchestrationReasoningMetadata,
        understanding: GoalUnderstanding,
        compiledPath: GoalCompiledPath,
        resourceGraph: GoalResourceGraph,
        energyModel: GoalEnergyModel,
        contradictionReport: GoalContradictionReport = .empty()
    ) {
        self.input = input
        self.context = context
        self.inference = inference
        self.clarification = clarification
        self.planner = planner
        self.reasoning = reasoning
        self.understanding = understanding
        self.compiledPath = compiledPath
        self.resourceGraph = resourceGraph
        self.energyModel = energyModel
        self.contradictionReport = contradictionReport
    }

    enum CodingKeys: String, CodingKey {
        case input
        case context
        case inference
        case clarification
        case planner
        case reasoning
        case understanding
        case compiledPath
        case resourceGraph
        case energyModel
        case contradictionReport
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        input = try container.decode(GoalEngineOrchestrationInputSnapshot.self, forKey: .input)
        context = try container.decode(GoalEngineOrchestrationContextSnapshot.self, forKey: .context)
        inference = try container.decode(GoalOrchestrationInferenceSnapshot.self, forKey: .inference)
        clarification = try container.decode(GoalOrchestrationClarification.self, forKey: .clarification)
        planner = try container.decode(GoalOrchestrationPlannerMetadata.self, forKey: .planner)
        reasoning = try container.decode(GoalOrchestrationReasoningMetadata.self, forKey: .reasoning)
        understanding = try container.decodeIfPresent(GoalUnderstanding.self, forKey: .understanding)
            ?? GoalUnderstanding.legacyFallback(
                input: input,
                context: context,
                inference: inference,
                clarification: clarification,
                reasoning: reasoning
            )
        compiledPath = try container.decodeIfPresent(GoalCompiledPath.self, forKey: .compiledPath)
            ?? GoalCompiledPath.legacyFallback(from: understanding)
        resourceGraph = try container.decodeIfPresent(GoalResourceGraph.self, forKey: .resourceGraph)
            ?? GoalResourceGraph.legacyFallback(
                compiledPath: compiledPath,
                knowledgeContext: context.knowledgeContext
            )
        energyModel = try container.decodeIfPresent(GoalEnergyModel.self, forKey: .energyModel)
            ?? .unevaluated()
        contradictionReport = try container.decodeIfPresent(GoalContradictionReport.self, forKey: .contradictionReport)
            ?? .empty()
    }
}

struct GoalClarificationRequiredResult: Sendable, Equatable {
    let draft: GoalDraft
    let clarification: GoalOrchestrationClarification
    let metadata: GoalOrchestrationMetadata
}

struct GoalPlannedResult: Sendable, Equatable {
    let draft: GoalDraft
    let plan: GoalPlan
    let lint: PlanLintResult
    let metadata: GoalOrchestrationMetadata
}

struct GoalStarterPlannedResult: Sendable, Equatable {
    let draft: GoalDraft
    let plan: GoalPlan
    let lint: PlanLintResult
    let assumptions: [PlanAssumption]
    let clarification: GoalOrchestrationClarification
    let metadata: GoalOrchestrationMetadata
}

enum GoalAdaptivePlanResult: Sendable, Equatable {
    case planned(GoalPlannedResult)
    case starterPlanned(GoalStarterPlannedResult)

    var draft: GoalDraft {
        switch self {
        case let .planned(result):
            return result.draft
        case let .starterPlanned(result):
            return result.draft
        }
    }

    var plan: GoalPlan {
        switch self {
        case let .planned(result):
            return result.plan
        case let .starterPlanned(result):
            return result.plan
        }
    }
}

struct GoalAdaptivePlanInput: Sendable, Equatable {
    let currentResult: GoalAdaptivePlanResult
    let selectedStep: Step
    let feedbackHistory: [GoalFeedbackEvent]
}

enum GoalReplanRecommendation: Sendable, Equatable {
    case noChange(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot)
    case reviseStep(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, rewriteHints: [String], evidenceAdjustments: [String], explanationHook: WhyStepMattersExplanationHook?)
    case shrinkStep(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, smallerVersion: String, fallbackMicroStep: String)
    case relaxTiming(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, suggestedTimingType: TimingType, removeDeadline: Bool)
    case requestReclarification(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, questions: [String])
    case adjustPlanTone(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, toneGuidance: [String])
    case suggestMicroStep(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, microStep: String)
    case suggestAlternatePath(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, alternatePath: String, explanationHook: WhyStepMattersExplanationHook?)

    var kind: GoalReplanRecommendationKind {
        switch self {
        case .noChange:
            return .noChange
        case .reviseStep:
            return .reviseStep
        case .shrinkStep:
            return .shrinkStep
        case .relaxTiming:
            return .relaxTiming
        case .requestReclarification:
            return .requestReclarification
        case .adjustPlanTone:
            return .adjustPlanTone
        case .suggestMicroStep:
            return .suggestMicroStep
        case .suggestAlternatePath:
            return .suggestAlternatePath
        }
    }

    var recommendationConfidence: RecommendationConfidence {
        switch self {
        case let .noChange(_, _, confidence, _),
             let .reviseStep(_, _, confidence, _, _, _, _),
             let .shrinkStep(_, _, confidence, _, _, _),
             let .relaxTiming(_, _, confidence, _, _, _),
             let .requestReclarification(_, _, confidence, _, _),
             let .adjustPlanTone(_, _, confidence, _, _),
             let .suggestMicroStep(_, _, confidence, _, _),
             let .suggestAlternatePath(_, _, confidence, _, _, _):
            return RecommendationConfidence.label(for: confidence)
        }
    }
}

struct GoalAdaptivePlanAdjustmentPayload: Sendable, Equatable {
    let goal: GoalDraft
    let plan: GoalPlan
    let selectedStep: Step
    let recommendation: GoalReplanRecommendation
    let explanationHook: WhyStepMattersExplanationHook?
}

struct GoalBlockedResult: Sendable, Equatable {
    let draft: GoalDraft
    let blockers: [GoalPlanningBlocker]
    let clarification: GoalOrchestrationClarification?
    let metadata: GoalOrchestrationMetadata
}

enum GoalOrchestrationResultKind: String, Codable, Sendable {
    case clarificationRequired = "clarification_required"
    case planned
    case starterPlanned = "starter_planned"
    case blocked
}
