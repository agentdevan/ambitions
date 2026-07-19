import AmbitionsDesignSystem
import SwiftUI

struct SourceInspectionView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let presentation: SourceInspectionPresentation

    init(presentation: SourceInspectionPresentation = SourceInspectionPresentationFixtures.defaultDetail) {
        self.presentation = presentation
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Trust",
                    title: presentation.title,
                    subtitle: presentation.subtitle
                )

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SourceInspectionStatusLabel(presentation.state.userFacingTitle, state: presentation.state.visualState)
                        hiddenByDefaultText
                    }
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                        TagPill(presentation.state.userFacingTitle, state: presentation.state.visualState)
                        hiddenByDefaultText
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(presentation.publicDetail.sourceName)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("\(presentation.publicDetail.sourceKind) · \(presentation.publicDetail.retrievedLabel)")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Reference")
                .accessibilityValue("\(presentation.publicDetail.sourceName). \(presentation.publicDetail.sourceKind). \(presentation.publicDetail.retrievedLabel).")

                ForEach(presentation.contextRows) { row in
                    SourceInspectionRowView(row: row)
                }

                Text(presentation.privacySummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                if reduceMotion {
                    Text(presentation.reduceMotionSummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier("trust.source.inspection-detail.\(presentation.state.rawValue)")
        .ambitionPanelAccessibility(
            label: presentation.accessibilityLabel,
            value: "\(presentation.accessibilityValue) \(presentation.redactionSummary)",
            hint: presentation.accessibilityHint
        )
    }

    private var hiddenByDefaultText: some View {
        Text(presentation.hiddenByDefaultSummary)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SourceInspectionRowView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let row: SourceInspectionRow

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    rowTitle
                    SourceInspectionStatusLabel("Review", state: row.state)
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    rowTitle
                    Spacer(minLength: theme.spacing.sm)
                    TagPill("Review", state: row.state)
                }
            }

            Text(row.detail)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(row.title)
        .accessibilityValue(row.detail)
    }

    private var rowTitle: some View {
        Text(row.title)
            .font(theme.typography.bodyEmphasized)
            .foregroundStyle(theme.colors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SourceInspectionStatusLabel: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let state: AmbitionVisualState

    init(_ title: String, state: AmbitionVisualState) {
        self.title = title
        self.state = state
    }

    var body: some View {
        let style = theme.stateStyle(for: state)

        Text(title)
            .font(theme.typography.caption)
            .foregroundStyle(style.foreground)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, theme.spacing.sm)
            .padding(.vertical, theme.spacing.xxs)
            .background(Capsule(style: .continuous).fill(style.fill))
            .overlay(Capsule(style: .continuous).stroke(style.stroke, lineWidth: 1))
            .opacity(style.opacity)
    }
}
