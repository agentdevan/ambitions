import Foundation

let goalUnderstandingSchemaVersion = "goal_understanding.native.v1"

enum GoalUnderstandingValueOrigin: String, Codable, Sendable, Equatable, Hashable {
    case rawInput = "raw_input"
    case clarification
    case derivedInference = "derived_inference"
    case knowledgeContext = "knowledge_context"
}

enum GoalUnderstandingSubjectExplicitness: String, Codable, Sendable, Equatable, Hashable {
    case explicit
    case inferred
}

struct GoalUnderstandingSubject: Codable, Sendable, Equatable {
    let canonicalIntent: String
    let normalizedTitle: String
    let normalizedSummary: String?
    let explicitness: GoalUnderstandingSubjectExplicitness
}

struct GoalUnderstandingInterpretation: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let modeHint: GoalMode?
    let domainHints: [LifeDomainKey]
    let supportingSignals: [String]
    let source: GoalUnderstandingValueOrigin
}

struct GoalUnderstandingDomainInterpretation: Codable, Sendable, Equatable {
    let primary: LifeDomainKey?
    let all: [LifeDomainAssignment]
    let isAmbiguous: Bool
}

struct GoalUnderstandingModeInterpretation: Codable, Sendable, Equatable {
    let goalMode: GoalMode
    let planningStrategyID: IntakePlanningStrategyID
    let progressStrategyID: IntakeProgressStrategyID
    let remainsProvisional: Bool
}

struct GoalUnderstandingOwnershipInterpretation: Codable, Sendable, Equatable {
    let executionOwnership: ExecutionOwnership
    let userRole: UserExecutionRole
    let supportScope: GoalSupportScope?
    let actorDisplayName: String
    let actorRoleLabel: String?
}

enum GoalUnderstandingTimelinePosture: String, Codable, Sendable, Equatable, Hashable {
    case hardDeadline = "hard_deadline"
    case flexibleWindow = "flexible_window"
    case ongoing
    case untimed
}

struct GoalUnderstandingTimelineInterpretation: Codable, Sendable, Equatable {
    let tempo: GoalTempo
    let timing: GoalTiming
    let posture: GoalUnderstandingTimelinePosture
    let unresolvedAmbiguity: Bool
}

enum GoalUnderstandingSuccessExplicitness: String, Codable, Sendable, Equatable, Hashable {
    case explicit
    case inferred
    case missing
}

struct GoalUnderstandingSuccessInterpretation: Codable, Sendable, Equatable {
    let summary: String?
    let explicitness: GoalUnderstandingSuccessExplicitness
    let remainsProvisional: Bool
}

struct GoalUnderstandingReadinessInterpretation: Codable, Sendable, Equatable {
    let decision: GoalClarificationDecision
    let safeToCompile: Bool
    let hasBlockingIssues: Bool
    let blockingFields: [MissingFieldKey]
}

enum GoalUnderstandingConstraintKind: String, Codable, Sendable, Equatable, Hashable {
    case goalSubject = "goal_subject"
    case goalShape = "goal_shape"
    case supportScope = "support_scope"
    case successDefinition = "success_definition"
    case timeHorizon = "time_horizon"
    case executorIdentity = "executor_identity"
    case contradiction
    case ownership
    case knowledgeFreshness = "knowledge_freshness"
    case knowledgeConflict = "knowledge_conflict"
}

struct GoalUnderstandingConstraintHint: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalUnderstandingConstraintKind
    let relatedField: MissingFieldKey?
    let blocking: Bool
    let source: GoalUnderstandingValueOrigin
}

enum GoalUnderstandingDependencyKind: String, Codable, Sendable, Equatable, Hashable {
    case readiness
    case support
    case timeline
    case knowledge
}

struct GoalUnderstandingDependencyHint: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalUnderstandingDependencyKind
    let sourceClaimIDs: [String]
    let sourceRecordIDs: [String]
}

enum GoalUnderstandingRiskKind: String, Codable, Sendable, Equatable, Hashable {
    case ambiguity
    case ownership
    case timeline
    case readiness
    case knowledgeFreshness = "knowledge_freshness"
    case knowledgeConflict = "knowledge_conflict"
}

struct GoalUnderstandingRiskFlag: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalUnderstandingRiskKind
    let severity: GoalClarificationSeverity
}

struct GoalUnderstandingAssumption: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let rationale: String
    let confidence: AssumptionConfidence
    let source: ContractValueSource
    let relatedField: MissingFieldKey?
    let safeForCompilation: Bool
}

struct GoalUnderstandingClarificationCarryForward: Codable, Sendable, Equatable {
    let analysis: GoalClarificationAnalysis
    let unresolvedQuestions: [GoalClarificationQuestionContract]
    let missingContext: [GoalMissingContextItem]
    let contradictions: [GoalInputContradiction]
    let alternateInterpretationsActive: Bool
}

struct GoalUnderstandingConfidenceMetadata: Codable, Sendable, Equatable {
    let overall: RecommendationConfidence
    let score: Double
    let uncertaintyTags: [String]
}

struct GoalUnderstandingAuditEntry: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let origin: GoalUnderstandingValueOrigin
    let summary: String
    let claimID: String?
    let sourceRecordID: String?
    let providerID: String?
}

struct GoalUnderstandingAuditMetadata: Codable, Sendable, Equatable {
    let evidence: [GoalUnderstandingAuditEntry]
}

struct GoalUnderstandingKnowledgeContext: Codable, Sendable, Equatable {
    let claims: [KnowledgeClaim]
    let sources: [KnowledgeSourceRecord]
    let providerStatuses: [KnowledgeProviderStatus]

    init(
        claims: [KnowledgeClaim] = [],
        sources: [KnowledgeSourceRecord] = [],
        providerStatuses: [KnowledgeProviderStatus] = []
    ) {
        self.claims = claims
        self.sources = sources
        self.providerStatuses = providerStatuses
    }
}

struct GoalUnderstanding: Codable, Sendable, Equatable {
    let schemaVersion: String
    let subject: GoalUnderstandingSubject
    let primaryInterpretation: GoalUnderstandingInterpretation
    let alternateInterpretations: [GoalUnderstandingInterpretation]
    let domains: GoalUnderstandingDomainInterpretation
    let mode: GoalUnderstandingModeInterpretation
    let ownership: GoalUnderstandingOwnershipInterpretation
    let timeline: GoalUnderstandingTimelineInterpretation
    let successDefinition: GoalUnderstandingSuccessInterpretation
    let readiness: GoalUnderstandingReadinessInterpretation
    let constraints: [GoalUnderstandingConstraintHint]
    let dependencies: [GoalUnderstandingDependencyHint]
    let risks: [GoalUnderstandingRiskFlag]
    let assumptions: [GoalUnderstandingAssumption]
    let clarification: GoalUnderstandingClarificationCarryForward
    let confidence: GoalUnderstandingConfidenceMetadata
    let audit: GoalUnderstandingAuditMetadata
}

extension GoalUnderstandingAssumption {
    var planAssumption: PlanAssumption {
        PlanAssumption(
            id: id,
            summary: summary,
            rationale: rationale,
            confidence: confidence,
            relatedField: relatedField
        )
    }
}

extension GoalUnderstanding {
    static func legacyFallback(
        input: GoalEngineOrchestrationInputSnapshot,
        context: GoalEngineOrchestrationContextSnapshot,
        inference: GoalOrchestrationInferenceSnapshot,
        clarification: GoalOrchestrationClarification,
        reasoning: GoalOrchestrationReasoningMetadata
    ) -> GoalUnderstanding {
        let candidateInterpretations = clarification.analysis.candidateInterpretations
        let primaryCandidate = candidateInterpretations.first
        let alternateCandidates = Array(candidateInterpretations.dropFirst())
        let allDomains = stableAssignments(
            direct: primaryCandidate.map { domainAssignments(from: $0.domainHints) } ?? [],
            fallback: alternateCandidates.flatMap { domainAssignments(from: $0.domainHints) }
        )
        let blockingFields = clarification.missingFields.filter(\.blocksPlanning).map(\.field)
        let uncertaintyTags = legacyUncertaintyTags(
            clarification: clarification,
            reasoning: reasoning
        )

        return GoalUnderstanding(
            schemaVersion: goalUnderstandingSchemaVersion,
            subject: GoalUnderstandingSubject(
                canonicalIntent: input.normalizedInput,
                normalizedTitle: input.normalizedInput,
                normalizedSummary: input.normalizedInput == input.rawInput ? nil : input.normalizedInput,
                explicitness: reasoning.missingFields.contains(where: { $0.field == .goalSubject && $0.blocksPlanning }) ? .inferred : .explicit
            ),
            primaryInterpretation: GoalUnderstandingInterpretation(
                id: primaryCandidate?.id ?? "stored-primary",
                summary: primaryCandidate?.summary ?? "Use the current classified interpretation as the primary structural reading.",
                modeHint: primaryCandidate?.modeHint ?? inference.mode.value,
                domainHints: primaryCandidate?.domainHints ?? allDomains.map(\.domain),
                supportingSignals: primaryCandidate?.supportingSignals ?? [inference.mode.metadata.reason, inference.tempo.metadata.reason],
                source: .derivedInference
            ),
            alternateInterpretations: alternateCandidates.map {
                GoalUnderstandingInterpretation(
                    id: $0.id,
                    summary: $0.summary,
                    modeHint: $0.modeHint,
                    domainHints: $0.domainHints,
                    supportingSignals: $0.supportingSignals,
                    source: .derivedInference
                )
            },
            domains: GoalUnderstandingDomainInterpretation(
                primary: allDomains.first?.domain,
                all: allDomains,
                isAmbiguous: allDomains.count > 1
            ),
            mode: GoalUnderstandingModeInterpretation(
                goalMode: inference.mode.value,
                planningStrategyID: inference.planningStrategyID.value,
                progressStrategyID: inference.progressStrategyID.value,
                remainsProvisional: reasoning.starterPlanSafe == false || clarification.analysis.decision != .safeToProceedWithAssumptions
            ),
            ownership: GoalUnderstandingOwnershipInterpretation(
                executionOwnership: inference.executionOwnership.value,
                userRole: inference.userRole.value,
                supportScope: context.supportScope,
                actorDisplayName: inference.actorDisplayName,
                actorRoleLabel: inference.actorRoleLabel
            ),
            timeline: GoalUnderstandingTimelineInterpretation(
                tempo: inference.tempo.value,
                timing: inference.timing,
                posture: timelinePosture(for: inference.tempo.value),
                unresolvedAmbiguity: clarification.analysis.ambiguities.contains(where: { $0.type == .timeline })
            ),
            successDefinition: GoalUnderstandingSuccessInterpretation(
                summary: reasoning.missingFields.contains(where: { $0.field == .successDefinition })
                    ? nil
                    : "Success remains aligned to the current classified goal framing.",
                explicitness: reasoning.missingFields.contains(where: { $0.field == .successDefinition }) ? .missing : .inferred,
                remainsProvisional: clarification.analysis.decision != .safeToProceedWithAssumptions
            ),
            readiness: GoalUnderstandingReadinessInterpretation(
                decision: clarification.analysis.decision,
                safeToCompile: clarification.analysis.decision == .safeToProceedWithAssumptions,
                hasBlockingIssues: blockingFields.isEmpty == false,
                blockingFields: blockingFields
            ),
            constraints: legacyConstraints(clarification: clarification),
            dependencies: legacyDependencies(clarification: clarification),
            risks: legacyRisks(clarification: clarification),
            assumptions: reasoning.assumptions.map {
                GoalUnderstandingAssumption(
                    id: $0.id,
                    summary: $0.summary,
                    rationale: $0.rationale,
                    confidence: $0.confidence,
                    source: .derivedContract,
                    relatedField: $0.relatedField,
                    safeForCompilation: clarification.analysis.decision == .safeToProceedWithAssumptions
                )
            },
            clarification: GoalUnderstandingClarificationCarryForward(
                analysis: clarification.analysis,
                unresolvedQuestions: clarification.analysis.questions,
                missingContext: clarification.analysis.missingContext,
                contradictions: clarification.contradictions,
                alternateInterpretationsActive: alternateCandidates.isEmpty == false
            ),
            confidence: GoalUnderstandingConfidenceMetadata(
                overall: RecommendationConfidence.label(for: legacyConfidenceScore(inference: inference, clarification: clarification)),
                score: legacyConfidenceScore(inference: inference, clarification: clarification),
                uncertaintyTags: uncertaintyTags
            ),
            audit: GoalUnderstandingAuditMetadata(
                evidence: legacyAuditEntries(input: input, clarification: clarification)
            )
        )
    }
}

private func domainAssignments(from hints: [LifeDomainKey]) -> [LifeDomainAssignment] {
    hints.enumerated().map { index, domain in
        LifeDomainAssignment(domain: domain, priority: max(0.2, 1 - Double(index) * 0.2))
    }
}

private func stableAssignments(
    direct: [LifeDomainAssignment],
    fallback: [LifeDomainAssignment]
) -> [LifeDomainAssignment] {
    var ordered: [LifeDomainAssignment] = []
    var seen: Set<LifeDomainKey> = []

    for assignment in direct + fallback {
        if seen.insert(assignment.domain).inserted {
            ordered.append(assignment)
        }
    }

    return ordered
}

private func legacyConstraints(clarification: GoalOrchestrationClarification) -> [GoalUnderstandingConstraintHint] {
    let missing = clarification.analysis.missingContext.map { item in
        GoalUnderstandingConstraintHint(
            id: item.id,
            summary: item.reason,
            kind: constraintKind(for: item.field),
            relatedField: item.field,
            blocking: item.blocksCompilation,
            source: .clarification
        )
    }
    let contradictions = clarification.contradictions.map { contradiction in
        GoalUnderstandingConstraintHint(
            id: "constraint-\(contradiction.code.rawValue)",
            summary: contradiction.reason,
            kind: .contradiction,
            relatedField: contradiction.question.field,
            blocking: true,
            source: .clarification
        )
    }
    return missing + contradictions
}

private func legacyDependencies(clarification: GoalOrchestrationClarification) -> [GoalUnderstandingDependencyHint] {
    clarification.analysis.missingContext.map { item in
        GoalUnderstandingDependencyHint(
            id: "dependency-\(item.id)",
            summary: item.reason,
            kind: .readiness,
            sourceClaimIDs: [],
            sourceRecordIDs: []
        )
    }
}

private func legacyRisks(clarification: GoalOrchestrationClarification) -> [GoalUnderstandingRiskFlag] {
    clarification.analysis.ambiguities.map { ambiguity in
        GoalUnderstandingRiskFlag(
            id: "risk-\(ambiguity.id)",
            summary: ambiguity.summary,
            kind: ambiguity.type == .timeline ? .timeline : .ambiguity,
            severity: ambiguity.severity
        )
    }
}

private func legacyConfidenceScore(
    inference: GoalOrchestrationInferenceSnapshot,
    clarification: GoalOrchestrationClarification
) -> Double {
    let baseline = (
        inference.mode.metadata.confidence +
        inference.tempo.metadata.confidence +
        inference.executionOwnership.metadata.confidence
    ) / 3
    let ambiguityPenalty = Double(clarification.analysis.ambiguities.count) * 0.08
    let blockerPenalty = Double(clarification.missingFields.filter(\.blocksPlanning).count) * 0.12
    return min(max(baseline - ambiguityPenalty - blockerPenalty, 0), 1)
}

private func legacyUncertaintyTags(
    clarification: GoalOrchestrationClarification,
    reasoning: GoalOrchestrationReasoningMetadata
) -> [String] {
    var tags: [String] = []
    if clarification.analysis.ambiguities.isEmpty == false {
        tags.append("ambiguity_active")
    }
    if clarification.missingFields.contains(where: \.blocksPlanning) {
        tags.append("blocking_context_missing")
    }
    if reasoning.assumptions.isEmpty == false {
        tags.append("assumptions_active")
    }
    return tags
}

private func legacyAuditEntries(
    input: GoalEngineOrchestrationInputSnapshot,
    clarification: GoalOrchestrationClarification
) -> [GoalUnderstandingAuditEntry] {
    var evidence: [GoalUnderstandingAuditEntry] = [
        GoalUnderstandingAuditEntry(
            id: "audit-raw-input",
            origin: .rawInput,
            summary: input.normalizedInput,
            claimID: nil,
            sourceRecordID: nil,
            providerID: nil
        )
    ]

    if clarification.analysis.questions.isEmpty == false || clarification.analysis.missingContext.isEmpty == false {
        evidence.append(
            GoalUnderstandingAuditEntry(
                id: "audit-clarification",
                origin: .clarification,
                summary: "Clarification structure remains active.",
                claimID: nil,
                sourceRecordID: nil,
                providerID: nil
            )
        )
    }

    evidence.append(
        GoalUnderstandingAuditEntry(
            id: "audit-derived",
            origin: .derivedInference,
            summary: "The primary interpretation is derived from classified intake and clarification state.",
            claimID: nil,
            sourceRecordID: nil,
            providerID: nil
        )
    )

    return evidence
}

private func constraintKind(for field: MissingFieldKey?) -> GoalUnderstandingConstraintKind {
    switch field {
    case .goalSubject:
        return .goalSubject
    case .goalShape:
        return .goalShape
    case .supportScope:
        return .supportScope
    case .successDefinition:
        return .successDefinition
    case .timeHorizon:
        return .timeHorizon
    case .executorIdentity:
        return .executorIdentity
    case .none:
        return .ownership
    }
}

private func timelinePosture(for tempo: GoalTempo) -> GoalUnderstandingTimelinePosture {
    switch tempo {
    case .deadlineBased:
        return .hardDeadline
    case .targetWindow:
        return .flexibleWindow
    case .ongoing:
        return .ongoing
    case .untimed:
        return .untimed
    }
}
