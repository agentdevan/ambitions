import Foundation

enum YouInteractionIntent: Sendable, Equatable {
    case openDetail(YouRootDetail)
    case savePreferences
    case requestNotificationPermission
    case openSystemSettings
}

enum YouInteractions {
    static func accessibilityAnnouncement(for intent: YouInteractionIntent) -> String {
        switch intent {
        case let .openDetail(detail):
            "Opened \(detail.title)."
        case .savePreferences:
            "Settings saved."
        case .requestNotificationPermission:
            "Notification permission requested."
        case .openSystemSettings:
            "System settings opened."
        }
    }

    static func permissionAnnouncement(granted: Bool) -> String {
        granted ? "Notifications enabled." : "Notifications remain off."
    }
}
