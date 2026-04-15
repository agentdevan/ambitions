import Foundation
import UserNotifications

struct NotificationResponsePayloadParser {
    func payload(actionIdentifier: String, userInfo: [AnyHashable: Any]) -> AppNotificationRoutingPayload? {
        let action: String
        switch actionIdentifier {
        case UNNotificationDefaultActionIdentifier, AppNotificationConstants.openActionID:
            action = "open"
        case AppNotificationConstants.snoozeActionID:
            action = "snooze"
        case AppNotificationConstants.completeActionID:
            action = "complete"
        case UNNotificationDismissActionIdentifier:
            action = "dismiss"
        default:
            action = actionIdentifier
        }

        let values = userInfo.reduce(into: [String: String]()) { partialResult, item in
            guard let key = item.key as? String else { return }
            if let string = item.value as? String {
                partialResult[key] = string
            } else {
                partialResult[key] = "\(item.value)"
            }
        }
        return AppNotificationRoutingPayload(action: action, values: values)
    }
}

@MainActor
final class NotificationRuntime: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationRuntime()

    weak var bootstrapper: AppBootstrapper?
    private let parser = NotificationResponsePayloadParser()

    func activate() {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        _ = center
        guard let payload = parser.payload(
            actionIdentifier: response.actionIdentifier,
            userInfo: response.notification.request.content.userInfo
        ) else { return }
        bootstrapper?.handleNotificationPayload(payload)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        _ = center
        _ = notification
        return [.banner, .sound]
    }
}
