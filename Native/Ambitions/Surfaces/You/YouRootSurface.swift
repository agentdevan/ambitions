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
    case lifeAreas
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
        case .personalRuntime: "Local profile"
        case .sessionDefaults: "Session defaults"
        case .appearance: "Appearance"
        case .whatAmbitionsKnows: "Local context"
        case .trustCenter: "Privacy"
        case .receiptsHistory: "Receipts & History"
        case .corrections: "Corrections"
        case .reviews: "Reviews"
        case .proof: "History"
        case .archive: "Archive / Completed"
        case .scheduleAvailability: "Schedule & Availability"
        case .planBehavior: "Time Behavior"
        case .lifeAreas: "Life Areas"
        case .automationTrust: "Privacy & automation"
        case .vacationAwayTime: "Vacation / Away Time"
        case .durations: "Durations"
        case .notifications: "Notifications"
        case .integrations: "Integrations"
        case .widgets: "Widgets / Live Activities / Shortcuts"
        case .exportImport: "Export / Import"
        case .support: "Help / Support"
        case .about: "About"
        case .capturePreferences: "Capture"
        case .sourceSettings: "Sources"
        case .localDataControls: "Local Data"
        case .accessibility: "Accessibility"
        }
    }

    var routeTarget: YouRouteTarget {
        switch self {
        case .personalization, .sessionDefaults:
            .sessionDefaults
        case .personalRuntime:
            .personalSystem
        case .appearance:
            .appearance
        case .whatAmbitionsKnows:
            .localContextControls
        case .trustCenter:
            .privacy
        case .receiptsHistory:
            .receiptsHistory
        case .corrections, .sourceSettings:
            .sourceSettings
        case .reviews:
            .monthlyReview
        case .proof:
            .history
        case .archive, .exportImport:
            .exportImport
        case .scheduleAvailability:
            .scheduleAvailability
        case .planBehavior, .durations:
            .planningDefaults
        case .lifeAreas:
            .lifeAreas
        case .automationTrust:
            .privacyAutomation
        case .vacationAwayTime:
            .vacationAwayTime
        case .notifications:
            .notifications
        case .integrations, .widgets:
            .sourceSettings
        case .capturePreferences:
            .capturePreferences
        case .localDataControls:
            .localDataControls
        case .support:
            .help
        case .about:
            .about
        case .accessibility:
            .accessibility
        }
    }
}

struct PersonalSystemCenterRootView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedRowHapticToken = ""
    let primitiveContract = YouObjectStageControlPrimitiveContract.current

    struct RootSectionRow {
        let id: String
        let sourceItemID: String?
        let title: String
        let detail: YouRootDetail
        let subtitle: String
        let symbolName: String
        let statusLabel: String?
        let semanticState: AmbitionSemanticState
    }

    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            objectStageHeader

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
        .accessibilityValue("Local-first settings. \(primitiveContract.stageName).")
        .ambitionHaptic(theme.haptics.routeChange, trigger: selectedRowHapticToken)
    }

    var objectStageHeader: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.colors.surfaceOverlay)
                    .frame(width: dynamicTypeSize.isAccessibilitySize ? 54 : 48, height: dynamicTypeSize.isAccessibilitySize ? 54 : 48)
                Image(systemName: "person.crop.circle.fill")
                    .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.title : theme.typography.titleCompact)
                    .foregroundStyle(LivingTabContext.you.accent(in: theme))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Local profile")
                    .font(dynamicTypeSize.isAccessibilitySize ? AmbitionsIOS26SemanticTokens.Typography.title3 : AmbitionsIOS26SemanticTokens.Typography.title2)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .accessibilityIdentifier("you.root-title")

                Text("On this device")
                    .font(AmbitionsIOS26SemanticTokens.Typography.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)

                Text(localStatusSummary)
                    .font(AmbitionsIOS26SemanticTokens.Typography.caption1.weight(.semibold))
                    .foregroundStyle(LivingTabContext.you.accent(in: theme))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, theme.spacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("you.object-stage-header")
        .accessibilityLabel("Local profile")
        .accessibilityValue(localStatusSummary)
    }

    var localStatusSummary: String {
        sourceSystemCenterItem(id: "export-import")?.statusLabel ?? "Local only"
    }

    var groupedNavigationSections: [GroupedNavigationSystemSection] {
        [
            groupedSection(
                id: "preferences",
                title: "Preferences",
                subtitle: nil,
                rows: [
                    RootSectionRow(
                        id: "appearance",
                        sourceItemID: "appearance",
                        title: "Appearance",
                        detail: .appearance,
                        subtitle: "System, Light, Dark, and accent.",
                        symbolName: "paintpalette",
                        statusLabel: sourceSystemCenterItem(id: "appearance")?.statusLabel,
                        semanticState: .success
                    ),
                    RootSectionRow(
                        id: "capture-preferences",
                        sourceItemID: nil,
                        title: "Capture",
                        detail: .capturePreferences,
                        subtitle: "Input, dictation, attachments, and teaching state.",
                        symbolName: "square.and.pencil",
                        statusLabel: "Settings",
                        semanticState: .capture
                    ),
                    RootSectionRow(
                        id: "life-areas",
                        sourceItemID: nil,
                        title: "Life Areas",
                        detail: .lifeAreas,
                        subtitle: "Defaults and customization ownership.",
                        symbolName: "square.grid.2x2",
                        statusLabel: "Goals-owned",
                        semanticState: .neutral
                    )
                ]
            ),
            groupedSection(
                id: "privacy-data",
                title: "Privacy & Data",
                subtitle: nil,
                rows: [
                    RootSectionRow(
                        id: "privacy",
                        sourceItemID: "trust-center",
                        title: "Privacy",
                        detail: .trustCenter,
                        subtitle: "Permissions and local boundaries.",
                        symbolName: "hand.raised",
                        statusLabel: "Review",
                        semanticState: .trust
                    ),
                    RootSectionRow(
                        id: "local-data-controls",
                        sourceItemID: "export-import",
                        title: "Local Data",
                        detail: .localDataControls,
                        subtitle: "Store status, export, and erase boundaries.",
                        symbolName: "externaldrive",
                        statusLabel: sourceSystemCenterItem(id: "export-import")?.statusLabel,
                        semanticState: .caution
                    ),
                    RootSectionRow(
                        id: "source-settings",
                        sourceItemID: "corrections",
                        title: "Sources",
                        detail: .sourceSettings,
                        subtitle: "Permissions, freshness, and source inspection.",
                        symbolName: "doc.text.magnifyingglass",
                        statusLabel: "Inspect",
                        semanticState: .review
                    ),
                    RootSectionRow(
                        id: "receipts-history",
                        sourceItemID: "receipts-history",
                        title: "Receipts",
                        detail: .receiptsHistory,
                        subtitle: "Proof and change ledger access.",
                        symbolName: "checkmark.seal",
                        statusLabel: sourceSystemCenterItem(id: "receipts-history")?.statusLabel,
                        semanticState: .neutral
                    )
                ]
            ),
            groupedSection(
                id: "app",
                title: "App",
                subtitle: nil,
                rows: [
                    RootSectionRow(
                        id: "accessibility",
                        sourceItemID: "accessibility",
                        title: "Accessibility",
                        detail: .accessibility,
                        subtitle: "System settings and app support status.",
                        symbolName: "figure",
                        statusLabel: sourceSystemCenterItem(id: "accessibility")?.statusLabel,
                        semanticState: .accessibilityUnverified
                    ),
                    RootSectionRow(
                        id: "about",
                        sourceItemID: "about",
                        title: "About",
                        detail: .about,
                        subtitle: "Version, privacy, legal, and diagnostics status.",
                        symbolName: "info.circle",
                        statusLabel: "Local",
                        semanticState: .neutral
                    )
                ]
            )
        ]
    }

    func groupedSection(
        id: String,
        title: String,
        subtitle: String?,
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
        let item = row.sourceItemID.flatMap(sourceSystemCenterItem)

        return GroupedNavigationSystemItem(
            id: row.id,
            title: row.title,
            subtitle: row.subtitle,
            symbolName: item?.icon ?? row.symbolName,
            state: livingState(for: item?.semanticState ?? row.semanticState),
            statusLabel: row.statusLabel ?? item?.statusLabel
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
        case "life-areas": .lifeAreas
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
