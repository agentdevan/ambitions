import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: root rows route to local profile detail surfaces, preserve visible You context, and rely on detail screens to save or show proof-backed preference changes.
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

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .personalization: "Personalization"
        case .personalRuntime: "Personal settings"
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

struct UserSystemProfileRootView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var selectedRowHapticToken = ""
    let primitiveContract = YouObjectStageControlPrimitiveContract.current

    struct RootSettingsGroup: Identifiable {
        let id: String
        let title: String
        let rows: [RootSettingsRow]
    }

    struct RootSettingsRow: Identifiable {
        let id: String
        let title: String
        let detail: YouRootDetail
        let value: String
        let symbolName: String
        let semanticState: AmbitionSemanticState
    }

    let profileProjection: YouDashboard
    let onOpenDetail: (YouRootDetail) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            profileHeader

            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                ForEach(settingsGroups) { group in
                    NativeSettingsGroup(title: group.title) {
                        VStack(spacing: 0) {
                            ForEach(group.rows) { row in
                                UserProfileSettingsRow(row: row) {
                                    selectedRowHapticToken = row.id
                                    onOpenDetail(row.detail)
                                }
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("you.root")
        .accessibilityValue("You settings. \(localStatusSummary).")
        .ambitionHaptic(theme.haptics.routeChange, trigger: selectedRowHapticToken)
    }

    var profileHeader: some View {
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
                Text("You")
                    .font(dynamicTypeSize.isAccessibilitySize ? AmbitionsIOS26SemanticTokens.Typography.title3 : AmbitionsIOS26SemanticTokens.Typography.title2)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .accessibilityIdentifier("you.root-title")

                Text("Your settings")
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
        .accessibilityIdentifier("you.profile-header")
        .accessibilityLabel("You")
        .accessibilityValue(localStatusSummary)
    }

    var localStatusSummary: String {
        sourceSystemCenterItem(id: "export-import")?.statusLabel ?? "Local only"
    }

    var settingsGroups: [RootSettingsGroup] {
        [
            RootSettingsGroup(
                id: "profile",
                title: "Account & local settings",
                rows: [
                    row(id: "personalization", title: "Personalization", detail: .personalization, value: "Local", symbolName: "person.crop.circle", semanticState: .neutral),
                    row(id: "session-defaults", title: "Session defaults", detail: .sessionDefaults, value: "Ready", symbolName: "slider.horizontal.3", semanticState: .success),
                    row(id: "appearance", title: "Appearance", detail: .appearance, value: sourceSystemCenterItem(id: "appearance")?.statusLabel ?? "System", symbolName: "paintpalette", semanticState: .success),
                ]
            ),
            RootSettingsGroup(
                id: "planning",
                title: "Planning",
                rows: [
                    row(id: "life-areas", title: "Life Areas", detail: .lifeAreas, value: "Goals", symbolName: "square.grid.2x2", semanticState: .neutral),
                    row(id: "schedule-availability", title: "Schedule & Availability", detail: .scheduleAvailability, value: "Time", symbolName: "calendar", semanticState: .calendarDerived),
                    row(id: "planning-defaults", title: "Time Behavior", detail: .planBehavior, value: "Defaults", symbolName: "clock", semanticState: .focus),
                    row(id: "durations", title: "Durations", detail: .durations, value: "Adjust", symbolName: "timer", semanticState: .neutral),
                ]
            ),
            RootSettingsGroup(
                id: "capture",
                title: "Capture",
                rows: [
                    row(id: "capture-preferences", title: "Capture", detail: .capturePreferences, value: "Composer", symbolName: "square.and.pencil", semanticState: .capture),
                    row(id: "reviews", title: "Reviews", detail: .reviews, value: "Manual", symbolName: "checklist", semanticState: .review),
                ]
            ),
            RootSettingsGroup(
                id: "privacy",
                title: "Privacy",
                rows: [
                    row(id: "privacy", title: "Permissions", detail: .trustCenter, value: "Local", symbolName: "hand.raised", semanticState: .trust),
                    row(id: "local-data-controls", title: "Local Data", detail: .localDataControls, value: sourceSystemCenterItem(id: "export-import")?.statusLabel ?? "On device", symbolName: "externaldrive", semanticState: .caution),
                    row(id: "export-import", title: "Export / Import", detail: .exportImport, value: "Files", symbolName: "square.and.arrow.up.on.square", semanticState: .neutral),
                ]
            ),
            RootSettingsGroup(
                id: "app",
                title: "App",
                rows: [
                    row(id: "notifications", title: "Notifications", detail: .notifications, value: "Off by default", symbolName: "bell", semanticState: .neutral),
                    row(id: "accessibility", title: "Accessibility", detail: .accessibility, value: sourceSystemCenterItem(id: "accessibility")?.statusLabel ?? "System", symbolName: "figure", semanticState: .accessibilityUnverified),
                    row(id: "help", title: "Help", detail: .support, value: "Guides", symbolName: "questionmark.circle", semanticState: .neutral),
                    row(id: "about", title: "About", detail: .about, value: "Local", symbolName: "info.circle", semanticState: .neutral),
                ]
            ),
        ]
    }

    func row(
        id: String,
        title: String,
        detail: YouRootDetail,
        value: String,
        symbolName: String,
        semanticState: AmbitionSemanticState
    ) -> RootSettingsRow {
        RootSettingsRow(
            id: id,
            title: title,
            detail: detail,
            value: value,
            symbolName: symbolName,
            semanticState: semanticState
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
}

private struct UserProfileSettingsRow: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let row: UserSystemProfileRootView.RootSettingsRow
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Image(systemName: row.symbolName)
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.semanticAccent(for: row.semanticState))
                    .frame(width: 28, height: 28)
                    .accessibilityHidden(true)

                Text(row.title)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)

                Spacer(minLength: theme.spacing.sm)

                Text(row.value)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)

                Image(systemName: "chevron.right")
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, theme.spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("you.settings.row.\(row.id)")
        .accessibilityLabel(row.title)
        .accessibilityValue(row.value)
    }
}
