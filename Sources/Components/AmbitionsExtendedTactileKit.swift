#if canImport(SwiftUI)
import SwiftUI

// MARK: - 1. AfiFlowIndicator
/// A micro-visualizer representing the current Active Focus Interval (AFI) flow density.
public struct AfiFlowIndicator: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var waveOffset: CGFloat = 0
    let intensity: Double

    public init(intensity: Double = 0.68) {
        self.intensity = intensity
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xxs) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(theme.shell.activeTabForeground)
                    .frame(width: 3, height: height(for: index))
            }
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxs)
        .background(Capsule().fill(theme.shell.activeTabBackground))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("AFI flow indicator")
        .accessibilityValue(accessibilityValue)
        .onAppear {
            guard reduceMotion == false else {
                waveOffset = 0
                return
            }

            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                waveOffset = 1.0
            }
        }
    }

    public var accessibilityValue: String {
        "Relative bars rise from shortest to tallest. Reduce Motion: static bars keep the same meaning. Non-color cue: height carries the state."
    }

    func height(for index: Int) -> CGFloat {
        let base = CGFloat(4 + (index * 3))
        return base + (waveOffset * CGFloat(index + 1) * CGFloat(intensity))
    }
}

// MARK: - 2. MeridianScaleAxis
/// A ruler-like tactile axis indicating where in the Reality Meridian a goal sits.
public struct MeridianScaleAxis: View {
    @Environment(\.ambitionTheme) private var theme
    let alignmentPosition: Double

    public init(alignmentPosition: Double = 0.5) {
        self.alignmentPosition = alignmentPosition
    }

    public var body: some View {
        VStack(spacing: theme.spacing.xs) {
            HStack(spacing: 0) {
                ForEach(0..<11) { tick in
                    Spacer()
                    Rectangle()
                        .fill(tick == 5 ? theme.colors.textPrimary : theme.colors.textTertiary)
                        .frame(width: tick == 5 ? 2 : 1, height: tick % 5 == 0 ? 12 : 6)
                    Spacer()
                }
            }
            .overlay(
                GeometryReader { geo in
                    Circle()
                        .fill(theme.colors.textPrimary)
                        .frame(width: 10, height: 10)
                        .offset(x: (geo.size.width * CGFloat(alignmentPosition)) - 5, y: -2)
                }
            )
        }
        .padding(.vertical, theme.spacing.xs)
        .background(RoundedRectangle(cornerRadius: theme.radius.sm).fill(theme.shell.controlBackground))
    }
}

// MARK: - 3. QuietBreatheIndicator
/// An elegant breathing status dot showing local database synchronization.
public struct QuietBreatheIndicator: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse: CGFloat = 0.38
    let title: String

    public init(title: String = "LOCAL ONLY") {
        self.title = title
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Circle()
                .fill(theme.semanticColors.trust)
                .frame(width: 8, height: 8)
                .scaleEffect(reduceMotion ? 1.0 : (1.0 + (pulse * 0.4)))
                .opacity(reduceMotion ? 1.0 : (1.0 - (pulse * 0.5)))
            
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Quiet breathe indicator")
        .accessibilityValue(accessibilityValue)
        .onAppear {
            guard reduceMotion == false else {
                pulse = 0.38
                return
            }

            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = 1.0
            }
        }
    }

    public var accessibilityValue: String {
        "\(title). Reduce Motion: static dot and label. Non-color cue: text identifies the sync state."
    }
}

// MARK: - 4. TactileDialControl
/// A custom gesture-responsive dial for configuring goal capacity thresholds.
public struct TactileDialControl: View {
    @Environment(\.ambitionTheme) private var theme
    @Binding private var threshold: Double

    public init(threshold: Binding<Double>) {
        self._threshold = threshold
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            Button(action: { threshold = max(0.0, threshold - 0.1) }) {
                Image(systemName: "minus.circle")
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .accessibilityLabel("Decrease capacity threshold")
            .accessibilityHint("Reduces the threshold by ten percent.")
            .ambitionMinimumTapTarget(theme.panel.minimumTapTarget)
            
            ZStack {
                Circle()
                    .stroke(theme.colors.textTertiary.opacity(0.38), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(threshold))
                    .stroke(theme.shell.activeTabForeground, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.0f%%", threshold * 100))
                    .font(theme.typography.caption.bold())
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Capacity threshold")
            .accessibilityValue(accessibilityValue)
            
            Button(action: { threshold = min(1.0, threshold + 0.1) }) {
                Image(systemName: "plus.circle")
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .accessibilityLabel("Increase capacity threshold")
            .accessibilityHint("Raises the threshold by ten percent.")
            .ambitionMinimumTapTarget(theme.panel.minimumTapTarget)
        }
    }

    public var accessibilityValue: String {
        "\(Int((threshold * 100).rounded())) percent selected. Non-color cue: the ring and number match the same threshold."
    }
}

// MARK: - 5. SeamConnector
/// A sleek vector connector bar showing links between captures and day lanes.
public struct SeamConnector: View {
    @Environment(\.ambitionTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(theme.colors.textTertiary)
                .frame(width: 4, height: 4)
            
            Rectangle()
                .fill(theme.colors.textTertiary.opacity(0.38))
                .frame(height: 1)
            
            Circle()
                .fill(theme.colors.textTertiary)
                .frame(width: 4, height: 4)
        }
        .padding(.horizontal, theme.spacing.sm)
    }
}

// MARK: - 6. AtmosphereBraid
/// A premium braided status ring demonstrating multi-source ingestion coherence.
public struct AtmosphereBraid: View {
    @Environment(\.ambitionTheme) private var theme

    public init() {}

    public var body: some View {
        ZStack {
            Circle()
                .stroke(theme.shell.activeTabForeground.opacity(0.24), lineWidth: 6)
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(
                    AngularGradient(
                        colors: [theme.shell.activeTabForeground, theme.semanticColors.trust, theme.shell.activeTabForeground],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [4, 4])
                )
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - 7. RecoveryTideStrip
/// A custom strip that shifts color harmoniously to recovery-guide users who had a heavy day.
public struct RecoveryTideStrip: View {
    let explanation: String

    public init(explanation: String) {
        self.explanation = explanation
    }

    public var body: some View {
        ClosureRecoveryPrimitiveLine(
            role: .recovery,
            title: "Recovery tide",
            subtitle: explanation,
            systemImage: "sparkles",
            accessibilityIdentifier: "recovery-tide-strip"
        ) {
            EmptyView()
        }
    }
}

// MARK: - 8. AnchorDotMeter
/// A micro-grid showing anchor-time availability status.
public struct AnchorDotMeter: View {
    @Environment(\.ambitionTheme) private var theme
    let totalAnchors = 8
    let availableAnchors = 5

    public init() {}

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<totalAnchors, id: \.self) { index in
                if index < availableAnchors {
                    Circle()
                        .fill(theme.shell.statusClear)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .stroke(theme.colors.textTertiary.opacity(0.55), lineWidth: 1)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Anchor dot meter")
        .accessibilityValue(accessibilityValue)
    }

    public var accessibilityValue: String {
        "\(availableAnchors) of \(totalAnchors) anchors available. Non-color cue: filled dots mean available and outlined dots mean unavailable."
    }
}

// MARK: - 9. ConfidenceBadge
/// A beautiful badge displaying recommendation alignment certainty.
public struct ConfidenceBadge: View {
    @Environment(\.ambitionTheme) private var theme
    let score: Double

    public init(score: Double) {
        self.score = score
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xxs) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 10))
            Text(String(format: "%.0f%% Fit", score * 100))
                .font(theme.typography.caption.bold())
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, 3)
        .foregroundStyle(theme.shell.activeTabForeground)
        .background(Capsule().fill(theme.shell.activeTabBackground))
    }
}

// MARK: - 10. PacingNeedle
/// An analog-style pacing needle depicting completion speed relative to capacity limiters.
public struct PacingNeedle: View {
    @Environment(\.ambitionTheme) private var theme
    let completionRate: Double

    public init(completionRate: Double) {
        self.completionRate = completionRate
    }

    public var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(theme.colors.textTertiary.opacity(0.38), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-180))
                .frame(width: 80, height: 80)
            
            Capsule()
                .fill(theme.colors.textPrimary)
                .frame(width: 4, height: 35)
                .offset(y: -15)
                .rotationEffect(.degrees(-90 + (180 * completionRate)))
        }
        .frame(width: 90, height: 50)
    }
}

// MARK: - 11. ProofPulseBadge
/// A live pulsating badge representing verified user evidence.
#endif
