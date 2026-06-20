import Foundation

extension StepCandidateFieldGenerator {

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
}
