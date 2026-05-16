import AmbitionsDesignSystem
import SwiftUI

struct YouPlanningDefaultsSectionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let section: YouPlanningDefaultsSection
    let accessibilityIdentifier: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Planning Behavior",
                    title: section.title,
                    subtitle: section.subtitle
                )

                ForEach(section.preferences) { preference in
                    YouPlanningDefaultsPreferenceRow(preference: preference)
                }

                Text(section.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .ambitionPanelAccessibility(
            label: section.title,
            value: "\(section.preferences.count) planning defaults",
            hint: "Explains why these planning preferences matter."
        )
    }
}

private struct YouPlanningDefaultsPreferenceRow: View {
    @Environment(\.ambitionTheme) private var theme

    let preference: YouPlanningDefaultsPreference

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(preference.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: theme.spacing.sm)

                TagPill(preference.statusLabel, state: preference.state)
            }

            Text(preference.whyItMatters)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text(footerLine)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preference.title)
        .accessibilityValue("\(preference.statusLabel). \(preference.privacyLabel)")
        .accessibilityHint(preference.accessibilityHint)
    }

    private var footerLine: String {
        if let defaultLabel = preference.defaultLabel {
            return "\(preference.privacyLabel) Default: \(defaultLabel)."
        }
        return preference.privacyLabel
    }
}
