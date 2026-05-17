#if canImport(SwiftUI)
import SwiftUI
import Combine

// MARK: - 1. AfiFlowIndicator
/// A micro-visualizer representing the current Active Focus Interval (AFI) flow density.
public struct AfiFlowIndicator: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var waveOffset: CGFloat = 0
    private let intensity: Double

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
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                waveOffset = 1.0
            }
        }
    }

    private func height(for index: Int) -> CGFloat {
        let base = CGFloat(4 + (index * 3))
        return base + (waveOffset * CGFloat(index + 1) * CGFloat(intensity))
    }
}

// MARK: - 2. MeridianScaleAxis
/// A ruler-like tactile axis indicating where in the Reality Meridian a goal sits.
public struct MeridianScaleAxis: View {
    @Environment(\.ambitionTheme) private var theme
    private let alignmentPosition: Double

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
    @State private var pulse: CGFloat = 0.38
    private let title: String

    public init(title: String = "LOCAL ONLY") {
        self.title = title
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Circle()
                .fill(theme.semanticColors.trust)
                .frame(width: 8, height: 8)
                .scaleEffect(1.0 + (pulse * 0.4))
                .opacity(1.0 - (pulse * 0.5))
            
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = 1.0
            }
        }
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
            }
            
            Button(action: { threshold = min(1.0, threshold + 0.1) }) {
                Image(systemName: "plus.circle")
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
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
    @Environment(\.ambitionTheme) private var theme
    private let explanation: String

    public init(explanation: String) {
        self.explanation = explanation
    }

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "sparkles")
                .foregroundStyle(theme.semanticColors.recovery)
            
            Text(explanation)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .fill(theme.semanticColors.recovery.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md)
                .stroke(theme.semanticColors.recovery.opacity(0.34), lineWidth: 1)
        )
    }
}

// MARK: - 8. AnchorDotMeter
/// A micro-grid showing anchor-time availability status.
public struct AnchorDotMeter: View {
    @Environment(\.ambitionTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<8) { index in
                Circle()
                    .fill(index < 5 ? theme.shell.statusClear : theme.colors.textTertiary.opacity(0.4))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - 9. ConfidenceBadge
/// A beautiful badge displaying recommendation alignment certainty.
public struct ConfidenceBadge: View {
    @Environment(\.ambitionTheme) private var theme
    private let score: Double

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
    private let completionRate: Double

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
public struct ProofPulseBadge: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var scale: CGFloat = 1.0

    public init() {}

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Circle()
                .fill(theme.semanticColors.success)
                .frame(width: 8, height: 8)
                .scaleEffect(scale)
            
            Text("VERIFIED")
                .font(theme.typography.caption.bold())
                .foregroundStyle(theme.semanticColors.success)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.38
            }
        }
    }
}

// MARK: - 12. AuditFoldOut
/// An accordion-like layout for transparently disclosing on-device audit logs.
public struct AuditFoldOut: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var isOpen: Bool = false
    private let title: String
    private let logs: [String]

    public init(title: String, logs: [String]) {
        self.title = title
        self.logs = logs
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Button(action: { withAnimation(.spring()) { isOpen.toggle() } }) {
                HStack {
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                }
            }
            .foregroundStyle(theme.colors.textPrimary)
            
            if isOpen {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logs, id: \.self) { log in
                        Text("• \(log)")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md).fill(theme.shell.controlBackground))
    }
}

// MARK: - 13. MicroTickRuler
/// A focus tick ruler depicting hourly increments.
public struct MicroTickRuler: View {
    @Environment(\.ambitionTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<24) { hour in
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(theme.colors.textTertiary)
                        .frame(width: 1, height: hour % 4 == 0 ? 12 : 6)
                    if hour % 4 == 0 {
                        Text(String(format: "%02d", hour))
                            .font(.system(size: 8))
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
                if hour != 23 { Spacer() }
            }
        }
        .padding(.vertical, theme.spacing.xs)
    }
}

// MARK: - 14. VacationBanner
/// An premium protected vacation banner that keeps automated planning paused.
public struct VacationBanner: View {
    @Environment(\.ambitionTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "airplane")
                .font(.title3)
                .foregroundStyle(theme.shell.statusProtected)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("VACATION AWAY ACTIVE")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Day plans are held quiet; no active tasks scheduled until recovery.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.md).fill(theme.shell.ribbonMaterial))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md).stroke(theme.shell.divider, lineWidth: 1))
    }
}

// MARK: - 15. CapacitiveTensionBar
/// A spring-feeling tension bar showing day-level planning stress.
public struct CapacitiveTensionBar: View {
    @Environment(\.ambitionTheme) private var theme
    private let stressScore: Double

    public init(stressScore: Double) {
        self.stressScore = stressScore
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack {
                Text("Planning Tension")
                    .font(theme.typography.caption.bold())
                Spacer()
                Text(stressScore > 0.8 ? "Overcommitted" : "Healthy")
                    .font(theme.typography.caption)
                    .foregroundStyle(stressScore > 0.8 ? theme.shell.statusAtRisk : theme.shell.statusClear)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.colors.textTertiary.opacity(0.38))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(stressScore > 0.8 ? theme.shell.statusAtRisk : theme.shell.statusClear)
                        .frame(width: geo.size.width * CGFloat(stressScore))
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - 16. ContextPathPill
/// An orientation badge detailing how a user arrived at their active screen.
public struct ContextPathPill: View {
    @Environment(\.ambitionTheme) private var theme
    private let path: String

    public init(path: String) {
        self.path = path
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xxs) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 10))
            Text(path.uppercased())
                .font(theme.typography.caption.bold())
        }
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, 4)
        .foregroundStyle(theme.colors.textSecondary)
        .background(Capsule().fill(theme.shell.controlBackground))
    }
}

// MARK: - 17. OnDeviceBadge
/// A dynamic on-device badge guaranteeing that data never leaves the device.
public struct OnDeviceBadge: View {
    @Environment(\.ambitionTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: theme.spacing.xxs) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 10))
                .foregroundStyle(theme.semanticColors.trust)
            Text("SECURE ON-DEVICE")
                .font(theme.typography.caption.bold())
                .foregroundStyle(theme.semanticColors.trust)
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, 3)
        .background(Capsule().fill(theme.shell.trustBadgeSurface))
    }
}

// MARK: - 18. UncertaintyIndicator
/// A calm, dotted visual indicating recommendation variance to build user trust.
public struct UncertaintyIndicator: View {
    @Environment(\.ambitionTheme) private var theme
    private let varianceLabel: String

    public init(varianceLabel: String = "Variance +- 10m") {
        self.varianceLabel = varianceLabel
    }

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(theme.colors.textTertiary)
            
            Text(varianceLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.horizontal, theme.spacing.sm)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .stroke(theme.colors.textTertiary.opacity(0.38), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [2, 2]))
        )
    }
}

// MARK: - 19. TactileToggleSeam
/// A highly interactive toggle switch designed like a physical design system seam.
public struct TactileToggleSeam: View {
    @Environment(\.ambitionTheme) private var theme
    @Binding private var isOn: Bool
    private let title: String

    public init(title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    public var body: some View {
        Button(action: { withAnimation(.spring()) { isOn.toggle() } }) {
            HStack {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                
                Spacer()
                
                ZStack(alignment: isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(isOn ? theme.shell.statusClear : theme.colors.textTertiary.opacity(0.38))
                        .frame(width: 44, height: 24)
                    
                    Circle()
                        .fill(theme.colors.textPrimary)
                        .frame(width: 20, height: 20)
                        .padding(.horizontal, 2)
                }
            }
        }
        .ambitionMinimumTapTarget(theme.panel.minimumTapTarget)
    }
}

// MARK: - 20. FrictionGateBadge
/// A protective confirm-first badge preventing silent automatic changes.
public struct FrictionGateBadge: View {
    @Environment(\.ambitionTheme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: theme.spacing.xxs) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 10))
                .foregroundStyle(theme.semanticColors.risk)
            Text("CONFIRM FIRST")
                .font(theme.typography.caption.bold())
                .foregroundStyle(theme.semanticColors.risk)
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, 3)
        .background(Capsule().fill(theme.semanticColors.risk.opacity(0.12)))
    }
}
#endif
