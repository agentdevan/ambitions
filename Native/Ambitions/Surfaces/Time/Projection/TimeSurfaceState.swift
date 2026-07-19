import AmbitionsDesignSystem
import Foundation

enum TimeSurfaceMode: Sendable {
    case empty
    case active
}
enum TimeWeekPressureLevel: String, Sendable, CaseIterable {
    case open
    case steady
    case tight
    case fragile
    case overloaded

    var title: String {
        switch self {
        case .open: "Open room"
        case .steady: "Steady"
        case .tight: "Tight"
        case .fragile: "Too much planned"
        case .overloaded: "Overloaded"
        }
    }

    var icon: String {
        switch self {
        case .open: "sparkles"
        case .steady: "circle.lefthalf.filled"
        case .tight: "calendar.badge.clock"
        case .fragile: "exclamationmark.triangle"
        case .overloaded: "exclamationmark.triangle.fill"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .open: .success
        case .steady: .selected
        case .tight: .warning
        case .fragile: .warning
        case .overloaded: .warning
        }
    }
}

enum TimeWeekBlockKind: String, Sendable {
    case fixed
    case flexible
    case protected

    var title: String {
        switch self {
        case .fixed: "Fixed"
        case .flexible: "Flexible"
        case .protected: "Time set aside"
        }
    }

    var icon: String {
        switch self {
        case .fixed: "pin.fill"
        case .flexible: "arrow.left.and.right"
        case .protected: "clock.badge.checkmark"
        }
    }
}

enum TimeWeekPrimaryActionKind: String, Sendable {
    case shapeWeek = "shape_week"
    case lightenWeek = "lighten_week"
    case useRoom = "use_room"
    case resolveCarryover = "resolve_carryover"
}

enum TimeShapingActionKind: String, Sendable, CaseIterable {
    case edit
    case patch
    case protect
    case lighten

    var title: String {
        switch self {
        case .edit: "Edit"
        case .patch: "Patch"
        case .protect: "Keep this"
        case .lighten: "Lighten"
        }
    }

    var systemImage: String {
        switch self {
        case .edit: "square.and.pencil"
        case .patch: "wand.and.stars"
        case .protect: "checkmark.circle"
        case .lighten: "sun.max"
        }
    }
}

enum TimeCalendarAwarenessStatus: String, Sendable {
    case unavailable
    case baseline
    case calendarAware
    case denied
    case writeOnly
}

struct TimeCalendarAwarenessState: Sendable {
    let status: TimeCalendarAwarenessStatus
    let title: String
    let detail: String
    let primaryActionTitle: String
    let primaryActionSystemImage: String
    let valueLabel: String
    let sourceLabel: String
    let visualState: AmbitionVisualState
    let canRequestCalendarRead: Bool
}

struct TimeHeroPillState: Identifiable, Sendable, Hashable {
    let title: String
    let icon: String?
    let state: AmbitionVisualState

    var id: String { [title, icon ?? "", state.rawValue].joined(separator: "|") }
}

struct TimeRealityHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let roomSummary: String
    let pressureSummary: String
    let contextPills: [TimeHeroPillState]
    let trustWhisper: String
}

struct TimeWeekPrimaryAction: Sendable {
    let kind: TimeWeekPrimaryActionKind
    let title: String
    let subtitle: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
    let interactionIntent: TimeInteractionIntent?

    init(
        kind: TimeWeekPrimaryActionKind,
        title: String,
        subtitle: String,
        systemImage: String,
        state: AmbitionVisualState,
        goalTarget: GoalRouteTarget?,
        timeRoute: TimeRouteTarget?,
        interactionIntent: TimeInteractionIntent? = nil
    ) {
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.state = state
        self.goalTarget = goalTarget
        self.timeRoute = timeRoute
        self.interactionIntent = interactionIntent
    }
}

struct TimePressureScrubberPoint: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: TimeWeekPressureLevel
    let pressureValue: Double
    let roomLabel: String
    let summary: String
}

struct TimePressureScrubberState: Sendable {
    let title: String
    let subtitle: String
    let defaultDayID: String
    let points: [TimePressureScrubberPoint]
}

struct TimeWeekBlockState: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let title: String
    let detail: String
    let goalLabel: String
    let timingLabel: String
    let kind: TimeWeekBlockKind
    let visualState: AmbitionVisualState
}

struct TimeOpenWindowState: Sendable {
    let title: String
    let detail: String
    let suggestionLabel: String?
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct TimeWindowMagnetismState: Sendable {
    let title: String
    let detail: String
    let dayLabel: String
    let suggestionTitle: String
    let suggestionDetail: String
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct TimeElasticWeekDayState: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: TimeWeekPressureLevel
    let intensity: Double
    let roomLabel: String
    let capacityLabel: String
    let highlight: String
    let blocks: [TimeWeekBlockState]
    let overflowCount: Int
    let openWindow: TimeOpenWindowState?
}

struct TimeBelievabilityState: Sendable {
    let title: String
    let detail: String
    let label: String
    let supportLabel: String
    let visualState: AmbitionVisualState
}

struct TimeExecutionResilienceLane: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let recommendation: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
    let interactionIntent: TimeInteractionIntent?

    init(
        id: String,
        title: String,
        detail: String,
        recommendation: String,
        state: AmbitionVisualState,
        goalTarget: GoalRouteTarget?,
        timeRoute: TimeRouteTarget?,
        interactionIntent: TimeInteractionIntent? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.recommendation = recommendation
        self.state = state
        self.goalTarget = goalTarget
        self.timeRoute = timeRoute
        self.interactionIntent = interactionIntent
    }
}

struct TimeExecutionResilienceState: Sendable {
    let title: String
    let subtitle: String
    let calmExplanation: String
    let focusProtection: String
    let tradeoffFraming: String
    let lanes: [TimeExecutionResilienceLane]
    let windowMagnetism: TimeWindowMagnetismState?
}

struct TimeGoalShapingItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let goalTitle: String
    let weekRelationship: String
    let pressureLabel: String
    let attentionReason: String
    let nextMoveLabel: String
    let visualState: AmbitionVisualState
}

struct TimeShapingActionState: Identifiable, Sendable {
    let kind: TimeShapingActionKind
    let title: String
    let subtitle: String
    let recommendation: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
    let interactionIntent: TimeInteractionIntent?

    var id: String { kind.rawValue }

    init(
        kind: TimeShapingActionKind,
        title: String,
        subtitle: String,
        recommendation: String,
        systemImage: String,
        state: AmbitionVisualState,
        goalTarget: GoalRouteTarget?,
        timeRoute: TimeRouteTarget?,
        interactionIntent: TimeInteractionIntent? = nil
    ) {
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.recommendation = recommendation
        self.systemImage = systemImage
        self.state = state
        self.goalTarget = goalTarget
        self.timeRoute = timeRoute
        self.interactionIntent = interactionIntent
    }
}
