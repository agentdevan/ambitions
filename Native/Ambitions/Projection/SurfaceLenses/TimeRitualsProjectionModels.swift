import Foundation

extension RepositoryBackedTimeRitualsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let appState: AppStateSnapshot
    }

    struct TimeRitualContext {
        let goal: Goal
        let draftID: String?
        let step: Step
        let status: TimeRitualState
        let currentRhythm: Int
        let bestRhythm: Int
        let consistency: Double
        let recoveryCount: Int
    }
}
