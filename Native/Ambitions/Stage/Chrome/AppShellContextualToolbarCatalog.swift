import Foundation

struct AppShellContextualToolbarAction: Hashable, Identifiable, Sendable {
    enum Kind: String, Hashable, Sendable {
        case surfacePrimary
        case captureFallback
        case inspection
    }

    let id: String
    let kind: Kind
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let requiresConfirmationBeforeDestructiveEffect: Bool

    init(
        id: String,
        kind: Kind,
        title: String,
        systemImage: String,
        accessibilityIdentifier: String,
        accessibilityLabel: String? = nil,
        accessibilityHint: String,
        requiresConfirmationBeforeDestructiveEffect: Bool = false
    ) {
        self.id = id
        self.kind = kind
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

    static func actions(for tab: AppTab) -> [AppShellContextualToolbarAction] {
        let canonicalTab = tab.canonicalTopLevelTab
        return [primaryAction(for: canonicalTab), captureAction(for: canonicalTab)]
    }

    static func shouldCompressActions(dynamicTypeIsAccessibilitySize: Bool, actionCount: Int) -> Bool {
        dynamicTypeIsAccessibilitySize && actionCount > 1
    }

    static var canonicalSurfaceCoverage: [String] {
        AppTab.allCases.map(\.title)
    }

    private static func primaryAction(for tab: AppTab) -> AppShellContextualToolbarAction {
        switch tab.canonicalTopLevelTab {
        case .today:
            return AppShellContextualToolbarAction(
                id: "today-start-here",
                kind: .surfacePrimary,
                title: "Start here",
                systemImage: "bolt.fill",
                accessibilityIdentifier: "shell.today.start-here-button",
                accessibilityHint: "Returns Today to the Start here execution object."
            )
        case .goals:
            return AppShellContextualToolbarAction(
                id: "goals-create-goal",
                kind: .surfacePrimary,
                title: "Create goal",
                systemImage: "plus",
                accessibilityIdentifier: "shell.goals.create-goal-button",
                accessibilityHint: "Opens goal creation from Goals."
            )
        case .time:
            return AppShellContextualToolbarAction(
                id: "time-weekly-review",
                kind: .surfacePrimary,
                title: "Review week",
                systemImage: "calendar.badge.clock",
                accessibilityIdentifier: "shell.time.weekly-review-button",
                accessibilityHint: "Opens the Time-owned weekly review surface."
            )
        case .you:
            return AppShellContextualToolbarAction(
                id: "you-history",
                kind: .inspection,
                title: "History",
                systemImage: "clock.arrow.circlepath",
                accessibilityIdentifier: "shell.you.history-button",
                accessibilityHint: "Opens the You-owned history surface."
            )
        }
    }

    private static func captureAction(for tab: AppTab) -> AppShellContextualToolbarAction {
        AppShellContextualToolbarAction(
            id: "\(tab.canonicalTopLevelTab.rawValue)-capture",
            kind: .captureFallback,
            title: AppShellCaptureAccessModel.toolbarTitle,
            systemImage: "square.and.pencil",
            accessibilityIdentifier: AppShellCaptureAccessModel.toolbarAccessibilityIdentifier(for: tab),
            accessibilityLabel: AppShellCaptureAccessModel.toolbarAccessibilityLabel,
            accessibilityHint: AppShellCaptureAccessModel.toolbarAccessibilityHint
        )
    }
}

enum AppShellCaptureAccessModel {
    static let toolbarTitle = "Capture"
    static let systemImage = "square.and.pencil"
    static let toolbarAccessibilityLabel = "Capture"
    static let toolbarAccessibilityHint = "Opens the Capture composer for this surface/context."
    static let activatedSeamAccessibilityLabel = "Capture composer"
    static let activatedSeamAccessibilityHint = "Capture is active for this surface/context."

    static func source(for tab: AppTab) -> ShellCommandEntrySource {
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

    static func toolbarAccessibilityIdentifier(for tab: AppTab) -> String {
        "shell.\(tab.canonicalTopLevelTab.rawValue).capture-button"
    }
}
