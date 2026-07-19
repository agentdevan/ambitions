#if canImport(SwiftUI)
import SwiftUI

public struct ProofPulseBadge: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 1.0

    public init() {}

    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            Circle()
                .fill(theme.semanticColors.accessibilityVerified)
                .frame(width: 8, height: 8)
                .scaleEffect(reduceMotion ? 1.0 : scale)
            
            Text("VERIFIED")
                .font(theme.typography.caption.bold())
                .foregroundStyle(theme.semanticColors.accessibilityVerified)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Proof pulse badge")
        .accessibilityValue(accessibilityValue)
        .onAppear {
            guard reduceMotion == false else {
                scale = 1.0
                return
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.38
            }
        }
    }

    public var accessibilityValue: String {
        "Verified. Reduce Motion: static badge and label. Non-color cue: the text stays visible alongside the symbol."
    }
}

// MARK: - 12. AuditFoldOut
/// An accordion-like layout for transparently disclosing on-device audit logs.
public struct AuditFoldOut: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isOpen: Bool = false
    let title: String
    let logs: [String]

    public init(title: String, logs: [String]) {
        self.title = title
        self.logs = logs
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Button(action: {
                if reduceMotion {
                    isOpen.toggle()
                } else {
                    withAnimation(.spring()) {
                        isOpen.toggle()
                    }
                }
            }) {
                HStack {
                    Text(title)
                        .font(theme.typography.bodyEmphasized)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                }
            }
            .foregroundStyle(theme.colors.textPrimary)
            .accessibilityLabel(title)
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Double tap to \(isOpen ? "hide" : "show") the audit logs.")
            .ambitionMinimumTapTarget(theme.panel.minimumTapTarget)
            
            if isOpen {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logs, id: \.self) { log in
                        Text("• \(log)")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        }
                }
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md).fill(theme.shell.controlBackground))
    }

    public var accessibilityValue: String {
        isOpen ? "Open. \(logs.count) log entries visible." : "Closed. \(logs.count) log entries hidden."
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
    let stressScore: Double

    public init(stressScore: Double) {
        self.stressScore = stressScore
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            HStack {
                Image(systemName: isOvercommitted ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                    .foregroundStyle(isOvercommitted ? theme.shell.statusAtRisk : theme.shell.statusClear)
                Text("Planning Tension")
                    .font(theme.typography.caption.bold())
                Spacer()
                Text(isOvercommitted ? "Overcommitted" : "Healthy")
                    .font(theme.typography.caption)
                    .foregroundStyle(isOvercommitted ? theme.shell.statusAtRisk : theme.shell.statusClear)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.colors.textTertiary.opacity(0.38))
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isOvercommitted ? theme.shell.statusAtRisk : theme.shell.statusClear)
                        .frame(width: geo.size.width * CGFloat(stressScore))
                }
            }
            .frame(height: 6)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Planning tension")
        .accessibilityValue(accessibilityValue)
    }

    var isOvercommitted: Bool {
        stressScore > 0.8
    }

    public var accessibilityValue: String {
        "\(isOvercommitted ? "Overcommitted" : "Healthy"). \(Int((stressScore * 100).rounded())) percent. Non-color cue: the symbol and text carry the state."
    }
}

// MARK: - 16. ContextPathPill
/// An orientation badge detailing how a user arrived at their active screen.
public struct ContextPathPill: View {
    @Environment(\.ambitionTheme) private var theme
    let path: String

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
    let varianceLabel: String

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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var isOn: Bool
    let title: String

    public init(title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    public var body: some View {
        Button(action: {
            if reduceMotion {
                isOn.toggle()
            } else {
                withAnimation(.spring()) {
                    isOn.toggle()
                }
            }
        }) {
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
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityHint("Double tap to toggle.")
        .ambitionMinimumTapTarget(theme.panel.minimumTapTarget)
    }

    public var accessibilityValue: String {
        isOn ? "On" : "Off"
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
