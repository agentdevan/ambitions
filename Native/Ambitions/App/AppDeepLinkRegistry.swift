import Foundation

struct AppDeepLinkRegistryEntry: Equatable, Identifiable, Sendable {
    enum ObjectKind: String, Sendable {
        case rootTab
        case todayContext
        case goal
        case timeRoute
        case youRoute
        case overlay
    }

    enum Owner: Equatable, Sendable {
        case tab(AmbitionsSurface)
        case globalComposer

        var isCanonical: Bool {
            switch self {
            case let .tab(tab):
                tab.isCanonicalTopLevel
            case .globalComposer:
                true
            }
        }
    }

    let id: String
    let objectKind: ObjectKind
    let owner: Owner
    let canonicalRoute: AppExternalRoute
    let deepLinkTemplate: String
    let allowedSources: [AppExternalRouteSource]
    let privacyBoundary: String

    var opensWithoutDeadEnd: Bool {
        switch canonicalRoute {
        case let .openTab(tab):
            tab.isCanonicalTopLevel
        case .openCaptureComposer:
            owner == .globalComposer
        case let .openToday(context):
            context == .standard || owner == .tab(.today)
        case let .openGoalDetail(goalID):
            owner == .tab(.goals) && goalID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        case .openTimeRoute:
            owner == .tab(.time)
        case .openYouRoute:
            owner == .tab(.you)
        case .presentOverlay:
            owner.isCanonical
        case .genericExternalEntry:
            false
        }
    }
}

enum AppDeepLinkRegistry {
    static let externalObjectSources: [AppExternalRouteSource] = [
        .deepLink,
        .notificationAction,
        .widgetAction,
        .liveActivity,
        .appIntent,
        .spotlight,
        .handoff,
        .relaunch
    ]

    static let entries: [AppDeepLinkRegistryEntry] = [
        AppDeepLinkRegistryEntry(
            id: "today.root",
            objectKind: .rootTab,
            owner: .tab(.today),
            canonicalRoute: .openTab(.today),
            deepLinkTemplate: "ambitions://tab/today",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; carries no private object identifier."
        ),
        AppDeepLinkRegistryEntry(
            id: "today.focus",
            objectKind: .todayContext,
            owner: .tab(.today),
            canonicalRoute: .openToday(.focus),
            deepLinkTemplate: "ambitions://tab/today?context=focus",
            allowedSources: externalObjectSources,
            privacyBoundary: "Context route only; opens Start here posture without mutating a step."
        ),
        AppDeepLinkRegistryEntry(
            id: "today.recovery",
            objectKind: .todayContext,
            owner: .tab(.today),
            canonicalRoute: .openToday(.recovery),
            deepLinkTemplate: "ambitions://tab/today?context=recovery",
            allowedSources: [.deepLink, .notificationAction, .widgetAction, .liveActivity, .appIntent, .relaunch],
            privacyBoundary: "Recovery route only; closure still requires in-app confirmation."
        ),
        AppDeepLinkRegistryEntry(
            id: "goals.root",
            objectKind: .rootTab,
            owner: .tab(.goals),
            canonicalRoute: .openTab(.goals),
            deepLinkTemplate: "ambitions://tab/goals",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; carries no private goal identifier."
        ),
        AppDeepLinkRegistryEntry(
            id: "goals.detail",
            objectKind: .goal,
            owner: .tab(.goals),
            canonicalRoute: .openGoalDetail(goalID: "preview-goal"),
            deepLinkTemplate: "ambitions://goal/{goalID}",
            allowedSources: externalObjectSources,
            privacyBoundary: "Requires an explicit goal identifier; unknown or missing IDs fall back instead of inventing a route."
        ),
        AppDeepLinkRegistryEntry(
            id: "time.root",
            objectKind: .rootTab,
            owner: .tab(.time),
            canonicalRoute: .openTab(.time),
            deepLinkTemplate: "ambitions://tab/time",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; opens LifeShape Field without schedule export."
        ),
        AppDeepLinkRegistryEntry(
            id: "time.rituals",
            objectKind: .timeRoute,
            owner: .tab(.time),
            canonicalRoute: .openTimeRoute(.rituals),
            deepLinkTemplate: "ambitions://time/rituals",
            allowedSources: externalObjectSources,
            privacyBoundary: "Time route only; no rhythm metric or score payload is supported."
        ),
        AppDeepLinkRegistryEntry(
            id: "time.weeklyReview",
            objectKind: .timeRoute,
            owner: .tab(.time),
            canonicalRoute: .openTimeRoute(.weeklyReview),
            deepLinkTemplate: "ambitions://time/weekly-review",
            allowedSources: externalObjectSources,
            privacyBoundary: "Review route under Time; does not claim completion or mutate history."
        ),
        AppDeepLinkRegistryEntry(
            id: "you.root",
            objectKind: .rootTab,
            owner: .tab(.you),
            canonicalRoute: .openTab(.you),
            deepLinkTemplate: "ambitions://tab/you",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; opens user-owned controls without exposing profile data."
        ),
        AppDeepLinkRegistryEntry(
            id: "you.history",
            objectKind: .youRoute,
            owner: .tab(.you),
            canonicalRoute: .openYouRoute(.history),
            deepLinkTemplate: "ambitions://you/history",
            allowedSources: externalObjectSources,
            privacyBoundary: "History support route remains in-app and local; no export is implied."
        ),
        AppDeepLinkRegistryEntry(
            id: "you.monthlyReview",
            objectKind: .youRoute,
            owner: .tab(.you),
            canonicalRoute: .openYouRoute(.monthlyReview),
            deepLinkTemplate: "ambitions://you/monthly-review",
            allowedSources: externalObjectSources,
            privacyBoundary: "Review support route remains in-app and local; no readiness claim is implied."
        ),
        AppDeepLinkRegistryEntry(
            id: "capture.composer",
            objectKind: .overlay,
            owner: .globalComposer,
            canonicalRoute: .openCaptureComposer,
            deepLinkTemplate: "ambitions://overlay/quiet-command-sheet?intent=quick_capture",
            allowedSources: externalObjectSources,
            privacyBoundary: "Opens the composer seam only after invocation; Capture is not a top-level tab."
        )
    ]

    static func validationIssues(translator: AppExternalRouteTranslator = AppExternalRouteTranslator()) -> [String] {
        var issues: [String] = []
        let ids = entries.map(\.id)
        if Set(ids).count != ids.count {
            issues.append("Deep-link registry entries must have unique IDs.")
        }
        for entry in entries {
            if entry.owner.isCanonical == false {
                issues.append("\(entry.id) must resolve to a canonical top-level owner.")
            }
            if entry.opensWithoutDeadEnd == false {
                issues.append("\(entry.id) does not resolve to an addressable in-app destination.")
            }
            if entry.allowedSources.isEmpty {
                issues.append("\(entry.id) must declare at least one supported external source.")
            }
            if entry.privacyBoundary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("\(entry.id) must declare a no-claim privacy boundary.")
            }
            if translator.deepLinkURL(for: entry.canonicalRoute) == nil {
                issues.append("\(entry.id) must generate a canonical deep link.")
            }
        }
        return issues
    }
}
