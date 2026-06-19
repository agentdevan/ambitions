import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]
        let teachingSignals: [GoalTeachingSignal]
        let eventLedger: [EventLedgerEntry]
        let lifeContextBundles: [LifeContextBundle]
        let appState: AppStateSnapshot
    }

    struct EverythingSearchDocument {
        let id: String
        let kind: YouEverythingSearchObjectKind
        let title: String
        let summary: String
        let sourceLabel: String
        let freshness: YouMemoryFreshness
        let actions: [YouEverythingSearchAction]
        let createdAt: String
        let updatedAt: String
        let searchableText: String
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let teachingSignals = repositories.teaching.listSignals(goalID: nil)
        async let eventLedger = repositories.eventLedger.fetchRecent(limit: 12)
        async let lifeContextBundles = loadLifeContextBundles()
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            teachingSignals: teachingSignals,
            eventLedger: eventLedger,
            lifeContextBundles: lifeContextBundles,
            appState: appState
        )
    }

    func loadLifeContextBundles() async throws -> [LifeContextBundle] {
        guard let repository = repositories.lifeContext else {
            return []
        }

        return try await repository.listBundles()
    }

}
