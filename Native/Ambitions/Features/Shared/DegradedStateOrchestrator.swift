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
    let statusRole: AmbitionsStatusSymbolRole

    init(
        id: String,
        kind: DegradedStateKind,
        title: String,
        explanation: String,
        primaryAction: DegradedStateAction,
        secondaryAction: DegradedStateAction? = nil,
        tone: AmbitionVisualState,
        icon: String,
        statusRole: AmbitionsStatusSymbolRole? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.explanation = explanation
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.tone = tone
        self.icon = icon
        self.statusRole = statusRole ?? Self.defaultStatusRole(for: kind)
    }

    private static func defaultStatusRole(for kind: DegradedStateKind) -> AmbitionsStatusSymbolRole {
        switch kind {
        case .empty, .lowHistory:
            .noDataYet
        case .permissionNeeded:
            .setupNeeded
        case .permissionDenied:
            .sourceDenied
        case .stale:
            .sourceStale
        case .offline:
            .localOnly
        case .unavailable, .error:
            .needsReview
        case .loading:
            .loading
        case .cannotExplainYet:
            .disabledPendingValidation
        }
    }
}

enum FlagshipObjectStateOwner: String, CaseIterable, Sendable, Equatable {
    case startHere
    case realityRail
    case missionControlTimeSpine
    case proofSpine
    case capturePlacementShelf
    case lifeShapeContourMap
    case personalSystemCenter
    case memoryLens

    var title: String {
        switch self {
        case .startHere: "Start Here"
        case .realityRail: "Reality Meridian"
        case .missionControlTimeSpine: "Your Direction"
        case .proofSpine: "Proof Spine"
        case .capturePlacementShelf: "Atmosphere Composer"
        case .lifeShapeContourMap: "LifeShape Field"
        case .personalSystemCenter: "User System Profile"
        case .memoryLens: "Search"
        }
    }

    var icon: String {
        switch self {
        case .startHere: "scope"
        case .realityRail: "point.3.connected.trianglepath.dotted"
        case .missionControlTimeSpine: "arrow.triangle.branch"
        case .proofSpine: "checkmark.seal"
        case .capturePlacementShelf: "tray.and.arrow.down"
        case .lifeShapeContourMap: "map"
        case .personalSystemCenter: "person.crop.circle"
        case .memoryLens: "memories"
        }
    }

    var loadingExplanation: String {
        switch self {
        case .startHere:
            "Ambitions is preserving the Start Here slot while it reads the local day."
        case .realityRail:
            "The rail keeps its order while local steps, waiting points, and recovery signals settle."
        case .missionControlTimeSpine:
            "Goals keeps the direction object stable while life areas, proof, pressure, and recommended steps load."
        case .proofSpine:
            "Proof stays hidden until source, freshness, privacy, and correction posture are ready."
        case .capturePlacementShelf:
            "Capture keeps the Atmosphere Composer available while placement, privacy, and correction signals settle."
        case .lifeShapeContourMap:
            "Time preserves the LifeShape Field while capacity, pressure, and protected pockets load."
        case .personalSystemCenter:
            "You keeps Your System stable while setup, trust, privacy, receipts, and defaults load."
        case .memoryLens:
            "Search waits for local source age, privacy, and correction posture before showing detail."
        }
    }

    var emptyExplanation: String {
        switch self {
        case .startHere:
            "Start Here waits for one real goal, capture, or promise instead of inventing urgency."
        case .realityRail:
            "The rail can stay open; empty space is not treated as failure."
        case .missionControlTimeSpine:
            "Your Direction waits for a goal with enough local shape to inspect."
        case .proofSpine:
            "No proof is shown until the user saves evidence or a local receipt exists."
        case .capturePlacementShelf:
            "The composer stays quiet until there is a capture that needs a place."
        case .lifeShapeContourMap:
            "The LifeShape Field can stay open when no real constraints need shaping."
        case .personalSystemCenter:
            "Your System starts with setup and trust controls before it shows deeper history."
        case .memoryLens:
            "Search stays quiet until explicit local evidence makes recall useful."
        }
    }

    var degradedExplanation: String {
        switch self {
        case .startHere:
            "Start Here can retry without moving commitments or pretending the recommendation is current."
        case .realityRail:
            "The rail stays readable and does not silently reorder steps while source state is uncertain."
        case .missionControlTimeSpine:
            "Goals can retry without changing the path, decisions, or proof."
        case .proofSpine:
            "Proof remains review-bound until source freshness and privacy posture are clear."
        case .capturePlacementShelf:
            "Capture can keep the text local and wait for placement review instead of saving silently."
        case .lifeShapeContourMap:
            "Time can retry without reshaping protected time or writing calendar changes."
        case .personalSystemCenter:
            "You can retry without changing setup, trust, memory, or receipts."
        case .memoryLens:
            "Search hides detail until stale or sensitive source state is reviewed."
        }
    }
}

struct FlagshipObjectStateMatrixEntry: Identifiable, Sendable, Equatable {
    let owner: FlagshipObjectStateOwner
    let normalState: AmbitionsLoadingState
    let loadingState: AmbitionsLoadingState
    let emptyState: AmbitionsLoadingState
    let degradedState: AmbitionsLoadingState
    let boundary: String

    var id: String { owner.rawValue }

    var accessibilitySummary: String {
        "\(owner.title). Normal: \(normalState.title). Loading: \(loadingState.title). Empty: \(emptyState.title). Degraded: \(degradedState.title). \(boundary)"
    }
}

enum FlagshipObjectStateMatrix {
    static let entries: [FlagshipObjectStateMatrixEntry] = FlagshipObjectStateOwner.allCases.map { owner in
        FlagshipObjectStateMatrixEntry(
            owner: owner,
            normalState: .localOnly,
            loadingState: .loading,
            emptyState: owner == .proofSpine || owner == .memoryLens ? .noDataYet : .empty,
            degradedState: degradedState(for: owner),
            boundary: boundary(for: owner)
        )
    }

    static func entry(for owner: FlagshipObjectStateOwner) -> FlagshipObjectStateMatrixEntry {
        entries.first { $0.owner == owner }!
    }

    private static func degradedState(for owner: FlagshipObjectStateOwner) -> AmbitionsLoadingState {
        switch owner {
        case .proofSpine, .memoryLens:
            .staleSource
        case .capturePlacementShelf, .lifeShapeContourMap, .missionControlTimeSpine:
            .needsReview
        case .startHere, .realityRail:
            .recovery
        case .personalSystemCenter:
            .privacySensitive
        }
    }

    private static func boundary(for owner: FlagshipObjectStateOwner) -> String {
        switch owner {
        case .startHere, .realityRail:
            "Progress stays source-bound, recovery stays non-shaming, and there is no silent commitment mutation."
        case .missionControlTimeSpine:
            "Routes stay user-reviewed, path changes stay visible, and thread detail stays out of project-board posture."
        case .proofSpine:
            "Proof stays source-bound and never becomes a trophy shelf, activity feed, or certification claim."
        case .capturePlacementShelf:
            "Capture stays composer-first with review before placement, learning, or goal creation."
        case .lifeShapeContourMap:
            "Time stays contour-first with reviewed reflow and grounded time language."
        case .personalSystemCenter:
            "Setup, trust, memory, and receipts stay explicit and user-owned."
        case .memoryLens:
            "Recall stays source-bound, privacy-preserving, and correction-ready."
        }
    }
}

enum DegradedStateOrchestrator {
    static func todayEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .today)
        return DegradedStatePresentation(
            id: "degraded.today.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .selected,
            icon: rule.icon
        )
    }

    static func goalsEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .goals)
        return DegradedStatePresentation(
            id: "degraded.goals.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .selected,
            icon: rule.icon
        )
    }

    static func timeEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.time.empty",
            kind: .empty,
            title: "The LifeShape Field is open",
            explanation: FlagshipObjectStateOwner.lifeShapeContourMap.emptyExplanation,
            primaryAction: DegradedStateAction(title: "Create a goal", systemImage: AppTab.goals.systemImage, routingHint: .createGoal),
            secondaryAction: DegradedStateAction(title: "Open Capture", systemImage: AppShellCaptureAccessModel.systemImage, routingHint: .captures),
            tone: .selected,
            icon: FlagshipObjectStateOwner.lifeShapeContourMap.icon
        )
    }

    static func planEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .plan)
        return DegradedStatePresentation(
            id: "degraded.plan.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .success,
            icon: rule.icon
        )
    }

    static func capturesEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .capture)
        return DegradedStatePresentation(
            id: "degraded.captures.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .default,
            icon: rule.icon
        )
    }

    static func youEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .you)
        return DegradedStatePresentation(
            id: "degraded.you.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .default,
            icon: rule.icon
        )
    }

    static func habitsEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.habits.empty",
            kind: .empty,
            title: "No routines are shaping the week yet",
            explanation: "Rituals stay quiet until a repeatable loop is useful enough to support the week.",
            primaryAction: DegradedStateAction(title: "Return to Time", systemImage: AppTab.time.systemImage, routingHint: .plan),
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
            primaryAction: DegradedStateAction(title: "Return to Time", systemImage: AppTab.time.systemImage, routingHint: .plan),
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
            secondaryAction: DegradedStateAction(title: "Shape the week", systemImage: AppTab.time.systemImage, routingHint: .plan),
            tone: .default,
            icon: "chart.line.uptrend.xyaxis"
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

    static func objectLoading(_ owner: FlagshipObjectStateOwner) -> DegradedStatePresentation {
        let entry = FlagshipObjectStateMatrix.entry(for: owner)
        return DegradedStatePresentation(
            id: "degraded.\(owner.rawValue).loading",
            kind: .loading,
            title: "\(owner.title) is getting ready",
            explanation: "\(owner.loadingExplanation) \(entry.boundary)",
            primaryAction: DegradedStateAction(title: entry.loadingState.action.title, systemImage: owner.icon),
            tone: .default,
            icon: owner.icon,
            statusRole: entry.loadingState.statusSymbolRole
        )
    }

    static func objectUnavailable(
        _ owner: FlagshipObjectStateOwner,
        retryHint: DegradedStateRoutingHint? = nil
    ) -> DegradedStatePresentation {
        let entry = FlagshipObjectStateMatrix.entry(for: owner)
        return DegradedStatePresentation(
            id: "degraded.\(owner.rawValue).unavailable",
            kind: .unavailable,
            title: "\(owner.title) needs review",
            explanation: "\(owner.degradedExplanation) \(entry.boundary)",
            primaryAction: DegradedStateAction(title: "Retry", systemImage: "arrow.clockwise", routingHint: retryHint),
            tone: .warning,
            icon: owner.icon,
            statusRole: entry.degradedState.statusSymbolRole
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

struct DegradedStateSurface: View {
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
                        .accessibilityHidden(true)
                    AmbitionsStatusSymbol(state.statusRole, style: .badge)
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

}
