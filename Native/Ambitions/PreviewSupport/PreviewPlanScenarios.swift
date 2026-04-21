import AmbitionsDesignSystem
import Foundation

enum PreviewPlanScenarios {
    static let seeded = PlanDashboard(
        mode: .active,
        title: "This week has a visible shape",
        subtitle: "Active goals, open planning pressure, and repeatable routines are gathered here before the day gets crowded.",
        timeframeLabel: "Apr 20-Apr 26",
        posture: PlanPostureState(
            title: "The week is believable but tight",
            detail: "The current plan can hold, but open captures or tight evaluations need review.",
            label: "Tight",
            visualState: .selected
        ),
        weeklyIntent: PlanWeeklyIntentSummary(
            title: "This week is carrying real goal work",
            detail: "Visible steps exist, but open captures and light friction are the main reasons the week still needs shaping attention.",
            attentionLabel: "Review pressure",
            goalCountLabel: "2 of 3 goals represented"
        ),
        metrics: [
            MetricSummary(id: "plan-goal-coverage", title: "Goal coverage", value: "2/3", detail: "Active goals with visible work", icon: "target"),
            MetricSummary(id: "plan-week-work", title: "Visible work", value: "5", detail: "Current steps in this weekly view", icon: "calendar"),
            MetricSummary(id: "plan-pressure", title: "Planning pressure", value: "2", detail: "Captures, blockers, and clarification", icon: "exclamationmark.triangle"),
            MetricSummary(id: "plan-routines", title: "Routines", value: "1", detail: "Habit-like goals stay under Plan", icon: "repeat")
        ],
        goalShapingItems: [
            PlanGoalShapingItem(
                id: "plan-goal-native",
                target: GoalRouteTarget(goalID: "preview-goal-1"),
                goalTitle: "Ship the native shell",
                summary: "Draft the weekly review notes and keep the next pass small enough to stay believable.",
                pressureLabel: "Tight",
                attentionReason: "This goal is visible in the week, but the surrounding pressure still needs review.",
                shellSummary: nil,
                visualState: .selected
            ),
            PlanGoalShapingItem(
                id: "plan-goal-retention",
                target: GoalRouteTarget(goalID: "preview-goal-2"),
                goalTitle: "Retention loop",
                summary: "No current step is visible in this week's shaping view yet.",
                pressureLabel: "Missing from week",
                attentionReason: "The goal is active, but the week does not yet show a believable step for it.",
                shellSummary: nil,
                visualState: .default
            )
        ],
        focusItems: [
            PlanFocusItem(
                id: "preview-plan-focus",
                target: GoalRouteTarget(goalID: "preview-goal-1"),
                title: "Draft the weekly review notes",
                subtitle: "Start with the smallest honest pass.",
                timingLabel: "Target Apr 22",
                statusLabel: "Planned",
                goalLabel: "Ship the native shell",
                visualState: .selected
            )
        ],
        pressureItems: [
            PlanPressureItem(id: "preview-captures", title: "Open captures", detail: "Captured ideas are waiting to be seeded, attached, or archived.", valueLabel: "2", icon: AppTab.captures.systemImage, visualState: .warning),
            PlanPressureItem(id: "preview-clarity", title: "Planning questions", detail: "No draft is currently blocked on missing shape.", valueLabel: "0", icon: "questionmark.bubble", visualState: .success),
            PlanPressureItem(id: "preview-friction", title: "Recent friction", detail: "Correction signals suggest this week may need smaller asks.", valueLabel: "1", icon: "waveform.path.ecg", visualState: .selected)
        ],
        secondaryDestinations: [
            PlanSecondaryDestination(id: "plan-habits", title: "Routines and habits", detail: "Review the repeatable loops that can steady or crowd this week.", valueLabel: "1", icon: AppTab.habits.systemImage, visualState: .selected)
        ],
        emptyTitle: nil,
        emptyMessage: nil
    )

    static let empty = PlanDashboard(
        mode: .empty,
        title: "Shape the week around real goals",
        subtitle: "Plan will stay honest as goals, captures, and routine work enter the local store.",
        timeframeLabel: "Apr 20-Apr 26",
        posture: PlanPostureState(title: "The week is open", detail: "There is no active local planning pressure yet.", label: "Quiet", visualState: .default),
        weeklyIntent: PlanWeeklyIntentSummary(
            title: "Nothing is claiming the week yet",
            detail: "Plan stays quiet until real goals, captures, or routine work create something worth shaping.",
            attentionLabel: "Open week",
            goalCountLabel: "0 active goals"
        ),
        metrics: [
            MetricSummary(id: "plan-goal-coverage", title: "Goal coverage", value: "0/1", detail: "No active goals yet", icon: "target"),
            MetricSummary(id: "plan-week-work", title: "Visible work", value: "0", detail: "Current steps in this weekly view", icon: "calendar"),
            MetricSummary(id: "plan-pressure", title: "Planning pressure", value: "0", detail: "Captures, blockers, and clarification", icon: "exclamationmark.triangle"),
            MetricSummary(id: "plan-routines", title: "Routines", value: "0", detail: "Habit-like goals stay under Plan", icon: "repeat")
        ],
        goalShapingItems: [],
        focusItems: [],
        pressureItems: [],
        secondaryDestinations: [
            PlanSecondaryDestination(id: "plan-habits", title: "Routines and habits", detail: "No repeatable loops are live yet. When they exist, they stay subordinate to weekly shaping here.", valueLabel: "0", icon: AppTab.habits.systemImage, visualState: .default)
        ],
        emptyTitle: "No weekly plan pressure yet",
        emptyMessage: "Create a goal or capture an idea, and Plan will show what needs shaping without inventing work."
    )
}
