import Foundation

struct ExternalSurfaceSnapshot: Codable, Sendable, Equatable {
    static let schemaVersion = "external_surface_snapshot.v1"

    let schemaVersion: String
    let generatedAt: String
    let nextAction: ExternalSurfaceNextAction?
    let nowState: ExternalSurfaceNowState?
    let ambientState: ExternalSurfaceAmbientState?
    let continuity: ExternalSurfaceContinuityState

    init(
        schemaVersion: String = ExternalSurfaceSnapshot.schemaVersion,
        generatedAt: String,
        nextAction: ExternalSurfaceNextAction?,
        nowState: ExternalSurfaceNowState? = nil,
        ambientState: ExternalSurfaceAmbientState? = nil,
        continuity: ExternalSurfaceContinuityState? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.nextAction = nextAction
        self.nowState = nowState
        self.ambientState = ambientState
        self.continuity = continuity ?? .localFirst(generatedAt: generatedAt)
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case generatedAt
        case nextAction
        case nowState
        case ambientState
        case continuity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        generatedAt = try container.decode(String.self, forKey: .generatedAt)
        nextAction = try container.decodeIfPresent(ExternalSurfaceNextAction.self, forKey: .nextAction)
        nowState = try container.decodeIfPresent(ExternalSurfaceNowState.self, forKey: .nowState)
        ambientState = try container.decodeIfPresent(ExternalSurfaceAmbientState.self, forKey: .ambientState)
        continuity = try container.decodeIfPresent(ExternalSurfaceContinuityState.self, forKey: .continuity)
            ?? .localFirst(generatedAt: generatedAt)
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

struct ExternalSurfaceAmbientState: Codable, Sendable, Equatable {
    let today: ExternalSurfaceVariantState
    let focus: ExternalSurfaceVariantState
    let goal: ExternalSurfaceVariantState
    let plan: ExternalSurfaceVariantState
}

struct ExternalSurfaceVariantState: Codable, Sendable, Equatable {
    let kind: ExternalSurfaceVariantKind
    let title: String
    let detail: String
    let privacySummary: String
    let action: ExternalSurfaceVariantAction
    let reference: ExternalSurfaceActionReference?
    let prominence: ExternalSurfaceVariantProminence
}

struct ExternalSurfaceVariantAction: Codable, Sendable, Equatable {
    let title: String
    let surface: ExternalSurfacePayloadSurface
    let tab: String?
}

enum ExternalSurfaceVariantKind: String, Codable, Sendable {
    case today
    case focus
    case goal
    case plan
}

enum ExternalSurfaceVariantProminence: String, Codable, Sendable {
    case quiet
    case standard
    case elevated
}

struct ExternalSurfaceContinuityState: Codable, Sendable, Equatable {
    let lease: ExternalSurfaceNowStateLease
    let syncHealth: ExternalSurfaceSyncHealth
    let receipt: ExternalSurfaceContinuityReceipt?

    static func localFirst(generatedAt: String?) -> ExternalSurfaceContinuityState {
        ExternalSurfaceContinuityState(
            lease: ExternalSurfaceNowStateLease(
                status: .current,
                generatedAt: generatedAt,
                freshnessLabel: "Updated recently",
                staleActionLabel: "Open Ambitions to confirm"
            ),
            syncHealth: ExternalSurfaceSyncHealth(
                state: .localFirst,
                label: "Local-first and stable",
                detail: "Based on your last local plan"
            ),
            receipt: nil
        )
    }
}

struct ExternalSurfaceNowStateLease: Codable, Sendable, Equatable {
    let status: ExternalSurfaceLeaseStatus
    let generatedAt: String?
    let freshnessLabel: String
    let staleActionLabel: String
}

struct ExternalSurfaceSyncHealth: Codable, Sendable, Equatable {
    let state: ExternalSurfaceSyncHealthState
    let label: String
    let detail: String
}

struct ExternalSurfaceContinuityReceipt: Codable, Sendable, Equatable {
    let origin: ExternalSurfaceOrigin
    let label: String
}

enum ExternalSurfaceLeaseStatus: String, Codable, Sendable {
    case current
    case stale
    case unavailable
}

enum ExternalSurfaceSyncHealthState: String, Codable, Sendable {
    case localFirst = "local_first"
    case pending
    case stale
    case unavailable
    case conflicting
    case recovered
}

enum ExternalSurfaceOrigin: String, Codable, Sendable {
    case today
    case focus
    case goal
    case plan
    case widget
    case liveActivity = "live_activity"
    case notification
    case shareExtension = "share_extension"
    case appIntent = "app_intent"
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
    case openMemoryLens
}
