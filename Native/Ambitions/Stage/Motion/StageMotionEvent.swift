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

}
