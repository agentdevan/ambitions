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
    private let primitiveContract = YouObjectStageControlPrimitiveContract.current

    private struct RootSectionRow {
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

    private var objectStageHeader: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(AmbitionsIOS26SemanticTokens.Fill.tertiaryDark)
                    .frame(width: dynamicTypeSize.isAccessibilitySize ? 54 : 48, height: dynamicTypeSize.isAccessibilitySize ? 54 : 48)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: dynamicTypeSize.isAccessibilitySize ? 30 : 27, weight: .semibold))
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

    private var priorityGovernanceRows: [RootSectionRow] {
        [
            RootSectionRow(id: "trust-automation", sourceItemID: "automation-trust", title: "Privacy & automation", detail: .automationTrust),
            RootSectionRow(id: "personal-runtime", sourceItemID: "what-ambitions-knows", title: "Personal system", detail: .personalRuntime),
            RootSectionRow(id: "receipts-history", sourceItemID: "receipts-history", title: "Receipts & History", detail: .receiptsHistory)
        ]
    }

    private var priorityGovernanceItems: [GroupedNavigationSystemItem] {
        priorityGovernanceRows.compactMap { makeNavigationItem(for: $0) }
    }

    private var groupedNavigationSections: [GroupedNavigationSystemSection] {
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

private struct YouPersonalRuntimeGovernanceField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let items: [GroupedNavigationSystemItem]
    let onSelect: (GroupedNavigationSystemItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("How Ambitions works for me")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("Trust, personal context, and receipts stay inspectable before deeper controls.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                ForEach(items) { item in
                    governanceNode(item)
                }
            }
            .padding(.vertical, theme.spacing.sm)
            .background(alignment: .leading) {
                Rectangle()
                    .fill(LivingTabContext.you.accent(in: theme).opacity(0.34))
                    .frame(width: 2)
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.64))
                    .frame(height: 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.48))
                    .frame(height: 1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("How Ambitions works for me")
        .accessibilityIdentifier("you.priority-governance")
    }

    private func governanceNode(_ item: GroupedNavigationSystemItem) -> some View {
        let accent = item.state == .calm ? LivingTabContext.you.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        return Button {
            onSelect(item)
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: item.symbolName)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(accent)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(item.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let statusLabel = item.statusLabel {
                            Spacer(minLength: theme.spacing.xs)

                            Text(statusLabel)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }
                    }

                    Text(compactDetail(for: item))
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 1)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.vertical, theme.spacing.xxxs)
            .padding(.leading, theme.spacing.sm)
            .padding(.trailing, theme.spacing.xs)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(accent.opacity(0.72))
                    .frame(width: 2)
            }
        }
        .buttonStyle(.plain)
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary(for: item))
        .accessibilityIdentifier("you.priority-node.\(item.id)")
    }

    private func accessibilitySummary(for item: GroupedNavigationSystemItem) -> String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    private func compactDetail(for item: GroupedNavigationSystemItem) -> String {
        switch item.id {
        case "trust-automation":
            "Proposes first, asks before changing."
        case "personal-runtime":
            "Local context stays inspectable."
        case "receipts-history":
            "Every change keeps a receipt path."
        default:
            item.subtitle
        }
    }
}

private struct YouPersonalRuntimeGovernanceControls: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [GroupedNavigationSystemItem]
    let onSelect: (GroupedNavigationSystemItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("How Ambitions works for me")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("Trust, personal context, and receipts stay inspectable before deeper controls.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        YouPersonalRuntimeGovernanceRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.72))
                    .frame(height: 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.colors.strokeSubtle.opacity(0.72))
                    .frame(height: 1)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("How Ambitions works for me")
        .accessibilityIdentifier("you.priority-governance")
    }
}

private struct YouPersonalRuntimeGovernanceRow: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: GroupedNavigationSystemItem

    var body: some View {
        let accent = item.state == .calm ? LivingTabContext.you.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: item.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(Circle().fill(accent.opacity(0.12)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.bodyEmphasized : theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            if let statusLabel = item.statusLabel {
                Text(statusLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 0.78)
                    .padding(.top, theme.spacing.xxxs)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
                .padding(.top, theme.spacing.xxxs)
                .accessibilityHidden(true)
        }
        .padding(.vertical, theme.spacing.sm)
        .background(alignment: .leading) {
            Rectangle()
                .fill(accent.opacity(0.16))
                .frame(width: 2)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.54))
                .frame(height: 1)
                .padding(.leading, 40)
        }
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("you.priority-row.\(item.id)")
    }

    private var accessibilitySummary: String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}

private struct YouPersonalSystemNavigation: View {
    @Environment(\.ambitionTheme) private var theme

    let sections: [GroupedNavigationSystemSection]
    let onSelect: (GroupedNavigationSystemItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(section.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)

                        if let subtitle = section.subtitle {
                            Text(subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: theme.spacing.xxs) {
                        ForEach(section.items) { item in
                            Button {
                                onSelect(item)
                            } label: {
                                YouPersonalSystemNavigationRow(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(section.title)
            }
        }
    }
}

private struct YouPersonalSystemNavigationRow: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: GroupedNavigationSystemItem

    var body: some View {
        let accent = item.state == .calm ? LivingTabContext.you.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        content(accent: accent)
        .padding(.vertical, theme.spacing.sm)
        .padding(.horizontal, theme.spacing.xs)
        .background(alignment: .leading) {
            Rectangle()
                .fill(accent.opacity(0.16))
                .frame(width: 2)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.72))
                .frame(height: 1)
                .padding(.leading, 42)
        }
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("you.row.\(item.id)")
    }

    @ViewBuilder
    private func content(accent: Color) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            accessibilityContent(accent: accent)
        } else {
            compactContent(accent: accent)
        }
    }

    private func compactContent(accent: Color) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            icon(accent: accent)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                titleText(lineLimit: nil)
                statusPill(accent: accent)
                subtitleText(lineLimit: nil)
            }
            .layoutPriority(1)

            Spacer(minLength: theme.spacing.sm)
            chevron
        }
    }

    private func accessibilityContent(accent: Color) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                icon(accent: accent)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    titleText(lineLimit: 3)
                    statusPill(accent: accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(2)

                chevron
            }

            subtitleText(lineLimit: 4)
                .padding(.leading, 42)
        }
    }

    private func icon(accent: Color) -> some View {
        Image(systemName: item.symbolName)
            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
            .foregroundStyle(accent)
            .frame(width: 34, height: 34)
            .background(Circle().fill(accent.opacity(0.12)))
            .accessibilityHidden(true)
    }

    private func titleText(lineLimit: Int?) -> some View {
        Text(item.title)
            .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.section : theme.typography.bodyEmphasized)
            .foregroundStyle(theme.colors.textPrimary)
            .lineLimit(lineLimit)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func statusPill(accent: Color) -> some View {
        if let statusLabel = item.statusLabel {
            Text(statusLabel)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 0.78)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, theme.spacing.xxxs)
                .background(alignment: .bottom) {
                    Rectangle()
                        .fill(accent.opacity(0.28))
                        .frame(height: 1)
                }
                .accessibilityHidden(true)
        }
    }

    private func subtitleText(lineLimit: Int?) -> some View {
        Text(item.subtitle)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .lineLimit(lineLimit)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
            .foregroundStyle(theme.colors.textTertiary)
            .padding(.top, theme.spacing.xxs)
            .accessibilityHidden(true)
    }

    private var accessibilitySummary: String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }
}
