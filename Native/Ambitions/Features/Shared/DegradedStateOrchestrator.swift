import AmbitionsDesignSystem
import SwiftUI

enum DegradedStateKind: String, CaseIterable, Sendable, Equatable {
    case empty
    case lowHistory
    case permissionNeeded
    case permissionDenied
    case stale
    case offline
    case unavailable
    case loading
    case error
    case cannotExplainYet
}

enum DegradedStateRoutingHint: String, Sendable, Equatable {
    case today
    case goals
    case plan
    case insights
    case profileTrust
    case captures
    case habits
    case weeklyReview
    case createGoal
    case quickCapture
    case systemSettings
}

struct DegradedStateAction: Sendable, Equatable {
    let title: String
    let systemImage: String
    let routingHint: DegradedStateRoutingHint?

    init(title: String, systemImage: String, routingHint: DegradedStateRoutingHint? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.routingHint = routingHint
    }
}

struct DegradedStatePresentation: Identifiable, Sendable, Equatable {
    let id: String
    let kind: DegradedStateKind
    let title: String
    let explanation: String
    let primaryAction: DegradedStateAction
    let secondaryAction: DegradedStateAction?
    let tone: AmbitionVisualState
    let icon: String

    init(
        id: String,
        kind: DegradedStateKind,
        title: String,
        explanation: String,
        primaryAction: DegradedStateAction,
        secondaryAction: DegradedStateAction? = nil,
        tone: AmbitionVisualState,
        icon: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.explanation = explanation
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.tone = tone
        self.icon = icon
    }
}

enum DegradedStateOrchestrator {
    static func todayEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.today.empty",
            kind: .empty,
            title: "Today is waiting for a real signal",
            explanation: "Add one goal or capture one thought. Today will stay calm until there is something worth acting on.",
            primaryAction: DegradedStateAction(title: "Create first goal", systemImage: "target", routingHint: .createGoal),
            secondaryAction: DegradedStateAction(title: "Capture first", systemImage: "tray.and.arrow.down", routingHint: .quickCapture),
            tone: .selected,
            icon: "sun.max"
        )
    }

    static func goalsEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.goals.empty",
            kind: .empty,
            title: "Your direction board is ready",
            explanation: "Start with one ambition in plain language. Ambitions will shape the first believable path before the board gets busy.",
            primaryAction: DegradedStateAction(title: "Create goal", systemImage: "plus", routingHint: .createGoal),
            secondaryAction: DegradedStateAction(title: "Capture an idea", systemImage: "tray.and.arrow.down", routingHint: .quickCapture),
            tone: .selected,
            icon: "scope"
        )
    }

    static func planEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.plan.empty",
            kind: .empty,
            title: "The week has room",
            explanation: "Nothing is asking the week for structure yet. Add a goal or capture, then Plan will show what still fits.",
            primaryAction: DegradedStateAction(title: "Create goal", systemImage: "target", routingHint: .createGoal),
            secondaryAction: DegradedStateAction(title: "Open captures", systemImage: "tray.full", routingHint: .captures),
            tone: .success,
            icon: AppTab.plan.systemImage
        )
    }

    static func capturesEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.captures.empty",
            kind: .empty,
            title: "No loose thoughts are waiting",
            explanation: "Captures will appear here when an idea needs a calm home in a goal, a week, or the seed vault.",
            primaryAction: DegradedStateAction(title: "Capture now", systemImage: "square.and.pencil", routingHint: .quickCapture),
            secondaryAction: DegradedStateAction(title: "Return to Plan", systemImage: AppTab.plan.systemImage, routingHint: .plan),
            tone: .default,
            icon: "tray"
        )
    }

    static func habitsEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.habits.empty",
            kind: .empty,
            title: "No routines are shaping the week yet",
            explanation: "Habits stay quiet until a repeatable loop is useful enough to support the week.",
            primaryAction: DegradedStateAction(title: "Return to Plan", systemImage: AppTab.plan.systemImage, routingHint: .plan),
            tone: .default,
            icon: "repeat"
        )
    }

    static func weeklyReviewEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.weekly-review.empty",
            kind: .lowHistory,
            title: "The review has little to carry forward",
            explanation: "A few goals, captures, or completed steps will give Weekly Review enough signal to shape the next week.",
            primaryAction: DegradedStateAction(title: "Return to Plan", systemImage: AppTab.plan.systemImage, routingHint: .plan),
            tone: .default,
            icon: "arrow.triangle.branch"
        )
    }

    static func insightsLowHistory() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.insights.low-history",
            kind: .lowHistory,
            title: "Reflection needs a little history",
            explanation: "Ambitions will not pretend there is a pattern yet. A few completions, skips, or smaller versions will make this read useful.",
            primaryAction: DegradedStateAction(title: "Open Today", systemImage: AppTab.today.systemImage, routingHint: .today),
            secondaryAction: DegradedStateAction(title: "Shape the week", systemImage: AppTab.plan.systemImage, routingHint: .plan),
            tone: .default,
            icon: AppTab.insights.systemImage
        )
    }

    static func permissionDeniedNotifications() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.permission.notifications.denied",
            kind: .permissionDenied,
            title: "Notifications are off",
            explanation: "Ambitions can still run locally. Time-sensitive reminders will stay inside the app unless you re-enable notifications in Settings.",
            primaryAction: DegradedStateAction(title: "Review Trust Center", systemImage: "checkmark.shield", routingHint: .profileTrust),
            secondaryAction: DegradedStateAction(title: "Open Settings", systemImage: "gearshape", routingHint: .systemSettings),
            tone: .warning,
            icon: "bell.slash"
        )
    }

    static func permissionNeededNotifications() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.permission.notifications.needed",
            kind: .permissionNeeded,
            title: "Notifications are optional",
            explanation: "Turn them on when local reminders would help. The app stays useful without asking for everything up front.",
            primaryAction: DegradedStateAction(title: "Enable notifications", systemImage: "bell.badge", routingHint: .profileTrust),
            secondaryAction: DegradedStateAction(title: "Keep off for now", systemImage: "xmark.circle", routingHint: nil),
            tone: .selected,
            icon: "bell.badge"
        )
    }

    static func unavailable(surface: String, retryHint: DegradedStateRoutingHint? = nil) -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.\(surface.lowercased()).unavailable",
            kind: .unavailable,
            title: "\(surface) is unavailable",
            explanation: "This looks temporary. Retry once, and Ambitions will keep the rest of the system usable.",
            primaryAction: DegradedStateAction(title: "Retry", systemImage: "arrow.clockwise", routingHint: retryHint),
            tone: .warning,
            icon: "exclamationmark.triangle"
        )
    }

    static func loading(surface: String) -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.\(surface.lowercased()).loading",
            kind: .loading,
            title: "\(surface) is getting ready",
            explanation: "Ambitions is assembling the local picture before it decides what deserves attention.",
            primaryAction: DegradedStateAction(title: "Loading", systemImage: "hourglass", routingHint: nil),
            tone: .default,
            icon: "hourglass"
        )
    }

    static func cannotExplainYet() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.explainability.cannot-explain-yet",
            kind: .cannotExplainYet,
            title: "Not enough signal to explain this yet",
            explanation: "Ambitions will wait for clearer local evidence before it gives a confident reason.",
            primaryAction: DegradedStateAction(title: "Keep moving", systemImage: "arrow.right", routingHint: .today),
            tone: .default,
            icon: "questionmark.circle"
        )
    }
}

struct DegradedStateCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: DegradedStatePresentation
    let primaryAccessibilityIdentifier: String?
    let secondaryAccessibilityIdentifier: String?
    let onPrimaryAction: (() -> Void)?
    let onSecondaryAction: (() -> Void)?

    init(
        state: DegradedStatePresentation,
        primaryAccessibilityIdentifier: String? = nil,
        secondaryAccessibilityIdentifier: String? = nil,
        onPrimaryAction: (() -> Void)? = nil,
        onSecondaryAction: (() -> Void)? = nil
    ) {
        self.state = state
        self.primaryAccessibilityIdentifier = primaryAccessibilityIdentifier
        self.secondaryAccessibilityIdentifier = secondaryAccessibilityIdentifier
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
    }

    var body: some View {
        AppCard(state: state.tone) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(spacing: theme.spacing.sm) {
                    Image(systemName: state.icon)
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textSecondary)
                    StatusChip(statusTitle, icon: statusIcon, state: state.tone)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(state.title)
                        .font(theme.typography.titleCompact)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(state.explanation)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: theme.spacing.sm) {
                    if let onPrimaryAction {
                        Button {
                            onPrimaryAction()
                        } label: {
                            Label(state.primaryAction.title, systemImage: state.primaryAction.systemImage)
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: state.tone))
                        .accessibilityIdentifier(primaryAccessibilityIdentifier ?? "\(state.id).primary")
                    }

                    if let secondary = state.secondaryAction, let onSecondaryAction {
                        Button {
                            onSecondaryAction()
                        } label: {
                            Label(secondary.title, systemImage: secondary.systemImage)
                        }
                        .buttonStyle(AmbitionButtonStyle(tier: .tertiary, state: .default))
                        .accessibilityIdentifier(secondaryAccessibilityIdentifier ?? "\(state.id).secondary")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier(state.id)
    }

    private var statusTitle: String {
        switch state.kind {
        case .empty: "Ready when you are"
        case .lowHistory: "Low history"
        case .permissionNeeded: "Optional"
        case .permissionDenied: "Limited"
        case .stale: "Older context"
        case .offline: "Local mode"
        case .unavailable, .error: "May need attention"
        case .loading: "Loading"
        case .cannotExplainYet: "Not enough signal"
        }
    }

    private var statusIcon: String {
        switch state.kind {
        case .empty: "sparkles"
        case .lowHistory: "chart.line.uptrend.xyaxis"
        case .permissionNeeded: "hand.raised"
        case .permissionDenied: "hand.raised.slash"
        case .stale: "clock"
        case .offline: "wifi.slash"
        case .unavailable, .error: "exclamationmark.triangle"
        case .loading: "hourglass"
        case .cannotExplainYet: "questionmark.circle"
        }
    }
}
