import Foundation

enum AppTab: CaseIterable, Hashable, Identifiable, Codable, RawRepresentable {
    typealias RawValue = String

    case today
    case goals
    case time
    case you

    static var allCases: [AppTab] {
        [.today, .goals, .time, .you]
    }

    static var capture: AppShellCaptureCompatibilityMetadata.Type {
        AppShellCaptureCompatibilityMetadata.self
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
        case .goals: return "goals"
        case .time: return "time"
        case .you: return "you"
        }
    }

    var canonicalTopLevelTab: AppTab {
        self
    }

    var isCanonicalTopLevel: Bool {
        AppTab.allCases.contains(self) && self == canonicalTopLevelTab
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

enum AppShellCaptureCompatibilityMetadata {
    static let systemImage = AppShellCaptureAccessModel.systemImage
}

struct AmbitionsSurfaceContract: Hashable, Sendable {
    let tab: AppTab
    let title: String
    let primaryObjectTitle: String
    let runtimeInspectionRequirements: [String]

    init(
        tab: AppTab,
        title: String,
        primaryObjectTitle: String,
        runtimeInspectionRequirements: [String] = AmbitionsSurfaceContractRegistry.runtimeInspectionRequirements
    ) {
        self.tab = tab
        self.title = title
        self.primaryObjectTitle = primaryObjectTitle
        self.runtimeInspectionRequirements = runtimeInspectionRequirements
    }
}

enum AmbitionsSurfaceContractRegistry {
    static let runtimeInspectionRequirements = [
        "SourceRecord",
        "Receipt",
        "ReplayTrace",
        "You / Search Ambitions"
    ]

    static let canonicalContracts: [AmbitionsSurfaceContract] = [
        AmbitionsSurfaceContract(tab: .today, title: "Today", primaryObjectTitle: "Reality Meridian"),
        AmbitionsSurfaceContract(tab: .goals, title: "Goals", primaryObjectTitle: "Constellation Atlas"),
        AmbitionsSurfaceContract(tab: .time, title: "Time", primaryObjectTitle: "LifeShape Field"),
        AmbitionsSurfaceContract(tab: .you, title: "You", primaryObjectTitle: "User System Profile")
    ]

    static func contract(for tab: AppTab) -> AmbitionsSurfaceContract {
        guard let contract = canonicalContracts.first(where: { $0.tab == tab }) else {
            preconditionFailure("Missing Ambitions surface contract for \(tab.rawValue)")
        }
        return contract
    }

    static func validate(_ contracts: [AmbitionsSurfaceContract] = canonicalContracts) -> [String] {
        var issues: [String] = []

        if contracts.map(\.tab) != AppTab.allCases {
            issues.append("Surface contracts must follow Today, Goals, Time, You.")
        }

        if contracts.map(\.title) != AppTab.allCases.map(\.title) {
            issues.append("Surface contract titles must match active app tab titles.")
        }

        for tab in AppTab.allCases {
            guard let contract = contracts.first(where: { $0.tab == tab }) else {
                issues.append("Missing surface contract for \(tab.title).")
                continue
            }
            if contract.primaryObjectTitle != canonicalPrimaryObjectTitle(for: tab) {
                issues.append("\(tab.title) must own \(canonicalPrimaryObjectTitle(for: tab)), not \(contract.primaryObjectTitle).")
            }
            if Set(contract.runtimeInspectionRequirements) != Set(runtimeInspectionRequirements) {
                issues.append("\(tab.title) must preserve runtime inspection requirements.")
            }
        }

        let duplicateObjects = Dictionary(grouping: contracts, by: \.primaryObjectTitle)
            .filter { $0.value.count > 1 }
            .keys
        for duplicate in duplicateObjects.sorted() {
            issues.append("Primary object \(duplicate) is assigned to multiple top-level surfaces.")
        }

        return issues
    }

    private static func canonicalPrimaryObjectTitle(for tab: AppTab) -> String {
        switch tab {
        case .today: "Reality Meridian"
        case .goals: "Constellation Atlas"
        case .time: "LifeShape Field"
        case .you: "User System Profile"
        }
    }
}

enum LegacyIARouteCompatibility {
    static func canonicalTab(forRawTab rawValue: String) -> AppTab? {
        switch rawValue.lowercased() {
        case "capture", "captures":
            .today
        case "motion", "pulse":
            .today
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
            (.today, nil, nil)
        case "goals":
            (.goals, nil, nil)
        case "time", "plan":
            (.time, nil, nil)
        case "motion", "pulse":
            (.today, nil, nil)
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
            return .openCaptureComposer
        case "goals":
            return .openTab(.goals)
        case "time", "plan":
            return .openTab(.time)
        case "motion", "pulse":
            return .openTab(.today)
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
