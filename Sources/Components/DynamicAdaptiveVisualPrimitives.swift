#if canImport(SwiftUI)
import SwiftUI

public enum LivingTabContext: String, CaseIterable, Identifiable, Sendable {
    case today
    case goals
    case capture
    case plan
    case motion
    case you
    case memory
    case trust

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .capture: "Capture"
        case .plan: "Time"
        case .motion: "Motion"
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
        case .plan: "clock"
        case .motion: "point.topleft.down.curvedto.point.bottomright.up"
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
        case .motion: theme.semanticColors.trust
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

    public var stateMeaning: String {
        switch self {
        case .subtlePulse:
            return "A proof or attention state became visible."
        case .softReveal:
            return "A surface or module became available without changing ownership."
        case .railProgress:
            return "A timeline or ordered rail advanced to a new visible state."
        case .receiptConfirmation:
            return "A receipt, proof, or safety confirmation settled."
        case .heroExpansion:
            return "A primary visual object expanded into the working context."
        case .stateSettle:
            return "A module reached a stable state after data or selection changed."
        }
    }

    public var reduceMotionEquivalent: String {
        switch self {
        case .subtlePulse:
            return "Static state label with proof or attention icon."
        case .softReveal:
            return "Opacity-only or instant reveal with the same label and hierarchy."
        case .railProgress:
            return "Static rail position, progress label, and accessible value."
        case .receiptConfirmation:
            return "Static receipt/proof state with source and undo or correction labels."
        case .heroExpansion:
            return "Direct focus or navigation with the destination title preserved."
        case .stateSettle:
            return "Immediate stable module state with non-color label."
        }
    }

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
                    .frame(width: proxy.size.width * primaryScale, height: proxy.size.width * primaryScale)
                    .offset(x: proxy.size.width * primaryOffset.x, y: proxy.size.height * primaryOffset.y)
                    .blur(radius: 38)

                Circle()
                    .fill(theme.colors.canvas.opacity(0.03 + 0.02 * intensity))
                    .frame(width: proxy.size.width * secondaryScale, height: proxy.size.width * secondaryScale)
                    .offset(x: proxy.size.width * secondaryOffset.x, y: proxy.size.height * secondaryOffset.y)
                    .blur(radius: 48)

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

    private var primaryScale: CGFloat {
        switch context {
        case .today: 0.88
        case .goals: 0.82
        case .capture: 0.84
        case .motion: 0.86
        case .plan: 0.90
        case .you: 0.80
        case .memory: 0.84
        case .trust: 0.78
        }
    }

    private var secondaryScale: CGFloat {
        switch context {
        case .today: 0.34
        case .goals: 0.28
        case .capture: 0.26
        case .motion: 0.25
        case .plan: 0.30
        case .you: 0.24
        case .memory: 0.26
        case .trust: 0.22
        }
    }

    private var primaryOffset: CGPoint {
        switch state {
        case .calm, .empty: baseOffset
        case .active, .proof: CGPoint(x: baseOffset.x - 0.10, y: baseOffset.y - 0.06)
        case .pressured, .stale: CGPoint(x: baseOffset.x - 0.16, y: baseOffset.y + 0.04)
        case .recovery: CGPoint(x: baseOffset.x - 0.04, y: baseOffset.y + 0.10)
        case .sensitive: CGPoint(x: baseOffset.x + 0.02, y: baseOffset.y + 0.06)
        }
    }

    private var secondaryOffset: CGPoint {
        switch context {
        case .today: CGPoint(x: 0.08, y: 0.24)
        case .goals: CGPoint(x: 0.62, y: 0.18)
        case .capture: CGPoint(x: 0.14, y: 0.30)
        case .motion: CGPoint(x: 0.58, y: 0.20)
        case .plan: CGPoint(x: 0.66, y: 0.16)
        case .you: CGPoint(x: 0.50, y: 0.04)
        case .memory: CGPoint(x: 0.24, y: 0.10)
        case .trust: CGPoint(x: 0.56, y: 0.28)
        }
    }

    private var baseOffset: CGPoint {
        switch context {
        case .today: CGPoint(x: 0.42, y: 0.02)
        case .goals: CGPoint(x: 0.24, y: 0.06)
        case .capture: CGPoint(x: 0.56, y: 0.03)
        case .motion: CGPoint(x: 0.48, y: 0.06)
        case .plan: CGPoint(x: 0.34, y: 0.10)
        case .you: CGPoint(x: 0.46, y: 0.12)
        case .memory: CGPoint(x: 0.36, y: 0.00)
        case .trust: CGPoint(x: 0.50, y: 0.14)
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

        QuietGlass(cornerRadius: theme.radius.lg) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                content
            }
            .padding(theme.spacing.lg)
        }
        .luminousTrace(isShimmering: state == .active, accentColor: accent)
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(accent.opacity(0.14))
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

public enum ContextRecallState: String, CaseIterable, Identifiable, Sendable {
    case current
    case stale
    case rejected
    case sensitive
    case corrected
    case noResult

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .current: "Current"
        case .stale: "Needs Review"
        case .rejected: "Rejected"
        case .sensitive: "Sensitive"
        case .corrected: "Corrected"
        case .noResult: "No Hidden Memory"
        }
    }

    public var symbolName: String {
        switch self {
        case .current: "checkmark.seal"
        case .stale: "clock.badge.exclamationmark"
        case .rejected: "xmark.shield"
        case .sensitive: "hand.raised"
        case .corrected: "pencil.and.scribble"
        case .noResult: "eye.slash"
        }
    }

    public var livingState: LivingVisualState {
        switch self {
        case .current, .corrected:
            return .proof
        case .stale:
            return .stale
        case .rejected:
            return .recovery
        case .sensitive:
            return .sensitive
        case .noResult:
            return .empty
        }
    }
}

public struct ContextRecallSurface: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let summary: String
    private let sourceLabel: String
    private let confidenceLabel: String
    private let state: ContextRecallState
    private let context: LivingTabContext
    private let controls: [String]

    public init(
        title: String,
        summary: String,
        sourceLabel: String,
        confidenceLabel: String,
        state: ContextRecallState,
        context: LivingTabContext = .memory,
        controls: [String] = []
    ) {
        self.title = title
        self.summary = summary
        self.sourceLabel = sourceLabel
        self.confidenceLabel = confidenceLabel
        self.state = state
        self.context = context
        self.controls = controls
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: context, state: state.livingState) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: state.symbolName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(context.accent(in: theme))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(context.accent(in: theme).opacity(0.12)))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(state.title)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(context.accent(in: theme))
                    Text(title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(summary)
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.xs)
            }

            FlowEvidenceLabels(
                labels: [
                    EvidenceLabel(sourceLabel, detail: "Source visible", state: state.livingState, context: context),
                    EvidenceLabel(confidenceLabel, detail: "No hidden certainty", state: state.livingState, context: .trust)
                ]
            )

            if controls.isEmpty == false {
                QuietCommandSurface(
                    placeholder: "Review controls",
                    detail: controls.joined(separator: " · "),
                    context: .trust
                ) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        [state.title, title, summary, sourceLabel, confidenceLabel, controls.joined(separator: ", ")]
            .filter { $0.isEmpty == false }
            .joined(separator: ". ")
    }
}

@available(*, deprecated, renamed: "ContextRecallSurface")
public typealias ContextRecallCard = ContextRecallSurface

public struct MemoryConstellationNode: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let detail: String
    public let state: ContextRecallState

    public init(id: String, title: String, detail: String, state: ContextRecallState) {
        self.id = id
        self.title = title
        self.detail = detail
        self.state = state
    }
}

public struct MemoryConstellation: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: String
    private let subtitle: String
    private let nodes: [MemoryConstellationNode]

    public init(title: String, subtitle: String, nodes: [MemoryConstellationNode]) {
        self.title = title
        self.subtitle = subtitle
        self.nodes = nodes
    }

    public var body: some View {
        StateDrivenMaterialPanel(context: .memory, state: .calm) {
            SectionHeader(eyebrow: "Memory map", title: title, subtitle: subtitle)

            VStack(spacing: theme.spacing.sm) {
                HStack(alignment: .center, spacing: theme.spacing.xs) {
                    ForEach(nodes) { node in
                        MemoryConstellationNodeView(node: node)
                    }
                }

                Capsule(style: .continuous)
                    .fill(theme.semanticColors.trust.opacity(0.28))
                    .frame(height: 1)
                    .overlay(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(theme.semanticColors.protected.opacity(reduceMotion ? 0.28 : 0.42))
                            .frame(maxWidth: .infinity)
                    }
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(subtitle). \(nodes.count) visible memory states.")
    }
}

private struct MemoryConstellationNodeView: View {
    @Environment(\.ambitionTheme) private var theme

    let node: MemoryConstellationNode

    var body: some View {
        VStack(spacing: theme.spacing.xxs) {
            Image(systemName: node.state.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(node.state == .sensitive ? theme.semanticColors.protected : theme.semanticColors.trust)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(theme.colors.surfaceOverlay)
                        .overlay(Circle().strokeBorder(theme.semanticColors.trust.opacity(0.24), lineWidth: 1))
                )
                .accessibilityHidden(true)

            Text(node.title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(node.detail)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, minHeight: 104)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(node.title). \(node.detail). \(node.state.title).")
    }
}

private struct FlowEvidenceLabels: View {
    @Environment(\.ambitionTheme) private var theme

    let labels: [EvidenceLabel]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(labels.indices, id: \.self) { index in
                labels[index]
            }
        }
    }
}

public enum TrustReceiptVisualState: String, CaseIterable, Identifiable, Sendable {
    case proofSaved
    case correction
    case undo
    case staleSource
    case blocked
    case empty

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .proofSaved: "Proof saved"
        case .correction: "Correction visible"
        case .undo: "Undo available"
        case .staleSource: "Source may need review"
        case .blocked: "Blocked safely"
        case .empty: "No receipts"
        }
    }

    public var livingState: LivingVisualState {
        switch self {
        case .proofSaved, .correction, .undo:
            return .proof
        case .staleSource:
            return .stale
        case .blocked:
            return .pressured
        case .empty:
            return .empty
        }
    }

    public var symbolName: String {
        switch self {
        case .proofSaved: "checkmark.seal.fill"
        case .correction: "checkmark.bubble"
        case .undo: "arrow.uturn.backward.circle"
        case .staleSource: "clock.badge.exclamationmark"
        case .blocked: "exclamationmark.shield"
        case .empty: "tray"
        }
    }
}

public struct TrustReceiptStackItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let summary: String
    public let sourceLabel: String
    public let freshnessLabel: String
    public let undoLabel: String
    public let correctionLabel: String
    public let nextActionLabel: String?
    public let state: TrustReceiptVisualState

    public init(
        id: String,
        title: String,
        summary: String,
        sourceLabel: String,
        freshnessLabel: String,
        undoLabel: String,
        correctionLabel: String,
        nextActionLabel: String? = nil,
        state: TrustReceiptVisualState
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.sourceLabel = sourceLabel
        self.freshnessLabel = freshnessLabel
        self.undoLabel = undoLabel
        self.correctionLabel = correctionLabel
        self.nextActionLabel = nextActionLabel
        self.state = state
    }
}

public struct TrustReceiptStack: View {
    @Environment(\.ambitionTheme) private var theme

    private let title: String
    private let subtitle: String
    private let items: [TrustReceiptStackItem]

    public init(
        title: String = "Trust receipts",
        subtitle: String = "Privacy-safe summaries of what changed, why, and what can be corrected or undone.",
        items: [TrustReceiptStackItem]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }

    public var body: some View {
        AdaptiveModuleChrome(
            title: title,
            subtitle: subtitle,
            context: .trust,
            state: items.isEmpty ? .empty : .proof,
            evidence: items.isEmpty ? "No receipt is shown without source evidence" : "\(items.count) source-bound receipts"
        ) {
            if items.isEmpty {
                TrustReceiptEmptyState()
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        TrustReceiptStackRow(item: item)
                    }
                }
            }
        }
        .accessibilityIdentifier("trust.receipt-stack")
    }
}

private struct TrustReceiptEmptyState: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        QuietCommandSurface(
            placeholder: "No receipts to show",
            detail: "Ambitions should say when there is no audit trail instead of implying hidden proof.",
            context: .trust
        ) {
            ProofPulse(isActive: false, label: "No proof receipt visible")
        }
    }
}

private struct TrustReceiptStackRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TrustReceiptStackItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                ProofPulse(isActive: item.state == .proofSaved || item.state == .correction || item.state == .undo, label: item.state.title)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.summary)
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let nextActionLabel = item.nextActionLabel {
                        Text(nextActionLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: theme.spacing.xs)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                EvidenceLabel(item.sourceLabel, detail: "Action source", state: item.state.livingState, context: .trust)
                EvidenceLabel(item.freshnessLabel, detail: "Source freshness", state: item.state.livingState, context: .memory)
            }

            QuietCommandSurface(
                placeholder: "Correction and undo",
                detail: "\(item.correctionLabel). \(item.undoLabel).",
                context: .trust
            ) {
                Image(systemName: item.state.symbolName)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .strokeBorder(theme.semanticColors.protected.opacity(0.22), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        [
            item.state.title,
            item.title,
            item.summary,
            item.sourceLabel,
            item.freshnessLabel,
            item.correctionLabel,
            item.undoLabel,
            item.nextActionLabel
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
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
