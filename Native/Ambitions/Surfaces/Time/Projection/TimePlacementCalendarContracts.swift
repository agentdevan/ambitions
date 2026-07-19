import AmbitionsDesignSystem
import Foundation

enum TimePlacementCandidateKind: String, Sendable, Hashable {
    case goalLinked
    case freeFloating

    var sourceLabel: String {
        switch self {
        case .goalLinked:
            "Goal Step"
        case .freeFloating:
            "Free-floating Step"
        }
    }
}

struct TimePlacementCandidate: Identifiable, Sendable, Hashable {
    let id: String
    let stepID: String
    let goalID: String?
    let title: String
    let detail: String
    let durationMinutes: Int
    let sourceLabel: String
    let kind: TimePlacementCandidateKind

    var isRealStep: Bool {
        id.isEmpty == false && stepID.isEmpty == false
    }

    var accessibilitySummary: String {
        [
            title,
            kind.sourceLabel,
            detail,
            "\(durationMinutes) minutes"
        ].filter { $0.isEmpty == false }.joined(separator: ". ")
    }
}

enum TimeCalendarRowKind: String, Sendable, Hashable {
    case now
    case fixedPoint
    case openWindow
    case scheduledStep
    case protectedWindow
    case pressure
    case buffer
    case recovery
    case goalLoad
    case day
    case week
    case month
    case year
    case list

    var systemImage: String {
        switch self {
        case .now:
            "clock"
        case .fixedPoint:
            "pin"
        case .openWindow:
            "sun.max"
        case .scheduledStep:
            "checkmark.circle"
        case .protectedWindow:
            "lock"
        case .pressure:
            "waveform.path"
        case .buffer:
            "rectangle.compress.vertical"
        case .recovery:
            "leaf"
        case .goalLoad:
            "scope"
        case .day:
            "sun.max"
        case .week:
            "calendar"
        case .month:
            "calendar.badge.clock"
        case .year:
            "chart.line.uptrend.xyaxis"
        case .list:
            "list.bullet"
        }
    }
}

struct TimeCalendarRow: Identifiable, Sendable, Hashable {
    let id: String
    let kind: TimeCalendarRowKind
    let title: String
    let value: String
    let detail: String
    let visualState: AmbitionVisualState
    let isOperational: Bool

    var accessibilitySummary: String {
        [
            title,
            value,
            detail,
            isOperational ? "Available" : "Staged"
        ].joined(separator: ". ")
    }
}
