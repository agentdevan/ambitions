import AmbitionsDesignSystem
import SwiftUI

enum YouRootDetail: String, Identifiable {
    case you
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
    case accessibility
    case support
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .you: "User System Profile"
        case .personalization: "Personalization"
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
        case .accessibility: "Accessibility"
        case .support: "Help / Support"
        case .about: "About"
        }
    }
}

struct PersonalSystemCenterRootView: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var selectedRowHapticToken = ""

    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            PersonalSystemCenterHeader(
                title: profileProjection.hero.title,
                summary: profileProjection.hero.dominantTruth,
                signals: primarySignals
            )

            PersonalSystemCenterSetupCompleteness(
                title: "Setup completeness",
                summary: "Trust, memory, planning, and access stay visible before deeper setup.",
                completedCount: setupCompletedCount,
                totalCount: setupItems.count,
                items: setupItems
            )

            Button {
                selectedRowHapticToken = "user-system-profile"
                onOpenDetail(.you)
            } label: {
                Label("User System Profile", systemImage: "person.crop.circle")
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("you.row.user-system-profile")

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
                subtitle: "Time, availability, away states, and duration defaults stay user-owned.",
                itemIDs: ["schedule-availability", "plan-behavior", "automation-trust", "vacation-away-time", "durations"]
            ),
            groupedSection(
                id: "trust-memory",
                title: "Trust, Memory & Receipts",
                subtitle: "Inspectable memory, receipts, corrections, proof, and review history.",
                itemIDs: ["trust-center", "what-ambitions-knows", "receipts-history", "corrections", "reviews", "proof", "archive-completed"]
            ),
            groupedSection(
                id: "personal-defaults",
                title: "Defaults",
                subtitle: "Identity, preference, and appearance controls stay separate from trust-critical choices.",
                itemIDs: ["you", "personalization", "appearance"]
            ),
            groupedSection(
                id: "privacy-accessibility",
                title: "Privacy, Accessibility & Boundaries",
                subtitle: "Controls that keep the system understandable, bounded, and humane.",
                itemIDs: ["export-import", "accessibility", "notifications", "integrations", "widgets-live-activities-shortcuts"]
            ),
            groupedSection(
                id: "preferences-personalization",
                title: "Preferences / Personalization",
                subtitle: "Support and app truth without a settings dump.",
                itemIDs: ["help-support", "about"]
            )
        ]
    }

    private func groupedSection(
        id: String,
        title: String,
        subtitle: String,
        itemIDs: [String]
    ) -> GroupedNavigationSystemSection {
        let items = itemIDs.compactMap(systemCenterItem)
        return GroupedNavigationSystemSection(
            id: id,
            title: title,
            subtitle: subtitle,
            items: items
        )
    }

    private func systemCenterItem(for id: String) -> GroupedNavigationSystemItem? {
        guard let item = profileProjection.systemCenter.sections
            .flatMap(\.items)
            .first(where: { $0.id == id })
        else { return nil }

        return GroupedNavigationSystemItem(
            id: item.id,
            title: normalizedTitle(for: item),
            subtitle: item.subtitle,
            symbolName: item.icon,
            state: livingState(for: item.semanticState),
            statusLabel: item.statusLabel
        )
    }

    private func normalizedTitle(for item: YouSystemCenterItem) -> String {
        switch item.id {
        case "you": "User System Profile"
        case "personalization": "Planning Defaults"
        case "what-ambitions-knows": "Memory"
        case "receipts-history": "Receipts / History"
        case "export-import": "Privacy"
        case "widgets-live-activities-shortcuts": "External Surfaces"
        default: item.title
        }
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
        case "you": .you
        case "personalization": .personalization
        case "appearance": .appearance
        case "what-ambitions-knows": .whatAmbitionsKnows
        case "trust-center": .trustCenter
        case "receipts-history": .receiptsHistory
        case "corrections": .corrections
        case "reviews": .reviews
        case "proof": .proof
        case "archive-completed": .archive
        case "schedule-availability": .scheduleAvailability
        case "plan-behavior": .planBehavior
        case "automation-trust": .automationTrust
        case "vacation-away-time": .vacationAwayTime
        case "durations": .durations
        case "notifications": .notifications
        case "integrations": .integrations
        case "widgets-live-activities-shortcuts": .widgets
        case "export-import": .exportImport
        case "accessibility": .accessibility
        case "help-support": .support
        case "about": .about
        default: .you
        }
    }

    private var primarySignals: [PersonalSystemCenterSignal] {
        [
            PersonalSystemCenterSignal(
                id: "trust",
                title: "Trust Center",
                detail: "Reviewable",
                source: "No silent changes",
                state: .proof,
                context: .trust
            ),
            PersonalSystemCenterSignal(
                id: "memory",
                title: "Memory",
                detail: "Inspectable",
                source: "Local records",
                state: .calm,
                context: .memory
            ),
            PersonalSystemCenterSignal(
                id: "accessibility",
                title: "Accessibility",
                detail: "Claims locked",
                source: "Human proof pending",
                state: .stale,
                context: .you
            )
        ]
    }

    private var setupItems: [PersonalSystemCenterSetupItem] {
        [
            setupItem(id: "schedule-availability"),
            setupItem(id: "automation-trust"),
            setupItem(id: "what-ambitions-knows"),
            setupItem(id: "trust-center"),
            setupItem(id: "accessibility")
        ].compactMap { $0 }
    }

    private var setupCompletedCount: Int {
        setupItems.filter { $0.state == .proof || $0.state == .active }.count
    }

    private func setupItem(id: String) -> PersonalSystemCenterSetupItem? {
        guard let item = profileProjection.systemCenter.sections
            .flatMap(\.items)
            .first(where: { $0.id == id })
        else { return nil }

        return PersonalSystemCenterSetupItem(
            id: item.id,
            title: normalizedTitle(for: item),
            statusLabel: item.statusLabel,
            state: livingState(for: item.semanticState)
        )
    }
}
