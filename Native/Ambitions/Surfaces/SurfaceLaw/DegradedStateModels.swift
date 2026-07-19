import AmbitionsDesignSystem
import Foundation

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
    case time
    case insights
    case profileTrust
    case rituals
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
    let accessibilitySummary: String

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
        self.accessibilitySummary = [
            title,
            explanation,
            primaryAction.title,
            secondaryAction?.title
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
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
