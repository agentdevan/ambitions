import AmbitionsDesignSystem
import Foundation

struct RepositoryBackedTodayService: TodayServicing {
    let repositories: AppRepositories
    let adaptationService: GoalEngineAdaptationService
    let rescheduleEngine: any GoalRescheduling
    let captureService: any CaptureServicing
    let calendarRemindersService: any CalendarRemindersServicing
    let ritualService: RitualOrchestrationService
    let learningService: LearningAnticipationService
    let sharedLifeService: SharedLifeCoordinationService
    let selector: PlanningNextStepSelector
    let explainabilityProjector: any GoalExplainabilityProjecting
    let goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)?

    init(
        repositories: AppRepositories,
        adaptationService: GoalEngineAdaptationService = GoalEngineAdaptationService(),
        rescheduleEngine: any GoalRescheduling = RescheduleEngine(),
        captureService: (any CaptureServicing)? = nil,
        calendarRemindersService: (any CalendarRemindersServicing)? = nil,
        ritualService: RitualOrchestrationService = RitualOrchestrationService(),
        learningService: LearningAnticipationService = LearningAnticipationService(),
        sharedLifeService: SharedLifeCoordinationService = SharedLifeCoordinationService(),
        energyFitService: any GoalEnergyFitEvaluating = DefaultGoalEnergyFitService(),
        energyLearningService: any GoalEnergyLearning = DefaultGoalEnergyLearningService(),
        selector: PlanningNextStepSelector? = nil,
        explainabilityProjector: any GoalExplainabilityProjecting = DefaultGoalExplainabilityProjector(),
        goalIntelligenceService: (any RuntimeGoalIntelligenceServicing)? = nil
    ) {
        self.repositories = repositories
        self.adaptationService = adaptationService
        self.rescheduleEngine = rescheduleEngine
        self.captureService = captureService ?? DefaultCaptureService(repository: repositories.captures)
        self.calendarRemindersService = calendarRemindersService ?? StubCalendarRemindersService()
        self.ritualService = ritualService
        self.learningService = learningService
        self.sharedLifeService = sharedLifeService
        self.selector = selector ?? PlanningNextStepSelector(
            learningService: learningService,
            sharedLifeService: sharedLifeService,
            energyFitService: energyFitService,
            energyLearningService: energyLearningService
        )
        self.explainabilityProjector = explainabilityProjector
        self.goalIntelligenceService = goalIntelligenceService
    }

    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        let snapshot = try await loadSnapshot()
        return makeExperience(snapshot: snapshot, userDisplayName: userDisplayName, now: now)
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        switch action.kind {
        case .openDetail:
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Opening plan context",
                    body: "Today is handing off to the same goal context used for replanning, evidence, and support decisions.",
                    state: .selected
                )
            )
        case .askForHelp:
            if action.target.goalID != nil, action.target.stepID != nil {
                return try await performFeedbackAction(action, now: now)
            }
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Support context captured",
                    body: "Ambitions will keep the blocked or heavy step visible so the next pass can shrink it, explain it, or route you into the fuller goal context.",
                    state: .warning
                )
            )
        case .dismissCelebration:
            return TodayActionResponse(message: nil)
        default:
            return try await performFeedbackAction(action, now: now)
        }
    }
}

struct StubTodayService: TodayServicing {
    let experience: TodayExperience
    let actionResponse: TodayActionResponse?

    init(experience: TodayExperience, actionResponse: TodayActionResponse? = nil) {
        self.experience = experience
        self.actionResponse = actionResponse
    }

    func loadTodayExperience(userDisplayName: String, now: Date) async throws -> TodayExperience {
        experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        actionResponse ?? TodayActionResponse(message: nil)
    }
}

private extension RepositoryBackedTodayService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let captures: [Capture]
        let appState: AppStateSnapshot
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let captures = repositories.captures.listCaptures()
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            captures: captures,
            appState: appState
        )
    }

    func makeExperience(snapshot: Snapshot, userDisplayName: String, now: Date) -> TodayExperience {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let learningSnapshot = learningService.buildSnapshot(
            goals: activeGoals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            now: now
        )
        let sharedLifeSnapshot = sharedLifeService.buildSnapshot(
            goals: activeGoals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            now: now
        )
        let draftsByGoalID: [String: PersistedGoalDraft] = Dictionary(uniqueKeysWithValues: snapshot.drafts.compactMap { draft in
            guard let plannedGoalID = draft.plannedGoalID else { return nil }
            return (plannedGoalID, draft)
        })
        let energyModelsByGoalID = draftsByGoalID.compactMapValues(\.metadata?.energyModel)
        let rankedSelections = selector.rankedSelections(
            goals: activeGoals,
            evidence: snapshot.evidence,
            feedback: snapshot.feedback,
            canonicalEnergyModelsByGoalID: energyModelsByGoalID,
            now: now
        )
        let allSteps = activeGoals.flatMap { $0.plan?.sections.flatMap(\.steps) ?? [] }
        let actionableSteps = rankedSelections.map(\.step)

        let clarificationDrafts = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }
        let blockedDrafts = snapshot.drafts.filter { $0.latestResultKind == .blocked }

        let completedSteps = allSteps.filter { $0.state == .completed }.count
        let totalSteps = allSteps.count
        let completedToday = todayCompletionTitles(snapshot: snapshot, now: now)
        let frictionCount = snapshot.feedback.filter { event in
            switch event {
            case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
                return true
            default:
                return false
            }
        }.count

        let mode: TodayExperienceMode = {
            if activeGoals.isEmpty && snapshot.drafts.isEmpty { return .empty }
            if snapshot.appState.lastSeedVersion == DemoSeedPipeline.seedVersion { return .seeded }
            return .active
        }()

        return TodayExperience(
            mode: mode,
            header: makeHeader(
                mode: mode,
                userDisplayName: userDisplayName,
                now: now,
                activeGoals: activeGoals,
                actionableCount: actionableSteps.count,
                clarificationCount: clarificationDrafts.count,
                blockedCount: blockedDrafts.count
            ),
            ritual: makeRitual(snapshot: snapshot, activeGoals: activeGoals, learningSnapshot: learningSnapshot, sharedLifeSnapshot: sharedLifeSnapshot, now: now),
            dailyTargets: makeDailyTargets(
                mode: mode,
                goals: activeGoals,
                actionableSteps: actionableSteps,
                draftsByGoalID: draftsByGoalID,
                completion: (completedSteps, totalSteps)
            ),
            focus: makeFocus(
                clarificationDrafts: clarificationDrafts,
                blockedDrafts: blockedDrafts,
                rankedSelections: rankedSelections,
                actionableSteps: actionableSteps,
                goals: activeGoals,
                draftsByGoalID: draftsByGoalID,
                feedback: snapshot.feedback,
                evidence: snapshot.evidence
            ),
            freeTime: makeFreeTime(
                goals: activeGoals,
                actionableSteps: actionableSteps,
                draftsByGoalID: draftsByGoalID
            ),
            milestone: makeMilestone(goals: activeGoals, draftsByGoalID: draftsByGoalID),
            momentum: makeMomentum(
                activeGoals: activeGoals,
                evidence: snapshot.evidence,
                completedToday: completedToday.count,
                frictionCount: frictionCount
            ),
            celebration: completedToday.isEmpty ? nil : TodayCelebrationState(
                title: completedToday.count == 1 ? "One clean win landed" : "Momentum is already real",
                subtitle: completedToday.count == 1
                    ? "Today has a visible completion on the board."
                    : "Multiple deliberate moves are already done today.",
                achievements: completedToday,
                actions: [
                    TodayInlineAction(
                        kind: .dismissCelebration,
                        title: "Keep going",
                        systemImage: "arrow.right",
                        state: .celebration,
                        target: TodayActionTarget()
                    )
                ]
            ),
            quickCapture: makeQuickCapture(goal: activeGoals.first, step: actionableSteps.first),
            reflection: makeReflection(
                now: now,
                completedToday: completedToday,
                activeGoals: activeGoals,
                feedback: snapshot.feedback
            )
        )
    }

    func makeRitual(snapshot: Snapshot, activeGoals: [Goal], learningSnapshot: LearningAnticipationSnapshot, sharedLifeSnapshot: SharedLifeCoordinationSnapshot, now: Date) -> TodayRitualLoopState {
        let plan = ritualService.makePlan(
            input: RitualOrchestrationInput(
                goals: activeGoals,
                captures: snapshot.captures,
                evidence: snapshot.evidence,
                feedback: snapshot.feedback,
                learningSnapshot: learningSnapshot,
                sharedLifeSnapshot: sharedLifeSnapshot,
                now: now
            )
        )
        let recommendation = plan.activeRecommendation
        return TodayRitualLoopState(
            kind: recommendation.kind,
            title: recommendation.title,
            subtitle: recommendation.body,
            thesis: recommendation.kind == .weeklyReset ? plan.weekThesis : plan.dayThesis,
            stateLabel: recommendation.stateLabel,
            signalLabels: ritualSignalLabels(from: plan.signalSummary),
            action: recommendation.primaryAction.map(todayAction(from:))
        )
    }

    func todayAction(from action: RitualActionReference) -> TodayInlineAction {
        let kind: TodayActionKind
        let title: String
        let systemImage: String
        let state: AmbitionVisualState
        switch action.kind {
        case .complete:
            kind = .complete
            title = "Complete"
            systemImage = "checkmark"
            state = .success
        case .delay:
            kind = .delay
            title = "Delay"
            systemImage = "clock.arrow.circlepath"
            state = .default
        case .askForSmallerStep:
            kind = .askForSmallerStep
            title = "Smaller step"
            systemImage = "scissors"
            state = .selected
        case .quickLog:
            kind = .quickLog
            title = "Quick log"
            systemImage = "square.and.pencil"
            state = .default
        case .openDetail:
            kind = .openDetail
            title = "Open detail"
            systemImage = "arrow.right.circle"
            state = .default
        }
        return TodayInlineAction(
            kind: kind,
            title: title,
            systemImage: systemImage,
            state: state,
            target: TodayActionTarget(goalID: action.goalID, stepID: action.stepID, draftID: action.draftID)
        )
    }

    func ritualSignalLabels(from summary: RitualSignalSummary) -> [String] {
        var labels = [
            "\(summary.activeGoalCount) active goal\(summary.activeGoalCount == 1 ? "" : "s")",
            "\(summary.completedTodayCount) done today"
        ]
        if summary.frictionTodayCount > 0 {
            labels.append("\(summary.frictionTodayCount) friction signal\(summary.frictionTodayCount == 1 ? "" : "s")")
        }
        if summary.openCaptureCount > 0 {
            labels.append("\(summary.openCaptureCount) open capture\(summary.openCaptureCount == 1 ? "" : "s")")
        }
        labels.append("\(summary.pressureLevel.rawValue) pressure")
        return labels
    }

    func performFeedbackAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        guard let goalID = action.target.goalID, let stepID = action.target.stepID else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Action not available",
                    body: "That panel does not currently point at a persisted goal step.",
                    state: .warning
                )
            )
        }

        guard var goal = try await repositories.goals.goal(id: goalID),
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Step moved",
                    body: "That step is no longer available in the current native store snapshot.",
                    state: .warning
                )
            )
        }

        let feedbackHistory = try await repositories.feedback.listEvents(goalID: goalID)
        let drafts = try await repositories.drafts.listDrafts()
        let draft = drafts.first(where: { $0.plannedGoalID == goalID })
        let timestamp = Self.iso.string(from: now)
        let base = GoalFeedbackEventBase(
            id: "today-\(action.kind.rawValue)-\(UUID().uuidString)",
            stepID: stepID,
            occurredAt: timestamp,
            note: note(for: action.kind, step: selectedStep)
        )

        var events = feedbackHistory
        var message: TodayInlineMessage?

        switch action.kind {
        case .complete:
            events.append(.completed(base: base, actualDuration: 25, effortLevel: .medium, confidenceDelta: 0.08))
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "evidence-\(UUID().uuidString)",
                    goalID: goalID,
                    stepID: stepID,
                    evidenceKind: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) ? .habitCompletion : .stepCompleted,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.18,
                    confidenceDelta: 0.08,
                    minutesInvested: 25,
                    note: "Completed from Today."
                )
            ])
            if HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) {
                let cadenceDays = HabitGoalSemantics.cadenceDays(goal: goal, step: selectedStep)
                goal = update(goal: goal, stepID: stepID) { step in
                    Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: HabitGoalSemantics.advancedTiming(from: step.timing, now: now, cadenceDays: cadenceDays),
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
            } else {
                goal = update(goal: goal, stepID: stepID) { step in
                    Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: .completed,
                        owner: step.owner,
                        timing: step.timing,
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
            }
            try await repositories.goals.saveGoals([goal])
            message = TodayInlineMessage(
                title: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) ? "Habit logged" : "Completion recorded",
                body: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep)
                    ? "\"\(selectedStep.title)\" was recorded for today and kept alive as an ongoing rhythm."
                    : "\"\(selectedStep.title)\" is now reflected in native evidence and feedback.",
                state: .success
            )
        case .delay:
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            let adjustment = decision?.timingAdjustment ?? .laterToday
            events.append(.delayed(base: base, timingAdjustment: adjustment, date: decision?.suggestedTime))
            if let smaller = decision?.smallerStep {
                events.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "today-reschedule-smaller-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            goal = update(goal: goal, stepID: stepID) { step in
                let shifted = shiftedTiming(for: step.timing, now: now, adjustment: adjustment)
                return Step(
                    id: step.id,
                    sectionID: step.sectionID,
                    title: step.title,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary,
                    type: step.type,
                    state: step.state,
                    owner: step.owner,
                    timing: shifted,
                    dependencyStepIDs: step.dependencyStepIDs,
                    isOptional: step.isOptional,
                    isRepeatable: step.isRepeatable,
                    evidenceRequired: step.evidenceRequired,
                    successSignals: step.successSignals,
                    actionability: step.actionability
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " It was deferred with a calmer retry window."
            }()
            message = TodayInlineMessage(
                title: "Pressure softened",
                body: "The step stays in play without pretending it must happen right now.\(deferLine)",
                state: .selected
            )
        case .skip:
            events.append(.skipped(base: base, reasonCode: .notNow))
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            if let adjustment = decision?.timingAdjustment {
                events.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "today-skip-reschedule-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            if let smaller = decision?.smallerStep {
                events.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "today-skip-smaller-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            goal = update(goal: goal, stepID: stepID) { step in
                let shifted = shiftedTiming(for: step.timing, now: now, adjustment: decision?.timingAdjustment ?? .laterThisWeek)
                return Step(
                    id: step.id,
                    sectionID: step.sectionID,
                    title: step.title,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary,
                    type: step.type,
                    state: step.state,
                    owner: step.owner,
                    timing: shifted,
                    dependencyStepIDs: step.dependencyStepIDs,
                    isOptional: step.isOptional,
                    isRepeatable: step.isRepeatable,
                    evidenceRequired: step.evidenceRequired,
                    successSignals: step.successSignals,
                    actionability: step.actionability
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " The next attempt was deferred to prevent churn."
            }()
            message = TodayInlineMessage(
                title: "Moved out of today",
                body: "The step was skipped without turning it into a failure state.\(deferLine)",
                state: .warning
            )
        case .markNotRelevant:
            events.append(.notRelevant(base: base))
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            goal = update(goal: goal, stepID: stepID) { step in
                Step(
                    id: step.id,
                    sectionID: step.sectionID,
                    title: step.title,
                    summary: step.summary,
                    type: step.type,
                    state: .cancelled,
                    owner: step.owner,
                    timing: step.timing,
                    dependencyStepIDs: step.dependencyStepIDs,
                    isOptional: step.isOptional,
                    isRepeatable: step.isRepeatable,
                    evidenceRequired: step.evidenceRequired,
                    successSignals: step.successSignals,
                    actionability: step.actionability
                )
            }
            try await repositories.goals.saveGoals([goal])
            message = TodayInlineMessage(
                title: "Relevance captured",
                body: "That step is out of the active queue until goal detail adds a fuller replanning flow.",
                state: .warning
            )
        case .quickLog:
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "evidence-\(UUID().uuidString)",
                    goalID: goalID,
                    stepID: stepID,
                    evidenceKind: .sessionLogged,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.08,
                    confidenceDelta: 0.04,
                    minutesInvested: 10,
                    note: "Quick log from Today."
                )
            ])
            _ = try await captureService.createCapture(
                CreateCaptureRequest(
                    rawText: "Quick log for \"\(selectedStep.title)\".",
                    sourceType: .todayQuickCapture,
                    linkedGoalID: goalID
                ),
                now: now
            )
            message = TodayInlineMessage(
                title: "Signal saved",
                body: "Today recorded a quick bit of evidence without creating fake urgency.",
                state: .success
            )
        case .createReminder:
            let selection = nextStepSchedulingSelection(goal: goal, step: selectedStep)
            let authorization = await calendarRemindersService.requestAuthorizationIfNeeded(for: .reminders)
            guard authorization.canWrite else {
                message = TodayInlineMessage(
                    title: "Reminders permission needed",
                    body: "Enable Reminders access to create next-step reminders from Ambitions.",
                    state: .warning
                )
                break
            }

            _ = try await calendarRemindersService.createReminder(for: selection, now: now)
            message = TodayInlineMessage(
                title: "Reminder created",
                body: "\"\(selectedStep.title)\" was added to Reminders.",
                state: .success
            )
        case .createCalendarEvent:
            let selection = nextStepSchedulingSelection(goal: goal, step: selectedStep)
            let authorization = await calendarRemindersService.requestAuthorizationIfNeeded(for: .calendarEvents)
            guard authorization.canWrite else {
                message = TodayInlineMessage(
                    title: "Calendar permission needed",
                    body: "Enable Calendar access to add next-step events from Ambitions.",
                    state: .warning
                )
                break
            }

            let conflictReport = await calendarRemindersService.detectConflicts(for: selection, durationMinutes: 45, now: now)
            let event = try await calendarRemindersService.createCalendarEvent(for: selection, durationMinutes: 45, now: now)
            message = TodayInlineMessage(
                title: "Calendar event created",
                body: calendarEventMessageBody(for: event.title, report: conflictReport),
                state: .success
            )
        case .askForSmallerStep:
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            events.append(.askedForSmallerVersion(base: base))
            if let adjustment = decision?.timingAdjustment {
                events.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "today-smaller-reschedule-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            let adjustment = adjustmentPayload(draft: draft, goal: goal, step: selectedStep, history: events)
            let replacement = adjustment.flatMap { smallerSummary(from: $0.recommendation, step: selectedStep) }
                ?? decision?.recoverySummary
                ?? decision?.smallerStep?.summary
                ?? selectedStep.actionability.fallbackMicroStep
            if replacement.isEmpty == false {
                goal = update(goal: goal, stepID: stepID) { step in
                    let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                    return Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: replacement,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: timing,
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
                try await repositories.goals.saveGoals([goal])
                message = TodayInlineMessage(
                    title: "Smaller version ready",
                    body: decision?.deferRecommendation.indicatesDeferral == true
                        ? "\(replacement)\n\nThe next attempt was deferred to keep the ask realistic."
                        : replacement,
                    state: .selected
                )
            } else {
                message = TodayInlineMessage(
                    title: "Smaller version ready",
                    body: selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            }
        case .askForHelp:
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            events.append(.confused(base: base, confusionType: .unclearAction))
            if let smaller = decision?.smallerStep {
                events.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "today-help-smaller-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            if let adjustment = decision?.timingAdjustment {
                events.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "today-help-delay-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            if let decision {
                goal = update(goal: goal, stepID: stepID) { step in
                    let shifted = decision.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                    return Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: decision.recoverySummary ?? decision.smallerStep?.summary ?? step.summary,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: shifted,
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
                try await repositories.goals.saveGoals([goal])
            }
            message = TodayInlineMessage(
                title: "A calmer next move is ready",
                body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                state: .selected
            )
        case .askWhyThisMatters:
            events.append(.askedWhyThisMatters(base: base))
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            let adjustment = adjustmentPayload(draft: draft, goal: goal, step: selectedStep, history: events)
            let explanation = try await goalIntelligenceService?.loadContext(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: goalID, draftID: draft?.id),
                    primaryStepID: selectedStep.id,
                    includeWhyNow: true
                ),
                now: now
            )?.explainability.whyThis.compactSummary ?? draft?.metadata.map { metadata in
                explainabilityProjector.makeState(
                    metadata: metadata,
                    applicableSignals: nil,
                    primaryStepID: selectedStep.id,
                    whyNow: learningService.learnedStepInsight(
                        goal: goal,
                        step: selectedStep,
                        snapshot: learningService.buildSnapshot(
                            goals: [goal],
                            evidence: [],
                            feedback: events,
                            now: now
                        ),
                        now: now
                    ).whyNow
                ).whyThis.compactSummary
            }
                ?? adjustment?.explanationHook?.explanation
                ?? draft.map { createWhyThisMattersExplanation(draft: $0.draft, step: selectedStep).explanation }
                ?? "\(selectedStep.title) matters because it moves \(goal.title.lowercased()) forward with visible evidence."
            message = TodayInlineMessage(
                title: "Why this matters",
                body: explanation,
                state: .selected
            )
        case .openDetail, .dismissCelebration:
            break
        }

        return TodayActionResponse(message: message)
    }

    func adjustmentPayload(
        draft: PersistedGoalDraft?,
        goal: Goal,
        step: Step,
        history: [GoalFeedbackEvent]
    ) -> GoalAdaptivePlanAdjustmentPayload? {
        guard let draft else { return nil }
        guard let currentResult = adaptiveResult(from: draft, goal: goal) else { return nil }

        return adaptationService.recommendPlanAdjustment(
            input: GoalAdaptivePlanInput(
                currentResult: currentResult,
                selectedStep: step,
                feedbackHistory: history
            )
        )
    }

    func adaptiveResult(from draft: PersistedGoalDraft, goal: Goal) -> GoalAdaptivePlanResult? {
        guard let plan = goal.plan ?? draft.stagedPlan else { return nil }

        switch draft.latestResultKind {
        case .planned:
            guard let metadata = draft.metadata else { return nil }
            return .planned(
                GoalPlannedResult(
                    draft: draft.draft,
                    plan: plan,
                    lint: plan.lint,
                    metadata: metadata
                )
            )
        case .starterPlanned:
            guard let clarification = draft.clarification, let metadata = draft.metadata else { return nil }
            return .starterPlanned(
                GoalStarterPlannedResult(
                    draft: draft.draft,
                    plan: plan,
                    lint: plan.lint,
                    assumptions: draft.assumptions,
                    clarification: clarification,
                    metadata: metadata
                )
            )
        case .clarificationRequired, .blocked, .none:
            return nil
        }
    }

    func makeHeader(
        mode: TodayExperienceMode,
        userDisplayName: String,
        now: Date,
        activeGoals: [Goal],
        actionableCount: Int,
        clarificationCount: Int,
        blockedCount: Int
    ) -> TodayHeaderState {
        let hour = Calendar.current.component(.hour, from: now)
        let trimmedName = userDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let greeting: String
        switch hour {
        case 0..<5: greeting = trimmedName.isEmpty ? "Still up" : "Still up, \(trimmedName)"
        case 5..<12: greeting = trimmedName.isEmpty ? "Good morning" : "Good morning, \(trimmedName)"
        case 12..<17: greeting = trimmedName.isEmpty ? "Good afternoon" : "Good afternoon, \(trimmedName)"
        default: greeting = trimmedName.isEmpty ? "Good evening" : "Good evening, \(trimmedName)"
        }

        let subtitle: String
        switch mode {
        case .empty:
            subtitle = "Today becomes useful as soon as one real goal or draft exists. Nothing here is faking urgency."
        case .seeded:
            subtitle = "Today is already reading real native plan, evidence, and feedback records, with starter data standing in until personal history takes over."
        case .active:
            subtitle = "Today is reading live native goals, drafts, evidence, and feedback to decide what deserves attention now."
        }

        var pills = [
            TodayPillState(id: "goals", title: "\(activeGoals.count) active goals", icon: "scope", state: .selected),
            TodayPillState(id: "steps", title: "\(actionableCount) live moves", icon: "bolt.fill", state: .default)
        ]
        if clarificationCount > 0 {
            pills.append(TodayPillState(id: "clarify", title: "\(clarificationCount) question\(clarificationCount == 1 ? "" : "s")", icon: "questionmark.circle", state: .warning))
        }
        if blockedCount > 0 {
            pills.append(TodayPillState(id: "blocked", title: "\(blockedCount) blocker\(blockedCount == 1 ? "" : "s")", icon: "exclamationmark.triangle", state: .warning))
        }
        if mode == .seeded {
            pills.append(TodayPillState(id: "seeded", title: "Starter data ready", icon: "sparkles", state: .celebration))
        }

        return TodayHeaderState(
            greeting: greeting,
            title: "Today",
            subtitle: subtitle,
            contextPills: pills
        )
    }

    func makeDailyTargets(
        mode: TodayExperienceMode,
        goals: [Goal],
        actionableSteps: [Step],
        draftsByGoalID: [String: PersistedGoalDraft],
        completion: (done: Int, total: Int)
    ) -> TodayDailyTargetsState {
        let completionLabel: String
        if completion.total == 0 {
            completionLabel = "No fake completion bars"
        } else {
            completionLabel = "\(Int((Double(completion.done) / Double(max(completion.total, 1))) * 100))% through visible plan work"
        }

        let items = actionableSteps.prefix(3).compactMap { step -> TodayTargetItem? in
            guard let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
                return nil
            }
            let draft = draftsByGoalID[goal.id]
            let state: AmbitionVisualState = draft?.latestResultKind == .starterPlanned ? .selected : .default
            return TodayTargetItem(
                id: step.id,
                title: step.title,
                subtitle: goal.title,
                timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                statusLabel: statusLabel(for: step, draft: draft),
                progress: progressValue(for: step),
                state: state,
                primaryAction: TodayInlineAction(
                    kind: .complete,
                    title: "Complete",
                    systemImage: "checkmark",
                    state: .success,
                    target: TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
                ),
                secondaryAction: TodayInlineAction(
                    kind: .delay,
                    title: "Delay",
                    systemImage: "clock.arrow.circlepath",
                    state: .default,
                    target: TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
                )
            )
        }

        return TodayDailyTargetsState(
            title: mode == .empty ? "No live targets yet" : "Daily targets",
            subtitle: mode == .empty
                ? "Once a goal exists, Today will surface only the few moves worth acting on."
                : "This is the smallest useful set of live work from the native planner and repository layers.",
            completionLabel: completionLabel,
            items: items,
            emptyMessage: items.isEmpty ? "Import, seed, or create a goal and Today will immediately fill from persisted steps and draft states." : nil
        )
    }

    func makeFocus(
        clarificationDrafts: [PersistedGoalDraft],
        blockedDrafts: [PersistedGoalDraft],
        rankedSelections: [PlanningNextStepSelection],
        actionableSteps: [Step],
        goals: [Goal],
        draftsByGoalID: [String: PersistedGoalDraft],
        feedback: [GoalFeedbackEvent],
        evidence: [ProgressEvidence]
    ) -> TodayFocusState {
        if let draft = clarificationDrafts.first, let clarification = draft.clarification {
            return .clarification(
                TodayFocusClarificationState(
                    title: draft.draft.title,
                    subtitle: "A short clarification here will unlock a better plan than pretending certainty.",
                    questions: clarification.questions.prefix(2).map {
                        TodayClarificationQuestionState(
                            id: $0.id,
                            prompt: $0.prompt,
                            rationale: $0.rationale,
                            gentleDefault: $0.skipSafeDefault
                        )
                    },
                    actions: [
                        TodayInlineAction(
                            kind: .openDetail,
                            title: "Answer",
                            systemImage: "arrow.right.circle",
                            state: .selected,
                            target: TodayActionTarget(draftID: draft.id)
                        )
                    ]
                )
            )
        }

        if let draft = blockedDrafts.first {
            return .blocked(
                TodayFocusBlockedState(
                    title: draft.draft.title,
                    subtitle: "There is a blocker, but Today still offers the next best move instead of a dead end.",
                    blockerSummary: draft.blockers.first?.reason ?? "Planning is blocked until one missing piece is clarified.",
                    nextBestAction: draft.blockers.first?.suggestedQuestion ?? draft.clarification?.questions.first?.prompt ?? "Open the draft and answer the smallest missing question.",
                    actions: [
                        TodayInlineAction(
                            kind: .openDetail,
                            title: "Open detail",
                            systemImage: "arrow.right.circle",
                            state: .warning,
                            target: TodayActionTarget(draftID: draft.id)
                        )
                    ]
                )
            )
        }

        guard let step = actionableSteps.first,
              let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
            return .empty(
                TodayEmptyPanelState(
                    title: "Nothing needs a push",
                    message: "Today stays calm when there is no clear next move. Untimed work can wait until it actually fits.",
                    actions: []
                )
            )
        }

        let draft = draftsByGoalID[goal.id]
        let target = TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
        let progress = focusProgress(for: step, feedback: feedback, evidence: evidence)
        let selection = rankedSelections.first(where: { $0.goal.id == goal.id && $0.step.id == step.id })

        if draft?.latestResultKind == .starterPlanned {
            return .starter(
                TodayFocusStarterState(
                    title: step.title,
                    subtitle: goal.title,
                    reassurance: "This plan was built from safe assumptions so you can start without technical warning energy.",
                    timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                    assumptions: draft?.assumptions.prefix(3).map(\.summary) ?? [],
                    actions: [
                        TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
                        TodayInlineAction(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected, target: target),
                        TodayInlineAction(kind: .createReminder, title: "Reminder", systemImage: "list.bullet.clipboard", state: .default, target: target),
                        TodayInlineAction(kind: .createCalendarEvent, title: "Calendar event", systemImage: "calendar.badge.plus", state: .default, target: target),
                        TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: target),
                        TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
                    ]
                )
            )
        }

        return .planned(
            TodayFocusPlannedState(
                title: step.title,
                subtitle: goal.title,
                reason: selection?.candidate.whyNow?.conciseReason ?? focusReason(for: goal, step: step),
                timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                energyLabel: energyLabel(for: goal.mode),
                progress: progress,
                supportingText: supportingText(for: goal, step: step),
                actions: [
                    TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
                    TodayInlineAction(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default, target: target),
                    TodayInlineAction(kind: .skip, title: "Skip", systemImage: "forward.fill", state: .warning, target: target),
                    TodayInlineAction(kind: .createReminder, title: "Reminder", systemImage: "list.bullet.clipboard", state: .default, target: target),
                    TodayInlineAction(kind: .createCalendarEvent, title: "Calendar event", systemImage: "calendar.badge.plus", state: .default, target: target),
                    TodayInlineAction(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected, target: target),
                    TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: target),
                    TodayInlineAction(kind: .markNotRelevant, title: "Not relevant", systemImage: "nosign", state: .warning, target: target),
                    TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
                ]
            )
        )
    }

    func makeFreeTime(
        goals: [Goal],
        actionableSteps: [Step],
        draftsByGoalID: [String: PersistedGoalDraft]
    ) -> TodayFreeTimeState {
        let opportunities = actionableSteps.compactMap { step -> TodayOpportunityState? in
            guard let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
                return nil
            }
            guard goal.timing.tempo == .untimed || goal.mode == .delegatedSupport || goal.mode == .learning || goal.mode == .exploration else {
                return nil
            }
            let state: AmbitionVisualState = goal.mode == .delegatedSupport ? .selected : .default
            return TodayOpportunityState(
                id: step.id,
                title: step.title,
                subtitle: opportunitySubtitle(for: goal),
                timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                state: state,
                action: TodayInlineAction(
                    kind: .quickLog,
                    title: "Quick log",
                    systemImage: "plus.bubble",
                    state: .success,
                    target: TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draftsByGoalID[goal.id]?.id)
                )
            )
        }

        return TodayFreeTimeState(
            title: opportunities.isEmpty ? "Free time can stay open" : "Free time opportunities",
            subtitle: opportunities.isEmpty
                ? "Nothing here is pretending a flexible goal is late."
                : "These are valid moves when the day opens up, especially for untimed, delegated, or exploratory work.",
            opportunities: Array(opportunities.prefix(3))
        )
    }

    func makeMilestone(goals: [Goal], draftsByGoalID: [String: PersistedGoalDraft]) -> TodayMilestoneState {
        let ordered = goals.sorted { lhs, rhs in
            timingSortKey(for: lhs.timing) < timingSortKey(for: rhs.timing)
        }
        guard let goal = ordered.first else {
            return TodayMilestoneState(
                title: "Milestone prompt",
                subtitle: "No active milestone yet",
                prompt: "Once a goal exists, Today will pull the next milestone cue from the real plan.",
                confidenceLabel: "Waiting on first goal",
                action: nil
            )
        }

        let pathSummary = LifeGraphResolver.pathStateSummary(for: goal)
        let pathPrompt: String?
        if let summary = pathSummary, let prerequisite = summary.blockedPrerequisites.first {
            pathPrompt = prerequisite.title
        } else if let summary = pathSummary,
                  let nextMilestoneID = summary.progression.nextMilestoneID,
                  let milestoneTitle = goal.lifeGraph?.milestones.first(where: { $0.id == nextMilestoneID })?.title {
            pathPrompt = milestoneTitle
        } else if let summary = pathSummary, let gap = summary.readiness.gapSignals.first {
            pathPrompt = gap.title
        } else {
            pathPrompt = nil
        }

        let sortedSections = goal.plan?.sections.sorted { $0.orderIndex < $1.orderIndex } ?? []
        let upcomingPrompt = sortedSections
            .first(where: { $0.kind == .upcoming || $0.kind == .review })?
            .steps
            .first?.title
        let fallbackPrompt = sortedSections.flatMap(\.steps).dropFirst().first?.title
        let prompt = pathPrompt
            ?? upcomingPrompt
            ?? fallbackPrompt
            ?? goal.summary
            ?? "Open the goal and confirm the next milestone."

        return TodayMilestoneState(
            title: goal.title,
            subtitle: "Milestone prompt",
            prompt: prompt,
            confidenceLabel: draftsByGoalID[goal.id]?.latestResultKind == .starterPlanned ? "Starter path" : "Live plan",
            action: TodayInlineAction(
                kind: .openDetail,
                title: "Open detail",
                systemImage: "flag.checkered.2.crossed",
                state: .selected,
                target: TodayActionTarget(goalID: goal.id, draftID: draftsByGoalID[goal.id]?.id)
            )
        )
    }

    func makeMomentum(
        activeGoals: [Goal],
        evidence: [ProgressEvidence],
        completedToday: Int,
        frictionCount: Int
    ) -> TodayMomentumState {
        let supportGoals = activeGoals.filter { $0.mode == .delegatedSupport }.count
        let loggedMinutes = evidence.compactMap(\.minutesInvested).reduce(0, +)
        let note: String
        if frictionCount == 0 {
            note = "Today is quiet on friction so far. Keep the scope small and visible."
        } else if supportGoals > 0 {
            note = "Supportive goals are in the mix, so momentum is being framed without punitive language."
        } else {
            note = "Friction is present but visible, which is better than invisible drift."
        }

        return TodayMomentumState(
            title: "Momentum",
            subtitle: "Progress summary",
            metrics: [
                TodayMetricState(id: "done", title: "Completed today", value: "\(completedToday)", detail: "Recorded from native evidence", icon: "checkmark.circle.fill", state: completedToday > 0 ? .success : .default),
                TodayMetricState(id: "active", title: "Active goals", value: "\(activeGoals.count)", detail: "Live in the repository", icon: "scope", state: .selected),
                TodayMetricState(id: "time", title: "Logged minutes", value: "\(loggedMinutes)", detail: "Captured evidence", icon: "timer", state: .default),
                TodayMetricState(id: "friction", title: "Friction signals", value: "\(frictionCount)", detail: "Feedback worth respecting", icon: "waveform.path.ecg", state: frictionCount > 0 ? .warning : .success)
            ],
            note: note
        )
    }

    func makeQuickCapture(goal: Goal?, step: Step?) -> TodayQuickCaptureState {
        let target = TodayActionTarget(goalID: goal?.id, stepID: step?.id)
        return TodayQuickCaptureState(
            title: "Quick capture",
            subtitle: "Ask for help when the next move is still too large or too vague.",
            prompt: "Use quick log when progress happened without a clean completion event.",
            helpText: "If the active step feels heavy, ask for a smaller step before the day turns into avoidance.",
            actions: [
                TodayInlineAction(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .success, target: target),
                TodayInlineAction(kind: .askForHelp, title: "Ask for help", systemImage: "lifepreserver", state: .default, target: target)
            ]
        )
    }

    func makeReflection(
        now: Date,
        completedToday: [String],
        activeGoals: [Goal],
        feedback: [GoalFeedbackEvent]
    ) -> TodayReflectionState {
        let hour = Calendar.current.component(.hour, from: now)
        let prompt = hour >= 18
            ? "What helped today feel lighter than it could have?"
            : "When tonight arrives, what do you want to feel good about?"

        let frictionHighlights = feedback.prefix(2).map { feedbackSummary(for: $0) }
        let highlights = completedToday.prefix(2) + frictionHighlights

        return TodayReflectionState(
            title: "End-of-day reflection",
            subtitle: "A calm close matters more than squeezing in one more noisy panel.",
            prompt: prompt,
            highlights: Array(highlights),
            actions: [
                TodayInlineAction(
                    kind: .quickLog,
                    title: "Quick log",
                    systemImage: "square.and.pencil",
                    state: .default,
                    target: TodayActionTarget(goalID: activeGoals.first?.id, stepID: activeGoals.first?.plan?.sections.flatMap(\.steps).first?.id)
                )
            ]
        )
    }

    func todayCompletionTitles(snapshot: Snapshot, now: Date) -> [String] {
        let dayStart = Calendar.current.startOfDay(for: now)
        return snapshot.feedback.compactMap { event -> String? in
            guard case .completed(let base, _, _, _) = event else { return nil }
            guard let occurredAt = parseDate(base.occurredAt), occurredAt >= dayStart else { return nil }
            return stepTitle(for: base.stepID, goals: snapshot.goals)
        }
    }

    func stepTitle(for stepID: String, goals: [Goal]) -> String? {
        goals.lazy
            .compactMap { $0.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID })?.title }
            .first
    }

    func feedbackSummary(for event: GoalFeedbackEvent) -> String {
        switch event {
        case let .skipped(base, _):
            return "Skipped: \(base.note ?? "Not today.")"
        case let .delayed(base, _, _):
            return "Delayed: \(base.note ?? "Made room without dropping it.")"
        case let .confused(base, _):
            return "Clarify: \(base.note ?? "The next step needs cleaner language.")"
        case let .notRelevant(base):
            return "Relevance check: \(base.note ?? "Something drifted.")"
        case .completed, .edited, .tooBig, .tooEasy, .askedForSmallerVersion, .askedWhyThisMatters:
            return "Signal captured from Today."
        }
    }

    func timingSortKey(for timing: GoalTiming, goalMode: GoalMode? = nil) -> String {
        if goalMode == .delegatedSupport {
            return timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
        }
        return timing.dueAt ?? timing.targetBy ?? timing.windowStart ?? timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
    }

    func timingLabel(for timing: GoalTiming, goalMode: GoalMode) -> String {
        switch goalMode {
        case .delegatedSupport:
            return timing.suggestedNextAt == nil ? "Support when helpful" : "Good support window"
        default:
            switch timing.tempo {
            case .untimed:
                return "No deadline"
            case .ongoing:
                return timing.repeatEveryDays.map { "Every \($0) day\($0 == 1 ? "" : "s")" } ?? "Keep it gentle"
            case .targetWindow:
                return timing.targetBy.map { "Target by \($0)" } ?? "Flexible window"
            case .deadlineBased:
                return timing.dueAt.map { "Due \($0)" } ?? "Time-bound"
            }
        }
    }

    func statusLabel(for step: Step, draft: PersistedGoalDraft?) -> String {
        if step.state == .blocked { return "Blocked" }
        if draft?.latestResultKind == .starterPlanned { return "Starter plan" }
        return "Planned"
    }

    func progressValue(for step: Step) -> Double {
        switch step.state {
        case .completed: return 1
        case .active: return 0.8
        case .blocked: return 0.22
        case .planned: return 0.48
        case .cancelled: return 0.08
        }
    }

    func focusProgress(for step: Step, feedback: [GoalFeedbackEvent], evidence: [ProgressEvidence]) -> Double {
        let stepFeedbackCount = feedback.filter { $0.stepID == step.id }.count
        let stepEvidenceCount = evidence.filter { $0.stepID == step.id }.count
        let base = progressValue(for: step)
        let bonus = min(0.32, Double(stepFeedbackCount + stepEvidenceCount) * 0.06)
        return min(0.96, base + bonus)
    }

    func focusReason(for goal: Goal, step: Step) -> String {
        if goal.mode == .delegatedSupport {
            return "This move supports \(goal.actor.displayName) without turning the relationship into compliance work."
        }
        if HabitGoalSemantics.isHabitLike(goal: goal, step: step) {
            return "Consistency matters more than intensity here. A smaller clean repetition is better than a loud miss."
        }
        return step.summary ?? goal.summary ?? "This is the cleanest next move from the current native plan."
    }

    func energyLabel(for mode: GoalMode) -> String {
        switch mode {
        case .habit, .maintenance:
            return "Steady"
        case .recovery:
            return "Gentle"
        case .delegatedSupport:
            return "Supportive"
        case .exploration, .learning:
            return "Curious"
        default:
            return "Deliberate"
        }
    }

    func supportingText(for goal: Goal, step: Step) -> [String] {
        var items = [timingLabel(for: step.timing, goalMode: goal.mode)]
        items.append(contentsOf: step.actionability.evidenceOfCompletion.prefix(2))
        if HabitGoalSemantics.isHabitLike(goal: goal, step: step) {
            items.append("Minimum version: \(step.actionability.fallbackMicroStep)")
        }
        if goal.mode == .delegatedSupport {
            items.append("Keep the other person as the owner of execution.")
        }
        return items
    }

    func opportunitySubtitle(for goal: Goal) -> String {
        switch goal.mode {
        case .delegatedSupport:
            return "A non-punitive support move"
        case .learning:
            return "A good flexible learning session"
        case .exploration:
            return "A low-pressure experiment"
        default:
            return goal.summary ?? "A calm use of spare time"
        }
    }

    func rescheduleDecision(
        for kind: TodayActionKind,
        goal: Goal,
        step: Step,
        history: [GoalFeedbackEvent],
        now: Date
    ) -> RescheduleDecision? {
        guard let trigger = rescheduleTrigger(for: kind) else { return nil }
        return rescheduleEngine.decide(
            RescheduleEngineInput(
                stepID: step.id,
                timing: step.timing,
                feedbackHistory: history,
                trigger: trigger,
                fallbackMicroStep: step.actionability.fallbackMicroStep,
                now: now,
                planningEvaluation: goal.plan?.evaluation,
                stepState: step.state,
                incompleteDependencyCount: incompleteDependencyCount(in: goal, for: step),
                pathStateSummary: LifeGraphResolver.pathStateSummary(for: goal),
                learningSummary: learningService.buildSnapshot(
                    goals: [goal],
                    evidence: [],
                    feedback: history,
                    now: now
                ).goalSummaries[goal.id],
                sharedLifeSummary: sharedLifeService.buildSnapshot(
                    goals: [goal],
                    evidence: [],
                    feedback: history,
                    now: now
                ).goalSummaries[goal.id]
            )
        )
    }

    func rescheduleTrigger(for kind: TodayActionKind) -> RescheduleTrigger? {
        switch kind {
        case .delay:
            return .delay
        case .skip:
            return .skip
        case .askForSmallerStep:
            return .askForSmallerStep
        case .askForHelp:
            return .stuck
        case .complete, .createReminder, .createCalendarEvent, .askWhyThisMatters, .markNotRelevant, .openDetail, .quickLog, .dismissCelebration:
            return nil
        }
    }

    func note(for kind: TodayActionKind, step: Step) -> String {
        switch kind {
        case .complete:
            return "Completed from Today."
        case .delay:
            return "Delayed from Today to reduce pressure."
        case .skip:
            return "Skipped from Today without punitive language."
        case .createReminder:
            return "Created reminder from Today."
        case .createCalendarEvent:
            return "Created calendar event from Today."
        case .askForSmallerStep:
            return "Asked for a smaller version from Today."
        case .askWhyThisMatters:
            return "Asked why this matters from Today."
        case .markNotRelevant:
            return "Marked not relevant from Today."
        case .quickLog:
            return "Quick log from Today."
        case .openDetail, .askForHelp, .dismissCelebration:
            return step.title
        }
    }

    func nextStepSchedulingSelection(goal: Goal, step: Step) -> NextStepSchedulingSelection {
        NextStepSchedulingSelection(
            goalID: goal.id,
            goalTitle: goal.title,
            stepID: step.id,
            stepTitle: step.title,
            stepSummary: step.summary ?? step.actionability.fallbackMicroStep,
            suggestedDate: parseDate(step.timing.suggestedNextAt ?? step.timing.targetBy ?? step.timing.dueAt ?? "")
        )
    }

    func shiftedTiming(for timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment) -> GoalTiming {
        let shiftedDate: Date
        switch adjustment {
        case .laterToday:
            shiftedDate = Calendar.current.date(byAdding: .hour, value: 3, to: now) ?? now
        case .laterThisWeek:
            shiftedDate = Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now
        case .someday:
            shiftedDate = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        case .removeDeadline:
            shiftedDate = now
        }

        let shiftedValue = adjustment == .removeDeadline ? nil : Self.iso.string(from: shiftedDate)
        return GoalTiming(
            tempo: adjustment == .removeDeadline ? .untimed : timing.tempo,
            timingType: adjustment == .removeDeadline ? .logWhenDone : .suggestedNext,
            startsOn: timing.startsOn,
            dueAt: adjustment == .removeDeadline ? nil : timing.dueAt,
            targetBy: adjustment == .removeDeadline ? nil : timing.targetBy,
            windowStart: timing.windowStart,
            windowEnd: timing.windowEnd,
            suggestedNextAt: shiftedValue,
            repeatEveryDays: timing.repeatEveryDays,
            progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }

    func smallerSummary(from recommendation: GoalReplanRecommendation, step: Step) -> String? {
        switch recommendation {
        case let .shrinkStep(_, _, _, _, smallerVersion, fallbackMicroStep):
            return "\(smallerVersion) Start with: \(fallbackMicroStep)"
        case let .suggestMicroStep(_, _, _, _, microStep):
            return microStep
        case let .reviseStep(_, _, _, _, rewriteHints, _, _):
            return rewriteHints.first ?? step.actionability.fallbackMicroStep
        case let .suggestAlternatePath(_, _, _, _, alternatePath, _):
            return alternatePath
        case .noChange, .relaxTiming, .requestReclarification, .adjustPlanTone:
            return nil
        }
    }

    func update(goal: Goal, stepID: String, transform: (Step) -> Step) -> Goal {
        let updatedSections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == stepID ? transform($0) : $0 }
            )
        }

        let updatedPlan = goal.plan.map { plan in
            GoalPlan(
                id: plan.id,
                goalID: plan.goalID,
                version: plan.version,
                generatedAt: plan.generatedAt,
                summary: plan.summary,
                strategy: plan.strategy,
                sections: updatedSections ?? plan.sections,
                assumptions: plan.assumptions,
                lint: plan.lint
            )
        }

        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: Self.iso.string(from: .now),
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: updatedPlan,
            lifeGraph: goal.lifeGraph
        )
    }

    func incompleteDependencyCount(in goal: Goal, for step: Step) -> Int {
        let completedStepIDs = Set(goal.plan?.sections.flatMap(\.steps).filter { $0.state == .completed }.map(\.id) ?? [])
        return step.dependencyStepIDs.filter { completedStepIDs.contains($0) == false }.count
    }

    static let iso: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let isoFallback: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    func parseDate(_ value: String) -> Date? {
        Self.iso.date(from: value) ?? Self.isoFallback.date(from: value) ?? Self.dateOnly.date(from: value)
    }

    static let dateOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    func calendarEventMessageBody(for title: String, report: CalendarConflictReport?) -> String {
        guard let report else {
            return "\"\(title)\" was added to Calendar."
        }
        if report.hasConflicts {
            let count = report.conflicts.count
            if let nearby = report.nearbyAvailableWindow {
                return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s"). A clearer opening starts around \(Self.shortTime.string(from: nearby.start))."
            }
            return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s")."
        }
        if report.pressure == .high {
            return "\"\(title)\" was added to Calendar. The day looks tight around that block."
        }
        return "\"\(title)\" was added to Calendar."
    }
}
