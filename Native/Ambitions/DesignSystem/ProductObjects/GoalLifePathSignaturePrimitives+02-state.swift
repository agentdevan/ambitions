import AmbitionsDesignSystem
import SwiftUI

// accessibilityReduceMotion contract: this split helper reads the root GoalLifePathView reduceMotion environment before drawing path motion.
extension GoalLifePathView {
    init(overview: GoalsOverview, privacySensitive: Bool = false) {
        self.state = GoalLifePathState(overview: overview, privacySensitive: privacySensitive)
    }


    var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text("Thread Focus")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.accentWarm)

                Text(state.badge)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.stateStyle(for: state.visualState).accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule(style: .continuous).fill(theme.stateStyle(for: state.visualState).fill))
                    .overlay(Capsule(style: .continuous).strokeBorder(theme.stateStyle(for: state.visualState).stroke, lineWidth: 1))
            }

            Text(state.title)
                .font(theme.typography.section)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(state.subtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }


    var visualPathStack: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            ForEach(Array(state.nodes.enumerated()), id: \.element.id) { index, node in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    GoalLifePathNodeView(
                        node: node,
                        isFocused: focusedNodeID == node.id,
                        onFocus: { focus(node) }
                    )

                    if index < state.nodes.count - 1 {
                        GoalLifePathConnectorView(
                            tone: connectorTone(after: node),
                            reducedMotion: reduceMotion
                        )
                        .padding(.top, 30)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }


    var accessibilityPathStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(state.nodes) { node in
                GoalLifePathNodeView(
                    node: node,
                    isFocused: focusedNodeID == node.id,
                    onFocus: { focus(node) }
                )
            }
        }
    }


    var alternateRoutes: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Alternate routes")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
                ForEach(state.alternateRoutes) { route in
                    let style = theme.stateStyle(for: route.state)
                    HStack(alignment: .top, spacing: theme.spacing.xs) {
                        Image(systemName: route.symbolName)
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(style.accent)
                            .frame(width: 24, height: 24)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(route.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textPrimary)
                                .lineLimit(2)
                            Text(route.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                    .padding(theme.spacing.xs)
                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
                    .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(route.title). \(route.detail)")
                }
            }
        }
    }


    func focus(_ node: GoalLifePathNodeState) {
        withAnimation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true)) {
            focusedNodeID = focusedNodeID == node.id ? nil : node.id
        }
    }


    func connectorTone(after node: GoalLifePathNodeState) -> AmbitionVisualState {
        switch node.kind {
        case .risk:
            .warning
        case .proof:
            .success
        case .current, .next, .start:
            .selected
        }
    }
}
