import Foundation

enum HapticPolicy {
    enum Intent: String, Sendable, Equatable {
        case confirmation
        case selection
        case warning
        case none
    }

    static func intent(for actionKind: TodayActionKind) -> Intent {
        switch actionKind {
        case .complete, .quickLog:
            return .confirmation
        case .askForHelp, .reschedule:
            return .warning
        case .openDetail, .askWhyThisMatters, .openTime, .protectLater:
            return .selection
        default:
            return .none
        }
    }
}
