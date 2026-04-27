import Foundation

enum AppTab: String, CaseIterable, Hashable, Identifiable, Codable {
    case today
    case captures
    case goals
    case habits
    case plan
    case insights
    case profile

    static var allCases: [AppTab] {
        [.today, .goals, .captures, .plan, .profile]
    }

    var id: String { rawValue }

    var canonicalTopLevelTab: AppTab {
        switch self {
        case .captures:
            return .captures
        case .habits:
            return .plan
        case .insights:
            return .profile
        case .today, .goals, .plan, .profile:
            return self
        }
    }

    var isCanonicalTopLevel: Bool {
        self == canonicalTopLevelTab
    }

    var title: String {
        switch self {
        case .today: "Today"
        case .captures: "Capture"
        case .goals: "Goals"
        case .habits: "Rituals"
        case .plan: "Plan"
        case .insights: "History"
        case .profile: "You"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .captures: "tray.full"
        case .goals: "target"
        case .habits: "repeat"
        case .plan: "calendar.badge.clock"
        case .insights: "chart.line.uptrend.xyaxis"
        case .profile: "person.crop.circle"
        }
    }
}
