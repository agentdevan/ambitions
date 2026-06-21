import Foundation

enum AmbitionsSurface: CaseIterable, Hashable, Identifiable, Codable, RawRepresentable {
    typealias RawValue = String

    case today
    case goals
    case time
    case you

    static var allCases: [AmbitionsSurface] {
        [.today, .goals, .time, .you]
    }

    var id: String { rawValue }

    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "today": self = .today
        case "goals": self = .goals
        case "time": self = .time
        case "you": self = .you
        default: return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let tab = AmbitionsSurface(rawValue: rawValue) {
            self = tab
            return
        }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unknown Ambitions tab raw value: \(rawValue)"
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var rawValue: String {
        switch self {
        case .today: return "today"
        case .goals: return "goals"
        case .time: return "time"
        case .you: return "you"
        }
    }

    var canonicalTopLevelTab: AmbitionsSurface {
        self
    }

    var isCanonicalTopLevel: Bool {
        AmbitionsSurface.allCases.contains(self) && self == canonicalTopLevelTab
    }

    var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .time: "Time"
        case .you: "You"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .goals: "target"
        case .time: "clock.badge"
        case .you: "person.crop.circle"
        }
    }

    var primaryObjectTitle: String {
        surfaceContract.primaryObjectTitle
    }

    var surfaceContract: AmbitionsSurfaceContract {
        AmbitionsSurfaceContractRegistry.contract(for: self)
    }
}
