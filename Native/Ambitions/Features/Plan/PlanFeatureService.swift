import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedPlanService: PlanServicing {
    let repositories: AppRepositories
    let calendarRealityService: (any CalendarRealityServicing)?

    init(
        repositories: AppRepositories,
        calendarRealityService: (any CalendarRealityServicing)? = nil
    ) {
        self.repositories = repositories
        self.calendarRealityService = calendarRealityService
    }

    func loadPlanDashboard(now: Date) async throws -> PlanDashboard {
        let snapshot = try await loadSnapshot()
        let permission = await calendarRealityService?.calendarPermissionState() ?? .unavailable
        return makeDashboard(snapshot: snapshot, now: now, calendarAwareness: makeCalendarAwarenessState(permission: permission, openWindowCount: nil))
    }

    func loadWeeklyReviewDashboard(now: Date) async throws -> WeeklyReviewDashboard {
        let snapshot = try await loadSnapshot()
        return makeWeeklyReviewDashboard(snapshot: snapshot, now: now)
    }

    func makePlanCalendarAware(now: Date) async throws -> PlanDashboard {
        let snapshot = try await loadSnapshot()
        guard let calendarRealityService else {
            return makeDashboard(snapshot: snapshot, now: now, calendarAwareness: makeCalendarAwarenessState(permission: .unavailable, openWindowCount: nil))
        }
        let result = await calendarRealityService.findOpenWindows(
            request: CalendarRealityReadRequest(
                horizon: weekHorizon(now: now),
                userInitiatedPlanAction: "Make Plan calendar-aware",
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
            actionName: "Make Plan calendar-aware"
        )
        try? await repositories.eventLedger.append(event)
        return makeDashboard(
            snapshot: snapshot,
            now: now,
            calendarAwareness: makeCalendarAwarenessState(
                permission: result.permissionState,
                openWindowCount: result.openWindowCandidates.count
            )
        )
    }
}

private extension RepositoryBackedPlanService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]
    }

    struct StepContext {
        let goal: Goal
        let step: Step
        let date: Date
        let dayIndex: Int
        let timingLabel: String
        let blockKind: PlanWeekBlockKind
        let visualState: AmbitionVisualState
        let frictionCount: Int
        let evaluation: PlanningEvaluation?
    }

    struct GoalWeekSummary {
        let goal: Goal
        let contexts: [StepContext]
        let frictionCount: Int
        let evaluation: PlanningEvaluation?
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures
        )
    }

    func weekHorizon(now: Date) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(7 * 86_400)
        return DateInterval(start: start, end: end)
    }

    func makeCalendarAwarenessState(permission: CalendarPermissionState, openWindowCount: Int?) -> PlanCalendarAwarenessState {
        switch permission {
        case .readWrite:
            return PlanCalendarAwarenessState(
                status: .calendarAware,
                title: "Calendar-aware planning",
                detail: openWindowCount.map { "Plan used calendar-derived busy time locally and found \($0) open window\($0 == 1 ? "" : "s")." }
                    ?? "Plan can use calendar-derived busy time locally when you ask for real open windows.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar.badge.clock",
                valueLabel: "Aware",
                sourceLabel: "From your calendar",
                visualState: .success,
                canRequestCalendarRead: true
            )
        case .writeOnly:
            return PlanCalendarAwarenessState(
                status: .writeOnly,
                title: "Calendar write is available",
                detail: "Plan can write confirmed blocks, but it cannot read availability until calendar read access is granted.",
                primaryActionTitle: "Make Plan calendar-aware",
                primaryActionSystemImage: "calendar.badge.clock",
                valueLabel: "Write only",
                sourceLabel: "Created in Ambitions",
                visualState: .warning,
                canRequestCalendarRead: true
            )
        case .denied, .restricted:
            return PlanCalendarAwarenessState(
                status: .denied,
                title: "Plan works without Calendar",
                detail: "Calendar access is unavailable, so Plan uses Ambitions data and baseline windows without reading events.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar.badge.exclamationmark",
                valueLabel: "Denied",
                sourceLabel: "Created in Ambitions",
                visualState: .warning,
                canRequestCalendarRead: false
            )
        case .notDetermined:
            return PlanCalendarAwarenessState(
                status: .baseline,
                title: "Make Plan calendar-aware",
                detail: "Plan works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
                primaryActionTitle: "Make Plan calendar-aware",
                primaryActionSystemImage: "calendar.badge.plus",
                valueLabel: "Optional",
                sourceLabel: "Based on your plan",
                visualState: .default,
                canRequestCalendarRead: true
            )
        case .unavailable:
            return PlanCalendarAwarenessState(
                status: .unavailable,
                title: "Calendar-aware mode unavailable",
                detail: "Plan is using Ambitions data only in this runtime.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar",
                valueLabel: "Local",
                sourceLabel: "Created in Ambitions",
                visualState: .default,
                canRequestCalendarRead: false
            )
        }
    }

    func makeDashboard(snapshot: Snapshot, now: Date, calendarAwareness: PlanCalendarAwarenessState) -> PlanDashboard {
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
        let mode: PlanDashboardMode = activeGoals.isEmpty && snapshot.drafts.isEmpty && openCaptures.isEmpty ? .empty : .active
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
        let recoveryMaturity = makeRecoveryMaturity(
            weekDays: weekDays,
            openCaptures: openCaptures,
            missingGoalSummaries: missingGoalSummaries,
            calendarAwareness: calendarAwareness,
            realityReflow: realityReflow,
            saveTheDay: saveTheDay,
            receiptPreview: reflowReceiptPreview
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

        return PlanDashboard(
            mode: mode,
            timeframeLabel: timeframeLabel(now: now),
            hero: hero,
            primaryAction: primaryAction,
            treaty: treaty,
            capacityEnvelope: capacityEnvelope,
            lifecycleRail: lifecycleRail,
            timelineStrip: timelineStrip,
            opportunityWindows: opportunityWindows,
            decisionDebt: decisionDebt,
            conflictCourt: conflictCourt,
            calendarBoundary: calendarBoundary,
            recoveryEntry: recoveryEntry,
            realityReflow: realityReflow,
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
                PlanSecondaryDestination(
                    id: "plan-habits",
                    title: "Rituals",
                    detail: habitGoals.isEmpty
                        ? "No repeatable loops are shaping the week yet."
                        : "Review the repeatable loops that can steady or crowd the week.",
                    valueLabel: "\(habitGoals.count)",
                    icon: AppTab.habits.systemImage,
                    visualState: habitGoals.isEmpty ? .default : .selected,
                    planRoute: .habits
                ),
                PlanSecondaryDestination(
                    id: "plan-captures",
                    title: "Capture into the week",
                    detail: openCaptures.isEmpty
                        ? "No open captures are pushing on the week right now."
                        : "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") still need to be absorbed, attached, or intentionally parked.",
                    valueLabel: "\(openCaptures.count)",
                    icon: AppTab.captures.systemImage,
                    visualState: openCaptures.isEmpty ? .default : .warning,
                    planRoute: .capturesInbox
                ),
                PlanSecondaryDestination(
                    id: "plan-weekly-review",
                    title: "Weekly review",
                    detail: "Close the current week by shaping carry-forward, ritual pressure, and unresolved captures without leaving Plan.",
                    valueLabel: posture.label,
                    icon: "arrow.triangle.branch",
                    visualState: posture.visualState,
                    planRoute: .weeklyReview
                )
            ],
            emptyTitle: mode == .empty ? "No weekly pressure yet" : nil,
            emptyMessage: mode == .empty ? "As soon as goals, captures, or routines create real constraints, Plan will show where the week still has room." : nil
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
                    ? "The review should reduce strain first, then carry forward only the moves the next week can explain."
                    : "The review can keep what worked, leave room visible, and carry forward only the next believable moves.",
                continuityLabel: "Return to the week with a calmer shape, not a larger list.",
                contextPills: [
                    PlanHeroPillState(title: timeframeLabel(now: now), icon: "calendar", state: .default),
                    PlanHeroPillState(title: posture.label, icon: AppTab.plan.systemImage, state: posture.visualState),
                    PlanHeroPillState(title: "\(carryForwardItems.count) carry-forward lanes", icon: "arrow.triangle.branch", state: carryForwardItems.isEmpty ? .default : .selected)
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
            returnActionTitle: "Return to Plan",
            returnActionSubtitle: "Use the reshaped week, then adjust one goal or support route only if it still needs help.",
            returnPlanRoute: nil,
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
    ) -> [PlanElasticWeekDayState] {
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
            let level: PlanWeekPressureLevel = {
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
                PlanWeekBlockState(
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

            return PlanElasticWeekDayState(
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
        level: PlanWeekPressureLevel,
        remainingCapacity: Double,
        suggestedSummary: GoalWeekSummary?,
        contextCount: Int
    ) -> PlanOpenWindowState? {
        guard level != .overloaded || remainingCapacity > -0.1 else {
            return nil
        }

        if let suggestedSummary {
            return PlanOpenWindowState(
                title: level == .open ? "Open window" : "Usable room",
                detail: contextCount == 0
                    ? "This day can carry one believable move without turning calendar-dense."
                    : "There is still enough room to protect or patch one calmer move.",
                suggestionLabel: suggestedSummary.goal.title,
                target: GoalRouteTarget(goalID: suggestedSummary.goal.id),
                visualState: level == .open ? .success : .selected
            )
        }

        return PlanOpenWindowState(
            title: level == .open ? "Leave this open" : "Keep breathing room",
            detail: "Not every open pocket needs to be filled. Open room keeps the week doable.",
            suggestionLabel: nil,
            target: nil,
            visualState: .default
        )
    }

    func makePressureScrubber(days: [PlanElasticWeekDayState]) -> PlanPressureScrubberState {
        let defaultDayID = days.max { lhs, rhs in
            if lhs.level == rhs.level {
                return lhs.intensity < rhs.intensity
            }
            return pressureRank(for: lhs.level) < pressureRank(for: rhs.level)
        }?.id ?? days.first?.id ?? "day-0"

        return PlanPressureScrubberState(
            title: "Pressure scrubber",
            subtitle: "Scrub the week to inspect where pressure gathers, where room remains, and which day can take another believable move.",
            defaultDayID: defaultDayID,
            points: days.map { day in
                PlanPressureScrubberPoint(
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
        posture: PlanBelievabilityState,
        blockedCount: Int,
        clarificationCount: Int,
        openCaptureCount: Int,
        missingGoalCount: Int,
        activeGoalCount: Int
    ) -> PlanBelievabilityState {
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

        return PlanBelievabilityState(
            title: posture.title,
            detail: posture.detail,
            label: posture.label,
            supportLabel: supportLabel,
            visualState: posture.visualState
        )
    }

    func makeExecutionResilience(
        posture: PlanBelievabilityState,
        weekDays: [PlanElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?,
        habitGoals: [Goal],
        openCaptures: [Capture]
    ) -> PlanExecutionResilienceState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let laneState: AmbitionVisualState = overloadedDays > 0 || missingGoalSummaries.isEmpty == false || openCaptures.isEmpty == false
            ? .warning
            : posture.visualState

        return PlanExecutionResilienceState(
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
                PlanExecutionResilienceLane(
                    id: "carryover",
                    title: "Carryover",
                    detail: missingGoalSummaries.isEmpty
                        ? "No active goal is currently floating outside the week."
                        : "Resolve carryover by giving only the missing goal a believable lane instead of widening the whole week.",
                    recommendation: missingGoalSummaries.first.map { "\($0.goal.title) is the cleanest carry-forward candidate." } ?? "Carry only what the next week can explain calmly.",
                    state: missingGoalSummaries.isEmpty ? .success : .warning,
                    goalTarget: missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) },
                    planRoute: nil
                ),
                PlanExecutionResilienceLane(
                    id: "overload",
                    title: "Overload",
                    detail: overloadedDays == 0
                        ? "No day is visibly overloaded right now."
                        : "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") are carrying more than the week can explain without relief.",
                    recommendation: pressuredGoalSummary.map { "Lighten \($0.goal.title) before adding anything new." } ?? "Lighten the loudest lane first.",
                    state: overloadedDays == 0 ? .selected : .warning,
                    goalTarget: pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) },
                    planRoute: nil
                ),
                PlanExecutionResilienceLane(
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
                    planRoute: .habits
                ),
                PlanExecutionResilienceLane(
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
                    planRoute: .capturesInbox
                ),
                PlanExecutionResilienceLane(
                    id: "review",
                    title: "Weekly review",
                    detail: "Use review as a shaping continuation so next week inherits the right amount of carry-forward truth.",
                    recommendation: "Close the week by shaping what should continue, not by creating more admin.",
                    state: laneState,
                    goalTarget: nil,
                    planRoute: .weeklyReview
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
        weekDays: [PlanElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?
    ) -> PlanWindowMagnetismState? {
        guard let candidateDay = weekDays.first(where: { $0.level == .open && $0.openWindow?.target != nil }) ??
                weekDays.first(where: { $0.level == .steady && $0.openWindow?.target != nil }),
              let openWindow = candidateDay.openWindow else {
            return nil
        }

        let suggestedGoalTitle = openWindow.suggestionLabel ?? missingGoalSummaries.first?.goal.title ?? pressuredGoalSummary?.goal.title ?? "the next lighter move"

        return PlanWindowMagnetismState(
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
        posture: PlanBelievabilityState,
        timeframeLabel: String,
        representedGoalCount: Int,
        activeGoalCount: Int,
        weekDays: [PlanElasticWeekDayState],
        missingGoalCount: Int,
        openCaptureCount: Int,
        mode: PlanDashboardMode
    ) -> PlanRealityHeroState {
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
            return "\(openDays) day\(openDays == 1 ? "" : "s") still carry visible room for a believable move."
        }()

        let pressureSummary: String = {
            if openCaptureCount > 0 {
                return "Outside pressure is mostly coming from captures that have not yet been attached or discarded."
            }
            return posture.supportLabel
        }()

        return PlanRealityHeroState(
            eyebrow: "Plan",
            title: "Does this hold together?",
            subtitle: "Plan now reads the week as room, pressure, and protected structure instead of a dense calendar clone.",
            dominantTruth: dominantTruth,
            roomSummary: roomSummary,
            pressureSummary: pressureSummary,
            contextPills: [
                PlanHeroPillState(title: timeframeLabel, icon: "calendar", state: .default),
                PlanHeroPillState(title: posture.label, icon: AppTab.plan.systemImage, state: posture.visualState),
                PlanHeroPillState(title: "\(representedGoalCount)/\(max(activeGoalCount, 1)) goals visible", icon: "target", state: representedGoalCount == activeGoalCount && activeGoalCount > 0 ? .success : .selected)
            ],
            trustWhisper: posture.supportLabel
        )
    }

    func makePrimaryAction(
        mode: PlanDashboardMode,
        posture: PlanBelievabilityState,
        missingGoalSummary: GoalWeekSummary?,
        pressuredGoalSummary: GoalWeekSummary?,
        openCaptureCount: Int,
        weekDays: [PlanElasticWeekDayState]
    ) -> PlanWeekPrimaryAction {
        if mode == .empty {
            return PlanWeekPrimaryAction(
                kind: .useRoom,
                title: "Use this room",
                subtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
                systemImage: "sparkles",
                state: .success,
                goalTarget: nil,
                planRoute: nil
            )
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            return PlanWeekPrimaryAction(
                kind: .lightenWeek,
                title: "Lighten week",
                subtitle: openCaptureCount > 0
                    ? "Reduce outside pressure first so the week stops carrying speculative load."
                    : "One day is carrying too much. Lighten the loudest lane before adding more.",
                systemImage: "sun.max",
                state: .warning,
                goalTarget: openCaptureCount > 0 ? nil : pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) },
                planRoute: openCaptureCount > 0 ? .capturesInbox : nil
            )
        }

        if let missingGoalSummary, weekDays.contains(where: { $0.level == .open }) {
            return PlanWeekPrimaryAction(
                kind: .useRoom,
                title: "Use this room",
                subtitle: "There is believable room for one calmer move on \(missingGoalSummary.goal.title).",
                systemImage: "arrow.down.left.and.arrow.up.right",
                state: .success,
                goalTarget: GoalRouteTarget(goalID: missingGoalSummary.goal.id),
                planRoute: nil
            )
        }

        if let missingGoalSummary {
            return PlanWeekPrimaryAction(
                kind: .resolveCarryover,
                title: "Resolve carryover",
                subtitle: "\(missingGoalSummary.goal.title) is active but still not represented in the week.",
                systemImage: "arrow.triangle.branch",
                state: .selected,
                goalTarget: GoalRouteTarget(goalID: missingGoalSummary.goal.id),
                planRoute: nil
            )
        }

        return PlanWeekPrimaryAction(
            kind: .shapeWeek,
            title: "Shape this week",
            subtitle: posture.supportLabel,
            systemImage: "wand.and.stars",
            state: posture.visualState == .warning ? .selected : posture.visualState,
            goalTarget: pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) } ?? weekDays.flatMap(\.blocks).first?.target,
            planRoute: nil
        )
    }

    func makeShapingActions(
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?,
        openCaptureCount: Int,
        weekDays: [PlanElasticWeekDayState]
    ) -> [PlanShapingActionState] {
        let firstVisibleBlock = weekDays.flatMap(\.blocks).first
        let firstOpenWindow = weekDays.compactMap(\.openWindow).first(where: { $0.target != nil })
        let noisyDay = weekDays.first(where: { $0.level == .overloaded }) ?? weekDays.first(where: { $0.level == .tight })
        let missingGoalTarget = missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) }
        let pressuredTarget = pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) }

        return [
            PlanShapingActionState(
                kind: .edit,
                title: "Edit",
                subtitle: firstVisibleBlock?.title ?? "Edit the week at the block level.",
                recommendation: firstVisibleBlock == nil
                    ? "No dated block is visible yet, so there is nothing to edit directly."
                    : "Start with the clearest existing block instead of redrawing the whole week.",
                systemImage: PlanShapingActionKind.edit.systemImage,
                state: firstVisibleBlock == nil ? .default : .selected,
                goalTarget: firstVisibleBlock?.target,
                planRoute: nil
            ),
            PlanShapingActionState(
                kind: .patch,
                title: "Patch",
                subtitle: missingGoalSummaries.isEmpty
                    ? "Patch the week without changing its calm shape."
                    : "Give missing goals one believable lane instead of spreading them everywhere.",
                recommendation: missingGoalSummaries.isEmpty
                    ? "Use the cleanest open window or the weakest day and make one small adjustment."
                    : "Patch missing work into the week only where room is actually visible.",
                systemImage: PlanShapingActionKind.patch.systemImage,
                state: missingGoalSummaries.isEmpty ? .selected : .warning,
                goalTarget: missingGoalTarget ?? firstOpenWindow?.target,
                planRoute: nil
            ),
            PlanShapingActionState(
                kind: .protect,
                title: "Protect",
                subtitle: firstOpenWindow?.title ?? "Protect the parts of the week that already feel believable.",
                recommendation: firstOpenWindow?.suggestionLabel == nil
                    ? "The best protection may be leaving one pocket unfilled."
                    : "Protect the calmest pocket before pressure spills into it.",
                systemImage: PlanShapingActionKind.protect.systemImage,
                state: firstOpenWindow == nil ? .default : .success,
                goalTarget: firstOpenWindow?.target ?? firstVisibleBlock?.target ?? pressuredTarget,
                planRoute: nil
            ),
            PlanShapingActionState(
                kind: .lighten,
                title: "Lighten",
                subtitle: noisyDay?.highlight ?? "Lighten the loudest part of the week first.",
                recommendation: openCaptureCount > 0
                    ? "Reduce speculative load before trying to force more commitment into the week."
                    : "Shrink or move the heaviest ask before the week starts feeling performative.",
                systemImage: PlanShapingActionKind.lighten.systemImage,
                state: noisyDay == nil ? .default : .warning,
                goalTarget: openCaptureCount > 0 ? nil : pressuredTarget,
                planRoute: openCaptureCount > 0 ? .capturesInbox : nil
            )
        ]
    }

    func makeTreaty(
        posture: PlanBelievabilityState,
        capacityEnvelope: PlanCapacityEnvelopeState,
        calendarBoundary: PlanCalendarBoundaryContractState,
        weekContexts: [StepContext],
        missingGoalCount: Int,
        openCaptureCount: Int,
        weekDays: [PlanElasticWeekDayState],
        primaryAction: PlanWeekPrimaryAction
    ) -> PlanTreatyState {
        let protectedCount = weekContexts.filter { $0.blockKind == .protected || $0.blockKind == .fixed }.count
        let flexibleCount = weekContexts.filter { $0.blockKind == .flexible }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let overloadedDays = weekDays.filter { $0.level == .overloaded || $0.level == .fragile }.count

        return PlanTreatyState(
            title: "This week's agreement",
            summary: posture.visualState == .warning
                ? "This plan can still be kind, but it needs one honest adjustment before more work is added."
                : "This plan is a calm agreement between protected work, flexible work, and room you are allowed to keep.",
            protectedWork: protectedCount == 0
                ? "Nothing is marked as protected yet."
                : "\(protectedCount) protected or fixed move\(protectedCount == 1 ? "" : "s") should stay defended.",
            flexibleWork: flexibleCount == 0
                ? "No flexible work is asking for placement right now."
                : "\(flexibleCount) flexible move\(flexibleCount == 1 ? "" : "s") can bend around real life.",
            notTodayWork: missingGoalCount + openCaptureCount == 0
                ? "Nothing obvious needs to be kept outside today."
                : "\(missingGoalCount + openCaptureCount) item\(missingGoalCount + openCaptureCount == 1 ? "" : "s") should wait, clarify, or stay outside today's pressure.",
            recoveryAllowance: overloadedDays == 0 && openDays > 0
                ? "\(openDays) open day\(openDays == 1 ? "" : "s") keep recovery room visible."
                : "Recovery room is thin; move one thing, not everything.",
            calendarBoundary: calendarBoundary.manualFallback,
            primaryActionTitle: primaryAction.title,
            primaryActionSubtitle: primaryAction.subtitle,
            visualState: capacityEnvelope.visualState
        )
    }

    func makeCapacityEnvelope(
        posture: PlanBelievabilityState,
        weekDays: [PlanElasticWeekDayState],
        visibleBlockCount: Int,
        protectedCount: Int,
        missingGoalCount: Int,
        openCaptureCount: Int,
        calendarAwareness: PlanCalendarAwarenessState
    ) -> PlanCapacityEnvelopeState {
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

        return PlanCapacityEnvelopeState(
            title: "Capacity envelope",
            detail: "\(calendarCopy) The envelope stays qualitative so it does not pretend to know more than the data shows.",
            label: level.0,
            availableCapacity: openDays == 0 ? "No obvious open day" : "\(openDays) open day\(openDays == 1 ? "" : "s")",
            pressure: overloadedDays > 0 ? "Pressure is stacked" : tightDays > 0 ? "Pressure is visible" : "Pressure is readable",
            protectedFocus: protectedCount == 0 ? "Focus time is not explicit yet" : "\(protectedCount) important move\(protectedCount == 1 ? "" : "s")",
            recoveryMargin: openDays >= 2 ? "Recovery room exists" : openDays == 1 ? "Recovery room is narrow" : "Recovery room needs protection",
            visualState: level.1
        )
    }

    func makeGoalLifecycleRail(
        goals: [Goal],
        summaries: [GoalWeekSummary],
        evidenceByGoal: [String: [ProgressEvidence]],
        now: Date
    ) -> PlanGoalLifecycleRailState {
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
            return PlanGoalLifecycleRailSegment(
                lifecycleState: state,
                count: count,
                subtitle: lifecycleSubtitle(for: state, count: count)
            )
        }

        return PlanGoalLifecycleRailState(
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
    ) -> PlanTimelineStripState {
        let activeItems = weekContexts.prefix(5).map { context in
            PlanTimelineItemState(
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
                PlanTimelineItemState(
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
                PlanTimelineItemState(
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
                PlanTimelineItemState(
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

        return PlanTimelineStripState(
            title: "Rich Timeline",
            subtitle: items.isEmpty
                ? "No goal movement is visible yet."
                : "A compact strip of previous, active, future, and outside pressure with local source labels.",
            items: items
        )
    }

    func makeOpportunityWindows(
        weekDays: [PlanElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary]
    ) -> PlanOpportunityWindowsState {
        let windows = weekDays.compactMap { day -> PlanOpportunityWindowItem? in
            guard let window = day.openWindow else { return nil }
            let modeLabel: String
            let title: String
            switch day.level {
            case .open:
                modeLabel = window.target == nil ? "Recovery" : "Focus"
                title = window.target == nil ? "Recovery window" : "Good window for one focused move"
            case .steady:
                modeLabel = "Follow-up"
                title = "Good for follow-up"
            case .tight:
                modeLabel = "Admin"
                title = "Better for admin"
            case .fragile, .overloaded:
                return nil
            }
            return PlanOpportunityWindowItem(
                id: "window-\(day.id)",
                title: title,
                detail: window.detail,
                modeLabel: modeLabel,
                timingLabel: "\(day.weekdayLabel) \(day.dateLabel)",
                visualState: window.visualState,
                target: window.target
            )
        }

        let fallback: [PlanOpportunityWindowItem] = windows.isEmpty ? [
            PlanOpportunityWindowItem(
                id: "window-manual",
                title: missingGoalSummaries.isEmpty ? "Keep this light" : "Manual window needed",
                detail: missingGoalSummaries.isEmpty ? "No believable window is asking to be filled." : "Choose one small pocket manually before adding this goal to the week.",
                modeLabel: missingGoalSummaries.isEmpty ? "Recovery" : "Focus",
                timingLabel: "Manual",
                visualState: missingGoalSummaries.isEmpty ? .default : .warning,
                target: missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) }
            )
        ] : []

        return PlanOpportunityWindowsState(
            title: "Opportunity windows",
            subtitle: "Windows are work modes, not a calendar grid.",
            windows: Array((windows + fallback).prefix(4))
        )
    }

    func makeDecisionDebt(
        activeGoals: [Goal],
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        weekDays: [PlanElasticWeekDayState],
        openCaptures: [Capture],
        blockedDraftCount: Int,
        clarificationDraftCount: Int,
        evidenceByGoal: [String: [ProgressEvidence]],
        calendarAwareness: PlanCalendarAwarenessState
    ) -> PlanDecisionDebtState {
        var items: [PlanDecisionItemState] = []

        items += missingGoalSummaries.prefix(2).map { summary in
            PlanDecisionItemState(
                id: "decision-next-step-\(summary.goal.id)",
                title: "Needs a decision",
                detail: "\(summary.goal.title) is active but not represented in this plan window.",
                suggestion: "Give it one next step, park it, or leave it intentionally outside today.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: summary.goal.id),
                planRoute: nil
            )
        }

        if activeGoals.count > 5 {
            items.append(PlanDecisionItemState(
                id: "decision-active-goals",
                title: "Too many active goals",
                detail: "\(activeGoals.count) active goals are competing for the same planning window.",
                suggestion: "Protect the few that matter now and park the rest.",
                visualState: .warning,
                target: nil,
                planRoute: nil
            ))
        }

        if openCaptures.contains(where: { $0.status == .waiting || $0.status == .delegated }) {
            items.append(PlanDecisionItemState(
                id: "decision-waiting-captures",
                title: "Waiting item needs follow-up",
                detail: "A waiting or delegated capture is still influencing the week.",
                suggestion: "Follow up, attach it, or keep it outside the plan.",
                visualState: .warning,
                target: nil,
                planRoute: .capturesInbox
            ))
        }

        if blockedDraftCount + clarificationDraftCount > 0 {
            items.append(PlanDecisionItemState(
                id: "decision-clarify-drafts",
                title: "Clarify before planning more",
                detail: "\(blockedDraftCount + clarificationDraftCount) draft\(blockedDraftCount + clarificationDraftCount == 1 ? "" : "s") need an answer before they become real plan pressure.",
                suggestion: "Resolve the smallest missing answer first.",
                visualState: .warning,
                target: nil,
                planRoute: .capturesInbox
            ))
        }

        if let noProof = summaries.first(where: { evidenceByGoal[$0.goal.id, default: []].isEmpty && $0.contexts.isEmpty == false }) {
            items.append(PlanDecisionItemState(
                id: "decision-proof-\(noProof.goal.id)",
                title: "Proof is thin",
                detail: "\(noProof.goal.title) has work in the plan but no proof recorded yet.",
                suggestion: "Keep the next step small enough to leave evidence.",
                visualState: .default,
                target: GoalRouteTarget(goalID: noProof.goal.id),
                planRoute: nil
            ))
        }

        if calendarAwareness.canRequestCalendarRead && calendarAwareness.status != .calendarAware {
            items.append(PlanDecisionItemState(
                id: "decision-calendar-boundary",
                title: "Calendar boundary is optional",
                detail: "Manual planning still works; calendar-derived windows require your action.",
                suggestion: "Use manual availability or ask Plan to find local open windows.",
                visualState: .default,
                target: nil,
                planRoute: nil
            ))
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            items.append(PlanDecisionItemState(
                id: "decision-overloaded-week",
                title: "Clarify overloaded week",
                detail: "At least one day is carrying too much to stay believable.",
                suggestion: "Move one thing, not everything.",
                visualState: .warning,
                target: nil,
                planRoute: nil
            ))
        }

        return PlanDecisionDebtState(
            title: "Needs a decision",
            subtitle: items.isEmpty ? "No unresolved planning decision is loud right now." : "Small decisions prevent the plan from becoming a dense task manager.",
            items: Array(items.prefix(5))
        )
    }

    func makeConflictCourt(
        activeGoals: [Goal],
        summaries: [GoalWeekSummary],
        weekDays: [PlanElasticWeekDayState],
        openCaptures: [Capture],
        evidenceByGoal: [String: [ProgressEvidence]]
    ) -> PlanConflictCourtState {
        var conflicts: [PlanDecisionItemState] = []
        let protectedSummaries = summaries.filter { summary in
            summary.contexts.contains(where: { $0.blockKind == .protected || $0.blockKind == .fixed })
        }

        if protectedSummaries.count >= 2,
           let first = protectedSummaries.first {
            conflicts.append(PlanDecisionItemState(
                id: "conflict-protected-goals",
                title: "Important goals are competing",
                detail: "\(protectedSummaries.count) important goals are asking the same week to hold them.",
                suggestion: "Choose the one that must stay protected and let the other flex.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: first.goal.id),
                planRoute: nil
            ))
        }

        if let blocked = summaries.first(where: { $0.contexts.contains(where: { $0.step.state == .blocked }) }) {
            conflicts.append(PlanDecisionItemState(
                id: "conflict-blocked-\(blocked.goal.id)",
                title: "Blocked goal is still active",
                detail: "\(blocked.goal.title) has blocked work inside the current plan.",
                suggestion: "Treat this as waiting or unblock it before protecting more time.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: blocked.goal.id),
                planRoute: nil
            ))
        }

        if activeGoals.count > 5 {
            conflicts.append(PlanDecisionItemState(
                id: "conflict-active-count",
                title: "Active goals are crowded",
                detail: "\(activeGoals.count) active goals make the week negotiate too many directions.",
                suggestion: "Protect fewer goals so the plan remains believable.",
                visualState: .warning,
                target: nil,
                planRoute: nil
            ))
        }

        if openCaptures.contains(where: { $0.status == .waiting || $0.status == .delegated }) && summaries.isEmpty == false {
            conflicts.append(PlanDecisionItemState(
                id: "conflict-commitment-goal",
                title: "Follow-up is competing with goal work",
                detail: "A waiting commitment and current goal work both want attention.",
                suggestion: "Follow up first if it unlocks the move; otherwise keep it outside today.",
                visualState: .warning,
                target: nil,
                planRoute: .capturesInbox
            ))
        }

        if let thinProof = summaries.first(where: { evidenceByGoal[$0.goal.id, default: []].isEmpty && $0.contexts.count >= 2 }) {
            conflicts.append(PlanDecisionItemState(
                id: "conflict-proof-\(thinProof.goal.id)",
                title: "Work is moving without proof",
                detail: "\(thinProof.goal.title) has multiple plan blocks but no proof yet.",
                suggestion: "Make the next step receipt-friendly.",
                visualState: .default,
                target: GoalRouteTarget(goalID: thinProof.goal.id),
                planRoute: nil
            ))
        }

        if weekDays.filter({ $0.level == .open }).isEmpty && summaries.isEmpty == false {
            conflicts.append(PlanDecisionItemState(
                id: "conflict-recovery-margin",
                title: "No recovery margin",
                detail: "The plan is using every visible day.",
                suggestion: "Protect one pocket as recovery room.",
                visualState: .warning,
                target: nil,
                planRoute: nil
            ))
        }

        return PlanConflictCourtState(
            title: "Conflicts to negotiate",
            subtitle: conflicts.isEmpty ? "No visible conflict needs court right now." : "These are negotiation items, not alarms.",
            conflicts: Array(conflicts.prefix(4))
        )
    }

    func makeCalendarBoundaryContract(_ calendarAwareness: PlanCalendarAwarenessState) -> PlanCalendarBoundaryContractState {
        PlanCalendarBoundaryContractState(
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
        weekDays: [PlanElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        openCaptures: [Capture],
        pressuredGoalSummary: GoalWeekSummary?
    ) -> PlanRecoveryEntryState {
        let overloaded = weekDays.contains(where: { $0.level == .overloaded || $0.level == .fragile })
        var suggestions: [PlanDecisionItemState] = []

        if overloaded, let pressuredGoalSummary {
            suggestions.append(PlanDecisionItemState(
                id: "recovery-shrink-\(pressuredGoalSummary.goal.id)",
                title: "Shrink one step",
                detail: "\(pressuredGoalSummary.goal.title) is the clearest place to reduce pressure.",
                suggestion: "Make the next step smaller before moving anything else.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: pressuredGoalSummary.goal.id),
                planRoute: nil
            ))
        }

        if let missing = missingGoalSummaries.first {
            suggestions.append(PlanDecisionItemState(
                id: "recovery-defer-\(missing.goal.id)",
                title: "Defer what has no room",
                detail: "\(missing.goal.title) is active but outside the current week.",
                suggestion: "Leave it not today unless a real open window appears.",
                visualState: .default,
                target: GoalRouteTarget(goalID: missing.goal.id),
                planRoute: nil
            ))
        }

        if openCaptures.isEmpty == false {
            suggestions.append(PlanDecisionItemState(
                id: "recovery-captures",
                title: "Park capture pressure",
                detail: "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") can wait outside the plan.",
                suggestion: "Attach, park, or archive only after reviewing the inbox.",
                visualState: .warning,
                target: nil,
                planRoute: .capturesInbox
            ))
        }

        if suggestions.isEmpty {
            suggestions.append(PlanDecisionItemState(
                id: "recovery-protect-room",
                title: "Protect recovery room",
                detail: "The safest move is keeping an open pocket unfilled.",
                suggestion: "Recovery room is part of the plan, not a failure to optimize.",
                visualState: .success,
                target: nil,
                planRoute: nil
            ))
        }

        return PlanRecoveryEntryState(
            title: "Recovery room",
            detail: "Save the Day stays suggestion-only here. Broad reflow waits for confirmed recovery tools.",
            suggestions: Array(suggestions.prefix(3)),
            boundary: "No schedule changes happen from this card."
        )
    }

    func makeRealityReflow(
        mode: PlanDashboardMode,
        activeGoals: [Goal],
        summaries: [GoalWeekSummary],
        missingGoalSummaries: [GoalWeekSummary],
        weekDays: [PlanElasticWeekDayState],
        openCaptures: [Capture],
        blockedDraftCount: Int,
        clarificationDraftCount: Int,
        evidenceByGoal: [String: [ProgressEvidence]],
        calendarAwareness: PlanCalendarAwarenessState,
        pressuredGoalSummary: GoalWeekSummary?
    ) -> PlanRealityReflowState {
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

        let reasonKind: PlanRealityBreakReasonKind
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
            reasonDetail = "\(blockedSummary.goal.title) is still active while a planned move is blocked."
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

        return PlanRealityReflowState(
            title: reasonKind == .stillBelievable ? "Plan is still believable" : "Reality changed",
            detail: reasonKind == .stillBelievable
                ? "Nothing changed yet, and no recovery action is needed."
                : "Move one thing, not everything. These are suggestions until you confirm a change.",
            reasonKind: reasonKind,
            reasonDetail: reasonDetail,
            recommendedAdjustment: recommendedAdjustment,
            noChangeCopy: "Nothing changed yet.",
            suggestions: suggestions,
            visualState: visualState
        )
    }

    func makeReflowSuggestions(
        reasonKind: PlanRealityBreakReasonKind,
        activeGoals: [Goal],
        missingGoalSummaries: [GoalWeekSummary],
        openCaptures: [Capture],
        pressuredGoalSummary: GoalWeekSummary?,
        blockedSummary: GoalWeekSummary?,
        calendarAwareness: PlanCalendarAwarenessState
    ) -> [PlanReflowSuggestionState] {
        let targetGoal = pressuredGoalSummary?.goal ?? missingGoalSummaries.first?.goal ?? blockedSummary?.goal ?? activeGoals.first
        var suggestions: [PlanReflowSuggestionState] = []

        func append(
            _ kind: PlanReflowSuggestionKind,
            detail: String,
            impact: String,
            state: AmbitionVisualState,
            target: GoalRouteTarget? = targetGoal.map { GoalRouteTarget(goalID: $0.id) },
            planRoute: PlanRouteTarget? = nil
        ) {
            suggestions.append(PlanReflowSuggestionState(
                id: "reflow-\(kind.rawValue)-\(suggestions.count)",
                kind: kind,
                title: kind.title,
                detail: detail,
                impactLabel: impact,
                boundary: reflowBoundary(for: kind, calendarAwareness: calendarAwareness),
                visualState: state,
                target: target,
                planRoute: planRoute
            ))
        }

        switch reasonKind {
        case .stillBelievable:
            append(.keepPlanUnchanged, detail: "The current plan still has a believable path.", impact: "No change", state: .success, target: nil)
        case .lowData:
            append(.keepPlanUnchanged, detail: "Create or choose one plan item before reflowing anything.", impact: "No plan mutation", state: .default, target: nil)
        case .blockedGoal:
            append(.markWaiting, detail: "Keep the blocked work visible as waiting instead of adding more pressure.", impact: "Waiting state only after confirmation", state: .warning)
            append(.protectOneItem, detail: "Protect the one unblocked move that still matters.", impact: "Protects one item", state: .selected)
        case .waitingOnPersonOrResource:
            append(.markWaiting, detail: "Treat the dependency as waiting and keep the rest of the plan calm.", impact: "Keeps follow-up explicit", state: .warning, target: nil, planRoute: .capturesInbox)
            append(.moveLocalActionLater, detail: "Move only the local follow-up later if it is not the protected item.", impact: "Local suggestion only", state: .default, target: nil, planRoute: .capturesInbox)
        case .noNextStep:
            append(.protectOneItem, detail: "Choose one must-do and leave the rest outside today.", impact: "Protects one item", state: .selected)
            append(.parkGoal, detail: "Park the goal that has no believable next step yet.", impact: "Broad change needs confirmation", state: .warning)
        case .calendarUnavailableOrDenied:
            append(.protectOneItem, detail: "Pick the one item to protect manually.", impact: "Manual planning still works", state: .selected)
            append(.moveLocalActionLater, detail: "Move a local action later without writing to Calendar.", impact: "No calendar write", state: .default)
        case .tooManyActiveGoals:
            append(.protectOneItem, detail: "Protect the one goal that must stay active now.", impact: "Narrows focus", state: .selected)
            append(.parkGoal, detail: "Park one active goal until it has real room.", impact: "Broad change needs confirmation", state: .warning)
        case .proofMissing:
            append(.shrinkAction, detail: "Make the next step small enough to leave proof.", impact: "Receipt-ready adjustment", state: .default)
            append(.splitAction, detail: "Split the work so the first part can close cleanly.", impact: "Local draft suggestion", state: .default)
        case .urgentOutsideItem:
            append(.deferGoalOrItem, detail: "Defer the item that does not belong in this plan window.", impact: "Needs confirmation", state: .warning, target: nil, planRoute: openCaptures.isEmpty ? nil : .capturesInbox)
            append(.dropOptionalWork, detail: "Drop optional work only after you confirm it is not needed.", impact: "Destructive choice gated", state: .warning, target: nil, planRoute: openCaptures.isEmpty ? nil : .capturesInbox)
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
        reflow: PlanRealityReflowState,
        calendarAwareness: PlanCalendarAwarenessState
    ) -> PlanRecoveryGradientState {
        let kinds: [PlanReflowSuggestionKind] = [
            .protectOneItem,
            .shrinkAction,
            .splitAction,
            .moveLocalActionLater,
            .deferGoalOrItem,
            .dropOptionalWork,
            .recoverRest
        ]
        let options = kinds.enumerated().map { index, kind in
            PlanRecoveryGradientOptionState(
                id: "gradient-\(kind.rawValue)",
                order: index,
                kind: kind,
                title: kind.title,
                detail: gradientDetail(for: kind),
                boundary: reflowBoundary(for: kind, calendarAwareness: calendarAwareness),
                visualState: kind == .protectOneItem ? .selected : kind == .recoverRest ? .success : .default
            )
        }

        return PlanRecoveryGradientState(
            title: "Recovery options",
            detail: reflow.reasonKind == .stillBelievable
                ? "No recovery is needed, but the order stays ready if reality changes."
                : "Start with the least disruptive option that still makes the plan believable.",
            options: options
        )
    }

    func makeSaveTheDay(
        reflow: PlanRealityReflowState,
        weekDays: [PlanElasticWeekDayState],
        missingGoalSummaries: [GoalWeekSummary],
        pressuredGoalSummary: GoalWeekSummary?,
        openCaptures: [Capture]
    ) -> PlanSaveTheDayState {
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

        return PlanSaveTheDayState(
            title: "Save the Day in Plan",
            detail: "Plan handles the deeper recovery shape without changing anything for you.",
            oneQuestion: question,
            protectedItem: protected,
            adjustment: adjustment,
            recoveryExplanation: reflow.reasonKind == .stillBelievable
                ? "No rescue is needed; keep recovery room visible."
                : "Recovery works by protecting one thing, reducing one thing, and leaving the rest unchanged until you confirm.",
            boundary: "No silent rescheduling. No calendar write. Nothing changed yet.",
            visualState: reflow.visualState
        )
    }

    func makeReflowReceiptPreview(
        reflow: PlanRealityReflowState,
        saveTheDay: PlanSaveTheDayState
    ) -> PlanReflowReceiptPreviewState {
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

        return PlanReflowReceiptPreviewState(
            title: "Before anything changes",
            detail: "A reflow receipt preview shows the tradeoff before action, not after a silent mutation.",
            whatChanged: wouldChange,
            whatWouldNotChange: wouldNotChange,
            confirmationRequired: confirmationRequired,
            undoAvailability: undoAvailability,
            safeFailureFallback: "If you decline confirmation, Ambitions keeps the plan as-is and leaves manual planning available.",
            visualState: primary?.visualState ?? reflow.visualState
        )
    }

    func makeRecoveryMaturity(
        weekDays: [PlanElasticWeekDayState],
        openCaptures: [Capture],
        missingGoalSummaries: [GoalWeekSummary],
        calendarAwareness: PlanCalendarAwarenessState,
        realityReflow: PlanRealityReflowState,
        saveTheDay: PlanSaveTheDayState,
        receiptPreview: PlanReflowReceiptPreviewState
    ) -> PlanRecoveryMaturityState {
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
            PlanRecoveryMaturitySignalState(
                id: "fit",
                title: "Plan fit",
                detail: overloadedDays > 0
                    ? "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") need relief before the week widens."
                    : saveTheDay.recoveryExplanation,
                statusLabel: fitLabel,
                boundaryLabel: "Suggests one smaller move",
                visualState: signalState
            ),
            PlanRecoveryMaturitySignalState(
                id: "waiting-commitments",
                title: "Waiting and commitments",
                detail: waitingDetail,
                statusLabel: waitingCount + commitmentCount == 0 ? "Quiet" : "Visible",
                boundaryLabel: "No silent routing",
                visualState: waitingCount + commitmentCount == 0 ? .default : .warning
            ),
            PlanRecoveryMaturitySignalState(
                id: "social-load",
                title: "Social load",
                detail: socialDetail,
                statusLabel: socialWaitingCount == 0 ? "Manual" : "Private",
                boundaryLabel: "No inference without you",
                visualState: socialWaitingCount == 0 ? .default : .selected
            ),
            PlanRecoveryMaturitySignalState(
                id: "receipt",
                title: "Receipt and undo",
                detail: receiptPreview.safeFailureFallback,
                statusLabel: receiptPreview.confirmationRequired,
                boundaryLabel: receiptPreview.undoAvailability,
                visualState: receiptPreview.visualState
            )
        ]

        return PlanRecoveryMaturityState(
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
        for kind: PlanReflowSuggestionKind,
        calendarAwareness: PlanCalendarAwarenessState
    ) -> PlanReflowBoundaryState {
        switch kind {
        case .protectOneItem, .shrinkAction, .splitAction, .recoverRest, .keepPlanUnchanged:
            return PlanReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .notRequired,
                undoAvailability: .availableLocal,
                safetyLabel: "Safe/local"
            )
        case .moveLocalActionLater, .deferGoalOrItem, .parkGoal, .markWaiting:
            return PlanReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .requiredForBroadReflow,
                undoAvailability: .requiresConfirmation,
                safetyLabel: "Confirm first"
            )
        case .dropOptionalWork:
            return PlanReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .requiredForDestructiveChange,
                undoAvailability: .unsafe,
                safetyLabel: "Confirm drop"
            )
        case .askForConfirmation:
            return PlanReflowBoundaryState(
                actionKind: calendarAwareness.status == .calendarAware ? .writeCalendarBlock : .changePlanWindow,
                confirmationRequirement: calendarAwareness.status == .calendarAware ? .requiredForExternalEffect : .requiredForBroadReflow,
                undoAvailability: .notSupportedYet,
                safetyLabel: calendarAwareness.status == .calendarAware ? "Plan action required" : "Confirm first"
            )
        }
    }

    func gradientDetail(for kind: PlanReflowSuggestionKind) -> String {
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

    func goalShapingItems(summaries: [GoalWeekSummary]) -> [PlanGoalShapingItem] {
        summaries
            .map { summary in
                let represented = summary.contexts.isEmpty == false
                let nextMove = summary.contexts.first?.step.summary ?? summary.contexts.first?.step.actionability.fallbackMicroStep ?? "Add one believable move."
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
                    attentionReason = "Recent friction suggests the current move is heavier than the week can comfortably carry."
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

                return PlanGoalShapingItem(
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
        weekDays: [PlanElasticWeekDayState],
        mode: PlanDashboardMode
    ) -> PlanBelievabilityState {
        guard mode == .active else {
            return PlanBelievabilityState(
                title: "The week is open",
                detail: "No active goals or captures are pressing for structure yet.",
                label: "Open",
                supportLabel: "This is a real state, not missing data.",
                visualState: .default
            )
        }

        if blockedCount + clarificationCount > 0 {
            return PlanBelievabilityState(
                title: "The week is waiting on reality",
                detail: "Open questions or blockers make the current shape less believable than it looks.",
                label: "Needs clarity",
                supportLabel: "Clarify before adding more commitment.",
                visualState: .warning
            )
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            return PlanBelievabilityState(
                title: "The week is overloaded",
                detail: "At least one day is carrying more than the current structure can explain calmly.",
                label: "Overloaded",
                supportLabel: "Lighten the loudest lane first.",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .notBelievable || $0.feasibilityLevel == .fragile }) {
            return PlanBelievabilityState(
                title: "The week is fragile",
                detail: "Existing plan evaluations are warning that current commitments need gentler scope.",
                label: "Fragile",
                supportLabel: "Protect what is believable and soften the rest.",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .tight }) || openCaptureCount > 0 || weekDays.contains(where: { $0.level == .tight }) {
            return PlanBelievabilityState(
                title: "The week is believable but tight",
                detail: "The structure can hold, but room is already limited and pressure is visible.",
                label: "Tight",
                supportLabel: "Patch with restraint instead of adding density.",
                visualState: .selected
            )
        }

        return PlanBelievabilityState(
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

    func blockKind(for timing: GoalTiming) -> PlanWeekBlockKind {
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

    func loadWeight(for kind: PlanWeekBlockKind, visualState: AmbitionVisualState) -> Double {
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

    func dayIntensity(for level: PlanWeekPressureLevel, blockCount: Int) -> Double {
        let base: Double = switch level {
        case .open: 0.48
        case .steady: 0.66
        case .tight: 0.84
        case .fragile: 0.92
        case .overloaded: 1.0
        }
        return min(base + (Double(blockCount) * 0.04), 1.0)
    }

    func roomLabel(for level: PlanWeekPressureLevel, remainingCapacity: Double, contextCount: Int) -> String {
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
        level: PlanWeekPressureLevel,
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

    func pressureRank(for level: PlanWeekPressureLevel) -> Int {
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
