import Foundation

enum TimeConflictProposalKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case commit
    case holdForReview = "hold_for_review"
    case moveToNextOpenWindow = "move_to_next_open_window"
    case keepExistingPlacement = "keep_existing_placement"
}

struct TimeConflictProposal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: TimeConflictProposalKind
    let candidateBlockID: String
    let proposedWindow: ProtectedStepPlacementWindow?
    let conflictIDs: [String]
    let violationIDs: [String]
    let summary: String
    let canCommit: Bool
    let runtimeTrace: TimeEngineRuntimeTrace

    init(
        kind: TimeConflictProposalKind,
        candidateBlockID: String,
        proposedWindow: ProtectedStepPlacementWindow?,
        conflictIDs: [String],
        violationIDs: [String],
        summary: String,
        canCommit: Bool,
        localOnly: Bool
    ) {
        self.kind = kind
        self.candidateBlockID = TimeEngineStableID.required(candidateBlockID)
        self.proposedWindow = proposedWindow
        self.conflictIDs = TimeEngineStableID.unique(conflictIDs)
        self.violationIDs = TimeEngineStableID.unique(violationIDs)
        self.summary = TimeEngineStableID.required(summary)
        self.canCommit = canCommit
        let source = [
            kind.rawValue,
            self.candidateBlockID,
            self.conflictIDs.joined(separator: ","),
            self.violationIDs.joined(separator: ","),
            proposedWindow.map { "\(TemporalMath.string(from: $0.start))-\(TemporalMath.string(from: $0.end))" } ?? "no-window",
            canCommit ? "commit" : "review"
        ].joined(separator: "|")
        runtimeTrace = TimeEngineRuntimeTrace.make(owner: "ConflictProposalEngine", sourceID: source, localOnly: localOnly)
        id = TimeEngineStableID.make(prefix: "time-conflict-proposal", components: [source])
    }
}

struct ConflictProposalEngine: Sendable {
    private let constraintEngine: ConstraintEngine

    init(constraintEngine: ConstraintEngine = ConstraintEngine()) {
        self.constraintEngine = constraintEngine
    }

    func proposals(
        for candidate: TimeBlock,
        graph: TimeBlockGraph,
        constraints: [TimeConstraint] = []
    ) -> [TimeConflictProposal] {
        let evaluation = constraintEngine.evaluate(graph: graph, candidate: candidate, constraints: constraints)
        let candidateGraph = graph.adding(candidate)
        let conflicts = candidateGraph.conflicts.filter {
            $0.firstBlockID == candidate.id || $0.secondBlockID == candidate.id
        }
        let blockingConflictIDs = conflicts.filter { $0.severity == .blocking }.map(\.id)
        let blockingViolationIDs = evaluation.blockingViolations.map(\.id)

        guard blockingConflictIDs.isEmpty == false || blockingViolationIDs.isEmpty == false else {
            return [
                TimeConflictProposal(
                    kind: .commit,
                    candidateBlockID: candidate.id,
                    proposedWindow: ProtectedStepPlacementWindow(start: candidate.start, end: candidate.end),
                    conflictIDs: conflicts.map(\.id),
                    violationIDs: evaluation.violations.map(\.id),
                    summary: "Placement can commit without violating protected TimeEngine constraints.",
                    canCommit: true,
                    localOnly: candidateGraph.localOnly
                )
            ]
        }

        var proposals: [TimeConflictProposal] = [
            TimeConflictProposal(
                kind: .holdForReview,
                candidateBlockID: candidate.id,
                proposedWindow: ProtectedStepPlacementWindow(start: candidate.start, end: candidate.end),
                conflictIDs: blockingConflictIDs,
                violationIDs: blockingViolationIDs,
                summary: "Placement is held for review because it conflicts with protected or capacity-consuming time.",
                canCommit: false,
                localOnly: candidateGraph.localOnly
            ),
            TimeConflictProposal(
                kind: .keepExistingPlacement,
                candidateBlockID: candidate.id,
                proposedWindow: nil,
                conflictIDs: blockingConflictIDs,
                violationIDs: blockingViolationIDs,
                summary: "Keep the existing placement until the conflict is explicitly resolved.",
                canCommit: false,
                localOnly: candidateGraph.localOnly
            )
        ]

        let searchEnd = TemporalMath.addDays(14, to: candidate.end)
        if let horizon = ProtectedStepPlacementWindow(start: candidate.end, end: searchEnd),
           let nextWindow = graph.availableWindows(in: horizon, minimumDurationMinutes: candidate.durationMinutes).first,
           let proposed = ProtectedStepPlacementWindow(start: nextWindow.start, end: TemporalMath.end(start: nextWindow.start, durationMinutes: candidate.durationMinutes)) {
            proposals.append(
                TimeConflictProposal(
                    kind: .moveToNextOpenWindow,
                    candidateBlockID: candidate.id,
                    proposedWindow: proposed,
                    conflictIDs: blockingConflictIDs,
                    violationIDs: blockingViolationIDs,
                    summary: "Move to the next open local window that fits the Step duration.",
                    canCommit: false,
                    localOnly: candidateGraph.localOnly
                )
            )
        }

        return proposals.sorted { $0.kind.rawValue < $1.kind.rawValue }
    }
}
