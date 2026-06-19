import AmbitionsDesignSystem
import SwiftUI

struct MotionCurrentProofThreadTexture: View {
    var body: some View {
        ProductMeaningCanvasEngine(
            role: .motionProofThread,
            visualState: .selected,
            accessibilityIdentifier: "motion.current.proof-thread-canvas-engine"
        )
        .opacity(0.74)
        .mask {
            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.82),
                    .black.opacity(0.56),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .accessibilityHidden(true)
    }
}

struct MotionFieldRhythmSpine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let lanes: [MotionLaneState]
    let reduceMotion: Bool

    var body: some View {
        ViewThatFits(in: .horizontal) {
            verticalRhythm
            horizontalRhythm
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Motion rhythm")
        .accessibilityValue(lanes.map { "\($0.rhythmTitle), \($0.status)" }.joined(separator: ". "))
        .accessibilityIdentifier("motion.current.rhythm-spine")
    }

    private var verticalRhythm: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            theme.colors.accentSecondary.opacity(0.72),
                            theme.colors.accentWarm.opacity(0.52),
                            theme.colors.success.opacity(0.72)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: colorSchemeContrast == .increased ? 2 : 1)
                .padding(.leading, 18)
                .padding(.vertical, theme.spacing.sm)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: reduceMotion ? theme.spacing.sm : theme.spacing.xs) {
                ForEach(lanes.indices, id: \.self) { index in
                    MotionRhythmNode(lane: lanes[index], index: index)
                }
            }
        }
    }

    private var horizontalRhythm: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            ForEach(lanes.indices, id: \.self) { index in
                MotionRhythmNode(lane: lanes[index], index: index)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct MotionRhythmNode: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    let lane: MotionLaneState
    let index: Int

    var body: some View {
        let tint = lane.color(theme)

        HStack(alignment: .center, spacing: theme.spacing.xs) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.18))
                    .frame(width: nodeSize, height: nodeSize)
                Image(systemName: lane.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)
            }
            .overlay(Circle().stroke(tint.opacity(colorSchemeContrast == .increased ? 0.78 : 0.34), lineWidth: 1))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(lane.rhythmTitle)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(lane.status)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(.vertical, theme.spacing.xxxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(lane.rhythmTitle)
        .accessibilityValue(lane.status)
    }

    private var nodeSize: CGFloat {
        index == 1 ? 32 : 28
    }
}
