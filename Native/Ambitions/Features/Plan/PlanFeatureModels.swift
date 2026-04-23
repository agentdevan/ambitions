import AmbitionsDesignSystem
import Foundation

enum PlanDashboardMode: Sendable {
    case empty
    case active
}

enum PlanWeekPressureLevel: String, Sendable, CaseIterable {
    case open
    case steady
    case tight
    case overloaded

    var title: String {
        switch self {
        case .open: "Open room"
        case .steady: "Steady"
        case .tight: "Tight"
        case .overloaded: "Overloaded"
        }
    }

    var icon: String {
        switch self {
        case .open: "sparkles"
        case .steady: "circle.lefthalf.filled"
        case .tight: "calendar.badge.clock"
        case .overloaded: "exclamationmark.triangle.fill"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .open: .success
        case .steady: .selected
        case .tight: .warning
        case .overloaded: .warning
        }
    }
}

enum PlanWeekBlockKind: String, Sendable {
    case fixed
    case flexible
    case protected

    var title: String {
        switch self {
        case .fixed: "Fixed"
        case .flexible: "Flexible"
        case .protected: "Protected"
        }
    }

    var icon: String {
        switch self {
        case .fixed: "pin.fill"
        case .flexible: "arrow.left.and.right"
        case .protected: "shield.lefthalf.filled"
        }
    }
}

enum PlanWeekPrimaryActionKind: String, Sendable {
    case shapeWeek = "shape_week"
    case lightenWeek = "lighten_week"
    case useRoom = "use_room"
    case resolveCarryover = "resolve_carryover"
}

enum PlanShapingActionKind: String, Sendable, CaseIterable {
    case edit
    case patch
    case protect
    case lighten

    var title: String {
        switch self {
        case .edit: "Edit"
        case .patch: "Patch"
        case .protect: "Protect"
        case .lighten: "Lighten"
        }
    }

    var systemImage: String {
        switch self {
        case .edit: "square.and.pencil"
        case .patch: "wand.and.stars"
        case .protect: "shield"
        case .lighten: "sun.max"
        }
    }
}

struct PlanHeroPillState: Identifiable, Sendable, Hashable {
    let title: String
    let icon: String?
    let state: AmbitionVisualState

    var id: String { [title, icon ?? "", state.rawValue].joined(separator: "|") }
}

struct PlanRealityHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let roomSummary: String
    let pressureSummary: String
    let contextPills: [PlanHeroPillState]
    let trustWhisper: String
}

struct PlanWeekPrimaryAction: Sendable {
    let kind: PlanWeekPrimaryActionKind
    let title: String
    let subtitle: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct PlanPressureScrubberPoint: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: PlanWeekPressureLevel
    let pressureValue: Double
    let roomLabel: String
    let summary: String
}

struct PlanPressureScrubberState: Sendable {
    let title: String
    let subtitle: String
    let defaultDayID: String
    let points: [PlanPressureScrubberPoint]
}

struct PlanWeekBlockState: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let title: String
    let detail: String
    let goalLabel: String
    let timingLabel: String
    let kind: PlanWeekBlockKind
    let visualState: AmbitionVisualState
}

struct PlanOpenWindowState: Sendable {
    let title: String
    let detail: String
    let suggestionLabel: String?
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct PlanWindowMagnetismState: Sendable {
    let title: String
    let detail: String
    let dayLabel: String
    let suggestionTitle: String
    let suggestionDetail: String
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct PlanElasticWeekDayState: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: PlanWeekPressureLevel
    let intensity: Double
    let roomLabel: String
    let capacityLabel: String
    let highlight: String
    let blocks: [PlanWeekBlockState]
    let overflowCount: Int
    let openWindow: PlanOpenWindowState?
}

struct PlanBelievabilityState: Sendable {
    let title: String
    let detail: String
    let label: String
    let supportLabel: String
    let visualState: AmbitionVisualState
}

struct PlanExecutionResilienceLane: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let recommendation: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct PlanExecutionResilienceState: Sendable {
    let title: String
    let subtitle: String
    let calmExplanation: String
    let focusProtection: String
    let tradeoffFraming: String
    let lanes: [PlanExecutionResilienceLane]
    let windowMagnetism: PlanWindowMagnetismState?
}

struct PlanGoalShapingItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let goalTitle: String
    let weekRelationship: String
    let pressureLabel: String
    let attentionReason: String
    let nextMoveLabel: String
    let visualState: AmbitionVisualState
}

struct PlanShapingActionState: Identifiable, Sendable {
    let kind: PlanShapingActionKind
    let title: String
    let subtitle: String
    let recommendation: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?

    var id: String { kind.rawValue }
}

struct PlanSecondaryDestination: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let visualState: AmbitionVisualState
    let planRoute: PlanRouteTarget?
}

struct WeeklyReviewHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let continuityLabel: String
    let contextPills: [PlanHeroPillState]
}

struct WeeklyReviewCarryForwardItem: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let bridgeLabel: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
}

struct WeeklyReviewDashboard: Sendable {
    let timeframeLabel: String
    let hero: WeeklyReviewHeroState
    let summaryTitle: String
    let summaryDetail: String
    let carryForwardItems: [WeeklyReviewCarryForwardItem]
    let captureSummary: String
    let habitSummary: String
    let returnActionTitle: String
    let returnActionSubtitle: String
    let returnPlanRoute: PlanRouteTarget?
    let splitPaneContext: PlanWindowMagnetismState?
}

struct PlanDashboard: Sendable {
    let mode: PlanDashboardMode
    let timeframeLabel: String
    let hero: PlanRealityHeroState
    let primaryAction: PlanWeekPrimaryAction
    let pressureScrubber: PlanPressureScrubberState
    let weekDays: [PlanElasticWeekDayState]
    let believability: PlanBelievabilityState
    let resilience: PlanExecutionResilienceState
    let goalShapingItems: [PlanGoalShapingItem]
    let shapingActions: [PlanShapingActionState]
    let secondaryDestinations: [PlanSecondaryDestination]
    let emptyTitle: String?
    let emptyMessage: String?
}
