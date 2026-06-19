import Foundation

struct StepCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceStepID: String
    let sourceCandidateID: String?
    let source: CandidateSource
    let kind: StepCandidateKind
    let title: String
    let summary: String
    let accessibilitySummary: String
    let estimatedMinutes: Int
    let estimatedEnergyCost: Double
    let accessRequirements: [String]
    let equipmentRequirements: [String]
    let facilityRequirements: [String]
    let goalContribution: Double
    let deadlineContribution: Double
    let futurePressureImpact: Double
    let opportunityCost: Double
    let approvalRequired: Bool
    let validity: CandidateValidity
    let tradeoffs: [CandidateTradeoff]
    let rejectionRisk: CandidateRejectionRisk
    let impactSimulation: StepImpactSimulation
    let score: CandidateScore
    let normalizedSemanticSignature: String

    init(
        sourceStepID: String,
        sourceCandidateID: String? = nil,
        source: CandidateSource,
        kind: StepCandidateKind,
        title: String,
        summary: String,
        accessibilitySummary: String,
        estimatedMinutes: Int,
        estimatedEnergyCost: Double,
        accessRequirements: [String] = [],
        equipmentRequirements: [String] = [],
        facilityRequirements: [String] = [],
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        approvalRequired: Bool,
        validity: CandidateValidity,
        tradeoffs: [CandidateTradeoff] = [],
        rejectionRisk: CandidateRejectionRisk,
        rejectionFitScore: Double = 0,
        evidenceFactorIDs: [String] = [],
        semanticAnchor: String,
        deadlineTargetDate: String? = nil,
        generatedAt: String? = nil,
        openCapacityWindowCount: Int = 0,
        protectedCapacityWindowCount: Int = 0,
        sourceStepIsOptional: Bool = false,
        sourceStepIsExecutable: Bool = true,
        rejectionHistoryCount: Int = 0,
        impactSimulation: StepImpactSimulation? = nil
    ) {
        self.sourceStepID = Self.normalizedRequired(sourceStepID)
        self.sourceCandidateID = Self.normalizedOptional(sourceCandidateID)
        self.source = source
        self.kind = kind
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedRequired(summary)
        self.accessibilitySummary = Self.normalizedRequired(accessibilitySummary)
        self.estimatedMinutes = max(0, estimatedMinutes)
        self.estimatedEnergyCost = Self.clamp(estimatedEnergyCost, lowerBound: 0, upperBound: 1)
        self.accessRequirements = Self.normalizedStrings(accessRequirements)
        self.equipmentRequirements = Self.normalizedStrings(equipmentRequirements)
        self.facilityRequirements = Self.normalizedStrings(facilityRequirements)
        self.goalContribution = Self.clamp(goalContribution)
        self.deadlineContribution = Self.clamp(deadlineContribution)
        self.futurePressureImpact = Self.clamp(futurePressureImpact)
        self.opportunityCost = Self.clamp(opportunityCost)
        self.approvalRequired = approvalRequired
        self.validity = validity
        self.tradeoffs = tradeoffs
        self.rejectionRisk = rejectionRisk

        let normalizedSemanticSignature = Self.semanticSignature(
            semanticAnchor: semanticAnchor,
            kind: kind,
            title: self.title,
            summary: self.summary,
            accessRequirements: self.accessRequirements,
            equipmentRequirements: self.equipmentRequirements,
            facilityRequirements: self.facilityRequirements,
            estimatedMinutes: self.estimatedMinutes,
            estimatedEnergyCost: self.estimatedEnergyCost,
            goalContribution: self.goalContribution,
            deadlineContribution: self.deadlineContribution,
            futurePressureImpact: self.futurePressureImpact,
            opportunityCost: self.opportunityCost,
            approvalRequired: self.approvalRequired,
            validity: validity,
            evidenceFactorIDs: evidenceFactorIDs
        )
        self.normalizedSemanticSignature = normalizedSemanticSignature
        let candidateID = Self.stableIdentifier(
            prefix: "step-candidate",
            components: [
                kind.rawValue,
                self.sourceStepID,
                normalizedSemanticSignature
            ]
        )
        self.impactSimulation = impactSimulation ?? StepImpactSimulation.make(
            goalID: nil,
            kind: kind,
            sourceStepID: self.sourceStepID,
            sourceCandidateID: self.sourceCandidateID,
            candidateID: candidateID,
            generatedAt: generatedAt,
            deadlineTargetDate: deadlineTargetDate,
            estimatedMinutes: self.estimatedMinutes,
            goalContribution: self.goalContribution,
            deadlineContribution: self.deadlineContribution,
            futurePressureImpact: self.futurePressureImpact,
            opportunityCost: self.opportunityCost,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: sourceStepIsExecutable,
            rejectionHistoryCount: rejectionHistoryCount,
            approvalRequired: approvalRequired,
            validity: validity
        )
        self.id = candidateID
        self.score = CandidateScore(
            durationScore: Self.durationScore(for: estimatedMinutes, kind: kind),
            energyScore: Self.energyScore(for: kind, estimatedEnergyCost: self.estimatedEnergyCost),
            accessScore: Self.accessScore(
                kind: kind,
                accessRequirements: self.accessRequirements,
                equipmentRequirements: self.equipmentRequirements,
                facilityRequirements: self.facilityRequirements
            ),
            goalContributionScore: self.goalContribution,
            deadlineContributionScore: self.deadlineContribution,
            futurePressureScore: self.futurePressureImpact,
            opportunityCostScore: 1 - self.opportunityCost,
            approvalRequirementScore: approvalRequired ? 0.35 : 1,
            validityScore: Self.validityScore(for: validity),
            factorEvidenceScore: Self.factorEvidenceScore(for: evidenceFactorIDs),
            rejectionFitScore: rejectionFitScore,
            evidenceFactorIDs: evidenceFactorIDs
        )
    }
}
