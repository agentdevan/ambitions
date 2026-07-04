import Foundation

extension StepCandidateFieldGenerator {
    static func clamp(_ value: Double, lowerBound: Double = 0, upperBound: Double = 1) -> Double {
        guard upperBound >= lowerBound else { return lowerBound }
        return min(max(value, lowerBound), upperBound)
    }


    func resolvedSourceSteps(for context: CandidateGenerationContext) -> [CompiledStep] {
        let compiledSteps = context.compilerOutput?.compiledSteps ?? []
        guard compiledSteps.isEmpty == false else {
            return [syntheticSourceStep(for: context)]
        }
        return compiledSteps.sorted { lhs, rhs in
            if lhs.orderIndex != rhs.orderIndex { return lhs.orderIndex < rhs.orderIndex }
            return lhs.id < rhs.id
        }
    }


    func syntheticSourceStep(for context: CandidateGenerationContext) -> CompiledStep {
        CompiledStep(
            id: "synthetic-step",
            intentID: context.goalID ?? "unscoped-goal",
            title: "Continue the goal thread",
            summary: "Review the next usable step.",
            orderIndex: 0,
            stepType: .actionUnit,
            pace: .untimed,
            evidenceHint: "The runtime needs a review-safe fallback.",
            contextRequirements: [],
            isOptional: true,
            isExecutable: false
        )
    }


    func generateVariants(
        for sourceStep: CompiledStep,
        context: CandidateGenerationContext,
        factorLedger: PersonalizationFactorLedger?,
        missingContext: Bool,
        rejectionHistory: [StepCandidateRejectionRecord]
    ) -> [StepCandidate] {
        if missingContext && context.compilerOutput == nil {
            return [
                makeCandidate(
                    kind: .fallback,
                    sourceStep: sourceStep,
                    context: context,
                    factorLedger: factorLedger,
                    missingContext: true,
                    rejectionHistory: rejectionHistory
                )
            ]
        }

        return StepCandidateKind.allCases.compactMap { kind -> StepCandidate? in
            guard kind != .fallback else { return nil }
            return makeCandidate(
                kind: kind,
                sourceStep: sourceStep,
                context: context,
                factorLedger: factorLedger,
                missingContext: missingContext,
                rejectionHistory: rejectionHistory
            )
        }
    }


    func makeCandidate(
        kind: StepCandidateKind,
        sourceStep: CompiledStep,
        context: CandidateGenerationContext,
        factorLedger: PersonalizationFactorLedger?,
        missingContext: Bool,
        rejectionHistory: [StepCandidateRejectionRecord]
    ) -> StepCandidate {
        let semanticAnchor = semanticAnchor(for: sourceStep)
        let deadlineDate = deadlineDate(for: context, sourceStep: sourceStep)
        let deadlineDays = deadlineDays(from: context.generatedAt, to: deadlineDate)
        let capacityEnvelope = context.compilerOutput?.capacityEnvelope
        let openCapacityWindowCount = capacityEnvelope?.openWindowCount ?? 0
        let protectedCapacityWindowCount = capacityEnvelope?.protectedWindowCount ?? 0
        let factors = relevantFactors(for: kind, factorLedger: factorLedger)
        let factorEvidenceIDs = factors.map(\.id).sorted()
        let rejectionRecord = latestRejectionRecord(
            for: sourceStep,
            kind: kind,
            context: context,
            rejectionHistory: rejectionHistory
        )
        let rejectionHistoryCount = rejectionHistory.filter { record in
            record.sourceStepID == sourceStep.id ||
                record.sourceCandidateID == sourceStep.sourceCandidateID ||
                record.candidateID == sourceStep.sourceCandidateID ||
                record.candidateID == sourceStep.id
        }.count
        let accessComponents = accessComponents(for: kind, sourceStep: sourceStep, context: context)
        let estimatedMinutes = estimatedMinutes(for: kind, sourceStep: sourceStep, deadlineDays: deadlineDays, missingContext: missingContext)
        let estimatedEnergyCost = estimatedEnergyCost(for: kind, sourceStep: sourceStep, missingContext: missingContext, factorLedger: factorLedger)
        let goalContribution = goalContribution(for: kind, sourceStep: sourceStep, factorLedger: factorLedger)
        let deadlineContribution = deadlineContribution(for: kind, deadlineDays: deadlineDays, factorLedger: factorLedger)
        let futurePressureImpact = futurePressureImpact(for: kind, factorLedger: factorLedger, missingContext: missingContext)
        let approval = approvalRequired(
            for: kind,
            sourceStep: sourceStep,
            context: context,
            factorLedger: factorLedger,
            missingContext: missingContext,
            deadlineDays: deadlineDays,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact
        )
        let opportunityCost = opportunityCost(
            kind: kind,
            estimatedMinutes: estimatedMinutes,
            estimatedEnergyCost: estimatedEnergyCost,
            approvalRequired: approval
        )
        let validity = validity(
            for: kind,
            factorEvidenceIDs: factorEvidenceIDs,
            missingContext: missingContext,
            sourceStep: sourceStep
        )
        let tradeoffs = tradeoffs(
            for: kind,
            sourceStep: sourceStep,
            estimatedMinutes: estimatedMinutes,
            estimatedEnergyCost: estimatedEnergyCost,
            approvalRequired: approval,
            missingContext: missingContext
        )
        let risk = rejectionRisk(
            for: kind,
            factorEvidenceIDs: factorEvidenceIDs,
            validity: validity,
            approvalRequired: approval,
            missingContext: missingContext,
            factorLedger: factorLedger
        )
        let rejectionFitScore = rejectionFitScore(for: kind, sourceStep: sourceStep, record: rejectionRecord)
        return StepCandidate(
            sourceStepID: sourceStep.id,
            sourceCandidateID: sourceStep.sourceCandidateID ?? sourceStep.id,
            source: .goalIntentCompiler,
            kind: kind,
            title: title(for: kind, sourceStep: sourceStep),
            summary: summary(for: kind, sourceStep: sourceStep),
            accessibilitySummary: accessibilitySummary(for: kind, sourceStep: sourceStep, factorLedger: factorLedger, missingContext: missingContext),
            estimatedMinutes: estimatedMinutes,
            estimatedEnergyCost: estimatedEnergyCost,
            accessRequirements: accessComponents.accessRequirements,
            equipmentRequirements: accessComponents.equipmentRequirements,
            facilityRequirements: accessComponents.facilityRequirements,
            goalContribution: goalContribution,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact,
            opportunityCost: opportunityCost,
            approvalRequired: approval,
            validity: validity,
            tradeoffs: tradeoffs,
            rejectionRisk: risk,
            rejectionFitScore: rejectionFitScore,
            evidenceFactorIDs: factorEvidenceIDs,
            semanticAnchor: semanticAnchor,
            deadlineTargetDate: deadlineDate.map(DomainTimestamp.string(from:)),
            generatedAt: context.generatedAt,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            sourceStepIsOptional: sourceStep.isOptional,
            sourceStepIsExecutable: sourceStep.isExecutable,
            rejectionHistoryCount: rejectionHistoryCount
        )
    }


    func latestRejectionRecord(
        for sourceStep: CompiledStep,
        kind: StepCandidateKind,
        context: CandidateGenerationContext,
        rejectionHistory: [StepCandidateRejectionRecord]
    ) -> StepCandidateRejectionRecord? {
        let sourceCandidateID = sourceStep.sourceCandidateID ?? sourceStep.id
        let matching = rejectionHistory.filter { record in
            record.sourceStepID == sourceStep.id ||
                record.sourceCandidateID == sourceCandidateID ||
                record.candidateID == sourceCandidateID ||
                record.candidateID == sourceStep.id
        }
        guard matching.isEmpty == false else { return nil }

        let sameContext = matching.filter { $0.contextFingerprint == context.contextFingerprint }
        let candidates = sameContext.isEmpty ? matching : sameContext
        return candidates.sorted {
            if $0.recordedAt != $1.recordedAt { return $0.recordedAt > $1.recordedAt }
            if $0.reason.code.learningWeight != $1.reason.code.learningWeight {
                return $0.reason.code.learningWeight > $1.reason.code.learningWeight
            }
            return $0.id < $1.id
        }.first
    }


    func rejectionFitScore(
        for kind: StepCandidateKind,
        sourceStep: CompiledStep,
        record: StepCandidateRejectionRecord?
    ) -> Double {
        guard let record else { return 0 }
        let alignment = rejectionAlignmentScore(for: kind, reason: record.reason.code)
        let qualityMultiplier = record.skippedReason ? 0.6 : record.reason.code.learningWeight
        let sourceBias = sourceStep.isOptional ? 0.96 : 1
        return Self.clamp(alignment * qualityMultiplier * sourceBias)
    }
}
