import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

// Mutation/accessibility/proof contract: planning handoff actions route through stage navigation, announce the opened destination, and keep proof context attached to the row.
struct YouPlanningHandoffRow: View {
    @Environment(\.ambitionTheme) private var theme

    let handoff: ReviewPlanningHandoff

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "arrowshape.turn.up.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(handoff.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(handoff.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: theme.spacing.sm)
                TagPill(handoff.destinationLabel, state: handoff.state)
            }

            TagPill(handoff.safetyLabel, icon: "hand.raised", state: handoff.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(handoff.title)
        .accessibilityValue("\(handoff.destinationLabel). \(handoff.safetyLabel).")
        .accessibilityHint(handoff.detail)
    }
}

struct YouCorrectionPromptRow: View {
    @Environment(\.ambitionTheme) private var theme

    let prompt: ReviewCorrectionPrompt

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.bubble")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(prompt.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(prompt.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            TagPill(prompt.actionLabel, state: prompt.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

struct YouRuleRow: View {
    @Environment(\.ambitionTheme) private var theme

    let rule: YouConstitutionRule

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            TagPill(rule.statusLabel, state: rule.state)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(rule.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(rule.detail)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

struct YouMetricTile: View {
    @Environment(\.ambitionTheme) private var theme

    let metric: MetricSummary

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Label(metric.title, systemImage: metric.icon)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text(metric.value)
                .font(theme.typography.numeric)
                .foregroundStyle(theme.colors.textPrimary)
            if let detail = metric.detail {
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

struct YouAppearanceStudioSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let studio: YouAppearanceStudioState
    @Binding var appearancePreference: AppAppearancePreference
    @Binding var accentFamily: AmbitionAccentFamily
    let isSaving: Bool
    let hasUnsavedChanges: Bool
    let onSave: () -> Void

    let previewColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Appearance",
                    title: studio.title,
                    subtitle: studio.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(studio.previewSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)

                    Picker("Appearance", selection: $appearancePreference) {
                        ForEach(studio.modeOptions) { option in
                            Text(option.title).tag(option.preference)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("you.appearance-picker")

                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        ForEach(studio.modeOptions) { option in
                            YouSelectableRow(
                                title: option.title,
                                subtitle: option.subtitle,
                                state: appearancePreference == option.preference ? .selected : .default
                            ) {
                                appearancePreference = option.preference
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack {
                        Text("Accent family")
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        TagPill(accentFamily.title, icon: "paintpalette", state: .selected)
                    }

                    Picker("Accent family", selection: $accentFamily) {
                        ForEach(studio.accentOptions) { option in
                            Text(option.title).tag(option.family)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("you.accent-family-picker")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacing.sm) {
                        ForEach(studio.accentOptions) { option in
                            YouAccentTile(
                                option: option,
                                isSelected: accentFamily == option.family
                            ) {
                                accentFamily = option.family
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        title: "Live preview",
                        subtitle: "See the selected appearance against real Ambitions surfaces before you commit it."
                    )

                    LazyVGrid(columns: previewColumns, spacing: theme.spacing.sm) {
                        ForEach(studio.previewSwatches) { swatch in
                            YouPreviewSwatchSurface(
                                swatch: swatch,
                                appearancePreference: appearancePreference,
                                accentFamily: accentFamily
                            )
                        }
                    }
                }

                Text(studio.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onSave) {
                    HStack(spacing: theme.spacing.sm) {
                        Image(systemName: hasUnsavedChanges ? "checkmark.circle" : "checkmark.circle.fill")
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(hasUnsavedChanges ? (isSaving ? "Saving…" : "Save appearance and defaults") : "No unsaved changes")
                                .font(theme.typography.bodyEmphasized)
                            Text("Persist the curated setup for future launches.")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(AmbitionButtonStyle(tier: .hero, state: hasUnsavedChanges ? .selected : .default))
                .disabled(hasUnsavedChanges == false || isSaving)
                .accessibilityIdentifier("you.save-preferences-button")
            }
        }
        .accessibilityIdentifier("you.appearance-studio-card")
    }
}

struct YouSelectableRow: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let state: AmbitionVisualState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Circle()
                    .fill(state == .selected ? theme.colors.accentPrimary : theme.colors.surfaceOverlay)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if state == .selected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(theme.colors.accentPrimary)
                }
            }
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
            .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct YouAccentTile: View {
    @Environment(\.ambitionTheme) private var theme

    let option: YouAccentOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let previewTheme = AmbitionTheme.theme(for: .dark, accentFamily: option.family)

        Button(action: action) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(previewTheme.surfaces.heroGradient)
                    .frame(height: 58)
                    .overlay(alignment: .bottomLeading) {
                        HStack(spacing: 6) {
                            Circle().fill(previewTheme.colors.accentPrimary).frame(width: 10, height: 10)
                            Circle().fill(previewTheme.colors.accentWarm).frame(width: 10, height: 10)
                            Circle().fill(previewTheme.colors.textPrimary.opacity(0.8)).frame(width: 10, height: 10)
                        }
                        .padding(10)
                    }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack {
                        Text(option.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.colors.accentPrimary)
                        }
                    }
                    Text(option.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
            .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(isSelected ? theme.colors.accentPrimary.opacity(0.7) : theme.colors.strokeSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
