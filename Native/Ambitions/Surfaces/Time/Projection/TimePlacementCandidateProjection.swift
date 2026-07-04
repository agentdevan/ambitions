import Foundation

extension RepositoryBackedTimeService {
    func makePlacementCandidates(
        weekContexts: [StepContext],
        openCaptures _: [Capture]
    ) -> [TimePlacementCandidate] {
        let goalCandidates = weekContexts.compactMap(goalLinkedPlacementCandidate(from:))
        return Array(goalCandidates.prefix(6))
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

}
