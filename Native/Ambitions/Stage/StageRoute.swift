import Foundation

enum GoalDetailLaunchContext: String, Hashable, Sendable {
    case standard
    case help
}

struct GoalRouteTarget: Hashable, Identifiable, Sendable {
    let goalID: String?
    let draftID: String?
    let lifeAreaID: String?
    let launchContext: GoalDetailLaunchContext

    init(
        goalID: String? = nil,
        draftID: String? = nil,
        lifeAreaID: String? = nil,
        launchContext: GoalDetailLaunchContext = .standard
    ) {
        self.goalID = goalID
        self.draftID = draftID
        self.lifeAreaID = lifeAreaID
        self.launchContext = launchContext
    }

    var id: String {
        "\(goalID ?? "goal:none")|\(draftID ?? "draft:none")|\(lifeAreaID ?? "area:none")|\(launchContext.rawValue)"
    }

    var canonicalGoalID: String? { goalID }

    var hasAddressableContent: Bool { goalID != nil || draftID != nil || lifeAreaID != nil }

    var isLifeAreaRoute: Bool { lifeAreaID != nil && goalID == nil && draftID == nil }
}

enum TimeRouteTarget: String, Hashable, Identifiable, Sendable {
    case rituals
    case weeklyReview

    var id: String { rawValue }
}

enum YouRouteTarget: String, CaseIterable, Hashable, Identifiable, Sendable {
    case monthlyReview
    case history
    case personalSystem
    case privacyAutomation
    case receiptsHistory
    case scheduleAvailability
    case planningDefaults
    case vacationAwayTime
    case localContextControls
    case notifications
    case capturePreferences
    case sessionDefaults
    case appearance
    case privacy
    case sourceSettings
    case localDataControls
    case exportImport
    case help
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthlyReview: "Monthly Review"
        case .history: "History"
        case .personalSystem: "Personal system"
        case .privacyAutomation: "Privacy & automation"
        case .receiptsHistory: "Receipts & History"
        case .scheduleAvailability: "Schedule & Availability"
        case .planningDefaults: "Planning Defaults"
        case .vacationAwayTime: "Vacation / Away Time"
        case .localContextControls: "Local Context Controls"
        case .notifications: "Notifications"
        case .capturePreferences: "Capture"
        case .sessionDefaults: "Session Defaults"
        case .appearance: "Appearance"
        case .privacy: "Privacy"
        case .sourceSettings: "Sources & permissions"
        case .localDataControls: "Local data"
        case .exportImport: "Export / Import"
        case .help: "Help"
        case .about: "About"
        }
    }

    var deepLinkPath: String {
        switch self {
        case .monthlyReview:
            "monthly-review"
        case .receiptsHistory:
            "receipts-history"
        case .scheduleAvailability:
            "schedule-availability"
        case .planningDefaults:
            "planning-defaults"
        case .vacationAwayTime:
            "vacation-away-time"
        case .localContextControls:
            "local-context-controls"
        case .capturePreferences:
            "capture"
        case .sessionDefaults:
            "session-defaults"
        case .sourceSettings:
            "sources-permissions"
        case .localDataControls:
            "local-data"
        case .exportImport:
            "export-import"
        case .privacyAutomation:
            "privacy-automation"
        default:
            rawValue
        }
    }
}

enum StageSurfaceReselectionAction: Equatable, Sendable {
    case scrollToTop
    case returnToRoot
}
