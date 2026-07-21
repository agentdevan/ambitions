import Foundation

public enum ExternalSurfaceActionName: String, Codable, Sendable, Equatable {
    case open
    case complete
    case snooze
    case delay
    case askForSmallerStep = "ask-for-smaller-step"
    case openToday = "open-today"
    case openCaptureComposer = "open-capture-composer"
    case openMemoryLens = "open-memory-lens"

    public init(rawAction: String) {
        switch rawAction.lowercased() {
        case "complete":
            self = .complete
        case "delay":
            self = .delay
        case "snooze":
            self = .snooze
        case "ask-for-smaller-step", "smaller-step":
            self = .askForSmallerStep
        case "open-today":
            self = .openToday
        case "open-capture-composer":
            self = .openCaptureComposer
        case "open-memory-lens", "memory-lens":
            self = .openMemoryLens
        default:
            self = .open
        }
    }
}

public enum ExternalSurfacePayloadSurface: String, Codable, Sendable, Equatable {
    case tab
    case goalDetail = "goal-detail"
    case captureComposer = "capture-composer"
}

public enum ExternalSurfaceKind: String, CaseIterable, Codable, Sendable, Equatable {
    case notifications
    case widgets
    case liveActivities = "live_activities"
    case appIntents = "app_intents"
    case shortcuts
    case focusFilters = "focus_filters"
}

public enum ExternalSurfacePrivacyDefault: String, Codable, Sendable, Equatable {
    case sparse
    case detailsHidden = "details_hidden"
    case glanceablePrivate = "glanceable_private"
    case minimalPayload = "minimal_payload"
    case conservative
    case optIn = "opt_in"
}

public struct ExternalSurfacePrivacySnapshotPolicy: Codable, Sendable, Equatable {
    public static let safeDefault = ExternalSurfacePrivacySnapshotPolicy(
        defaultVisibility: .detailsHidden,
        sensitiveDetailLabel: "Details stay private until you open Ambitions.",
        unavailableLabel: "Open Ambitions to confirm the latest local state.",
        staleLabel: "This may be behind. Open Ambitions to refresh."
    )

    public let defaultVisibility: ExternalSurfacePrivacyDefault
    public let sensitiveDetailLabel: String
    public let unavailableLabel: String
    public let staleLabel: String

    private init(
        defaultVisibility: ExternalSurfacePrivacyDefault,
        sensitiveDetailLabel: String,
        unavailableLabel: String,
        staleLabel: String
    ) {
        self.defaultVisibility = defaultVisibility
        self.sensitiveDetailLabel = sensitiveDetailLabel
        self.unavailableLabel = unavailableLabel
        self.staleLabel = staleLabel
    }
}
