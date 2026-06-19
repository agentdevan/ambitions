import Foundation

extension StepCandidateFieldGenerator {

    func validity(
        for kind: StepCandidateKind,
        factorEvidenceIDs: [String],
        missingContext: Bool,
        sourceStep: CompiledStep
    ) -> CandidateValidity {
        if kind == .fallback {
            return .fallback
        }
        if sourceStep.isExecutable == false {
            return .blocked
        }
        if missingContext {
            return factorEvidenceIDs.isEmpty ? .fallback : .review
        }
        if factorEvidenceIDs.isEmpty {
            return .review
        }
        return .preferred
    }


    func tradeoffs(
        for kind: StepCandidateKind,
        sourceStep: CompiledStep,
        estimatedMinutes: Int,
        estimatedEnergyCost: Double,
        approvalRequired: Bool,
        missingContext: Bool
    ) -> [CandidateTradeoff] {
        var items: [CandidateTradeoff] = []
        items.append(
            CandidateTradeoff(
                id: "tradeoff.\(kind.rawValue).benefit",
                label: "Benefit",
                benefit: kind.semanticLabel,
                cost: summary(for: kind, sourceStep: sourceStep),
                note: nil
            )
        )
        items.append(
            CandidateTradeoff(
                id: "tradeoff.\(kind.rawValue).cost",
                label: "Cost",
                benefit: "Estimated \(estimatedMinutes) minute pass",
                cost: estimatedEnergyCost > 0.5 ? "Higher energy" : "Lower energy",
                note: approvalRequired ? "Approval is required before this path can run." : nil
            )
        )
        if missingContext {
            items.append(
                CandidateTradeoff(
                    id: "tradeoff.\(kind.rawValue).review",
                    label: "Context",
                    benefit: "Review-safe",
                    cost: "The runtime is missing context.",
                    note: nil
                )
            )
        }
        return items
    }


    func rejectionRisk(
        for kind: StepCandidateKind,
        factorEvidenceIDs: [String],
        validity: CandidateValidity,
        approvalRequired: Bool,
        missingContext: Bool,
        factorLedger: PersonalizationFactorLedger?
    ) -> CandidateRejectionRisk {
        let level: CandidateRiskLevel
        if validity == .blocked || approvalRequired || missingContext {
            level = .high
        } else if factorEvidenceIDs.isEmpty {
            level = .moderate
        } else if factorLedger?.confidenceBand == .reviewNeeded {
            level = .moderate
        } else {
            level = .low
        }
        return CandidateRejectionRisk(
            id: "risk.\(kind.rawValue)",
            level: level,
            summary: riskSummary(for: kind, validity: validity, approvalRequired: approvalRequired, missingContext: missingContext),
            factorIDs: factorEvidenceIDs,
            requiresReview: level != .low
        )
    }


    func riskSummary(
        for kind: StepCandidateKind,
        validity: CandidateValidity,
        approvalRequired: Bool,
        missingContext: Bool
    ) -> String {
        if validity == .blocked {
            return "The source step is not executable."
        }
        if missingContext {
            return "The runtime is missing enough context for a stronger ranking."
        }
        if approvalRequired {
            return "This path needs approval before it can be treated as the clear winner."
        }
        switch kind {
        case .fallback:
            return "Fallback paths should not be treated as a final answer."
        case .learningResearch:
            return "Research paths can slow execution if the answer is already known."
        case .adminSetup:
            return "Setup paths help later execution but can delay immediate progress."
        default:
            return "The candidate remains review-safe but still revisable."
        }
    }


    func relevantFactors(
        for kind: StepCandidateKind,
        factorLedger: PersonalizationFactorLedger?
    ) -> [PersonalizationFactorLedgerFactor] {
        guard let factorLedger else { return [] }
        let relevantTypes: Set<PersonalizationFactorLedgerFactorType>
        switch kind {
        case .directBest:
            relevantTypes = [.goalRequirement, .deadlinePressure, .availabilityWindow, .trustAllowance, .recentProof]
        case .lighter:
            relevantTypes = [.energyPattern, .recoveryConstraint, .recentDrift, .safetyConstraint]
        case .shorter:
            relevantTypes = [.deadlinePressure, .availabilityWindow, .timeOfDayFit, .executionBehavior]
        case .lowerEnergy:
            relevantTypes = [.energyPattern, .recoveryConstraint, .safetyConstraint, .timeOfDayFit]
        case .locationCompatible:
            relevantTypes = [.availabilityWindow, .travelFit, .transportationConstraint, .facilityAccess]
        case .noEquipment:
            relevantTypes = [.equipmentAccess, .facilityAccess, .availabilityWindow]
        case .recoverySafe:
            relevantTypes = [.recoveryConstraint, .safetyConstraint, .pastFailure, .recentDrift]
        case .adminSetup:
            relevantTypes = [.executionBehavior, .trustAllowance, .recentProof, .goalRequirement]
        case .learningResearch:
            relevantTypes = [.historicalContext, .recentDrift, .eligibilityPathway, .preference]
        case .proofGathering:
            relevantTypes = [.recentProof, .executionBehavior, .trustAllowance, .historicalContext]
        case .prerequisite:
            relevantTypes = [.dependencyConstraint, .historicalContext, .eligibilityPathway, .goalRequirement]
        case .maintenance:
            relevantTypes = [.executionBehavior, .preference, .recentProof, .pastSuccess]
        case .catchUp:
            relevantTypes = [.deadlinePressure, .historicalContext, .pastFailure, .recentDrift]
        case .substitution:
            relevantTypes = [.transportationConstraint, .availabilityWindow, .facilityAccess, .goalRequirement]
        case .parallelPath:
            relevantTypes = [.availabilityWindow, .goalRequirement, .deadlinePressure, .preference]
        case .fallback:
            relevantTypes = [.recentDrift, .historicalContext, .executionBehavior]
        }
        return factorLedger.factors.filter { relevantTypes.contains($0.factorType) }
    }


    func deadlineDate(for context: CandidateGenerationContext, sourceStep: CompiledStep) -> Date? {
        if let override = context.deadlineTargetDate.flatMap(DomainTimestamp.date(from:)) {
            return override
        }
        if let stepDate = sourceStep.targetDate.flatMap(DomainTimestamp.date(from:)) {
            return stepDate
        }
        return context.compilerOutput?.compiledSteps.compactMap(\.targetDate).compactMap(DomainTimestamp.date(from:)).sorted().first
    }


    func earliestTargetDate(in sourceSteps: [CompiledStep]) -> String? {
        sourceSteps
            .compactMap { $0.targetDate.flatMap(DomainTimestamp.date(from:)) }
            .sorted()
            .first
            .map(DomainTimestamp.string(from:))
    }


    func deadlineDays(from generatedAt: String, to deadlineDate: Date?) -> Int? {
        guard let deadlineDate, let generatedAtDate = DomainTimestamp.date(from: generatedAt) else {
            return nil
        }
        let interval = deadlineDate.timeIntervalSince(generatedAtDate)
        return Int((interval / 86_400).rounded(.down))
    }
}
