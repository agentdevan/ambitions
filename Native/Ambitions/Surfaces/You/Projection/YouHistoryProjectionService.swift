import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedInsightsService: InsightsServicing {
    let repositories: AppRepositories

    func loadInsightsDashboard() async throws -> InsightsDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot)
    }
}

extension RepositoryBackedInsightsService {
    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback
        )
    }
}
