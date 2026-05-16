import Foundation

enum AppTab: String, CaseIterable, Hashable, Identifiable, Codable {
    case today
    case capture
    case goals
    case habits
    case time
    case insights
    case you

    static var allCases: [AppTab] {
        [.today, .goals, .capture, .time, .you]
    }

    var id: String { rawValue }

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
