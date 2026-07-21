import AmbitionsExternalContracts
import Foundation

struct ExternalSurfaceSnapshot: Codable, Sendable, Equatable {
    static let schemaVersion = "external_surface_snapshot.v1"

    let schemaVersion: String
    let generatedAt: String
    let nextAction: ExternalSurfaceNextAction?
    let nowState: ExternalSurfaceNowState?
    let ambientState: ExternalSurfaceAmbientState?
    let continuity: ExternalSurfaceContinuityState
    let privacy: ExternalSurfacePrivacySnapshotPolicy

    init(
        schemaVersion: String = ExternalSurfaceSnapshot.schemaVersion,
        generatedAt: String,
        nextAction: ExternalSurfaceNextAction?,
        nowState: ExternalSurfaceNowState? = nil,
        ambientState: ExternalSurfaceAmbientState? = nil,
        continuity: ExternalSurfaceContinuityState? = nil,
        privacy: ExternalSurfacePrivacySnapshotPolicy = .safeDefault
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.nextAction = nextAction
        self.nowState = nowState
        self.ambientState = ambientState
        self.continuity = continuity ?? .localFirst(generatedAt: generatedAt)
        self.privacy = privacy
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case generatedAt
        case nextAction
        case nowState
        case ambientState
        case continuity
        case privacy
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
        privacy = try container.decodeIfPresent(ExternalSurfacePrivacySnapshotPolicy.self, forKey: .privacy)
            ?? .safeDefault
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
    let timeShape: ExternalSurfaceVariantState
    let currentStep: ExternalSurfaceVariantState?
    let todayPressure: ExternalSurfaceVariantState?
    let protectedTime: ExternalSurfaceVariantState?
    let captureEntry: ExternalSurfaceVariantState?
    let recovery: ExternalSurfaceVariantState?

    init(
        today: ExternalSurfaceVariantState,
        focus: ExternalSurfaceVariantState,
        goal: ExternalSurfaceVariantState,
        timeShape: ExternalSurfaceVariantState,
        currentStep: ExternalSurfaceVariantState? = nil,
        todayPressure: ExternalSurfaceVariantState? = nil,
        protectedTime: ExternalSurfaceVariantState? = nil,
        captureEntry: ExternalSurfaceVariantState? = nil,
        recovery: ExternalSurfaceVariantState? = nil
    ) {
        self.today = today
        self.focus = focus
        self.goal = goal
        self.timeShape = timeShape
        self.currentStep = currentStep
        self.todayPressure = todayPressure
        self.protectedTime = protectedTime
        self.captureEntry = captureEntry
        self.recovery = recovery
    }
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
    case timeShape = "time_shape"
    case currentStep = "current_step"
    case todayPressure = "today_pressure"
    case protectedTime = "protected_time"
    case captureEntry = "capture_entry"
    case recovery
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
    let lifecycle: ExternalSurfaceLifecycleReconciliationState

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
                detail: "Based on your last local Time shape"
            ),
            receipt: nil,
            lifecycle: .localFirst(context: .app, generatedAt: generatedAt)
        )
    }

    init(
        lease: ExternalSurfaceNowStateLease,
        syncHealth: ExternalSurfaceSyncHealth,
        receipt: ExternalSurfaceContinuityReceipt? = nil,
        lifecycle: ExternalSurfaceLifecycleReconciliationState? = nil,
        lifecycleContext: ExternalSurfaceLifecycleContext = .app
    ) {
        self.lease = lease
        self.syncHealth = syncHealth
        self.receipt = receipt
        self.lifecycle = lifecycle ?? ExternalSurfaceLifecycleReconciliationState.make(
            context: lifecycleContext,
            leaseStatus: lease.status,
            syncHealthState: syncHealth.state,
            generatedAt: lease.generatedAt
        )
    }

    enum CodingKeys: String, CodingKey {
        case lease
        case syncHealth
        case receipt
        case lifecycle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lease = try container.decode(ExternalSurfaceNowStateLease.self, forKey: .lease)
        let syncHealth = try container.decode(ExternalSurfaceSyncHealth.self, forKey: .syncHealth)
        let receipt = try container.decodeIfPresent(ExternalSurfaceContinuityReceipt.self, forKey: .receipt)
        let lifecycle = try container.decodeIfPresent(ExternalSurfaceLifecycleReconciliationState.self, forKey: .lifecycle)

        self.init(
            lease: lease,
            syncHealth: syncHealth,
            receipt: receipt,
            lifecycle: lifecycle
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

enum ExternalSurfaceLifecycleContext: String, Codable, Sendable, Equatable, CaseIterable {
    case app
    case `extension`
    case widget
    case liveActivity = "live_activity"
    case background
    case relaunch
}

enum ExternalSurfaceLifecycleSourceState: String, Codable, Sendable, Equatable {
    case fresh
    case stale
    case unavailable
}

struct ExternalSurfaceLifecycleReconciliationState: Codable, Sendable, Equatable {
    let context: ExternalSurfaceLifecycleContext
    let sourceState: ExternalSurfaceLifecycleSourceState
    let sourceStateLabel: String
    let backgroundMaintenanceMayMutateUserData: Bool
    let preservesCanonicalPayloadsOnRelaunch: Bool

    static func localFirst(
        context: ExternalSurfaceLifecycleContext,
        generatedAt: String?
    ) -> ExternalSurfaceLifecycleReconciliationState {
        make(
            context: context,
            leaseStatus: .current,
            syncHealthState: .localFirst,
            generatedAt: generatedAt
        )
    }

    static func make(
        context: ExternalSurfaceLifecycleContext,
        leaseStatus: ExternalSurfaceLeaseStatus,
        syncHealthState: ExternalSurfaceSyncHealthState,
        generatedAt: String?
    ) -> ExternalSurfaceLifecycleReconciliationState {
        let sourceState: ExternalSurfaceLifecycleSourceState
        let sourceStateLabel: String

        switch (leaseStatus, syncHealthState) {
        case (.current, .localFirst), (.current, .recovered):
            sourceState = .fresh
            sourceStateLabel = "Fresh local source state"
        case (.stale, _), (_, .stale), (_, .pending), (_, .conflicting):
            sourceState = .stale
            sourceStateLabel = "Stale local source state"
        case (.unavailable, _), (_, .unavailable):
            sourceState = .unavailable
            sourceStateLabel = "Needs context"
        default:
            sourceState = .fresh
            sourceStateLabel = "Fresh local source state"
        }

        let contextLabel: String
        switch context {
        case .app:
            contextLabel = "App"
        case .`extension`:
            contextLabel = "Extension"
        case .widget:
            contextLabel = "Widget"
        case .liveActivity:
            contextLabel = "Live Activity"
        case .background:
            contextLabel = "Background"
        case .relaunch:
            contextLabel = "Relaunch"
        }

        let freshnessSuffix = generatedAt.map { " at \($0)" } ?? ""

        return ExternalSurfaceLifecycleReconciliationState(
            context: context,
            sourceState: sourceState,
            sourceStateLabel: "\(contextLabel) \(sourceStateLabel)\(freshnessSuffix)".trimmingCharacters(in: .whitespacesAndNewlines),
            backgroundMaintenanceMayMutateUserData: false,
            preservesCanonicalPayloadsOnRelaunch: true
        )
    }
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
    case time
    case widget
    case spotlight
    case handoff
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
    case openCaptureComposer
    case openMemoryLens
}
