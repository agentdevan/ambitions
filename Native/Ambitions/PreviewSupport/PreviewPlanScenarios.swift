import AmbitionsDesignSystem
import Foundation

enum PreviewPlanScenarios {
    static let seeded = PlanDashboard(
        mode: .active,
        timeframeLabel: "Apr 20-Apr 26",
        hero: PlanRealityHeroState(
            eyebrow: "Plan",
            title: "Does this hold together?",
            subtitle: "Plan reads the week as room, pressure, and protected structure instead of a dense calendar clone.",
            dominantTruth: "Pressure is clustering into one overloaded day, while two calmer windows still have believable room.",
            roomSummary: "Wednesday and Saturday can still carry one small step without collapsing into calendar noise.",
            pressureSummary: "Open captures and one fragile goal are the loudest reasons the week still needs shaping.",
            contextPills: [
                PlanHeroPillState(title: "Apr 20-Apr 26", icon: "calendar", state: .default),
                PlanHeroPillState(title: "Tight", icon: AppTab.plan.systemImage, state: .selected),
                PlanHeroPillState(title: "2/3 goals visible", icon: "target", state: .selected)
            ],
            trustWhisper: "One active goal is still outside the week, so the current calm is real but incomplete."
        ),
        lifeSuite: seededLifeSuite,
        primaryAction: PlanWeekPrimaryAction(
            kind: .useRoom,
            title: "Use this room",
            subtitle: "Wednesday still has believable room for the retention loop.",
            systemImage: "arrow.down.left.and.arrow.up.right",
            state: .success,
            goalTarget: GoalRouteTarget(goalID: "preview-goal-2"),
            planRoute: nil
        ),
        treaty: PlanTreatyState(
            title: "This week's agreement",
            summary: "Protect shell work, flex the retention loop, keep one capture outside today, and leave recovery room visible.",
            protectedWork: "3 protected or fixed items should stay defended.",
            flexibleWork: "4 flexible items can bend around real life.",
            notTodayWork: "2 items should wait, clarify, or stay outside today's pressure.",
            recoveryAllowance: "2 open days keep recovery room visible.",
            calendarBoundary: "Manual planning still works without calendar access.",
            primaryActionTitle: "Use this room",
            primaryActionSubtitle: "Wednesday still has believable room for the retention loop.",
            visualState: .selected
        ),
        capacityEnvelope: PlanCapacityEnvelopeState(
            title: "Capacity envelope",
            detail: "Manual availability is enough to keep shaping this plan. The envelope stays qualitative so it does not pretend to know more than the data shows.",
            label: "Tight",
            availableCapacity: "2 open days",
            pressure: "Pressure is visible",
            protectedFocus: "3 protected items",
            recoveryMargin: "Recovery room exists",
            visualState: .warning
        ),
        lifecycleRail: PlanGoalLifecycleRailState(
            title: "What this plan is carrying",
            subtitle: "Goals stay visible by lifecycle, including work that belongs outside this week's pressure.",
            segments: [
                PlanGoalLifecycleRailSegment(lifecycleState: .previous, count: 1, subtitle: "Closed, parked, or transformed"),
                PlanGoalLifecycleRailSegment(lifecycleState: .active, count: 2, subtitle: "Currently shaping attention"),
                PlanGoalLifecycleRailSegment(lifecycleState: .future, count: 1, subtitle: "Planned, not active yet"),
                PlanGoalLifecycleRailSegment(lifecycleState: .waiting, count: 1, subtitle: "Waiting on an answer"),
                PlanGoalLifecycleRailSegment(lifecycleState: .blocked, count: 1, subtitle: "Needs unblock"),
                PlanGoalLifecycleRailSegment(lifecycleState: .parked, count: 1, subtitle: "Intentionally outside pressure"),
                PlanGoalLifecycleRailSegment(lifecycleState: .protected, count: 1, subtitle: "Should be defended"),
                PlanGoalLifecycleRailSegment(lifecycleState: .completed, count: 1, subtitle: "Done and preserved"),
                PlanGoalLifecycleRailSegment(lifecycleState: .cancelledDropped, count: 1, subtitle: "Dropped without shame")
            ]
        ),
        timelineStrip: PlanTimelineStripState(
            title: "Rich Timeline",
            subtitle: "A compact strip of previous, active, future, and outside pressure with local source labels.",
            items: [
                PlanTimelineItemState(id: "preview-previous", title: "Launch audit", detail: "Kept outside current pressure.", timingLabel: "Previous", sourceLabel: "Created in Ambitions", kind: .previous, visualState: .default, target: nil),
                PlanTimelineItemState(id: "preview-active", title: "Ship the native shell", detail: "Fix shell regressions", timingLabel: "Due Apr 21", sourceLabel: "Based on your plan", kind: .active, visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-1")),
                PlanTimelineItemState(id: "preview-future", title: "Retention loop", detail: "Planned later, not part of this week's load.", timingLabel: "Future", sourceLabel: "Based on your plan", kind: .future, visualState: .default, target: GoalRouteTarget(goalID: "preview-goal-2"))
            ]
        ),
        opportunityWindows: PlanOpportunityWindowsState(
            title: "Opportunity windows",
            subtitle: "Windows are work modes, not a calendar grid.",
            windows: [
                PlanOpportunityWindowItem(id: "preview-window-focus", title: "Good window for one focused step", detail: "Wednesday can carry one believable step without turning calendar-dense.", modeLabel: "Focus", timingLabel: "Wed 22", visualState: .success, target: GoalRouteTarget(goalID: "preview-goal-2")),
                PlanOpportunityWindowItem(id: "preview-window-admin", title: "Better for admin", detail: "Thursday can hold only lightweight follow-up.", modeLabel: "Admin", timingLabel: "Thu 23", visualState: .default, target: nil)
            ]
        ),
        decisionDebt: PlanDecisionDebtState(
            title: "Needs a decision",
            subtitle: "Small decisions prevent the plan from becoming a dense task manager.",
            items: [
                PlanDecisionItemState(id: "preview-decision", title: "Needs a decision", detail: "Retention loop is active but not represented in this plan window.", suggestion: "Give it one next step, park it, or leave it intentionally outside today.", visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-2"), planRoute: nil)
            ]
        ),
        conflictCourt: PlanConflictCourtState(
            title: "Conflicts to negotiate",
            subtitle: "These are negotiation items, not alarms.",
            conflicts: [
                PlanDecisionItemState(id: "preview-conflict", title: "Important goals are competing", detail: "Two goals are asking the same week to hold them.", suggestion: "Choose the one that must stay and let the other flex.", visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-1"), planRoute: nil)
            ]
        ),
        calendarBoundary: PlanCalendarBoundaryContractState(
            title: "Calendar stays optional",
            detail: "Plan works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
            permissionLabel: "Optional",
            sourceLabel: "Based on your plan",
            manualFallback: "Manual planning still works without calendar access.",
            writeBoundary: "Plan never silently writes or reschedules calendar blocks.",
            visualState: .default,
            canRequestCalendarRead: true
        ),
        recoveryEntry: PlanRecoveryEntryState(
            title: "Recovery room",
            detail: "Save the Day stays suggestion-only here. Broad reflow waits for confirmed recovery tools.",
            suggestions: [
                PlanDecisionItemState(id: "preview-recovery", title: "Shrink one step", detail: "Ship the native shell is the clearest place to reduce pressure.", suggestion: "Make the next step smaller before moving anything else.", visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-1"), planRoute: nil)
            ],
            boundary: "No schedule changes happen from this card."
        ),
        realityReflow: PlanRealityReflowState(
            title: "Reality changed",
            detail: "Adjust one thing, not everything. These are suggestions until you confirm a change.",
            reasonKind: .overloadedPlan,
            reasonDetail: "Tuesday is carrying more than this plan can calmly explain.",
            recommendedAdjustment: "Keep this",
            noChangeCopy: "Nothing changed yet.",
            suggestions: [
                PlanReflowSuggestionState(
                    id: "preview-reflow-protect",
                    kind: .protectOneItem,
                    title: "Keep this",
                    detail: "Keep shell regression work defended before changing the rest.",
                    impactLabel: "Smallest useful adjustment",
                    boundary: PlanReflowBoundaryState(actionKind: .changePlanWindow, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"),
                    visualState: .selected,
                    target: GoalRouteTarget(goalID: "preview-goal-1"),
                    planRoute: nil
                ),
                PlanReflowSuggestionState(
                    id: "preview-reflow-shrink",
                    kind: .shrinkAction,
                    title: "Make it smaller",
                    detail: "Close only the top regression before moving anything else.",
                    impactLabel: "Local suggestion only",
                    boundary: PlanReflowBoundaryState(actionKind: .shrinkAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"),
                    visualState: .warning,
                    target: GoalRouteTarget(goalID: "preview-goal-1"),
                    planRoute: nil
                ),
                PlanReflowSuggestionState(
                    id: "preview-reflow-confirm",
                    kind: .askForConfirmation,
                    title: "Needs confirmation",
                    detail: "Confirm before applying any broad reflow or calendar-impacting change.",
                    impactLabel: "Nothing changes until confirmed",
                    boundary: PlanReflowBoundaryState(actionKind: .changePlanWindow, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .notSupportedYet, safetyLabel: "Confirm first"),
                    visualState: .warning,
                    target: nil,
                    planRoute: nil
                )
            ],
            visualState: .warning
        ),
        reflowDecision: seededReflowDecision,
        recoveryGradient: PlanRecoveryGradientState(
            title: "Recovery options",
            detail: "Start with the least disruptive option that still makes the plan believable.",
            options: [
                PlanRecoveryGradientOptionState(id: "preview-gradient-protect", order: 0, kind: .protectOneItem, title: "Keep this", detail: "Keep one must-do visible.", boundary: PlanReflowBoundaryState(actionKind: .changePlanWindow, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .selected),
                PlanRecoveryGradientOptionState(id: "preview-gradient-shrink", order: 1, kind: .shrinkAction, title: "Make it smaller", detail: "Reduce the ask before moving it.", boundary: PlanReflowBoundaryState(actionKind: .shrinkAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-gradient-split", order: 2, kind: .splitAction, title: "Split it", detail: "Carry only the first clear part.", boundary: PlanReflowBoundaryState(actionKind: .splitAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-gradient-move", order: 3, kind: .moveLocalActionLater, title: "Adjust plan", detail: "Reschedule one local item after confirmation.", boundary: PlanReflowBoundaryState(actionKind: .moveActionLater, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-gradient-defer", order: 4, kind: .deferGoalOrItem, title: "Defer this", detail: "Leave lower-priority work outside this window.", boundary: PlanReflowBoundaryState(actionKind: .deferAction, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-gradient-drop", order: 5, kind: .dropOptionalWork, title: "Drop optional work", detail: "Remove optional work only with confirmation.", boundary: PlanReflowBoundaryState(actionKind: .dropAction, confirmationRequirement: .requiredForDestructiveChange, undoAvailability: .unsafe, safetyLabel: "Confirm drop"), visualState: .warning),
                PlanRecoveryGradientOptionState(id: "preview-gradient-recover", order: 6, kind: .recoverRest, title: "Recover", detail: "Protect rest or recovery as real plan material.", boundary: PlanReflowBoundaryState(actionKind: .noOp, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .success)
            ]
        ),
        saveTheDay: PlanSaveTheDayState(
            title: "Save the Day in Plan",
            detail: "Plan handles the deeper recovery shape without changing anything for you.",
            oneQuestion: "What is the one thing that still needs protection?",
            protectedItem: "Fix shell regressions",
            adjustment: "Make it smaller",
            recoveryExplanation: "Recovery works by protecting one thing, reducing one thing, and leaving the rest unchanged until you confirm.",
            boundary: "No silent rescheduling. No calendar write. Nothing changed yet.",
            visualState: .warning
        ),
        reflowReceiptPreview: PlanReflowReceiptPreviewState(
            title: "Before anything changes",
            detail: "A reflow receipt preview shows the tradeoff before action, not after a silent mutation.",
            whatChanged: ["Protect: Fix shell regressions", "Adjust: Make it smaller", "Receipt would show the suggested change before action."],
            whatWouldNotChange: ["Calendar blocks are not written.", "The plan is not silently rescheduled.", "Sync, export, widgets, and future systems are not touched."],
            confirmationRequired: "Safe local suggestion",
            undoAvailability: "Undo can be local",
            safeFailureFallback: "If you decline confirmation, Ambitions keeps the plan as-is and leaves manual planning available.",
            visualState: .warning
        ),
        recoveryMaturity: PlanRecoveryMaturityState(
            title: "Recovery maturity",
            detail: "Overloaded days become decisions with receipts, not silent reschedules.",
            planFitLabel: "Needs relief",
            confirmationBoundary: "Save the Day and Reality Reflow require confirmation before broad plan changes.",
            calendarBoundary: "Manual planning works without calendar access.",
            socialBoundary: "People-shaped pressure stays private, optional, and manually named.",
            receiptBoundary: "A receipt preview names what would change, what would not change, and the undo boundary.",
            signals: [
                PlanRecoveryMaturitySignalState(id: "fit", title: "Plan fit", detail: "One day needs relief before the week widens.", statusLabel: "Needs relief", boundaryLabel: "Suggests one smaller step", visualState: .warning),
                PlanRecoveryMaturitySignalState(id: "waiting-commitments", title: "Waiting and commitments", detail: "One waiting item should stay visible instead of becoming quiet pressure.", statusLabel: "Visible", boundaryLabel: "No silent routing", visualState: .warning),
                PlanRecoveryMaturitySignalState(id: "social-load", title: "Social load", detail: "People-shaped pressure stays private and manual-first.", statusLabel: "Private", boundaryLabel: "No inference without you", visualState: .selected),
                PlanRecoveryMaturitySignalState(id: "receipt", title: "Receipt and undo", detail: "If you decline confirmation, Ambitions keeps the plan as-is.", statusLabel: "Safe local suggestion", boundaryLabel: "Undo can be local", visualState: .warning)
            ]
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
                openWindow: PlanOpenWindowState(title: "Usable room", detail: "One smaller step still fits here if the day stays protected.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
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
                openWindow: PlanOpenWindowState(title: "Open window", detail: "This day can carry one believable step without turning calendar-dense.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .success)
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
                openWindow: PlanOpenWindowState(title: "Usable room", detail: "There is still enough room to protect one smaller step.", suggestionLabel: "Retention loop", target: GoalRouteTarget(goalID: "preview-goal-2"), visualState: .selected)
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
                openWindow: PlanOpenWindowState(title: "Leave this open", detail: "Not every open pocket needs to be filled. Open room keeps the week doable.", suggestionLabel: nil, target: nil, visualState: .default)
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
            sourceLabel: "Based on your plan",
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
                PlanExecutionResilienceLane(id: "habits", title: "Rituals", detail: "One routine should support the week shape without crowding it.", recommendation: "Use the rituals route to keep the loop lightweight.", state: .selected, goalTarget: nil, planRoute: .habits),
                PlanExecutionResilienceLane(id: "captures", title: "Captures", detail: "Two open captures still need to be absorbed or parked.", recommendation: "Attach or park capture pressure before polishing the schedule.", state: .warning, goalTarget: nil, planRoute: .captureInbox),
                PlanExecutionResilienceLane(id: "review", title: "Weekly review", detail: "Close the current week by shaping what should continue.", recommendation: "Review should feel like a continuation, not a detached ritual.", state: .warning, goalTarget: nil, planRoute: .weeklyReview)
            ],
            windowMagnetism: PlanWindowMagnetismState(
                title: "Window magnetism",
                detail: "Wednesday is the cleanest place for a calmer suggestion to dock.",
                dayLabel: "Wed 22",
                suggestionTitle: "Retention loop",
                suggestionDetail: "This day can carry one believable step without turning calendar-dense.",
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
                pressureLabel: "Kept in view",
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
                nextMoveLabel: "Add one small step on Wednesday",
                visualState: .warning
            ),
            PlanGoalShapingItem(
                id: "plan-goal-roadmap",
                target: GoalRouteTarget(goalID: "preview-goal-3"),
                goalTitle: "Refine roadmap",
                weekRelationship: "Visible, but straining",
                pressureLabel: "Needs lighter ask",
                attentionReason: "Recent friction suggests the current step is heavier than the week can comfortably carry.",
                nextMoveLabel: "Resolve the missing scope questions before planning more UI",
                visualState: .warning
            )
        ],
        shapingActions: [
            PlanShapingActionState(kind: .edit, title: "Edit", subtitle: "Fix shell regressions", recommendation: "Start with the clearest existing block instead of redrawing the whole week.", systemImage: "square.and.pencil", state: .selected, goalTarget: GoalRouteTarget(goalID: "preview-goal-1"), planRoute: nil),
            PlanShapingActionState(kind: .patch, title: "Patch", subtitle: "Give missing goals one believable lane instead of spreading them everywhere.", recommendation: "Use Wednesday or Friday to patch the retention loop into real room.", systemImage: "wand.and.stars", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), planRoute: nil),
            PlanShapingActionState(kind: .protect, title: "Protect", subtitle: "Protect the calmest pocket before pressure spills into it.", recommendation: "The cleanest protection step is to keep Wednesday or Sunday from filling up reactively.", systemImage: "shield", state: .success, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), planRoute: nil),
            PlanShapingActionState(kind: .lighten, title: "Lighten", subtitle: "Pressure is stacking here.", recommendation: "Shrink or reschedule the heaviest ask before the week starts feeling performative.", systemImage: "sun.max", state: .warning, goalTarget: nil, planRoute: .captureInbox)
        ],
        secondaryDestinations: [
            PlanSecondaryDestination(id: "plan-habits", title: "Routines and habits", detail: "Review the repeatable loops that can steady or crowd the week.", valueLabel: "1", icon: AppTab.habits.systemImage, visualState: .selected, planRoute: .habits),
            PlanSecondaryDestination(id: "plan-captures", title: "Captures into the week", detail: "2 captures still need to be absorbed, attached, or intentionally parked.", valueLabel: "2", icon: AppTab.captures.systemImage, visualState: .warning, planRoute: .captureInbox),
            PlanSecondaryDestination(id: "plan-weekly-review", title: "Weekly review", detail: "Close the current week by shaping carry-forward and unresolved capture pressure without leaving Plan.", valueLabel: "Tight", icon: "arrow.triangle.branch", visualState: .selected, planRoute: .weeklyReview)
        ],
        emptyTitle: nil,
        emptyMessage: nil
    )

    static let empty = PlanDashboard(
        mode: .empty,
        timeframeLabel: "Apr 20-Apr 26",
        hero: PlanRealityHeroState(
            eyebrow: "Plan",
            title: "Does this hold together?",
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
        lifeSuite: emptyLifeSuite,
        primaryAction: PlanWeekPrimaryAction(
            kind: .useRoom,
            title: "Use this room",
            subtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
            systemImage: "sparkles",
            state: .success,
            goalTarget: nil,
            planRoute: nil
        ),
        treaty: PlanTreatyState(
            title: "This week's agreement",
            summary: "The plan is allowed to stay open until real work needs shape.",
            protectedWork: "Nothing is marked as protected yet.",
            flexibleWork: "No flexible work is asking for placement right now.",
            notTodayWork: "Nothing obvious needs to be kept outside today.",
            recoveryAllowance: "7 open days keep recovery room visible.",
            calendarBoundary: "Manual planning still works without calendar access.",
            primaryActionTitle: "Use this room",
            primaryActionSubtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
            visualState: .success
        ),
        capacityEnvelope: PlanCapacityEnvelopeState(
            title: "Capacity envelope",
            detail: "Manual availability is enough to keep shaping this plan. The envelope stays qualitative so it does not pretend to know more than the data shows.",
            label: "Light",
            availableCapacity: "7 open days",
            pressure: "Pressure is readable",
            protectedFocus: "Focus time is not explicit yet",
            recoveryMargin: "Recovery room exists",
            visualState: .success
        ),
        lifecycleRail: PlanGoalLifecycleRailState(
            title: "What this plan is carrying",
            subtitle: "Goals stay visible by lifecycle, including work that belongs outside this week's pressure.",
            segments: [
                PlanGoalLifecycleRailSegment(lifecycleState: .previous, count: 0, subtitle: "No prior pressure"),
                PlanGoalLifecycleRailSegment(lifecycleState: .active, count: 0, subtitle: "No live load"),
                PlanGoalLifecycleRailSegment(lifecycleState: .future, count: 0, subtitle: "Nothing scheduled later"),
                PlanGoalLifecycleRailSegment(lifecycleState: .waiting, count: 0, subtitle: "No waiting goal"),
                PlanGoalLifecycleRailSegment(lifecycleState: .blocked, count: 0, subtitle: "No blocked goal"),
                PlanGoalLifecycleRailSegment(lifecycleState: .parked, count: 0, subtitle: "Nothing parked"),
                PlanGoalLifecycleRailSegment(lifecycleState: .protected, count: 0, subtitle: "Nothing protected"),
                PlanGoalLifecycleRailSegment(lifecycleState: .completed, count: 0, subtitle: "No completion here"),
                PlanGoalLifecycleRailSegment(lifecycleState: .cancelledDropped, count: 0, subtitle: "No dropped goal")
            ]
        ),
        timelineStrip: PlanTimelineStripState(
            title: "Rich Timeline",
            subtitle: "No goal movement is visible yet.",
            items: []
        ),
        opportunityWindows: PlanOpportunityWindowsState(
            title: "Opportunity windows",
            subtitle: "Windows are work modes, not a calendar grid.",
            windows: [
                PlanOpportunityWindowItem(id: "preview-empty-window", title: "Keep this light", detail: "No believable window is asking to be filled.", modeLabel: "Recovery", timingLabel: "Manual", visualState: .default, target: nil)
            ]
        ),
        decisionDebt: PlanDecisionDebtState(
            title: "Needs a decision",
            subtitle: "No unresolved planning decision is loud right now.",
            items: []
        ),
        conflictCourt: PlanConflictCourtState(
            title: "Conflicts to negotiate",
            subtitle: "No visible conflict needs court right now.",
            conflicts: []
        ),
        calendarBoundary: PlanCalendarBoundaryContractState(
            title: "Calendar stays optional",
            detail: "Plan works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
            permissionLabel: "Optional",
            sourceLabel: "Based on your plan",
            manualFallback: "Manual planning still works without calendar access.",
            writeBoundary: "Plan never silently writes or reschedules calendar blocks.",
            visualState: .default,
            canRequestCalendarRead: true
        ),
        recoveryEntry: PlanRecoveryEntryState(
            title: "Recovery room",
            detail: "Save the Day stays suggestion-only here. Broad reflow waits for confirmed recovery tools.",
            suggestions: [
                PlanDecisionItemState(id: "preview-empty-recovery", title: "Protect recovery room", detail: "The safest choice is keeping an open pocket unfilled.", suggestion: "Recovery room is part of the plan, not a failure to optimize.", visualState: .success, target: nil, planRoute: nil)
            ],
            boundary: "No schedule changes happen from this card."
        ),
        realityReflow: PlanRealityReflowState(
            title: "Not enough plan data yet",
            detail: "Create or choose one plan item before reflowing anything.",
            reasonKind: .lowData,
            reasonDetail: "There is not enough plan pressure to reflow yet.",
            recommendedAdjustment: "Keep plan unchanged",
            noChangeCopy: "Nothing changed yet.",
            suggestions: [
                PlanReflowSuggestionState(
                    id: "preview-empty-reflow-keep",
                    kind: .keepPlanUnchanged,
                    title: "Keep plan unchanged",
                    detail: "Create or choose one plan item before reflowing anything.",
                    impactLabel: "No plan mutation",
                    boundary: PlanReflowBoundaryState(actionKind: .noOp, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"),
                    visualState: .default,
                    target: nil,
                    planRoute: nil
                )
            ],
            visualState: .default
        ),
        reflowDecision: emptyReflowDecision,
        recoveryGradient: PlanRecoveryGradientState(
            title: "Recovery options",
            detail: "No recovery is needed, but the order stays ready if reality changes.",
            options: [
                PlanRecoveryGradientOptionState(id: "preview-empty-gradient-protect", order: 0, kind: .protectOneItem, title: "Keep this", detail: "Keep one must-do visible.", boundary: PlanReflowBoundaryState(actionKind: .changePlanWindow, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .selected),
                PlanRecoveryGradientOptionState(id: "preview-empty-gradient-shrink", order: 1, kind: .shrinkAction, title: "Make it smaller", detail: "Reduce the ask before moving it.", boundary: PlanReflowBoundaryState(actionKind: .shrinkAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-empty-gradient-split", order: 2, kind: .splitAction, title: "Split it", detail: "Carry only the first clear part.", boundary: PlanReflowBoundaryState(actionKind: .splitAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-empty-gradient-move", order: 3, kind: .moveLocalActionLater, title: "Adjust plan", detail: "Reschedule one local item after confirmation.", boundary: PlanReflowBoundaryState(actionKind: .moveActionLater, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-empty-gradient-defer", order: 4, kind: .deferGoalOrItem, title: "Defer this", detail: "Leave lower-priority work outside this window.", boundary: PlanReflowBoundaryState(actionKind: .deferAction, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                PlanRecoveryGradientOptionState(id: "preview-empty-gradient-drop", order: 5, kind: .dropOptionalWork, title: "Drop optional work", detail: "Remove optional work only with confirmation.", boundary: PlanReflowBoundaryState(actionKind: .dropAction, confirmationRequirement: .requiredForDestructiveChange, undoAvailability: .unsafe, safetyLabel: "Confirm drop"), visualState: .warning),
                PlanRecoveryGradientOptionState(id: "preview-empty-gradient-recover", order: 6, kind: .recoverRest, title: "Recover", detail: "Protect rest or recovery as real plan material.", boundary: PlanReflowBoundaryState(actionKind: .noOp, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .success)
            ]
        ),
        saveTheDay: PlanSaveTheDayState(
            title: "Save the Day in Plan",
            detail: "Plan handles the deeper recovery shape without changing anything for you.",
            oneQuestion: nil,
            protectedItem: "One must-do",
            adjustment: "Keep the plan unchanged",
            recoveryExplanation: "No rescue is needed; keep recovery room visible.",
            boundary: "No silent rescheduling. No calendar write. Nothing changed yet.",
            visualState: .default
        ),
        reflowReceiptPreview: PlanReflowReceiptPreviewState(
            title: "Before anything changes",
            detail: "A reflow receipt preview shows the tradeoff before action, not after a silent mutation.",
            whatChanged: ["Protect: One must-do", "Adjust: Keep the plan unchanged", "No reflow would be applied."],
            whatWouldNotChange: ["Calendar blocks are not written.", "The plan is not silently rescheduled.", "Sync, export, widgets, and future systems are not touched."],
            confirmationRequired: "Safe local suggestion",
            undoAvailability: "Undo can be local",
            safeFailureFallback: "If you decline confirmation, Ambitions keeps the plan as-is and leaves manual planning available.",
            visualState: .default
        ),
        recoveryMaturity: PlanRecoveryMaturityState(
            title: "Recovery maturity",
            detail: "Overloaded days become decisions with receipts, not silent reschedules.",
            planFitLabel: "Believable",
            confirmationBoundary: "Save the Day and Reality Reflow require confirmation before broad plan changes.",
            calendarBoundary: "Manual planning works without calendar access.",
            socialBoundary: "People-shaped pressure stays private, optional, and manually named.",
            receiptBoundary: "A receipt preview names what would change, what would not change, and the undo boundary.",
            signals: [
                PlanRecoveryMaturitySignalState(id: "fit", title: "Plan fit", detail: "No rescue is needed; keep recovery room visible.", statusLabel: "Believable", boundaryLabel: "Suggests one smaller step", visualState: .success),
                PlanRecoveryMaturitySignalState(id: "waiting-commitments", title: "Waiting and commitments", detail: "No waiting item or one-time commitment is currently pushing on the plan.", statusLabel: "Quiet", boundaryLabel: "No silent routing", visualState: .default),
                PlanRecoveryMaturitySignalState(id: "social-load", title: "Social load", detail: "No social-load assumption is inferred.", statusLabel: "Manual", boundaryLabel: "No inference without you", visualState: .default),
                PlanRecoveryMaturitySignalState(id: "receipt", title: "Receipt and undo", detail: "If you decline confirmation, Ambitions keeps the plan as-is.", statusLabel: "Safe local suggestion", boundaryLabel: "Undo can be local", visualState: .default)
            ]
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
                openWindow: PlanOpenWindowState(title: "Leave this open", detail: "Open room keeps the week doable.", suggestionLabel: nil, target: nil, visualState: .default)
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
            sourceLabel: "Based on your plan",
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
                PlanExecutionResilienceLane(id: "habits", title: "Rituals", detail: "No recurring loop is shaping the week yet.", recommendation: "Keep the week dominant until a routine is truly needed.", state: .default, goalTarget: nil, planRoute: .habits),
                PlanExecutionResilienceLane(id: "captures", title: "Captures", detail: "No open captures are pushing on this week.", recommendation: "Let the week stay quiet.", state: .default, goalTarget: nil, planRoute: .captureInbox),
                PlanExecutionResilienceLane(id: "review", title: "Weekly review", detail: "Review becomes useful once the week has something real to carry forward.", recommendation: "Use review only when the week has earned it.", state: .default, goalTarget: nil, planRoute: .weeklyReview)
            ],
            windowMagnetism: nil
        ),
        goalShapingItems: [],
        shapingActions: [
            PlanShapingActionState(kind: .edit, title: "Edit", subtitle: "No dated block is visible yet.", recommendation: "Plan stays quiet until a real block exists.", systemImage: "square.and.pencil", state: .default, goalTarget: nil, planRoute: nil),
            PlanShapingActionState(kind: .patch, title: "Patch", subtitle: "Patch the week only when real work arrives.", recommendation: "Do not manufacture density for the sake of having a plan.", systemImage: "wand.and.stars", state: .selected, goalTarget: nil, planRoute: nil),
            PlanShapingActionState(kind: .protect, title: "Protect", subtitle: "Protect the open room while it is still calm.", recommendation: "The best protection step may be leaving the week quiet.", systemImage: "shield", state: .success, goalTarget: nil, planRoute: nil),
            PlanShapingActionState(kind: .lighten, title: "Lighten", subtitle: "There is nothing to lighten yet.", recommendation: "No overload is visible right now.", systemImage: "sun.max", state: .default, goalTarget: nil, planRoute: nil)
        ],
        secondaryDestinations: [
            PlanSecondaryDestination(id: "plan-habits", title: "Routines and habits", detail: "No repeatable loops are shaping the week yet.", valueLabel: "0", icon: AppTab.habits.systemImage, visualState: .default, planRoute: .habits),
            PlanSecondaryDestination(id: "plan-captures", title: "Captures into the week", detail: "No open captures are pushing on the week right now.", valueLabel: "0", icon: AppTab.captures.systemImage, visualState: .default, planRoute: .captureInbox),
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
            dominantTruth: "Lighten Tuesday first, then carry forward only the steps the next week can still explain.",
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
            detail: "Wednesday remains the cleanest place for the next calmer step to dock.",
            dayLabel: "Wed 22",
            suggestionTitle: "Retention loop",
            suggestionDetail: "One believable step still fits without turning the next week dense.",
            target: GoalRouteTarget(goalID: "preview-goal-2"),
            visualState: .success
        )
    )

    private static let seededLifeSuite = PlanLifeSuiteState(
        title: "Plan Life Suite",
        subtitle: "Does this hold together?",
        shapes: [
            PlanLifeSuiteShapeState(kind: .day, title: "Day Shape", question: "What can this day honestly hold?", summary: "Today has tight room and three planned blocks.", facts: ["Tight room", "One open window", "3 planned blocks attached."], sourceLabel: "Based on your plan", boundaryLabel: "No silent replanning", visualState: .warning),
            PlanLifeSuiteShapeState(kind: .week, title: "Week Shape", question: "Does the week still fit?", summary: "Two days may need shaping before the week feels believable.", facts: ["2 pressured days visible.", "2 captures need a place.", "7 days included in this week."], sourceLabel: "Based on goals and captures", boundaryLabel: "Suggestions require confirmation", visualState: .warning),
            PlanLifeSuiteShapeState(kind: .life, title: "Life Shape", question: "Is the plan still pointed at the life you are building?", summary: "Three active goals shape the current life plan.", facts: ["3 active goals included.", "Life Shape stays inside Plan."], sourceLabel: "Based on active goals", boundaryLabel: "Life view, broader than time slots", visualState: .selected)
        ],
        calendarBoundaryLabel: "Calendar stays optional",
        manualFallbackLabel: "Manual fallback available",
        trustLabel: "No silent calendar changes"
    )

    private static let emptyLifeSuite = PlanLifeSuiteState(
        title: "Plan Life Suite",
        subtitle: "Does this hold together?",
        shapes: [
            PlanLifeSuiteShapeState(kind: .day, title: "Day Shape", question: "What can this day honestly hold?", summary: "No day shape is loaded yet.", facts: ["Manual shaping is available.", "Nothing moves without review."], sourceLabel: "Based on your plan", boundaryLabel: "No silent replanning", visualState: .default),
            PlanLifeSuiteShapeState(kind: .week, title: "Week Shape", question: "Does the week still fit?", summary: "The week has room until goals, captures, or routines create real constraints.", facts: ["0 pressured days visible.", "0 captures need a place.", "7 days included in this week."], sourceLabel: "Based on goals and captures", boundaryLabel: "Suggestions require confirmation", visualState: .selected),
            PlanLifeSuiteShapeState(kind: .life, title: "Life Shape", question: "Is the plan still pointed at the life you are building?", summary: "Life Shape is quiet until active goals give Plan something to coordinate.", facts: ["No active goals shaping life view yet.", "Life Shape stays inside Plan."], sourceLabel: "Based on active goals", boundaryLabel: "Life view, broader than time slots", visualState: .default)
        ],
        calendarBoundaryLabel: "Manual planning still works",
        manualFallbackLabel: "Manual fallback available",
        trustLabel: "No silent calendar changes"
    )

    private static let seededReflowDecision = PlanReflowDecisionState(
        title: "Reflow decisions",
        subtitle: "Choose one path before anything changes.",
        sourceLabel: "Based on your plan",
        trustLabel: "No silent changes",
        reasonLabel: "Tuesday is carrying more than this plan can calmly explain.",
        recoveryLabel: "No schedule changes happen from this card.",
        receiptLabel: "Safe local suggestion. No silent rescheduling. No calendar write. Nothing changed yet.",
        options: [
            PlanReflowDecisionOptionState(
                id: "preview-decision-protect",
                kind: .protectTime,
                title: "Protect time",
                detail: "Keep shell regression work defended before changing the rest.",
                impactLabel: "Smallest useful adjustment",
                sourceLabel: "Based on your plan",
                trustLabel: "No silent changes",
                boundaryLabel: "Safe local suggestion. Undo can be local.",
                visualState: .selected,
                target: GoalRouteTarget(goalID: "preview-goal-1"),
                planRoute: nil
            ),
            PlanReflowDecisionOptionState(
                id: "preview-decision-smaller",
                kind: .makeSmaller,
                title: "Make smaller",
                detail: "Close only the top regression before moving anything else.",
                impactLabel: "Local suggestion only",
                sourceLabel: "Based on your plan",
                trustLabel: "No silent changes",
                boundaryLabel: "Safe local suggestion. Undo can be local.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: "preview-goal-1"),
                planRoute: nil
            ),
            PlanReflowDecisionOptionState(
                id: "preview-decision-review",
                kind: .reviewPlan,
                title: "Review plan",
                detail: "Confirm before applying any broad reflow or calendar-impacting change.",
                impactLabel: "Nothing changes until confirmed",
                sourceLabel: "Based on your plan",
                trustLabel: "No silent changes",
                boundaryLabel: "Broad reflow needs confirmation. Undo not supported yet.",
                visualState: .warning,
                target: nil,
                planRoute: nil
            )
        ],
        visualState: .warning
    )

    private static let emptyReflowDecision = PlanReflowDecisionState(
        title: "Reflow decisions",
        subtitle: "Choose one path before anything changes.",
        sourceLabel: "Based on your plan",
        trustLabel: "No silent changes",
        reasonLabel: "There is not enough plan pressure to reflow yet.",
        recoveryLabel: "No schedule changes happen from this card.",
        receiptLabel: "Safe local suggestion. No silent rescheduling. No calendar write. Nothing changed yet.",
        options: [
            PlanReflowDecisionOptionState(
                id: "preview-empty-decision-keep",
                kind: .keepPlan,
                title: "Keep plan",
                detail: "Create or choose one plan item before reflowing anything.",
                impactLabel: "No plan mutation",
                sourceLabel: "Based on your plan",
                trustLabel: "No silent changes",
                boundaryLabel: "Safe local suggestion. Undo can be local.",
                visualState: .default,
                target: nil,
                planRoute: nil
            )
        ],
        visualState: .default
    )
}
