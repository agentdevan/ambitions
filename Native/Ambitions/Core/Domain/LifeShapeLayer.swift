import Foundation

enum LifeShapeLayer: String, Sendable, CaseIterable, Identifiable, Hashable {
    case open
    case protected
    case pressure
    case buffer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .open: "Open"
        case .protected: "Protected"
        case .pressure: "Pressure"
        case .buffer: "Buffer"
        }
    }
}
