import Foundation

let goalPathCompilerSchemaVersion = "goal_path_compiler.native.v1"

enum GoalPathCompilePosture: String, Codable, Sendable, Equatable, Hashable {
    case provisional
    case stronger
    case blocked
}

enum GoalCompiledPathStageKind: String, Codable, Sendable, Equatable, Hashable {
    case setup
    case readiness
    case firstProof = "first_proof"
    case advancement
    case reviewFinish = "review_finish"
}

enum GoalCompiledPathDependencyKind: String, Codable, Sendable, Equatable, Hashable {
    case stageOrdering = "stage_ordering"
    case readiness
    case support
    case timeline
    case knowledge
}

enum GoalCompiledPathBranchType: String, Codable, Sendable, Equatable, Hashable {
    case fallback
    case alternateInterpretation = "alternate_interpretation"
    case blocked
}

enum GoalCompiledPathUncertaintyReason: String, Codable, Sendable, Equatable, Hashable {
    case activeAmbiguity = "active_ambiguity"
    case missingContext = "missing_context"
    case carriedAssumption = "carried_assumption"
    case carriedRisk = "carried_risk"
    case blockedReadiness = "blocked_readiness"
}

enum GoalCompiledPathAuditKind: String, Codable, Sendable, Equatable, Hashable {
    case interpretationSelection = "interpretation_selection"
    case dependencyCarryForward = "dependency_carry_forward"
    case assumptionCarryForward = "assumption_carry_forward"
    case riskCarryForward = "risk_carry_forward"
    case knowledgeEvidence = "knowledge_evidence"
}

enum GoalCompiledPathRequirementKind: String, Codable, Sendable, Equatable, Hashable {
    case externalRequirement = "external_requirement"
    case domainReadiness = "domain_readiness"
}

enum GoalCompiledPathReadinessCriterionKind: String, Codable, Sendable, Equatable, Hashable {
    case confirmation
    case eligibility
}

enum GoalCompiledPathResourceHookKind: String, Codable, Sendable, Equatable, Hashable {
    case requirementReference = "requirement_reference"
    case preparationMaterial = "preparation_material"
}

enum GoalCompiledPathResourceHookPlaceholderState: String, Codable, Sendable, Equatable, Hashable {
    case resourceNeeded = "resource_needed"
}

enum GoalCompiledPathPackAuditContributionKind: String, Codable, Sendable, Equatable, Hashable {
    case requirementHint = "requirement_hint"
    case dependencyHint = "dependency_hint"
    case readinessCriterion = "readiness_criterion"
    case riskHint = "risk_hint"
    case resourceHook = "resource_hook"
    case branchAddition = "branch_addition"
}

struct GoalCompiledPathConfidence: Codable, Sendable, Equatable {
    let overall: RecommendationConfidence
    let score: Double
    let uncertaintyTags: [String]
}

struct GoalCompiledPathBlockingReason: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let field: MissingFieldKey?
}

struct GoalCompiledPathAssumption: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let rationale: String
    let confidence: AssumptionConfidence
    let source: ContractValueSource
    let relatedField: MissingFieldKey?
    let safeForCompilation: Bool
}

struct GoalCompiledPathRisk: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalUnderstandingRiskKind
    let severity: GoalClarificationSeverity
}

struct GoalCompiledPathRequirementHint: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathRequirementKind
    let relatedField: MissingFieldKey?
    let relatedStageID: String?
    let blocking: Bool
}

struct GoalCompiledPathReadinessCriterion: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathReadinessCriterionKind
    let targetStageID: String?
    let token: String
    let blocking: Bool
}

struct GoalCompiledPathResourceHook: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathResourceHookKind
    let targetStageID: String?
    let relatedDomains: [LifeDomainKey]
    let sourceClaimIDs: [String]
    let sourceRecordIDs: [String]
    let optionality: GoalCompiledPathResourceOptionality
    let placeholderState: GoalCompiledPathResourceHookPlaceholderState
}

struct GoalCompiledPathAppliedPack: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let displayName: String
    let matchConfidence: Double
    let matchedDomains: [LifeDomainKey]
    let matchReasons: [String]
    let provisional: Bool
}

struct GoalCompiledPathDependency: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathDependencyKind
    let sourceClaimIDs: [String]
    let sourceRecordIDs: [String]
    let blocking: Bool
    let relatedStageID: String?
}

struct GoalCompiledPathStage: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let orderIndex: Int
    let kind: GoalCompiledPathStageKind
    let dependencyIDs: [String]
    let prerequisiteHints: [String]
    let readinessHints: [String]
    let uncertainBecause: [GoalCompiledPathUncertaintyReason]
}

struct GoalCompiledPathBranch: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let branchType: GoalCompiledPathBranchType
    let summary: String
    let condition: String
    let targetCandidateID: String?
    let targetStageID: String?
    let posture: GoalPathCompilePosture
}

struct GoalCompiledPathCandidate: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let isPrimary: Bool
    let posture: GoalPathCompilePosture
    let safeForStarterPlanning: Bool
    let stages: [GoalCompiledPathStage]
    let dependencies: [GoalCompiledPathDependency]
    let branches: [GoalCompiledPathBranch]
    let assumptions: [GoalCompiledPathAssumption]
    let risks: [GoalCompiledPathRisk]
    let appliedPacks: [GoalCompiledPathAppliedPack]
    let requirementHints: [GoalCompiledPathRequirementHint]
    let readinessCriteria: [GoalCompiledPathReadinessCriterion]
    let resourceHooks: [GoalCompiledPathResourceHook]
    let blockingReasons: [GoalCompiledPathBlockingReason]
    let confidence: GoalCompiledPathConfidence

    init(
        id: String,
        title: String,
        summary: String,
        isPrimary: Bool,
        posture: GoalPathCompilePosture,
        safeForStarterPlanning: Bool,
        stages: [GoalCompiledPathStage],
        dependencies: [GoalCompiledPathDependency],
        branches: [GoalCompiledPathBranch],
        assumptions: [GoalCompiledPathAssumption],
        risks: [GoalCompiledPathRisk],
        appliedPacks: [GoalCompiledPathAppliedPack] = [],
        requirementHints: [GoalCompiledPathRequirementHint] = [],
        readinessCriteria: [GoalCompiledPathReadinessCriterion] = [],
        resourceHooks: [GoalCompiledPathResourceHook] = [],
        blockingReasons: [GoalCompiledPathBlockingReason],
        confidence: GoalCompiledPathConfidence
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.isPrimary = isPrimary
        self.posture = posture
        self.safeForStarterPlanning = safeForStarterPlanning
        self.stages = stages
        self.dependencies = dependencies
        self.branches = branches
        self.assumptions = assumptions
        self.risks = risks
        self.appliedPacks = appliedPacks
        self.requirementHints = requirementHints
        self.readinessCriteria = readinessCriteria
        self.resourceHooks = resourceHooks
        self.blockingReasons = blockingReasons
        self.confidence = confidence
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case isPrimary
        case posture
        case safeForStarterPlanning
        case stages
        case dependencies
        case branches
        case assumptions
        case risks
        case appliedPacks
        case requirementHints
        case readinessCriteria
        case resourceHooks
        case blockingReasons
        case confidence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        isPrimary = try container.decode(Bool.self, forKey: .isPrimary)
        posture = try container.decode(GoalPathCompilePosture.self, forKey: .posture)
        safeForStarterPlanning = try container.decode(Bool.self, forKey: .safeForStarterPlanning)
        stages = try container.decode([GoalCompiledPathStage].self, forKey: .stages)
        dependencies = try container.decode([GoalCompiledPathDependency].self, forKey: .dependencies)
        branches = try container.decode([GoalCompiledPathBranch].self, forKey: .branches)
        assumptions = try container.decode([GoalCompiledPathAssumption].self, forKey: .assumptions)
        risks = try container.decode([GoalCompiledPathRisk].self, forKey: .risks)
        appliedPacks = try container.decodeIfPresent([GoalCompiledPathAppliedPack].self, forKey: .appliedPacks) ?? []
        requirementHints = try container.decodeIfPresent([GoalCompiledPathRequirementHint].self, forKey: .requirementHints) ?? []
        readinessCriteria = try container.decodeIfPresent([GoalCompiledPathReadinessCriterion].self, forKey: .readinessCriteria) ?? []
        resourceHooks = try container.decodeIfPresent([GoalCompiledPathResourceHook].self, forKey: .resourceHooks) ?? []
        blockingReasons = try container.decode([GoalCompiledPathBlockingReason].self, forKey: .blockingReasons)
        confidence = try container.decode(GoalCompiledPathConfidence.self, forKey: .confidence)
    }
}

struct GoalCompiledPathUncertainty: Codable, Sendable, Equatable {
    let ambiguityActive: Bool
    let missingContextFields: [MissingFieldKey]
    let unresolvedQuestionIDs: [String]
    let alternateInterpretationsActive: Bool
    let knowledgeContextAttached: Bool
    let knowledgeContextRequired: Bool
}

struct GoalCompiledPathAuditEntry: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let kind: GoalCompiledPathAuditKind
    let sourceInterpretationID: String?
    let sourceDependencyID: String?
    let sourceRiskID: String?
    let sourceAssumptionID: String?
    let claimID: String?
    let sourceRecordID: String?
    let summary: String
}

struct GoalCompiledPathPackAuditEntry: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let packID: String
    let contributionKind: GoalCompiledPathPackAuditContributionKind
    let artifactID: String
    let targetCandidateID: String
    let targetStageID: String?
    let summary: String
}

struct GoalCompiledPathAuditMetadata: Codable, Sendable, Equatable {
    let entries: [GoalCompiledPathAuditEntry]
    let packEntries: [GoalCompiledPathPackAuditEntry]

    init(
        entries: [GoalCompiledPathAuditEntry],
        packEntries: [GoalCompiledPathPackAuditEntry] = []
    ) {
        self.entries = entries
        self.packEntries = packEntries
    }

    private enum CodingKeys: String, CodingKey {
        case entries
        case packEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entries = try container.decode([GoalCompiledPathAuditEntry].self, forKey: .entries)
        packEntries = try container.decodeIfPresent([GoalCompiledPathPackAuditEntry].self, forKey: .packEntries) ?? []
    }
}

struct GoalCompiledPath: Codable, Sendable, Equatable {
    let schemaVersion: String
    let sourceUnderstandingSchemaVersion: String
    let overallPosture: GoalPathCompilePosture
    let safeForStarterPlanning: Bool
    let candidates: [GoalCompiledPathCandidate]
    let uncertainty: GoalCompiledPathUncertainty
    let audit: GoalCompiledPathAuditMetadata
}

extension GoalCompiledPath {
    static func legacyFallback(from understanding: GoalUnderstanding) -> GoalCompiledPath {
        GoalCompiledPathCompilerCore().compile(understanding: understanding)
    }
}

struct GoalCompiledPathCompilerCore {
    func compile(understanding: GoalUnderstanding) -> GoalCompiledPath {
        let overallPosture = posture(for: understanding)
        let starterSafe = understanding.readiness.safeToCompile
        let assumptions = understanding.assumptions.map {
            GoalCompiledPathAssumption(
                id: $0.id,
                summary: $0.summary,
                rationale: $0.rationale,
                confidence: $0.confidence,
                source: $0.source,
                relatedField: $0.relatedField,
                safeForCompilation: $0.safeForCompilation
            )
        }
        let risks = understanding.risks.map {
            GoalCompiledPathRisk(
                id: $0.id,
                summary: $0.summary,
                kind: $0.kind,
                severity: $0.severity
            )
        }
        let uncertainty = GoalCompiledPathUncertainty(
            ambiguityActive: ambiguityActive(in: understanding),
            missingContextFields: Array(Set(understanding.clarification.missingContext.compactMap(\.field))).sorted { $0.rawValue < $1.rawValue },
            unresolvedQuestionIDs: understanding.clarification.unresolvedQuestions.map(\.id),
            alternateInterpretationsActive: understanding.clarification.alternateInterpretationsActive,
            knowledgeContextAttached: understanding.audit.evidence.contains(where: { $0.origin == .knowledgeContext }),
            knowledgeContextRequired: false
        )
        let candidateInputs = [understanding.primaryInterpretation] + understanding.alternateInterpretations
        let candidates = candidateInputs.enumerated().map { index, interpretation in
            let isPrimary = index == 0
            let candidatePosture = candidatePosture(
                overallPosture: overallPosture,
                understanding: understanding,
                interpretation: interpretation,
                isPrimary: isPrimary
            )
            let stages = makeStages(
                understanding: understanding,
                interpretation: interpretation,
                posture: candidatePosture
            )
            let dependencies = makeDependencies(
                understanding: understanding,
                stages: stages
            )
            let branches = makeBranches(
                understanding: understanding,
                interpretation: interpretation,
                isPrimary: isPrimary,
                posture: candidatePosture,
                candidateID: candidateID(for: interpretation, isPrimary: isPrimary)
            )

            return GoalCompiledPathCandidate(
                id: candidateID(for: interpretation, isPrimary: isPrimary),
                title: isPrimary ? "Primary path" : "Alternate path",
                summary: candidateSummary(
                    understanding: understanding,
                    interpretation: interpretation,
                    isPrimary: isPrimary
                ),
                isPrimary: isPrimary,
                posture: candidatePosture,
                safeForStarterPlanning: starterSafe && candidatePosture != .blocked,
                stages: stages,
                dependencies: dependencies,
                branches: branches,
                assumptions: assumptions,
                risks: risks,
                appliedPacks: [],
                requirementHints: [],
                readinessCriteria: [],
                resourceHooks: [],
                blockingReasons: blockingReasons(from: understanding, posture: candidatePosture),
                confidence: GoalCompiledPathConfidence(
                    overall: understanding.confidence.overall,
                    score: confidenceScore(
                        understanding: understanding,
                        isPrimary: isPrimary
                    ),
                    uncertaintyTags: understanding.confidence.uncertaintyTags
                )
            )
        }

        let audit = GoalCompiledPathAuditMetadata(
            entries: makeAuditEntries(
                understanding: understanding,
                candidates: candidates
            ),
            packEntries: []
        )

        return GoalCompiledPath(
            schemaVersion: goalPathCompilerSchemaVersion,
            sourceUnderstandingSchemaVersion: understanding.schemaVersion,
            overallPosture: overallPosture,
            safeForStarterPlanning: starterSafe && overallPosture != .blocked,
            candidates: candidates,
            uncertainty: uncertainty,
            audit: audit
        )
    }

    private func posture(for understanding: GoalUnderstanding) -> GoalPathCompilePosture {
        guard understanding.readiness.safeToCompile else {
            return .blocked
        }
        if ambiguityActive(in: understanding) ||
            understanding.assumptions.isEmpty == false ||
            understanding.risks.isEmpty == false {
            return .provisional
        }
        return .stronger
    }

    private func ambiguityActive(in understanding: GoalUnderstanding) -> Bool {
        understanding.clarification.alternateInterpretationsActive ||
            understanding.timeline.unresolvedAmbiguity ||
            understanding.domains.isAmbiguous ||
            understanding.clarification.unresolvedQuestions.isEmpty == false ||
            understanding.clarification.missingContext.isEmpty == false ||
            understanding.confidence.uncertaintyTags.isEmpty == false
    }

    private func candidatePosture(
        overallPosture: GoalPathCompilePosture,
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        isPrimary: Bool
    ) -> GoalPathCompilePosture {
        if overallPosture == .blocked {
            return .blocked
        }
        if isPrimary == false || understanding.alternateInterpretations.contains(interpretation) {
            return .provisional
        }
        return overallPosture
    }

    private func candidateID(for interpretation: GoalUnderstandingInterpretation, isPrimary: Bool) -> String {
        isPrimary ? "candidate-\(interpretation.id)" : "candidate-alternate-\(interpretation.id)"
    }

    private func candidateSummary(
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        isPrimary: Bool
    ) -> String {
        if isPrimary {
            return "Compile a conservative path from the primary interpretation without hiding remaining uncertainty."
        }
        return "Preserve an alternate structural path while ambiguity remains active: \(interpretation.summary)"
    }

    private func makeStages(
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        posture: GoalPathCompilePosture
    ) -> [GoalCompiledPathStage] {
        let subject = understanding.subject.normalizedTitle
        let stageKinds: [GoalCompiledPathStageKind] = [
            .setup,
            .readiness,
            .firstProof,
            .advancement,
            .reviewFinish
        ]
        let uncertaintyReasons = stageUncertaintyReasons(
            understanding: understanding,
            posture: posture
        )

        return stageKinds.enumerated().map { index, kind in
            let previousStageID = index > 0 ? stageID(for: interpretation, kind: stageKinds[index - 1]) : nil
            return GoalCompiledPathStage(
                id: stageID(for: interpretation, kind: kind),
                title: stageTitle(for: kind),
                summary: stageSummary(for: kind, subject: subject),
                orderIndex: index,
                kind: kind,
                dependencyIDs: previousStageID.map { [stageOrderingDependencyID(previousStageID: $0, nextStageID: stageID(for: interpretation, kind: kind))] } ?? [],
                prerequisiteHints: stagePrerequisiteHints(for: kind, understanding: understanding),
                readinessHints: stageReadinessHints(for: kind, understanding: understanding),
                uncertainBecause: uncertaintyReasons
            )
        }
    }

    private func stageID(
        for interpretation: GoalUnderstandingInterpretation,
        kind: GoalCompiledPathStageKind
    ) -> String {
        "stage-\(interpretation.id)-\(kind.rawValue)"
    }

    private func stageOrderingDependencyID(
        previousStageID: String,
        nextStageID: String
    ) -> String {
        "stage-order-\(previousStageID)-\(nextStageID)"
    }

    private func stageTitle(for kind: GoalCompiledPathStageKind) -> String {
        switch kind {
        case .setup: return "Set up"
        case .readiness: return "Establish readiness"
        case .firstProof: return "Reach first proof"
        case .advancement: return "Advance"
        case .reviewFinish: return "Review and finish"
        }
    }

    private func stageSummary(for kind: GoalCompiledPathStageKind, subject: String) -> String {
        switch kind {
        case .setup:
            return "Frame the goal and clarify what \(subject.lowercased()) is trying to achieve."
        case .readiness:
            return "Reduce the main readiness gaps before deeper commitment."
        case .firstProof:
            return "Produce the first visible proof that the path is working."
        case .advancement:
            return "Build on the first proof without pretending the path is final."
        case .reviewFinish:
            return "Review what changed and decide whether the path is strong enough to finish or should branch."
        }
    }

    private func stagePrerequisiteHints(
        for kind: GoalCompiledPathStageKind,
        understanding: GoalUnderstanding
    ) -> [String] {
        switch kind {
        case .setup:
            return understanding.constraints.map(\.summary)
        case .readiness:
            return understanding.dependencies.map(\.summary)
        case .firstProof, .advancement, .reviewFinish:
            return []
        }
    }

    private func stageReadinessHints(
        for kind: GoalCompiledPathStageKind,
        understanding: GoalUnderstanding
    ) -> [String] {
        switch kind {
        case .setup:
            return understanding.assumptions.map(\.summary)
        case .readiness:
            return understanding.risks.map(\.summary)
        case .firstProof:
            return understanding.successDefinition.summary.map { [$0] } ?? []
        case .advancement, .reviewFinish:
            return []
        }
    }

    private func stageUncertaintyReasons(
        understanding: GoalUnderstanding,
        posture: GoalPathCompilePosture
    ) -> [GoalCompiledPathUncertaintyReason] {
        var reasons: [GoalCompiledPathUncertaintyReason] = []
        if understanding.clarification.alternateInterpretationsActive || understanding.timeline.unresolvedAmbiguity {
            reasons.append(.activeAmbiguity)
        }
        if understanding.clarification.missingContext.isEmpty == false {
            reasons.append(.missingContext)
        }
        if understanding.assumptions.isEmpty == false {
            reasons.append(.carriedAssumption)
        }
        if understanding.risks.isEmpty == false {
            reasons.append(.carriedRisk)
        }
        if posture == .blocked {
            reasons.append(.blockedReadiness)
        }
        return reasons
    }

    private func makeDependencies(
        understanding: GoalUnderstanding,
        stages: [GoalCompiledPathStage]
    ) -> [GoalCompiledPathDependency] {
        var dependencies = understanding.dependencies.map {
            GoalCompiledPathDependency(
                id: $0.id,
                summary: $0.summary,
                kind: compiledDependencyKind(for: $0.kind),
                sourceClaimIDs: $0.sourceClaimIDs,
                sourceRecordIDs: $0.sourceRecordIDs,
                blocking: understanding.readiness.safeToCompile == false && $0.kind == .readiness,
                relatedStageID: stages.first(where: { $0.kind == .readiness })?.id
            )
        }

        for pair in zip(stages, stages.dropFirst()) {
            dependencies.append(
                GoalCompiledPathDependency(
                    id: stageOrderingDependencyID(previousStageID: pair.0.id, nextStageID: pair.1.id),
                    summary: "\(pair.0.title) should precede \(pair.1.title).",
                    kind: .stageOrdering,
                    sourceClaimIDs: [],
                    sourceRecordIDs: [],
                    blocking: false,
                    relatedStageID: pair.1.id
                )
            )
        }

        return dependencies
    }

    private func compiledDependencyKind(for kind: GoalUnderstandingDependencyKind) -> GoalCompiledPathDependencyKind {
        switch kind {
        case .readiness:
            return .readiness
        case .support:
            return .support
        case .timeline:
            return .timeline
        case .knowledge:
            return .knowledge
        }
    }

    private func makeBranches(
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        isPrimary: Bool,
        posture: GoalPathCompilePosture,
        candidateID currentCandidateID: String
    ) -> [GoalCompiledPathBranch] {
        var branches: [GoalCompiledPathBranch] = []

        if isPrimary {
            branches.append(contentsOf: understanding.alternateInterpretations.map {
                GoalCompiledPathBranch(
                    id: "branch-\(currentCandidateID)-\($0.id)",
                    branchType: .alternateInterpretation,
                    summary: "Keep the alternate interpretation available instead of collapsing to one final path.",
                    condition: "Switch here if the alternate reading becomes the better fit.",
                    targetCandidateID: candidateID(for: $0, isPrimary: false),
                    targetStageID: nil,
                    posture: .provisional
                )
            })
        }

        if posture == .blocked {
            branches.append(
                GoalCompiledPathBranch(
                    id: "branch-\(currentCandidateID)-blocked",
                    branchType: .blocked,
                    summary: "The path remains blocked until clarification is sufficient.",
                    condition: "Clarify the blocking fields before treating this as starter-safe.",
                    targetCandidateID: nil,
                    targetStageID: "stage-\(interpretation.id)-setup",
                    posture: .blocked
                )
            )
        } else if understanding.assumptions.isEmpty == false || understanding.risks.isEmpty == false {
            branches.append(
                GoalCompiledPathBranch(
                    id: "branch-\(currentCandidateID)-fallback",
                    branchType: .fallback,
                    summary: "Keep a starter-safe fallback branch while uncertainty remains material.",
                    condition: "Use this branch when assumptions still shape the next step.",
                    targetCandidateID: nil,
                    targetStageID: "stage-\(interpretation.id)-setup",
                    posture: .provisional
                )
            )
        }

        return branches
    }

    private func blockingReasons(
        from understanding: GoalUnderstanding,
        posture: GoalPathCompilePosture
    ) -> [GoalCompiledPathBlockingReason] {
        guard posture == .blocked else { return [] }

        var reasons = understanding.clarification.missingContext
            .filter(\.blocksCompilation)
            .map {
                GoalCompiledPathBlockingReason(
                    id: "blocking-\($0.id)",
                    summary: $0.reason,
                    field: $0.field
                )
            }

        reasons.append(
            contentsOf: understanding.clarification.unresolvedQuestions
                .filter(\.blocking)
                .map {
                    GoalCompiledPathBlockingReason(
                        id: "blocking-\($0.id)",
                        summary: $0.prompt,
                        field: $0.targetField
                    )
                }
        )

        return reasons
    }

    private func confidenceScore(
        understanding: GoalUnderstanding,
        isPrimary: Bool
    ) -> Double {
        let base = understanding.confidence.score
        if isPrimary {
            return roundToTwoDecimals(base)
        }
        return roundToTwoDecimals(max(0.0, base - 0.12))
    }

    private func makeAuditEntries(
        understanding: GoalUnderstanding,
        candidates: [GoalCompiledPathCandidate]
    ) -> [GoalCompiledPathAuditEntry] {
        var entries: [GoalCompiledPathAuditEntry] = []

        entries.append(
            GoalCompiledPathAuditEntry(
                id: "audit-interpretation-\(understanding.primaryInterpretation.id)",
                kind: .interpretationSelection,
                sourceInterpretationID: understanding.primaryInterpretation.id,
                sourceDependencyID: nil,
                sourceRiskID: nil,
                sourceAssumptionID: nil,
                claimID: nil,
                sourceRecordID: nil,
                summary: "Primary interpretation selected as the lead path candidate."
            )
        )

        entries.append(
            contentsOf: understanding.dependencies.map {
                GoalCompiledPathAuditEntry(
                    id: "audit-dependency-\($0.id)",
                    kind: .dependencyCarryForward,
                    sourceInterpretationID: nil,
                    sourceDependencyID: $0.id,
                    sourceRiskID: nil,
                    sourceAssumptionID: nil,
                    claimID: $0.sourceClaimIDs.first,
                    sourceRecordID: $0.sourceRecordIDs.first,
                    summary: $0.summary
                )
            }
        )

        entries.append(
            contentsOf: understanding.assumptions.map {
                GoalCompiledPathAuditEntry(
                    id: "audit-assumption-\($0.id)",
                    kind: .assumptionCarryForward,
                    sourceInterpretationID: nil,
                    sourceDependencyID: nil,
                    sourceRiskID: nil,
                    sourceAssumptionID: $0.id,
                    claimID: nil,
                    sourceRecordID: nil,
                    summary: $0.summary
                )
            }
        )

        entries.append(
            contentsOf: understanding.risks.map {
                GoalCompiledPathAuditEntry(
                    id: "audit-risk-\($0.id)",
                    kind: .riskCarryForward,
                    sourceInterpretationID: nil,
                    sourceDependencyID: nil,
                    sourceRiskID: $0.id,
                    sourceAssumptionID: nil,
                    claimID: nil,
                    sourceRecordID: nil,
                    summary: $0.summary
                )
            }
        )

        entries.append(
            contentsOf: understanding.audit.evidence
                .filter { $0.origin == .knowledgeContext }
                .map {
                    GoalCompiledPathAuditEntry(
                        id: "audit-knowledge-\($0.id)",
                        kind: .knowledgeEvidence,
                        sourceInterpretationID: nil,
                        sourceDependencyID: nil,
                        sourceRiskID: nil,
                        sourceAssumptionID: nil,
                        claimID: $0.claimID,
                        sourceRecordID: $0.sourceRecordID,
                        summary: $0.summary
                    )
                }
        )

        if entries.isEmpty, let candidate = candidates.first {
            entries.append(
                GoalCompiledPathAuditEntry(
                    id: "audit-candidate-\(candidate.id)",
                    kind: .interpretationSelection,
                    sourceInterpretationID: understanding.primaryInterpretation.id,
                    sourceDependencyID: nil,
                    sourceRiskID: nil,
                    sourceAssumptionID: nil,
                    claimID: nil,
                    sourceRecordID: nil,
                    summary: candidate.summary
                )
            )
        }

        return entries
    }

    private func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }
}
