import Foundation

extension RepositoryBackedTimeRitualsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let appState: AppStateSnapshot
    }

    struct HabitContext {
        let goal: Goal
        let draftID: String?
        let step: Step
        let status: HabitTodayState
        let currentStreak: Int
        let bestStreak: Int
        let consistency: Double
        let recoveryCount: Int
    }
}
