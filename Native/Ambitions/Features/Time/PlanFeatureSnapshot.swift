import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedPlanService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]

        static var empty: Self {
            Self(goals: [], drafts: [], evidence: [], feedback: [], captures: [])
        }
    }

    struct StepContext {
        let goal: Goal
        let step: Step
        let date: Date
        let dayIndex: Int
        let timingLabel: String
        let blockKind: PlanWeekBlockKind
        let visualState: AmbitionVisualState
        let frictionCount: Int
        let evaluation: PlanningEvaluation?
    }

    struct GoalWeekSummary {
        let goal: Goal
        let contexts: [StepContext]
        let frictionCount: Int
        let evaluation: PlanningEvaluation?
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures
        )
    }

}
