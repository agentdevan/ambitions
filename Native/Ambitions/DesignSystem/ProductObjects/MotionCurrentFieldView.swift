import AmbitionsDesignSystem
import SwiftUI

struct MotionCurrentField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: MotionCurrentFieldState
    let lanes: [MotionLaneState]
    let reduceMotion: Bool
    let onAction: (MotionCurrentAction) -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            MotionCurrentProofThreadTexture()

            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    MotionFieldRhythmSpine(lanes: lanes, reduceMotion: reduceMotion)
                        .frame(width: 132, alignment: .leading)

                    fieldFacts
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)
                }
            }
        }
        .padding(.vertical, theme.spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.accentSecondary.opacity(colorSchemeContrast == .increased ? 0.82 : 0.38))
                .frame(height: colorSchemeContrast == .increased ? 2 : 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.74 : 0.32))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("motion.current.field")
        .accessibilityLabel("\(state.title). \(state.summary)")
        .accessibilityValue("\(state.source). \(state.proof). \(state.receipt). \(state.control)")
    }

    @ViewBuilder
    private var fieldFacts: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text(state.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                motionActionStrip

                traceFacts

                Text(state.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.control)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text(state.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(state.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.control)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                motionActionStrip

                traceFacts
            }
        }
    }

    private var motionActionStrip: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    motionActionButton(title: "Review", systemImage: "checkmark.seal", accessibilityIdentifier: "motion.behavior.action.review", action: .reviewHistory(state.proof))
                    motionActionButton(title: "History", systemImage: "clock.arrow.circlepath", accessibilityIdentifier: "motion.behavior.action.history", action: .openHistory(state.receipt))
                    motionActionButton(title: "Return", systemImage: "arrowshape.turn.up.forward", accessibilityIdentifier: "motion.behavior.action.return", action: .returnToThread(state.control))
                }
            } else {
                MotionCurrentFlowLayout(spacing: theme.spacing.xs) {
                    motionActionButton(title: "Review", systemImage: "checkmark.seal", accessibilityIdentifier: "motion.behavior.action.review", action: .reviewHistory(state.proof))
                    motionActionButton(title: "History", systemImage: "clock.arrow.circlepath", accessibilityIdentifier: "motion.behavior.action.history", action: .openHistory(state.receipt))
                    motionActionButton(title: "Return", systemImage: "arrowshape.turn.up.forward", accessibilityIdentifier: "motion.behavior.action.return", action: .returnToThread(state.control))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("motion.current.action-strip")
    }

    private func motionActionButton(
        title: String,
        systemImage: String,
        accessibilityIdentifier: String,
        action: MotionCurrentAction
    ) -> some View {
        Button {
            onAction(action)
        } label: {
            Label(title, systemImage: systemImage)
                .font(theme.typography.caption.weight(.semibold))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? .infinity : nil, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private var traceFacts: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                sourceFact
                proofFact
                receiptFact
            }
        } else {
            HStack(alignment: .top, spacing: theme.spacing.xs) {
                compactTraceFact(title: "Context", subtitle: state.source, systemImage: "link", accessibilityIdentifier: "motion.current.fact.source")
                compactTraceFact(title: "History", subtitle: state.proof, systemImage: "seal", accessibilityIdentifier: "motion.current.fact.proof")
                compactTraceFact(title: "Review", subtitle: state.receipt, systemImage: "doc.text.magnifyingglass", accessibilityIdentifier: "motion.current.fact.receipt")
            }
        }
    }

    private func compactTraceFact(
        title: String,
        subtitle: String,
        systemImage: String,
        accessibilityIdentifier: String
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Image(systemName: systemImage)
                .font(theme.typography.caption.weight(theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.accentSecondary)
                .accessibilityHidden(true)

            Text(title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(subtitle)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .padding(.vertical, theme.spacing.xs)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(theme.colors.accentSecondary.opacity(0.42))
                .frame(width: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle)
    }

    private var sourceFact: some View {
        ProofRelationshipTracePrimitiveLine(role: .source, title: "Context", subtitle: state.source, systemImage: "link", accessibilityIdentifier: "motion.current.fact.source")
    }

    private var proofFact: some View {
        ProofRelationshipTracePrimitiveLine(role: .proof, title: "History", subtitle: state.proof, systemImage: "seal", accessibilityIdentifier: "motion.current.fact.proof")
    }

    private var receiptFact: some View {
        ProofRelationshipTracePrimitiveLine(role: .receipt, title: "Review", subtitle: state.receipt, systemImage: "doc.text.magnifyingglass", accessibilityIdentifier: "motion.current.fact.receipt")
    }
}
