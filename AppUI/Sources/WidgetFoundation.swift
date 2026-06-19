#if canImport(SwiftUI)
import AmbitionsDesignSystem
import SwiftUI

// Package-local widget metadata stays here intentionally; these names describe widget routing, not shared design-system chrome.
public enum AmbitionsWidgetFamily: String, CaseIterable, Identifiable, Sendable {
    case dailyTargets
    case focusNow
    case freeTime
    case goalsList
    case milestonePrompt
    case ritualSummary
    case ritualRhythm
    case insightStats
    case weeklyTrend
    case recentActivity
    case profileSummary
    case celebration
    case settingsGroup

    public var id: String { rawValue }
}

public enum WidgetDisplayPriority: Int, CaseIterable, Comparable, Sendable {
    case background = 0
    case supporting = 25
    case standard = 50
    case high = 75
    case hero = 100

    public static func < (lhs: WidgetDisplayPriority, rhs: WidgetDisplayPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public enum WidgetDisplayVariant: String, CaseIterable, Sendable {
    case compact
    case medium
    case expanded
}

// Adapter-side chrome labels remain package-local to avoid reintroducing duplicate shared primitives.
public enum WidgetChromeStyle: String, CaseIterable, Sendable {
    case widgetCard
    case appCard
    case heroCard
}

public enum WidgetActionKind: String, CaseIterable, Hashable, Sendable {
    case complete
    case delay
    case skip
    case expand
    case collapse
    case markHelpful
    case askForSmallerStep
    case askWhyThisMatters
    case openDetail
    case quickLog
    case refinePlan
    case dismiss
}

public struct WidgetIdentity: Identifiable, Hashable, Sendable {
    public let family: AmbitionsWidgetFamily
    public let instanceID: String
    public let analyticsID: String?
    public let debugLabel: String?

    public init(
        family: AmbitionsWidgetFamily,
        instanceID: String,
        analyticsID: String? = nil,
        debugLabel: String? = nil
    ) {
        self.family = family
        self.instanceID = instanceID
        self.analyticsID = analyticsID
        self.debugLabel = debugLabel
    }

    public var id: String { "\(family.rawValue)-\(instanceID)" }
}

public struct WidgetAction: Identifiable, Hashable, Sendable {
    public let identity: WidgetIdentity
    public let kind: WidgetActionKind
    public let payload: String?

    public init(identity: WidgetIdentity, kind: WidgetActionKind, payload: String? = nil) {
        self.identity = identity
        self.kind = kind
        self.payload = payload
    }

    public var id: String {
        [identity.id, kind.rawValue, payload ?? "none"].joined(separator: "::")
    }
}

public typealias WidgetActionHandler = @MainActor @Sendable (WidgetAction) -> Void
public typealias WidgetVoidAction = @MainActor @Sendable () -> Void

@MainActor
public func makeWidgetAction(
    identity: WidgetIdentity,
    kind: WidgetActionKind,
    handler: WidgetActionHandler?
) -> WidgetVoidAction? {
    guard let handler else { return nil }

    let action: WidgetVoidAction = {
        handler(WidgetAction(identity: identity, kind: kind))
    }
    return action
}

public struct WidgetEmptyState: Hashable, Sendable {
    public let title: String
    public let message: String
    public let icon: String
    public let actionTitle: String?

    public init(title: String, message: String, icon: String, actionTitle: String? = nil) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
    }
}

public struct WidgetErrorState: Hashable, Sendable {
    public let title: String
    public let message: String
    public let recoveryTitle: String?

    public init(title: String, message: String, recoveryTitle: String? = nil) {
        self.title = title
        self.message = message
        self.recoveryTitle = recoveryTitle
    }
}

public enum WidgetState<Content: Sendable>: Sendable {
    case loading
    case empty(WidgetEmptyState)
    case ready(Content)
    case error(WidgetErrorState)
}

public struct WidgetMetadata: Sendable {
    public let identity: WidgetIdentity
    public let priority: WidgetDisplayPriority
    public let variant: WidgetDisplayVariant
    public let chrome: WidgetChromeStyle
    public let supportedActions: Set<WidgetActionKind>

    public init(
        identity: WidgetIdentity,
        priority: WidgetDisplayPriority,
        variant: WidgetDisplayVariant,
        chrome: WidgetChromeStyle,
        supportedActions: Set<WidgetActionKind>
    ) {
        self.identity = identity
        self.priority = priority
        self.variant = variant
        self.chrome = chrome
        self.supportedActions = supportedActions
    }
}

/// Widget-facing adapter output consumed directly by SwiftUI views.
/// Keep planner/orchestrator shaping in the view model and keep view structs
/// focused on rendering and upward intent emission.
public struct WidgetSnapshot<Content: Sendable>: Sendable {
    public let metadata: WidgetMetadata
    public let state: WidgetState<Content>

    public init(metadata: WidgetMetadata, state: WidgetState<Content>) {
        self.metadata = metadata
        self.state = state
    }
}

/// App-side widget adapters should expose one snapshot per widget family and
/// accept dependencies through initializers rather than reaching into global
/// persistence or engines from inside SwiftUI view code.
public protocol AmbitionsWidgetViewModeling: Sendable {
    associatedtype Content: Sendable

    var snapshot: WidgetSnapshot<Content> { get }
}

public extension AmbitionsWidgetViewModeling {
    var identity: WidgetIdentity { snapshot.metadata.identity }
    var variant: WidgetDisplayVariant { snapshot.metadata.variant }
    var priority: WidgetDisplayPriority { snapshot.metadata.priority }
}

public struct WidgetInlineActionDescriptor: Identifiable, Hashable, Sendable {
    public let kind: WidgetActionKind
    public let title: String
    public let icon: String
    public let state: AmbitionVisualState

    public init(
        kind: WidgetActionKind,
        title: String,
        icon: String,
        state: AmbitionVisualState = .default
    ) {
        self.kind = kind
        self.title = title
        self.icon = icon
        self.state = state
    }

    public var id: String { "\(kind.rawValue)-\(title)" }
}

public struct WidgetStat: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let value: String
    public let detail: String?
    public let icon: String
    public let state: AmbitionVisualState

    public init(
        id: String,
        title: String,
        value: String,
        detail: String? = nil,
        icon: String,
        state: AmbitionVisualState = .default
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.detail = detail
        self.icon = icon
        self.state = state
    }
}

public struct WidgetProgressItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let detail: String?
    public let progress: Double
    public let trailingValue: String?
    public let statusLabel: String?
    public let state: AmbitionVisualState

    public init(
        id: String,
        title: String,
        detail: String? = nil,
        progress: Double,
        trailingValue: String? = nil,
        statusLabel: String? = nil,
        state: AmbitionVisualState = .default
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.progress = progress
        self.trailingValue = trailingValue
        self.statusLabel = statusLabel
        self.state = state
    }
}

public struct WidgetActivityItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let timestamp: String
    public let icon: String
    public let badge: String?

    public init(
        id: String,
        title: String,
        subtitle: String,
        timestamp: String,
        icon: String,
        badge: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
        self.icon = icon
        self.badge = badge
    }
}

public struct WidgetSettingItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let icon: String
    public let valueLabel: String?

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        icon: String,
        valueLabel: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.valueLabel = valueLabel
    }
}

public struct WidgetTrendPoint: Identifiable, Hashable, Sendable {
    public let id: String
    public let label: String
    public let value: Double

    public init(id: String, label: String, value: Double) {
        self.id = id
        self.label = label
        self.value = value
    }
}

#endif
