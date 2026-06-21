import Foundation

enum LifeShapeHorizon: String, Sendable, CaseIterable, Identifiable, Hashable {
    case day
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day: "Day"
        case .week: "Week"
        case .month: "Month"
        case .year: "Year"
        }
    }
}
