import AmbitionsDesignSystem
import Foundation

extension PreviewTimeScenarios {
    static let seeded = TimeSurfaceState(
        mode: .active,
        timeframeLabel: "Apr 20-Apr 26",
        hero: TimeRealityHeroState(
            eyebrow: "Time",
            title: "Shape Time",
            subtitle: "Time reads the week as open room, goal time, pressure, and protected structure.",
            dominantTruth: "Pressure is clustering into one overloaded day, while two calmer windows still have believable room.",
            roomSummary: "Wednesday and Saturday can still carry one small step without collapsing into calendar noise.",
            pressureSummary: "Open captures and one fragile goal are the loudest reasons the week still needs shaping.",
            contextPills: [
                TimeHeroPillState(title: "Apr 20-Apr 26", icon: "calendar", state: .default),
                TimeHeroPillState(title: "Tight", icon: AmbitionsSurface.time.systemImage, state: .selected),
                TimeHeroPillState(title: "2/3 goals visible", icon: "target", state: .selected)
            ],
            trustWhisper: "One active goal is still outside the week, so the current calm is real but incomplete."
        ),
        lifeSuite: seededLifeSuite,
        primaryAction: TimeWeekPrimaryAction(
            kind: .useRoom,
            title: "Use this room",
            subtitle: "Wednesday still has believable room for the retention loop.",
            systemImage: "arrow.down.left.and.arrow.up.right",
            state: .success,
            goalTarget: GoalRouteTarget(goalID: "preview-goal-2"),
            timeRoute: nil
        ),
        treaty: TimeTreatyState(
            title: "This week's agreement",
            summary: "Protect shell work, flex the retention loop, keep one capture outside today, and leave recovery room visible.",
            protectedWork: "3 protected or fixed items should stay defended.",
            flexibleWork: "4 flexible items can bend around real life.",
            notTodayWork: "2 items should wait, clarify, or stay outside today's pressure.",
            recoveryAllowance: "2 open days keep recovery room visible.",
            calendarBoundary: "Manual shaping still works without calendar access.",
            primaryActionTitle: "Use this room",
            primaryActionSubtitle: "Wednesday still has believable room for the retention loop.",
            visualState: .selected
        ),
        capacityEnvelope: TimeCapacityEnvelopeState(
            title: "Capacity envelope",
            detail: "Manual availability is enough to keep shaping this week. The envelope stays qualitative so it does not pretend to know more than the data shows.",
            label: "Tight",
            availableCapacity: "2 open days",
            pressure: "Pressure is visible",
            protectedFocus: "3 protected items",
            recoveryMargin: "Recovery room exists",
            visualState: .warning
        ),
        lifecycleRail: TimeGoalLifecycleRailState(
            title: "What this week is carrying",
            subtitle: "Goals stay visible by lifecycle, including work that belongs outside this week's pressure.",
            segments: [
                TimeGoalLifecycleRailSegment(lifecycleState: .previous, count: 1, subtitle: "Closed, parked, or transformed"),
                TimeGoalLifecycleRailSegment(lifecycleState: .active, count: 2, subtitle: "Currently shaping attention"),
                TimeGoalLifecycleRailSegment(lifecycleState: .future, count: 1, subtitle: "Future, not active yet"),
                TimeGoalLifecycleRailSegment(lifecycleState: .waiting, count: 1, subtitle: "Waiting on an answer"),
                TimeGoalLifecycleRailSegment(lifecycleState: .blocked, count: 1, subtitle: "Needs unblock"),
                TimeGoalLifecycleRailSegment(lifecycleState: .parked, count: 1, subtitle: "Intentionally outside pressure"),
                TimeGoalLifecycleRailSegment(lifecycleState: .protected, count: 1, subtitle: "Should be defended"),
                TimeGoalLifecycleRailSegment(lifecycleState: .completed, count: 1, subtitle: "Done and preserved"),
                TimeGoalLifecycleRailSegment(lifecycleState: .cancelledDropped, count: 1, subtitle: "Dropped without shame")
            ]
        ),
        timelineStrip: TimeTimelineStripState(
            title: "Rich Timeline",
            subtitle: "A compact strip of previous, active, future, and outside pressure with local source labels.",
            items: [
                TimeTimelineItemState(id: "preview-previous", title: "Launch audit", detail: "Kept outside current pressure.", timingLabel: "Previous", sourceLabel: "Created in Ambitions", kind: .previous, visualState: .default, target: nil),
                TimeTimelineItemState(id: "preview-active", title: "Ship the native shell", detail: "Fix shell regressions", timingLabel: "Due Apr 21", sourceLabel: "Based on your Time shape", kind: .active, visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-1")),
                TimeTimelineItemState(id: "preview-future", title: "Retention loop", detail: "Future work, not part of this week's load.", timingLabel: "Future", sourceLabel: "Based on your Time shape", kind: .future, visualState: .default, target: GoalRouteTarget(goalID: "preview-goal-2"))
            ]
        ),
        opportunityWindows: TimeOpportunityWindowsState(
            title: "Opportunity windows",
            subtitle: "Windows are work modes, not a calendar grid.",
            windows: [
                TimeOpportunityWindowItem(id: "preview-window-focus", title: "Good window for one focused step", detail: "Wednesday can carry one believable step without turning calendar-dense.", modeLabel: "Focus", timingLabel: "Wed 22", visualState: .success, target: GoalRouteTarget(goalID: "preview-goal-2")),
                TimeOpportunityWindowItem(id: "preview-window-admin", title: "Better for admin", detail: "Thursday can hold only lightweight follow-up.", modeLabel: "Admin", timingLabel: "Thu 23", visualState: .default, target: nil)
            ]
        ),
        decisionDebt: TimeDecisionDebtState(
            title: "Needs a decision",
            subtitle: "Small decisions prevent the week from becoming a dense task manager.",
            items: [
                TimeDecisionItemState(id: "preview-decision", title: "Needs a decision", detail: "Retention loop is active but not represented in this week window.", suggestion: "Give it one step, park it, or leave it intentionally outside today.", visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-2"), timeRoute: nil)
            ]
        ),
        conflictCourt: TimeConflictCourtState(
            title: "Conflicts to negotiate",
            subtitle: "These are negotiation items, not alarms.",
            conflicts: [
                TimeDecisionItemState(id: "preview-conflict", title: "Important goals are competing", detail: "Two goals are asking the same week to hold them.", suggestion: "Choose the one that must stay and let the other flex.", visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-1"), timeRoute: nil)
            ]
        ),
        calendarBoundary: TimeCalendarBoundaryContractState(
            title: "Calendar stays optional",
            detail: "Time works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
            permissionLabel: "Optional",
            sourceLabel: "Based on Time",
            manualFallback: "Manual shaping still works without calendar access.",
            writeBoundary: "Time never silently writes or reschedules calendar blocks.",
            visualState: .default,
            canRequestCalendarRead: true
        ),
        recoveryEntry: TimeRecoveryEntryState(
            title: "Recovery room",
            detail: "Save the Day stays suggestion-only here. Broad reshaping waits for confirmed recovery tools.",
            suggestions: [
                TimeDecisionItemState(id: "preview-recovery", title: "Shrink one step", detail: "Ship the native shell is the clearest place to reduce pressure.", suggestion: "Make the next step smaller before moving anything else.", visualState: .warning, target: GoalRouteTarget(goalID: "preview-goal-1"), timeRoute: nil)
            ],
            boundary: "No schedule changes happen from this card."
        ),
        realityReflow: TimeRealityReflowState(
            title: "Reality changed",
            detail: "Adjust one thing, not everything. These are suggestions until you confirm a change.",
            reasonKind: .overloadedTimeShape,
            reasonDetail: "Tuesday is carrying more than this week can calmly explain.",
            recommendedAdjustment: "Keep this",
            noChangeCopy: "Nothing changed yet.",
            suggestions: [
                TimeReflowSuggestionState(
                    id: "preview-shape-protect",
                    kind: .protectOneItem,
                    title: "Keep this",
                    detail: "Keep shell regression work defended before changing the rest.",
                    impactLabel: "Smallest useful adjustment",
                    boundary: TimeReflowBoundaryState(actionKind: .changeTimeWindow, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"),
                    visualState: .selected,
                    target: GoalRouteTarget(goalID: "preview-goal-1"),
                    timeRoute: nil
                ),
                TimeReflowSuggestionState(
                    id: "preview-shape-shrink",
                    kind: .shrinkAction,
                    title: "Make it smaller",
                    detail: "Close only the top regression before moving anything else.",
                    impactLabel: "Local suggestion only",
                    boundary: TimeReflowBoundaryState(actionKind: .shrinkAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"),
                    visualState: .warning,
                    target: GoalRouteTarget(goalID: "preview-goal-1"),
                    timeRoute: nil
                ),
                TimeReflowSuggestionState(
                    id: "preview-shape-confirm",
                    kind: .askForConfirmation,
                    title: "Needs confirmation",
                    detail: "Confirm before applying any broad reshaping or calendar-impacting change.",
                    impactLabel: "Nothing changes until confirmed",
                    boundary: TimeReflowBoundaryState(actionKind: .changeTimeWindow, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .notSupportedYet, safetyLabel: "Confirm first"),
                    visualState: .warning,
                    target: nil,
                    timeRoute: nil
                )
            ],
            visualState: .warning
        ),
        reflowDecision: seededReflowDecision,
        recoveryGradient: TimeRecoveryGradientState(
            title: "Recovery options",
            detail: "Start with the least disruptive option that still makes the week believable.",
            options: [
                TimeRecoveryGradientOptionState(id: "preview-gradient-protect", order: 0, kind: .protectOneItem, title: "Keep this", detail: "Keep one must-do visible.", boundary: TimeReflowBoundaryState(actionKind: .changeTimeWindow, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .selected),
                TimeRecoveryGradientOptionState(id: "preview-gradient-shrink", order: 1, kind: .shrinkAction, title: "Make it smaller", detail: "Reduce the ask before moving it.", boundary: TimeReflowBoundaryState(actionKind: .shrinkAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-gradient-split", order: 2, kind: .splitAction, title: "Split it", detail: "Carry only the first clear part.", boundary: TimeReflowBoundaryState(actionKind: .splitAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-gradient-move", order: 3, kind: .moveLocalActionLater, title: "Adjust shape", detail: "Move one local item after confirmation.", boundary: TimeReflowBoundaryState(actionKind: .moveActionLater, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-gradient-defer", order: 4, kind: .deferGoalOrItem, title: "Defer this", detail: "Leave lower-priority work outside this window.", boundary: TimeReflowBoundaryState(actionKind: .deferAction, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-gradient-drop", order: 5, kind: .dropOptionalWork, title: "Drop optional work", detail: "Remove optional work only with confirmation.", boundary: TimeReflowBoundaryState(actionKind: .dropAction, confirmationRequirement: .requiredForDestructiveChange, undoAvailability: .unsafe, safetyLabel: "Confirm drop"), visualState: .warning),
                TimeRecoveryGradientOptionState(id: "preview-gradient-recover", order: 6, kind: .recoverRest, title: "Recover", detail: "Protect rest or recovery as real Time material.", boundary: TimeReflowBoundaryState(actionKind: .noOp, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .success)
            ]
        ),
        saveTheDay: TimeSaveTheDayState(
            title: "Save the Day in Time",
            detail: "Time handles the deeper recovery shape without changing anything for you.",
            oneQuestion: "What is the one thing that still needs protection?",
            protectedItem: "Fix shell regressions",
            adjustment: "Make it smaller",
            recoveryExplanation: "Recovery works by protecting one thing, reducing one thing, and leaving the rest unchanged until you confirm.",
            boundary: "No silent rescheduling. No calendar write. Nothing changed yet.",
            visualState: .warning
        ),
        reflowReceiptPreview: TimeReflowReceiptPreviewState(
            title: "Before anything changes",
            detail: "A shape review preview shows the tradeoff before action, not after a silent mutation.",
            whatChanged: ["Protect: Fix shell regressions", "Adjust: Make it smaller", "Receipt would show the suggested change before action."],
            whatWouldNotChange: ["Calendar blocks are not written.", "The week is not silently rescheduled.", "Sync, export, widgets, and future systems are not touched."],
            momentumReflowContract: [
                "Original block link: Fix shell regressions (source confirmation path active).",
                "Approved duration: user-approved duration selection is required before reassignment.",
                "Displaced step pressure: current pressure context is recalculated before any write.",
                "Destination step: goal-1 pressure is recalculated in this contract.",
                "LifeShape impact: recoverable pressure for destination and displaced steps is recalculated."
            ],
            confirmationRequired: "Safe local suggestion",
            undoAvailability: "Undo can be local",
            safeFailureFallback: "If you decline confirmation, Ambitions keeps the week fit as-is and leaves manual shaping available.",
            visualState: .warning
        ),
        recoveryMaturity: TimeRecoveryMaturityState(
            title: "Recovery maturity",
            detail: "Overloaded days become decisions with receipts, not silent reschedules.",
            timeFitLabel: "Needs relief",
            confirmationBoundary: "Save the Day and shape review require confirmation before broad Time changes.",
            calendarBoundary: "Manual shaping works without calendar access.",
            socialBoundary: "People-shaped pressure stays private, optional, and manually named.",
            receiptBoundary: "A review preview names what would change, what would not change, and the undo boundary.",
            signals: [
                TimeRecoveryMaturitySignalState(id: "fit", title: "Shape fit", detail: "One day needs relief before the week widens.", statusLabel: "Needs relief", boundaryLabel: "Suggests one smaller step", visualState: .warning),
                TimeRecoveryMaturitySignalState(id: "waiting-commitments", title: "Waiting and commitments", detail: "One waiting item should stay visible instead of becoming quiet pressure.", statusLabel: "Visible", boundaryLabel: "No silent routing", visualState: .warning),
                TimeRecoveryMaturitySignalState(id: "social-load", title: "Social load", detail: "People-shaped pressure stays private and manual-first.", statusLabel: "Private", boundaryLabel: "No inference without you", visualState: .selected),
                TimeRecoveryMaturitySignalState(id: "receipt", title: "Receipt and undo", detail: "If you decline confirmation, Ambitions keeps the week fit as-is.", statusLabel: "Safe local suggestion", boundaryLabel: "Undo can be local", visualState: .warning)
            ]
        ),
        pressureScrubber: TimePressureScrubberState(
            title: "Pressure scrubber",
            subtitle: "Scrub the week to inspect where pressure gathers and where room remains.",
            defaultDayID: "day-1",
            points: [
                TimePressureScrubberPoint(id: "day-0", weekdayLabel: "Mon", dateLabel: "20", level: .steady, pressureValue: 0.62, roomLabel: "Steady load", summary: "Shell work is anchoring the day."),
                TimePressureScrubberPoint(id: "day-1", weekdayLabel: "Tue", dateLabel: "21", level: .overloaded, pressureValue: 1.0, roomLabel: "Needs relief", summary: "Pressure is stacking here."),
                TimePressureScrubberPoint(id: "day-2", weekdayLabel: "Wed", dateLabel: "22", level: .open, pressureValue: 0.45, roomLabel: "Open day", summary: "Retention loop could fit here."),
                TimePressureScrubberPoint(id: "day-3", weekdayLabel: "Thu", dateLabel: "23", level: .tight, pressureValue: 0.82, roomLabel: "Little room left", summary: "This day needs protected edges."),
                TimePressureScrubberPoint(id: "day-4", weekdayLabel: "Fri", dateLabel: "24", level: .steady, pressureValue: 0.66, roomLabel: "Room remains", summary: "The review notes are anchoring this day."),
                TimePressureScrubberPoint(id: "day-5", weekdayLabel: "Sat", dateLabel: "25", level: .open, pressureValue: 0.42, roomLabel: "Wide room", summary: "Keep the room visible."),
                TimePressureScrubberPoint(id: "day-6", weekdayLabel: "Sun", dateLabel: "26", level: .steady, pressureValue: 0.6, roomLabel: "Steady load", summary: "The week resets calmly here.")
            ]
        ),
        weekDays: seededWeekDays,
        believability: TimeBelievabilityState(
            title: "The week is believable but tight",
            detail: "The structure can hold, but Tuesday is overloaded and one active goal is still missing from the week.",
            label: "Tight",
            supportLabel: "Patch missing work into an open window instead of forcing it into the crowded days.",
            visualState: .selected
        ),
        calendarAwareness: TimeCalendarAwarenessState(
            status: .baseline,
            title: "Make Time calendar-aware",
            detail: "Time works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
            primaryActionTitle: "Make Time calendar-aware",
            primaryActionSystemImage: "calendar.badge.plus",
            valueLabel: "Optional",
            sourceLabel: "Based on Time",
            visualState: .default,
            canRequestCalendarRead: true
        ),
        resilience: TimeExecutionResilienceState(
            title: "Execution resilience",
            subtitle: "Carryover, overload, and recovery shaping stay explainable by keeping one smaller lane obvious at a time.",
            calmExplanation: "One active goal still needs a believable carryover lane instead of diffuse pressure.",
            focusProtection: "Protect Wednesday before Tuesday pressure spills into it.",
            tradeoffFraming: "Open captures should compete with the week honestly. Absorb them, park them, or let them wait.",
            lanes: [
                TimeExecutionResilienceLane(id: "carryover", title: "Carryover", detail: "Retention loop still sits outside the week.", recommendation: "Give it one calmer lane instead of widening the whole week.", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-2"), timeRoute: nil),
                TimeExecutionResilienceLane(id: "overload", title: "Overload", detail: "Tuesday is carrying more than the week can explain calmly.", recommendation: "Lighten shell work before adding anything new.", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-1"), timeRoute: nil),
                TimeExecutionResilienceLane(id: "rituals", title: "Rituals", detail: "One routine should support the week fit without crowding it.", recommendation: "Use the rituals route to keep the loop lightweight.", state: .selected, goalTarget: nil, timeRoute: .rituals),
                TimeExecutionResilienceLane(id: "captures", title: "Captures", detail: "Two open captures still need to be absorbed or parked.", recommendation: "Attach or park capture pressure before polishing the schedule.", state: .warning, goalTarget: nil, timeRoute: nil, interactionIntent: .openGlobalCapture),
                TimeExecutionResilienceLane(id: "review", title: "Weekly review", detail: "Close the current week by shaping what should continue.", recommendation: "Review should feel like a continuation, not a detached ritual.", state: .warning, goalTarget: nil, timeRoute: .weeklyReview)
            ],
            windowMagnetism: TimeWindowMagnetismState(
                title: "Window magnetism",
                detail: "Wednesday is the cleanest place for a calmer suggestion to dock.",
                dayLabel: "Wed 22",
                suggestionTitle: "Retention loop",
                suggestionDetail: "This day can carry one believable step without turning calendar-dense.",
                target: GoalRouteTarget(goalID: "preview-goal-2"),
                visualState: .success
            )
        ),
        goalShapingItems: seededGoalShapingItems,
        shapingActions: seededShapingActions,
        secondaryDestinations: seededSecondaryDestinations,
        emptyTitle: nil,
        emptyMessage: nil
    )

}
