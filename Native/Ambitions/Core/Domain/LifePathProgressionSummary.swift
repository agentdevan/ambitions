import Foundation

struct LifePathProgressionSummary: Sendable, Equatable {
    let activeStageID: String?
    let completedStageIDs: [String]
    let completedMilestoneIDs: [String]
    let nextMilestoneID: String?
    let totalStageCount: Int
    let totalMilestoneCount: Int
    let completedMilestoneCount: Int
}

struct LifePathStateSummary: Sendable, Equatable {
    let orderedStages: [LifePathStage]
    let activeStageID: String?
    let stageMilestones: [String: [LifeGraphMilestone]]
    let blockedPrerequisites: [LifePathPrerequisite]
    let readiness: LifePathReadinessSummary
    let progression: LifePathProgressionSummary
}

struct GoalRelationshipGraph: Sendable, Equatable {
    let focus: Goal
    let parent: Goal?
    let children: [Goal]
    let supportGoals: [Goal]
}

struct SharedResponsibilitySummary: Sendable, Equatable {
    let totalCount: Int
    let careCount: Int
    let householdCount: Int
    let appointmentCount: Int
    let logisticsCount: Int
    let supportCount: Int
    let participantNames: [String]
}

struct SharedLifeCoordinationSignal: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let needsPreparation: Bool
    let isTimed: Bool
}

struct SharedLifeGoalSummary: Sendable, Equatable {
    let goalID: String
    let participantNames: [String]
    let relationshipLabels: [String]
    let delegatedSupportActive: Bool
    let careContextActive: Bool
    let structuralSupportGoalCount: Int
    let responsibilitySummary: SharedResponsibilitySummary
    let coordinationSignals: [SharedLifeCoordinationSignal]
    let pressureScore: Double
    let reasons: [String]
}

struct SharedLifePortfolioSummary: Sendable, Equatable {
    let totalResponsibilityCount: Int
    let careGoalCount: Int
    let coordinationSignalCount: Int
    let headline: String
}

struct SharedLifeCoordinationSnapshot: Sendable, Equatable {
    let goalSummaries: [String: SharedLifeGoalSummary]
    let portfolioSummary: SharedLifePortfolioSummary
}
