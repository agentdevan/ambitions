import Foundation

enum SmallerStepProposalReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case shorterDuration = "shorter_duration"
    case lowerEnergy = "lower_energy"
    case saferRecovery = "safer_recovery"
    case lowerOpportunityCost = "lower_opportunity_cost"
}

struct SmallerStepProposal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let originalCandidateID: String
    let proposedCandidateID: String
    let proposedKind: StepCandidateKind
    let estimatedMinutesDelta: Int
    let energyDelta: Double
    let reasons: [SmallerStepProposalReason]
    let summary: String
    let runtimeTrace: PlanningRuntimeTrace
}

struct SmallerStepEngine: Sendable {
    private let preferredKinds: [StepCandidateKind] = [
        .shorter,
        .lighter,
        .lowerEnergy,
        .recoverySafe,
        .maintenance,
        .proofGathering,
        .fallback
    ]

    func proposal(from field: StepCandidateField, avoiding candidateID: String? = nil) -> SmallerStepProposal? {
        guard let selected = field.selectedCandidate ?? field.candidates.first else {
            return nil
        }
        let avoidedID = candidateID ?? selected.id
        let alternatives = field.candidates
            .filter { $0.id != avoidedID }
            .filter { preferredKinds.contains($0.kind) || $0.estimatedMinutes < selected.estimatedMinutes || $0.estimatedEnergyCost < selected.estimatedEnergyCost }
            .sorted { lhs, rhs in
                let lhsPreferred = preferredKinds.firstIndex(of: lhs.kind) ?? preferredKinds.count
                let rhsPreferred = preferredKinds.firstIndex(of: rhs.kind) ?? preferredKinds.count
                if lhsPreferred != rhsPreferred { return lhsPreferred < rhsPreferred }
                if lhs.estimatedMinutes != rhs.estimatedMinutes { return lhs.estimatedMinutes < rhs.estimatedMinutes }
                if lhs.estimatedEnergyCost != rhs.estimatedEnergyCost { return lhs.estimatedEnergyCost < rhs.estimatedEnergyCost }
                if lhs.score.total != rhs.score.total { return lhs.score.total > rhs.score.total }
                return lhs.id < rhs.id
            }
        guard let proposed = alternatives.first else {
            return nil
        }

        let minuteDelta = proposed.estimatedMinutes - selected.estimatedMinutes
        let energyDelta = ((proposed.estimatedEnergyCost - selected.estimatedEnergyCost) * 100).rounded() / 100
        let reasons = proposalReasons(selected: selected, proposed: proposed)
        let trace = PlanningRuntimeTrace.make(
            owner: "SmallerStepEngine",
            generatedAt: field.generatedAt,
            components: [
                field.id,
                selected.id,
                proposed.id,
                reasons.map(\.rawValue).joined(separator: ",")
            ],
            localOnly: field.localOnly
        )
        return SmallerStepProposal(
            id: CandidateSource.stableIdentifier(prefix: "smaller-step-proposal", components: [field.id, selected.id, proposed.id]),
            originalCandidateID: selected.id,
            proposedCandidateID: proposed.id,
            proposedKind: proposed.kind,
            estimatedMinutesDelta: minuteDelta,
            energyDelta: energyDelta,
            reasons: reasons,
            summary: summary(selected: selected, proposed: proposed, reasons: reasons),
            runtimeTrace: trace
        )
    }

    private func proposalReasons(selected: StepCandidate, proposed: StepCandidate) -> [SmallerStepProposalReason] {
        var reasons: [SmallerStepProposalReason] = []
        if proposed.estimatedMinutes < selected.estimatedMinutes || proposed.kind == .shorter {
            reasons.append(.shorterDuration)
        }
        if proposed.estimatedEnergyCost < selected.estimatedEnergyCost || proposed.kind == .lowerEnergy || proposed.kind == .lighter {
            reasons.append(.lowerEnergy)
        }
        if proposed.kind == .recoverySafe || proposed.impactSimulation.goalTimeline.recovery.isRecoverySafe {
            reasons.append(.saferRecovery)
        }
        if proposed.opportunityCost < selected.opportunityCost {
            reasons.append(.lowerOpportunityCost)
        }
        return reasons.isEmpty ? [.shorterDuration] : reasons.removingDuplicates()
    }

    private func summary(
        selected: StepCandidate,
        proposed: StepCandidate,
        reasons: [SmallerStepProposalReason]
    ) -> String {
        let reasonText = reasons.map(\.rawValue).joined(separator: ", ")
        return "Proposed \(proposed.kind.semanticLabel.lowercased()) instead of \(selected.kind.semanticLabel.lowercased()) because \(reasonText)."
    }
}
