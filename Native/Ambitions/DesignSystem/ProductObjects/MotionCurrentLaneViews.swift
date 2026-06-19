import AmbitionsDesignSystem
import SwiftUI

struct MotionLaneCluster: View {
    @Environment(\.ambitionTheme) private var theme

    let lanes: [MotionLaneState]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(lanes) { lane in
                MotionLaneBand(lane: lane)
            }
        }
        .accessibilityIdentifier("motion.current.lanes")
    }
}

private struct MotionLaneBand: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let lane: MotionLaneState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(lane.color(theme).opacity(0.2))
                    .frame(width: 38, height: 38)
                Image(systemName: lane.icon)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(lane.color(theme))
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Text(lane.title)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(lane.status)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .textCase(.uppercase)
                }

                Text(lane.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                MotionCurrentFlowLayout(spacing: theme.spacing.xs) {
                    ForEach(lane.markers) { marker in
                        ProofRelationshipTracePrimitiveToken(
                            role: motionTraceRole(for: marker.title),
                            title: marker.title,
                            systemImage: marker.icon,
                            semanticState: marker.semanticState,
                            accessibilityIdentifier: "motion.current.lane.\(lane.id).trace.\(marker.id.motionSlug)"
                        )
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(lane.items) { item in
                        MotionLaneStateRow(item: item, tint: lane.color(theme))
                    }
                }
                .padding(.top, theme.spacing.xs)
            }
        }
        .padding(.vertical, theme.spacing.md)
        .padding(.horizontal, theme.spacing.md)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(lane.color(theme).opacity(colorSchemeContrast == .increased ? 0.80 : 0.34))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.70 : 0.28))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(lane.color(theme))
                .frame(width: colorSchemeContrast == .increased ? 5 : 3)
                .padding(.vertical, theme.spacing.sm)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("motion.current.lane.\(lane.id)")
        .accessibilityLabel("\(lane.title). \(lane.status). \(lane.summary)")
        .accessibilityValue(lane.items.map(\.accessibilitySummary).joined(separator: ". "))
    }
}

private struct MotionLaneStateRow: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let item: MotionLaneItemState
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Circle()
                .fill(item.semanticState == .success ? theme.colors.success : tint)
                .frame(width: 8, height: 8)
                .padding(.top, 7)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(item.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.stateLabel)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .textCase(.uppercase)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ProofRelationshipTracePrimitiveLine(role: .source, title: "Context", subtitle: item.source, systemImage: "link", semanticState: item.semanticState, accessibilityIdentifier: "motion.current.lane.\(item.id).source")
                    ProofRelationshipTracePrimitiveLine(role: .proof, title: "History", subtitle: item.proof, systemImage: "seal", semanticState: item.semanticState, accessibilityIdentifier: "motion.current.lane.\(item.id).proof")
                    ProofRelationshipTracePrimitiveLine(role: .receipt, title: "Review", subtitle: item.receipt, systemImage: "doc.text.magnifyingglass", semanticState: item.semanticState, accessibilityIdentifier: "motion.current.lane.\(item.id).receipt")
                }
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(colorSchemeContrast == .increased ? 0.68 : 0.24))
                .frame(height: colorSchemeContrast == .increased ? 1.5 : 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.accessibilitySummary)
    }
}
