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
        let colors = AmbitionsColor(theme: theme)
        let typography = AmbitionsTypography(theme: theme)
        let spacing = AmbitionsSpacing(theme: theme)
        let material = AmbitionsMaterial(theme: theme)
        let lighting = AmbitionsLighting(theme: theme)
        let depth = AmbitionsDepth(theme: theme)
        let motion = AmbitionsMotion(theme: theme)

        VStack(alignment: .leading, spacing: spacing.sectionGap) {
            Button {
                onOpenStepDetail(step.stepDetail(privacy: privacy, contextLabel: contextLabel))
            } label: {
                HStack(alignment: .top, spacing: spacing.objectGap) {
                    DayRailNode(kind: .recommended, active: true)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: spacing.objectGap) {
                        Text("Start here")
                            .font(typography.caption)
                            .foregroundStyle(colors.tertiaryText)
                            .accessibilityIdentifier("TodayRealityRailStartHereTitle")

                        Text(step.title)
                            .font(typography.objectTitle)
                            .foregroundStyle(colors.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("TodayRealityRailStepTitle")

                        Text(step.subtitle)
                            .font(typography.body)
                            .foregroundStyle(colors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: spacing.standard)
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Opens Step Detail. Start now opens Step session. The review history explains what will stay reviewable.")
            .accessibilityIdentifier(privacy.isSensitiveProjection ? "TodayRealityRailPrivateItem" : "TodayStartHereSurface")

            footer
            inspectionStrip

            actionRow
        }
        .padding(spacing.primaryObjectPadding)
        .background(
            ZStack {
                UnevenRoundedRectangle(
                    topLeadingRadius: theme.radius.sm,
                    bottomLeadingRadius: theme.radius.sm,
                    bottomTrailingRadius: theme.radius.lg,
                    topTrailingRadius: theme.radius.lg,
                    style: .continuous
                )
                .fill(colors.primaryObjectFill)

                material.startHereWash
                    .blendMode(lighting.startHereWashBlendMode)
            }
        )
        .overlay(
            HStack(spacing: 0) {
                Rectangle()
                    .fill(colors.startHereAccent.opacity(lighting.startHereAccentOpacity))
                    .frame(width: 3)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
            }
        )
        .shadow(
            color: depth.primaryObjectShadow.color,
            radius: depth.primaryObjectShadow.radius,
            x: depth.primaryObjectShadow.x,
            y: depth.primaryObjectShadow.y
        )
        .transition(motion.primaryObjectTransition(reduceMotion: reduceMotion))
    }

    @ViewBuilder
    var actionRow: some View {
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

    var actionColumn: some View {
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
    var optionalityControls: some View {
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

    var showAnotherButton: some View {
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

    var notThisButton: some View {
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

    var footer: some View {
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

            Button {
                onOpenStepDetail(step.stepDetail(privacy: privacy, contextLabel: contextLabel))
            } label: {
                Label("Trust details", systemImage: "doc.text.magnifyingglass")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, theme.spacing.xxs)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(theme.colors.strokeSubtle)
                            .frame(height: 1)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("TodayStartHereTrustDetails")
        }
    }

    var inspectionStrip: some View {
        Button {
            onOpenStepDetail(step.stepDetail(privacy: privacy, contextLabel: contextLabel))
        } label: {
            Label("Why this?", systemImage: "doc.text.magnifyingglass")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, theme.spacing.xxs)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle)
                        .frame(height: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("TodayStartHereProofDetails")
    }

    var proofCaption: String {
        switch mode {
        case .recovery:
            "Still counts."
        default:
            "Receipt saved"
        }
    }

    var sourceSummary: String {
        if privacy.isSensitiveProjection {
            return privacy.sourceLabel
        }
        let labels = step.sourceLabels.map(\.label).prefix(2)
        return labels.isEmpty ? step.sourceQualityLabel : labels.joined(separator: " · ")
    }

    var accessibilityLabel: String {
        privacy.isSensitiveProjection
            ? "Start here. Private item. Details stay private on Today."
            : "Start here. \(step.title). \(step.subtitle)"
    }

    var accessibilityValue: String {
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
