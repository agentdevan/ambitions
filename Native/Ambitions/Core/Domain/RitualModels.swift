import Foundation

enum RitualKind: String, Codable, Sendable, Equatable {
    case morningSetup = "morning_setup"
    case middayReset = "midday_reset"
    case eveningClose = "evening_close"
    case weeklyReset = "weekly_reset"
}

enum RitualProgressState: String, Codable, Sendable, Equatable {
    case unavailable
    case ready
    case needsReset = "needs_reset"
    case complete
}

enum RitualActionKind: String, Codable, Sendable, Equatable {
    case complete
    case delay
    case askForSmallerStep = "ask_for_smaller_step"
    case quickLog = "quick_log"
    case openDetail = "open_detail"
}

struct RitualActionReference: Codable, Sendable, Equatable {
    let kind: RitualActionKind
    let goalID: String?
    let stepID: String?
    let draftID: String?

    init(
        kind: RitualActionKind,
        goalID: String? = nil,
        stepID: String? = nil,
        draftID: String? = nil
    ) {
        self.kind = kind
        self.goalID = goalID
        self.stepID = stepID
        self.draftID = draftID
    }
}

struct RitualSignalSummary: Codable, Sendable, Equatable {
    let activeGoalCount: Int
    let openCaptureCount: Int
    let completedTodayCount: Int
    let frictionTodayCount: Int
    let frictionThisWeekCount: Int
    let pressureLevel: PlanningPressureLevel
}

struct RitualRecommendation: Codable, Sendable, Equatable {
    let kind: RitualKind
    let progressState: RitualProgressState
    let title: String
    let body: String
    let stateLabel: String
    let primaryAction: RitualActionReference?
}

struct RitualPlan: Codable, Sendable, Equatable {
    let activeRecommendation: RitualRecommendation
    let signalSummary: RitualSignalSummary
    let dayThesis: String
    let weekThesis: String
}
