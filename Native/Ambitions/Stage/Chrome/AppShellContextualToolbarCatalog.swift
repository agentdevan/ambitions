import Foundation

struct AppShellContextualToolbarAction: Hashable, Identifiable, Sendable {
    enum Kind: String, Hashable, Sendable {
        case surfacePrimary
        case captureFallback
        case inspection
    }

    enum Route: Hashable, Sendable, CustomStringConvertible {
        case selectToday
        case createGoal
        case weeklyReview
        case memoryLens
        case capture(AmbitionsSurface)

        var description: String {
            switch self {
            case .selectToday: "selectToday"
            case .createGoal: "createGoal"
            case .weeklyReview: "weeklyReview"
            case .memoryLens: "memoryLens"
            case let .capture(surface): "capture(\(surface.canonicalTopLevelTab.rawValue))"
            }
        }
    }

    let id: String
    let kind: Kind
    let route: Route
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let requiresConfirmationBeforeDestructiveEffect: Bool

    init(
        id: String,
        kind: Kind,
        route: Route,
        title: String,
        systemImage: String,
        accessibilityIdentifier: String,
        accessibilityLabel: String? = nil,
        accessibilityHint: String,
        requiresConfirmationBeforeDestructiveEffect: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.route = route
        self.title = title
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint
        self.requiresConfirmationBeforeDestructiveEffect = requiresConfirmationBeforeDestructiveEffect
    }
}

enum AppShellContextualToolbarCatalog {
    static let maxOneViewportActions = 2

    static func actions(for tab: AmbitionsSurface) -> [AppShellContextualToolbarAction] {
        let canonicalTab = tab.canonicalTopLevelTab
        return [primaryAction(for: canonicalTab), captureAction(for: canonicalTab)]
    }

    static func shouldCompressActions(dynamicTypeIsAccessibilitySize: Bool, actionCount: Int) -> Bool {
        dynamicTypeIsAccessibilitySize && actionCount > 1
    }

    static var canonicalSurfaceCoverage: [String] {
        AmbitionsSurface.allCases.map(\.title)
    }

    private static func primaryAction(for tab: AmbitionsSurface) -> AppShellContextualToolbarAction {
        switch tab.canonicalTopLevelTab {
        case .today:
            return AppShellContextualToolbarAction(
                id: "today-start-here",
                kind: .surfacePrimary,
                route: .selectToday,
                title: "Start here",
                systemImage: "bolt.fill",
                accessibilityIdentifier: "shell.today.start-here-button",
                accessibilityHint: "Returns Today to the Start here execution object."
            )
        case .goals:
            return AppShellContextualToolbarAction(
                id: "goals-create-goal",
                kind: .surfacePrimary,
                route: .createGoal,
                title: "Create goal",
                systemImage: "plus",
                accessibilityIdentifier: "shell.goals.create-goal-button",
                accessibilityHint: "Opens goal creation from Goals."
            )
        case .time:
            return AppShellContextualToolbarAction(
                id: "time-weekly-review",
                kind: .surfacePrimary,
                route: .weeklyReview,
                title: "Review week",
                systemImage: "calendar.badge.clock",
                accessibilityIdentifier: "shell.time.weekly-review-button",
                accessibilityHint: "Opens the Time-owned weekly review surface."
            )
        case .you:
            return AppShellContextualToolbarAction(
                id: "you-history",
                kind: .inspection,
                route: .memoryLens,
                title: "History",
                systemImage: "clock.arrow.circlepath",
                accessibilityIdentifier: "shell.you.history-button",
                accessibilityHint: "Opens the You-owned history surface."
            )
        }
    }

    private static func captureAction(for tab: AmbitionsSurface) -> AppShellContextualToolbarAction {
        AppShellContextualToolbarAction(
            id: "\(tab.canonicalTopLevelTab.rawValue)-capture",
            kind: .captureFallback,
            route: .capture(tab.canonicalTopLevelTab),
            title: AppShellCaptureAccessModel.toolbarTitle,
            systemImage: "square.and.pencil",
            accessibilityIdentifier: AppShellCaptureAccessModel.toolbarAccessibilityIdentifier(for: tab),
            accessibilityLabel: AppShellCaptureAccessModel.toolbarAccessibilityLabel,
            accessibilityHint: AppShellCaptureAccessModel.toolbarAccessibilityHint
        )
    }
}

enum AppShellCaptureAccessModel {
    static let toolbarTitle = CaptureAccessPoint.toolbar.title
    static let systemImage = CaptureAccessPoint.toolbar.systemImage
    static let toolbarAccessibilityLabel = CaptureAccessPoint.toolbar.accessibilityLabel
    static let toolbarAccessibilityHint = CaptureAccessPoint.toolbar.accessibilityHint
    static let activatedSeamAccessibilityLabel = CaptureAccessPoint.activeComposer.accessibilityLabel
    static let activatedSeamAccessibilityHint = CaptureAccessPoint.activeComposer.accessibilityHint

    static func source(for tab: AmbitionsSurface) -> ShellCommandEntrySource {
        switch tab.canonicalTopLevelTab {
        case .today:
            .todayQuickCapture
        case .goals:
            .goalsQuickCapture
        case .time:
            .timeQuickCapture
        case .you:
            .youQuickCapture
        }
    }

    static func toolbarAccessibilityIdentifier(for tab: AmbitionsSurface) -> String {
        CaptureAccessPoint.toolbar.accessibilityIdentifier(for: tab)
    }
}
