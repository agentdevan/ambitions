import AmbitionsDesignSystem
import Foundation

extension PreviewTimeScenarios {
    static let seededWeekDays: [TimeElasticWeekDayState] = [
        TimeElasticWeekDayState(
            id: "day-0",
            weekdayLabel: "Mon",
            dateLabel: "20",
            level: .steady,
            intensity: 0.62,
            roomLabel: "Steady load",
            capacityLabel: "2 blocks",
            highlight: "Native shell is anchoring this day.",
            blocks: [
                TimeWeekBlockState(id: "m1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Review shell regressions", detail: "Keep the next pass small enough to stay believable.", goalLabel: "Ship the native shell", timingLabel: "Protect Apr 20", kind: .protected, visualState: .selected),
                TimeWeekBlockState(id: "m2", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Close shell polish notes", detail: "Only keep the fixes that improve clarity.", goalLabel: "Ship the native shell", timingLabel: "Flexible", kind: .flexible, visualState: .default)
            ],
            overflowCount: 0,
            openWindow: TimeOpenWindowState(title: "Usable room", detail: "One smaller step still fits here if the day stays protected.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
        ),
        TimeElasticWeekDayState(
            id: "day-1",
            weekdayLabel: "Tue",
            dateLabel: "21",
            level: .overloaded,
            intensity: 1.0,
            roomLabel: "Needs relief",
            capacityLabel: "4 blocks",
            highlight: "Pressure is stacking here.",
            blocks: [
                TimeWeekBlockState(id: "t1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Fix shell regressions", detail: "Close the top 3 regressions only.", goalLabel: "Ship the native shell", timingLabel: "Due Apr 21", kind: .fixed, visualState: .warning),
                TimeWeekBlockState(id: "t2", target: GoalRouteTarget(goalID: "preview-goal-3"), title: "Answer roadmap clarifications", detail: "Resolve the missing scope questions before shaping more UI.", goalLabel: "Refine roadmap", timingLabel: "Due Apr 21", kind: .fixed, visualState: .warning),
                TimeWeekBlockState(id: "t3", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Update preview notes", detail: "Only document what really changed in the shell.", goalLabel: "Ship the native shell", timingLabel: "Flexible", kind: .flexible, visualState: .selected)
            ],
            overflowCount: 1,
            openWindow: nil
        ),
        TimeElasticWeekDayState(
            id: "day-2",
            weekdayLabel: "Wed",
            dateLabel: "22",
            level: .open,
            intensity: 0.45,
            roomLabel: "Open day",
            capacityLabel: "No blocks yet",
            highlight: "Retention loop could fit here.",
            blocks: [],
            overflowCount: 0,
            openWindow: TimeOpenWindowState(title: "Open window", detail: "This day can carry one believable step without turning calendar-dense.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .success)
        ),
        TimeElasticWeekDayState(
            id: "day-3",
            weekdayLabel: "Thu",
            dateLabel: "23",
            level: .tight,
            intensity: 0.82,
            roomLabel: "Little room left",
            capacityLabel: "3 blocks",
            highlight: "This day needs protected edges.",
            blocks: [
                TimeWeekBlockState(id: "th1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Manual simulator audit", detail: "Check reduced motion, readability, and shell continuity.", goalLabel: "Ship the native shell", timingLabel: "Protect Apr 23", kind: .protected, visualState: .selected),
                TimeWeekBlockState(id: "th2", target: GoalRouteTarget(goalID: "preview-goal-3"), title: "Refine roadmap notes", detail: "Keep the clarification answer honest and small.", goalLabel: "Refine roadmap", timingLabel: "Flexible", kind: .flexible, visualState: .warning)
            ],
            overflowCount: 1,
            openWindow: TimeOpenWindowState(title: "Keep breathing room", detail: "The day can still hold, but only if the remaining pocket stays protected.", suggestionLabel: nil, target: nil, visualState: .default)
        ),
        TimeElasticWeekDayState(
            id: "day-4",
            weekdayLabel: "Fri",
            dateLabel: "24",
            level: .steady,
            intensity: 0.66,
            roomLabel: "Room remains",
            capacityLabel: "2 blocks",
            highlight: "Review notes are anchoring this day.",
            blocks: [
                TimeWeekBlockState(id: "f1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Write closeout notes", detail: "Summarize only what was truly verified.", goalLabel: "Ship the native shell", timingLabel: "Flexible", kind: .flexible, visualState: .default),
                TimeWeekBlockState(id: "f2", target: GoalRouteTarget(goalID: "preview-goal-3"), title: "Polish roadmap wording", detail: "Remove any batch drift before wrapping the week.", goalLabel: "Refine roadmap", timingLabel: "Flexible", kind: .flexible, visualState: .default)
            ],
            overflowCount: 0,
            openWindow: TimeOpenWindowState(title: "Usable room", detail: "There is still enough room to protect one smaller step.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
        ),
        TimeElasticWeekDayState(
            id: "day-5",
            weekdayLabel: "Sat",
            dateLabel: "25",
            level: .open,
            intensity: 0.42,
            roomLabel: "Wide room",
            capacityLabel: "No blocks yet",
            highlight: "Keep the room visible.",
            blocks: [],
            overflowCount: 0,
            openWindow: TimeOpenWindowState(title: "Leave this open", detail: "Not every open pocket needs to be filled. Open room keeps the week doable.", suggestionLabel: nil, target: nil, visualState: .default)
        ),
        TimeElasticWeekDayState(
            id: "day-6",
            weekdayLabel: "Sun",
            dateLabel: "26",
            level: .steady,
            intensity: 0.6,
            roomLabel: "Steady load",
            capacityLabel: "1 block",
            highlight: "The week resets calmly here.",
            blocks: [
                TimeWeekBlockState(id: "su1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Quiet weekly reset", detail: "Leave a calm note about what actually held.", goalLabel: "Ship the native shell", timingLabel: "Protect Apr 26", kind: .protected, visualState: .success)
            ],
            overflowCount: 0,
            openWindow: TimeOpenWindowState(title: "Usable room", detail: "There is enough room for one lighter follow-through if it stays gentle.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
        )
    ]

    static let seededGoalShapingItems: [TimeGoalShapingItem] = [
        TimeGoalShapingItem(
            id: "shape-goal-native",
            target: GoalRouteTarget(goalID: "preview-goal-1"),
            goalTitle: "Ship the native shell",
            weekRelationship: "Visible and narrow",
            pressureLabel: "Kept in view",
            attentionReason: "This goal has a believable lane, but it depends on Tuesday and Thursday staying protected.",
            nextMoveLabel: "Review shell regressions",
            visualState: .selected
        ),
        TimeGoalShapingItem(
            id: "shape-goal-retention",
            target: GoalRouteTarget(goalID: "preview-goal-2"),
            goalTitle: "Retention loop",
            weekRelationship: "Still outside the week",
            pressureLabel: "Carryover",
            attentionReason: "This goal is active but the current week still does not give it believable room.",
            nextMoveLabel: "Add one small step on Wednesday",
            visualState: .warning
        ),
        TimeGoalShapingItem(
            id: "shape-goal-roadmap",
            target: GoalRouteTarget(goalID: "preview-goal-3"),
            goalTitle: "Refine roadmap",
            weekRelationship: "Visible, but straining",
            pressureLabel: "Needs lighter ask",
            attentionReason: "Recent friction suggests the current step is heavier than the week can comfortably carry.",
            nextMoveLabel: "Resolve the missing scope questions before shaping more UI",
            visualState: .warning
        )
    ]

    static let seededShapingActions: [TimeShapingActionState] = [
        TimeShapingActionState(kind: .edit, title: "Edit", subtitle: "Fix shell regressions", recommendation: "Start with the clearest existing block instead of redrawing the whole week.", systemImage: "square.and.pencil", state: .selected, goalTarget: GoalRouteTarget(goalID: "preview-goal-1"), timeRoute: nil),
        TimeShapingActionState(kind: .patch, title: "Patch", subtitle: "Give missing goals one believable lane instead of spreading them everywhere.", recommendation: "Use Wednesday or Friday to patch the retention loop into real room.", systemImage: "wand.and.stars", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), timeRoute: nil),
        TimeShapingActionState(kind: .protect, title: "Protect", subtitle: "Protect the calmest pocket before pressure spills into it.", recommendation: "The cleanest protection step is to keep Wednesday or Sunday from filling up reactively.", systemImage: "shield", state: .success, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), timeRoute: nil),
        TimeShapingActionState(kind: .lighten, title: "Lighten", subtitle: "Pressure is stacking here.", recommendation: "Shrink or reschedule the heaviest ask before the week starts feeling performative.", systemImage: "sun.max", state: .warning, goalTarget: nil, timeRoute: nil, interactionIntent: .openGlobalCapture)
    ]

    static let seededSecondaryDestinations: [TimeSecondaryDestination] = [
        TimeSecondaryDestination(id: "time-rituals", title: "Ritual loops", detail: "Review the repeatable loops that can steady or crowd the week.", valueLabel: "1", icon: "repeat", visualState: .selected, timeRoute: .habits),
        TimeSecondaryDestination(id: "time-held-input", title: "Open Capture composer", detail: "2 captures can stay outside Time until you place, park, or archive them.", valueLabel: "2", icon: "square.and.pencil", visualState: .warning, timeRoute: nil, interactionIntent: .openGlobalCapture),
        TimeSecondaryDestination(id: "time-weekly-review", title: "Weekly review", detail: "Close the current week by shaping carry-forward and unresolved capture pressure without leaving Time.", valueLabel: "Tight", icon: "arrow.triangle.branch", visualState: .selected, timeRoute: .weeklyReview)
    ]
}
