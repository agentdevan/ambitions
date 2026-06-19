import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeTimeSurfaceState(snapshot: RepositoryBackedTimeService.Snapshot, now: Date, calendarAwareness: TimeCalendarAwarenessState) -> TimeSurfaceState {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let openCaptures = snapshot.captures.filter { $0.status != .archived }
        let blockedDrafts = snapshot.drafts.filter { $0.latestResultKind == .blocked }
        let clarificationDrafts = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }
        let activeGoalSummaries = makeGoalSummaries(goals: activeGoals, feedback: snapshot.feedback, now: now)
        let weekContexts = activeGoalSummaries.flatMap(\.contexts)
        let evidenceByGoal = Dictionary(grouping: snapshot.evidence, by: \.goalID)
        let habitGoals = activeGoals.filter { goal in
            guard let step = TimeRitualGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || TimeRitualGoalSemantics.isRitualLike(goal: goal, step: step)
        }
        let mode: TimeSurfaceMode = activeGoals.isEmpty && snapshot.drafts.isEmpty && openCaptures.isEmpty ? .empty : .active
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

        return TimeSurfaceState(
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
                    id: "time-rituals",
                    title: "Rituals",
                    detail: habitGoals.isEmpty
                        ? "No repeatable loops are shaping the week yet."
                        : "Review the repeatable loops that can steady or crowd the week.",
                    valueLabel: "\(habitGoals.count)",
                    icon: "repeat",
                    visualState: habitGoals.isEmpty ? .default : .selected,
                    timeRoute: .rituals
                ),
                TimeSecondaryDestination(
                    id: "time-held-input",
                    title: "Open Capture composer",
                    detail: openCaptures.isEmpty
                        ? "No open captures are pushing on the week right now."
                        : "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") still need to be absorbed, attached, or intentionally parked.",
                    valueLabel: "\(openCaptures.count)",
                    icon: "square.and.pencil",
                    visualState: openCaptures.isEmpty ? .default : .warning,
                    timeRoute: nil,
                    interactionIntent: .openGlobalCapture
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

}
