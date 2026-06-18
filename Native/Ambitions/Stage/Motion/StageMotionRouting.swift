import Foundation

/// The cross-surface route produced by the Stage/Motion behavior layer.
///
/// Motion is not a root destination. It is a behavior layer that interprets
/// recovery, proof, receipt, and re-entry intent, then returns the user to the
/// correct canonical surface.
enum StageMotionRoute {
    case returnToToday(TodayEntryContext)
    case openGoals
    case openTime
    case openTrust
    case presentOverlay(ShellOverlayState)
    case none
}

/// User-visible actions emitted by Motion Current.
///
/// These are not legacy tab actions. They are cross-surface behavior intents:
/// inspect proof, open a receipt, re-enter a thread, or route to a canonical
/// object-stage surface.
enum MotionCurrentAction: Equatable, Sendable {
    case openToday
    case openGoals
    case openTime
    case openTrust
    case inspectProof(String)
    case openReceipt(String)
    case openThread(String)

    static let notificationName = Notification.Name("Ambitions.StageMotion.CurrentAction")
    static let notificationActionKey = "ambitions.stageMotion.action"
    static let notificationValueKey = "ambitions.stageMotion.value"
    static let notificationSourceKey = "ambitions.stageMotion.source"

    func toNotificationPayload(source: String = "motion.current") -> [AnyHashable: Any] {
        var payload: [AnyHashable: Any] = [
            Self.notificationActionKey: actionName,
            Self.notificationSourceKey: source
        ]
        if let payloadValue {
            payload[Self.notificationValueKey] = payloadValue
        }
        return payload
    }

    private var actionName: String {
        switch self {
        case .openToday:
            return "openToday"
        case .openGoals:
            return "openGoals"
        case .openTime:
            return "openTime"
        case .openTrust:
            return "openTrust"
        case .inspectProof:
            return "inspectProof"
        case .openReceipt:
            return "openReceipt"
        case .openThread:
            return "openThread"
        }
    }

    private var payloadValue: String? {
        switch self {
        case .openToday, .openGoals, .openTime, .openTrust:
            return nil
        case let .inspectProof(value), let .openReceipt(value), let .openThread(value):
            return value
        }
    }

    static func fromNotificationPayload(_ payload: [AnyHashable: Any]?) -> MotionCurrentAction? {
        guard let actionName = payload?[notificationActionKey] as? String else { return nil }
        let value = payload?[notificationValueKey] as? String ?? ""
        switch actionName {
        case "openToday":
            return .openToday
        case "openGoals":
            return .openGoals
        case "openTime":
            return .openTime
        case "openTrust":
            return .openTrust
        case "inspectProof":
            return .inspectProof(value)
        case "openReceipt":
            return .openReceipt(value)
        case "openThread":
            return .openThread(value)
        default:
            return nil
        }
    }
}

extension Notification {
    var ambitionsMotionCurrentAction: MotionCurrentAction? {
        MotionCurrentAction.fromNotificationPayload(userInfo)
    }
}

/// Owns Stage/Motion behavior routing for the root shell.
///
/// This type is intentionally app-local and deterministic. It does not create
/// a Motion root tab and it does not silently mutate user data. It translates
/// Motion Current action intent into canonical object-stage routes.
@MainActor
final class StageOwner {
    private var reduceMotionEnabled = false

    func setReduceMotionEnabled(_ isEnabled: Bool) {
        reduceMotionEnabled = isEnabled
    }

    func route(for action: MotionCurrentAction, source: String) -> StageMotionRoute {
        switch action {
        case .openToday:
            return .returnToToday(.standard)
        case .openGoals:
            return .openGoals
        case .openTime:
            return .openTime
        case .openTrust:
            return .openTrust
        case .inspectProof:
            return .openTrust
        case .openReceipt:
            return .openTrust
        case .openThread:
            return .returnToToday(.focus)
        }
    }
}
