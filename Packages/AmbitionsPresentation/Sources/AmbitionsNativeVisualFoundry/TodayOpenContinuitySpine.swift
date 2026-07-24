import SwiftUI

struct TodayOpenContinuitySpine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let kind: TodayOpenContinuityNodeKind
    let palette: TodayOpenContinuityPalette
    var extendsBefore = true
    var extendsAfter = true

    var body: some View {
        VStack(spacing: 0) {
            connector
                .opacity(extendsBefore ? 1 : 0)

            node
                .frame(width: 24, height: 24)

            connector
                .opacity(extendsAfter ? 1 : 0)
        }
        .frame(width: 28)
        .frame(minHeight: 44)
        .animation(policy.stateAnimation, value: kind)
        .accessibilityHidden(true)
    }

    private var policy: TodayOpenContinuityMotionPolicy {
        TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)
    }

    private var connector: some View {
        Rectangle()
            .fill(connectorColor)
            .frame(width: kind == .saving ? 2 : 1)
            .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var node: some View {
        switch kind {
        case .current:
            Circle()
                .strokeBorder(nodeColor, lineWidth: 2)
                .frame(width: 11, height: 11)
        case .proposed:
            ZStack {
                Circle()
                    .strokeBorder(nodeColor, lineWidth: 1.5)
                    .frame(width: 10, height: 10)
                    .offset(x: -3, y: 2)
                Circle()
                    .strokeBorder(nodeColor, lineWidth: 1.5)
                    .frame(width: 10, height: 10)
                    .offset(x: 3, y: -2)
            }
        case .saving:
            ZStack {
                Capsule()
                    .fill(nodeColor)
                    .frame(width: 3, height: 22)
                Circle()
                    .fill(palette.canvas)
                    .frame(width: 7, height: 7)
                    .overlay {
                        Circle().stroke(nodeColor, lineWidth: 1.5)
                    }
            }
        case .settled:
            Circle()
                .strokeBorder(nodeColor, lineWidth: 2)
                .frame(width: 14, height: 14)
                .overlay {
                    Circle()
                        .fill(nodeColor)
                        .frame(width: 6, height: 6)
                }
        case .interrupted:
            VStack(spacing: 5) {
                Rectangle()
                    .fill(nodeColor)
                    .frame(width: 2, height: 7)
                    .offset(x: -2)
                Rectangle()
                    .fill(nodeColor)
                    .frame(width: 2, height: 7)
                    .offset(x: 2)
            }
        case .protected:
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .strokeBorder(nodeColor, lineWidth: 1.5)
                    .frame(width: 16, height: 16)
                    .overlay {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 7, weight: .semibold))
                            .foregroundStyle(nodeColor)
                    }
                Rectangle()
                    .fill(nodeColor)
                    .frame(width: 2, height: 20)
            }
        case .fixed:
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .strokeBorder(nodeColor, lineWidth: 1.5)
                .frame(width: 13, height: 13)
                .rotationEffect(.degrees(45))
                .overlay {
                    Circle()
                        .fill(nodeColor)
                        .frame(width: 4, height: 4)
                }
        case .external:
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .strokeBorder(nodeColor, lineWidth: 1.5)
                .frame(width: 14, height: 14)
        case .openLane:
            VStack(spacing: 5) {
                Capsule()
                    .fill(nodeColor)
                    .frame(width: 15, height: 2)
                Capsule()
                    .fill(nodeColor)
                    .frame(width: 15, height: 2)
            }
        }
    }

    private var connectorColor: Color {
        kind == .saving ? palette.ambitionsAccentMuted : palette.separator
    }

    private var nodeColor: Color {
        switch kind {
        case .current:
            palette.labelSecondary
        case .proposed, .saving:
            palette.ambitionsAccentMuted
        case .settled, .protected:
            palette.protectedState
        case .interrupted:
            palette.interruptedState
        case .fixed:
            palette.fixedState
        case .external:
            palette.externalState
        case .openLane:
            palette.labelTertiary
        }
    }
}
