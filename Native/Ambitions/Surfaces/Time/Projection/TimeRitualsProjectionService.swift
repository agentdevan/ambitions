import Foundation

struct RepositoryBackedTimeRitualsService: TimeRitualsServicing {
    let repositories: AppRepositories
    let tickPolicy: RuntimeTickPolicy = .system

    func loadDashboard(now: Date) async throws -> TimeRitualsDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot, now: now)
    }

    func performAction(_ request: TimeRitualActionRequest, now: Date) async throws -> TimeRitualActionResponse {
        guard let goal = try await repositories.goals.goal(id: request.target.goalID),
              goal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == request.target.stepID }) == true else {
            return TimeRitualActionResponse(
                message: TimeRitualInlineMessage(
                    title: "Ritual moved",
                    body: "That routine is no longer available in the current native snapshot.",
                    state: .warning
                )
            )
        }
        guard request.kind == .openDetail else {
            throw TimeRitualDurableActionError.unavailable
        }
        _ = now
        return TimeRitualActionResponse(message: TimeRitualInlineMessage(
            title: "Opening ritual context",
            body: "This ritual is linked back to the full goal context so cadence, support language, and replanning all stay aligned.",
            state: .selected
        ))
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listHabitGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let appState = repositories.appState.loadState()

        return try await Snapshot(goals: goals, drafts: drafts, evidence: evidence, feedback: feedback, appState: appState)
    }
}

protocol TimeRitualDurableActionPreparing: Sendable {
    func prepareDurableAction(_ request: TimeRitualActionRequest, now: Date) async throws -> PreparedTimeRitualAction
}

extension RepositoryBackedTimeRitualsService: TimeRitualDurableActionPreparing {
    func prepareDurableAction(
        _ request: TimeRitualActionRequest,
        now: Date
    ) async throws -> PreparedTimeRitualAction {
        try await TimeRitualActionPlanner(repositories: repositories).prepare(request, now: now)
    }
}
import AmbitionsTimeFoundation
