import AmbitionsDesignSystem
import Foundation

extension PreviewTimeScenarios {
    static let empty = TimeSurfaceState(
        mode: .empty,
        timeframeLabel: "Apr 20-Apr 26",
        hero: TimeRealityHeroState(
            eyebrow: "Time",
            title: "Shape Time",
            subtitle: "Time stays calm until real goals, captures, or routines create week pressure worth shaping.",
            dominantTruth: "The week is mostly empty, which is useful information.",
            roomSummary: "All seven days are carrying visible room right now.",
            pressureSummary: "There is no active outside pressure asking the week to harden yet.",
            contextPills: [
                TimeHeroPillState(title: "Apr 20-Apr 26", icon: "calendar", state: .default),
                TimeHeroPillState(title: "Open", icon: AmbitionsSurface.time.systemImage, state: .default),
                TimeHeroPillState(title: "0/1 goals visible", icon: "target", state: .default)
            ],
            trustWhisper: "This quiet week is real because nothing active is asking it to carry more."
        ),
        lifeSuite: emptyLifeSuite,
        primaryAction: TimeWeekPrimaryAction(
            kind: .useRoom,
            title: "Use this room",
            subtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
            systemImage: "sparkles",
            state: .success,
            goalTarget: nil,
            timeRoute: nil
        ),
        treaty: TimeTreatyState(
            title: "This week's agreement",
            summary: "The week is allowed to stay open until real work needs shape.",
            protectedWork: "Nothing is marked as protected yet.",
            flexibleWork: "No flexible work is asking for placement right now.",
            notTodayWork: "Nothing obvious needs to be kept outside today.",
            recoveryAllowance: "7 open days keep recovery room visible.",
            calendarBoundary: "Manual shaping still works without calendar access.",
            primaryActionTitle: "Use this room",
            primaryActionSubtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
            visualState: .success
        ),
        capacityEnvelope: TimeCapacityEnvelopeState(
            title: "Capacity envelope",
            detail: "Manual availability is enough to keep shaping this week. The envelope stays qualitative so it does not pretend to know more than the data shows.",
            label: "Light",
            availableCapacity: "7 open days",
            pressure: "Pressure is readable",
            protectedFocus: "Focus time is not explicit yet",
            recoveryMargin: "Recovery room exists",
            visualState: .success
        ),
        lifecycleRail: TimeGoalLifecycleRailState(
            title: "What this week is carrying",
            subtitle: "Goals stay visible by lifecycle, including work that belongs outside this week's pressure.",
            segments: [
                TimeGoalLifecycleRailSegment(lifecycleState: .previous, count: 0, subtitle: "No prior pressure"),
                TimeGoalLifecycleRailSegment(lifecycleState: .active, count: 0, subtitle: "No live load"),
                TimeGoalLifecycleRailSegment(lifecycleState: .future, count: 0, subtitle: "Nothing scheduled later"),
                TimeGoalLifecycleRailSegment(lifecycleState: .waiting, count: 0, subtitle: "No waiting goal"),
                TimeGoalLifecycleRailSegment(lifecycleState: .blocked, count: 0, subtitle: "No blocked goal"),
                TimeGoalLifecycleRailSegment(lifecycleState: .parked, count: 0, subtitle: "Nothing parked"),
                TimeGoalLifecycleRailSegment(lifecycleState: .protected, count: 0, subtitle: "Nothing protected"),
                TimeGoalLifecycleRailSegment(lifecycleState: .completed, count: 0, subtitle: "No completion here"),
                TimeGoalLifecycleRailSegment(lifecycleState: .cancelledDropped, count: 0, subtitle: "No dropped goal")
            ]
        ),
        timelineStrip: TimeTimelineStripState(
            title: "Rich Timeline",
            subtitle: "No goal movement is visible yet.",
            items: []
        ),
        opportunityWindows: TimeOpportunityWindowsState(
            title: "Opportunity windows",
            subtitle: "Windows are work modes, not a calendar grid.",
            windows: [
                TimeOpportunityWindowItem(id: "preview-empty-window", title: "Keep this light", detail: "No believable window is asking to be filled.", modeLabel: "Recovery", timingLabel: "Manual", visualState: .default, target: nil)
            ]
        ),
        decisionDebt: TimeDecisionDebtState(
            title: "Needs a decision",
            subtitle: "No unresolved shaping decision is loud right now.",
            items: []
        ),
        conflictCourt: TimeConflictCourtState(
            title: "Conflicts to negotiate",
            subtitle: "No visible conflict needs court right now.",
            conflicts: []
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
                TimeDecisionItemState(id: "preview-empty-recovery", title: "Protect recovery room", detail: "The safest choice is keeping an open pocket unfilled.", suggestion: "Recovery room is part of the week fit, not a failure to optimize.", visualState: .success, target: nil, timeRoute: nil)
            ],
            boundary: "No schedule changes happen from this card."
        ),
        realityReflow: TimeRealityReflowState(
            title: "Not enough shape data yet",
            detail: "Create or choose one Time item before reviewing a change.",
            reasonKind: .lowData,
            reasonDetail: "There is not enough week pressure to reshape yet.",
            recommendedAdjustment: "Keep week fit unchanged",
            noChangeCopy: "Nothing changed yet.",
            suggestions: [
                TimeReflowSuggestionState(
                    id: "preview-empty-shape-keep",
                    kind: .keepTimeUnchanged,
                    title: "Keep week fit unchanged",
                    detail: "Create or choose one Time item before reviewing a change.",
                    impactLabel: "No shape mutation",
                    boundary: TimeReflowBoundaryState(actionKind: .noOp, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"),
                    visualState: .default,
                    target: nil,
                    timeRoute: nil
                )
            ],
            visualState: .default
        ),
        reflowDecision: emptyReflowDecision,
        recoveryGradient: TimeRecoveryGradientState(
            title: "Recovery options",
            detail: "No recovery is needed, but the order stays ready if reality changes.",
            options: [
                TimeRecoveryGradientOptionState(id: "preview-empty-gradient-protect", order: 0, kind: .protectOneItem, title: "Keep this", detail: "Keep one must-do visible.", boundary: TimeReflowBoundaryState(actionKind: .changeTimeWindow, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .selected),
                TimeRecoveryGradientOptionState(id: "preview-empty-gradient-shrink", order: 1, kind: .shrinkAction, title: "Make it smaller", detail: "Reduce the ask before moving it.", boundary: TimeReflowBoundaryState(actionKind: .shrinkAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-empty-gradient-split", order: 2, kind: .splitAction, title: "Split it", detail: "Carry only the first clear part.", boundary: TimeReflowBoundaryState(actionKind: .splitAction, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-empty-gradient-move", order: 3, kind: .moveLocalActionLater, title: "Adjust shape", detail: "Move one local item after confirmation.", boundary: TimeReflowBoundaryState(actionKind: .moveActionLater, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-empty-gradient-defer", order: 4, kind: .deferGoalOrItem, title: "Defer this", detail: "Leave lower-priority work outside this window.", boundary: TimeReflowBoundaryState(actionKind: .deferAction, confirmationRequirement: .requiredForBroadReflow, undoAvailability: .requiresConfirmation, safetyLabel: "Confirm first"), visualState: .default),
                TimeRecoveryGradientOptionState(id: "preview-empty-gradient-drop", order: 5, kind: .dropOptionalWork, title: "Drop optional work", detail: "Remove optional work only with confirmation.", boundary: TimeReflowBoundaryState(actionKind: .dropAction, confirmationRequirement: .requiredForDestructiveChange, undoAvailability: .unsafe, safetyLabel: "Confirm drop"), visualState: .warning),
                TimeRecoveryGradientOptionState(id: "preview-empty-gradient-recover", order: 6, kind: .recoverRest, title: "Recover", detail: "Protect rest or recovery as real Time material.", boundary: TimeReflowBoundaryState(actionKind: .noOp, confirmationRequirement: .notRequired, undoAvailability: .availableLocal, safetyLabel: "Safe/local"), visualState: .success)
            ]
        ),
        saveTheDay: TimeSaveTheDayState(
            title: "Save the Day in Time",
            detail: "Time handles the deeper recovery shape without changing anything for you.",
            oneQuestion: nil,
            protectedItem: "One must-do",
            adjustment: "Keep the week fit unchanged",
            recoveryExplanation: "No rescue is needed; keep recovery room visible.",
            boundary: "No silent rescheduling. No calendar write. Nothing changed yet.",
            visualState: .default
        ),
        reflowReceiptPreview: TimeReflowReceiptPreviewState(
            title: "Before anything changes",
            detail: "A shape review preview shows the tradeoff before action, not after a silent mutation.",
            whatChanged: ["Protect: One must-do", "Adjust: Keep the week fit unchanged", "No reshaping would be applied."],
            whatWouldNotChange: ["Calendar blocks are not written.", "The week is not silently rescheduled.", "Sync, export, widgets, and future systems are not touched."],
            momentumReflowContract: [
                "Original block link: One must-do (source confirmation path active).",
                "Approved duration: user-approved duration selection is required before reassignment.",
                "Displaced step pressure: no displaced step pressure recalculation needed for still-believable states.",
                "Destination step: active destination step pressure remains unchanged.",
                "LifeShape impact: no recovery shift needed now."
            ],
            confirmationRequired: "Safe local suggestion",
            undoAvailability: "Undo can be local",
            safeFailureFallback: "If you decline confirmation, Ambitions keeps the week fit as-is and leaves manual shaping available.",
            visualState: .default
        ),
        recoveryMaturity: TimeRecoveryMaturityState(
            title: "Recovery maturity",
            detail: "Overloaded days become decisions with receipts, not silent reschedules.",
            timeFitLabel: "Believable",
            confirmationBoundary: "Save the Day and shape review require confirmation before broad Time changes.",
            calendarBoundary: "Manual shaping works without calendar access.",
            socialBoundary: "People-shaped pressure stays private, optional, and manually named.",
            receiptBoundary: "A review preview names what would change, what would not change, and the undo boundary.",
            signals: [
                TimeRecoveryMaturitySignalState(id: "fit", title: "Shape fit", detail: "No rescue is needed; keep recovery room visible.", statusLabel: "Believable", boundaryLabel: "Suggests one smaller step", visualState: .success),
                TimeRecoveryMaturitySignalState(id: "waiting-commitments", title: "Waiting and commitments", detail: "No waiting item or one-time commitment is currently pushing on the week.", statusLabel: "Quiet", boundaryLabel: "No silent routing", visualState: .default),
                TimeRecoveryMaturitySignalState(id: "social-load", title: "Social load", detail: "No social-load assumption is inferred.", statusLabel: "Manual", boundaryLabel: "No inference without you", visualState: .default),
                TimeRecoveryMaturitySignalState(id: "receipt", title: "Receipt and undo", detail: "If you decline confirmation, Ambitions keeps the week fit as-is.", statusLabel: "Safe local suggestion", boundaryLabel: "Undo can be local", visualState: .default)
            ]
        ),
        pressureScrubber: TimePressureScrubberState(
            title: "Pressure scrubber",
            subtitle: "Scrub the empty week to see open room without forcing structure.",
            defaultDayID: "day-0",
            points: (0..<7).map { dayIndex in
                TimePressureScrubberPoint(
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
            TimeElasticWeekDayState(
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
                openWindow: TimeOpenWindowState(title: "Leave this open", detail: "Open room keeps the week doable.", suggestionLabel: nil, target: nil, visualState: .default)
            )
        },
        believability: TimeBelievabilityState(
            title: "The week is open",
            detail: "No active goals or captures are pressing for structure yet.",
            label: "Open",
            supportLabel: "This is a real state, not missing data.",
            visualState: .default
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
            calmExplanation: "This quiet week is real because nothing is asking it to carry more yet.",
            focusProtection: "Protect the open room until something meaningful needs it.",
            tradeoffFraming: "Do not manufacture density for the sake of filling the week.",
            lanes: [
                TimeExecutionResilienceLane(id: "carryover", title: "Carryover", detail: "No active goal is floating outside the week.", recommendation: "Carry only what the next week can explain calmly.", state: .success, goalTarget: nil, timeRoute: nil),
                TimeExecutionResilienceLane(id: "overload", title: "Overload", detail: "No day is visibly overloaded right now.", recommendation: "Lighten only when something real becomes too loud.", state: .selected, goalTarget: nil, timeRoute: nil),
                TimeExecutionResilienceLane(id: "rituals", title: "Rituals", detail: "No recurring loop is shaping the week yet.", recommendation: "Keep the week dominant until a routine is truly needed.", state: .default, goalTarget: nil, timeRoute: .rituals),
                TimeExecutionResilienceLane(id: "captures", title: "Captures", detail: "No open captures are pushing on this week.", recommendation: "Let the week stay quiet.", state: .default, goalTarget: nil, timeRoute: nil, interactionIntent: .openGlobalCapture),
                TimeExecutionResilienceLane(id: "review", title: "Weekly review", detail: "Review becomes useful once the week has something real to carry forward.", recommendation: "Use review only when the week has earned it.", state: .default, goalTarget: nil, timeRoute: .weeklyReview)
            ],
            windowMagnetism: nil
        ),
        goalShapingItems: [],
        shapingActions: [
            TimeShapingActionState(kind: .edit, title: "Edit", subtitle: "No dated block is visible yet.", recommendation: "Time stays quiet until a real block exists.", systemImage: "square.and.pencil", state: .default, goalTarget: nil, timeRoute: nil),
            TimeShapingActionState(kind: .patch, title: "Patch", subtitle: "Patch the week only when real work arrives.", recommendation: "Do not manufacture density for the sake of filling the week.", systemImage: "wand.and.stars", state: .selected, goalTarget: nil, timeRoute: nil),
            TimeShapingActionState(kind: .protect, title: "Protect", subtitle: "Protect the open room while it is still calm.", recommendation: "The best protection step may be leaving the week quiet.", systemImage: "shield", state: .success, goalTarget: nil, timeRoute: nil),
            TimeShapingActionState(kind: .lighten, title: "Lighten", subtitle: "There is nothing to lighten yet.", recommendation: "No overload is visible right now.", systemImage: "sun.max", state: .default, goalTarget: nil, timeRoute: nil)
        ],
        secondaryDestinations: [
            TimeSecondaryDestination(id: "time-empty-rituals", title: "Ritual loops", detail: "Review the repeatable loops that can steady or crowd the week.", valueLabel: "0", icon: "repeat", visualState: .default, timeRoute: .rituals),
            TimeSecondaryDestination(id: "time-held-input", title: "Open Capture composer", detail: "No open captures are pushing on the week right now.", valueLabel: "0", icon: "square.and.pencil", visualState: .default, timeRoute: nil, interactionIntent: .openGlobalCapture),
            TimeSecondaryDestination(id: "time-empty-weekly-review", title: "Weekly review", detail: "Review stays available as the eventual closeout path for a real week.", valueLabel: "Open", icon: "arrow.triangle.branch", visualState: .default, timeRoute: .weeklyReview)
        ],
        emptyTitle: "No weekly pressure yet",
        emptyMessage: "As soon as goals, captures, or routines create real constraints, Time will show where the week still has room."
    )
}
