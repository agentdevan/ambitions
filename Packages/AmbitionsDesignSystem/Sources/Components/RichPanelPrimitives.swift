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
#endif
