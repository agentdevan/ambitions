import Foundation

protocol GoalUnderstandingBuilding: Sendable {
    func build(
        classification: ClassificationResult,
        clarification: GoalClarificationAnalysis,
        context: GoalEngineOrchestrationContextSnapshot,
        contradictions: [GoalInputContradiction]
    ) -> GoalUnderstanding
}

struct DefaultGoalUnderstandingService: GoalUnderstandingBuilding {
    func build(
        classification: ClassificationResult,
        clarification: GoalClarificationAnalysis,
        context: GoalEngineOrchestrationContextSnapshot,
        contradictions: [GoalInputContradiction] = []
    ) -> GoalUnderstanding {
        let interpretations = understandingInterpretations(
            from: clarification.candidateInterpretations,
            classification: classification
        )
        let primary = interpretations.first ?? fallbackInterpretation(from: classification)
        let alternates = Array(interpretations.dropFirst())
        let domains = buildDomains(
            classification: classification,
            interpretations: interpretations,
            clarification: clarification
        )
        let readiness = buildReadiness(clarification: clarification)
        let constraints = buildConstraints(
            clarification: clarification,
            contradictions: contradictions,
            knowledgeContext: context.knowledgeContext
        )
        let dependencies = buildDependencies(
            clarification: clarification,
            knowledgeContext: context.knowledgeContext
        )
        let risks = buildRisks(
            clarification: clarification,
            knowledgeContext: context.knowledgeContext
        )
        let assumptions = clarification.assumptions.map {
            GoalUnderstandingAssumption(
                id: $0.id,
                summary: $0.summary,
                rationale: $0.rationale,
                confidence: $0.confidence,
                source: $0.source,
                relatedField: $0.relatedField,
                safeForCompilation: $0.safeForCompilation
            )
        }

        return GoalUnderstanding(
            schemaVersion: goalUnderstandingSchemaVersion,
            subject: buildSubject(classification: classification),
            primaryInterpretation: primary,
            alternateInterpretations: alternates,
            domains: domains,
            mode: GoalUnderstandingModeInterpretation(
                goalMode: classification.mode.value,
                planningStrategyID: classification.planningStrategyID.value,
                progressStrategyID: classification.progressStrategyID.value,
                remainsProvisional: clarification.decision != .safeToProceedWithAssumptions
            ),
            ownership: GoalUnderstandingOwnershipInterpretation(
                executionOwnership: classification.executionOwnership.value,
                userRole: classification.userRole.value,
                supportScope: context.supportScope,
                actorDisplayName: classification.draft.actor.displayName,
                actorRoleLabel: classification.draft.actor.roleLabel
            ),
            timeline: GoalUnderstandingTimelineInterpretation(
                tempo: classification.tempo.value,
                timing: classification.draft.timing,
                posture: timelinePosture(for: classification.tempo.value),
                unresolvedAmbiguity: clarification.ambiguities.contains(where: { $0.type == .timeline })
            ),
            successDefinition: buildSuccessDefinition(
                classification: classification,
                clarification: clarification
            ),
            readiness: readiness,
            constraints: constraints,
            dependencies: dependencies,
            risks: risks,
            assumptions: assumptions,
            clarification: GoalUnderstandingClarificationCarryForward(
                analysis: clarification,
                unresolvedQuestions: clarification.questions,
                missingContext: clarification.missingContext,
                contradictions: contradictions,
                alternateInterpretationsActive: alternates.isEmpty == false
            ),
            confidence: buildConfidence(
                classification: classification,
                clarification: clarification,
                knowledgeContext: context.knowledgeContext
            ),
            audit: buildAudit(
                classification: classification,
                clarification: clarification,
                context: context
            )
        )
    }
}

private extension DefaultGoalUnderstandingService {
    func buildSubject(classification: ClassificationResult) -> GoalUnderstandingSubject {
        let subjectMissing = classification.missingFields.contains(where: { $0.field == .goalSubject && $0.blocksPlanning })
        return GoalUnderstandingSubject(
            canonicalIntent: classification.normalizedInput,
            normalizedTitle: classification.title,
            normalizedSummary: classification.summary,
            explicitness: subjectMissing ? .inferred : .explicit
        )
    }

    func understandingInterpretations(
        from candidates: [GoalInterpretationCandidate],
        classification: ClassificationResult
    ) -> [GoalUnderstandingInterpretation] {
        if candidates.isEmpty {
            return [fallbackInterpretation(from: classification)]
        }

        return candidates.map {
            GoalUnderstandingInterpretation(
                id: $0.id,
                summary: $0.summary,
                modeHint: $0.modeHint,
                domainHints: $0.domainHints,
                supportingSignals: $0.supportingSignals,
                source: .derivedInference
            )
        }
    }

    func fallbackInterpretation(from classification: ClassificationResult) -> GoalUnderstandingInterpretation {
        GoalUnderstandingInterpretation(
            id: "primary",
            summary: "Use the current classified goal shape as the primary structural reading.",
            modeHint: classification.mode.value,
            domainHints: classification.draft.lifeGraph?.domains.map(\.domain) ?? [],
            supportingSignals: [
                classification.mode.metadata.reason,
                classification.tempo.metadata.reason
            ],
            source: .derivedInference
        )
    }

    func buildDomains(
        classification: ClassificationResult,
        interpretations: [GoalUnderstandingInterpretation],
        clarification: GoalClarificationAnalysis
    ) -> GoalUnderstandingDomainInterpretation {
        let direct = classification.draft.lifeGraph?.domains ?? []
        let fallback = stableAssignments(
            direct: [],
            fallback: interpretations.flatMap { domainAssignments(from: $0.domainHints) }
        )
        let all = direct.isEmpty ? fallback : direct
        let domainAmbiguity = clarification.ambiguities.contains(where: { $0.type == .domain }) ||
            Set(all.map { $0.domain }).count > 1
        return GoalUnderstandingDomainInterpretation(
            primary: all.sorted(by: { $0.priority > $1.priority }).first?.domain,
            all: all,
            isAmbiguous: domainAmbiguity
        )
    }

    func buildSuccessDefinition(
        classification: ClassificationResult,
        clarification: GoalClarificationAnalysis
    ) -> GoalUnderstandingSuccessInterpretation {
        let missing = clarification.missingContext.contains(where: { $0.field == .successDefinition })
        let explicitness: GoalUnderstandingSuccessExplicitness = missing ? .missing : .inferred
        let summary = missing ? nil : "Advance \(classification.title.lowercased()) to a visible first useful outcome."
        return GoalUnderstandingSuccessInterpretation(
            summary: summary,
            explicitness: explicitness,
            remainsProvisional: missing || clarification.decision != .safeToProceedWithAssumptions
        )
    }

    func buildReadiness(clarification: GoalClarificationAnalysis) -> GoalUnderstandingReadinessInterpretation {
        let blockingFields = clarification.missingContext.compactMap { item in
            item.blocksCompilation ? item.field : nil
        }
        return GoalUnderstandingReadinessInterpretation(
            decision: clarification.decision,
            safeToCompile: clarification.decision == .safeToProceedWithAssumptions,
            hasBlockingIssues: blockingFields.isEmpty == false,
            blockingFields: blockingFields
        )
    }

    func buildConstraints(
        clarification: GoalClarificationAnalysis,
        contradictions: [GoalInputContradiction],
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> [GoalUnderstandingConstraintHint] {
        var constraints = clarification.missingContext.map { item in
            GoalUnderstandingConstraintHint(
                id: item.id,
                summary: item.reason,
                kind: constraintKind(for: item.field),
                relatedField: item.field,
                blocking: item.blocksCompilation,
                source: .clarification
            )
        }

        constraints.append(contentsOf: contradictions.map { contradiction in
            GoalUnderstandingConstraintHint(
                id: "constraint-\(contradiction.code.rawValue)",
                summary: contradiction.reason,
                kind: .contradiction,
                relatedField: contradiction.question.field,
                blocking: true,
                source: .clarification
            )
        })

        if let knowledgeContext {
            let stale = knowledgeContext.claims.contains(where: { $0.freshness.state == .stale || $0.freshness.state == .expired })
            if stale {
                constraints.append(
                    GoalUnderstandingConstraintHint(
                        id: "constraint-knowledge-freshness",
                        summary: "Knowledge context includes stale or expired material.",
                        kind: .knowledgeFreshness,
                        relatedField: nil,
                        blocking: false,
                        source: .knowledgeContext
                    )
                )
            }
            let conflicting = knowledgeContext.claims.contains(where: { $0.uncertaintyFlags.contains(.conflicting) })
            if conflicting {
                constraints.append(
                    GoalUnderstandingConstraintHint(
                        id: "constraint-knowledge-conflict",
                        summary: "Knowledge context includes conflicting claims.",
                        kind: .knowledgeConflict,
                        relatedField: nil,
                        blocking: false,
                        source: .knowledgeContext
                    )
                )
            }
        }

        return constraints
    }

    func buildDependencies(
        clarification: GoalClarificationAnalysis,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> [GoalUnderstandingDependencyHint] {
        var dependencies = clarification.missingContext.map { item in
            GoalUnderstandingDependencyHint(
                id: "dependency-\(item.id)",
                summary: item.reason,
                kind: .readiness,
                sourceClaimIDs: [],
                sourceRecordIDs: []
            )
        }

        if let knowledgeContext {
            dependencies.append(
                contentsOf: knowledgeContext.claims.map { claim in
                    GoalUnderstandingDependencyHint(
                        id: "dependency-\(claim.id)",
                        summary: claim.payload.summary,
                        kind: .knowledge,
                        sourceClaimIDs: [claim.id],
                        sourceRecordIDs: [claim.source.id]
                    )
                }
            )
        }

        return dependencies
    }

    func buildRisks(
        clarification: GoalClarificationAnalysis,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> [GoalUnderstandingRiskFlag] {
        var risks = clarification.ambiguities.map { ambiguity in
            GoalUnderstandingRiskFlag(
                id: "risk-\(ambiguity.id)",
                summary: ambiguity.summary,
                kind: riskKind(for: ambiguity.type),
                severity: ambiguity.severity
            )
        }

        if let knowledgeContext {
            if knowledgeContext.claims.contains(where: { $0.freshness.state == .stale || $0.freshness.state == .expired }) {
                risks.append(
                    GoalUnderstandingRiskFlag(
                        id: "risk-knowledge-freshness",
                        summary: "Stale knowledge may lower confidence in the current understanding.",
                        kind: .knowledgeFreshness,
                        severity: .important
                    )
                )
            }
            if knowledgeContext.claims.contains(where: { $0.uncertaintyFlags.contains(.conflicting) }) {
                risks.append(
                    GoalUnderstandingRiskFlag(
                        id: "risk-knowledge-conflict",
                        summary: "Conflicting knowledge remains preserved and unresolved.",
                        kind: .knowledgeConflict,
                        severity: .important
                    )
                )
            }
        }

        return risks
    }

    func buildConfidence(
        classification: ClassificationResult,
        clarification: GoalClarificationAnalysis,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> GoalUnderstandingConfidenceMetadata {
        let baseline = (
            classification.mode.metadata.confidence +
            classification.tempo.metadata.confidence +
            classification.executionOwnership.metadata.confidence +
            classification.userRole.metadata.confidence
        ) / 4
        let ambiguityPenalty = Double(clarification.ambiguities.count) * 0.08
        let missingPenalty = Double(clarification.missingContext.filter(\.blocksCompilation).count) * 0.12
        let knowledgePenalty = knowledgeContext?.claims.contains(where: { $0.uncertaintyFlags.contains(.conflicting) || $0.freshness.state == .stale || $0.freshness.state == .expired }) == true ? 0.06 : 0
        let score = min(max(baseline - ambiguityPenalty - missingPenalty - knowledgePenalty, 0), 1)

        var tags: [String] = []
        if clarification.ambiguities.isEmpty == false {
            tags.append("ambiguity_active")
        }
        if clarification.missingContext.contains(where: \.blocksCompilation) {
            tags.append("blocking_context_missing")
        }
        if knowledgePenalty > 0 {
            tags.append("knowledge_context_limited")
        }

        return GoalUnderstandingConfidenceMetadata(
            overall: RecommendationConfidence.label(for: score),
            score: score,
            uncertaintyTags: tags
        )
    }

    func buildAudit(
        classification: ClassificationResult,
        clarification: GoalClarificationAnalysis,
        context: GoalEngineOrchestrationContextSnapshot
    ) -> GoalUnderstandingAuditMetadata {
        var evidence: [GoalUnderstandingAuditEntry] = [
            GoalUnderstandingAuditEntry(
                id: "audit-raw-input",
                origin: .rawInput,
                summary: classification.normalizedInput,
                claimID: nil,
                sourceRecordID: nil,
                providerID: nil
            ),
            GoalUnderstandingAuditEntry(
                id: "audit-clarification",
                origin: .clarification,
                summary: "Clarification analysis is preserved structurally.",
                claimID: nil,
                sourceRecordID: nil,
                providerID: nil
            ),
            GoalUnderstandingAuditEntry(
                id: "audit-derived",
                origin: .derivedInference,
                summary: "Primary interpretation comes from deterministic intake and clarification composition.",
                claimID: nil,
                sourceRecordID: nil,
                providerID: nil
            )
        ]

        if let knowledgeContext = context.knowledgeContext {
            evidence.append(
                contentsOf: knowledgeContext.claims.map { claim in
                    GoalUnderstandingAuditEntry(
                        id: "audit-knowledge-\(claim.id)",
                        origin: .knowledgeContext,
                        summary: claim.payload.summary,
                        claimID: claim.id,
                        sourceRecordID: claim.source.id,
                        providerID: claim.providerID
                    )
                }
            )
            evidence.append(
                contentsOf: knowledgeContext.providerStatuses.map { status in
                    GoalUnderstandingAuditEntry(
                        id: "audit-provider-\(status.provider.id)",
                        origin: .knowledgeContext,
                        summary: status.detail,
                        claimID: nil,
                        sourceRecordID: nil,
                        providerID: status.provider.id
                    )
                }
            )
        }

        return GoalUnderstandingAuditMetadata(evidence: evidence)
    }

    func riskKind(for ambiguityType: GoalAmbiguityType) -> GoalUnderstandingRiskKind {
        switch ambiguityType {
        case .timeline:
            return .timeline
        case .readiness:
            return .readiness
        case .constraintResource:
            return .ownership
        case .domain, .scope, .successDefinition:
            return .ambiguity
        }
    }

    func timelinePosture(for tempo: GoalTempo) -> GoalUnderstandingTimelinePosture {
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

    func domainAssignments(from hints: [LifeDomainKey]) -> [LifeDomainAssignment] {
        hints.enumerated().map { index, domain in
            LifeDomainAssignment(domain: domain, priority: max(0.2, 1 - Double(index) * 0.2))
        }
    }

    func stableAssignments(
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

    func constraintKind(for field: MissingFieldKey?) -> GoalUnderstandingConstraintKind {
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
}
