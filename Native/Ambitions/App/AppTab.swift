import Foundation

enum AppTab: CaseIterable, Hashable, Identifiable, Codable, RawRepresentable {
    typealias RawValue = String

    case today
    case capture
    case goals
    case time
    case you

    static var allCases: [AppTab] {
        [.today, .goals, .capture, .time, .you]
    }

    var id: String { rawValue }

    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "today": self = .today
        case "capture": self = .capture
        case "goals": self = .goals
        case "time": self = .time
        case "you": self = .you
        default: return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        if let tab = AppTab(rawValue: rawValue) ?? LegacyIARouteCompatibility.canonicalTab(forRawTab: rawValue) {
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
        case .capture: return "capture"
        case .goals: return "goals"
        case .time: return "time"
        case .you: return "you"
        }
    }

    var canonicalTopLevelTab: AppTab {
        self
    }

    var isCanonicalTopLevel: Bool {
        self == canonicalTopLevelTab
    }

    var title: String {
        switch self {
        case .today: "Today"
        case .capture: "Capture"
        case .goals: "Goals"
        case .time: "Time"
        case .you: "You"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .capture: "tray.full"
        case .goals: "target"
        case .time: "clock.badge"
        case .you: "person.crop.circle"
        }
    }
}

enum LegacyIARouteCompatibility {
    static func canonicalTab(forRawTab rawValue: String) -> AppTab? {
        switch rawValue.lowercased() {
        case "captures":
            .capture
        case "plan", "habits":
            .time
        case "profile", "insights":
            .you
        default:
            nil
        }
    }

    static func navigationSeed(forRawTab rawValue: String) -> (selectedTab: AppTab, timeRoute: TimeRouteTarget?, youRoute: YouRouteTarget?)? {
        switch rawValue.lowercased() {
        case "today":
            (.today, nil, nil)
        case "capture", "captures":
            (.capture, nil, nil)
        case "goals":
            (.goals, nil, nil)
        case "time", "plan":
            (.time, nil, nil)
        case "habits":
            (.time, .habits, nil)
        case "you", "profile":
            (.you, nil, nil)
        case "insights":
            (.you, nil, .history)
        default:
            nil
        }
    }

    static func externalRoute(forRawTab rawValue: String, todayContext: TodayEntryContext? = nil) -> AppExternalRoute? {
        switch rawValue.lowercased() {
        case "today":
            if let todayContext, todayContext != .standard {
                return .openToday(todayContext)
            }
            return .openTab(.today)
        case "capture", "captures":
            return .openTab(.capture)
        case "goals":
            return .openTab(.goals)
        case "time", "plan":
            return .openTab(.time)
        case "habits":
            return .openTimeRoute(.habits)
        case "you", "profile":
            return .openTab(.you)
        case "insights":
            return .openYouRoute(.history)
        default:
            return nil
        }
    }
}
