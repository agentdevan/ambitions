import AmbitionsDesignSystem
import SwiftUI

enum YouRootDetail: String, Identifiable {
    case personalization
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
        case .sessionDefaults: "Session Defaults"
        case .appearance: "Appearance"
        case .whatAmbitionsKnows: "What Ambitions Knows"
        case .trustCenter: "Trust Center"
        case .receiptsHistory: "Receipts & History"
        case .corrections: "Corrections"
        case .reviews: "Reviews"
        case .proof: "Proof"
        case .archive: "Archive / Completed"
        case .scheduleAvailability: "Schedule & Availability"
        case .planBehavior: "Time Behavior"
        case .automationTrust: "Trust & Automation"
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

struct PersonalSystemCenterRootView: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var selectedRowHapticToken = ""

    private struct RootSectionRow {
        let id: String
        let sourceItemID: String
        let title: String
        let detail: YouRootDetail
    }

    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Text(profileProjection.hero.title)
                .font(theme.typography.section)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityIdentifier("you.root-title")

            Text(profileProjection.hero.dominantTruth)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            PersonalSystemCenterNavigation(sections: groupedNavigationSections) { item in
                selectedRowHapticToken = item.id
                onOpenDetail(detail(for: item.id))
            }

            Text(profileProjection.systemCenter.footer)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier("you.root")
        .accessibilityValue(profileProjection.userSystemProfileInspectionSummary)
        .ambitionHaptic(theme.haptics.routeChange, trigger: selectedRowHapticToken)
    }

    private var groupedNavigationSections: [GroupedNavigationSystemSection] {
        [
            groupedSection(
                id: "planning-setup",
                title: "Planning Setup",
                subtitle: "Time, availability, and planning defaults stay user-owned.",
                rows: [
                    RootSectionRow(id: "schedule-availability", sourceItemID: "schedule-availability", title: "Schedule & Availability", detail: .scheduleAvailability),
                    RootSectionRow(id: "planning-defaults", sourceItemID: "plan-behavior", title: "Planning Defaults", detail: .planBehavior),
                    RootSectionRow(id: "vacation-away-time", sourceItemID: "vacation-away-time", title: "Vacation / Away Time", detail: .vacationAwayTime),
                    RootSectionRow(id: "trust-automation", sourceItemID: "automation-trust", title: "Trust & Automation", detail: .automationTrust),
                    RootSectionRow(id: "local-context-controls", sourceItemID: "what-ambitions-knows", title: "Local Context Controls", detail: .whatAmbitionsKnows)
                ]
            ),
            groupedSection(
                id: "account-preferences",
                title: "Account & Preferences",
                subtitle: "Execution controls stay explicit and local.",
                rows: [
                    RootSectionRow(id: "notifications", sourceItemID: "notifications", title: "Notifications", detail: .notifications),
                    RootSectionRow(id: "capture-preferences", sourceItemID: "integrations", title: "Capture Preferences", detail: .capturePreferences),
                    RootSectionRow(id: "session-defaults", sourceItemID: "personalization", title: "Session Defaults", detail: .sessionDefaults),
                    RootSectionRow(id: "appearance", sourceItemID: "appearance", title: "Appearance", detail: .appearance),
                    RootSectionRow(id: "privacy", sourceItemID: "trust-center", title: "Privacy", detail: .trustCenter)
                ]
            ),
            groupedSection(
                id: "history-trust",
                title: "History & Trust",
                subtitle: "Receipts and controls remain connected to local evidence.",
                rows: [
                    RootSectionRow(id: "receipts-history", sourceItemID: "receipts-history", title: "Receipts & History", detail: .receiptsHistory),
                    RootSectionRow(id: "proof", sourceItemID: "proof", title: "Proof", detail: .proof),
                    RootSectionRow(id: "source-settings", sourceItemID: "corrections", title: "Source Settings", detail: .sourceSettings),
                    RootSectionRow(id: "local-data-controls", sourceItemID: "export-import", title: "Local Data Controls", detail: .localDataControls)
                ]
            ),
            groupedSection(
                id: "support-system",
                title: "Support / System",
                subtitle: "Assistance and app-system context in a single settings band.",
                rows: [
                    RootSectionRow(id: "help", sourceItemID: "help-support", title: "Help", detail: .support),
                    RootSectionRow(id: "about", sourceItemID: "about", title: "About Ambitions", detail: .about)
                ]
            )
        ]
    }

    private func groupedSection(
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

    private func makeNavigationItem(for row: RootSectionRow) -> GroupedNavigationSystemItem? {
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

    private func sourceSystemCenterItem(id: String) -> YouSystemCenterItem? {
        profileProjection.systemCenter.sections
            .flatMap(\.items)
            .first { $0.id == id }
    }

    private func livingState(for semanticState: AmbitionSemanticState) -> LivingVisualState {
        switch semanticState {
        case .success, .trust, .protected, .accessibilityVerified: .proof
        case .caution, .review, .waiting, .confidenceLow, .accessibilityUnverified: .stale
        case .risk: .pressured
        case .recovery: .recovery
        case .capture, .focus, .calendarDerived, .confidenceHigh, .confidenceMedium: .active
        case .neutral: .calm
        }
    }

    private func detail(for itemID: String) -> YouRootDetail {
        switch itemID {
        case "schedule-availability": .scheduleAvailability
        case "planning-defaults": .planBehavior
        case "vacation-away-time": .vacationAwayTime
        case "trust-automation": .automationTrust
        case "local-context-controls": .whatAmbitionsKnows

        case "notifications": .notifications
        case "capture-preferences": .capturePreferences
        case "session-defaults": .sessionDefaults
        case "appearance": .appearance
        case "privacy": .trustCenter

        case "receipts-history": .receiptsHistory
        case "proof": .proof
        case "source-settings": .sourceSettings
        case "local-data-controls": .localDataControls

        case "help": .support
        case "about": .about
        default: .scheduleAvailability
        }
    }
}
