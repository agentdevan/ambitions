import Foundation

extension StepCandidateFieldGenerator {

    func accessComponents(
        for kind: StepCandidateKind,
        sourceStep: CompiledStep,
        context: CandidateGenerationContext
    ) -> (accessRequirements: [String], equipmentRequirements: [String], facilityRequirements: [String]) {
        let projection = context.lifeContextProjection
        let locationLabel = projection?.travelModel.locationLabel
        let anchors = projection?.availableOpportunityAnchors.map(\.title) ?? []
        switch kind {
        case .locationCompatible:
            return (
                accessRequirements: locationLabel.map { [$0] } ?? anchors.prefix(1).map { $0 },
                equipmentRequirements: [],
                facilityRequirements: anchors.isEmpty ? ["Local access"] : anchors.prefix(2).map { $0 }
            )
        case .noEquipment:
            return (accessRequirements: [], equipmentRequirements: [], facilityRequirements: anchors.prefix(1).map { $0 })
        case .adminSetup:
            return (accessRequirements: ["Permission to prepare the setup"], equipmentRequirements: [], facilityRequirements: [])
        case .learningResearch:
            return (accessRequirements: [], equipmentRequirements: [], facilityRequirements: ["Library", "Notes"])
        case .proofGathering:
            return (accessRequirements: [], equipmentRequirements: [], facilityRequirements: ["Proof capture"])
        case .prerequisite:
            return (accessRequirements: sourceStep.contextRequirements, equipmentRequirements: [], facilityRequirements: [])
        case .maintenance:
            return (accessRequirements: [], equipmentRequirements: [], facilityRequirements: [])
        case .catchUp:
            return (accessRequirements: sourceStep.contextRequirements, equipmentRequirements: [], facilityRequirements: [])
        case .substitution:
            return (accessRequirements: anchors.prefix(1).map { $0 }, equipmentRequirements: [], facilityRequirements: [])
        case .parallelPath:
            return (accessRequirements: [], equipmentRequirements: [], facilityRequirements: anchors.prefix(2).map { $0 })
        case .recoverySafe:
            return (accessRequirements: [], equipmentRequirements: [], facilityRequirements: [])
        case .lighter, .shorter, .lowerEnergy, .directBest, .fallback:
            return (accessRequirements: sourceStep.contextRequirements, equipmentRequirements: [], facilityRequirements: [])
        }
    }


    func estimatedMinutes(
        for kind: StepCandidateKind,
        sourceStep: CompiledStep,
        deadlineDays: Int?,
        missingContext: Bool
    ) -> Int {
        let base = max(1, sourceStep.repeatEveryDays ?? 12)
        let adjusted: Int
        switch kind {
        case .directBest:
            adjusted = base
        case .lighter:
            adjusted = max(3, base - 4)
        case .shorter:
            adjusted = max(2, base / 2)
        case .lowerEnergy:
            adjusted = max(4, base - 3)
        case .locationCompatible:
            adjusted = base
        case .noEquipment:
            adjusted = max(4, base - 1)
        case .recoverySafe:
            adjusted = max(4, base - 2)
        case .adminSetup:
            adjusted = max(5, base - 2)
        case .learningResearch:
            adjusted = max(8, base + 2)
        case .proofGathering:
            adjusted = max(5, base - 5)
        case .prerequisite:
            adjusted = max(5, base - 3)
        case .maintenance:
            adjusted = max(5, base - 4)
        case .catchUp:
            adjusted = max(6, base - 1)
        case .substitution:
            adjusted = max(5, base - 2)
        case .parallelPath:
            adjusted = base
        case .fallback:
            adjusted = missingContext ? 6 : max(5, base - 4)
        }

        if let deadlineDays {
            if deadlineDays <= 3 {
                return max(3, adjusted - 2)
            }
            if deadlineDays >= 30 {
                return adjusted + 1
            }
        }
        return adjusted
    }


    func estimatedEnergyCost(
        for kind: StepCandidateKind,
        sourceStep: CompiledStep,
        missingContext: Bool,
        factorLedger: PersonalizationFactorLedger?
    ) -> Double {
        let baseline: Double
        switch kind {
        case .directBest:
            baseline = 0.52
        case .lighter:
            baseline = 0.38
        case .shorter:
            baseline = 0.34
        case .lowerEnergy:
            baseline = 0.28
        case .locationCompatible:
            baseline = 0.47
        case .noEquipment:
            baseline = 0.31
        case .recoverySafe:
            baseline = 0.2
        case .adminSetup:
            baseline = 0.48
        case .learningResearch:
            baseline = 0.55
        case .proofGathering:
            baseline = 0.27
        case .prerequisite:
            baseline = 0.42
        case .maintenance:
            baseline = 0.24
        case .catchUp:
            baseline = 0.45
        case .substitution:
            baseline = 0.36
        case .parallelPath:
            baseline = 0.51
        case .fallback:
            baseline = missingContext ? 0.18 : 0.3
        }

        if factorLedger?.factors.contains(where: { $0.factorType == .recoveryConstraint || $0.factorType == .safetyConstraint }) == true {
            return max(0.1, baseline - 0.08)
        }
        if sourceStep.isOptional {
            return max(0.1, baseline - 0.03)
        }
        return baseline
    }


    func goalContribution(for kind: StepCandidateKind, sourceStep: CompiledStep, factorLedger: PersonalizationFactorLedger?) -> Double {
        switch kind {
        case .directBest:
            return 1
        case .parallelPath:
            return 0.88
        case .proofGathering:
            return 0.8
        case .prerequisite:
            return 0.76
        case .adminSetup:
            return 0.68
        case .catchUp:
            return 0.64
        case .substitution:
            return 0.62
        case .locationCompatible:
            return 0.72
        case .noEquipment:
            return 0.7
        case .lighter:
            return 0.66
        case .shorter:
            return 0.64
        case .lowerEnergy:
            return 0.69
        case .recoverySafe:
            return 0.63
        case .learningResearch:
            return 0.56
        case .maintenance:
            return 0.58
        case .fallback:
            return factorLedger?.missingContextQuestions.isEmpty == false ? 0.42 : 0.5
        }
    }


    func deadlineContribution(
        for kind: StepCandidateKind,
        deadlineDays: Int?,
        factorLedger: PersonalizationFactorLedger?
    ) -> Double {
        let urgency: Double
        if let deadlineDays {
            switch deadlineDays {
            case ...1:
                urgency = 1
            case ...3:
                urgency = 0.92
            case ...7:
                urgency = 0.82
            case ...14:
                urgency = 0.7
            default:
                urgency = 0.54
            }
        } else {
            urgency = factorLedger?.factors.contains(where: { $0.factorType == .deadlinePressure }) == true ? 0.76 : 0.56
        }

        switch kind {
        case .directBest, .shorter, .proofGathering, .catchUp:
            return min(1, urgency + 0.06)
        case .prerequisite, .adminSetup:
            return min(1, urgency + 0.02)
        case .fallback:
            return min(1, urgency - 0.14)
        default:
            return urgency
        }
    }


    func futurePressureImpact(
        for kind: StepCandidateKind,
        factorLedger: PersonalizationFactorLedger?,
        missingContext: Bool
    ) -> Double {
        let hasPressure = factorLedger?.factors.contains(where: { $0.factorType == .deadlinePressure || $0.factorType == .recentDrift }) == true
        switch kind {
        case .prerequisite, .proofGathering, .adminSetup:
            return hasPressure ? 0.92 : 0.82
        case .maintenance, .parallelPath, .directBest:
            return hasPressure ? 0.8 : 0.7
        case .catchUp, .substitution:
            return hasPressure ? 0.84 : 0.74
        case .fallback:
            return missingContext ? 0.4 : 0.54
        default:
            return hasPressure ? 0.68 : 0.58
        }
    }


    func opportunityCost(
        kind: StepCandidateKind,
        estimatedMinutes: Int,
        estimatedEnergyCost: Double,
        approvalRequired: Bool
    ) -> Double {
        let durationFactor = min(1, Double(estimatedMinutes) / 30)
        let energyFactor = estimatedEnergyCost
        let approvalFactor = approvalRequired ? 0.18 : 0
        let kindAdjustment: Double
        switch kind {
        case .proofGathering, .maintenance, .shorter, .fallback:
            kindAdjustment = -0.08
        case .learningResearch, .adminSetup, .parallelPath:
            kindAdjustment = 0.04
        default:
            kindAdjustment = 0
        }
        return max(0, min(1, (durationFactor * 0.55) + (energyFactor * 0.35) + approvalFactor + kindAdjustment))
    }


    func approvalRequired(
        for kind: StepCandidateKind,
        sourceStep: CompiledStep,
        context: CandidateGenerationContext,
        factorLedger: PersonalizationFactorLedger?,
        missingContext: Bool,
        deadlineDays: Int?,
        deadlineContribution: Double,
        futurePressureImpact: Double
    ) -> Bool {
        if missingContext {
            return true
        }

        if materialTimelineApprovalRequired(
            kind: kind,
            sourceStep: sourceStep,
            deadlineDays: deadlineDays,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact
        ) {
            return true
        }

        switch kind {
        case .adminSetup, .learningResearch, .substitution:
            return true
        case .locationCompatible:
            return context.lifeContextProjection?.availableOpportunityAnchors.isEmpty ?? true
        case .proofGathering:
            return factorLedger?.replayProjection.canReplay == false
        case .fallback:
            return true
        default:
            return sourceStep.contextRequirements.isEmpty == false && (context.lifeContextProjection?.hardConstraints.isEmpty ?? true)
        }
    }


    func materialTimelineApprovalRequired(
        kind: StepCandidateKind,
        sourceStep: CompiledStep,
        deadlineDays: Int?,
        deadlineContribution: Double,
        futurePressureImpact: Double
    ) -> Bool {
        guard sourceStep.isExecutable else { return false }

        let deadlinePressureRequiresApproval: Bool
        if let deadlineDays {
            deadlinePressureRequiresApproval = deadlineDays <= 3
        } else {
            deadlinePressureRequiresApproval = deadlineContribution < 0.8 || futurePressureImpact < 0.8
        }

        guard deadlinePressureRequiresApproval else { return false }

        switch kind {
        case .lighter, .shorter, .lowerEnergy, .catchUp, .substitution, .parallelPath:
            return true
        case .adminSetup, .learningResearch, .proofGathering, .prerequisite, .maintenance, .fallback:
            return deadlineContribution < 0.72 || futurePressureImpact < 0.72
        default:
            return deadlineContribution < 0.68 || futurePressureImpact < 0.68
        }
    }
}
