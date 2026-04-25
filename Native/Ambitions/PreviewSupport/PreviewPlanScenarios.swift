import AmbitionsDesignSystem
import Foundation

enum PreviewPlanScenarios {
    static let seeded = PlanDashboard(
        mode: .active,
        timeframeLabel: "Apr 20-Apr 26",
        hero: PlanRealityHeroState(
            eyebrow: "Reality Model",
            title: "How this week holds together",
            subtitle: "Plan reads the week as room, pressure, and protected structure instead of a dense calendar clone.",
            dominantTruth: "Pressure is clustering into one overloaded day, while two calmer windows still have believable room.",
            roomSummary: "Wednesday and Saturday can still carry one small move without collapsing into calendar noise.",
            pressureSummary: "Open captures and one fragile goal are the loudest reasons the week still needs shaping.",
            contextPills: [
                PlanHeroPillState(title: "Apr 20-Apr 26", icon: "calendar", state: .default),
                PlanHeroPillState(title: "Tight", icon: AppTab.plan.systemImage, state: .selected),
                PlanHeroPillState(title: "2/3 goals visible", icon: "target", state: .selected)
            ],
            trustWhisper: "One active goal is still outside the week, so the current calm is real but incomplete."
        ),
        primaryAction: PlanWeekPrimaryAction(
            kind: .useRoom,
            title: "Use this room",
            subtitle: "Wednesday still has believable room for the retention loop.",
            systemImage: "arrow.down.left.and.arrow.up.right",
            state: .success,
            goalTarget: GoalRouteTarget(goalID: "preview-goal-2"),
            planRoute: nil
        ),
        pressureScrubber: PlanPressureScrubberState(
            title: "Pressure scrubber",
            subtitle: "Scrub the week to inspect where pressure gathers and where room remains.",
            defaultDayID: "day-1",
            points: [
                PlanPressureScrubberPoint(id: "day-0", weekdayLabel: "Mon", dateLabel: "20", level: .steady, pressureValue: 0.62, roomLabel: "Steady load", summary: "Shell work is anchoring the day."),
                PlanPressureScrubberPoint(id: "day-1", weekdayLabel: "Tue", dateLabel: "21", level: .overloaded, pressureValue: 1.0, roomLabel: "Needs relief", summary: "Pressure is stacking here."),
                PlanPressureScrubberPoint(id: "day-2", weekdayLabel: "Wed", dateLabel: "22", level: .open, pressureValue: 0.45, roomLabel: "Open day", summary: "Retention loop could fit here."),
                PlanPressureScrubberPoint(id: "day-3", weekdayLabel: "Thu", dateLabel: "23", level: .tight, pressureValue: 0.82, roomLabel: "Little room left", summary: "This day needs protected edges."),
                PlanPressureScrubberPoint(id: "day-4", weekdayLabel: "Fri", dateLabel: "24", level: .steady, pressureValue: 0.66, roomLabel: "Room remains", summary: "The review notes are anchoring this day."),
                PlanPressureScrubberPoint(id: "day-5", weekdayLabel: "Sat", dateLabel: "25", level: .open, pressureValue: 0.42, roomLabel: "Wide room", summary: "Keep the room visible."),
                PlanPressureScrubberPoint(id: "day-6", weekdayLabel: "Sun", dateLabel: "26", level: .steady, pressureValue: 0.6, roomLabel: "Steady load", summary: "The week resets calmly here.")
            ]
        ),
        weekDays: [
            PlanElasticWeekDayState(
                id: "day-0",
                weekdayLabel: "Mon",
                dateLabel: "20",
                level: .steady,
                intensity: 0.62,
                roomLabel: "Steady load",
                capacityLabel: "2 blocks",
                highlight: "Native shell is anchoring this day.",
                blocks: [
                    PlanWeekBlockState(id: "m1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Review shell regressions", detail: "Keep the next pass small enough to stay believable.", goalLabel: "Ship the native shell", timingLabel: "Protect Apr 20", kind: .protected, visualState: .selected),
                    PlanWeekBlockState(id: "m2", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Close shell polish notes", detail: "Only keep the fixes that improve clarity.", goalLabel: "Ship the native shell", timingLabel: "Flexible", kind: .flexible, visualState: .default)
                ],
                overflowCount: 0,
                openWindow: PlanOpenWindowState(title: "Usable room", detail: "One smaller move still fits here if the day stays protected.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
            ),
            PlanElasticWeekDayState(
                id: "day-1",
                weekdayLabel: "Tue",
                dateLabel: "21",
                level: .overloaded,
                intensity: 1.0,
                roomLabel: "Needs relief",
                capacityLabel: "4 blocks",
                highlight: "Pressure is stacking here.",
                blocks: [
                    PlanWeekBlockState(id: "t1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Fix shell regressions", detail: "Close the top 3 regressions only.", goalLabel: "Ship the native shell", timingLabel: "Due Apr 21", kind: .fixed, visualState: .warning),
                    PlanWeekBlockState(id: "t2", target: GoalRouteTarget(goalID: "preview-goal-3"), title: "Answer roadmap clarifications", detail: "Resolve the missing scope questions before planning more UI.", goalLabel: "Refine roadmap", timingLabel: "Due Apr 21", kind: .fixed, visualState: .warning),
                    PlanWeekBlockState(id: "t3", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Update preview notes", detail: "Only document what really changed in the shell.", goalLabel: "Ship the native shell", timingLabel: "Flexible", kind: .flexible, visualState: .selected)
                ],
                overflowCount: 1,
                openWindow: nil
            ),
            PlanElasticWeekDayState(
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
                openWindow: PlanOpenWindowState(title: "Open window", detail: "This day can carry one believable move without turning calendar-dense.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .success)
            ),
            PlanElasticWeekDayState(
                id: "day-3",
                weekdayLabel: "Thu",
                dateLabel: "23",
                level: .tight,
                intensity: 0.82,
                roomLabel: "Little room left",
                capacityLabel: "3 blocks",
                highlight: "This day needs protected edges.",
                blocks: [
                    PlanWeekBlockState(id: "th1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Manual simulator audit", detail: "Check reduced motion, readability, and shell continuity.", goalLabel: "Ship the native shell", timingLabel: "Protect Apr 23", kind: .protected, visualState: .selected),
                    PlanWeekBlockState(id: "th2", target: GoalRouteTarget(goalID: "preview-goal-3"), title: "Refine roadmap notes", detail: "Keep the clarification answer honest and small.", goalLabel: "Refine roadmap", timingLabel: "Flexible", kind: .flexible, visualState: .warning)
                ],
                overflowCount: 1,
                openWindow: PlanOpenWindowState(title: "Keep breathing room", detail: "The day can still hold, but only if the remaining pocket stays protected.", suggestionLabel: nil, target: nil, visualState: .default)
            ),
            PlanElasticWeekDayState(
                id: "day-4",
                weekdayLabel: "Fri",
                dateLabel: "24",
                level: .steady,
                intensity: 0.66,
                roomLabel: "Room remains",
                capacityLabel: "2 blocks",
                highlight: "Review notes are anchoring this day.",
                blocks: [
                    PlanWeekBlockState(id: "f1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Write closeout notes", detail: "Summarize only what was truly verified.", goalLabel: "Ship the native shell", timingLabel: "Flexible", kind: .flexible, visualState: .default),
                    PlanWeekBlockState(id: "f2", target: GoalRouteTarget(goalID: "preview-goal-3"), title: "Polish roadmap wording", detail: "Remove any batch drift before wrapping the week.", goalLabel: "Refine roadmap", timingLabel: "Flexible", kind: .flexible, visualState: .default)
                ],
                overflowCount: 0,
                openWindow: PlanOpenWindowState(title: "Usable room", detail: "There is still enough room to protect one smaller move.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
            ),
            PlanElasticWeekDayState(
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
                openWindow: PlanOpenWindowState(title: "Leave this open", detail: "Not every open pocket needs to be filled. Protected slack keeps the week believable.", suggestionLabel: nil, target: nil, visualState: .default)
            ),
            PlanElasticWeekDayState(
                id: "day-6",
                weekdayLabel: "Sun",
                dateLabel: "26",
                level: .steady,
                intensity: 0.6,
                roomLabel: "Steady load",
                capacityLabel: "1 block",
                highlight: "The week resets calmly here.",
                blocks: [
                    PlanWeekBlockState(id: "su1", target: GoalRouteTarget(goalID: "preview-goal-1"), title: "Quiet weekly reset", detail: "Leave a calm note about what actually held.", goalLabel: "Ship the native shell", timingLabel: "Protect Apr 26", kind: .protected, visualState: .success)
                ],
                overflowCount: 0,
                openWindow: PlanOpenWindowState(title: "Usable room", detail: "There is enough room for one lighter follow-through if it stays gentle.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
            )
        ],
        believability: PlanBelievabilityState(
            title: "The week is believable but tight",
            detail: "The structure can hold, but Tuesday is overloaded and one active goal is still missing from the week.",
            label: "Tight",
            supportLabel: "Patch missing work into an open window instead of forcing it into the crowded days.",
            visualState: .selected
        ),
        calendarAwareness: PlanCalendarAwarenessState(
            status: .baseline,
            title: "Make Plan calendar-aware",
            detail: "Plan works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
            primaryActionTitle: "Make Plan calendar-aware",
            primaryActionSystemImage: "calendar.badge.plus",
            valueLabel: "Optional",
            visualState: .default,
            canRequestCalendarRead: true
        ),
        resilience: PlanExecutionResilienceState(
            title: "Execution resilience",
            subtitle: "Carryover, overload, and recovery shaping stay explainable by keeping one smaller lane obvious at a time.",
            calmExplanation: "One active goal still needs a believable carryover lane instead of diffuse pressure.",
            focusProtection: "Protect Wednesday before Tuesday pressure spills into it.",
            tradeoffFraming: "Open captures should compete with the week honestly. Absorb them, park them, or let them wait.",
            lanes: [
                PlanExecutionResilienceLane(id: "carryover", title: "Carryover", detail: "Retention loop still sits outside the week.", recommendation: "Give it one calmer lane instead of widening the whole week.", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), planRoute: nil),
                PlanExecutionResilienceLane(id: "overload", title: "Overload", detail: "Tuesday is carrying more than the week can explain calmly.", recommendation: "Lighten shell work before adding anything new.", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-1"), planRoute: nil),
                PlanExecutionResilienceLane(id: "habits", title: "Habits", detail: "One routine should support the week shape without crowding it.", recommendation: "Use the habits route to keep the loop lightweight.", state: .selected, goalTarget: nil, planRoute: .habits),
                PlanExecutionResilienceLane(id: "captures", title: "Captures", detail: "Two open captures still need to be absorbed or parked.", recommendation: "Attach or park capture pressure before polishing the schedule.", state: .warning, goalTarget: nil, planRoute: .capturesInbox),
                PlanExecutionResilienceLane(id: "review", title: "Weekly review", detail: "Close the current week by shaping what should continue.", recommendation: "Review should feel like a continuation, not a detached ritual.", state: .warning, goalTarget: nil, planRoute: .weeklyReview)
            ],
            windowMagnetism: PlanWindowMagnetismState(
                title: "Window magnetism",
                detail: "Wednesday is the cleanest place for a calmer suggestion to dock.",
                dayLabel: "Wed 22",
                suggestionTitle: "Retention loop",
                suggestionDetail: "This day can carry one believable move without turning calendar-dense.",
                target: GoalRouteTarget(goalID: "preview-goal-2"),
                visualState: .success
            )
        ),
        goalShapingItems: [
            PlanGoalShapingItem(
                id: "plan-goal-native",
                target: GoalRouteTarget(goalID: "preview-goal-1"),
                goalTitle: "Ship the native shell",
                weekRelationship: "Visible and narrow",
                pressureLabel: "Protected",
                attentionReason: "This goal has a believable lane, but it depends on Tuesday and Thursday staying protected.",
                nextMoveLabel: "Review shell regressions",
                visualState: .selected
            ),
            PlanGoalShapingItem(
                id: "plan-goal-retention",
                target: GoalRouteTarget(goalID: "preview-goal-2"),
                goalTitle: "Retention loop",
                weekRelationship: "Still outside the week",
                pressureLabel: "Carryover",
                attentionReason: "This goal is active but the current week still does not give it believable room.",
                nextMoveLabel: "Add one small move on Wednesday",
                visualState: .warning
            ),
            PlanGoalShapingItem(
                id: "plan-goal-roadmap",
                target: GoalRouteTarget(goalID: "preview-goal-3"),
                goalTitle: "Refine roadmap",
                weekRelationship: "Visible, but straining",
                pressureLabel: "Needs lighter ask",
                attentionReason: "Recent friction suggests the current move is heavier than the week can comfortably carry.",
                nextMoveLabel: "Resolve the missing scope questions before planning more UI",
                visualState: .warning
            )
        ],
        shapingActions: [
            PlanShapingActionState(kind: .edit, title: "Edit", subtitle: "Fix shell regressions", recommendation: "Start with the clearest existing block instead of redrawing the whole week.", systemImage: "square.and.pencil", state: .selected, goalTarget: GoalRouteTarget(goalID: "preview-goal-1"), planRoute: nil),
            PlanShapingActionState(kind: .patch, title: "Patch", subtitle: "Give missing goals one believable lane instead of spreading them everywhere.", recommendation: "Use Wednesday or Friday to patch the retention loop into real room.", systemImage: "wand.and.stars", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), planRoute: nil),
            PlanShapingActionState(kind: .protect, title: "Protect", subtitle: "Protect the calmest pocket before pressure spills into it.", recommendation: "The cleanest protection move is to keep Wednesday or Sunday from filling up reactively.", systemImage: "shield", state: .success, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), planRoute: nil),
            PlanShapingActionState(kind: .lighten, title: "Lighten", subtitle: "Pressure is stacking here.", recommendation: "Shrink or move the heaviest ask before the week starts feeling performative.", systemImage: "sun.max", state: .warning, goalTarget: nil, planRoute: .capturesInbox)
        ],
        secondaryDestinations: [
            PlanSecondaryDestination(id: "plan-habits", title: "Routines and habits", detail: "Review the repeatable loops that can steady or crowd the week.", valueLabel: "1", icon: AppTab.habits.systemImage, visualState: .selected, planRoute: .habits),
            PlanSecondaryDestination(id: "plan-captures", title: "Captures into the week", detail: "2 captures still need to be absorbed, attached, or intentionally parked.", valueLabel: "2", icon: AppTab.captures.systemImage, visualState: .warning, planRoute: .capturesInbox),
            PlanSecondaryDestination(id: "plan-weekly-review", title: "Weekly review", detail: "Close the current week by shaping carry-forward and unresolved capture pressure without leaving Plan.", valueLabel: "Tight", icon: "arrow.triangle.branch", visualState: .selected, planRoute: .weeklyReview)
        ],
        emptyTitle: nil,
        emptyMessage: nil
    )

    static let empty = PlanDashboard(
        mode: .empty,
        timeframeLabel: "Apr 20-Apr 26",
        hero: PlanRealityHeroState(
            eyebrow: "Reality Model",
            title: "How this week holds together",
            subtitle: "Plan stays calm until real goals, captures, or routines create week pressure worth shaping.",
            dominantTruth: "The week is mostly empty, which is useful information.",
            roomSummary: "All seven days are carrying visible room right now.",
            pressureSummary: "There is no active outside pressure asking the week to harden yet.",
            contextPills: [
                PlanHeroPillState(title: "Apr 20-Apr 26", icon: "calendar", state: .default),
                PlanHeroPillState(title: "Open", icon: AppTab.plan.systemImage, state: .default),
                PlanHeroPillState(title: "0/1 goals visible", icon: "target", state: .default)
            ],
            trustWhisper: "This quiet week is real because nothing active is asking it to carry more."
        ),
        primaryAction: PlanWeekPrimaryAction(
            kind: .useRoom,
            title: "Use this room",
            subtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
            systemImage: "sparkles",
            state: .success,
            goalTarget: nil,
            planRoute: nil
        ),
        pressureScrubber: PlanPressureScrubberState(
            title: "Pressure scrubber",
            subtitle: "Scrub the empty week to see open room without forcing structure.",
            defaultDayID: "day-0",
            points: (0..<7).map { dayIndex in
                PlanPressureScrubberPoint(
                    id: "day-\(dayIndex)",
                    weekdayLabel: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dayIndex],
                    dateLabel: "\(20 + dayIndex)",
                    level: .open,
                    pressureValue: 0.4,
                    roomLabel: "Open day",
                    summary: "Keep the room visible."
                )
            }
        ),
        weekDays: (0..<7).map { dayIndex in
            PlanElasticWeekDayState(
                id: "day-\(dayIndex)",
                weekdayLabel: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dayIndex],
                dateLabel: "\(20 + dayIndex)",
                level: .open,
                intensity: 0.4,
                roomLabel: "Open day",
                capacityLabel: "No blocks yet",
                highlight: "Keep the room visible.",
                blocks: [],
                overflowCount: 0,
                openWindow: PlanOpenWindowState(title: "Leave this open", detail: "Protected slack keeps the week believable.", suggestionLabel: nil, target: nil, visualState: .default)
            )
        },
        believability: PlanBelievabilityState(
            title: "The week is open",
            detail: "No active goals or captures are pressing for structure yet.",
            label: "Open",
            supportLabel: "This is a real state, not missing data.",
            visualState: .default
        ),
        calendarAwareness: PlanCalendarAwarenessState(
            status: .baseline,
            title: "Make Plan calendar-aware",
            detail: "Plan works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
            primaryActionTitle: "Make Plan calendar-aware",
            primaryActionSystemImage: "calendar.badge.plus",
            valueLabel: "Optional",
            visualState: .default,
            canRequestCalendarRead: true
        ),
        resilience: PlanExecutionResilienceState(
            title: "Execution resilience",
            subtitle: "Carryover, overload, and recovery shaping stay explainable by keeping one smaller lane obvious at a time.",
            calmExplanation: "This quiet week is real because nothing is asking it to carry more yet.",
            focusProtection: "Protect the open room until something meaningful needs it.",
            tradeoffFraming: "Do not manufacture density for the sake of having a plan.",
            lanes: [
                PlanExecutionResilienceLane(id: "carryover", title: "Carryover", detail: "No active goal is floating outside the week.", recommendation: "Carry only what the next week can explain calmly.", state: .success, goalTarget: nil, planRoute: nil),
                PlanExecutionResilienceLane(id: "overload", title: "Overload", detail: "No day is visibly overloaded right now.", recommendation: "Lighten only when something real becomes too loud.", state: .selected, goalTarget: nil, planRoute: nil),
                PlanExecutionResilienceLane(id: "habits", title: "Habits", detail: "No recurring loop is shaping the week yet.", recommendation: "Keep the week dominant until a routine is truly needed.", state: .default, goalTarget: nil, planRoute: .habits),
                PlanExecutionResilienceLane(id: "captures", title: "Captures", detail: "No open captures are pushing on this week.", recommendation: "Let the week stay quiet.", state: .default, goalTarget: nil, planRoute: .capturesInbox),
                PlanExecutionResilienceLane(id: "review", title: "Weekly review", detail: "Review becomes useful once the week has something real to carry forward.", recommendation: "Use review only when the week has earned it.", state: .default, goalTarget: nil, planRoute: .weeklyReview)
            ],
            windowMagnetism: nil
        ),
        goalShapingItems: [],
        shapingActions: [
            PlanShapingActionState(kind: .edit, title: "Edit", subtitle: "No dated block is visible yet.", recommendation: "Plan stays quiet until a real block exists.", systemImage: "square.and.pencil", state: .default, goalTarget: nil, planRoute: nil),
            PlanShapingActionState(kind: .patch, title: "Patch", subtitle: "Patch the week only when real work arrives.", recommendation: "Do not manufacture density for the sake of having a plan.", systemImage: "wand.and.stars", state: .selected, goalTarget: nil, planRoute: nil),
            PlanShapingActionState(kind: .protect, title: "Protect", subtitle: "Protect the open room while it is still calm.", recommendation: "The best protection move may be leaving the week quiet.", systemImage: "shield", state: .success, goalTarget: nil, planRoute: nil),
            PlanShapingActionState(kind: .lighten, title: "Lighten", subtitle: "There is nothing to lighten yet.", recommendation: "No overload is visible right now.", systemImage: "sun.max", state: .default, goalTarget: nil, planRoute: nil)
        ],
        secondaryDestinations: [
            PlanSecondaryDestination(id: "plan-habits", title: "Routines and habits", detail: "No repeatable loops are shaping the week yet.", valueLabel: "0", icon: AppTab.habits.systemImage, visualState: .default, planRoute: .habits),
            PlanSecondaryDestination(id: "plan-captures", title: "Captures into the week", detail: "No open captures are pushing on the week right now.", valueLabel: "0", icon: AppTab.captures.systemImage, visualState: .default, planRoute: .capturesInbox),
            PlanSecondaryDestination(id: "plan-weekly-review", title: "Weekly review", detail: "Review stays available as the eventual closeout path for a real week.", valueLabel: "Open", icon: "arrow.triangle.branch", visualState: .default, planRoute: .weeklyReview)
        ],
        emptyTitle: "No weekly pressure yet",
        emptyMessage: "As soon as goals, captures, or routines create real constraints, Plan will show where the week still has room."
    )

    static let weeklyReview = WeeklyReviewDashboard(
        timeframeLabel: "Apr 20-Apr 26",
        hero: WeeklyReviewHeroState(
            eyebrow: "Weekly Review",
            title: "Shape what carries forward",
            subtitle: "Weekly review now continues the same authored week workspace instead of becoming a detached ritual.",
            dominantTruth: "Lighten Tuesday first, then carry forward only the moves the next week can still explain.",
            continuityLabel: "Return to the week with a calmer shape, not a larger list.",
            contextPills: [
                PlanHeroPillState(title: "Apr 20-Apr 26", icon: "calendar", state: .default),
                PlanHeroPillState(title: "Tight", icon: AppTab.plan.systemImage, state: .selected),
                PlanHeroPillState(title: "3 carry-forward lanes", icon: "arrow.triangle.branch", state: .selected)
            ]
        ),
        summaryTitle: "Why the next week should look different",
        summaryDetail: "Carryover, capture pressure, and overloaded days need gentler scope before the next week hardens.",
        carryForwardItems: [
            WeeklyReviewCarryForwardItem(id: "review-preview-retention", title: "Retention loop", detail: "Still active, but the current week never gave it a believable lane.", bridgeLabel: "Carry forward carefully", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-2")),
            WeeklyReviewCarryForwardItem(id: "review-preview-shell", title: "Ship the native shell", detail: "The next week should carry a lighter version so recovery stays believable.", bridgeLabel: "Lighten before it rolls forward", state: .selected, goalTarget: GoalRouteTarget(goalID: "preview-goal-1")),
            WeeklyReviewCarryForwardItem(id: "review-preview-captures", title: "Capture pressure", detail: "2 captures still need a calm decision before they become next-week clutter.", bridgeLabel: "Clear the inbox inside Plan", state: .warning, goalTarget: nil)
        ],
        captureSummary: "2 captures still need to be absorbed, attached, or intentionally parked.",
        habitSummary: "1 routine should support the next week without crowding it.",
        returnActionTitle: "Return to Plan",
        returnActionSubtitle: "Use the reshaped week, then adjust one goal or support route only if it still needs help.",
        returnPlanRoute: nil,
        splitPaneContext: PlanWindowMagnetismState(
            title: "Window magnetism",
            detail: "Wednesday remains the cleanest place for the next calmer move to dock.",
            dayLabel: "Wed 22",
            suggestionTitle: "Retention loop",
            suggestionDetail: "One believable move still fits without turning the next week dense.",
            target: GoalRouteTarget(goalID: "preview-goal-2"),
            visualState: .success
        )
    )
}
