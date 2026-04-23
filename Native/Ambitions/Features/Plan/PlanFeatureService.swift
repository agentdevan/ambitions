import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedPlanService: PlanServicing {
    let repositories: AppRepositories

    func loadPlanDashboard(now: Date) async throws -> PlanDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot, now: now)
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

    func makeDashboard(snapshot: Snapshot, now: Date) -> PlanDashboard {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let openCaptures = snapshot.captures.filter { $0.status != .archived }
        let blockedDrafts = snapshot.drafts.filter { $0.latestResultKind == .blocked }
        let clarificationDrafts = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }
        let activeGoalSummaries = makeGoalSummaries(goals: activeGoals, feedback: snapshot.feedback, now: now)
        let weekContexts = activeGoalSummaries.flatMap(\.contexts)
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
        let primaryAction = makePrimaryAction(
            mode: mode,
            posture: posture,
            missingGoalSummary: missingGoalSummaries.first,
            pressuredGoalSummary: mostPressuredGoal,
            openCaptureCount: openCaptures.count,
            weekDays: weekDays
        )

        return PlanDashboard(
            mode: mode,
            timeframeLabel: timeframeLabel(now: now),
            hero: hero,
            primaryAction: primaryAction,
            pressureScrubber: pressureScrubber,
            weekDays: weekDays,
            believability: believability,
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
                    title: "Routines and habits",
                    detail: habitGoals.isEmpty
                        ? "No repeatable loops are shaping the week yet."
                        : "Review the repeatable loops that can steady or crowd the week.",
                    valueLabel: "\(habitGoals.count)",
                    icon: AppTab.habits.systemImage,
                    visualState: habitGoals.isEmpty ? .default : .selected
                )
            ],
            emptyTitle: mode == .empty ? "No weekly pressure yet" : nil,
            emptyMessage: mode == .empty ? "As soon as goals, captures, or routines create real constraints, Plan will show where the week still has room." : nil
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
            detail: "Not every open pocket needs to be filled. Protected slack keeps the week believable.",
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
            eyebrow: "Reality Model",
            title: "How this week holds together",
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
                    pressureLabel = "Protected"
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
        case .overloaded: 3
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
