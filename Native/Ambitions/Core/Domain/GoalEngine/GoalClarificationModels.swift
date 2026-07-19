import Foundation

enum GoalAmbiguityType: String, Codable, Sendable, Equatable, Hashable {
    case domain
    case scope
    case timeline
    case readiness
    case constraintResource = "constraint_resource"
    case successDefinition = "success_definition"
}

enum GoalClarificationSeverity: String, Codable, Sendable, Equatable, Hashable {
    case info
    case important
    case blocking
}

enum GoalClarificationDecision: String, Codable, Sendable, Equatable, Hashable {
    case safeToProceedWithAssumptions = "safe_to_proceed_with_assumptions"
    case mustClarifyBeforeCompile = "must_clarify_before_compile"
}

struct GoalInterpretationCandidate: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let modeHint: GoalMode?
    let domainHints: [LifeDomainKey]
    let confidence: RecommendationConfidence
    let supportingSignals: [String]
}

struct GoalAmbiguitySignal: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let type: GoalAmbiguityType
    let summary: String
    let detail: String
    let severity: GoalClarificationSeverity
    let relatedField: MissingFieldKey?
    let candidateIDs: [String]
}

struct GoalMissingContextItem: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let field: MissingFieldKey?
    let label: String
    let reason: String
    let severity: GoalClarificationSeverity
    let blocksCompilation: Bool
}

struct GoalClarificationAssumption: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let rationale: String
    let confidence: AssumptionConfidence
    let source: ContractValueSource
    let relatedField: MissingFieldKey?
    let safeForCompilation: Bool
}

struct GoalClarificationQuestionContract: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let prompt: String
    let rationale: String
    let targetField: MissingFieldKey?
    let addressesAmbiguityTypes: [GoalAmbiguityType]
    let severity: GoalClarificationSeverity
    let blocking: Bool
    let skipSafeDefault: String
}

struct GoalClarificationReasoningMetadata: Codable, Sendable, Equatable {
    let signalNotes: [String]
    let inference: [String: InferenceMetadata]
    let auditTags: [String]
}

struct GoalClarificationAnalysis: Codable, Sendable, Equatable {
    let candidateInterpretations: [GoalInterpretationCandidate]
    let ambiguities: [GoalAmbiguitySignal]
    let missingContext: [GoalMissingContextItem]
    let assumptions: [GoalClarificationAssumption]
    let questions: [GoalClarificationQuestionContract]
    let decision: GoalClarificationDecision
    let reasoning: GoalClarificationReasoningMetadata
}

extension GoalClarificationSeverity {
    var blocksCompilation: Bool {
        self == .blocking
    }
}

extension GoalClarificationDecision {
    var compatibilityReadiness: PlanningReadiness {
        switch self {
        case .mustClarifyBeforeCompile:
            return .needsClarification
        case .safeToProceedWithAssumptions:
            return .canPlanWithDefaults
        }
    }

    var clarificationNeeded: Bool {
        self == .mustClarifyBeforeCompile
    }

    var starterPlanSafe: Bool {
        self == .safeToProceedWithAssumptions
    }
}

extension GoalClarificationAnalysis {
    var compatibilityReadiness: PlanningReadiness {
        if decision == .mustClarifyBeforeCompile {
            return .needsClarification
        }

        let projectedMissingFields = compatibilityMissingFields
        if projectedMissingFields.isEmpty && ambiguities.isEmpty {
            return .readyForPlanning
        }

        return .canPlanWithDefaults
    }

    var compatibilityMissingFields: [MissingField] {
        stableUnique(
            missingContext.compactMap { item in
                guard let field = item.field else { return nil }
                return MissingField(
                    field: field,
                    reason: item.reason,
                    blocksPlanning: item.blocksCompilation || item.severity.blocksCompilation
                )
            },
            key: \.field
        )
    }

    var compatibilityQuestions: [ClarificationQuestion] {
        stableUnique(
            questions.compactMap { question in
                guard let field = question.targetField else { return nil }
                return ClarificationQuestion(
                    id: question.id,
                    field: field,
                    prompt: question.prompt,
                    rationale: question.rationale,
                    skipSafeDefault: question.skipSafeDefault
                )
            },
            key: \.field
        )
    }

    var compatibilityClarificationSet: ClarificationSet {
        ClarificationSet(
            readiness: compatibilityReadiness,
            questions: compatibilityQuestions,
            missingFields: compatibilityMissingFields
        )
    }

    var compatibilityPlanAssumptions: [PlanAssumption] {
        guard decision == .safeToProceedWithAssumptions else { return [] }
        return assumptions
            .filter(\.safeForCompilation)
            .map {
                PlanAssumption(
                    id: $0.id,
                    summary: $0.summary,
                    rationale: $0.rationale,
                    confidence: $0.confidence,
                    relatedField: $0.relatedField
                )
            }
    }
}

private func stableUnique<Value, Key: Hashable>(
    _ values: [Value],
    key: KeyPath<Value, Key>
) -> [Value] {
    var seen: Set<Key> = []
    var result: [Value] = []

    for value in values {
        let resolvedKey = value[keyPath: key]
        if seen.insert(resolvedKey).inserted {
            result.append(value)
        }
    }

    return result
}
