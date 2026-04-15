import Foundation

enum AppTab: String, CaseIterable, Hashable, Identifiable, Codable {
    case today
    case captures
    case goals
    case habits
    case insights
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: "Today"
        case .captures: "Captures"
        case .goals: "Goals"
        case .habits: "Habits"
        case .insights: "Insights"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .captures: "tray.full"
        case .goals: "target"
        case .habits: "repeat"
        case .insights: "chart.line.uptrend.xyaxis"
        case .profile: "person.crop.circle"
        }
    }
}
