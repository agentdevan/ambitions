#if canImport(SwiftUI)
import SwiftUI

public struct ProofPulse: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool
    let label: String

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

    let title: String
    let detail: String?
    let source: String?
    let state: LivingVisualState
    let context: LivingTabContext

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

    var accessibilitySummary: String {
        [title, detail, source].compactMap { $0 }.joined(separator: ". ")
    }
}

public struct StateDrivenMaterialPanel<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let context: LivingTabContext
    let state: LivingVisualState
    let content: Content

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

    let title: String
    let subtitle: String?
    let context: LivingTabContext
    let state: LivingVisualState
    let evidence: String?
    let content: Content

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

    var accessibilitySummary: String {
        [title, subtitle, evidence].compactMap { $0 }.joined(separator: ". ")
    }
}

public struct QuietCommandSurface<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let placeholder: String
    let detail: String?
    let context: LivingTabContext
    let content: Content

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
#endif
