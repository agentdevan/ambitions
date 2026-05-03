#if canImport(SwiftUI)
import SwiftUI

public enum LivingTabContext: String, CaseIterable, Identifiable, Sendable {
    case today
    case goals
    case capture
    case plan
    case you
    case memory
    case trust

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .capture: "Capture"
        case .plan: "Plan"
        case .you: "You"
        case .memory: "Memory"
        case .trust: "Trust"
        }
    }

    public var symbolName: String {
        switch self {
        case .today: "sun.max"
        case .goals: "scope"
        case .capture: "plus.circle"
        case .plan: "calendar"
        case .you: "person.crop.circle"
        case .memory: "sparkle.magnifyingglass"
        case .trust: "checkmark.shield"
        }
    }

    public func accent(in theme: AmbitionTheme) -> Color {
        switch self {
        case .today: theme.semanticColors.focus
        case .goals: theme.colors.accentPrimary
        case .capture: theme.semanticColors.capture
        case .plan: theme.semanticColors.calendarDerived
        case .you: theme.semanticColors.review
        case .memory: theme.semanticColors.trust
        case .trust: theme.semanticColors.protected
        }
    }
}

public enum LivingVisualState: String, CaseIterable, Sendable {
    case calm
    case active
    case pressured
    case proof
    case recovery
    case sensitive
    case stale
    case empty

    public var title: String {
        switch self {
        case .calm: "Calm"
        case .active: "Active"
        case .pressured: "Pressure visible"
        case .proof: "Proof visible"
        case .recovery: "Recovery"
        case .sensitive: "Sensitive"
        case .stale: "Needs review"
        case .empty: "Ready"
        }
    }

    public var ambitionState: AmbitionVisualState {
        switch self {
        case .calm, .empty: .default
        case .active: .selected
        case .pressured, .stale: .warning
        case .proof: .success
        case .recovery: .celebration
        case .sensitive: .loading
        }
    }
}

public enum DAVMotionPreset: String, CaseIterable, Sendable {
    case subtlePulse
    case softReveal
    case railProgress
    case receiptConfirmation
    case heroExpansion
    case stateSettle

    public func animation(theme: AmbitionTheme, reduceMotion: Bool) -> Animation? {
        guard reduceMotion == false else { return nil }

        switch self {
        case .subtlePulse:
            return .easeInOut(duration: theme.timing.settle)
        case .softReveal:
            return theme.motion.animation(reduceMotion: false)
        case .railProgress:
            return .spring(response: theme.timing.regular, dampingFraction: 0.90)
        case .receiptConfirmation:
            return theme.motion.animation(reduceMotion: false, emphasis: true)
        case .heroExpansion:
            return .spring(response: theme.timing.emphasis, dampingFraction: 0.88)
        case .stateSettle:
            return theme.motion.settleAnimation(reduceMotion: false)
        }
    }

    public func transition(reduceMotion: Bool) -> AnyTransition {
        guard reduceMotion == false else { return .opacity }

        switch self {
        case .subtlePulse, .stateSettle:
            return .opacity
        case .softReveal:
            return .opacity.combined(with: .scale(scale: 0.985, anchor: .top))
        case .railProgress:
            return .opacity.combined(with: .move(edge: .leading))
        case .receiptConfirmation:
            return .opacity.combined(with: .scale(scale: 0.975, anchor: .center))
        case .heroExpansion:
            return .opacity.combined(with: .scale(scale: 0.98, anchor: .top))
        }
    }
}

public struct LivingSurfaceBackground: View {
    @Environment(\.ambitionTheme) private var theme

    private let context: LivingTabContext
    private let state: LivingVisualState
    private let intensity: Double

    public init(
        context: LivingTabContext,
        state: LivingVisualState = .calm,
        intensity: Double = 1
    ) {
        self.context = context
        self.state = state
        self.intensity = max(0, min(intensity, 1))
    }

    public var body: some View {
        ZStack {
            theme.surfaces.canvasGradient
            ContextAtmosphereLayer(context: context, state: state, intensity: intensity)
        }
        .accessibilityHidden(true)
    }
}

public struct ContextAtmosphereLayer: View {
    @Environment(\.ambitionTheme) private var theme

    private let context: LivingTabContext
    private let state: LivingVisualState
    private let intensity: Double

    public init(
        context: LivingTabContext,
        state: LivingVisualState = .calm,
        intensity: Double = 1
    ) {
        self.context = context
        self.state = state
        self.intensity = max(0, min(intensity, 1))
    }

    public var body: some View {
        let accent = context.accent(in: theme)
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Circle()
                    .fill(accent.opacity(0.10 + 0.08 * intensity))
                    .frame(width: proxy.size.width * 0.86, height: proxy.size.width * 0.86)
                    .offset(x: proxy.size.width * stateOffset.x, y: proxy.size.height * stateOffset.y)
                    .blur(radius: 38)

                LinearGradient(
                    colors: [
                        accent.opacity(0.08 * intensity),
                        theme.colors.canvas.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var stateOffset: CGPoint {
        switch state {
        case .calm, .empty: CGPoint(x: 0.46, y: 0.04)
        case .active, .proof: CGPoint(x: 0.34, y: -0.02)
        case .pressured, .stale: CGPoint(x: 0.26, y: 0.08)
        case .recovery: CGPoint(x: 0.42, y: 0.14)
        case .sensitive: CGPoint(x: 0.52, y: 0.10)
        }
    }
}

public struct PressureGlow: View {
    @Environment(\.ambitionTheme) private var theme

    private let level: Double
    private let context: LivingTabContext
    private let label: String

    public init(level: Double, context: LivingTabContext = .today, label: String = "Pressure") {
        self.level = max(0, min(level, 1))
        self.context = context
        self.label = label
    }

    public var body: some View {
        let accent = level > 0.72 ? theme.semanticColors.risk : context.accent(in: theme)

        Capsule()
            .fill(accent.opacity(0.10 + level * 0.16))
            .overlay {
                Capsule()
                    .strokeBorder(accent.opacity(0.22 + level * 0.28), lineWidth: 1)
            }
            .frame(height: 8)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(accent.opacity(0.72))
                    .frame(width: max(14, CGFloat(level) * 160), height: 8)
            }
            .accessibilityLabel(label)
            .accessibilityValue("\(Int(level * 100)) percent")
    }
}

public struct ProofPulse: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let isActive: Bool
    private let label: String

    public init(isActive: Bool = false, label: String = "Proof visible") {
        self.isActive = isActive
        self.label = label
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(theme.semanticColors.protected.opacity(isActive ? 0.24 : 0.10))
                .frame(width: 34, height: 34)

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.semanticColors.protected)
        }
        .scaleEffect(isActive && reduceMotion == false ? 1.04 : 1)
        .animation(DAVMotionPreset.receiptConfirmation.animation(theme: theme, reduceMotion: reduceMotion), value: isActive)
        .accessibilityLabel(label)
    }
}

public struct EvidenceLabel: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let detail: String?
    private let source: String?
    private let state: LivingVisualState
    private let context: LivingTabContext

    public init(
        _ title: String,
        detail: String? = nil,
        source: String? = nil,
        state: LivingVisualState = .calm,
        context: LivingTabContext = .trust
    ) {
        self.title = title
        self.detail = detail
        self.source = source
        self.state = state
        self.context = context
    }

    public var body: some View {
        let accent = context.accent(in: theme)

        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xxs) {
            Image(systemName: state == .stale ? "clock.badge.exclamationmark" : "checkmark.seal")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)

                if let detail {
                    Text(detail)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let source {
                    Text(source)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxs)
        .background(
            Capsule(style: .continuous)
                .fill(accent.opacity(0.10))
        )
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(accent.opacity(0.24), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        [title, detail, source].compactMap { $0 }.joined(separator: ". ")
    }
}

public struct StateDrivenMaterialPanel<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let context: LivingTabContext
    private let state: LivingVisualState
    private let content: Content

    public init(
        context: LivingTabContext,
        state: LivingVisualState = .calm,
        @ViewBuilder content: () -> Content
    ) {
        self.context = context
        self.state = state
        self.content = content()
    }

    public var body: some View {
        let accent = context.accent(in: theme)
        let shape = RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)

        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            content
        }
        .padding(theme.spacing.lg)
        .background {
            shape.fill(theme.surfaces.elevatedGradient)
        }
        .overlay(alignment: .topLeading) {
            shape
                .strokeBorder(accent.opacity(state == .active ? 0.42 : 0.22), lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(accent.opacity(0.18))
                .frame(width: 74, height: 74)
                .blur(radius: 24)
                .offset(x: 18, y: -18)
                .accessibilityHidden(true)
        }
        .shadow(color: theme.depth.resting.color, radius: theme.depth.resting.radius, x: theme.depth.resting.x, y: theme.depth.resting.y)
        .accessibilityElement(children: .contain)
    }
}

public struct AdaptiveModuleChrome<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String?
    private let context: LivingTabContext
    private let state: LivingVisualState
    private let evidence: String?
    private let content: Content

    public init(
        title: String,
        subtitle: String? = nil,
        context: LivingTabContext,
        state: LivingVisualState = .calm,
        evidence: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.context = context
        self.state = state
        self.evidence = evidence
        self.content = content()
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: context, state: state) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: context.symbolName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(context.accent(in: theme))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(context.accent(in: theme).opacity(0.12)))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .font(theme.typography.bodySecondary)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: theme.spacing.xs)
            }

            content

            if let evidence {
                EvidenceLabel(evidence, context: context)
            }
        }
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        [title, subtitle, evidence].compactMap { $0 }.joined(separator: ". ")
    }
}

public struct QuietCommandSurface<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    private let placeholder: String
    private let detail: String?
    private let context: LivingTabContext
    private let content: Content

    public init(
        placeholder: String,
        detail: String? = nil,
        context: LivingTabContext = .capture,
        @ViewBuilder content: () -> Content
    ) {
        self.placeholder = placeholder
        self.detail = detail
        self.context = context
        self.content = content()
    }

    public var body: some View {
        let accent = context.accent(in: theme)

        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: context == .capture ? "mic" : context.symbolName)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(accent.opacity(0.12)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(placeholder)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let detail {
                    Text(detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: theme.spacing.xs)
            content
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.pill, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.pill, style: .continuous)
                .strokeBorder(accent.opacity(0.26), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel([placeholder, detail].compactMap { $0 }.joined(separator: ". "))
    }
}

public struct GroupedNavigationSystemItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let symbolName: String
    public let state: LivingVisualState
    public let statusLabel: String?

    public init(
        id: String,
        title: String,
        subtitle: String,
        symbolName: String,
        state: LivingVisualState = .calm,
        statusLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbolName = symbolName
        self.state = state
        self.statusLabel = statusLabel
    }
}

public struct GroupedNavigationSystemSection: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let items: [GroupedNavigationSystemItem]

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        items: [GroupedNavigationSystemItem]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }
}

public struct GroupedNavigationSystem: View {
    @Environment(\.ambitionTheme) private var theme

    private let sections: [GroupedNavigationSystemSection]
    private let context: LivingTabContext
    private let accessibilityIdentifierPrefix: String?
    private let onSelect: ((GroupedNavigationSystemItem) -> Void)?

    public init(
        sections: [GroupedNavigationSystemSection],
        context: LivingTabContext = .you,
        accessibilityIdentifierPrefix: String? = nil,
        onSelect: ((GroupedNavigationSystemItem) -> Void)? = nil
    ) {
        self.sections = sections
        self.context = context
        self.accessibilityIdentifierPrefix = accessibilityIdentifierPrefix
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(section.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)

                        if let subtitle = section.subtitle {
                            Text(subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: theme.spacing.xxs) {
                        ForEach(section.items) { item in
                            row(for: item)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(section.title)
            }
        }
    }

    @ViewBuilder
    private func row(for item: GroupedNavigationSystemItem) -> some View {
        let accent = item.state == .calm ? context.accent(in: theme) : theme.stateStyle(for: item.state.ambitionState).accent

        let rowContent = HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: item.symbolName)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(accent.opacity(0.12)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            if let statusLabel = item.statusLabel {
                Text(statusLabel)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxxs)
                    .background(Capsule(style: .continuous).fill(accent.opacity(0.10)))
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(accent.opacity(0.18), lineWidth: 1)
                    }
                    .accessibilityHidden(true)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .strokeBorder(accent.opacity(0.18), lineWidth: 1)
        }
        .ambitionMinimumTapTarget()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary(for: item))
        .modifier(GroupedNavigationSystemIdentifier(identifier: accessibilityIdentifier(for: item)))

        if let onSelect {
            Button {
                onSelect(item)
            } label: {
                rowContent
            }
            .buttonStyle(GroupedNavigationSystemButtonStyle())
        } else {
            rowContent
        }
    }

    private func accessibilitySummary(for item: GroupedNavigationSystemItem) -> String {
        [item.title, item.subtitle, item.statusLabel, item.state.title]
            .compactMap { $0 }
            .joined(separator: ". ")
    }

    private func accessibilityIdentifier(for item: GroupedNavigationSystemItem) -> String? {
        guard let accessibilityIdentifierPrefix else { return nil }
        return "\(accessibilityIdentifierPrefix).\(item.id)"
    }
}

private struct GroupedNavigationSystemButtonStyle: ButtonStyle {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && reduceMotion == false ? 0.992 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(theme.motion.settleAnimation(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}

private struct GroupedNavigationSystemIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}
#endif
