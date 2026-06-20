import Foundation

struct NotificationPermission: Sendable {
    func state(for authorization: NotificationAuthorizationState) -> PermissionState {
        PermissionState(
            kind: .notifications,
            availability: availability(for: authorization),
            canRead: authorization.allowsDelivery,
            canWrite: authorization.allowsDelivery,
            canRequest: authorization == .notDetermined,
            requestTiming: authorization == .notDetermined ? .userInitiated : .blocked,
            fallbackSummary: fallbackSummary(for: authorization),
            inspectionSummary: "Notification permission is optional and local reminder scheduling stays inspectable. State: \(authorization)."
        )
    }

    func optInDecision(
        current authorization: NotificationAuthorizationState,
        context: PermissionRequestContext
    ) -> PermissionRequestDecision {
        let permissionState = state(for: authorization)
        guard context.isContextual else {
            return .blocked(
                state: permissionState,
                reason: "Notification prompts require an explicit user action."
            )
        }
        guard authorization == .notDetermined else {
            return .blocked(
                state: permissionState,
                reason: "Notification authorization is already determined."
            )
        }
        return .request(
            state: permissionState,
            reason: "Notification access is requested from an explicit reminder opt-in."
        )
    }

    private func availability(for authorization: NotificationAuthorizationState) -> PermissionAvailability {
        switch authorization {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized, .provisional, .ephemeral:
            return .available
        }
    }

    private func fallbackSummary(for authorization: NotificationAuthorizationState) -> String {
        authorization.allowsDelivery
            ? "Local reminders may be scheduled without exposing private details on the Lock Screen."
            : "Ambitions continues in-app reminders and Today recovery without notification access."
    }
}

extension NotificationAuthorizationState {
    var allowsDelivery: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}
