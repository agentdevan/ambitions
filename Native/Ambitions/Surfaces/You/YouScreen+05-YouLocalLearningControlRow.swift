import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

struct YouLocalLearningControlRow: View {
    @Environment(\.ambitionTheme) private var theme

    let control: YouLocalLearningControl

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentWarm)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(control.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(control.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                TagPill(control.availabilityLabel, state: control.state)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.xs, alignment: .leading)],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                TagPill(control.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                TagPill(control.receiptLabel, icon: "checkmark.seal", state: control.state)
                TagPill(control.boundaryLabel, icon: "lock.shield", state: .default)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: control.accessibilityLabel,
            value: control.accessibilityValue,
            hint: control.accessibilityHint
        )
    }

    var iconName: String {
        switch control.id {
        case "local-learning-reset":
            return "arrow.counterclockwise.circle"
        case "local-learning-disable":
            return "pause.circle"
        case "local-learning-delete":
            return "trash.slash"
        case "local-learning-export":
            return "square.and.arrow.up"
        default:
            return "slider.horizontal.3"
        }
    }
}

struct YouEverythingSearchSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var searchQuery = ""

    let search: YouEverythingSearchState

    var body: some View {
        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Search",
                    title: search.title,
                    subtitle: search.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    TextField(search.queryPrompt, text: $searchQuery, axis: .vertical)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1...3)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("you.everything-search.query")
                        .accessibilityLabel(search.queryPrompt)
                        .accessibilityHint("Filters local objects already stored on this device.")

                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "scope")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.colors.accentWarm)
                            .frame(width: 24)
                        Text(search.summary(for: searchQuery))
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text(search.performanceBudgetSummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if search.filters.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Filters",
                            title: "Local object types",
                            subtitle: "Counts reflect what is already loaded locally."
                        )

                        ForEach(search.filters) { item in
                            YouSettingRow(item: item)
                        }
                    }
                }

                let results = Array(search.filteredItems(matching: searchQuery).prefix(12))
                if results.isEmpty {
                    Text("No local objects match this search yet.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Matches",
                            title: "Inspectable local objects",
                            subtitle: search.hitPerformanceBudget ? "The view is capped to keep search responsive." : "The view stays limited to local objects only."
                        )

                        ForEach(results) { item in
                            YouEverythingSearchResultRow(item: item)
                        }
                    }
                }

                Text(search.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.everything-search-card")
        .ambitionPanelAccessibility(
            label: search.title,
            value: search.summary(for: searchQuery),
            hint: "Search stays local and inspectable."
        )
    }
}

struct YouEverythingSearchResultRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouEverythingSearchItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: item.kind.systemImage)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.kind.title, state: .default)
                TagPill(item.sourceLabel, state: .default)
                TagPill(item.freshness.label, state: item.freshness.visualState)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(item.primaryActions) { action in
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        TagPill(action.title, state: action.state)
                        Text(action.statusLabel)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(action.detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: item.accessibilityLabel,
            value: item.accessibilityValue,
            hint: item.accessibilityHint
        )
    }
}

struct YouMemoryLensItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: YouMemoryLensItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "scope")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.accentPrimary)
                    .frame(width: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.whyRemembered)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.sourceLabel, icon: "doc.text.magnifyingglass", state: .default)
                TagPill(item.sourceAgeLabel, icon: "clock", state: item.state)
                TagPill(item.privacyShutterLabel, icon: "eye.slash", state: .default)
            }

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.reviewLabel, icon: "checkmark.seal", state: item.state)
                TagPill(item.correctionLabel, icon: "pencil", state: .default)
                TagPill(item.rejectionLabel, icon: "xmark.seal", state: item.state == .success ? .default : .warning)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility(
            label: item.accessibilityLabel,
            value: item.accessibilityValue,
            hint: item.accessibilityHint
        )
    }
}

extension YouMemoryFreshness {
    var contextRecallState: ContextRecallState {
        switch self {
        case .current:
            return .current
        case .mayNeedReview:
            return .stale
        case .basedOnOlderContext:
            return .corrected
        }
    }
}

struct YouPersonalizationConsentPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let consent: YouPersonalizationConsentState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(
                eyebrow: "Consent",
                title: consent.title,
                subtitle: consent.summary
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(consent.sourceLabel, icon: "internaldrive", state: .default)
                    TagPill(consent.sensitiveMemoryLabel, icon: "hand.raised", state: .warning)
                    TagPill(consent.hiddenMemoryLabel, icon: "eye.slash", state: .selected)
                    TagPill(consent.controlLabel, icon: "person.crop.circle", state: .success)
                }
            }
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
        .accessibilityIdentifier("you.personalization-consent")
        .accessibilityLabel("\(consent.title). \(consent.summary). \(consent.controlLabel).")
    }
}
