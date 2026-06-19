import AmbitionsDesignSystem
import SwiftUI

enum YouRootDetail: String, Identifiable {
    case personalization
    case personalRuntime
    case appearance
    case whatAmbitionsKnows
    case trustCenter
    case receiptsHistory
    case corrections
    case reviews
    case proof
    case archive
    case scheduleAvailability
    case planBehavior
    case automationTrust
    case vacationAwayTime
    case durations
    case notifications
    case integrations
    case widgets
    case exportImport
    case support
    case about
    case sessionDefaults
    case capturePreferences
    case sourceSettings
    case localDataControls
    case accessibility

    var id: String { rawValue }

    var title: String {
        switch self {
        case .personalization: "Personalization"
        case .personalRuntime: "Personal system"
        case .sessionDefaults: "Session Defaults"
        case .appearance: "Appearance"
        case .whatAmbitionsKnows: "What Ambitions Knows"
        case .trustCenter: "Trust Center"
        case .receiptsHistory: "Receipts & History"
        case .corrections: "Corrections"
        case .reviews: "Reviews"
        case .proof: "History"
        case .archive: "Archive / Completed"
        case .scheduleAvailability: "Schedule & Availability"
        case .planBehavior: "Time Behavior"
        case .automationTrust: "Privacy & automation"
        case .vacationAwayTime: "Vacation / Away Time"
        case .durations: "Durations"
        case .notifications: "Notifications"
        case .integrations: "Integrations"
        case .widgets: "Widgets / Live Activities / Shortcuts"
        case .exportImport: "Export / Import"
        case .support: "Help / Support"
        case .about: "About"
        case .capturePreferences: "Capture Preferences"
        case .sourceSettings: "Source Settings"
        case .localDataControls: "Local Data Controls"
        case .accessibility: "Accessibility"
        }
    }
}

struct YouObjectStageControlPrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let stageName: String
    let screenshotIdentifier: String
    let sourceControlOrder: [String]
    let replacesFirstViewportStructures: [String]
    let exemptedSemanticControls: [String]
    let accessibilityFallbacks: [String]
    let reservesTabBarClearance: Bool
    let avoidsGenericProfileSettingsWall: Bool

    static let current = YouObjectStageControlPrimitiveContract(
        primitiveID: "personal-runtime-group",
        ownerSurface: "You",
        productObject: "User System Profile",
        stageName: "User System Profile",
        screenshotIdentifier: "YouObjectStageControl",
        sourceControlOrder: [
            "account and profile",
            "privacy and automation",
            "appearance",
            "notifications",
            "learning",
            "receipts and history",
            "export",
            "support"
        ],
        replacesFirstViewportStructures: [
            "detached profile hero",
            "generic settings wall",
            "operator-style root overview",
            "rounded per-row card stack",
            "social profile",
            "admin panel",
            "AI settings wall",
            "verbose documentation UI",
            "internal runtime console"
        ],
        exemptedSemanticControls: [
            "native grouped navigation rows",
            "semantic detail control groups",
            "permission and receipt drill-down controls"
        ],
        accessibilityFallbacks: [
            "VoiceOver reads object, group purpose, control title, status, and available route in grouped order.",
            "Dynamic Type shifts rows into stacked symbol, title, status, and detail content without restoring card containers.",
            "Reduce Motion relies on native disclosure and haptic route change state rather than motion-only meaning.",
            "Increase Contrast and Differentiate Without Color use line, symbol, and status text in addition to accent color."
        ],
        reservesTabBarClearance: true,
        avoidsGenericProfileSettingsWall: true
    )
}

struct PersonalSystemCenterRootView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedRowHapticToken = ""
    let primitiveContract = YouObjectStageControlPrimitiveContract.current

    struct RootSectionRow {
        let id: String
        let sourceItemID: String
        let title: String
        let detail: YouRootDetail
    }

    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            objectStageHeader

            YouPersonalRuntimeGovernanceField(items: priorityGovernanceItems) { item in
                selectedRowHapticToken = item.id
                onOpenDetail(detail(for: item.id))
            }

            YouPersonalSystemNavigation(sections: groupedNavigationSections) { item in
                selectedRowHapticToken = item.id
                onOpenDetail(detail(for: item.id))
            }

            Text(profileProjection.systemCenter.footer)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("you.root")
        .accessibilityValue("\(profileProjection.userSystemProfileInspectionSummary). \(primitiveContract.stageName).")
        .ambitionHaptic(theme.haptics.routeChange, trigger: selectedRowHapticToken)
    }

    var objectStageHeader: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(AmbitionsIOS26SemanticTokens.Fill.tertiaryDark)
                    .frame(width: dynamicTypeSize.isAccessibilitySize ? 54 : 48, height: dynamicTypeSize.isAccessibilitySize ? 54 : 48)
                Image(systemName: "person.crop.circle.fill")
                    .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.title : theme.typography.titleCompact)
                    .foregroundStyle(LivingTabContext.you.accent(in: theme))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(profileProjection.hero.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "You" : profileProjection.hero.title)
                    .font(dynamicTypeSize.isAccessibilitySize ? AmbitionsIOS26SemanticTokens.Typography.title3 : AmbitionsIOS26SemanticTokens.Typography.title2)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .accessibilityIdentifier("you.root-title")

                Text("Account, privacy, learning, and controls stay local")
                    .font(AmbitionsIOS26SemanticTokens.Typography.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)

                Text("User System Profile")
                    .font(AmbitionsIOS26SemanticTokens.Typography.caption1.weight(.semibold))
                    .foregroundStyle(LivingTabContext.you.accent(in: theme))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("you.object-stage-header")
        .accessibilityLabel("User System Profile")
        .accessibilityValue("Account, privacy, appearance, notifications, learning, receipts, export, and support controls are organized locally.")
    }

    var priorityGovernanceRows: [RootSectionRow] {
        [
            RootSectionRow(id: "trust-automation", sourceItemID: "automation-trust", title: "Privacy & automation", detail: .automationTrust),
            RootSectionRow(id: "personal-runtime", sourceItemID: "what-ambitions-knows", title: "Personal system", detail: .personalRuntime),
            RootSectionRow(id: "receipts-history", sourceItemID: "receipts-history", title: "Receipts & History", detail: .receiptsHistory)
        ]
    }

    var priorityGovernanceItems: [GroupedNavigationSystemItem] {
        priorityGovernanceRows.compactMap { makeNavigationItem(for: $0) }
    }

    var groupedNavigationSections: [GroupedNavigationSystemSection] {
        [
            groupedSection(
                id: "planning-setup",
                title: "Account & profile",
                subtitle: "Profile, availability, and planning defaults stay user-owned.",
                rows: [
                    RootSectionRow(id: "schedule-availability", sourceItemID: "schedule-availability", title: "Schedule & Availability", detail: .scheduleAvailability),
                    RootSectionRow(id: "planning-defaults", sourceItemID: "plan-behavior", title: "Planning Defaults", detail: .planBehavior),
                    RootSectionRow(id: "vacation-away-time", sourceItemID: "vacation-away-time", title: "Vacation / Away Time", detail: .vacationAwayTime),
                    RootSectionRow(id: "trust-automation", sourceItemID: "automation-trust", title: "Privacy & automation", detail: .automationTrust),
                    RootSectionRow(id: "personal-runtime", sourceItemID: "what-ambitions-knows", title: "Personal system", detail: .personalRuntime),
                    RootSectionRow(id: "local-context-controls", sourceItemID: "what-ambitions-knows", title: "Local Context Controls", detail: .whatAmbitionsKnows)
                ]
            ),
            groupedSection(
                id: "runtime-preferences",
                title: "Appearance & notifications",
                subtitle: "Capture, notifications, sessions, appearance, and privacy.",
                rows: [
                    RootSectionRow(id: "notifications", sourceItemID: "notifications", title: "Notifications", detail: .notifications),
                    RootSectionRow(id: "capture-preferences", sourceItemID: "integrations", title: "Capture", detail: .capturePreferences),
                    RootSectionRow(id: "session-defaults", sourceItemID: "personalization", title: "Session Defaults", detail: .sessionDefaults),
                    RootSectionRow(id: "appearance", sourceItemID: "appearance", title: "Appearance", detail: .appearance),
                    RootSectionRow(id: "privacy", sourceItemID: "trust-center", title: "Privacy", detail: .trustCenter)
                ]
            ),
            groupedSection(
                id: "history-trust",
                title: "Privacy, learning & receipts",
                subtitle: "Learning controls, receipts, history, and local data stay inspectable.",
                rows: [
                    RootSectionRow(id: "receipts-history", sourceItemID: "receipts-history", title: "Receipts & History", detail: .receiptsHistory),
                    RootSectionRow(id: "history", sourceItemID: "history", title: "History", detail: .proof),
                    RootSectionRow(id: "source-settings", sourceItemID: "corrections", title: "Sources & permissions", detail: .sourceSettings),
                    RootSectionRow(id: "local-data-controls", sourceItemID: "export-import", title: "Local data", detail: .localDataControls)
                ]
            ),
            groupedSection(
                id: "support-system",
                title: "Export & support",
                subtitle: "Export, support, and app-system context in one native settings group.",
                rows: [
                    RootSectionRow(id: "export-import", sourceItemID: "export-import", title: "Export / Import", detail: .exportImport),
                    RootSectionRow(id: "help", sourceItemID: "help-support", title: "Help", detail: .support),
                    RootSectionRow(id: "about", sourceItemID: "about", title: "About", detail: .about)
                ]
            )
        ]
    }

    func groupedSection(
        id: String,
        title: String,
        subtitle: String,
        rows: [RootSectionRow]
    ) -> GroupedNavigationSystemSection {
        GroupedNavigationSystemSection(
            id: id,
            title: title,
            subtitle: subtitle,
            items: rows.compactMap { makeNavigationItem(for: $0) }
        )
    }

    func makeNavigationItem(for row: RootSectionRow) -> GroupedNavigationSystemItem? {
        guard let item = sourceSystemCenterItem(id: row.sourceItemID) else { return nil }

        return GroupedNavigationSystemItem(
            id: row.id,
            title: row.title,
            subtitle: item.subtitle,
            symbolName: item.icon,
            state: livingState(for: item.semanticState),
            statusLabel: item.statusLabel
        )
    }

    func sourceSystemCenterItem(id: String) -> YouSystemCenterItem? {
        profileProjection.systemCenter.sections
            .flatMap(\.items)
            .first { $0.id == id }
    }

    func livingState(for semanticState: AmbitionSemanticState) -> LivingVisualState {
        switch semanticState {
        case .success, .trust, .protected, .accessibilityVerified: .proof
        case .caution, .review, .waiting, .confidenceLow, .accessibilityUnverified: .stale
        case .risk: .pressured
        case .recovery: .recovery
        case .capture, .focus, .calendarDerived, .confidenceHigh, .confidenceMedium: .active
        case .neutral: .calm
        }
    }

    func detail(for itemID: String) -> YouRootDetail {
        switch itemID {
        case "schedule-availability": .scheduleAvailability
        case "planning-defaults": .planBehavior
        case "vacation-away-time": .vacationAwayTime
        case "trust-automation": .automationTrust
        case "personal-runtime": .personalRuntime
        case "local-context-controls": .whatAmbitionsKnows

        case "notifications": .notifications
        case "capture-preferences": .capturePreferences
        case "session-defaults": .sessionDefaults
        case "appearance": .appearance
        case "privacy": .trustCenter

        case "receipts-history": .receiptsHistory
        case "history": .proof
        case "source-settings": .sourceSettings
        case "local-data-controls": .localDataControls

        case "export-import": .exportImport
        case "help": .support
        case "about": .about
        default: .scheduleAvailability
        }
    }
}
