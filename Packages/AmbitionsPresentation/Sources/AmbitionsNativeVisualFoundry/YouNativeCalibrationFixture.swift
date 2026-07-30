public enum YouNativeCalibrationDomainID: String, CaseIterable, Identifiable, Sendable {
    case identityAndLocalData = "identity-and-local-data"
    case personalization
    case privacyAndData = "privacy-and-data"
    case appearance
    case notificationsAndAttention = "notifications-and-attention"
    case connectionsAndPermissions = "connections-and-permissions"
    case accessibilityAndInteraction = "accessibility-and-interaction"
    case appBehavior = "app-behavior"
    case aboutAmbitions = "about-ambitions"

    public var id: String { rawValue }
}

public struct YouNativeCalibrationDomain: Identifiable, Equatable, Sendable {
    public let id: YouNativeCalibrationDomainID
    public let title: String
    public let summary: String
    public let symbolName: String
}

public enum YouNativeCalibrationPersonalizationTruth: String, CaseIterable, Sendable {
    case personEntered = "person-entered"
    case confirmed
    case suggested
    case inferred
    case uncertain
    case historical
    case superseded
    case removed
}

public enum YouNativeCalibrationPermissionFamily: String, CaseIterable, Sendable {
    case calendar
    case reminders
    case notifications
    case contextualLocalAuthentication = "contextual-local-authentication"
}

public enum YouNativeCalibrationAppearanceMode: String, CaseIterable, Identifiable, Sendable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }
}

public struct YouNativeCalibrationAccent: Equatable, Sendable {
    public let id: String
    public let name: String
    public let posture: String
    public let matchesProductionEnum: Bool
}

public struct YouNativeCalibrationAppearanceFixture: Equatable, Sendable {
    public let current: YouNativeCalibrationAppearanceMode
    public let availableModes: [YouNativeCalibrationAppearanceMode]
    public let provisionalAccent: YouNativeCalibrationAccent
}

public struct YouNativeCalibrationFixture: Equatable, Sendable {
    public static let fixtureID = "you-flagship/local-personal-control/v1"

    public let title: String
    public let domains: [YouNativeCalibrationDomain]
    public let personalizationTruthStates: [YouNativeCalibrationPersonalizationTruth]
    public let permissionFamilies: [YouNativeCalibrationPermissionFamily]
    public let appearance: YouNativeCalibrationAppearanceFixture
    public let hasAmbitionsAccount: Bool
    public let supportsCloudContinuity: Bool
    public let supportsSubscriptions: Bool
    public let supportsBroadDataCommands: Bool

    public func domain(_ id: YouNativeCalibrationDomainID) -> YouNativeCalibrationDomain? {
        domains.first { $0.id == id }
    }
}

public extension YouNativeCalibrationFixture {
    static let flagship = YouNativeCalibrationFixture(
        title: "You",
        domains: [
            YouNativeCalibrationDomain(
                id: .identityAndLocalData,
                title: "Identity & Local Data",
                summary: "On this iPhone · No account",
                symbolName: "iphone"
            ),
            YouNativeCalibrationDomain(
                id: .personalization,
                title: "Personalization",
                summary: "Today · Review every 7 days",
                symbolName: "slider.horizontal.3"
            ),
            YouNativeCalibrationDomain(
                id: .privacyAndData,
                title: "Privacy & Data",
                summary: "Stored locally",
                symbolName: "hand.raised"
            ),
            YouNativeCalibrationDomain(
                id: .appearance,
                title: "Appearance",
                summary: "System",
                symbolName: "circle.lefthalf.filled"
            ),
            YouNativeCalibrationDomain(
                id: .notificationsAndAttention,
                title: "Notifications & Attention",
                summary: "Allowed",
                symbolName: "bell"
            ),
            YouNativeCalibrationDomain(
                id: .connectionsAndPermissions,
                title: "Connections & Permissions",
                summary: "Calendar and Reminders · Allowed",
                symbolName: "link"
            ),
            YouNativeCalibrationDomain(
                id: .accessibilityAndInteraction,
                title: "Accessibility & Interaction",
                summary: "Follows system settings",
                symbolName: "accessibility"
            ),
            YouNativeCalibrationDomain(
                id: .appBehavior,
                title: "App Behavior",
                summary: "Local defaults active",
                symbolName: "gearshape"
            ),
            YouNativeCalibrationDomain(
                id: .aboutAmbitions,
                title: "About Ambitions",
                summary: "Version and build",
                symbolName: "info.circle"
            )
        ],
        personalizationTruthStates: YouNativeCalibrationPersonalizationTruth.allCases,
        permissionFamilies: YouNativeCalibrationPermissionFamily.allCases,
        appearance: YouNativeCalibrationAppearanceFixture(
            current: .system,
            availableModes: YouNativeCalibrationAppearanceMode.allCases,
            provisionalAccent: YouNativeCalibrationAccent(
                id: "accent.target.violet-indigo",
                name: "Violet–indigo",
                posture: "Visual-authority target · Production enum unresolved",
                matchesProductionEnum: false
            )
        ),
        hasAmbitionsAccount: false,
        supportsCloudContinuity: false,
        supportsSubscriptions: false,
        supportsBroadDataCommands: false
    )
}
