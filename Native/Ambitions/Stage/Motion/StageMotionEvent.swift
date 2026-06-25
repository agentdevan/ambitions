
import Foundation

/// Typed Motion action contract.
///
/// Motion is object movement, recovery, review, and return, not analytics and not a passive ledger.
/// Root shell routing can map these actions to Today, Goals, Time, Trust, or review
/// destinations without adding a fifth tab.
enum MotionCurrentAction: Equatable, Hashable, Sendable {
    case reviewHistory(String?)
    case openHistory(String?)
    case returnToThread(String?)
    case openToday
    case openGoals
    case openTime
    case openTrust
}

extension MotionCurrentAction {
    static let notificationName = Notification.Name("AmbitionsMotionCurrentActionSelected")
    static let notificationPayloadKey = "ambitions.motion.current.action"
    static let notificationSourceKey = "ambitions.motion.current.source"

    var identifier: String? {
        switch self {
        case let .reviewHistory(value):
            value
        case let .openHistory(value):
            value
        case let .returnToThread(value):
            value
        case .openToday, .openGoals, .openTime, .openTrust:
            nil
        }
    }

    static func fromTitle(_ title: String) -> MotionCurrentAction? {
        switch title.lowercased() {
        case "review":
            return .reviewHistory(nil)
        case "history":
            return .openHistory(nil)
        case "return":
            return .returnToThread(nil)
        case "open today", "start here":
            return .openToday
        case "open goals":
            return .openGoals
        case "open time":
            return .openTime
        case "open trust":
            return .openTrust
        default:
            return nil
        }
    }

    func toNotificationPayload() -> [String: AnyHashable] {
        [MotionCurrentAction.notificationPayloadKey: self]
    }
}

extension Notification {
    var ambitionsMotionCurrentAction: MotionCurrentAction? {
        if let payload = userInfo?[MotionCurrentAction.notificationPayloadKey] as? MotionCurrentAction {
            return payload
        }
        if let rawTitle = userInfo?[MotionCurrentAction.notificationPayloadKey] as? String {
            return MotionCurrentAction.fromTitle(rawTitle)
        }
        if let title = object as? String {
            return MotionCurrentAction.fromTitle(title)
        }
        return nil
    }
}
