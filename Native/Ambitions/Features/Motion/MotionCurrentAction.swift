
import Foundation

/// Typed Motion action contract.
///
/// Motion is proof/progress/inspection, not analytics and not a passive ledger.
/// Root shell routing can map these actions to Today, Goals, Time, Trust, receipt,
/// or proof-detail destinations without adding a sixth tab.
enum MotionCurrentAction: Equatable, Hashable, Sendable {
    case inspectProof(String?)
    case openReceipt(String?)
    case openThread(String?)
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
        case let .inspectProof(value):
            value
        case let .openReceipt(value):
            value
        case let .openThread(value):
            value
        case .openToday, .openGoals, .openTime, .openTrust:
            nil
        }
    }

    static func fromTitle(_ title: String) -> MotionCurrentAction? {
        switch title.lowercased() {
        case "inspect proof":
            return .inspectProof(nil)
        case "open receipt":
            return .openReceipt(nil)
        case "re-enter thread":
            return .openThread(nil)
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
