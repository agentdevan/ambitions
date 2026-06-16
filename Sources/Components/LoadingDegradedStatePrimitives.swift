#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionsLoadingStateAction: String, CaseIterable, Sendable {
    case wait
    case retry
    case review
    case openCapture
    case openSetup
    case keepLocal
    case getSupport
    case blocked

    public var title: String {
        switch self {
        case .wait: "Waiting"
        case .retry: "Retry"
        case .review: "Review"
        case .openCapture: "Capture"
        case .openSetup: "Set up"
        case .keepLocal: "Keep local"
        case .getSupport: "Get support"
        case .blocked: "Blocked"
        }
    }
}

public enum AmbitionsLoadingState: String, CaseIterable, Identifiable, Sendable {
    case loading
    case empty
    case noDataYet
    case disabledPendingValidation
    case staleSource
    case partialSource
    case deniedSource
    case sourceConflict
    case packUnavailable
    case iCloudUnavailable
    case localOnly
    case updatePending
    case privacySensitive
    case crisisSupport
    case unsafeBlocked
    case waiting
    case needsReview
    case recovery
    case overwhelmingDay
    case setupNeeded

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .loading: "Getting this ready"
        case .empty: "Nothing needs your attention here"
        case .noDataYet: "No signal yet"
        case .disabledPendingValidation: "Waiting for validation"
        case .staleSource: "Source may be stale"
        case .partialSource: "Source is partial"
        case .deniedSource: "Needs context"
        case .sourceConflict: "Source needs review"
        case .packUnavailable: "Source pack unavailable"
        case .iCloudUnavailable: "iCloud unavailable"
        case .localOnly: "Local only"
        case .updatePending: "Update pending"
        case .privacySensitive: "Private detail hidden"
        case .crisisSupport: "Support comes first"
        case .unsafeBlocked: "This path is blocked"
        case .waiting: "Waiting on something outside Ambitions"
        case .needsReview: "Review before changes"
        case .recovery: "Still counts"
        case .overwhelmingDay: "Make this smaller"
        case .setupNeeded: "Setup needed"
        }
    }

    public var message: String {
        switch self {
        case .loading:
            return "Ambitions is preparing the next useful state without hiding what is happening."
        case .empty:
            return "This area is clear. The next useful action stays available when there is one."
        case .noDataYet:
            return "There is not enough local history to show a stronger signal yet."
        case .disabledPendingValidation:
            return "The action stays still until the required check finishes."
        case .staleSource:
            return "The visible guidance may need a source refresh before it changes a plan."
        case .partialSource:
            return "Some context is available, but not enough to treat this as complete."
        case .deniedSource:
            return "Ambitions can continue locally, but this source is not available right now."
        case .sourceConflict:
            return "Two source states disagree. Review is required before any commitment moves."
        case .packUnavailable:
            return "The source pack is not available here, so this stays in review."
        case .iCloudUnavailable:
            return "Continuity is paused. Your local state remains the source of truth."
        case .localOnly:
            return "This stays on this device unless you choose another continuity path later."
        case .updatePending:
            return "A source update is waiting. It does not change commitments by itself."
        case .privacySensitive:
            return "Sensitive detail is intentionally summarized instead of exposed."
        case .crisisSupport:
            return "Ambitions redirects to support language and does not operationalize harm."
        case .unsafeBlocked:
            return "This cannot become an action path inside Ambitions."
        case .waiting:
            return "The state is parked until the outside dependency changes."
        case .needsReview:
            return "A person reviews this before Ambitions treats it as ready."
        case .recovery:
            return "Recovery keeps what counted visible without turning today into a failure."
        case .overwhelmingDay:
            return "The next step should become smaller before more detail appears."
        case .setupNeeded:
            return "A setup choice is needed before this can become useful."
        }
    }

    public var symbolName: String {
        switch self {
        case .loading: "hourglass"
        case .empty: "checkmark.circle"
        case .noDataYet: "circle.dashed"
        case .disabledPendingValidation: "lock.circle"
        case .staleSource: "clock.badge.exclamationmark"
        case .partialSource: "circle.lefthalf.filled"
        case .deniedSource: "eye.slash"
        case .sourceConflict: "exclamationmark.arrow.triangle.2.circlepath"
        case .packUnavailable: "shippingbox"
        case .iCloudUnavailable: "icloud.slash"
        case .localOnly: "iphone"
        case .updatePending: "arrow.triangle.2.circlepath"
        case .privacySensitive: "lock.shield"
        case .crisisSupport: "heart.text.square"
        case .unsafeBlocked: "hand.raised"
        case .waiting: "pause.circle"
        case .needsReview: "checklist"
        case .recovery: "arrow.uturn.backward.circle"
        case .overwhelmingDay: "rectangle.compress.vertical"
        case .setupNeeded: "slider.horizontal.3"
        }
    }

    public var action: AmbitionsLoadingStateAction {
        switch self {
        case .loading, .disabledPendingValidation, .updatePending, .waiting:
            return .wait
        case .empty, .noDataYet:
            return .openCapture
        case .staleSource, .partialSource, .deniedSource, .sourceConflict,
             .packUnavailable, .needsReview:
            return .review
        case .iCloudUnavailable, .localOnly, .privacySensitive:
            return .keepLocal
        case .crisisSupport:
            return .getSupport
        case .unsafeBlocked:
            return .blocked
        case .recovery, .overwhelmingDay:
            return .retry
        case .setupNeeded:
            return .openSetup
        }
    }

    public var emphasis: PanelEmphasis {
        switch self {
        case .loading, .waiting, .updatePending, .disabledPendingValidation:
            return .quiet
        case .empty, .noDataYet:
            return .orientation
        case .staleSource, .partialSource, .deniedSource, .sourceConflict,
             .packUnavailable:
            return .source
        case .iCloudUnavailable, .localOnly, .privacySensitive:
            return .setup
        case .crisisSupport, .unsafeBlocked:
            return .pressure
        case .needsReview:
            return .receipt
        case .recovery, .overwhelmingDay:
            return .recovery
        case .setupNeeded:
            return .setup
        }
    }

    public var motionToken: AmbitionInteractionToken {
        switch self {
        case .loading, .waiting, .updatePending, .disabledPendingValidation:
            return .recompilePending
        case .empty, .noDataYet, .localOnly:
            return .localOnlySettle
        case .staleSource, .partialSource, .deniedSource, .sourceConflict,
             .packUnavailable:
            return .sourceCheck
        case .iCloudUnavailable, .privacySensitive:
            return .privacyBoundary
        case .crisisSupport, .unsafeBlocked:
            return .unsafeRedirect
        case .needsReview:
            return .reviewRequired
        case .recovery, .overwhelmingDay, .setupNeeded:
            return .correctionNeeded
        }
    }

    public var reduceMotionEquivalent: String {
        "\(motionToken.reduceMotionEquivalent) The state also keeps a static title and next action."
    }

    public var accessibilityAnnouncement: String {
        "\(title). \(message) Next action: \(action.title). Reduce Motion: \(reduceMotionEquivalent)"
    }

    public var isFutureLDIVisualHook: Bool {
        switch self {
        case .sourceConflict, .packUnavailable, .iCloudUnavailable,
             .updatePending, .crisisSupport, .unsafeBlocked:
            return true
        default:
            return false
        }
    }
}

public struct AmbitionsLoadingStatePrimitive: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let state: AmbitionsLoadingState
    private let action: (@MainActor () -> Void)?

    public init(
        state: AmbitionsLoadingState,
        action: (@MainActor () -> Void)? = nil
    ) {
        self.state = state
        self.action = action
    }

    public var body: some View {
        AdaptivePanel(
            .init(
                emphasis: state.emphasis,
                title: state.title,
                subtitle: state.message,
                status: state.action.title,
                isLoading: state == .loading,
                isDisabled: state.action == .blocked,
                isPrivacySensitive: state == .privacySensitive,
                accessibilityLabel: state.accessibilityAnnouncement,
                accessibilityHint: "Shows an honest Ambitions state and a safe next action."
            )
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    Image(systemName: state.symbolName)
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(state.emphasis.semanticState.accentColor(in: theme))
                        .accessibilityHidden(true)

                    StaleSourceLabel(state: state)
                }

                Text(state.reduceMotionEquivalent)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let action {
                    AmbitionsActionButton(
                        state.action.title,
                        icon: actionIcon,
                        role: actionRole,
                        state: state.emphasis.semanticState.visualState,
                        isLoading: state.action == .wait,
                        action: action
                    )
                }
            }
        }
        .transition(AnyTransition.ambitionInteraction(state.motionToken, reduceMotion: reduceMotion))
    }

    private var actionRole: AmbitionsActionRole {
        switch state.action {
        case .retry, .review, .openCapture, .openSetup: .secondary
        case .keepLocal, .wait: .quiet
        case .getSupport: .recovery
        case .blocked: .destructive
        }
    }

    private var actionIcon: String {
        switch state.action {
        case .wait: "pause.circle"
        case .retry: "arrow.clockwise"
        case .review: "checklist"
        case .openCapture: "plus.circle"
        case .openSetup: "slider.horizontal.3"
        case .keepLocal: "iphone"
        case .getSupport: "heart.text.square"
        case .blocked: "hand.raised"
        }
    }
}

public struct StaleSourceLabel: View {
    @Environment(\.ambitionTheme) private var theme

    private let state: AmbitionsLoadingState

    public init(state: AmbitionsLoadingState) {
        self.state = state
    }

    public var body: some View {
        EvidenceLabel(sourceCopy, state: visualState, context: .trust)
            .accessibilityLabel("\(sourceCopy). \(state.message)")
    }

    private var sourceCopy: String {
        switch state {
        case .staleSource: "Stale source"
        case .partialSource: "Partial source"
        case .deniedSource: "Denied source"
        case .sourceConflict: "Conflict review"
        case .packUnavailable: "Pack unavailable"
        case .iCloudUnavailable: "iCloud unavailable"
        case .localOnly: "Local only"
        case .privacySensitive: "Private"
        case .crisisSupport: "Support"
        case .unsafeBlocked: "Blocked"
        case .updatePending: "Update pending"
        case .needsReview: "Needs review"
        default: state.action.title
        }
    }

    private var visualState: LivingVisualState {
        switch state {
        case .empty, .noDataYet, .localOnly: .empty
        case .loading, .waiting, .updatePending: .calm
        case .recovery, .overwhelmingDay: .recovery
        case .privacySensitive, .iCloudUnavailable: .sensitive
        case .crisisSupport, .unsafeBlocked, .sourceConflict: .pressured
        case .staleSource, .partialSource, .deniedSource, .packUnavailable,
             .needsReview, .disabledPendingValidation, .setupNeeded:
            .stale
        }
    }
}

public struct RecoveryPromptModule: View {
    private let state: AmbitionsLoadingState
    private let action: @MainActor () -> Void

    public init(
        state: AmbitionsLoadingState = .recovery,
        action: @escaping @MainActor () -> Void
    ) {
        self.state = state
        self.action = action
    }

    public var body: some View {
        AmbitionsLoadingStatePrimitive(state: state, action: action)
    }
}

extension AmbitionSemanticState {
    var visualState: AmbitionVisualState {
        switch self {
        case .confidenceHigh, .trust, .success, .accessibilityVerified: .success
        case .confidenceMedium, .focus, .protected, .capture, .calendarDerived: .selected
        case .confidenceLow, .caution, .review, .risk, .accessibilityUnverified: .warning
        case .recovery: .celebration
        case .neutral, .waiting: .default
        }
    }

    func accentColor(in theme: AmbitionTheme) -> Color {
        theme.semanticStyle(for: self).accent
    }
}
#endif
