import Foundation

extension RepositoryBackedTimeService {
    func makePlacementCandidates(
        weekContexts: [StepContext],
        openCaptures: [Capture]
    ) -> [TimePlacementCandidate] {
        let goalCandidates = weekContexts.compactMap(goalLinkedPlacementCandidate(from:))
        let captureCandidates = openCaptures.compactMap(freeFloatingPlacementCandidate(from:))
        return Array((goalCandidates + captureCandidates).prefix(6))
    }

    private func goalLinkedPlacementCandidate(from context: StepContext) -> TimePlacementCandidate? {
        guard [.planned, .active, .blocked].contains(context.step.state) else { return nil }
        return TimePlacementCandidate(
            id: "time.placement.goal.\(context.goal.id).\(context.step.id)",
            stepID: context.step.id,
            goalID: context.goal.id,
            title: context.step.title,
            detail: context.step.summary ?? "\(context.goal.title) step. \(context.timingLabel)",
            durationMinutes: 30,
            sourceLabel: context.goal.title,
            kind: .goalLinked
        )
    }

    private func freeFloatingPlacementCandidate(from capture: Capture) -> TimePlacementCandidate? {
        guard capture.status != .archived,
              capture.triageStatus != .archived,
              capture.linkedGoalID == nil,
              [.oneTimeCommitment, .deadlineTask].contains(capture.kind)
        else { return nil }

        let title = capture.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard title.isEmpty == false else { return nil }
        let deadline = capture.deadlineText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let detail = if let deadline, deadline.isEmpty == false {
            "Deadline: \(deadline)"
        } else {
            "Free-floating Step from Capture."
        }
        return TimePlacementCandidate(
            id: "time.placement.free-floating.\(capture.id)",
            stepID: "capture.\(capture.id)",
            goalID: nil,
            title: title,
            detail: detail,
            durationMinutes: 30,
            sourceLabel: "Capture",
            kind: .freeFloating
        )
    }
}
