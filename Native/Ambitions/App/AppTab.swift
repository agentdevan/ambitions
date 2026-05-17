import Foundation

enum AppTab: CaseIterable, Hashable, Identifiable, Codable, RawRepresentable {
    typealias RawValue = String

    case today
    case capture
    case goals
    case habits
    case time
    case insights
    case you

    // Legacy compatibility aliases
    static let captures = AppTab.capture
    static let plan = AppTab.time
    static let profile = AppTab.you

    static var allCases: [AppTab] {
        [.today, .goals, .capture, .time, .you]
    }

    var id: String { rawValue }

    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "today": self = .today
        case "capture", "captures": self = .capture
        case "goals": self = .goals
        case "habits": self = .habits
        case "time", "plan": self = .time
        case "insights": self = .insights
        case "you", "profile": self = .you
        default: return nil
        }
    }

    var rawValue: String {
        switch self {
        case .today: return "today"
        case .capture: return "capture"
        case .goals: return "goals"
        case .habits: return "habits"
        case .time: return "time"
        case .insights: return "insights"
        case .you: return "you"
        }
    }

    var canonicalTopLevelTab: AppTab {
        switch self {
        case .capture:
            return .capture
        case .habits:
            return .time
        case .insights:
            return .you
        case .today, .goals, .time, .you:
            return self
        }
    }

    var isCanonicalTopLevel: Bool {
        self == canonicalTopLevelTab
    }

    var title: String {
        switch self {
        case .today: "Today"
        case .capture: "Capture"
        case .goals: "Goals"
        case .habits: "Rituals"
        case .time: "Time"
        case .insights: "History"
        case .you: "You"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .capture: "tray.full"
        case .goals: "target"
        case .habits: "repeat"
        case .time: "clock.badge"
        case .insights: "chart.line.uptrend.xyaxis"
        case .you: "person.crop.circle"
        }
    }
}
