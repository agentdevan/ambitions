import Foundation

let permissionStateSchemaVersion = "permission_state.native.v1"

enum AmbitionsPermissionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case calendarRead = "calendar_read"
    case calendarWrite = "calendar_write"
    case remindersWrite = "reminders_write"
    case notifications
    case speechRecognition = "speech_recognition"
    case localAuthentication = "local_authentication"
}

enum PermissionAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notDetermined = "not_determined"
    case available
    case denied
    case restricted
    case unavailable
}

enum PermissionRequestTiming: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userInitiated = "user_initiated"
    case blocked
}

struct PermissionState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: AmbitionsPermissionKind
    let availability: PermissionAvailability
    let canRead: Bool
    let canWrite: Bool
    let canRequest: Bool
    let requestTiming: PermissionRequestTiming
    let fallbackSummary: String
    let inspectionSummary: String

    init(
        kind: AmbitionsPermissionKind,
        availability: PermissionAvailability,
        canRead: Bool = false,
        canWrite: Bool = false,
        canRequest: Bool,
        requestTiming: PermissionRequestTiming,
        fallbackSummary: String,
        inspectionSummary: String
    ) {
        self.id = kind.rawValue
        self.kind = kind
        self.availability = availability
        self.canRead = canRead
        self.canWrite = canWrite
        self.canRequest = canRequest
        self.requestTiming = requestTiming
        self.fallbackSummary = fallbackSummary
        self.inspectionSummary = inspectionSummary
    }
}

struct PermissionRequestContext: Codable, Sendable, Equatable, Hashable {
    let surface: AmbitionsSurface
    let actionName: String
    let requiresExternalEffect: Bool
    let userInitiated: Bool

    init(
        surface: AmbitionsSurface,
        actionName: String,
        requiresExternalEffect: Bool = false,
        userInitiated: Bool = true
    ) {
        self.surface = surface
        self.actionName = actionName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requiresExternalEffect = requiresExternalEffect
        self.userInitiated = userInitiated
    }

    var isContextual: Bool {
        userInitiated && actionName.isEmpty == false
    }
}

struct PermissionRequestDecision: Codable, Sendable, Equatable, Hashable {
    let shouldRequestSystemPermission: Bool
    let state: PermissionState
    let reason: String

    static func blocked(state: PermissionState, reason: String) -> PermissionRequestDecision {
        PermissionRequestDecision(
            shouldRequestSystemPermission: false,
            state: state,
            reason: reason
        )
    }

    static func request(state: PermissionState, reason: String) -> PermissionRequestDecision {
        PermissionRequestDecision(
            shouldRequestSystemPermission: true,
            state: state,
            reason: reason
        )
    }
}
