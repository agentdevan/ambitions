import AmbitionsDesignSystem
import SwiftUI

struct MotionReentryPrompt: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: "arrow.uturn.forward.circle")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentWarm)
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Re-enter from here")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Motion shows what changed, where to return, and what needs recovery.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("motion.reentry.prompt")
    }
}

struct MotionContextCrown: View {
    @Environment(\.ambitionTheme) private var theme

    let state: MotionContextCrownState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(state.eyebrow)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .textCase(.uppercase)

                Rectangle()
                    .fill(theme.colors.strokeSubtle)
                    .frame(width: 22, height: 1)
                    .accessibilityHidden(true)
            }

            Text(state.title)
                .font(theme.typography.hero)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .accessibilityIdentifier("motion.current.title")

            Text(state.summary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("motion.current.context-summary")

            HStack(alignment: .top, spacing: theme.spacing.xs) {
                ForEach(state.chips) { chip in
                    ProofRelationshipTracePrimitiveToken(
                        role: motionTraceRole(for: chip.title),
                        title: chip.title,
                        systemImage: chip.icon,
                        semanticState: chip.semanticState,
                        accessibilityIdentifier: "motion.current.crown.trace.\(chip.id.motionSlug)"
                    )
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(state.title). \(state.summary)")
    }
}

struct MotionSourceReceiptAffordance: View {
    @Environment(\.ambitionTheme) private var theme

    let state: MotionSourceReceiptAffordanceState

    var body: some View {
        ProofRelationshipTracePrimitiveStage(
            role: .inspection,
            title: state.title,
            subtitle: "Source, proof, and receipt stay inspectable when you open the history detail.",
            accessibilityIdentifier: "motion.current.source-proof-receipt"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(state.items) { item in
                    ProofRelationshipTracePrimitiveLine(
                        role: motionTraceRole(for: item.label),
                        title: item.label,
                        subtitle: item.value,
                        systemImage: item.icon,
                        semanticState: item.semanticState,
                        accessibilityIdentifier: "motion.current.source-proof-receipt.\(item.id)"
                    )
                }
            }
        }
    }
}

struct MotionContinuityDock: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [MotionDockAction]
    let onAction: (MotionCurrentAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Continue")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)

            MotionCurrentFlowLayout(spacing: theme.spacing.sm) {
                ForEach(actions) { action in
                    Button(action.title) {
                        onAction(stageMotionAction(for: action.id))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .accessibilityIdentifier("motion.current.dock.\(action.id)")
                }
            }
        }
        .padding(.bottom, theme.spacing.md)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("motion.current.continuity-dock")
    }

    private func stageMotionAction(for actionID: String) -> MotionCurrentAction {
        switch actionID.lowercased() {
        case "today":
            return .openToday
        case "goals":
            return .openGoals
        case "time":
            return .openTime
        case "trust":
            return .openTrust
        default:
            return .openTrust
        }
    }
}
