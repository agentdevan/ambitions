import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedTimeService: TimeServicing {
    let repositories: AppRepositories
    let calendarRealityService: (any CalendarRealityServicing)?
    let timeFeatureService: TimeFeatureService

    init(
        repositories: AppRepositories,
        calendarRealityService: (any CalendarRealityServicing)? = nil,
        timeFeatureService: TimeFeatureService = .init()
    ) {
        self.repositories = repositories
        self.calendarRealityService = calendarRealityService
        self.timeFeatureService = timeFeatureService
    }

    func loadTimeDashboard(now: Date) async throws -> TimeDashboard {
        let snapshot = try await loadSnapshot()
        let permission = await calendarRealityService?.calendarPermissionState() ?? .unavailable
        return try await timeFeatureService.makeDashboard(
            from: self,
            now: now,
            permission: permission,
            openWindowCount: nil,
            snapshot: snapshot
        )
    }

    func loadWeeklyReviewDashboard(now: Date) async throws -> WeeklyReviewDashboard {
        return try await timeFeatureService.makeWeeklyReviewDashboard(from: self, now: now)
    }

    func makeTimeCalendarAware(now: Date) async throws -> TimeDashboard {
        let snapshot = try await loadSnapshot()
        guard let calendarRealityService else {
            return try await timeFeatureService.makeDashboard(
                from: self,
                now: now,
                permission: .unavailable,
                openWindowCount: nil,
                snapshot: snapshot
            )
        }
        let result = await calendarRealityService.findOpenWindows(
            request: CalendarRealityReadRequest(
                horizon: weekHorizon(now: now),
                userInitiatedPlanAction: "Make Time calendar-aware",
                minimumWindowMinutes: 30
            )
        )
        let realitySnapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: weekHorizon(now: now),
                activeContextLens: .all,
                calendarBusyWindows: result.derivedBusyWindows,
                calendarContext: result.calendarContext,
                minimumWindowMinutes: 30
            )
        )
        let event = RealityIntegrationAdapter.calendarContextObservedEntry(
            snapshot: realitySnapshot,
            occurredAt: now,
            actionName: "Make Time calendar-aware"
        )
        try? await repositories.eventLedger.append(event)
        return try await timeFeatureService.makeDashboard(
            from: self,
            now: now,
            permission: result.permissionState,
            openWindowCount: result.openWindowCandidates.count,
            snapshot: snapshot
        )
    }
}

extension RepositoryBackedTimeService: TimeFeatureProjectionSource {}

extension RepositoryBackedTimeService {
    func makeDashboard(snapshot: Snapshot, now: Date, calendarAwareness: TimeCalendarAwarenessState) -> TimeDashboard {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let openCaptures = snapshot.captures.filter { $0.status != .archived }
        let blockedDrafts = snapshot.drafts.filter { $0.latestResultKind == .blocked }
        let clarificationDrafts = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }
        let activeGoalSummaries = makeGoalSummaries(goals: activeGoals, feedback: snapshot.feedback, now: now)
        let weekContexts = activeGoalSummaries.flatMap(\.contexts)
        let evidenceByGoal = Dictionary(grouping: snapshot.evidence, by: \.goalID)
        let habitGoals = activeGoals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }
        let mode: TimeDashboardMode = activeGoals.isEmpty && snapshot.drafts.isEmpty && openCaptures.isEmpty ? .empty : .active
        let missingGoalSummaries = activeGoalSummaries.filter { $0.contexts.isEmpty }
        let mostPressuredGoal = pressuredGoalSummary(from: activeGoalSummaries)
        let weekDays = makeWeekDays(
            summaries: activeGoalSummaries,
            missingGoalSummaries: missingGoalSummaries,
            now: now
        )
        let posture = postureState(
            evaluations: activeGoalSummaries.compactMap(\.evaluation),
            blockedCount: blockedDrafts.count,
            clarificationCount: clarificationDrafts.count,
            openCaptureCount: openCaptures.count,
            weekDays: weekDays,
            mode: mode
        )
        let representedGoalCount = Set(weekContexts.map(\.goal.id)).count
        let pressureScrubber = makePressureScrubber(days: weekDays)
        let believability = makeBelievability(
            posture: posture,
            blockedCount: blockedDrafts.count,
            clarificationCount: clarificationDrafts.count,
            openCaptureCount: openCaptures.count,
            missingGoalCount: missingGoalSummaries.count,
            activeGoalCount: activeGoals.count
        )
        let lifeSuite = TimeLifeSuiteProjector().project(
            weekDays: weekDays,
            calendarAwareness: calendarAwareness,
            openCaptureCount: openCaptures.count,
            activeGoalCount: activeGoals.count,
            mode: mode
        )
        let hero = makeHero(
            posture: posture,
            timeframeLabel: timeframeLabel(now: now),
            representedGoalCount: representedGoalCount,
            activeGoalCount: activeGoals.count,
            weekDays: weekDays,
            missingGoalCount: missingGoalSummaries.count,
            openCaptureCount: openCaptures.count,
            mode: mode
        )
        let resilience = makeExecutionResilience(
            posture: posture,
            weekDays: weekDays,
            missingGoalSummaries: missingGoalSummaries,
            pressuredGoalSummary: mostPressuredGoal,
            habitGoals: habitGoals,
            openCaptures: openCaptures
        )
        let primaryAction = makePrimaryAction(
            mode: mode,
            posture: posture,
            missingGoalSummary: missingGoalSummaries.first,
            pressuredGoalSummary: mostPressuredGoal,
            openCaptureCount: openCaptures.count,
            weekDays: weekDays
        )
        let capacityEnvelope = makeCapacityEnvelope(
            posture: posture,
            weekDays: weekDays,
            visibleBlockCount: weekContexts.count,
            protectedCount: weekContexts.filter { $0.blockKind == .protected || $0.blockKind == .fixed }.count,
            missingGoalCount: missingGoalSummaries.count,
            openCaptureCount: openCaptures.count,
            calendarAwareness: calendarAwareness
        )
        let lifecycleRail = makeGoalLifecycleRail(goals: snapshot.goals, summaries: activeGoalSummaries, evidenceByGoal: evidenceByGoal, now: now)
        let timelineStrip = makeTimelineStrip(
            goals: snapshot.goals,
            weekContexts: weekContexts,
            evidenceByGoal: evidenceByGoal,
            now: now
        )
        let opportunityWindows = makeOpportunityWindows(weekDays: weekDays, missingGoalSummaries: missingGoalSummaries)
        let decisionDebt = makeDecisionDebt(
            activeGoals: activeGoals,
            summaries: activeGoalSummaries,
            missingGoalSummaries: missingGoalSummaries,
            weekDays: weekDays,
            openCaptures: openCaptures,
            blockedDraftCount: blockedDrafts.count,
            clarificationDraftCount: clarificationDrafts.count,
            evidenceByGoal: evidenceByGoal,
            calendarAwareness: calendarAwareness
        )
        let conflictCourt = makeConflictCourt(
            activeGoals: activeGoals,
            summaries: activeGoalSummaries,
            weekDays: weekDays,
            openCaptures: openCaptures,
            evidenceByGoal: evidenceByGoal
        )
        let recoveryEntry = makeRecoveryEntry(
            weekDays: weekDays,
            missingGoalSummaries: missingGoalSummaries,
            openCaptures: openCaptures,
            pressuredGoalSummary: mostPressuredGoal
        )
        let calendarBoundary = makeCalendarBoundaryContract(calendarAwareness)
        let realityReflow = makeRealityReflow(
            mode: mode,
            activeGoals: activeGoals,
            summaries: activeGoalSummaries,
            missingGoalSummaries: missingGoalSummaries,
            weekDays: weekDays,
            openCaptures: openCaptures,
            blockedDraftCount: blockedDrafts.count,
            clarificationDraftCount: clarificationDrafts.count,
            evidenceByGoal: evidenceByGoal,
            calendarAwareness: calendarAwareness,
            pressuredGoalSummary: mostPressuredGoal
        )
        let recoveryGradient = makeRecoveryGradient(reflow: realityReflow, calendarAwareness: calendarAwareness)
        let saveTheDay = makeSaveTheDay(
            reflow: realityReflow,
            weekDays: weekDays,
            missingGoalSummaries: missingGoalSummaries,
            pressuredGoalSummary: mostPressuredGoal,
            openCaptures: openCaptures
        )
        let reflowReceiptPreview = makeReflowReceiptPreview(reflow: realityReflow, saveTheDay: saveTheDay)
        let reflowDecision = TimeReflowDecisionProjector().project(
            reflow: realityReflow,
            recoveryEntry: recoveryEntry,
            saveTheDay: saveTheDay,
            receiptPreview: reflowReceiptPreview
        )
        let recoveryMaturity = makeRecoveryMaturity(
            weekDays: weekDays,
            openCaptures: openCaptures,
            missingGoalSummaries: missingGoalSummaries,
            calendarAwareness: calendarAwareness,
            realityReflow: realityReflow,
            saveTheDay: saveTheDay,
            receiptPreview: reflowReceiptPreview
        )
        let pressureRecoveryReview = makePressureRecoveryReview(
            weekDays: weekDays,
            capacityEnvelope: capacityEnvelope,
            recoveryEntry: recoveryEntry,
            realityReflow: realityReflow,
            saveTheDay: saveTheDay,
            recoveryMaturity: recoveryMaturity
        )
        let treaty = makeTreaty(
            posture: posture,
            capacityEnvelope: capacityEnvelope,
            calendarBoundary: calendarBoundary,
            weekContexts: weekContexts,
            missingGoalCount: missingGoalSummaries.count,
            openCaptureCount: openCaptures.count,
            weekDays: weekDays,
            primaryAction: primaryAction
        )

        return TimeDashboard(
            mode: mode,
            timeframeLabel: timeframeLabel(now: now),
            hero: hero,
            lifeSuite: lifeSuite,
            primaryAction: primaryAction,
            treaty: treaty,
            capacityEnvelope: capacityEnvelope,
            pressureRecoveryReview: pressureRecoveryReview,
            lifecycleRail: lifecycleRail,
            timelineStrip: timelineStrip,
            opportunityWindows: opportunityWindows,
            decisionDebt: decisionDebt,
            conflictCourt: conflictCourt,
            calendarBoundary: calendarBoundary,
            recoveryEntry: recoveryEntry,
            realityReflow: realityReflow,
            reflowDecision: reflowDecision,
            recoveryGradient: recoveryGradient,
            saveTheDay: saveTheDay,
            reflowReceiptPreview: reflowReceiptPreview,
            recoveryMaturity: recoveryMaturity,
            pressureScrubber: pressureScrubber,
            weekDays: weekDays,
            believability: believability,
            calendarAwareness: calendarAwareness,
            resilience: resilience,
            goalShapingItems: goalShapingItems(summaries: activeGoalSummaries),
            shapingActions: makeShapingActions(
                summaries: activeGoalSummaries,
                missingGoalSummaries: missingGoalSummaries,
                pressuredGoalSummary: mostPressuredGoal,
                openCaptureCount: openCaptures.count,
                weekDays: weekDays
            ),
            secondaryDestinations: [
                TimeSecondaryDestination(
                    id: "time-habits",
                    title: "Rituals",
                    detail: habitGoals.isEmpty
                        ? "No repeatable loops are shaping the week yet."
                        : "Review the repeatable loops that can steady or crowd the week.",
                    valueLabel: "\(habitGoals.count)",
                    icon: AppTab.habits.systemImage,
                    visualState: habitGoals.isEmpty ? .default : .selected,
                    timeRoute: .habits
                ),
                TimeSecondaryDestination(
                    id: "time-capture",
                    title: "Capture into the week",
                    detail: openCaptures.isEmpty
                        ? "No open captures are pushing on the week right now."
                        : "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") still need to be absorbed, attached, or intentionally parked.",
                    valueLabel: "\(openCaptures.count)",
                    icon: AppTab.capture.systemImage,
                    visualState: openCaptures.isEmpty ? .default : .warning,
                    timeRoute: .captureInbox
                ),
                TimeSecondaryDestination(
                    id: "time-weekly-review",
                    title: "Weekly review",
                    detail: "Close the current week by shaping carry-forward, ritual pressure, and unresolved captures without leaving Time.",
                    valueLabel: posture.label,
                    icon: "arrow.triangle.branch",
                    visualState: posture.visualState,
                    timeRoute: .weeklyReview
                )
            ],
            emptyTitle: mode == .empty ? "No weekly pressure yet" : nil,
            emptyMessage: mode == .empty ? "As soon as goals, captures, or routines create real constraints, Time will show where the week still has room." : nil
        )
    }

    func makeWeeklyReviewDashboard(snapshot: Snapshot, now: Date) -> WeeklyReviewDashboard {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let openCaptures = snapshot.captures.filter { $0.status != .archived }
        let activeGoalSummaries = makeGoalSummaries(goals: activeGoals, feedback: snapshot.feedback, now: now)
        let missingGoalSummaries = activeGoalSummaries.filter { $0.contexts.isEmpty }
        let pressuredGoalSummary = pressuredGoalSummary(from: activeGoalSummaries)
        let habitGoals = activeGoals.filter { goal in
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || HabitGoalSemantics.isHabitLike(goal: goal, step: step)
        }
        let weekDays = makeWeekDays(
            summaries: activeGoalSummaries,
            missingGoalSummaries: missingGoalSummaries,
            now: now
        )
        let posture = postureState(
            evaluations: activeGoalSummaries.compactMap(\.evaluation),
            blockedCount: snapshot.drafts.filter { $0.latestResultKind == .blocked }.count,
            clarificationCount: snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count,
            openCaptureCount: openCaptures.count,
            weekDays: weekDays,
            mode: activeGoals.isEmpty && openCaptures.isEmpty ? .empty : .active
        )
        let carryForwardItems = makeWeeklyReviewCarryForwardItems(
            summaries: activeGoalSummaries,
            missingGoalSummaries: missingGoalSummaries,
            pressuredGoalSummary: pressuredGoalSummary,
            openCaptureCount: openCaptures.count
        )
        let splitPaneContext = makeWindowMagnetism(
            weekDays: weekDays,
            missingGoalSummaries: missingGoalSummaries,
            pressuredGoalSummary: pressuredGoalSummary
        )

        return WeeklyReviewDashboard(
            timeframeLabel: timeframeLabel(now: now),
            hero: WeeklyReviewHeroState(
                eyebrow: "Weekly Review",
                title: "Shape what carries forward",
                subtitle: "Weekly review now continues the same authored week workspace instead of becoming a detached ritual.",
                dominantTruth: posture.visualState == .warning
                    ? "The review should reduce strain first, then carry forward only the steps the next week can explain."
                    : "The review can keep what worked, leave room visible, and carry forward only the next believable steps.",
                continuityLabel: "Return to the week with a calmer shape, not a larger list.",
                contextPills: [
                    TimeHeroPillState(title: timeframeLabel(now: now), icon: "calendar", state: .default),
                    TimeHeroPillState(title: posture.label, icon: AppTab.plan.systemImage, state: posture.visualState),
                    TimeHeroPillState(title: "\(carryForwardItems.count) carry-forward lanes", icon: "arrow.triangle.branch", state: carryForwardItems.isEmpty ? .default : .selected)
                ]
            ),
            summaryTitle: "Why the next week should look different",
            summaryDetail: posture.visualState == .warning
                ? "Carryover, capture pressure, and overloaded days need gentler scope before the next week hardens."
                : "Keep the backbone that worked, then patch only the few things that still deserve a lane next week.",
            carryForwardItems: carryForwardItems,
            captureSummary: openCaptures.isEmpty
                ? "No open captures are demanding carry-forward attention."
                : "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") still need a calm decision before the next week starts.",
            habitSummary: habitGoals.isEmpty
                ? "No recurring loops are currently shaping the review."
                : "\(habitGoals.count) routine\(habitGoals.count == 1 ? "" : "s") should support the next week without crowding it.",
            returnActionTitle: "Return to Time",
            returnActionSubtitle: "Use the reshaped week, then adjust one goal or support route only if it still needs help.",
            returnTimeRoute: nil,
            splitPaneContext: splitPaneContext
        )
    }

    func makeGoalSummaries(goals: [Goal], feedback: [GoalFeedbackEvent], now: Date) -> [GoalWeekSummary] {
        goals.map { goal in
            let sections = goal.plan?.sections ?? []
            let steps = sections.flatMap(\.steps)
            let goalFeedback = feedback.filter { event in
                steps.contains(where: { $0.id == event.stepID })
            }
            let frictionCount = goalFeedback.filter(isFriction).count
            let contexts = weekStepContexts(goal: goal, frictionCount: frictionCount, now: now)
            return GoalWeekSummary(
                goal: goal,
                contexts: contexts,
                frictionCount: frictionCount,
                evaluation: goal.plan?.evaluation
            )
        }
    }

    func weekStepContexts(goal: Goal, frictionCount: Int, now: Date) -> [StepContext] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? now
        let evaluation = goal.plan?.evaluation

        return (goal.plan?.sections ?? [])
            .flatMap(\.steps)
            .compactMap { step -> StepContext? in
                guard step.state != .completed, step.state != .cancelled else { return nil }
                guard let date = plannedDate(for: step.timing) else { return nil }
                guard date >= start, date < end else { return nil }
                let dayIndex = calendar.dateComponents([.day], from: start, to: calendar.startOfDay(for: date)).day ?? 0
                guard (0..<7).contains(dayIndex) else { return nil }
                return StepContext(
                    goal: goal,
                    step: step,
                    date: date,
                    dayIndex: dayIndex,
                    timingLabel: timingLabel(for: step.timing),
                    blockKind: blockKind(for: step.timing),
                    visualState: blockVisualState(step: step, evaluation: evaluation, frictionCount: frictionCount),
                    frictionCount: frictionCount,
                    evaluation: evaluation
                )
            }
            .sorted { lhs, rhs in
                if lhs.dayIndex == rhs.dayIndex {
                    return lhs.date < rhs.date
                }
                return lhs.dayIndex < rhs.dayIndex
            }
    }

    func makeWeekDays(
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        now: Date
    ) -> [TimeElasticWeekDayState] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: now)
        let dayFormatter = DateFormatter()
        dayFormatter.locale = .current
        dayFormatter.setLocalizedDateFormatFromTemplate("EEE")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.setLocalizedDateFormatFromTemplate("d")

        let contextsByDay = Dictionary(grouping: summaries.flatMap(\.contexts), by: \.dayIndex)

        return (0..<7).map { dayIndex in
            let date = calendar.date(byAdding: .day, value: dayIndex, to: start) ?? start
            let contexts = (contextsByDay[dayIndex] ?? []).sorted { lhs, rhs in
                if lhs.visualState == rhs.visualState {
                    return lhs.date < rhs.date
                }
                return shapingRank(for: lhs.visualState) < shapingRank(for: rhs.visualState)
            }
            let load = contexts.reduce(0.0) { partial, context in
                partial + loadWeight(for: context.blockKind, visualState: context.visualState)
            }
            let remainingCapacity = 3.0 - load
            let level: TimeWeekPressureLevel = {
                if remainingCapacity < -0.3 || contexts.count >= 4 { return .overloaded }
                if remainingCapacity < 0.7 || contexts.count >= 3 { return .tight }
                if contexts.isEmpty || remainingCapacity > 1.7 { return .open }
                return .steady
            }()
            let suggestedSummary = missingGoalSummaries.first ?? summaries.first(where: {
                $0.contexts.contains(where: { $0.dayIndex == dayIndex }) == false && ($0.evaluation?.feasibilityLevel == .tight || $0.evaluation?.feasibilityLevel == .fragile)
            })
            let roomLabel = roomLabel(for: level, remainingCapacity: remainingCapacity, contextCount: contexts.count)
            let openWindow = makeOpenWindow(
                level: level,
                remainingCapacity: remainingCapacity,
                suggestedSummary: suggestedSummary,
                contextCount: contexts.count
            )
            let visibleBlocks = Array(contexts.prefix(level == .overloaded ? 4 : 3)).map { context in
                TimeWeekBlockState(
                    id: "\(context.goal.id)-\(context.step.id)",
                    target: GoalRouteTarget(goalID: context.goal.id),
                    title: context.step.title,
                    detail: context.step.summary ?? context.step.actionability.fallbackMicroStep,
                    goalLabel: context.goal.title,
                    timingLabel: context.timingLabel,
                    kind: context.blockKind,
                    visualState: context.visualState
                )
            }
            let highlight = dayHighlight(
                level: level,
                contexts: contexts,
                suggestedSummary: suggestedSummary
            )

            return TimeElasticWeekDayState(
                id: "day-\(dayIndex)",
                weekdayLabel: dayFormatter.string(from: date),
                dateLabel: dateFormatter.string(from: date),
                level: level,
                intensity: dayIntensity(for: level, blockCount: contexts.count),
                roomLabel: roomLabel,
                capacityLabel: contexts.isEmpty ? "No blocks yet" : "\(contexts.count) block\(contexts.count == 1 ? "" : "s")",
                highlight: highlight,
                blocks: visibleBlocks,
                overflowCount: max(contexts.count - visibleBlocks.count, 0),
                openWindow: openWindow
            )
        }
    }

    func makeOpenWindow(
        level: TimeWeekPressureLevel,
        remainingCapacity: Double,
        suggestedSummary: GoalWeekSummary?,
        contextCount: Int
    ) -> TimeOpenWindowState? {
        guard level != .overloaded || remainingCapacity > -0.1 else {
            return nil
        }

        if let suggestedSummary {
            return TimeOpenWindowState(
                title: level == .open ? "Open window" : "Usable room",
                detail: contextCount == 0
                    ? "This day can carry one believable step without turning calendar-dense."
                    : "There is still enough room to protect or patch one calmer step.",
                suggestionLabel: suggestedSummary.goal.title,
                target: GoalRouteTarget(goalID: suggestedSummary.goal.id),
                visualState: level == .open ? .success : .selected
            )
        }

        return TimeOpenWindowState(
            title: level == .open ? "Leave this open" : "Keep breathing room",
            detail: "Not every open pocket needs to be filled. Open room keeps the week doable.",
            suggestionLabel: nil,
            target: nil,
            visualState: .default
        )
    }

    func makePressureScrubber(days: [TimeElasticWeekDayState]) -> TimePressureScrubberState {
        let defaultDayID = days.max { lhs, rhs in
            if lhs.level == rhs.level {
                return lhs.intensity < rhs.intensity
            }
            return pressureRank(for: lhs.level) < pressureRank(for: rhs.level)
        }?.id ?? days.first?.id ?? "day-0"

        return TimePressureScrubberState(
            title: "Pressure scrubber",
            subtitle: "Scrub the week to inspect where pressure gathers, where room remains, and which day can take another believable step.",
            defaultDayID: defaultDayID,
            points: days.map { day in
                TimePressureScrubberPoint(
                    id: day.id,
                    weekdayLabel: day.weekdayLabel,
                    dateLabel: day.dateLabel,
                    level: day.level,
                    pressureValue: day.intensity,
                    roomLabel: day.roomLabel,
                    summary: day.highlight
                )
            }
        )
    }

    func makeBelievability(
        posture: TimeBelievabilityState,
        blockedCount: Int,
        clarificationCount: Int,
        openCaptureCount: Int,
        missingGoalCount: Int,
        activeGoalCount: Int
    ) -> TimeBelievabilityState {
        let supportLabel: String
        if blockedCount + clarificationCount > 0 {
            supportLabel = "Clarify \(blockedCount + clarificationCount) planning gap\(blockedCount + clarificationCount == 1 ? "" : "s") before widening the week."
        } else if openCaptureCount > 0 {
            supportLabel = "Open captures are the loudest outside pressure on the current week."
        } else if missingGoalCount > 0 {
            supportLabel = "\(missingGoalCount) active goal\(missingGoalCount == 1 ? "" : "s") still need believable room."
        } else if activeGoalCount == 0 {
            supportLabel = "The week is intentionally quiet because nothing real is asking it to carry work."
        } else {
            supportLabel = "The current shape is believable because active goals already have visible room."
        }

        return TimeBelievabilityState(
            title: posture.title,
            detail: posture.detail,
            label: posture.label,
            supportLabel: supportLabel,
            visualState: posture.visualState
        )
    }

    func makePressureRecoveryReview(
        weekDays: [TimeElasticWeekDayState],
        capacityEnvelope: TimeCapacityEnvelopeState,
        recoveryEntry: TimeRecoveryEntryState,
        realityReflow: TimeRealityReflowState,
        saveTheDay: TimeSaveTheDayState,
        recoveryMaturity: TimeRecoveryMaturityState
    ) -> TimePressureRecoveryReviewState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded || $0.level == .fragile }.count
        let tightDays = weekDays.filter { $0.level == .tight }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let protectedConflicts = weekDays.flatMap(\.blocks).filter { block in
            (block.kind == .fixed || block.kind == .protected) && block.visualState == .warning
        }
        let pressureVisible = overloadedDays > 0 || tightDays > 0 || protectedConflicts.isEmpty == false
        let visualState: AmbitionVisualState = pressureVisible ? .warning : .selected
        let dayNoun = overloadedDays == 1 ? "day" : "days"
        let openNoun = openDays == 1 ? "day" : "days"
        let conflictNoun = protectedConflicts.count == 1 ? "item" : "items"

        return TimePressureRecoveryReviewState(
            title: "Pressure and recovery review",
            detail: pressureVisible
                ? "Pressure gets explained before the week changes, then recovery stays smaller than the strain."
                : "The week still has readable room, so recovery can stay protective instead of becoming extra planning.",
            pressureFieldLabel: overloadedDays > 0
                ? "Pressure field: \(overloadedDays) \(dayNoun) should be lightened before new work lands."
                : "Pressure field: keep the current week shape readable before widening it.",
            recoveryLoopLabel: pressureVisible
                ? "Recovery loop: explain pressure, choose the smaller step, then preview the receipt."
                : "Recovery loop: preserve room and keep Still Counts available.",
            weekPressureLabel: overloadedDays > 0
                ? "\(overloadedDays) \(dayNoun) need relief before adding work."
                : tightDays > 0
                    ? "\(tightDays) tight day\(tightDays == 1 ? "" : "s") should stay visible before anything moves."
                    : "Pressure is readable and does not need a larger plan.",
            overloadedDayLabel: overloadedDays > 0
                ? "Overloaded day explanation: reduce one ask before adding another."
                : "Overloaded day explanation: no day is asking for relief right now.",
            recoverySpaceLabel: openDays > 0
                ? "Recovery space: \(openDays) open \(openNoun) can protect breathing room."
                : "Recovery space: make one smaller pocket before widening the week.",
            smallerStepAnchorLabel: overloadedDays > 0
                ? "Smaller step anchor: make the next ask lighter before protecting anything else."
                : "Smaller step anchor: keep one believable next move available.",
            protectedTimeConflictLabel: protectedConflicts.isEmpty
                ? "Protected time conflict: nothing protected is competing loudly."
                : "Protected time conflict: \(protectedConflicts.count) fixed or protected \(conflictNoun) need care before moving anything.",
            lateStartAdjustmentLabel: "Late-start adjustment: \(saveTheDay.adjustment) Start with the smaller version.",
            recoveryDayReviewLabel: "Recovery-day review: Still counts; protect what remains and make the next ask lighter.",
            recoveryReceiptPreviewLabel: "Recovery receipt preview: records what was lightened, what stayed protected, and what still counts before any plan change.",
            capacityReviewLabel: "Capacity review: \(capacityEnvelope.label.lowercased()) is qualitative, with no percentage or certainty claim.",
            signals: [
                TimePressureRecoverySignalState(
                    id: "week-pressure",
                    title: "Week pressure",
                    detail: realityReflow.reasonDetail,
                    statusLabel: capacityEnvelope.label,
                    boundaryLabel: "Explain before changing",
                    visualState: visualState
                ),
                TimePressureRecoverySignalState(
                    id: "recovery-space",
                    title: "Recovery space",
                    detail: recoveryEntry.detail,
                    statusLabel: openDays > 0 ? "Available" : "Make room",
                    boundaryLabel: "Reduce the ask",
                    visualState: openDays > 0 ? .success : .warning
                ),
                TimePressureRecoverySignalState(
                    id: "protected-time",
                    title: "Protected time",
                    detail: protectedConflicts.first?.detail ?? "Nothing protected needs to be moved automatically.",
                    statusLabel: protectedConflicts.isEmpty ? "Clear" : "Review",
                    boundaryLabel: "No silent rescheduling",
                    visualState: protectedConflicts.isEmpty ? .success : .warning
                ),
                TimePressureRecoverySignalState(
                    id: "recovery-boundary",
                    title: "Recovery boundary",
                    detail: recoveryMaturity.confirmationBoundary,
                    statusLabel: recoveryMaturity.planFitLabel,
                    boundaryLabel: "Confirm first",
                    visualState: recoveryMaturity.planFitLabel == "Needs relief" ? .warning : .selected
                )
            ],
            visualState: visualState
        )
    }

    func makeExecutionResilience(
        posture: TimeBelievabilityState,
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?,
        habitGoals: [Goal],
        openCaptures: [Capture]
    ) -> TimeExecutionResilienceState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let laneState: AmbitionVisualState = overloadedDays > 0 || missingGoalSummaries.isEmpty == false || openCaptures.isEmpty == false
            ? .warning
            : posture.visualState

        return TimeExecutionResilienceState(
            title: "Execution resilience",
            subtitle: "Carryover, overload, and recovery shaping stay explainable by keeping one smaller lane obvious at a time.",
            calmExplanation: missingGoalSummaries.isEmpty
                ? "This week holds together best when open room stays visible and only the loudest pressure gets reshaped."
                : "\(missingGoalSummaries.count) active goal\(missingGoalSummaries.count == 1 ? "" : "s") still need a believable carryover lane instead of diffuse pressure.",
            focusProtection: overloadedDays > 0
                ? "Protect the clearest focus window before moving anything else. Relief works better than adding another organizing layer."
                : "Focus windows already exist in the week. Protect them before turning rituals or captures into extra structure.",
            tradeoffFraming: openCaptures.isEmpty
                ? "Every new ask should either reuse visible room or trade off against the loudest loaded day."
                : "Open captures should compete with the week honestly. Absorb them, park them, or let them wait.",
            lanes: [
                TimeExecutionResilienceLane(
                    id: "carryover",
                    title: "Carryover",
                    detail: missingGoalSummaries.isEmpty
                        ? "No active goal is currently floating outside the week."
                        : "Resolve carryover by giving only the missing goal a believable lane instead of widening the whole week.",
                    recommendation: missingGoalSummaries.first.map { "\($0.goal.title) is the cleanest carry-forward candidate." } ?? "Carry only what the next week can explain calmly.",
                    state: missingGoalSummaries.isEmpty ? .success : .warning,
                    goalTarget: missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) },
                    timeRoute: nil
                ),
                TimeExecutionResilienceLane(
                    id: "overload",
                    title: "Overload",
                    detail: overloadedDays == 0
                        ? "No day is visibly overloaded right now."
                        : "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") are carrying more than the week can explain without relief.",
                    recommendation: pressuredGoalSummary.map { "Lighten \($0.goal.title) before adding anything new." } ?? "Lighten the loudest lane first.",
                    state: overloadedDays == 0 ? .selected : .warning,
                    goalTarget: pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) },
                    timeRoute: nil
                ),
                TimeExecutionResilienceLane(
                    id: "habits",
                    title: "Rituals",
                    detail: habitGoals.isEmpty
                        ? "No recurring loop is currently shaping the week."
                        : "\(habitGoals.count) routine\(habitGoals.count == 1 ? "" : "s") should support the week shape instead of competing with it.",
                    recommendation: habitGoals.isEmpty
                        ? "Keep the week dominant until a repeatable loop is truly needed."
                        : "Use the routines route to soften or trim loops that are crowding the week.",
                    state: habitGoals.isEmpty ? .default : .selected,
                    goalTarget: nil,
                    timeRoute: .habits
                ),
                TimeExecutionResilienceLane(
                    id: "captures",
                    title: "Capture",
                    detail: openCaptures.isEmpty
                        ? "No open captures are pushing on this week."
                        : "\(openCaptures.count) open capture\(openCaptures.count == 1 ? "" : "s") still need to be absorbed or parked.",
                    recommendation: openCaptures.isEmpty
                        ? "Let the week stay quiet."
                        : "Attach or park capture pressure before trying to polish the schedule.",
                    state: openCaptures.isEmpty ? .default : .warning,
                    goalTarget: nil,
                    timeRoute: .captureInbox
                ),
                TimeExecutionResilienceLane(
                    id: "review",
                    title: "Weekly review",
                    detail: "Use review as a shaping continuation so next week inherits the right amount of carry-forward truth.",
                    recommendation: "Close the week by shaping what should continue, not by creating more admin.",
                    state: laneState,
                    goalTarget: nil,
                    timeRoute: .weeklyReview
                )
            ],
            windowMagnetism: makeWindowMagnetism(
                weekDays: weekDays,
                missingGoalSummaries: missingGoalSummaries,
                pressuredGoalSummary: pressuredGoalSummary
            )
        )
    }

    func makeWindowMagnetism(
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?
    ) -> TimeWindowMagnetismState? {
        guard let candidateDay = weekDays.first(where: { $0.level == .open && $0.openWindow?.target != nil }) ??
                weekDays.first(where: { $0.level == .steady && $0.openWindow?.target != nil }),
              let openWindow = candidateDay.openWindow else {
            return nil
        }

        let suggestedGoalTitle = openWindow.suggestionLabel ?? missingGoalSummaries.first?.goal.title ?? pressuredGoalSummary?.goal.title ?? "the next lighter step"

        return TimeWindowMagnetismState(
            title: "Window magnetism",
            detail: "When the week has one believable opening, suggestions should dock there calmly instead of making the whole schedule feel reactive.",
            dayLabel: "\(candidateDay.weekdayLabel) \(candidateDay.dateLabel)",
            suggestionTitle: suggestedGoalTitle,
            suggestionDetail: openWindow.detail,
            target: openWindow.target,
            visualState: openWindow.visualState
        )
    }

    func makeWeeklyReviewCarryForwardItems(
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?,
        openCaptureCount: Int
    ) -> [WeeklyReviewCarryForwardItem] {
        let carryoverItems = missingGoalSummaries.prefix(2).map { summary in
            WeeklyReviewCarryForwardItem(
                id: "weekly-review-carry-\(summary.goal.id)",
                title: summary.goal.title,
                detail: "Still active, but the current week never gave it a believable lane.",
                bridgeLabel: "Carry forward carefully",
                state: .warning,
                goalTarget: GoalRouteTarget(goalID: summary.goal.id)
            )
        }
        let strainedItem = pressuredGoalSummary.map { summary in
            WeeklyReviewCarryForwardItem(
                id: "weekly-review-strain-\(summary.goal.id)",
                title: summary.goal.title,
                detail: "The next week should carry a lighter version so recovery stays believable.",
                bridgeLabel: "Lighten before it rolls forward",
                state: .selected,
                goalTarget: GoalRouteTarget(goalID: summary.goal.id)
            )
        }
        let captureItem: WeeklyReviewCarryForwardItem? = openCaptureCount > 0 ? WeeklyReviewCarryForwardItem(
            id: "weekly-review-captures",
            title: "Capture pressure",
            detail: "\(openCaptureCount) capture\(openCaptureCount == 1 ? "" : "s") still need a decision before they become next-week clutter.",
            bridgeLabel: "Clear the inbox inside Plan",
            state: .warning,
            goalTarget: nil
        ) : nil

        return Array((carryoverItems + [strainedItem, captureItem].compactMap { $0 }).prefix(4))
    }

    func makeHero(
        posture: TimeBelievabilityState,
        timeframeLabel: String,
        representedGoalCount: Int,
        activeGoalCount: Int,
        weekDays: [TimeElasticWeekDayState],
        missingGoalCount: Int,
        openCaptureCount: Int,
        mode: TimeDashboardMode
    ) -> TimeRealityHeroState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let tightDays = weekDays.filter { $0.level == .tight }.count
        let dominantTruth: String = {
            guard mode == .active else { return "The week is mostly empty, which is useful information." }
            if overloadedDays > 0 {
                return "Pressure is clustering into \(overloadedDays) overloaded day\(overloadedDays == 1 ? "" : "s")."
            }
            if missingGoalCount > 0 {
                return "\(missingGoalCount) active goal\(missingGoalCount == 1 ? "" : "s") still need believable room in the week."
            }
            if tightDays > 0 {
                return "The week basically holds, but pressure is already visible on \(tightDays) day\(tightDays == 1 ? "" : "s")."
            }
            return "The current week is holding together without calendar-noise density."
        }()

        let roomSummary: String = {
            if openDays == 0 { return "Room is scarce, so every new ask needs a tradeoff." }
            if openDays <= 2 { return "Only a little open room remains; protect it deliberately." }
            return "\(openDays) day\(openDays == 1 ? "" : "s") still carry visible room for a believable step."
        }()

        let pressureSummary: String = {
            if openCaptureCount > 0 {
                return "Outside pressure is mostly coming from captures that have not yet been attached or discarded."
            }
            return posture.supportLabel
        }()

        return TimeRealityHeroState(
            eyebrow: "Time",
            title: "Shape Time",
            subtitle: "Time reads the week as open room, goal time, pressure, and protected structure.",
            dominantTruth: dominantTruth,
            roomSummary: roomSummary,
            pressureSummary: pressureSummary,
            contextPills: [
                TimeHeroPillState(title: timeframeLabel, icon: "calendar", state: .default),
                TimeHeroPillState(title: posture.label, icon: AppTab.plan.systemImage, state: posture.visualState),
                TimeHeroPillState(title: "\(representedGoalCount)/\(max(activeGoalCount, 1)) goals visible", icon: "target", state: representedGoalCount == activeGoalCount && activeGoalCount > 0 ? .success : .selected)
            ],
            trustWhisper: posture.supportLabel
        )
    }

    func makePrimaryAction(
        mode: TimeDashboardMode,
        posture: TimeBelievabilityState,
        missingGoalSummary: GoalWeekSummary?,
        pressuredGoalSummary: GoalWeekSummary?,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState]
    ) -> TimeWeekPrimaryAction {
        if mode == .empty {
            return TimeWeekPrimaryAction(
                kind: .useRoom,
                title: "Use this room",
                subtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
                systemImage: "sparkles",
                state: .success,
                goalTarget: nil,
                timeRoute: nil
            )
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            return TimeWeekPrimaryAction(
                kind: .lightenWeek,
                title: "Lighten week",
                subtitle: openCaptureCount > 0
                    ? "Reduce outside pressure first so the week stops carrying speculative load."
                    : "One day is carrying too much. Lighten the loudest lane before adding more.",
                systemImage: "sun.max",
                state: .warning,
                goalTarget: openCaptureCount > 0 ? nil : pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) },
                timeRoute: openCaptureCount > 0 ? .captureInbox : nil
            )
        }

        if let missingGoalSummary, weekDays.contains(where: { $0.level == .open }) {
            return TimeWeekPrimaryAction(
                kind: .useRoom,
                title: "Use this room",
                subtitle: "There is believable room for one calmer step on \(missingGoalSummary.goal.title).",
                systemImage: "arrow.down.left.and.arrow.up.right",
                state: .success,
                goalTarget: GoalRouteTarget(goalID: missingGoalSummary.goal.id),
                timeRoute: nil
            )
        }

        if let missingGoalSummary {
            return TimeWeekPrimaryAction(
                kind: .resolveCarryover,
                title: "Resolve carryover",
                subtitle: "\(missingGoalSummary.goal.title) is active but still not represented in the week.",
                systemImage: "arrow.triangle.branch",
                state: .selected,
                goalTarget: GoalRouteTarget(goalID: missingGoalSummary.goal.id),
                timeRoute: nil
            )
        }

        return TimeWeekPrimaryAction(
            kind: .shapeWeek,
            title: "Shape this week",
            subtitle: posture.supportLabel,
            systemImage: "wand.and.stars",
            state: posture.visualState == .warning ? .selected : posture.visualState,
            goalTarget: pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) } ?? weekDays.flatMap(\.blocks).first?.target,
            timeRoute: nil
        )
    }

    func makeShapingActions(
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState]
    ) -> [TimeShapingActionState] {
        let firstVisibleBlock = weekDays.flatMap(\.blocks).first
        let firstOpenWindow = weekDays.compactMap(\.openWindow).first(where: { $0.target != nil })
        let noisyDay = weekDays.first(where: { $0.level == .overloaded }) ?? weekDays.first(where: { $0.level == .tight })
        let missingGoalTarget = missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) }
        let pressuredTarget = pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) }

        return [
            TimeShapingActionState(
                kind: .edit,
                title: "Edit",
                subtitle: firstVisibleBlock?.title ?? "Edit the week at the block level.",
                recommendation: firstVisibleBlock == nil
                    ? "No dated block is visible yet, so there is nothing to edit directly."
                    : "Start with the clearest existing block instead of redrawing the whole week.",
                systemImage: TimeShapingActionKind.edit.systemImage,
                state: firstVisibleBlock == nil ? .default : .selected,
                goalTarget: firstVisibleBlock?.target,
                timeRoute: nil
            ),
            TimeShapingActionState(
                kind: .patch,
                title: "Patch",
                subtitle: missingGoalSummaries.isEmpty
                    ? "Patch the week without changing its calm shape."
                    : "Give missing goals one believable lane instead of spreading them everywhere.",
                recommendation: missingGoalSummaries.isEmpty
                    ? "Use the cleanest open window or the weakest day and make one small adjustment."
                    : "Patch missing work into the week only where room is actually visible.",
                systemImage: TimeShapingActionKind.patch.systemImage,
                state: missingGoalSummaries.isEmpty ? .selected : .warning,
                goalTarget: missingGoalTarget ?? firstOpenWindow?.target,
                timeRoute: nil
            ),
            TimeShapingActionState(
                kind: .protect,
                title: "Protect",
                subtitle: firstOpenWindow?.title ?? "Protect the parts of the week that already feel believable.",
                recommendation: firstOpenWindow?.suggestionLabel == nil
                    ? "The best protection may be leaving one pocket unfilled."
                    : "Protect the calmest pocket before pressure spills into it.",
                systemImage: TimeShapingActionKind.protect.systemImage,
                state: firstOpenWindow == nil ? .default : .success,
                goalTarget: firstOpenWindow?.target ?? firstVisibleBlock?.target ?? pressuredTarget,
                timeRoute: nil
            ),
            TimeShapingActionState(
                kind: .lighten,
                title: "Lighten",
                subtitle: noisyDay?.highlight ?? "Lighten the loudest part of the week first.",
                recommendation: openCaptureCount > 0
                    ? "Reduce speculative load before trying to force more commitment into the week."
                    : "Shrink or reschedule the heaviest ask before the week starts feeling performative.",
                systemImage: TimeShapingActionKind.lighten.systemImage,
                state: noisyDay == nil ? .default : .warning,
                goalTarget: openCaptureCount > 0 ? nil : pressuredTarget,
                timeRoute: openCaptureCount > 0 ? .captureInbox : nil
            )
        ]
    }

    func makeTreaty(
        posture: TimeBelievabilityState,
        capacityEnvelope: TimeCapacityEnvelopeState,
        calendarBoundary: TimeCalendarBoundaryContractState,
        weekContexts: [StepContext],
        missingGoalCount: Int,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState],
        primaryAction: TimeWeekPrimaryAction
    ) -> TimeTreatyState {
        let protectedCount = weekContexts.filter { $0.blockKind == .protected || $0.blockKind == .fixed }.count
        let flexibleCount = weekContexts.filter { $0.blockKind == .flexible }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let overloadedDays = weekDays.filter { $0.level == .overloaded || $0.level == .fragile }.count

        return TimeTreatyState(
            title: "This week's agreement",
            summary: posture.visualState == .warning
                ? "This plan can still be kind, but it needs one honest adjustment before more work is added."
                : "This plan is a calm agreement between protected work, flexible work, and room you are allowed to keep.",
            protectedWork: protectedCount == 0
                ? "Nothing is marked as protected yet."
                : "\(protectedCount) protected or fixed item\(protectedCount == 1 ? "" : "s") should stay defended.",
            flexibleWork: flexibleCount == 0
                ? "No flexible work is asking for placement right now."
                : "\(flexibleCount) flexible item\(flexibleCount == 1 ? "" : "s") can bend around real life.",
            notTodayWork: missingGoalCount + openCaptureCount == 0
                ? "Nothing obvious needs to be kept outside today."
                : "\(missingGoalCount + openCaptureCount) item\(missingGoalCount + openCaptureCount == 1 ? "" : "s") should wait, clarify, or stay outside today's pressure.",
            recoveryAllowance: overloadedDays == 0 && openDays > 0
                ? "\(openDays) open day\(openDays == 1 ? "" : "s") keep recovery room visible."
                : "Recovery room is thin; adjust one thing, not everything.",
            calendarBoundary: calendarBoundary.manualFallback,
            primaryActionTitle: primaryAction.title,
            primaryActionSubtitle: primaryAction.subtitle,
            visualState: capacityEnvelope.visualState
        )
    }

    func makeCapacityEnvelope(
        posture: TimeBelievabilityState,
        weekDays: [TimeElasticWeekDayState],
        visibleBlockCount: Int,
        protectedCount: Int,
        missingGoalCount: Int,
        openCaptureCount: Int,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeCapacityEnvelopeState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let tightDays = weekDays.filter { $0.level == .tight }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let fragile = posture.label == "Fragile" || missingGoalCount >= 2
        let level: (String, AmbitionVisualState)

        if overloadedDays > 0 || visibleBlockCount >= 12 {
            level = ("Overloaded", .warning)
        } else if fragile {
            level = ("Fragile", .warning)
        } else if tightDays >= 2 || openCaptureCount >= 3 {
            level = ("Tight", .warning)
        } else if visibleBlockCount >= 4 || protectedCount > 0 {
            level = ("Steady", .selected)
        } else {
            level = ("Light", .success)
        }

        let calendarCopy = calendarAwareness.status == .calendarAware
            ? "Calendar-derived busy time is informing open windows locally."
            : "Manual availability is enough to keep shaping this plan."

        return TimeCapacityEnvelopeState(
            title: "Capacity envelope",
            detail: "\(calendarCopy) The envelope stays qualitative so it does not pretend to know more than the data shows.",
            label: level.0,
            availableCapacity: openDays == 0 ? "No obvious open day" : "\(openDays) open day\(openDays == 1 ? "" : "s")",
            pressure: overloadedDays > 0 ? "Pressure is stacked" : tightDays > 0 ? "Pressure is visible" : "Pressure is readable",
            protectedFocus: protectedCount == 0 ? "Focus time is not explicit yet" : "\(protectedCount) important item\(protectedCount == 1 ? "" : "s")",
            recoveryMargin: openDays >= 2 ? "Recovery room exists" : openDays == 1 ? "Recovery room is narrow" : "Recovery room needs protection",
            visualState: level.1
        )
    }

    func makeGoalLifecycleRail(
        goals: [Goal],
        summaries: [GoalWeekSummary],
        evidenceByGoal: [String: [ProgressEvidence]],
        now: Date
    ) -> TimeGoalLifecycleRailState {
        let states = goals.map { goalLifecycleState(goal: $0, evidence: evidenceByGoal[$0.id] ?? [], now: now) }
        let representedGoalIDs = Set(summaries.filter { $0.contexts.isEmpty == false }.map(\.goal.id))
        let sequence: [GoalPortfolioLifecycleState] = [.previous, .active, .future, .waiting, .blocked, .parked, .protected, .completed, .cancelledDropped]
        let segments = sequence.map { state in
            let count: Int
            if state == .active {
                count = states.filter { $0 == .active }.count + representedGoalIDs.count
            } else {
                count = states.filter { $0 == state }.count
            }
            return TimeGoalLifecycleRailSegment(
                lifecycleState: state,
                count: count,
                subtitle: lifecycleSubtitle(for: state, count: count)
            )
        }

        return TimeGoalLifecycleRailState(
            title: "What this plan is carrying",
            subtitle: "Goals stay visible by lifecycle, including work that belongs outside this week's pressure.",
            segments: segments
        )
    }

    func makeTimelineStrip(
        goals: [Goal],
        weekContexts: [StepContext],
        evidenceByGoal: [String: [ProgressEvidence]],
        now: Date
    ) -> TimeTimelineStripState {
        let activeItems = weekContexts.prefix(5).map { context in
            TimeTimelineItemState(
                id: "timeline-\(context.goal.id)-\(context.step.id)",
                title: context.goal.title,
                detail: context.step.title,
                timingLabel: context.timingLabel,
                sourceLabel: "Based on your plan",
                kind: .active,
                visualState: context.visualState,
                target: GoalRouteTarget(goalID: context.goal.id)
            )
        }
        let previousItems = goals
            .filter { goalLifecycleState(goal: $0, evidence: evidenceByGoal[$0.id] ?? [], now: now) == .previous || $0.state == .completed }
            .prefix(2)
            .map { goal in
                TimeTimelineItemState(
                    id: "timeline-previous-\(goal.id)",
                    title: goal.title,
                    detail: "Kept outside current pressure.",
                    timingLabel: "Previous",
                    sourceLabel: "Created in Ambitions",
                    kind: .previous,
                    visualState: goal.state == .completed ? .success : .default,
                    target: GoalRouteTarget(goalID: goal.id)
                )
            }
        let futureItems = goals
            .filter { goalLifecycleState(goal: $0, evidence: evidenceByGoal[$0.id] ?? [], now: now) == .future }
            .prefix(2)
            .map { goal in
                TimeTimelineItemState(
                    id: "timeline-future-\(goal.id)",
                    title: goal.title,
                    detail: "Planned later, not part of this week's load.",
                    timingLabel: futureTimingLabel(for: goal, now: now),
                    sourceLabel: "Based on your plan",
                    kind: .future,
                    visualState: .default,
                    target: GoalRouteTarget(goalID: goal.id)
                )
            }
        let outsideItems = goals
            .filter { [.paused, .archived].contains($0.state) }
            .prefix(2)
            .map { goal in
                TimeTimelineItemState(
                    id: "timeline-outside-\(goal.id)",
                    title: goal.title,
                    detail: goal.state == .paused ? "Parked outside current pressure." : "Closed or dropped outside this plan.",
                    timingLabel: goal.state == .paused ? "Parked" : "Outside",
                    sourceLabel: "Created in Ambitions",
                    kind: .outside,
                    visualState: .default,
                    target: GoalRouteTarget(goalID: goal.id)
                )
            }
        let items = Array((previousItems + activeItems + futureItems + outsideItems).prefix(8))

        return TimeTimelineStripState(
            title: "Rich Timeline",
            subtitle: items.isEmpty
                ? "No goal movement is visible yet."
                : "A compact strip of previous, active, future, and outside pressure with local source labels.",
            items: items
        )
    }

    func makeOpportunityWindows(
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary]
    ) -> TimeOpportunityWindowsState {
        let windows = weekDays.compactMap { day -> TimeOpportunityWindowItem? in
            guard let window = day.openWindow else { return nil }
            let modeLabel: String
            let title: String
            switch day.level {
            case .open:
                modeLabel = window.target == nil ? "Recovery" : "Focus"
                title = window.target == nil ? "Recovery window" : "Good window for one focused step"
            case .steady:
                modeLabel = "Follow-up"
                title = "Good for follow-up"
            case .tight:
                modeLabel = "Admin"
                title = "Better for admin"
            case .fragile, .overloaded:
                return nil
            }
            return TimeOpportunityWindowItem(
                id: "window-\(day.id)",
                title: title,
                detail: window.detail,
                modeLabel: modeLabel,
                timingLabel: "\(day.weekdayLabel) \(day.dateLabel)",
                visualState: window.visualState,
                target: window.target
            )
        }

        let fallback: [TimeOpportunityWindowItem] = windows.isEmpty ? [
            TimeOpportunityWindowItem(
                id: "window-manual",
                title: missingGoalSummaries.isEmpty ? "Keep this light" : "Manual window needed",
                detail: missingGoalSummaries.isEmpty ? "No believable window is asking to be filled." : "Choose one small pocket manually before adding this goal to the week.",
                modeLabel: missingGoalSummaries.isEmpty ? "Recovery" : "Focus",
                timingLabel: "Manual",
                visualState: missingGoalSummaries.isEmpty ? .default : .warning,
                target: missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) }
            )
        ] : []

        return TimeOpportunityWindowsState(
            title: "Opportunity windows",
            subtitle: "Windows are work modes, not a calendar grid.",
            windows: Array((windows + fallback).prefix(4))
        )
    }

    func makeDecisionDebt(
        activeGoals: [Goal],
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        blockedDraftCount: Int,
        clarificationDraftCount: Int,
        evidenceByGoal: [String: [ProgressEvidence]],
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeDecisionDebtState {
        var items: [TimeDecisionItemState] = []

        items += missingGoalSummaries.prefix(2).map { summary in
            TimeDecisionItemState(
                id: "decision-next-step-\(summary.goal.id)",
                title: "Needs a decision",
                detail: "\(summary.goal.title) is active but not represented in this plan window.",
                suggestion: "Give it one next step, park it, or leave it intentionally outside today.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: summary.goal.id),
                timeRoute: nil
            )
        }

        if activeGoals.count > 5 {
            items.append(TimeDecisionItemState(
                id: "decision-active-goals",
                title: "Too many active goals",
                detail: "\(activeGoals.count) active goals are competing for the same planning window.",
                suggestion: "Protect the few that matter now and park the rest.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        if openCaptures.contains(where: { $0.status == .waiting || $0.status == .delegated }) {
            items.append(TimeDecisionItemState(
                id: "decision-waiting-captures",
                title: "Waiting item needs follow-up",
                detail: "A waiting or delegated capture is still influencing the week.",
                suggestion: "Follow up, attach it, or keep it outside the plan.",
                visualState: .warning,
                target: nil,
                timeRoute: .captureInbox
            ))
        }

        if blockedDraftCount + clarificationDraftCount > 0 {
            items.append(TimeDecisionItemState(
                id: "decision-clarify-drafts",
                title: "Clarify before planning more",
                detail: "\(blockedDraftCount + clarificationDraftCount) draft\(blockedDraftCount + clarificationDraftCount == 1 ? "" : "s") need an answer before they become real plan pressure.",
                suggestion: "Resolve the smallest missing answer first.",
                visualState: .warning,
                target: nil,
                timeRoute: .captureInbox
            ))
        }

        if let noProof = summaries.first(where: { evidenceByGoal[$0.goal.id, default: []].isEmpty && $0.contexts.isEmpty == false }) {
            items.append(TimeDecisionItemState(
                id: "decision-proof-\(noProof.goal.id)",
                title: "Proof is thin",
                detail: "\(noProof.goal.title) has work in the plan but no proof recorded yet.",
                suggestion: "Keep the next step small enough to leave evidence.",
                visualState: .default,
                target: GoalRouteTarget(goalID: noProof.goal.id),
                timeRoute: nil
            ))
        }

        if calendarAwareness.canRequestCalendarRead && calendarAwareness.status != .calendarAware {
            items.append(TimeDecisionItemState(
                id: "decision-calendar-boundary",
                title: "Calendar boundary is optional",
                detail: "Manual planning still works; calendar-derived windows require your action.",
                suggestion: "Use manual availability or ask Plan to find local open windows.",
                visualState: .default,
                target: nil,
                timeRoute: nil
            ))
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            items.append(TimeDecisionItemState(
                id: "decision-overloaded-week",
                title: "Clarify overloaded week",
                detail: "At least one day is carrying too much to stay believable.",
                suggestion: "Adjust one thing, not everything.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        return TimeDecisionDebtState(
            title: "Needs a decision",
            subtitle: items.isEmpty ? "No unresolved planning decision is loud right now." : "Small decisions prevent the plan from becoming a dense task manager.",
            items: Array(items.prefix(5))
        )
    }

    func makeConflictCourt(
        activeGoals: [Goal],
        summaries: [GoalWeekSummary],
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        evidenceByGoal: [String: [ProgressEvidence]]
    ) -> TimeConflictCourtState {
        var conflicts: [TimeDecisionItemState] = []
        let protectedSummaries = summaries.filter { summary in
            summary.contexts.contains(where: { $0.blockKind == .protected || $0.blockKind == .fixed })
        }

        if protectedSummaries.count >= 2,
           let first = protectedSummaries.first {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-protected-goals",
                title: "Important goals are competing",
                detail: "\(protectedSummaries.count) important goals are asking the same week to hold them.",
                suggestion: "Choose the one that must stay protected and let the other flex.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: first.goal.id),
                timeRoute: nil
            ))
        }

        if let blocked = summaries.first(where: { $0.contexts.contains(where: { $0.step.state == .blocked }) }) {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-blocked-\(blocked.goal.id)",
                title: "Blocked goal is still active",
                detail: "\(blocked.goal.title) has blocked work inside the current plan.",
                suggestion: "Treat this as waiting or unblock it before protecting more time.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: blocked.goal.id),
                timeRoute: nil
            ))
        }

        if activeGoals.count > 5 {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-active-count",
                title: "Active goals are crowded",
                detail: "\(activeGoals.count) active goals make the week negotiate too many directions.",
                suggestion: "Protect fewer goals so the plan remains believable.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        if openCaptures.contains(where: { $0.status == .waiting || $0.status == .delegated }) && summaries.isEmpty == false {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-commitment-goal",
                title: "Follow-up is competing with goal work",
                detail: "A waiting commitment and current goal work both want attention.",
                suggestion: "Follow up first if it unlocks the step; otherwise keep it outside today.",
                visualState: .warning,
                target: nil,
                timeRoute: .captureInbox
            ))
        }

        if let thinProof = summaries.first(where: { evidenceByGoal[$0.goal.id, default: []].isEmpty && $0.contexts.count >= 2 }) {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-proof-\(thinProof.goal.id)",
                title: "Work is moving without proof",
                detail: "\(thinProof.goal.title) has multiple plan blocks but no proof yet.",
                suggestion: "Make the next step receipt-friendly.",
                visualState: .default,
                target: GoalRouteTarget(goalID: thinProof.goal.id),
                timeRoute: nil
            ))
        }

        if weekDays.filter({ $0.level == .open }).isEmpty && summaries.isEmpty == false {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-recovery-margin",
                title: "No recovery margin",
                detail: "The plan is using every visible day.",
                suggestion: "Protect one pocket as recovery room.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        return TimeConflictCourtState(
            title: "Conflicts to negotiate",
            subtitle: conflicts.isEmpty ? "No visible conflict needs court right now." : "These are negotiation items, not alarms.",
            conflicts: Array(conflicts.prefix(4))
        )
    }

    func makeCalendarBoundaryContract(_ calendarAwareness: TimeCalendarAwarenessState) -> TimeCalendarBoundaryContractState {
        TimeCalendarBoundaryContractState(
            title: "Calendar stays optional",
            detail: calendarAwareness.detail,
            permissionLabel: calendarAwareness.valueLabel,
            sourceLabel: calendarAwareness.sourceLabel,
            manualFallback: calendarAwareness.status == .calendarAware
                ? "Plan can use derived busy time after your action."
                : "Manual planning still works without calendar access.",
            writeBoundary: "Plan never silently writes or reschedules calendar blocks.",
            visualState: calendarAwareness.visualState,
            canRequestCalendarRead: calendarAwareness.canRequestCalendarRead
        )
    }

    func makeRecoveryEntry(
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        openCaptures: [Capture],
        pressuredGoalSummary: GoalWeekSummary?
    ) -> TimeRecoveryEntryState {
        let overloaded = weekDays.contains(where: { $0.level == .overloaded || $0.level == .fragile })
        var suggestions: [TimeDecisionItemState] = []

        if overloaded, let pressuredGoalSummary {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-shrink-\(pressuredGoalSummary.goal.id)",
                title: "Shrink one step",
                detail: "\(pressuredGoalSummary.goal.title) is the clearest place to reduce pressure.",
                suggestion: "Make the next step smaller before moving anything else.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: pressuredGoalSummary.goal.id),
                timeRoute: nil
            ))
        }

        if let missing = missingGoalSummaries.first {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-defer-\(missing.goal.id)",
                title: "Defer what has no room",
                detail: "\(missing.goal.title) is active but outside the current week.",
                suggestion: "Leave it not today unless a real open window appears.",
                visualState: .default,
                target: GoalRouteTarget(goalID: missing.goal.id),
                timeRoute: nil
            ))
        }

        if openCaptures.isEmpty == false {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-captures",
                title: "Park capture pressure",
                detail: "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") can wait outside the plan.",
                suggestion: "Attach, park, or archive only after reviewing the inbox.",
                visualState: .warning,
                target: nil,
                timeRoute: .captureInbox
            ))
        }

        if suggestions.isEmpty {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-protect-room",
                title: "Protect recovery room",
                detail: "The safest choice is keeping an open pocket unfilled.",
                suggestion: "Recovery room is part of the plan, not a failure to optimize.",
                visualState: .success,
                target: nil,
                timeRoute: nil
            ))
        }

        return TimeRecoveryEntryState(
            title: "Recovery room",
            detail: "Save the Day stays suggestion-only here. Broad reflow waits for confirmed recovery tools.",
            suggestions: Array(suggestions.prefix(3)),
            boundary: "No schedule changes happen from this card."
        )
    }

    func makeRealityReflow(
        mode: TimeDashboardMode,
        activeGoals: [Goal],
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        blockedDraftCount: Int,
        clarificationDraftCount: Int,
        evidenceByGoal: [String: [ProgressEvidence]],
        calendarAwareness: TimeCalendarAwarenessState,
        pressuredGoalSummary: GoalWeekSummary?
    ) -> TimeRealityReflowState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let fragileDays = weekDays.filter { $0.level == .fragile }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let blockedSummary = summaries.first { summary in
            summary.contexts.contains(where: { $0.step.state == .blocked })
        }
        let waitingCaptureExists = openCaptures.contains { $0.status == .waiting || $0.status == .delegated }
        let proofMissingSummary = summaries.first { summary in
            summary.contexts.count >= 2 && evidenceByGoal[summary.goal.id, default: []].isEmpty
        }

        let reasonKind: TimeRealityBreakReasonKind
        let reasonDetail: String
        let visualState: AmbitionVisualState

        if mode == .empty {
            reasonKind = .lowData
            reasonDetail = "There is not enough plan pressure to reflow yet."
            visualState = .default
        } else if overloadedDays > 0 {
            reasonKind = .overloadedPlan
            reasonDetail = "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") are carrying more than this plan can calmly explain."
            visualState = .warning
        } else if fragileDays > 0 {
            reasonKind = .lowCapacityFragileDay
            reasonDetail = "\(fragileDays) day\(fragileDays == 1 ? "" : "s") need recovery room before more work is added."
            visualState = .warning
        } else if openDays == 0 && summaries.isEmpty == false {
            reasonKind = .noRecoveryMargin
            reasonDetail = "The plan is using every visible day, so one pocket should stay protected."
            visualState = .warning
        } else if let blockedSummary {
            reasonKind = .blockedGoal
            reasonDetail = "\(blockedSummary.goal.title) is still active while a planned step is blocked."
            visualState = .warning
        } else if waitingCaptureExists {
            reasonKind = .waitingOnPersonOrResource
            reasonDetail = "A waiting item is still influencing the week and should not silently become more work."
            visualState = .warning
        } else if missingGoalSummaries.isEmpty == false {
            reasonKind = .noNextStep
            reasonDetail = "\(missingGoalSummaries.count) active goal\(missingGoalSummaries.count == 1 ? "" : "s") need one believable next step or an intentional park."
            visualState = .warning
        } else if calendarAwareness.status == .denied {
            reasonKind = .calendarUnavailableOrDenied
            reasonDetail = "Manual planning still works; calendar access is not required for recovery suggestions."
            visualState = .default
        } else if activeGoals.count > 5 {
            reasonKind = .tooManyActiveGoals
            reasonDetail = "\(activeGoals.count) active goals are asking this plan to defend too many directions."
            visualState = .warning
        } else if let proofMissingSummary {
            reasonKind = .proofMissing
            reasonDetail = "\(proofMissingSummary.goal.title) has plan work but no proof yet, so the next step should be receipt-ready."
            visualState = .default
        } else if openCaptures.isEmpty == false {
            reasonKind = .urgentOutsideItem
            reasonDetail = "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") should be absorbed, parked, or left outside the plan with confirmation."
            visualState = .warning
        } else {
            reasonKind = .stillBelievable
            reasonDetail = "No visible disruption needs a plan change right now."
            visualState = .success
        }

        let suggestions = makeReflowSuggestions(
            reasonKind: reasonKind,
            activeGoals: activeGoals,
            missingGoalSummaries: missingGoalSummaries,
            openCaptures: openCaptures,
            pressuredGoalSummary: pressuredGoalSummary,
            blockedSummary: blockedSummary,
            calendarAwareness: calendarAwareness
        )
        let recommendedAdjustment = suggestions.first?.title ?? "Keep plan unchanged"

        return TimeRealityReflowState(
            title: reasonKind == .stillBelievable ? "Plan is still believable" : "Reality changed",
            detail: reasonKind == .stillBelievable
                ? "Nothing changed yet, and no recovery action is needed."
                : "Adjust one thing, not everything. These are suggestions until you confirm a change.",
            reasonKind: reasonKind,
            reasonDetail: reasonDetail,
            recommendedAdjustment: recommendedAdjustment,
            noChangeCopy: "Nothing changed yet.",
            suggestions: suggestions,
            visualState: visualState
        )
    }

    func makeReflowSuggestions(
        reasonKind: TimeRealityBreakReasonKind,
        activeGoals: [Goal],
        missingGoalSummaries: [GoalWeekSummary],
        openCaptures: [Capture],
        pressuredGoalSummary: GoalWeekSummary?,
        blockedSummary: GoalWeekSummary?,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> [TimeReflowSuggestionState] {
        let targetGoal = pressuredGoalSummary?.goal ?? missingGoalSummaries.first?.goal ?? blockedSummary?.goal ?? activeGoals.first
        var suggestions: [TimeReflowSuggestionState] = []

        func append(
            _ kind: TimeReflowSuggestionKind,
            detail: String,
            impact: String,
            state: AmbitionVisualState,
            target: GoalRouteTarget? = targetGoal.map { GoalRouteTarget(goalID: $0.id) },
            timeRoute: TimeRouteTarget? = nil
        ) {
            suggestions.append(TimeReflowSuggestionState(
                id: "reflow-\(kind.rawValue)-\(suggestions.count)",
                kind: kind,
                title: kind.title,
                detail: detail,
                impactLabel: impact,
                boundary: reflowBoundary(for: kind, calendarAwareness: calendarAwareness),
                visualState: state,
                target: target,
                timeRoute: timeRoute
            ))
        }

        switch reasonKind {
        case .stillBelievable:
            append(.keepPlanUnchanged, detail: "The current plan still has a believable path.", impact: "No change", state: .success, target: nil)
        case .lowData:
            append(.keepPlanUnchanged, detail: "Create or choose one plan item before reflowing anything.", impact: "No plan mutation", state: .default, target: nil)
        case .blockedGoal:
            append(.markWaiting, detail: "Keep the blocked work visible as waiting instead of adding more pressure.", impact: "Waiting state only after confirmation", state: .warning)
            append(.protectOneItem, detail: "Protect the one unblocked step that still matters.", impact: "Protects one item", state: .selected)
        case .waitingOnPersonOrResource:
            append(.markWaiting, detail: "Treat the dependency as waiting and keep the rest of the plan calm.", impact: "Keeps follow-up explicit", state: .warning, target: nil, timeRoute: .captureInbox)
            append(.moveLocalActionLater, detail: "Reschedule only the local follow-up later if it is not the protected item.", impact: "Local suggestion only", state: .default, target: nil, timeRoute: .captureInbox)
        case .noNextStep:
            append(.protectOneItem, detail: "Choose one must-do and leave the rest outside today.", impact: "Protects one item", state: .selected)
            append(.parkGoal, detail: "Park the goal that has no believable next step yet.", impact: "Broad change needs confirmation", state: .warning)
        case .calendarUnavailableOrDenied:
            append(.protectOneItem, detail: "Pick the one item to protect manually.", impact: "Manual planning still works", state: .selected)
            append(.moveLocalActionLater, detail: "Reschedule a local action later while Calendar stays untouched.", impact: "Calendar untouched", state: .default)
        case .tooManyActiveGoals:
            append(.protectOneItem, detail: "Protect the one goal that must stay active now.", impact: "Narrows focus", state: .selected)
            append(.parkGoal, detail: "Park one active goal until it has real room.", impact: "Broad change needs confirmation", state: .warning)
        case .proofMissing:
            append(.shrinkAction, detail: "Make the next step small enough to leave proof.", impact: "Receipt-ready adjustment", state: .default)
            append(.splitAction, detail: "Split the work so the first part can close cleanly.", impact: "Local draft suggestion", state: .default)
        case .urgentOutsideItem:
            append(.deferGoalOrItem, detail: "Defer the item that does not belong in this plan window.", impact: "Needs confirmation", state: .warning, target: nil, timeRoute: openCaptures.isEmpty ? nil : .captureInbox)
            append(.dropOptionalWork, detail: "Drop optional work only after you confirm it is not needed.", impact: "Destructive choice gated", state: .warning, target: nil, timeRoute: openCaptures.isEmpty ? nil : .captureInbox)
        case .missedDay, .overloadedPlan, .noRecoveryMargin, .lowCapacityFragileDay:
            append(.protectOneItem, detail: "Keep one must-do defended before changing the rest.", impact: "Smallest useful adjustment", state: .selected)
            append(.shrinkAction, detail: targetGoal.map { "Make \($0.title)'s next step smaller." } ?? "Make the next step smaller.", impact: "Local suggestion only", state: .warning)
            append(.splitAction, detail: "Split the work so today carries only the first clear part.", impact: "Local draft suggestion", state: .default)
            append(.moveLocalActionLater, detail: "Reschedule one local action later without touching Calendar.", impact: "Needs confirmation before mutation", state: .default)
            append(.deferGoalOrItem, detail: "Defer the lower-priority item that no longer fits.", impact: "Broad change needs confirmation", state: .warning)
            append(.dropOptionalWork, detail: "Drop only optional work, and only after confirmation.", impact: "Destructive choice gated", state: .warning)
            append(.recoverRest, detail: "Protect recovery or rest as part of the plan.", impact: "No shame recovery", state: .success, target: nil)
        }

        if reasonKind != .stillBelievable && suggestions.contains(where: { $0.kind == .askForConfirmation }) == false {
            append(.askForConfirmation, detail: "Confirm before applying any broad reflow or calendar-impacting change.", impact: "Nothing changes until confirmed", state: .warning, target: nil)
        }

        return Array(suggestions.prefix(8))
    }

    func makeRecoveryGradient(
        reflow: TimeRealityReflowState,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeRecoveryGradientState {
        let kinds: [TimeReflowSuggestionKind] = [
            .protectOneItem,
            .shrinkAction,
            .splitAction,
            .moveLocalActionLater,
            .deferGoalOrItem,
            .dropOptionalWork,
            .recoverRest
        ]
        let options = kinds.enumerated().map { index, kind in
            TimeRecoveryGradientOptionState(
                id: "gradient-\(kind.rawValue)",
                order: index,
                kind: kind,
                title: kind.title,
                detail: gradientDetail(for: kind),
                boundary: reflowBoundary(for: kind, calendarAwareness: calendarAwareness),
                visualState: kind == .protectOneItem ? .selected : kind == .recoverRest ? .success : .default
            )
        }

        return TimeRecoveryGradientState(
            title: "Recovery options",
            detail: reflow.reasonKind == .stillBelievable
                ? "No recovery is needed, but the order stays ready if reality changes."
                : "Start with the least disruptive option that still makes the plan believable.",
            options: options
        )
    }

    func makeSaveTheDay(
        reflow: TimeRealityReflowState,
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?,
        openCaptures: [Capture]
    ) -> TimeSaveTheDayState {
        let protected = pressuredGoalSummary?.contexts.first?.step.title
            ?? pressuredGoalSummary?.goal.title
            ?? weekDays.flatMap(\.blocks).first(where: { $0.kind == .protected || $0.kind == .fixed })?.title
            ?? missingGoalSummaries.first?.goal.title
            ?? "One must-do"
        let adjustment = reflow.suggestions.first { suggestion in
            [.shrinkAction, .moveLocalActionLater, .dropOptionalWork, .deferGoalOrItem].contains(suggestion.kind)
        }?.title ?? "Keep the plan unchanged"
        let question = openCaptures.isEmpty && missingGoalSummaries.isEmpty
            ? nil
            : "What is the one thing that still needs protection?"

        return TimeSaveTheDayState(
            title: "Save the Day in Time",
            detail: "Time handles the deeper recovery shape without changing anything for you.",
            oneQuestion: question,
            protectedItem: protected,
            adjustment: adjustment,
            recoveryExplanation: reflow.reasonKind == .stillBelievable
                ? "No rescue is needed; keep recovery room visible."
                : "Recovery works by protecting one thing, reducing one thing, and leaving the rest unchanged until you confirm.",
            boundary: "No silent rescheduling. Calendar stays untouched. Nothing changed yet.",
            visualState: reflow.visualState
        )
    }

    func makeReflowReceiptPreview(
        reflow: TimeRealityReflowState,
        saveTheDay: TimeSaveTheDayState
    ) -> TimeReflowReceiptPreviewState {
        let primary = reflow.suggestions.first
        let confirmationRequired = primary?.boundary.confirmationLabel ?? "Safe local suggestion"
        let undoAvailability = primary?.boundary.undoLabel ?? "Undo unavailable"
        let wouldChange = [
            "Protect: \(saveTheDay.protectedItem)",
            "Adjust: \(saveTheDay.adjustment)",
            reflow.reasonKind == .stillBelievable ? "No reflow would be applied." : "Receipt would show the suggested change before action."
        ]
        let wouldNotChange = [
            "Calendar blocks are not written.",
            "The plan is not silently rescheduled.",
            "Sync, export, widgets, and future systems are not touched."
        ]

        return TimeReflowReceiptPreviewState(
            title: "Before anything changes",
            detail: "A reflow receipt preview shows the tradeoff before action, not after a hidden change.",
            whatChanged: wouldChange,
            whatWouldNotChange: wouldNotChange,
            confirmationRequired: confirmationRequired,
            undoAvailability: undoAvailability,
            safeFailureFallback: "If you decline confirmation, Ambitions keeps the plan as-is and leaves manual planning available.",
            visualState: primary?.visualState ?? reflow.visualState
        )
    }

    func makeRecoveryMaturity(
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        missingGoalSummaries: [GoalWeekSummary],
        calendarAwareness: TimeCalendarAwarenessState,
        realityReflow: TimeRealityReflowState,
        saveTheDay: TimeSaveTheDayState,
        receiptPreview: TimeReflowReceiptPreviewState
    ) -> TimeRecoveryMaturityState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded || $0.level == .fragile }.count
        let waitingCount = openCaptures.filter { capture in
            capture.status == .waiting || capture.status == .delegated || capture.kind == .waitingItem || capture.triageStatus == .waiting
        }.count
        let commitmentCount = openCaptures.filter { capture in
            capture.kind == .oneTimeCommitment || capture.kind == .deadlineTask || capture.commitmentKind != nil
        }.count
        let socialWaitingCount = openCaptures.filter { capture in
            capture.waitingMetadata?.waitingOn?.isEmpty == false || capture.waitingMetadata?.blockedBy?.isEmpty == false || capture.status == .delegated
        }.count
        let fitLabel: String
        if overloadedDays > 0 {
            fitLabel = "Needs relief"
        } else if missingGoalSummaries.isEmpty == false || waitingCount > 0 || commitmentCount > 0 {
            fitLabel = "Needs a decision"
        } else if realityReflow.reasonKind == .stillBelievable {
            fitLabel = "Believable"
        } else {
            fitLabel = "Needs review"
        }

        let waitingDetail: String
        if waitingCount > 0 || commitmentCount > 0 {
            waitingDetail = "\(waitingCount) waiting item\(waitingCount == 1 ? "" : "s") and \(commitmentCount) commitment\(commitmentCount == 1 ? "" : "s") should stay visible instead of becoming quiet pressure."
        } else {
            waitingDetail = "No waiting item or one-time commitment is currently pushing on the plan."
        }

        let socialDetail: String
        if socialWaitingCount > 0 {
            socialDetail = "\(socialWaitingCount) people-shaped dependency \(socialWaitingCount == 1 ? "is" : "are") visible, but Plan keeps the language private and manual-first."
        } else {
            socialDetail = "No social-load assumption is inferred. You can name people-shaped pressure only when it helps you."
        }

        let signalState: AmbitionVisualState = overloadedDays > 0 || missingGoalSummaries.isEmpty == false || waitingCount > 0 || commitmentCount > 0 ? .warning : .success
        let signals = [
            TimeRecoveryMaturitySignalState(
                id: "fit",
                title: "Plan fit",
                detail: overloadedDays > 0
                    ? "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") need relief before the week widens."
                    : saveTheDay.recoveryExplanation,
                statusLabel: fitLabel,
                boundaryLabel: "Suggests one smaller step",
                visualState: signalState
            ),
            TimeRecoveryMaturitySignalState(
                id: "waiting-commitments",
                title: "Waiting and commitments",
                detail: waitingDetail,
                statusLabel: waitingCount + commitmentCount == 0 ? "Quiet" : "Visible",
                boundaryLabel: "No silent routing",
                visualState: waitingCount + commitmentCount == 0 ? .default : .warning
            ),
            TimeRecoveryMaturitySignalState(
                id: "social-load",
                title: "Social load",
                detail: socialDetail,
                statusLabel: socialWaitingCount == 0 ? "Manual" : "Private",
                boundaryLabel: "No inference without you",
                visualState: socialWaitingCount == 0 ? .default : .selected
            ),
            TimeRecoveryMaturitySignalState(
                id: "receipt",
                title: "Receipt and undo",
                detail: receiptPreview.safeFailureFallback,
                statusLabel: receiptPreview.confirmationRequired,
                boundaryLabel: receiptPreview.undoAvailability,
                visualState: receiptPreview.visualState
            )
        ]

        return TimeRecoveryMaturityState(
            title: "Recovery maturity",
            detail: "Overloaded days become decisions with receipts, not silent reschedules.",
            planFitLabel: fitLabel,
            confirmationBoundary: "Save the Day and Reality Reflow require confirmation before broad plan changes.",
            calendarBoundary: calendarAwareness.status == .calendarAware
                ? "Calendar context can inform open windows, but Plan still does not write calendar changes silently."
                : "Manual planning works without calendar access.",
            socialBoundary: "People-shaped pressure stays private, optional, and manually named.",
            receiptBoundary: "A receipt preview names what would change, what would not change, and the undo boundary.",
            signals: signals
        )
    }

    func reflowBoundary(
        for kind: TimeReflowSuggestionKind,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeReflowBoundaryState {
        switch kind {
        case .protectOneItem, .shrinkAction, .splitAction, .recoverRest, .keepPlanUnchanged:
            return TimeReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .notRequired,
                undoAvailability: .availableLocal,
                safetyLabel: "Safe/local"
            )
        case .moveLocalActionLater, .deferGoalOrItem, .parkGoal, .markWaiting:
            return TimeReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .requiredForBroadReflow,
                undoAvailability: .requiresConfirmation,
                safetyLabel: "Confirm first"
            )
        case .dropOptionalWork:
            return TimeReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .requiredForDestructiveChange,
                undoAvailability: .unsafe,
                safetyLabel: "Confirm drop"
            )
        case .askForConfirmation:
            return TimeReflowBoundaryState(
                actionKind: calendarAwareness.status == .calendarAware ? .writeCalendarBlock : .changePlanWindow,
                confirmationRequirement: calendarAwareness.status == .calendarAware ? .requiredForExternalEffect : .requiredForBroadReflow,
                undoAvailability: .notSupportedYet,
                safetyLabel: calendarAwareness.status == .calendarAware ? "Plan action required" : "Confirm first"
            )
        }
    }

    func gradientDetail(for kind: TimeReflowSuggestionKind) -> String {
        switch kind {
        case .protectOneItem: "Keep one must-do defended."
        case .shrinkAction: "Reduce the ask before moving it."
        case .splitAction: "Carry only the first clear part."
        case .moveLocalActionLater: "Reschedule one local item after confirmation."
        case .deferGoalOrItem: "Leave lower-priority work outside this window."
        case .dropOptionalWork: "Remove optional work only with confirmation."
        case .recoverRest: "Protect rest or recovery as real plan material."
        case .parkGoal: "Pause a goal until there is believable room."
        case .markWaiting: "Name the dependency instead of pushing harder."
        case .askForConfirmation: "Confirm before broad or external effects."
        case .keepPlanUnchanged: "Leave the current plan as-is."
        }
    }

    func goalShapingItems(summaries: [GoalWeekSummary]) -> [TimeGoalShapingItem] {
        summaries
            .map { summary in
                let represented = summary.contexts.isEmpty == false
                let nextMove = summary.contexts.first?.step.summary ?? summary.contexts.first?.step.actionability.fallbackMicroStep ?? "Add one believable step."
                let pressureLabel: String
                let attentionReason: String
                let relationship: String
                let visualState: AmbitionVisualState

                if represented == false {
                    pressureLabel = "Carryover"
                    attentionReason = "This goal is active but the current week does not yet give it believable room."
                    relationship = "Still outside the week"
                    visualState = .warning
                } else if summary.frictionCount > 0 {
                    pressureLabel = "Needs lighter ask"
                    attentionReason = "Recent friction suggests the current step is heavier than the week can comfortably carry."
                    relationship = "Visible, but straining"
                    visualState = .warning
                } else if summary.evaluation?.feasibilityLevel == .fragile || summary.evaluation?.feasibilityLevel == .notBelievable {
                    pressureLabel = "Fragile"
                    attentionReason = "The underlying plan evaluation is already warning that this goal is stressing the week."
                    relationship = "Present on protected time"
                    visualState = .warning
                } else if summary.evaluation?.feasibilityLevel == .tight {
                    pressureLabel = "Kept in view"
                    attentionReason = "This goal fits, but only if its current room stays protected."
                    relationship = "Visible and narrow"
                    visualState = .selected
                } else {
                    pressureLabel = "Believable"
                    attentionReason = "This goal has a clear lane in the week and does not currently need heavy intervention."
                    relationship = "Holding cleanly"
                    visualState = .success
                }

                return TimeGoalShapingItem(
                    id: "plan-goal-\(summary.goal.id)",
                    target: GoalRouteTarget(goalID: summary.goal.id),
                    goalTitle: summary.goal.title,
                    weekRelationship: relationship,
                    pressureLabel: pressureLabel,
                    attentionReason: attentionReason,
                    nextMoveLabel: nextMove,
                    visualState: visualState
                )
            }
            .sorted { lhs, rhs in
                let leftRank = shapingRank(for: lhs.visualState)
                let rightRank = shapingRank(for: rhs.visualState)
                if leftRank == rightRank {
                    return lhs.goalTitle.localizedCaseInsensitiveCompare(rhs.goalTitle) == .orderedAscending
                }
                return leftRank < rightRank
            }
            .prefix(4)
            .map { $0 }
    }

    func pressuredGoalSummary(from summaries: [GoalWeekSummary]) -> GoalWeekSummary? {
        summaries.max { lhs, rhs in
            pressureScore(for: lhs) < pressureScore(for: rhs)
        }
    }

    func goalLifecycleState(goal: Goal, evidence: [ProgressEvidence], now: Date) -> GoalPortfolioLifecycleState {
        switch goal.state {
        case .completed:
            return .completed
        case .archived:
            return goal.plan?.sections.flatMap(\.steps).contains(where: { $0.state == .completed }) == true ? .previous : .cancelledDropped
        case .paused:
            return .parked
        case .draft:
            return .future
        case .active:
            break
        }

        let steps = goal.plan?.sections.flatMap(\.steps) ?? []
        if steps.contains(where: { $0.state == .blocked }) {
            return .blocked
        }
        if hasFutureStart(goal.timing, now: now) {
            return .future
        }
        if goal.mode == .delegatedSupport || goal.relationshipKind == .delegated {
            return .waiting
        }
        if goal.mode == .maintenance || goal.mode == .learning || goal.mode == .exploration {
            if evidence.isEmpty && steps.filter({ $0.state != .completed && $0.state != .cancelled }).count <= 1 {
                return .waiting
            }
        }
        if goal.timing.dueAt != nil || goal.timing.targetBy != nil {
            return .protected
        }
        return .active
    }

    func lifecycleSubtitle(for state: GoalPortfolioLifecycleState, count: Int) -> String {
        if count == 0 {
            switch state {
            case .previous: return "No prior pressure"
            case .active: return "No live load"
            case .future: return "Nothing scheduled later"
            case .waiting: return "No waiting goal"
            case .blocked: return "No blocked goal"
            case .parked: return "Nothing parked"
            case .protected: return "Nothing protected"
            case .completed: return "No completion here"
            case .cancelledDropped: return "No dropped goal"
            case .passive: return "No passive goal"
            }
        }

        switch state {
        case .previous: return "Closed, parked, or transformed"
        case .active: return "Currently shaping attention"
        case .future: return "Planned, not active yet"
        case .waiting: return "Waiting on an answer"
        case .blocked: return "Needs unblock"
        case .parked: return "Intentionally outside pressure"
        case .protected: return "Should be defended"
        case .completed: return "Done and preserved"
        case .cancelledDropped: return "Dropped without shame"
        case .passive: return "Quiet support"
        }
    }

    func hasFutureStart(_ timing: GoalTiming, now: Date) -> Bool {
        guard let startsOn = timing.startsOn, let date = parseDate(startsOn) else {
            return false
        }
        return date > now
    }

    func futureTimingLabel(for goal: Goal, now: Date) -> String {
        if hasFutureStart(goal.timing, now: now), let startsOn = goal.timing.startsOn {
            return "Starts \(shortDate(startsOn))"
        }
        if let targetBy = goal.timing.targetBy {
            return "Later \(shortDate(targetBy))"
        }
        if let dueAt = goal.timing.dueAt {
            return "Due later \(shortDate(dueAt))"
        }
        return "Future"
    }

    func postureState(
        evaluations: [PlanningEvaluation],
        blockedCount: Int,
        clarificationCount: Int,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState],
        mode: TimeDashboardMode
    ) -> TimeBelievabilityState {
        guard mode == .active else {
            return TimeBelievabilityState(
                title: "The week is open",
                detail: "No active goals or captures are pressing for structure yet.",
                label: "Open",
                supportLabel: "This is a real state, not missing data.",
                visualState: .default
            )
        }

        if blockedCount + clarificationCount > 0 {
            return TimeBelievabilityState(
                title: "The week is waiting on reality",
                detail: "Open questions or blockers make the current shape less believable than it looks.",
                label: "Needs clarity",
                supportLabel: "Clarify before adding more commitment.",
                visualState: .warning
            )
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            return TimeBelievabilityState(
                title: "The week is overloaded",
                detail: "At least one day is carrying more than the current structure can explain calmly.",
                label: "Overloaded",
                supportLabel: "Lighten the loudest lane first.",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .notBelievable || $0.feasibilityLevel == .fragile }) {
            return TimeBelievabilityState(
                title: "The week is fragile",
                detail: "Existing plan evaluations are warning that current commitments need gentler scope.",
                label: "Fragile",
                supportLabel: "Protect what is believable and soften the rest.",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .tight }) || openCaptureCount > 0 || weekDays.contains(where: { $0.level == .tight }) {
            return TimeBelievabilityState(
                title: "The week is believable but tight",
                detail: "The structure can hold, but room is already limited and pressure is visible.",
                label: "Tight",
                supportLabel: "Patch with restraint instead of adding density.",
                visualState: .selected
            )
        }

        return TimeBelievabilityState(
            title: "The week looks believable",
            detail: "Visible work, protected time, and open room are currently in balance.",
            label: "Believable",
            supportLabel: "You can shape calmly because the week already has a coherent backbone.",
            visualState: .success
        )
    }

    func timeframeLabel(now: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        let start = Calendar.current.startOfDay(for: now)
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
        return "\(formatter.string(from: start))-\(formatter.string(from: end))"
    }

    func timingLabel(for timing: GoalTiming) -> String {
        if let dueAt = timing.dueAt {
            return "Due \(shortDate(dueAt))"
        }
        if let targetBy = timing.targetBy {
            return "Protect \(shortDate(targetBy))"
        }
        if let suggestedNextAt = timing.suggestedNextAt {
            return "Flex \(shortDate(suggestedNextAt))"
        }
        if let repeatEveryDays = timing.repeatEveryDays {
            return "Every \(repeatEveryDays)d"
        }
        return "Flexible"
    }

    func plannedDate(for timing: GoalTiming) -> Date? {
        parseDate(timing.dueAt ?? timing.targetBy ?? timing.suggestedNextAt ?? timing.startsOn)
    }

    func blockKind(for timing: GoalTiming) -> TimeWeekBlockKind {
        if timing.dueAt != nil {
            return .fixed
        }
        if timing.targetBy != nil {
            return .protected
        }
        return .flexible
    }

    func blockVisualState(step: Step, evaluation: PlanningEvaluation?, frictionCount: Int) -> AmbitionVisualState {
        if step.state == .blocked || frictionCount > 0 {
            return .warning
        }
        if evaluation?.feasibilityLevel == .fragile || evaluation?.feasibilityLevel == .notBelievable {
            return .warning
        }
        if evaluation?.feasibilityLevel == .tight {
            return .selected
        }
        return .default
    }

    func loadWeight(for kind: TimeWeekBlockKind, visualState: AmbitionVisualState) -> Double {
        let base: Double = switch kind {
        case .fixed: 1.35
        case .protected: 1.0
        case .flexible: 0.72
        }
        if visualState == .warning {
            return base + 0.25
        }
        if visualState == .selected {
            return base + 0.1
        }
        return base
    }

    func dayIntensity(for level: TimeWeekPressureLevel, blockCount: Int) -> Double {
        let base: Double = switch level {
        case .open: 0.48
        case .steady: 0.66
        case .tight: 0.84
        case .fragile: 0.92
        case .overloaded: 1.0
        }
        return min(base + (Double(blockCount) * 0.04), 1.0)
    }

    func roomLabel(for level: TimeWeekPressureLevel, remainingCapacity: Double, contextCount: Int) -> String {
        switch level {
        case .open:
            return contextCount == 0 ? "Open day" : "Wide room"
        case .steady:
            return remainingCapacity > 1.0 ? "Room remains" : "Steady load"
        case .tight:
            return "Little room left"
        case .fragile:
            return "Fragile room"
        case .overloaded:
            return "Needs relief"
        }
    }

    func dayHighlight(
        level: TimeWeekPressureLevel,
        contexts: [StepContext],
        suggestedSummary: GoalWeekSummary?
    ) -> String {
        if level == .overloaded {
            return "Pressure is stacking here."
        }
        if level == .fragile {
            return "This day needs recovery room."
        }
        if level == .tight {
            return "This day needs protected edges."
        }
        if let first = contexts.first {
            return "\(first.goal.title) is anchoring this day."
        }
        if let suggestedSummary {
            return "\(suggestedSummary.goal.title) could fit here."
        }
        return "Keep the room visible."
    }

    func pressureRank(for level: TimeWeekPressureLevel) -> Int {
        switch level {
        case .open: 0
        case .steady: 1
        case .tight: 2
        case .fragile: 3
        case .overloaded: 4
        }
    }

    func pressureScore(for summary: GoalWeekSummary) -> Double {
        var score = Double(summary.frictionCount * 3)
        if summary.contexts.isEmpty {
            score += 5
        }
        switch summary.evaluation?.feasibilityLevel {
        case .notBelievable:
            score += 5
        case .fragile:
            score += 4
        case .tight:
            score += 2
        default:
            break
        }
        score += Double(summary.contexts.count)
        return score
    }

    func shortDate(_ value: String) -> String {
        guard let date = parseDate(value) else { return value }
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter.string(from: date)
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        if let date = ISO8601DateFormatter().date(from: value) {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        default:
            return false
        }
    }

    func shapingRank(for state: AmbitionVisualState) -> Int {
        switch state {
        case .warning:
            return 0
        case .selected:
            return 1
        case .pressed, .loading:
            return 2
        case .default:
            return 3
        case .disabled:
            return 4
        case .success:
            return 5
        case .celebration:
            return 6
        }
    }
}

protocol TimeFeatureProjectionSource {
    func loadSnapshot() async throws -> RepositoryBackedTimeService.Snapshot
    func makeDashboard(snapshot: RepositoryBackedTimeService.Snapshot, now: Date, calendarAwareness: TimeCalendarAwarenessState) -> TimeDashboard
    func makeWeeklyReviewDashboard(snapshot: RepositoryBackedTimeService.Snapshot, now: Date) -> WeeklyReviewDashboard
    func makeCalendarAwarenessState(permission: CalendarPermissionState, openWindowCount: Int?) -> TimeCalendarAwarenessState
}

struct TimeFeatureService {
    func makeDashboard(
        from source: any TimeFeatureProjectionSource,
        now: Date,
        permission: CalendarPermissionState,
        openWindowCount: Int? = nil,
        snapshot: RepositoryBackedTimeService.Snapshot? = nil
    ) async throws -> TimeDashboard {
        let resolvedSnapshot = try await {
            if let snapshot {
                return snapshot
            }
            return try await source.loadSnapshot()
        }()
        let calendarAwareness = source.makeCalendarAwarenessState(permission: permission, openWindowCount: openWindowCount)
        return source.makeDashboard(
            snapshot: resolvedSnapshot,
            now: now,
            calendarAwareness: calendarAwareness
        )
    }

    func makeWeeklyReviewDashboard(from source: any TimeFeatureProjectionSource, now: Date) async throws -> WeeklyReviewDashboard {
        let snapshot = try await source.loadSnapshot()
        return source.makeWeeklyReviewDashboard(snapshot: snapshot, now: now)
    }
}
