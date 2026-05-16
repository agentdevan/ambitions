import AmbitionsDesignSystem
import SwiftUI

struct ProfileAvailabilityCenterCard: View {
    @Environment(\.ambitionTheme) private var theme

    let center: ProfileAvailabilityCenterState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "Availability Center",
                    title: center.title,
                    subtitle: center.subtitle
                )

                ProfileAvailabilityCenterGroup(
                    title: "Hard Context Stack",
                    items: center.hardContextStack
                )
                ProfileAvailabilityCenterGroup(
                    title: "Protected Pocket Map",
                    items: center.protectedPocketMap
                )
                ProfileAvailabilityCenterGroup(
                    title: "Planning Defaults",
                    items: center.planningDefaults
                )
                ProfileAvailabilityCenterGroup(
                    title: "Automation Trust Control",
                    items: center.automationTrustControls
                )
                ProfileAvailabilityCenterGroup(
                    title: "Duration Source Proof",
                    items: center.durationSourceProof
                )
                ProfileAvailabilityCenterGroup(
                    title: "Vacation / Away Behavior",
                    items: center.vacationAwayBehavior
                )

                Text(center.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.availability-center-card")
        .ambitionPanelAccessibility(
            label: center.title,
            value: "Hard context, protected pockets, defaults, automation, duration, and away behavior",
            hint: "Explains the availability rules that Time and Today must respect."
        )
    }
}

private struct ProfileAvailabilityCenterGroup: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let items: [ProfileAvailabilityCenterItem]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            ForEach(items) { item in
                ProfileAvailabilityCenterRow(item: item)
            }
        }
    }
}

private struct ProfileAvailabilityCenterRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ProfileAvailabilityCenterItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: theme.spacing.sm)

                TagPill(item.statusLabel, state: item.state)
            }

            Text(item.summary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.sourceLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue("\(item.statusLabel). \(item.summary)")
        .accessibilityHint(item.sourceLabel)
    }
}
