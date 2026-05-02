import AmbitionsDesignSystem
import SwiftUI

enum ProfileRootDetail: String, Identifiable {
    case profile
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
        case .profile: "Profile"
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
        case .planBehavior: "Plan Behavior"
        case .automationTrust: "Automation & Trust"
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

struct ProfileSettingsRootView: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: ProfileDashboard
    let onOpenDetail: (ProfileRootDetail) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("You")
                    .font(theme.typography.heroDisplay)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)

                Text("Your settings, memory, and trust controls.")
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .accessibilityIdentifier("you.root-title")

            ProfileCompactSystemCard(dashboard: dashboard)

            GroupedNavigationList {
                ForEach(dashboard.systemCenter.sections) { section in
                    GroupedNavigationSection(title: section.title, footer: section.footer) {
                        ForEach(section.items) { item in
                            GroupedDisclosureNavigationRow(
                                title: item.title,
                                subtitle: item.subtitle,
                                systemImage: item.icon,
                                badge: GroupedNavigationBadge(item.statusLabel, state: item.semanticState),
                                accessibilityIdentifier: "you.row.\(item.id)",
                                accessibilityLabel: item.title,
                                accessibilityValue: item.statusLabel,
                                accessibilityHint: item.accessibilityHint
                            ) {
                                onOpenDetail(detail(for: item))
                            }
                        }
                    }
                }
            }
            .accessibilityIdentifier("you.grouped-navigation-root")
        }
        .accessibilityIdentifier("you.root")
    }

    private func detail(for item: ProfileSystemCenterItem) -> ProfileRootDetail {
        switch item.id {
        case "profile": .profile
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
        default: .profile
        }
    }
}

private struct ProfileCompactSystemCard: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: ProfileDashboard

    var body: some View {
        AppCard {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Circle()
                    .fill(theme.shell.activeTabBackground)
                    .overlay(
                        Text("A")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.shell.activeTabForeground)
                    )
                    .frame(width: 42, height: 42)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(dashboard.hero.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                    Text(dashboard.hero.dominantTruth)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Spacer(minLength: theme.spacing.xs)

                Text(dashboard.preferences.appearancePreference.title)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule().fill(theme.colors.surfaceOverlay))
                    .overlay(Capsule().stroke(theme.colors.strokeSubtle, lineWidth: 1))
            }
            .padding(theme.spacing.sm)
        }
        .accessibilityIdentifier("you.compact-profile-card")
    }
}
