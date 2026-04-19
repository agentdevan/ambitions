import Foundation

struct ExternalSurfaceSnapshot: Codable, Sendable, Equatable {
    static let schemaVersion = "external_surface_snapshot.v1"

    let schemaVersion: String
    let generatedAt: String
    let nextAction: ExternalSurfaceNextAction?
    let nowState: ExternalSurfaceNowState?

    init(
        schemaVersion: String = ExternalSurfaceSnapshot.schemaVersion,
        generatedAt: String,
        nextAction: ExternalSurfaceNextAction?,
        nowState: ExternalSurfaceNowState? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.nextAction = nextAction
        self.nowState = nowState
    }
}

struct ExternalSurfaceNextAction: Codable, Sendable, Equatable {
    let goalID: String
    let stepID: String
    let display: ExternalSurfaceDisplayMetadata
}

struct ExternalSurfaceDisplayMetadata: Codable, Sendable, Equatable {
    let templateKey: String
    let goalMode: ExternalSurfaceGoalMode
    let stepState: ExternalSurfaceStepState
    let urgency: ExternalSurfaceUrgency
    let timing: ExternalSurfaceTiming
}

enum ExternalSurfaceGoalMode: String, Codable, Sendable {
    case achievement
    case project
    case habit
    case learning
    case exploration
    case maintenance
    case recovery
    case delegatedSupport = "delegated_support"
}

enum ExternalSurfaceStepState: String, Codable, Sendable {
    case planned
    case active
    case completed
    case blocked
    case cancelled
}

enum ExternalSurfaceUrgency: String, Codable, Sendable {
    case overdue
    case soon
    case normal
    case anytime
}

enum ExternalSurfaceTiming: String, Codable, Sendable {
    case deadline
    case window
    case cadence
    case untimed
}

struct ExternalSurfaceNowState: Codable, Sendable, Equatable {
    let todayPosture: ExternalSurfaceTodayPosture
    let pressureLevel: ExternalSurfacePressureLevel
    let bestNextStep: ExternalSurfaceActionReference?
    let activeFocus: ExternalSurfaceActionReference?
    let openCaptureUrgency: ExternalSurfaceCaptureUrgency
    let blockerSummary: ExternalSurfaceBlockerSummary
    let ritualCue: ExternalSurfaceRitualCue?
    let supportedCommands: [ExternalSurfaceCommandDescriptor]

    init(
        todayPosture: ExternalSurfaceTodayPosture,
        pressureLevel: ExternalSurfacePressureLevel,
        bestNextStep: ExternalSurfaceActionReference?,
        activeFocus: ExternalSurfaceActionReference?,
        openCaptureUrgency: ExternalSurfaceCaptureUrgency,
        blockerSummary: ExternalSurfaceBlockerSummary,
        ritualCue: ExternalSurfaceRitualCue? = nil,
        supportedCommands: [ExternalSurfaceCommandDescriptor]
    ) {
        self.todayPosture = todayPosture
        self.pressureLevel = pressureLevel
        self.bestNextStep = bestNextStep
        self.activeFocus = activeFocus
        self.openCaptureUrgency = openCaptureUrgency
        self.blockerSummary = blockerSummary
        self.ritualCue = ritualCue
        self.supportedCommands = supportedCommands
    }
}

struct ExternalSurfaceActionReference: Codable, Sendable, Equatable {
    let goalID: String
    let stepID: String?

    init(goalID: String, stepID: String? = nil) {
        self.goalID = goalID
        self.stepID = stepID
    }
}

struct ExternalSurfaceBlockerSummary: Codable, Sendable, Equatable {
    let waitingCount: Int
    let blockedCount: Int
}

struct ExternalSurfaceCommandDescriptor: Codable, Sendable, Equatable {
    let kind: ExternalSurfaceCommandKind
    let requiresGoalID: Bool
    let requiresStepID: Bool
}

struct ExternalSurfaceRitualCue: Codable, Sendable, Equatable {
    let kind: ExternalSurfaceRitualKind
    let templateKey: String
    let progressState: ExternalSurfaceRitualProgressState
    let primaryReference: ExternalSurfaceActionReference?
}

enum ExternalSurfaceTodayPosture: String, Codable, Sendable {
    case empty
    case active
    case waiting
    case recovery
}

enum ExternalSurfacePressureLevel: String, Codable, Sendable {
    case open
    case steady
    case elevated
    case overloaded
}

enum ExternalSurfaceCaptureUrgency: String, Codable, Sendable {
    case none
    case low
    case elevated
}

enum ExternalSurfaceRitualKind: String, Codable, Sendable {
    case morningSetup = "morning_setup"
    case middayReset = "midday_reset"
    case eveningClose = "evening_close"
    case weeklyReset = "weekly_reset"
}

enum ExternalSurfaceRitualProgressState: String, Codable, Sendable {
    case unavailable
    case ready
    case needsReset = "needs_reset"
    case complete
}

enum ExternalSurfaceCommandKind: String, Codable, Sendable {
    case complete
    case snooze
    case openGoal
    case openToday
    case openCapturesInbox
}
