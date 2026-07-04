import Foundation

enum PlanRepairActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case useSelectedCandidate = "use_selected_candidate"
    case proposeSmallerStep = "propose_smaller_step"
    case deferBlockedNode = "defer_blocked_node"
    case preserveExistingProgress = "preserve_existing_progress"
    case requestReview = "request_review"
}

struct PlanRepairTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let actionKind: PlanRepairActionKind
    let selectedCandidateID: String?
    let smallerStepProposal: SmallerStepProposal?
    let blockedNodeIDs: [String]
    let preservedNodeIDs: [String]
    let reason: String
    let runtimeTrace: PlanningRuntimeTrace
}

struct PlanRepairEngine: Sendable {
    private let smallerStepEngine: SmallerStepEngine

    init(smallerStepEngine: SmallerStepEngine = SmallerStepEngine()) {
        self.smallerStepEngine = smallerStepEngine
    }

    func repair(
        field: StepCandidateField,
        dependencyResolution: DependencyResolution,
        preservationReport: ProgressPreservationReport
    ) -> PlanRepairTrace {
        let selected = field.selectedCandidate
        let smallerProposal = smallerStepEngine.proposal(from: field)
        let action: PlanRepairActionKind
        let reason: String

        if dependencyResolution.hasBlockingFailures {
            action = .deferBlockedNode
            reason = "Dependencies block \(dependencyResolution.blockedNodeIDs.count) planning node\(dependencyResolution.blockedNodeIDs.count == 1 ? "" : "s")."
        } else if shouldUseSmallerProposal(selected: selected, proposal: smallerProposal) {
            action = .proposeSmallerStep
            reason = smallerProposal?.summary ?? "A smaller step is safer than the selected candidate."
        } else if preservationReport.hasPreservedProgress {
            action = .preserveExistingProgress
            reason = preservationReport.summary
        } else if selected == nil {
            action = .requestReview
            reason = "No selected candidate survived ranking."
        } else {
            action = .useSelectedCandidate
            reason = field.rankingTrace.semanticSummary
        }

        let trace = PlanningRuntimeTrace.make(
            owner: "PlanRepairEngine",
            generatedAt: field.generatedAt,
            components: [
                field.id,
                dependencyResolution.runtimeTrace.id,
                preservationReport.runtimeTrace.id,
                selected?.id ?? "no-selected",
                smallerProposal?.id ?? "no-smaller",
                action.rawValue
            ],
            localOnly: field.localOnly
        )
        return PlanRepairTrace(
            id: CandidateSource.stableIdentifier(
                prefix: "plan-repair-trace",
                components: [field.id, action.rawValue, trace.checksum]
            ),
            actionKind: action,
            selectedCandidateID: selected?.id,
            smallerStepProposal: action == .proposeSmallerStep ? smallerProposal : nil,
            blockedNodeIDs: dependencyResolution.blockedNodeIDs,
            preservedNodeIDs: preservationReport.preservedNodeIDs,
            reason: reason,
            runtimeTrace: trace
        )
    }

    private func shouldUseSmallerProposal(
        selected: StepCandidate?,
        proposal: SmallerStepProposal?
    ) -> Bool {
        guard let selected, let proposal else {
            return false
        }
        if selected.validity == .blocked || selected.validity == .fallback {
            return true
        }
        if selected.rejectionRisk.level == .high {
            return true
        }
        if proposal.estimatedMinutesDelta < 0 || proposal.energyDelta < 0 {
            return selected.rejectionRisk.level != .low || selected.validity == .review
        }
        return false
    }
}
