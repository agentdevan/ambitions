import Foundation

struct ToolbarPreviewFixture: Hashable, Identifiable, Sendable {
    let id: String
    let surface: String
    let primaryObject: String
    let actionTitles: [String]
    let accessibilityIdentifiers: [String]
    let oneViewportActionCount: Int
    let dynamicTypeCompressionBehavior: String
    let noDestructiveActionWithoutConfirmation: Bool
}

enum ToolbarPreviewCatalog {
    static let ownerIssue = "AMB-995"
    static let claimUnlocked = "Fast access to key actions."
    static let claimsScreenshotProof = false
    static let claimsAccessibilityApproval = false

    static let fixtures: [ToolbarPreviewFixture] = AppTab.allCases.map { tab in
        let actions = AppShellContextualToolbarCatalog.actions(for: tab)
        return ToolbarPreviewFixture(
            id: "toolbar-\(tab.rawValue)",
            surface: tab.title,
            primaryObject: primaryObject(for: tab),
            actionTitles: actions.map(\.title),
            accessibilityIdentifiers: actions.map(\.accessibilityIdentifier),
            oneViewportActionCount: actions.count,
            dynamicTypeCompressionBehavior: "Regular sizes show the contextual action cluster inline; accessibility Dynamic Type compresses the same actions into the Actions menu without dropping Capture.",
            noDestructiveActionWithoutConfirmation: actions.allSatisfy { $0.requiresConfirmationBeforeDestructiveEffect == false }
        )
    }

    static var coveredSurfaces: [String] { fixtures.map(\.surface) }

    static var supportsOneViewportActionDensity: Bool {
        fixtures.allSatisfy { $0.oneViewportActionCount <= AppShellContextualToolbarCatalog.maxOneViewportActions }
    }

    static var supportsDynamicTypeCompression: Bool {
        fixtures.allSatisfy { fixture in
            AppShellContextualToolbarCatalog.shouldCompressActions(
                dynamicTypeIsAccessibilitySize: true,
                actionCount: fixture.oneViewportActionCount
            ) && fixture.dynamicTypeCompressionBehavior.contains("Actions menu")
        }
    }

    static var preservesNoDestructiveActionBoundary: Bool {
        fixtures.allSatisfy(\.noDestructiveActionWithoutConfirmation)
    }

    private static func primaryObject(for tab: AppTab) -> String {
        switch tab {
        case .today: "Reality Meridian / Start here"
        case .goals: "Constellation Atlas"
        case .time: "LifeShape Field"
        case .you: "User System Profile"
        }
    }
}
