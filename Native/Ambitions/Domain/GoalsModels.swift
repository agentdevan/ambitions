import Foundation

struct GoalSummary: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let progressLabel: String
    let statusLabel: String
}

struct MilestonePrompt: Sendable {
    let title: String
    let subtitle: String
    let prompt: String
    let confidenceLabel: String
}

struct GoalsDashboard: Sendable {
    let title: String
    let subtitle: String
    let goals: [GoalSummary]
    let milestone: MilestonePrompt
}
