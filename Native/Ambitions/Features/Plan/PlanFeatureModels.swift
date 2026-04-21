import AmbitionsDesignSystem
import Foundation

enum PlanDashboardMode: Sendable {
    case empty
    case active
}

struct PlanPostureState: Sendable {
    let title: String
    let detail: String
    let label: String
    let visualState: AmbitionVisualState
}

struct PlanWeeklyIntentSummary: Sendable {
    let title: String
    let detail: String
    let attentionLabel: String
    let goalCountLabel: String
}

struct PlanFocusItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let title: String
    let subtitle: String
    let timingLabel: String
    let statusLabel: String
    let goalLabel: String
    let visualState: AmbitionVisualState
}

struct PlanGoalShapingItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let goalTitle: String
    let summary: String
    let pressureLabel: String
    let attentionReason: String
    let shellSummary: GoalShellSummaryState?
    let visualState: AmbitionVisualState
}

struct PlanPressureItem: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let visualState: AmbitionVisualState
}

struct PlanSecondaryDestination: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let visualState: AmbitionVisualState
}

struct PlanDashboard: Sendable {
    let mode: PlanDashboardMode
    let title: String
    let subtitle: String
    let timeframeLabel: String
    let posture: PlanPostureState
    let weeklyIntent: PlanWeeklyIntentSummary
    let metrics: [MetricSummary]
    let goalShapingItems: [PlanGoalShapingItem]
    let focusItems: [PlanFocusItem]
    let pressureItems: [PlanPressureItem]
    let secondaryDestinations: [PlanSecondaryDestination]
    let emptyTitle: String?
    let emptyMessage: String?
}
