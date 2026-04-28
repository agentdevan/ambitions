#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionSemanticState: String, CaseIterable, Sendable, Identifiable {
    case neutral
    case confidenceHigh
    case confidenceMedium
    case confidenceLow
    case recovery
    case waiting
    case protected
    case focus
    case capture
    case trust
    case review
    case success
    case caution
    case risk
    case calendarDerived
    case accessibilityVerified
    case accessibilityUnverified

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .neutral: "Calm"
        case .confidenceHigh: "Strong signal"
        case .confidenceMedium: "Useful signal"
        case .confidenceLow: "Needs review"
        case .recovery: "Recovery"
        case .waiting: "Waiting"
        case .protected: "Private"
        case .focus: "Focus"
        case .capture: "Capture"
        case .trust: "Trust"
        case .review: "Review"
        case .success: "Stable"
        case .caution: "Watch"
        case .risk: "Risk"
        case .calendarDerived: "From calendar"
        case .accessibilityVerified: "Verified"
        case .accessibilityUnverified: "Unverified"
        }
    }

    public var icon: String {
        switch self {
        case .neutral: "circle"
        case .confidenceHigh: "checkmark.seal.fill"
        case .confidenceMedium: "scope"
        case .confidenceLow: "exclamationmark.triangle.fill"
        case .recovery: "arrow.uturn.backward.circle.fill"
        case .waiting: "hourglass"
        case .protected: "lock.shield.fill"
        case .focus: "scope"
        case .capture: "tray.and.arrow.down.fill"
        case .trust: "checkmark.shield.fill"
        case .review: "doc.text.magnifyingglass"
        case .success: "checkmark.circle.fill"
        case .caution: "exclamationmark.circle.fill"
        case .risk: "xmark.octagon.fill"
        case .calendarDerived: "calendar.badge.clock"
        case .accessibilityVerified: "accessibility.fill"
        case .accessibilityUnverified: "accessibility"
        }
    }

    public var accessibilityText: String {
        switch self {
        case .neutral: "calm state"
        case .confidenceHigh: "strong signal"
        case .confidenceMedium: "useful signal"
        case .confidenceLow: "needs review"
        case .recovery: "recovery option"
        case .waiting: "waiting state"
        case .protected: "private item"
        case .focus: "current focus"
        case .capture: "capture state"
        case .trust: "trust or source status"
        case .review: "review state"
        case .success: "stable state"
        case .caution: "needs attention"
        case .risk: "risk state"
        case .calendarDerived: "from calendar"
        case .accessibilityVerified: "accessibility verified"
        case .accessibilityUnverified: "accessibility not yet verified"
        }
    }
}

public struct AmbitionSemanticStyle: Sendable {
    public let fill: Color
    public let stroke: Color
    public let foreground: Color
    public let accent: Color
}

public extension AmbitionTheme {
    func semanticStyle(for state: AmbitionSemanticState) -> AmbitionSemanticStyle {
        let accent = semanticAccent(for: state)
        let fillOpacity = mode == .dark ? 0.20 : 0.11
        return .init(
            fill: accent.opacity(fillOpacity),
            stroke: accent.opacity(borders.semanticOpacity),
            foreground: colors.textPrimary,
            accent: accent
        )
    }

    func semanticAccent(for state: AmbitionSemanticState) -> Color {
        switch state {
        case .neutral: colors.accentPrimary
        case .confidenceHigh: semanticColors.confidenceHigh
        case .confidenceMedium: semanticColors.confidenceMedium
        case .confidenceLow: semanticColors.confidenceLow
        case .recovery: semanticColors.recovery
        case .waiting: semanticColors.waiting
        case .protected: semanticColors.protected
        case .focus: semanticColors.focus
        case .capture: semanticColors.capture
        case .trust: semanticColors.trust
        case .review: semanticColors.review
        case .success: colors.success
        case .caution: colors.warning
        case .risk: semanticColors.risk
        case .calendarDerived: semanticColors.calendarDerived
        case .accessibilityVerified: semanticColors.accessibilityVerified
        case .accessibilityUnverified: semanticColors.accessibilityUnverified
        }
    }
}

public enum AmbitionPanelKind: String, CaseIterable, Sendable, Identifiable {
    case heroDecision
    case progress
    case timeline
    case schedule
    case insight
    case recovery
    case trust
    case capture
    case review
    case settingsPreference

    public var id: String { rawValue }

    public var defaultEyebrow: String {
        switch self {
        case .heroDecision: "Decision"
        case .progress: "Progress"
        case .timeline: "Timeline"
        case .schedule: "Schedule"
        case .insight: "Insight"
        case .recovery: "Recovery"
        case .trust: "Trust"
        case .capture: "Capture"
        case .review: "Review"
        case .settingsPreference: "Preference"
        }
    }

    public var defaultIcon: String {
        switch self {
        case .heroDecision: "sparkles"
        case .progress: "chart.bar.fill"
        case .timeline: "point.topleft.down.curvedto.point.bottomright.up"
        case .schedule: "calendar"
        case .insight: "lightbulb.fill"
        case .recovery: "arrow.uturn.backward.circle.fill"
        case .trust: "checkmark.shield.fill"
        case .capture: "tray.and.arrow.down.fill"
        case .review: "doc.text.magnifyingglass"
        case .settingsPreference: "slider.horizontal.3"
        }
    }

    public var defaultSemanticState: AmbitionSemanticState {
        switch self {
        case .heroDecision: .focus
        case .progress: .confidenceMedium
        case .timeline: .review
        case .schedule: .calendarDerived
        case .insight: .trust
        case .recovery: .recovery
        case .trust: .trust
        case .capture: .capture
        case .review: .review
        case .settingsPreference: .protected
        }
    }

    var surfaceStyle: AmbitionCardStyle {
        switch self {
        case .heroDecision:
            return .hero
        case .schedule, .timeline:
            return .app
        case .progress, .insight, .recovery, .trust, .capture, .review, .settingsPreference:
            return .widget
        }
    }
}

public struct AmbitionPanelAction: Identifiable, Hashable, Sendable {
    public enum Role: String, CaseIterable, Sendable {
        case primary
        case secondary
        case tertiary
        case recovery
        case destructive
        case compact
    }

    public let id: String
    public let title: String
    public let icon: String?
    public let role: Role
    public let accessibilityHint: String?

    public init(
        id: String,
        title: String,
        icon: String? = nil,
        role: Role,
        accessibilityHint: String? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.role = role
        self.accessibilityHint = accessibilityHint
    }
}

public struct AmbitionRichPanelConfiguration: Sendable {
    public let kind: AmbitionPanelKind
    public let eyebrow: String?
    public let title: String
    public let subtitle: String?
    public let icon: String?
    public let semanticState: AmbitionSemanticState
    public let confidenceLabel: String?
    public let progressValue: Double?
    public let explanationTitle: String?
    public let explanation: String?
    public let primaryAction: AmbitionPanelAction?
    public let secondaryAction: AmbitionPanelAction?
    public let accessibilityLabel: String?
    public let accessibilityHint: String?
    public let accessibilityValue: String?

    public init(
        kind: AmbitionPanelKind,
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        semanticState: AmbitionSemanticState? = nil,
        confidenceLabel: String? = nil,
        progressValue: Double? = nil,
        explanationTitle: String? = nil,
        explanation: String? = nil,
        primaryAction: AmbitionPanelAction? = nil,
        secondaryAction: AmbitionPanelAction? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        accessibilityValue: String? = nil
    ) {
        self.kind = kind
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.semanticState = semanticState ?? kind.defaultSemanticState
        self.confidenceLabel = confidenceLabel
        self.progressValue = progressValue
        self.explanationTitle = explanationTitle
        self.explanation = explanation
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.accessibilityValue = accessibilityValue
    }
}

public typealias AmbitionPanelActionHandler = @MainActor (AmbitionPanelAction) -> Void

public struct AmbitionRichPanel<VisualSlot: View, ContentSlot: View>: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let configuration: AmbitionRichPanelConfiguration
    private let visualSlot: VisualSlot
    private let contentSlot: ContentSlot
    private let onAction: AmbitionPanelActionHandler?

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

    private var visualState: AmbitionVisualState {
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

    private var shouldReserveVisualSlot: Bool {
        configuration.progressValue != nil || configuration.kind == .timeline || configuration.kind == .schedule
    }

    private var defaultAccessibilityLabel: String {
        [
            configuration.kind.defaultEyebrow,
            configuration.title,
            configuration.semanticState.label,
            configuration.confidenceLabel
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    private var defaultAccessibilityValue: String? {
        if let progressValue = configuration.progressValue {
            return "\(Int(min(max(progressValue, 0), 1) * 100)) percent"
        }
        return configuration.semanticState.accessibilityText
    }

    private func header(semanticStyle: AmbitionSemanticStyle) -> some View {
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

    private var stateRow: some View {
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

    private func explanationBlock(_ explanation: String) -> some View {
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
    private var actionRow: some View {
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
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

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
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .progress), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct TimelinePanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .timeline), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct SchedulePanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .schedule), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct InsightPanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .insight), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct RecoveryPanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .recovery), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct TrustPanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .trust), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct CapturePanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .capture), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct ReviewPanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .review), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public struct SettingsPreferencePanel<VisualSlot: View, ContentSlot: View>: View {
    private let panel: AmbitionRichPanel<VisualSlot, ContentSlot>

    public init(_ configuration: AmbitionRichPanelConfiguration, onAction: AmbitionPanelActionHandler? = nil, @ViewBuilder visualSlot: () -> VisualSlot, @ViewBuilder contentSlot: () -> ContentSlot) {
        panel = AmbitionRichPanel(configuration.with(kind: .settingsPreference), onAction: onAction, visualSlot: visualSlot, contentSlot: contentSlot)
    }

    public var body: some View { panel }
}

public extension AmbitionRichPanelConfiguration {
    func with(kind: AmbitionPanelKind) -> AmbitionRichPanelConfiguration {
        AmbitionRichPanelConfiguration(
            kind: kind,
            eyebrow: eyebrow,
            title: title,
            subtitle: subtitle,
            icon: icon,
            semanticState: semanticState == self.kind.defaultSemanticState ? kind.defaultSemanticState : semanticState,
            confidenceLabel: confidenceLabel,
            progressValue: progressValue,
            explanationTitle: explanationTitle,
            explanation: explanation,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction,
            accessibilityLabel: accessibilityLabel,
            accessibilityHint: accessibilityHint,
            accessibilityValue: accessibilityValue
        )
    }
}
#endif
