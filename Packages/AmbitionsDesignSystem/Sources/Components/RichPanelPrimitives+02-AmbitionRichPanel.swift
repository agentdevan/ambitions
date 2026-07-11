#if canImport(SwiftUI)
import SwiftUI

public struct AmbitionRichPanel<VisualSlot: View, ContentSlot: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let configuration: AmbitionRichPanelConfiguration
    let visualSlot: VisualSlot
    let contentSlot: ContentSlot
    let onAction: AmbitionPanelActionHandler?

    public init(
        _ configuration: AmbitionRichPanelConfiguration,
        onAction: AmbitionPanelActionHandler? = nil,
        @ViewBuilder visualSlot: () -> VisualSlot,
        @ViewBuilder contentSlot: () -> ContentSlot
    ) {
        self.configuration = configuration
        self.visualSlot = visualSlot()
        self.contentSlot = contentSlot()
        self.onAction = onAction
    }

    public var body: some View {
        let semanticStyle = theme.semanticStyle(for: configuration.semanticState)

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            header(semanticStyle: semanticStyle)

            if let subtitle = configuration.subtitle {
                Text(subtitle)
                    .font(configuration.kind == .heroDecision ? theme.typography.bodyPrimary : theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if configuration.progressValue != nil || configuration.confidenceLabel != nil {
                stateRow
            }

            visualSlot
                .frame(maxWidth: .infinity, minHeight: shouldReserveVisualSlot ? theme.panel.visualSlotMinimumHeight : nil, alignment: .leading)
                .accessibilityHidden(false)

            contentSlot

            if let explanation = configuration.explanation {
                explanationBlock(explanation)
            }

            actionRow
        }
        .ambitionSurface(configuration.kind.surfaceStyle, state: visualState, accent: semanticStyle.accent)
        .transition(reduceMotion ? .opacity : .ambitionPanel)
        .ambitionPanelAccessibility(
            label: configuration.accessibilityLabel ?? defaultAccessibilityLabel,
            value: configuration.accessibilityValue ?? defaultAccessibilityValue,
            hint: configuration.accessibilityHint
        )
    }

    var visualState: AmbitionVisualState {
        switch configuration.semanticState {
        case .success, .confidenceHigh, .accessibilityVerified:
            return .success
        case .caution, .confidenceMedium, .waiting, .calendarDerived, .accessibilityUnverified:
            return .warning
        case .risk, .confidenceLow:
            return .warning
        case .focus, .protected, .capture, .trust, .review, .recovery:
            return .selected
        case .neutral:
            return .default
        }
    }

    var shouldReserveVisualSlot: Bool {
        configuration.progressValue != nil || configuration.kind == .timeline || configuration.kind == .schedule
    }

    var defaultAccessibilityLabel: String {
        [
            configuration.kind.defaultEyebrow,
            configuration.title,
            configuration.semanticState.label,
            configuration.confidenceLabel
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    var defaultAccessibilityValue: String? {
        if let progressValue = configuration.progressValue {
            return "\(Int(min(max(progressValue, 0), 1) * 100)) percent"
        }
        return configuration.semanticState.accessibilityText
    }

    func header(semanticStyle: AmbitionSemanticStyle) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: configuration.icon ?? configuration.kind.defaultIcon)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(semanticStyle.accent)
                .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                .background(Circle().fill(semanticStyle.fill))
                .overlay(Circle().stroke(semanticStyle.stroke, lineWidth: 1))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                HStack(spacing: theme.spacing.xs) {
                    Text((configuration.eyebrow ?? configuration.kind.defaultEyebrow).uppercased())
                        .font(theme.typography.micro)
                        .foregroundStyle(semanticStyle.accent)

                    AmbitionChip(configuration.semanticState.label, role: .state, semanticState: configuration.semanticState)
                }

                Text(configuration.title)
                    .font(configuration.kind == .heroDecision ? theme.typography.title : theme.typography.titleCompact)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    var stateRow: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let confidenceLabel = configuration.confidenceLabel {
                AmbitionChip(confidenceLabel, role: .confidence, semanticState: configuration.semanticState)
            }

            if let progressValue = configuration.progressValue {
                ProgressRail(
                    title: configuration.confidenceLabel ?? "Progress",
                    progress: progressValue,
                    trailingValue: "\(Int(min(max(progressValue, 0), 1) * 100))%",
                    state: visualState,
                    accent: theme.semanticAccent(for: configuration.semanticState)
                )
            }
        }
    }

    func explanationBlock(_ explanation: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(configuration.explanationTitle ?? "Why this")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
            Text(explanation)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.borders.quiet, lineWidth: 1))
    }

    @ViewBuilder
    var actionRow: some View {
        let actions = [configuration.primaryAction, configuration.secondaryAction].compactMap { $0 }
        if actions.isEmpty == false {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(actions) { action in
                    Button {
                        onAction?(action)
                    } label: {
                        Label(action.title, systemImage: action.icon ?? action.role.defaultIcon)
                            .frame(maxWidth: action.role == .tertiary || action.role == .compact ? nil : .infinity)
                    }
                    .buttonStyle(AmbitionButtonStyle(tier: action.role.buttonTier, state: visualState, accent: theme.semanticAccent(for: configuration.semanticState)))
                    .accessibilityHint(action.accessibilityHint ?? "")
                }
            }
        }
    }
}

public extension AmbitionPanelAction.Role {
    var buttonTier: AmbitionButtonTier {
        switch self {
        case .primary: .primary
        case .secondary: .secondary
        case .tertiary: .tertiary
        case .recovery: .recovery
        case .destructive: .destructive
        case .compact: .compact
        }
    }

    var defaultIcon: String {
        switch self {
        case .primary: "arrow.right.circle.fill"
        case .secondary: "arrow.right.circle"
        case .tertiary: "info.circle"
        case .recovery: "arrow.uturn.backward.circle"
        case .destructive: "exclamationmark.triangle"
        case .compact: "ellipsis.circle"
        }
    }
}

public extension AmbitionRichPanel where VisualSlot == EmptyView, ContentSlot == EmptyView {
    init(
        _ configuration: AmbitionRichPanelConfiguration,
        onAction: AmbitionPanelActionHandler? = nil
    ) {
        self.init(configuration, onAction: onAction, visualSlot: { EmptyView() }, contentSlot: { EmptyView() })
    }
}

public extension AmbitionRichPanel where ContentSlot == EmptyView {
    init(
        _ configuration: AmbitionRichPanelConfiguration,
        onAction: AmbitionPanelActionHandler? = nil,
        @ViewBuilder visualSlot: () -> VisualSlot
    ) {
        self.init(configuration, onAction: onAction, visualSlot: visualSlot, contentSlot: { EmptyView() })
    }
}

public struct HeroDecisionPanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(
        _ configuration: AmbitionRichPanelConfiguration,
        onAction: AmbitionPanelActionHandler? = nil,
        @ViewBuilder visualSlot: () -> VisualSlot,
        @ViewBuilder contentSlot: () -> ContentSlot
    ) {
        panel = AmbitionRichPanel(configuration.with(kind: .heroDecision), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct ProgressPanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .progress), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct TimelinePanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .timeline), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct SchedulePanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .schedule), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct InsightPanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .insight), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct RecoveryPanel<VisualSlot: View, ContentSlot: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let configuration: AmbitionRichPanelConfiguration
    let visualSlot: VisualSlot
    let contentSlot: ContentSlot
    let onAction: AmbitionPanelActionHandler?

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        self.configuration = configuration.with(kind: .recovery)
        self.visualSlot = visualSlot()
        self.contentSlot = contentSlot()
        self.onAction = onAction
    }

    public var body: some View {
        ClosureRecoveryPrimitiveStage(
            role: .recovery,
            eyebrow: configuration.eyebrow ?? configuration.kind.defaultEyebrow,
            title: configuration.title,
            subtitle: configuration.subtitle,
            statusLabel: configuration.confidenceLabel ?? configuration.semanticState.label,
            systemImage: configuration.icon ?? configuration.kind.defaultIcon,
            accessibilityIdentifier: "recovery-primitive-panel"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                visualSlot
                contentSlot
                actionStack
            }
        }
        .accessibilityHint(configuration.accessibilityHint ?? "")
        .accessibilityValue(configuration.accessibilityValue ?? configuration.semanticState.accessibilityText)
    }

    @ViewBuilder
    var actionStack: some View {
        if configuration.primaryAction != nil || configuration.secondaryAction != nil {
            HStack(spacing: theme.spacing.xs) {
                if let primaryAction = configuration.primaryAction {
                    actionButton(primaryAction, isPrimary: true)
                }
                if let secondaryAction = configuration.secondaryAction {
                    actionButton(secondaryAction, isPrimary: false)
                }
            }
        }
    }

    func actionButton(_ action: AmbitionPanelAction, isPrimary: Bool) -> some View {
        Button {
            onAction?(action)
        } label: {
            Label(action.title, systemImage: action.icon ?? (isPrimary ? "arrow.right" : "ellipsis"))
                .font(theme.typography.caption.weight(.semibold))
                .frame(minHeight: 36)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: isPrimary ? .warning : .default))
        .accessibilityHint(action.accessibilityHint ?? "")
    }
}

public struct TrustPanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .trust), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct CapturePanel<VisualSlot: View, ContentSlot: View>: View {
    let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .capture), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}
#endif
