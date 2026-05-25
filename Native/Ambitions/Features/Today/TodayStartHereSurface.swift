import AmbitionsDesignSystem
import SwiftUI

struct StartHereSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let step: DayRailHeroStepState
    let mode: DayRailMode
    let privacy: DayRailPrivacyProjectionState
    let contextLabel: String
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Button {
                onOpenStepDetail(step.stepDetail(privacy: privacy, contextLabel: contextLabel))
            } label: {
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    DayRailNode(kind: .recommended, active: true)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        Text("Start here")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .accessibilityIdentifier("TodayRealityRailStartHereTitle")

                        Text(step.title)
                            .font(theme.typography.titleCompact)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("TodayRealityRailStepTitle")

                        Text(step.subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: theme.spacing.sm)
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Opens Step Detail. Start now opens Step Session. The receipt seam explains what will stay reviewable.")
            .accessibilityIdentifier(privacy.isSensitiveProjection ? "TodayRealityRailPrivateItem" : "TodayStartHereSurface")

            footer
            inspectionStrip

            actionRow
        }
        .padding(theme.spacing.md)
        .background(
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: theme.radius.sm,
                    bottomLeadingRadius: theme.radius.sm,
                    bottomTrailingRadius: theme.radius.lg,
                    topTrailingRadius: theme.radius.lg,
                    style: .continuous
                )
                .fill(theme.colors.surfaceOverlay.opacity(0.76))

                LinearGradient(
                    colors: [
                        theme.colors.accentWarm.opacity(0.14),
                        theme.colors.surfaceOverlay.opacity(0.02),
                        .clear,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.screen)
            }
        )
        .overlay(
            HStack(spacing: 0) {
                Rectangle()
                    .fill(theme.colors.accentWarm.opacity(0.86))
                    .frame(width: 3)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
            }
        )
        .transition(DAVMotionPreset.heroExpansion.transition(reduceMotion: reduceMotion))
    }

    @ViewBuilder
    private var actionRow: some View {
        let stacksVertically = dynamicTypeSize.isAccessibilitySize
        if stacksVertically {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                actionColumn
            }
        } else {
            HStack(alignment: .bottom, spacing: theme.spacing.md) {
                Spacer(minLength: 0)
                actionColumn
            }
        }
    }

    private var actionColumn: some View {
        VStack(alignment: .trailing, spacing: theme.spacing.xs) {
            TodayPrimaryActionButton(action: step.primaryAction, handler: onAction)
                .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : 220, alignment: .trailing)
                .accessibilityIdentifier("TodayRealityRailPrimaryAction")

            if let secondaryAction = step.secondaryAction {
                Button {
                    onAction(secondaryAction)
                } label: {
                    Label(secondaryAction.title, systemImage: secondaryAction.systemImage)
                        .font(theme.typography.caption.weight(.semibold))
                        .padding(.horizontal, theme.spacing.sm)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                .accessibilityHint("Uses the existing Today action without changing anything silently.")
                .accessibilityIdentifier("TodayStartHereSecondaryAction")
            }

            optionalityControls
        }
    }

    @ViewBuilder
    private var optionalityControls: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .trailing, spacing: theme.spacing.xs) {
                showAnotherButton
                notThisButton
            }
        } else {
            HStack(spacing: theme.spacing.xs) {
                showAnotherButton
                notThisButton
            }
        }
    }

    private var showAnotherButton: some View {
        Button {
            onShowAnother(step)
        } label: {
            Label("Show another", systemImage: "arrow.triangle.branch")
                .font(theme.typography.caption.weight(.semibold))
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .trailing)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .overlay(
            Capsule(style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityHint("Opens a focused replacement sheet with timeline impact before approval.")
        .accessibilityIdentifier("TodayStartHereShowAnother")
    }

    private var notThisButton: some View {
        Button {
            onNotThis(step)
        } label: {
            Label("Not this", systemImage: "hand.thumbsdown")
                .font(theme.typography.caption.weight(.semibold))
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .trailing)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .overlay(
            Capsule(style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityHint("Opens a compact reason sheet so the rejection stays local and reviewable.")
        .accessibilityIdentifier("TodayStartHereNotThis")
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.xs) {
                AmbitionChip(step.duration.label, role: .time, semanticState: .calendarDerived)
                AmbitionChip(step.fitLabel, role: .state, semanticState: .focus)
            }
            .accessibilityHidden(true)

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Text(proofCaption)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityHidden(true)

                Spacer(minLength: theme.spacing.sm)

                EvidenceLabel(
                    "Why this?",
                    detail: step.becauseLine,
                    source: sourceSummary,
                    state: privacy.isSensitiveProjection ? .sensitive : .proof,
                    context: .today
                )
                .accessibilityIdentifier("TodayStartHereBecauseLine")
            }

            VStack(alignment: .leading, spacing: 0) {
                InlineTrustReceipt(item: step.receiptItem)
                    .accessibilityIdentifier("TodayStartHereReceiptPreview")
            }
            .accessibilityIdentifier("TodayStartHereSourceFreshness")
        }
    }

    private var inspectionStrip: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                EvidenceLabel(
                    "Source",
                    detail: sourceSummary,
                    source: step.sourceRecordLabel,
                    state: privacy.isSensitiveProjection ? .sensitive : .proof,
                    context: .today
                )

                EvidenceLabel(
                    "Receipt",
                    detail: step.receiptLabel,
                    source: step.proofLabel,
                    state: .proof,
                    context: .trust
                )
            }

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                EvidenceLabel(
                    "Proof",
                    detail: step.proofLabel,
                    source: step.receiptItem.privacyLabel,
                    state: .proof,
                    context: .trust
                )

                EvidenceLabel(
                    "Replay / inspection",
                    detail: step.replayInspectionLabel,
                    source: step.sourceRecordLabel,
                    state: .proof,
                    context: .trust
                )
            }
        }
        .accessibilityHidden(false)
    }

    private var proofCaption: String {
        switch mode {
        case .recovery:
            "Still counts."
        default:
            "Receipt saved"
        }
    }

    private var sourceSummary: String {
        if privacy.isSensitiveProjection {
            return privacy.sourceLabel
        }
        let labels = step.sourceLabels.map(\.label).prefix(2)
        return labels.isEmpty ? privacy.sourceLabel : labels.joined(separator: " · ")
    }

    private var accessibilityLabel: String {
        privacy.isSensitiveProjection
            ? "Start here. Private item. Details stay private on Today."
            : "Start here. \(step.title). \(step.subtitle)"
    }

    private var accessibilityValue: String {
        [
            step.duration.label,
            sourceSummary,
            step.becauseLine,
            proofCaption,
            step.receiptLabel,
            step.proofLabel,
            step.sourceRecordLabel,
            step.replayTraceLabel,
            step.replayInspectionLabel,
            step.receiptItem.accessibilitySummary,
        ].joined(separator: ". ")
    }
}
