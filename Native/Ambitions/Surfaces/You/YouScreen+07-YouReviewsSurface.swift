import AmbitionsDesignSystem
import Foundation
import SwiftUI
import UIKit

struct YouReviewsSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let reviews: YouReviewsState

    var body: some View {
        let projection = reviews.projection

        ProductObjectFrame {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Reviews",
                    title: reviews.title,
                    subtitle: reviews.subtitle
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "rectangle.stack.badge.play")
                            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.colors.accentPrimary)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(projection.period.timeframeLabel)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.accentWarm)
                            Text(projection.period.title)
                                .font(theme.typography.titleCompact)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(projection.period.dominantTruth)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                        TagPill(projection.lifeOSReceipt.statusLabel, state: projection.period.state)
                    }
                    .padding(theme.spacing.md)
                    .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                    .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))

                    Text(projection.period.trustWhisper)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                YouReviewCluster(
                    title: projection.recovery.title,
                    subtitle: projection.recovery.subtitle,
                    emptyTitle: projection.recovery.emptyStateTitle,
                    emptyDetail: projection.recovery.emptyStateDetail,
                    items: Array((projection.recovery.whatRecovered + projection.recovery.whatWasProtected + projection.recovery.needsReview).prefix(4))
                )

                YouReviewCluster(
                    title: projection.lifeOSReceipt.title,
                    subtitle: projection.lifeOSReceipt.subtitle,
                    emptyTitle: projection.lifeOSReceipt.emptyStateTitle,
                    emptyDetail: projection.lifeOSReceipt.emptyStateDetail,
                    items: Array((projection.lifeOSReceipt.receiptHighlights + projection.lifeOSReceipt.meaningfulEvents).prefix(4))
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Review rhythms", subtitle: "Weekly, monthly, and recovery reviews stay under You, Time, and Goal context.")
                    ForEach(projection.cadences) { cadence in
                        YouReviewCadenceRow(cadence: cadence)
                    }
                }
                .accessibilityIdentifier("you.review-cadences-section")

                if projection.progressLines.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Progress receipt", subtitle: "A plain record of what changed, what has proof, and what should carry forward.")
                        ForEach(projection.progressLines) { line in
                            YouProgressReceiptLineRow(line: line)
                        }
                    }
                    .accessibilityIdentifier("you.progress-receipt-section")
                }

                if projection.proofHighlights.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Proof highlights", subtitle: "Recent evidence that can make the next review more grounded.")
                        ForEach(projection.proofHighlights) { proof in
                            YouReviewProofRow(proof: proof)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Carry forward", subtitle: "The smallest useful thing to keep visible after this review.")
                    ForEach(projection.carryForward) { item in
                        YouCarryForwardRow(item: item)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Planning handoff", subtitle: "Review can suggest where to go next, but it does not change the plan silently.")
                    ForEach(projection.planningHandoffs) { handoff in
                        YouPlanningHandoffRow(handoff: handoff)
                    }
                }
                .accessibilityIdentifier("you.review-planning-handoff-section")

                if projection.correctionPrompts.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(title: "Corrections", subtitle: "Existing correction paths stay user-directed.")
                        ForEach(projection.correctionPrompts.prefix(2)) { prompt in
                            YouCorrectionPromptRow(prompt: prompt)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(title: "Unavailable here", subtitle: "Trust notes for what this review does not claim.")
                    ForEach(projection.unavailableNotes.prefix(3)) { note in
                        YouReviewSignalRow(item: note)
                    }
                }

                Text(reviews.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("you.reviews-card")
        .ambitionPanelAccessibility()
    }
}

struct YouReviewCluster: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let emptyTitle: String
    let emptyDetail: String
    let items: [ReviewSignalItem]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(title: title, subtitle: subtitle)

            if items.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    TagPill("Available after more activity", icon: "clock", state: .default)
                    Text(emptyTitle)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(emptyDetail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(theme.spacing.md)
                .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
            } else {
                ForEach(items) { item in
                    YouReviewSignalRow(item: item)
                }
            }
        }
    }
}

struct YouReviewCadenceRow: View {
    @Environment(\.ambitionTheme) private var theme

    let cadence: ReviewCadenceSummary

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: cadenceIcon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(cadence.contextLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)
                Text(cadence.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(cadence.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
            TagPill(cadence.statusLabel, state: cadence.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(cadence.title)
        .accessibilityValue("\(cadence.contextLabel). \(cadence.statusLabel).")
        .accessibilityHint(cadence.detail)
    }

    var cadenceIcon: String {
        switch cadence.cadence {
        case .weekly:
            return "calendar"
        case .monthly:
            return "calendar.badge.clock"
        case .recovery:
            return "lifepreserver"
        }
    }
}

struct YouProgressReceiptLineRow: View {
    @Environment(\.ambitionTheme) private var theme

    let line: LifeOSReceiptProgressLine

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(line.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(line.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: theme.spacing.sm)
                TagPill(line.sourceLabel, state: line.state)
            }

            TagPill(line.privacyLabel, icon: "lock.shield", state: .default)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(line.title)
        .accessibilityValue("\(line.sourceLabel). \(line.privacyLabel).")
        .accessibilityHint(line.detail)
    }
}

struct YouReviewSignalRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ReviewSignalItem

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: item.icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(item.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
            TagPill(item.valueLabel, state: item.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

struct YouReviewProofRow: View {
    @Environment(\.ambitionTheme) private var theme

    let proof: ReviewProofHighlight

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentPrimary)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(proof.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(proof.detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            TagPill(proof.valueLabel, state: proof.state)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

struct YouCarryForwardRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ReviewCarryForwardItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            TagPill(item.actionLabel, icon: "arrow.forward", state: item.state)
            Text(item.title)
                .font(theme.typography.section)
                .foregroundStyle(theme.colors.textPrimary)
            Text(item.detail)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}
