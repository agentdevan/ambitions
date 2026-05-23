import Foundation

struct StepCandidateFieldGenerator: Sendable {
    func generate(_ context: CandidateGenerationContext) -> StepCandidateField {
        let sourceSteps = resolvedSourceSteps(for: context)
        let factorLedger = context.resolvedFactorLedger
        let missingContext = hasMissingContext(context: context, factorLedger: factorLedger)
        let rejectionHistory = context.rejectionHistory
        let contextFingerprint = context.contextFingerprint

        var candidates: [StepCandidate] = []
        for sourceStep in sourceSteps {
            candidates.append(contentsOf: generateVariants(
                for: sourceStep,
                context: context,
                factorLedger: factorLedger,
                missingContext: missingContext,
                rejectionHistory: rejectionHistory
            ))
        }

        if shouldAddFallbackCandidate(sourceSteps: sourceSteps, context: context, missingContext: missingContext) {
            let fallbackSourceStep = sourceSteps.first ?? syntheticSourceStep(for: context)
            candidates.append(
                makeCandidate(
                    kind: .fallback,
                    sourceStep: fallbackSourceStep,
                    context: context,
                    factorLedger: factorLedger,
                    missingContext: true,
                    rejectionHistory: rejectionHistory
                )
            )
        }

        let dedupedResult = deduplicate(candidates)
        let deduped = dedupedResult.candidates
        let suppressedRejectedIDs = Set(
            rejectionHistory
                .filter { $0.contextFingerprint == contextFingerprint }
                .map(\.candidateID)
        )
        let filtered = deduped.filter { suppressedRejectedIDs.contains($0.id) == false }
        let activeCandidates = filtered.isEmpty
            ? [
                makeCandidate(
                    kind: .fallback,
                    sourceStep: syntheticSourceStep(for: context),
                    context: context,
                    factorLedger: factorLedger,
                    missingContext: true,
                    rejectionHistory: rejectionHistory
                )
            ]
            : filtered
        let sorted = activeCandidates.sorted(by: rankCandidates(lhs:rhs:))
        let limited = Array(sorted.prefix(context.candidateLimit))
        let selected = limited.first ?? makeCandidate(
            kind: .fallback,
            sourceStep: syntheticSourceStep(for: context),
            context: context,
            factorLedger: factorLedger,
            missingContext: true,
            rejectionHistory: rejectionHistory
        )
        let rankedIDs = limited.map(\.id)
        let rejectedIDs = Array(sorted.dropFirst().map(\.id))
        let factorEvidenceIDs = Array(Set(limited.flatMap { $0.score.evidenceFactorIDs })).sorted()
        let replayFingerprint = factorLedger?.replayProjection.stableFingerprint
            ?? context.replayTrace?.personalizationFactorLedger.replayProjection.stableFingerprint
            ?? context.runtimeOutput?.personalizationFactorLedger.replayProjection.stableFingerprint
        let rankingTrace = CandidateRankingTrace(
            generatedAt: context.generatedAt,
            selectedCandidateID: selected.id,
            rankedCandidateIDs: rankedIDs,
            rejectedCandidateIDs: rejectedIDs,
            suppressedRejectedCandidateIDs: Array(suppressedRejectedIDs).sorted(),
            duplicateRejectedCandidateIDs: dedupedResult.duplicateRejectedIDs,
            sourceProvenance: context.sourceProvenance,
            factorEvidenceIDs: factorEvidenceIDs,
            replayReferenceID: context.replayTrace?.id ?? context.decisionRecord?.id ?? context.runtimeOutput?.recordID,
            replayFingerprint: replayFingerprint,
            sourceAtlasExpansionTrace: context.sourceAtlasExpansionTrace,
            semanticSummary: rankingSummary(
                selected: selected,
                factorLedger: factorLedger,
                missingContext: missingContext,
                candidateCount: limited.count
            ),
            factorlessRanking: factorEvidenceIDs.isEmpty
        )

        return StepCandidateField(
            goalID: context.goalID,
            deadlineTargetDate: context.deadlineTargetDate ?? earliestTargetDate(in: sourceSteps),
            generatedAt: context.generatedAt,
            sourceProvenance: context.sourceProvenance,
            candidates: limited,
            rankingTrace: rankingTrace,
            sourceAtlasExpansionTrace: context.sourceAtlasExpansionTrace,
            localOnly: context.localOnly
        )
    }
}

private extension StepCandidateFieldGenerator {
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

    func rejectionAlignmentScore(for kind: StepCandidateKind, reason: StepCandidateRejectionReasonCode) -> Double {
        switch reason {
        case .tooLong, .notEnoughTime:
            switch kind {
            case .shorter, .proofGathering, .lighter:
                return 1
            case .lowerEnergy, .maintenance:
                return 0.82
            case .directBest, .fallback:
                return 0.25
            case .recoverySafe:
                return 0.62
            case .locationCompatible, .noEquipment, .adminSetup, .learningResearch, .prerequisite, .catchUp, .substitution, .parallelPath:
                return 0.44
            }
        case .tooHard, .tooMuchEnergy, .emotionallyNotReady, .unsafeInjuryConcern:
            switch kind {
            case .recoverySafe, .lowerEnergy:
                return 1
            case .lighter, .shorter:
                return 0.88
            case .maintenance, .proofGathering:
                return 0.74
            case .directBest, .fallback:
                return 0.2
            case .locationCompatible, .noEquipment, .adminSetup, .learningResearch, .prerequisite, .catchUp, .substitution, .parallelPath:
                return 0.46
            }
        case .wrongLocation, .noTransportation:
            switch kind {
            case .locationCompatible, .substitution, .parallelPath:
                return 1
            case .adminSetup:
                return 0.84
            case .noEquipment, .learningResearch, .prerequisite:
                return 0.7
            case .directBest, .fallback:
                return 0.22
            case .lighter, .shorter, .lowerEnergy, .recoverySafe, .maintenance, .catchUp, .proofGathering:
                return 0.5
            }
        case .noEquipment:
            switch kind {
            case .noEquipment:
                return 1
            case .adminSetup, .learningResearch, .prerequisite:
                return 0.86
            case .substitution, .parallelPath:
                return 0.72
            case .directBest, .fallback:
                return 0.24
            case .lighter, .shorter, .lowerEnergy, .recoverySafe, .maintenance, .catchUp, .proofGathering, .locationCompatible:
                return 0.48
            }
        case .blockedBySomeoneElse:
            switch kind {
            case .adminSetup, .parallelPath, .substitution:
                return 1
            case .learningResearch, .prerequisite, .maintenance:
                return 0.76
            case .directBest, .fallback:
                return 0.22
            case .lighter, .shorter, .lowerEnergy, .recoverySafe, .catchUp, .proofGathering, .locationCompatible, .noEquipment:
                return 0.52
            }
        case .alreadyDidSimilar:
            switch kind {
            case .directBest, .proofGathering:
                return 1
            case .substitution, .parallelPath, .catchUp, .maintenance:
                return 0.86
            case .lighter, .shorter, .lowerEnergy:
                return 0.44
            case .recoverySafe, .adminSetup, .learningResearch, .prerequisite, .locationCompatible, .noEquipment, .fallback:
                return 0.58
            }
        case .notUseful:
            switch kind {
            case .substitution, .parallelPath, .adminSetup:
                return 1
            case .learningResearch, .prerequisite, .proofGathering:
                return 0.86
            case .directBest, .fallback:
                return 0.2
            case .lighter, .shorter, .lowerEnergy, .recoverySafe, .maintenance, .catchUp, .locationCompatible, .noEquipment:
                return 0.5
            }
        case .tooEasy:
            switch kind {
            case .directBest, .proofGathering:
                return 1
            case .learningResearch, .prerequisite, .adminSetup, .substitution, .parallelPath:
                return 0.88
            case .lighter, .shorter, .maintenance:
                return 0.34
            case .lowerEnergy, .recoverySafe, .catchUp, .locationCompatible, .noEquipment, .fallback:
                return 0.56
            }
        case .boringLowMotivation:
            switch kind {
            case .lighter, .shorter, .lowerEnergy, .recoverySafe:
                return 1
            case .maintenance, .proofGathering:
                return 0.82
            case .directBest, .fallback:
                return 0.32
            case .locationCompatible, .noEquipment, .adminSetup, .learningResearch, .prerequisite, .catchUp, .substitution, .parallelPath:
                return 0.5
            }
        case .preferDifferentPath:
            switch kind {
            case .substitution, .parallelPath, .adminSetup:
                return 1
            case .learningResearch, .prerequisite, .catchUp:
                return 0.84
            case .directBest, .fallback:
                return 0.26
            case .lighter, .shorter, .lowerEnergy, .recoverySafe, .maintenance, .proofGathering, .locationCompatible, .noEquipment:
                return 0.54
            }
        case .custom:
            switch kind {
            case .substitution, .parallelPath, .adminSetup, .learningResearch, .proofGathering:
                return 0.76
            case .directBest, .fallback:
                return 0.42
            case .lighter, .shorter, .lowerEnergy, .recoverySafe, .maintenance, .catchUp, .locationCompatible, .noEquipment, .prerequisite:
                return 0.62
            }
        }
    }

    func deduplicate(_ candidates: [StepCandidate]) -> (candidates: [StepCandidate], duplicateRejectedIDs: [String]) {
        var bestBySignature: [String: StepCandidate] = [:]
        var duplicateRejectedIDs: [String] = []
        for candidate in candidates {
            if let existing = bestBySignature[candidate.normalizedSemanticSignature] {
                if shouldReplace(existing: existing, with: candidate) {
                    bestBySignature[candidate.normalizedSemanticSignature] = candidate
                    duplicateRejectedIDs.append(existing.id)
                } else {
                    duplicateRejectedIDs.append(candidate.id)
                }
            } else {
                bestBySignature[candidate.normalizedSemanticSignature] = candidate
            }
        }
        return (
            candidates: bestBySignature.values.sorted(by: rankCandidates(lhs:rhs:)),
            duplicateRejectedIDs: duplicateRejectedIDs.sorted()
        )
    }

    func shouldReplace(existing: StepCandidate, with candidate: StepCandidate) -> Bool {
        if candidate.score.total != existing.score.total {
            return candidate.score.total > existing.score.total
        }
        if candidate.validity.sortWeight != existing.validity.sortWeight {
            return candidate.validity.sortWeight > existing.validity.sortWeight
        }
        if candidate.kind.rawValue != existing.kind.rawValue {
            return candidate.kind.rawValue < existing.kind.rawValue
        }
        return candidate.id < existing.id
    }

    func rankCandidates(lhs: StepCandidate, rhs: StepCandidate) -> Bool {
        if lhs.score.total != rhs.score.total { return lhs.score.total > rhs.score.total }
        if lhs.validity.sortWeight != rhs.validity.sortWeight { return lhs.validity.sortWeight > rhs.validity.sortWeight }
        if lhs.score.factorEvidenceScore != rhs.score.factorEvidenceScore { return lhs.score.factorEvidenceScore > rhs.score.factorEvidenceScore }
        if lhs.kind.rawValue != rhs.kind.rawValue { return lhs.kind.rawValue < rhs.kind.rawValue }
        if lhs.sourceStepID != rhs.sourceStepID { return lhs.sourceStepID < rhs.sourceStepID }
        return lhs.id < rhs.id
    }

    func rankingSummary(
        selected: StepCandidate,
        factorLedger: PersonalizationFactorLedger?,
        missingContext: Bool,
        candidateCount: Int
    ) -> String {
        let evidenceCount = selected.score.evidenceFactorIDs.count
        if missingContext || factorLedger?.missingContextQuestions.isEmpty == false {
            return "Selected a fallback review-safe candidate from \(candidateCount) options because the runtime is missing context."
        }
        if evidenceCount == 0 {
            return "Selected a fallback candidate because factor-ledger evidence is missing."
        }
        return "Selected \(selected.kind.semanticLabel.lowercased()) from \(candidateCount) factor-backed candidates."
    }

    func hasMissingContext(context: CandidateGenerationContext, factorLedger: PersonalizationFactorLedger?) -> Bool {
        if context.compilerOutput?.clarification.status == .blocked {
            return true
        }
        if context.compilerOutput?.clarification.missingFields.isEmpty == false {
            return true
        }
        if factorLedger?.missingContextQuestions.isEmpty == false {
            return true
        }
        if context.runtimeOutput == nil && context.decisionRecord == nil && context.replayTrace == nil && context.compilerOutput == nil {
            return true
        }
        return false
    }

    func shouldAddFallbackCandidate(sourceSteps: [CompiledStep], context: CandidateGenerationContext, missingContext: Bool) -> Bool {
        if sourceSteps.isEmpty {
            return true
        }
        if missingContext, context.compilerOutput != nil {
            return true
        }
        return false
    }

    func semanticAnchor(for sourceStep: CompiledStep) -> String {
        [
            sourceStep.title,
            sourceStep.summary ?? "",
            sourceStep.evidenceHint ?? "",
            sourceStep.contextRequirements.joined(separator: " ")
        ]
        .joined(separator: " ")
    }

    func title(for kind: StepCandidateKind, sourceStep: CompiledStep) -> String {
        let base = sourceStep.title
        switch kind {
        case .directBest:
            return base
        case .lighter:
            return "Make a lighter version of \(base)"
        case .shorter:
            return "Do the shortest visible version of \(base)"
        case .lowerEnergy:
            return "Do a lower-energy version of \(base)"
        case .locationCompatible:
            return "Do \(base) where access is already available"
        case .noEquipment:
            return "Do \(base) without equipment"
        case .recoverySafe:
            return "Do a recovery-safe version of \(base)"
        case .adminSetup:
            return "Set up the conditions for \(base)"
        case .learningResearch:
            return "Learn what is needed before \(base)"
        case .proofGathering:
            return "Get one proof step for \(base)"
        case .prerequisite:
            return "Do the prerequisite for \(base)"
        case .maintenance:
            return "Keep the \(base) thread warm"
        case .catchUp:
            return "Catch up on \(base)"
        case .substitution:
            return "Use an alternate route to \(base)"
        case .parallelPath:
            return "Advance \(base) through a parallel path"
        case .fallback:
            return "Keep the goal open and review the next step"
        }
    }

    func summary(for kind: StepCandidateKind, sourceStep: CompiledStep) -> String {
        switch kind {
        case .directBest:
            return "Best fit when the runtime can take the clearest path."
        case .lighter:
            return "Lighter version that keeps the same goal thread but lowers the load."
        case .shorter:
            return "Cuts the work down to a smaller pass."
        case .lowerEnergy:
            return "Keeps the thread moving with less energy."
        case .locationCompatible:
            return "Fits the places and access already available."
        case .noEquipment:
            return "Avoids an equipment dependency."
        case .recoverySafe:
            return "Stays conservative and gentle on recovery."
        case .adminSetup:
            return "Prepares the conditions for a later pass."
        case .learningResearch:
            return "Clarifies the missing information first."
        case .proofGathering:
            return "Collects proof before expanding the step."
        case .prerequisite:
            return "Finishes the dependency before the main move."
        case .maintenance:
            return "Keeps continuity without pressure to overreach."
        case .catchUp:
            return "Recovers momentum without pretending the delay disappeared."
        case .substitution:
            return "Uses another route when the preferred path is blocked."
        case .parallelPath:
            return "Advances the goal alongside the main thread."
        case .fallback:
            return "Keeps the goal open while context is reviewed."
        }
    }

    func accessibilitySummary(
        for kind: StepCandidateKind,
        sourceStep: CompiledStep,
        factorLedger: PersonalizationFactorLedger?,
        missingContext: Bool
    ) -> String {
        var parts = [kind.semanticLabel, sourceStep.title]
        if missingContext {
            parts.append("review needed")
        } else if factorLedger?.missingContextQuestions.isEmpty == false {
            parts.append("context missing")
        }
        if factorLedger?.factors.isEmpty == false {
            parts.append("factor evidence present")
        }
        return parts.joined(separator: " · ")
    }

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
