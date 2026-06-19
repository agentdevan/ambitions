import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedInsightsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
    }

    struct PeriodWindow {
        let start: Date
        let end: Date
    }

    struct PeriodMetrics {
        let completionCount: Int
        let minimumCount: Int
        let quickLogCount: Int
        let frictionCount: Int
        let adaptationCount: Int

        var visibleFollowThrough: Int { completionCount + minimumCount }
        var momentumScore: Double { Double((completionCount * 2) + minimumCount + quickLogCount) - Double(frictionCount * 2) }
    }

    struct DatedActivity {
        let date: Date
        let summary: InsightsTimelineItem
    }
}
