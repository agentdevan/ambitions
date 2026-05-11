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

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        let snapshot = try await loadSnapshot()
        return try await makeExperience(snapshot: snapshot, userDisplayName: userDisplayName, now: now, entryContext: entryContext)
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        let handler = TodayCommandHandler(
            feedbackActionHandler: { action, now in
                try await self.performFeedbackAction(action, now: now)
            },
            commandActionHandler: { action, command, now in
                try await self.performCommandAction(action, command: command, now: now)
            }
        )
        return try await handler.performAction(action, now: now)
    }
}

private extension RepositoryBackedTodayService {
    func performCommandAction(
        _ action: TodayInlineAction,
        command: AmbitionsCommand,
        now: Date
    ) async throws -> TodayActionResponse {
        let validator = AmbitionsCommandValidator()
        let validation = validator.validate(command)

        let goalID = action.target.goalID
        let beforeFeedback = try await preFeedbackEvents(for: goalID)
        let beforeEvidence = try await preEvidenceRecords(goalID: goalID)
        let beforeCaptures = try await repositories.captures.listCaptures()

        let response = try await performFeedbackAction(action, now: now)

        let afterFeedback = try await preFeedbackEvents(for: goalID)
        let afterEvidence = try await preEvidenceRecords(goalID: goalID)
        let afterCaptures = try await repositories.captures.listCaptures()
        let newCaptures = newCaptures(before: beforeCaptures, after: afterCaptures)

        let eventLedgerEntryIDs = await emitTodayCommandEvidence(
            for: action,
            command: command,
            now: now,
            goalID: goalID,
            beforeFeedback: beforeFeedback,
            afterFeedback: afterFeedback,
            beforeEvidence: beforeEvidence,
            afterEvidence: afterEvidence,
            beforeCaptures: beforeCaptures,
            afterCaptures: afterCaptures
        )
        let result = makeCommandExecutionResult(
            validation: validation,
            command: command,
            action: action,
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            resultTarget: commandResultTarget(
                command: command,
                action: action,
                newCaptures: newCaptures
            )
        )
        await persistCommandExecution(command: command, result: result, at: now)

        return response
    }

    func preFeedbackEvents(for goalID: String?) async throws -> [GoalFeedbackEvent] {
        guard let goalID else { return [] }
        return try await repositories.feedback.listEvents(goalID: goalID)
    }

    func preEvidenceRecords(goalID: String?) async throws -> [ProgressEvidence] {
        try await repositories.evidence.listEvidence(goalID: goalID)
    }

    func persistCommandExecution(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        at timestamp: Date
    ) async {
        guard let commandExecutionRecords = repositories.commandExecutionRecords else { return }
        let record = AmbitionsCommandExecutionRecord(
            command: command,
            result: result,
            recordedAt: Self.iso.string(from: timestamp)
        )
        try? await commandExecutionRecords.append(record)
    }

    func makeCommandExecutionResult(
        validation: AmbitionsCommandValidationState,
        command: AmbitionsCommand,
        action: TodayInlineAction,
        eventLedgerEntryIDs: [String],
        resultTarget: AmbitionsCommandTarget
    ) -> AmbitionsCommandExecutionResult {
        if validation != .valid {
            return blockedCommandResult(for: validation, command: command)
        }

        let status: AmbitionsCommandExecutionStatus = eventLedgerEntryIDs.isEmpty ? .noOp : .succeeded
        return AmbitionsCommandExecutionResult(
            status: status,
            summary: status == .succeeded ? "Today command completed." : "Today command changed nothing.",
            target: resultTarget,
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "commandSource": command.source.rawValue,
                "todayAction": action.kind.rawValue,
                "validation": validation.rawValue
            ]
        )
    }

    func commandResultTarget(
        command: AmbitionsCommand,
        action: TodayInlineAction,
        newCaptures: [Capture]
    ) -> AmbitionsCommandTarget {
        guard command.kind == .quickCapture || action.kind == .quickLog,
              let capture = newCaptures.first else {
            return command.target
        }
        return AmbitionsCommandTarget(
            goalID: command.target.goalID ?? capture.linkedGoalID,
            captureID: capture.id,
            stepID: command.target.stepID,
            destination: command.target.destination
        )
    }

    func blockedCommandResult(
        for validation: AmbitionsCommandValidationState,
        command: AmbitionsCommand
    ) -> AmbitionsCommandExecutionResult {
        let status: AmbitionsCommandExecutionStatus
        let summary: String
        switch validation {
        case .valid:
            status = .noOp
            summary = "Command is valid."
        case .invalid:
            status = .failed
            summary = "Command payload is invalid."
        case .needsConfirmation:
            status = .requiresConfirmation
            summary = "Command needs confirmation before it can execute."
        case .needsMissingTarget:
            status = .blocked
            summary = "Command is missing the target needed for safe execution."
        case .unsupportedInThisBuild:
            status = .unsupported
            summary = "Command is unsupported in this build."
        case .blockedByMissingFoundation:
            status = .blocked
            summary = "Command is blocked by missing foundation work."
        }

        return AmbitionsCommandExecutionResult(
            status: status,
            summary: summary,
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: ["validation": validation.rawValue]
        )
    }

    func emitTodayCommandEvidence(
        for action: TodayInlineAction,
        command: AmbitionsCommand,
        now: Date,
        goalID: String?,
        beforeFeedback: [GoalFeedbackEvent],
        afterFeedback: [GoalFeedbackEvent],
        beforeEvidence: [ProgressEvidence],
        afterEvidence: [ProgressEvidence],
        beforeCaptures: [Capture],
        afterCaptures: [Capture]
    ) async -> [String] {
        let beforeFeedbackIDs = Set(beforeFeedback.map(\.base.id))
        let beforeEvidenceIDs = Set(beforeEvidence.map(\.id))
        let newFeedback = afterFeedback.filter { beforeFeedbackIDs.contains($0.base.id) == false }
        let newEvidence = afterEvidence.filter { beforeEvidenceIDs.contains($0.id) == false }
        let newCaptures = newCaptures(before: beforeCaptures, after: afterCaptures)

        guard !newFeedback.isEmpty || !newEvidence.isEmpty || !newCaptures.isEmpty else {
            return []
        }
        guard let goalID else { return [] }

        var eventLedgerEntryIDs: [String] = []

        for event in newFeedback {
            let entry = EventLedgerEntry.fromFeedbackEvent(event, goalID: goalID, source: .today)
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        for evidence in newEvidence {
            let entry = EventLedgerEntry.fromProgressEvidence(evidence, source: .today)
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        for capture in newCaptures where action.kind == .quickLog {
            let entry = commandCaptureCreatedEntry(
                capture: capture,
                command: command,
                occurredAt: Self.iso.string(from: now)
            )
            do {
                try await repositories.eventLedger.append(entry)
                eventLedgerEntryIDs.append(entry.id)
            } catch {
                // Keep command behavior alive even if ledger emission fails.
            }
        }

        return eventLedgerEntryIDs
    }

    func newCaptures(before: [Capture], after: [Capture]) -> [Capture] {
        let beforeCaptureIDs = Set(before.map(\.id))
        return after.filter { beforeCaptureIDs.contains($0.id) == false }
    }

    func commandCaptureCreatedEntry(
        capture: Capture,
        command: AmbitionsCommand,
        occurredAt: String
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.command.\(command.id)",
            kind: .captureCreated,
            occurredAt: occurredAt,
            source: eventLedgerSource(for: command.source),
            goalID: command.target.goalID,
            captureID: capture.id,
            title: "Capture created",
            summary: nil,
            semanticState: command.kind.rawValue,
            tone: .neutral,
            trust: EventLedgerTrustMetadata(isUserConfirmed: command.actor == .user),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: command.id,
                    kind: .externalCommand,
                    occurredAt: command.requestedAt,
                    summary: command.kind.rawValue
                ),
                EventLedgerEvidenceReference(
                    id: capture.id,
                    kind: .capture,
                    occurredAt: capture.createdAt,
                    summary: "quick_capture"
                )
            ],
            metadata: [
                "commandKind": command.kind.rawValue,
                "commandSource": command.source.rawValue,
                "sourceSurface": command.sourceSurface ?? ""
            ].filter { $0.value.isEmpty == false },
            payload: [
                "captureID": capture.id,
                "contextLens": command.payload.contextLens?.rawValue ?? "",
                "commitmentKind": command.payload.commitmentKind?.rawValue ?? ""
            ].filter { $0.value.isEmpty == false },
            privacy: .privateUserText
        )
    }

    func eventLedgerSource(for source: AmbitionsCommandSource) -> EventLedgerSource {
        switch source {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .capture:
            return .capture
        case .plan:
            return .plan
        case .you:
            return .you
        case .reviews:
            return .you
        case .widget, .liveActivity, .appIntent, .notification, .deepLink, .system:
            return .system
        }
    }

    func makeExperience(snapshot: Snapshot, userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
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
        let shellSummaries = try await todayShellSummaries(
            goals: activeGoals,
            draftsByGoalID: draftsByGoalID,
            actionableSteps: actionableSteps,
            now: now
        )

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

        let header = makeHeader(
            mode: mode,
            userDisplayName: userDisplayName,
            now: now,
            activeGoals: activeGoals,
            actionableCount: actionableSteps.count,
            clarificationCount: clarificationDrafts.count,
            blockedCount: blockedDrafts.count
        )
        let ritual = makeRitual(
            snapshot: snapshot,
            activeGoals: activeGoals,
            learningSnapshot: learningSnapshot,
            sharedLifeSnapshot: sharedLifeSnapshot,
            now: now
        )
        let dailyTargets = makeDailyTargets(
            mode: mode,
            goals: activeGoals,
            actionableSteps: actionableSteps,
            draftsByGoalID: draftsByGoalID,
            completion: (completedSteps, totalSteps),
            shellSummaries: shellSummaries
        )
        let focus = makeFocus(
            clarificationDrafts: clarificationDrafts,
            blockedDrafts: blockedDrafts,
            rankedSelections: rankedSelections,
            actionableSteps: actionableSteps,
            goals: activeGoals,
            draftsByGoalID: draftsByGoalID,
            feedback: snapshot.feedback,
            evidence: snapshot.evidence,
            shellSummaries: shellSummaries
        )
        let freeTime = makeFreeTime(
            goals: activeGoals,
            actionableSteps: actionableSteps,
            draftsByGoalID: draftsByGoalID
        )
        let milestone = makeMilestone(
            goals: activeGoals,
            draftsByGoalID: draftsByGoalID,
            shellSummaries: shellSummaries
        )
        let momentum = makeMomentum(
            activeGoals: activeGoals,
            evidence: snapshot.evidence,
            completedToday: completedToday.count,
            frictionCount: frictionCount
        )
        let quickCapture = makeQuickCapture(goal: activeGoals.first, step: actionableSteps.first)
        let reflection = makeReflection(
            now: now,
            completedToday: completedToday,
            activeGoals: activeGoals,
            feedback: snapshot.feedback
        )

        let posture = dayPosture(
            mode: mode,
            entryContext: entryContext,
            frictionCount: frictionCount,
            clarificationCount: clarificationDrafts.count,
            blockedCount: blockedDrafts.count,
            actionableCount: actionableSteps.count
        )

        let hero = makeHero(
            header: header,
            ritual: ritual,
            focus: focus,
            dailyTargets: dailyTargets,
            freeTime: freeTime,
            milestone: milestone,
            posture: posture,
            entryContext: entryContext
        )
        let support = makeSupportLayer(
            now: now,
            posture: posture,
            entryContext: entryContext,
            focus: focus,
            dailyTargets: dailyTargets,
            freeTime: freeTime,
            milestone: milestone,
            momentum: momentum,
            quickCapture: quickCapture,
            reflection: reflection,
            completedToday: completedToday,
            shellSummary: focus.shellSummary ?? milestone.shellSummary
        )
        let execution = TodayReadModelProjector(selector: selector).project(
            mode: mode,
            snapshot: snapshot,
            activeGoals: activeGoals,
            hero: hero,
            support: support,
            now: now,
            entryContext: entryContext
        )

        return TodayExperience(
            mode: mode,
            hero: hero,
            support: support,
            execution: execution
        )
    }

    func dayPosture(
        mode: TodayExperienceMode,
        entryContext: TodayEntryContext,
        frictionCount: Int,
        clarificationCount: Int,
        blockedCount: Int,
        actionableCount: Int
    ) -> TodayDayPosture {
        if mode == .empty {
            return .noPlan
        }
        switch entryContext.normalized {
        case .recovery:
            return .recovering
        case .stepSession:
            return .stable
        case .standard, .focus:
            break
        }
        if clarificationCount > 0 {
            return .lowData
        }
        if blockedCount > 0 {
            return .drifted
        }
        if frictionCount >= 4 || actionableCount >= 5 {
            return .overloaded
        }
        if frictionCount >= 2 || actionableCount >= 4 {
            return .tight
        }
        return .stable
    }

    func makeHero(
        header: TodayHeaderState,
        ritual: TodayRitualLoopState,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState,
        posture: TodayDayPosture,
        entryContext: TodayEntryContext
    ) -> TodayHeroState {
        let heroSeed = heroSeed(from: focus, ritual: ritual, milestone: milestone)
        let trustWhisper = heroSeed.shellSummary.map { summary in
            TodayTrustWhisperState(
                title: "Why this now",
                detail: summary.explanationSummary,
                state: .selected
            )
        }
        let nextItem = nextHeroItem(from: dailyTargets, excluding: heroSeed.title) ?? nextHeroItem(from: freeTime)

        return TodayHeroState(
            truth: TodayHeroTruthState(
                greeting: header.greeting,
                dominantText: dominantText(for: posture, heroTitle: heroSeed.title),
                supportingText: heroSupportingText(for: posture, heroDetail: heroSeed.detail, ritual: ritual),
                nowTitle: heroSeed.title,
                nowSubtitle: heroSeed.detail,
                nextTitle: nextItem?.title,
                nextSubtitle: nextItem?.subtitle,
                posture: posture,
                contextPills: header.contextPills,
                trustWhisper: trustWhisper,
                shellSummary: heroSeed.shellSummary
            ),
            primaryAction: makePrimaryAction(
                posture: posture,
                entryContext: entryContext,
                focus: focus,
                freeTime: freeTime,
                milestone: milestone
            ),
            reentry: makeReentryState(entryContext: entryContext)
        )
    }

    func makeSupportLayer(
        now: Date,
        posture: TodayDayPosture,
        entryContext: TodayEntryContext,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState,
        momentum: TodayMomentumState,
        quickCapture: TodayQuickCaptureState,
        reflection: TodayReflectionState,
        completedToday: [String],
        shellSummary: GoalShellSummaryState?
    ) -> TodaySupportLayerState {
        TodaySupportLayerState(
            timeAperture: makeTimeAperture(
                now: now,
                posture: posture,
                focus: focus,
                dailyTargets: dailyTargets,
                freeTime: freeTime,
                milestone: milestone,
                shellSummary: shellSummary
            ),
            recoveryBloom: makeRecoveryBloom(
                posture: posture,
                focus: focus,
                freeTime: freeTime
            ),
            stepSession: makeStepSession(
                entryContext: entryContext,
                focus: focus,
                posture: posture,
                shellSummary: shellSummary
            ),
            fixedCommitments: TodayFixedCommitmentsState(
                title: dailyTargets.title,
                summary: dailyTargets.subtitle,
                items: dailyTargets.items.map {
                    TodaySupportItemState(
                        id: $0.id,
                        title: $0.title,
                        subtitle: $0.subtitle,
                        label: $0.timingLabel,
                        state: $0.state,
                        action: $0.primaryAction ?? $0.secondaryAction
                    )
                },
                emptyMessage: dailyTargets.emptyMessage
            ),
            flexibleRoom: TodayFlexibleRoomState(
                title: freeTime.title,
                summary: freeTime.subtitle,
                items: freeTime.opportunities.map {
                    TodaySupportItemState(
                        id: $0.id,
                        title: $0.title,
                        subtitle: $0.subtitle,
                        label: $0.timingLabel,
                        state: $0.state,
                        action: $0.action
                    )
                },
                emptyMessage: freeTime.opportunities.isEmpty ? "Free space is allowed to stay free." : nil
            ),
            momentum: TodayMomentumStripState(
                title: momentum.title,
                summary: momentum.subtitle,
                metrics: momentum.metrics,
                note: momentum.note,
                celebrationLine: completedToday.isEmpty ? nil : "Momentum is already visible today."
            ),
            quickCaptureAction: quickCapture.actions.first,
            quickCaptureTitle: quickCapture.title,
            quickCaptureDetail: quickCapture.helpText,
            planAction: TodayInlineAction(
                kind: .openPlan,
                title: "Open Time",
                systemImage: "calendar",
                state: .default,
                target: TodayActionTarget()
            ),
            reflectionPrompt: reflection.prompt,
            reflectionHighlights: reflection.highlights
        )
    }

    func heroSeed(
        from focus: TodayFocusState,
        ritual: TodayRitualLoopState,
        milestone: TodayMilestoneState
    ) -> (title: String, detail: String, shellSummary: GoalShellSummaryState?) {
        switch focus {
        case let .planned(state):
            return (state.title, state.reason, state.shellSummary)
        case let .starter(state):
            return (state.title, state.subtitle, state.shellSummary)
        case let .clarification(state):
            return (state.title, state.subtitle, nil)
        case let .blocked(state):
            return (state.title, state.nextBestAction, nil)
        case let .empty(state):
            return (
                milestone.title.isEmpty ? state.title : milestone.title,
                state.message.isEmpty ? ritual.thesis : state.message,
                milestone.shellSummary
            )
        }
    }

    func makePrimaryAction(
        posture: TodayDayPosture,
        entryContext: TodayEntryContext,
        focus: TodayFocusState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState
    ) -> TodayPrimaryActionState {
        let available = primaryActions(
            from: focus,
            posture: posture,
            entryContext: entryContext,
            milestone: milestone,
            freeTime: freeTime
        )
        let primary = available.first ?? TodayInlineAction(
            kind: .openPlan,
            title: "Build today",
            systemImage: "calendar.badge.plus",
            state: .selected,
            target: TodayActionTarget()
        )
        return TodayPrimaryActionState(
            title: primary.title,
            subtitle: primarySubtitle(for: posture, action: primary),
            action: primary,
            supportingActions: prioritizedSupportingActions(from: Array(available.dropFirst()))
        )
    }

    func prioritizedSupportingActions(from actions: [TodayInlineAction]) -> [TodayInlineAction] {
        guard actions.count > 4 else { return actions }

        var prioritized: [TodayInlineAction] = []
        var seen = Set<String>()

        func append(_ action: TodayInlineAction?) {
            guard let action else { return }
            let key = action.id
            guard seen.insert(key).inserted else { return }
            prioritized.append(action)
        }

        append(actions.first(where: { $0.kind == .openDetail }))
        append(actions.first(where: { $0.kind == .split }))
        append(actions.first(where: { $0.kind == .defer }))
        append(actions.first(where: { $0.kind == .reschedule }))
        append(actions.first(where: { $0.kind == .askWhyThisMatters }))

        for action in actions where prioritized.count < 5 {
            append(action)
        }

        return Array(prioritized.prefix(5))
    }

    func primaryActions(
        from focus: TodayFocusState,
        posture: TodayDayPosture,
        entryContext: TodayEntryContext,
        milestone: TodayMilestoneState,
        freeTime: TodayFreeTimeState
    ) -> [TodayInlineAction] {
        let focusActions: [TodayInlineAction] = {
            switch focus {
            case let .planned(state):
                state.actions
            case let .starter(state):
                state.actions
            case let .clarification(state):
                state.actions
            case let .blocked(state):
                state.actions
            case let .empty(state):
                state.actions
            }
        }()

        var actions = focusActions
        if entryContext.normalized != .stepSession,
           posture == .stable,
           let firstFocusAction = focusActions.first(where: {
               $0.kind == .complete || $0.kind == .split || $0.kind == .askForHelp
           }) {
            actions.insert(
                TodayInlineAction(
                    kind: .startStepSession,
                    title: "Start now",
                    systemImage: "scope",
                    state: .selected,
                    target: firstFocusAction.target
                ),
                at: 0
            )
        }
        if posture == .tight || posture == .overloaded || posture == .recovering {
            actions.insert(
                TodayInlineAction(
                    kind: .protectLater,
                    title: "Adjust plan",
                    systemImage: "calendar.badge.clock",
                    state: .selected,
                    target: TodayActionTarget()
                ),
                at: 0
            )
        }
        if actions.isEmpty, let milestoneAction = milestone.action {
            actions.append(milestoneAction)
        }
        if actions.isEmpty, let freeAction = freeTime.opportunities.first?.action {
            actions.append(freeAction)
        }
        return deduplicated(actions)
    }

    func primarySubtitle(for posture: TodayDayPosture, action: TodayInlineAction) -> String {
        switch posture {
        case .stable:
            return "One clear step matters more than another stack of cards."
        case .tight:
            return action.kind == .protectLater ? "Adjust this in Plan before pressure turns noisy." : "Keep the day doable without widening scope."
        case .drifted:
            return "Use the calmest next step to get traction back."
        case .overloaded:
            return "Reduce pressure before adding more intent."
        case .recovering:
            return "Come back through one safer lane, not a full reset."
        case .lowData:
            return "Clarify the next step before pretending certainty."
        case .noPlan:
            return "Start with one bounded step and let the shell own the bigger reshaping."
        }
    }

    func dominantText(for posture: TodayDayPosture, heroTitle: String) -> String {
        switch posture {
        case .stable:
            return heroTitle
        case .tight:
            return "Hold the day around \(heroTitle.lowercased())"
        case .drifted:
            return "Return through \(heroTitle.lowercased())"
        case .overloaded:
            return "Lighten the day before it hardens"
        case .recovering:
            return "Recover through one believable step"
        case .lowData:
            return "Clarify the next step first"
        case .noPlan:
            return "Build today from one real step"
        }
    }

    func heroSupportingText(for posture: TodayDayPosture, heroDetail: String, ritual: TodayRitualLoopState) -> String {
        switch posture {
        case .stable:
            if ritual.thesis.localizedCaseInsensitiveContains("shared") &&
                heroDetail.localizedCaseInsensitiveContains("shared") == false {
                return ritual.thesis
            }
            return heroDetail
        case .tight, .recovering:
            return ritual.thesis
        case .drifted, .overloaded:
            return heroDetail.isEmpty ? ritual.subtitle : heroDetail
        case .lowData:
            return heroDetail
        case .noPlan:
            return ritual.thesis
        }
    }

    func makeReentryState(entryContext: TodayEntryContext) -> TodayReentryState? {
        switch entryContext.normalized {
        case .standard:
            return nil
        case .recovery:
            return TodayReentryState(
                eyebrow: "Re-entry",
                title: "Recovery landed in Today",
                detail: "This pass is centered on the calmest next step, not the whole backlog.",
                state: .selected
            )
        case .stepSession:
            return TodayReentryState(
                eyebrow: "Re-entry",
                title: "Step Session landed in Today",
                detail: "The hero is holding the clearest next step without turning the session into a timer.",
                state: .success
            )
        case .focus:
            return nil
        }
    }

    func nextHeroItem(from dailyTargets: TodayDailyTargetsState, excluding title: String) -> (title: String, subtitle: String)? {
        guard let item = dailyTargets.items.first(where: { $0.title != title }) else {
            return nil
        }
        return (item.title, item.subtitle)
    }

    func nextHeroItem(from freeTime: TodayFreeTimeState) -> (title: String, subtitle: String)? {
        guard let item = freeTime.opportunities.first else { return nil }
        return (item.title, item.subtitle)
    }

    func makeTimeAperture(
        now: Date,
        posture: TodayDayPosture,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState,
        shellSummary: GoalShellSummaryState?
    ) -> TodayTimeApertureState {
        let pressure = dayPressureState(
            posture: posture,
            fixedCount: dailyTargets.items.count,
            flexibleCount: freeTime.opportunities.count
        )
        let windows = openWindows(
            now: now,
            posture: posture,
            focus: focus,
            dailyTargets: dailyTargets,
            freeTime: freeTime
        )
        let bestUseAction = windows.first?.action ?? milestone.action
        let bestUseTitle: String
        let bestUseDetail: String
        if let window = windows.first {
            bestUseTitle = window.title
            bestUseDetail = window.subtitle
        } else if let opportunity = freeTime.opportunities.first {
            bestUseTitle = opportunity.title
            bestUseDetail = opportunity.subtitle
        } else {
            bestUseTitle = "Keep the day quiet"
            bestUseDetail = posture == .overloaded || posture == .drifted || posture == .recovering
                ? "The best use of the remaining day may be protecting one believable block instead of forcing more work."
                : "Unused room is allowed to stay unused when nothing cleanly fits."
        }

        let whisper = shellSummary.map { summary in
            TodayTrustWhisperState(
                title: pressure.label == "Needs confirmation" ? "May need confirmation" : "Based on",
                detail: pressure.label == "Needs confirmation"
                    ? "Time pressure is being inferred from current plan shape and may change as newer input lands."
                    : summary.pathSummary,
                state: pressure.state
            )
        }

        return TodayTimeApertureState(
            title: "Time Aperture",
            subtitle: "Room and pressure stay visible without turning Today into a dense calendar.",
            pressure: pressure,
            windows: windows,
            emptyMessage: windows.isEmpty ? "No open window needs to be filled right now." : nil,
            bestUseTitle: bestUseTitle,
            bestUseDetail: bestUseDetail,
            bestUseAction: bestUseAction,
            trustWhisper: whisper
        )
    }

    func dayPressureState(
        posture: TodayDayPosture,
        fixedCount: Int,
        flexibleCount: Int
    ) -> TodayDayPressureState {
        switch posture {
        case .stable:
            return TodayDayPressureState(
                title: "The day still has breathing room",
                detail: flexibleCount > 0
                    ? "There is space for one deliberate step and one flexible option if the first block lands."
                    : "The visible work can stay singular without squeezing more into the day.",
                label: "Strong fit",
                state: .success
            )
        case .tight:
            return TodayDayPressureState(
                title: "The day is getting tight",
                detail: "There is still enough room for one meaningful block, but extra switching will make the day noisier.",
                label: "Likely fit",
                state: .selected
            )
        case .drifted:
            return TodayDayPressureState(
                title: "The day drifted off its first plan",
                detail: "Pressure is less about time volume and more about getting back to one believable step.",
                label: "Needs recovery",
                state: .warning
            )
        case .overloaded:
            return TodayDayPressureState(
                title: "Too many asks are touching today",
                detail: "The remaining room is real, but only after the day is lightened back to one safe lane.",
                label: "Compressed",
                state: .warning
            )
        case .recovering:
            return TodayDayPressureState(
                title: "Recovery is already in progress",
                detail: "Use the remaining room for the smallest safe block, not for catching everything up.",
                label: "Recovering",
                state: .selected
            )
        case .lowData:
            return TodayDayPressureState(
                title: "Time shape is present, but certainty is not",
                detail: "The day can still hold one small step, but clarification matters before stronger timing claims.",
                label: "Needs confirmation",
                state: .warning
            )
        case .noPlan:
            return TodayDayPressureState(
                title: "Today has open room",
                detail: fixedCount == 0
                    ? "Nothing is forcing the day yet, so the first step should stay small and real."
                    : "One small commitment is enough to make the day useful.",
                label: "Open",
                state: .default
            )
        }
    }

    func openWindows(
        now: Date,
        posture: TodayDayPosture,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState
    ) -> [TodayOpenWindowState] {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let laneTitles: [(String, String)] = [
            ("Next 45 minutes", hour < 17 ? "A near-term block is still available if the next step stays bounded." : "A short closing block is still available if it stays gentle."),
            ("Later today", "There is still room for one follow-on step if the first block resolves cleanly."),
            ("Protect the evening", "If attention is thinning, preserve one calmer block instead of adding more switching.")
        ]

        var windows: [TodayOpenWindowState] = []
        let candidateActions = focus.primaryActionsForRecovery + freeTime.opportunities.compactMap(\.action)
        for (index, lane) in laneTitles.enumerated() {
            let action = candidateActions.dropFirst(index).first ?? candidateActions.first
            let title: String
            let subtitle: String
            if let action {
                title = lane.0
                subtitle = action.kind == .protectLater
                    ? "Use this room to preserve the next believable block."
                    : lane.1
            } else {
                title = lane.0
                subtitle = "No additional step needs to be forced into this window."
            }
            windows.append(
                TodayOpenWindowState(
                    id: "window-\(index)",
                    title: title,
                    subtitle: subtitle,
                    timingLabel: timingLabelForWindow(index: index, hour: hour),
                    state: posture == .overloaded && index == 0 ? .warning : .default,
                    action: action
                )
            )
        }

        if dailyTargets.items.isEmpty && freeTime.opportunities.isEmpty {
            return []
        }
        return Array(windows.prefix(posture == .stable ? 2 : 3))
    }

    func timingLabelForWindow(index: Int, hour: Int) -> String {
        switch index {
        case 0:
            return hour < 12 ? "Morning room" : hour < 17 ? "Afternoon room" : "Closing room"
        case 1:
            return "Later today"
        default:
            return "Adjust plan"
        }
    }

    func makeRecoveryBloom(
        posture: TodayDayPosture,
        focus: TodayFocusState,
        freeTime: TodayFreeTimeState
    ) -> TodayRecoveryBloomState? {
        guard posture == .drifted || posture == .recovering || posture == .overloaded || posture == .tight else {
            return nil
        }

        let options = recoveryOptions(for: posture, focus: focus, freeTime: freeTime)
        guard options.isEmpty == false else { return nil }

        let title: String
        let subtitle: String
        let explanation: String
        let pressureField: String
        let recoveryLoop: String
        let smallerStepAnchor: String
        let receiptPreview: String
        switch posture {
        case .tight:
            title = "Keep the day believable"
            subtitle = "One light adjustment now is calmer than a mess later."
            explanation = "Recovery here is small on purpose. The app is reducing pressure before the day turns into catch-up theater."
            pressureField = "Pressure field: the day is tight, so extra switching should stay visible."
            recoveryLoop = "Recovery loop: lighten one ask, keep Still Counts available, and review before changing the day."
            smallerStepAnchor = "Smaller step anchor: choose the lightest useful version before adding effort."
            receiptPreview = "Recovery receipt preview: records the lighter path and what stayed unchanged."
        case .drifted:
            title = "Recovery Bloom"
            subtitle = "The day can still recover through one believable step."
            explanation = "The safer path is shown first, and the prior plan stays visible only as background context."
            pressureField = "Pressure field: the first plan drifted, so recovery starts with one believable lane."
            recoveryLoop = "Recovery loop: orient, shrink the next step, and preview the receipt before anything changes."
            smallerStepAnchor = "Smaller step anchor: return through one safe action, not the whole original plan."
            receiptPreview = "Recovery receipt preview: records what changed and what still counts."
        case .overloaded:
            title = "Lighten today"
            subtitle = "The day needs fewer simultaneous asks before effort goes up."
            explanation = "This is not a failure state. The system is narrowing the day so the next step feels real again."
            pressureField = "Pressure field: too many asks are touching today at once."
            recoveryLoop = "Recovery loop: reduce the load, offer the smaller safe next step, and keep review in front."
            smallerStepAnchor = "Smaller step anchor: make the next step small enough to start without sacrificing protected time."
            receiptPreview = "Recovery receipt preview: records the lighter next step, protected time, and Still Counts boundary."
        case .recovering:
            title = "Stay in the recovery lane"
            subtitle = "Use one gentle step to stabilize the rest of the day."
            explanation = "The bloom keeps the next step singular so recovery feels relieving instead of corrective."
            pressureField = "Pressure field: recovery is already active, so the day stays narrowed."
            recoveryLoop = "Recovery loop: continue the lighter path and keep the receipt visible."
            smallerStepAnchor = "Smaller step anchor: stay with the smallest stabilizing block."
            receiptPreview = "Recovery receipt preview: records that recovery continued without turning into catch-up."
        case .stable, .lowData, .noPlan:
            return nil
        }

        return TodayRecoveryBloomState(
            title: title,
            subtitle: subtitle,
            explanation: explanation,
            pressureFieldLabel: pressureField,
            recoveryLoopLabel: recoveryLoop,
            smallerStepAnchorLabel: smallerStepAnchor,
            recoveryReceiptPreviewLabel: receiptPreview,
            options: options
        )
    }

    func recoveryOptions(
        for posture: TodayDayPosture,
        focus: TodayFocusState,
        freeTime: TodayFreeTimeState
    ) -> [TodayRecoveryOptionState] {
        let actions = focus.primaryActionsForRecovery + freeTime.opportunities.compactMap(\.action)
        var options: [TodayRecoveryOptionState] = []

        func append(_ action: TodayInlineAction?, title: String? = nil, detail: String, state: AmbitionVisualState? = nil) {
            guard let action else { return }
            let resolvedTitle = title ?? action.title
            guard options.contains(where: { $0.action.id == action.id || $0.title == resolvedTitle }) == false else { return }
            options.append(
                TodayRecoveryOptionState(
                    id: "\(action.kind.rawValue)-\(resolvedTitle)",
                    title: resolvedTitle,
                    detail: detail,
                    state: state ?? action.state,
                    action: action
                )
            )
        }

        append(actions.first(where: { $0.kind == .split }), title: "Smaller version", detail: "Shrink the next step until it feels safe to start.", state: .selected)
        append(actions.first(where: { $0.kind == .complete || $0.kind == .startStepSession }), title: "Safest step", detail: "If the current step is still doable, stay with the calmest useful action.", state: .success)
        append(actions.first(where: { $0.kind == .reschedule || $0.kind == .defer }), title: "Reschedule gently", detail: "Reschedule the work without turning the day into a failure narrative.", state: .default)
        append(actions.first(where: { $0.kind == .protectLater }), title: "Adjust plan", detail: "Put one cleaner block in Plan instead of squeezing it here.", state: .default)
        append(
            TodayInlineAction(
                kind: .openPlan,
                title: "Accept today's shape",
                systemImage: "calendar",
                state: .default,
                target: actions.first?.target ?? TodayActionTarget()
            ),
            detail: "Let the rest of the day stay lighter and carry the shaping into Plan."
        )

        return Array(options.prefix(4))
    }

    func makeStepSession(
        entryContext: TodayEntryContext,
        focus: TodayFocusState,
        posture: TodayDayPosture,
        shellSummary: GoalShellSummaryState?
    ) -> TodayStepSessionState? {
        guard entryContext.normalized == .stepSession else { return nil }
        let fallbackAction = TodayInlineAction(
            kind: .openPlan,
            title: "Open Time",
            systemImage: "calendar",
            state: .selected,
            target: TodayActionTarget()
        )
        let primary = focus.primaryActionsForRecovery.first(where: { $0.kind != .startStepSession }) ?? fallbackAction

        let title: String
        let subtitle: String
        switch focus {
        case let .planned(state):
            title = state.title
            subtitle = state.reason
        case let .starter(state):
            title = state.title
            subtitle = state.reassurance
        case let .clarification(state):
            title = state.title
            subtitle = state.subtitle
        case let .blocked(state):
            title = state.title
            subtitle = state.nextBestAction
        case let .empty(state):
            title = state.title
            subtitle = state.message
        }

        let detail = posture == .stable
            ? "Step Session is narrowed to one step so the rest of Today can stay quiet."
            : "Step Session is a calmer lane back into the day."

        let closeAction = TodayInlineAction(
            kind: .closeActionClosure,
            title: "Close the loop",
            systemImage: "checkmark.bubble",
            state: .selected,
            target: primary.target
        )
        let pauseAction = TodayInlineAction(
            kind: .pauseStepSession,
            title: "Pause",
            systemImage: "pause.circle",
            state: .default,
            target: primary.target
        )
        let stopAction = TodayInlineAction(
            kind: .stopStepSession,
            title: "Stop session",
            systemImage: "xmark.circle",
            state: .default,
            target: primary.target
        )
        let supportingActions = focus.primaryActionsForRecovery.filter {
            $0.id != primary.id
                && $0.kind != .startStepSession
                && $0.kind != .complete
                && $0.kind != .pauseStepSession
                && $0.kind != .stopStepSession
        }
        let contextReminder = posture == .stable
            ? "One step is in focus. The rest of Today stays available behind it."
            : "One step is in focus. Recovery stays available without changing proof."
        let goalConnection = primary.target.goalID == nil
            ? "Goal context is not attached yet."
            : "Goal context stays attached while this step is in session."

        return TodayStepSessionState(
            title: title,
            subtitle: subtitle,
            detail: detail,
            primaryAction: primary,
            secondaryActions: Array(supportingActions.prefix(2)),
            trustWhisper: shellSummary.map {
                TodayTrustWhisperState(
                    title: "Based on",
                    detail: $0.explanationSummary,
                    state: .selected
                )
            },
            contextReminderLabel: contextReminder,
            goalConnectionLabel: goalConnection,
            timerLabel: "Timer optional",
            sessionControlActions: [pauseAction, stopAction, closeAction],
            receiptGenerationLabel: "Closing the loop opens the receipt preview before proof changes.",
            exitBoundaryLabel: "Stopping the session returns to Today without changing proof or plan."
        )
    }

    func deduplicated(_ actions: [TodayInlineAction]) -> [TodayInlineAction] {
        var seen = Set<String>()
        return actions.filter {
            let key = "\($0.kind.rawValue)-\($0.target.goalID ?? "none")-\($0.target.stepID ?? "none")"
            return seen.insert(key).inserted
        }
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
            kind = .defer
            title = "Defer"
            systemImage = "clock.arrow.circlepath"
            state = .default
        case .askForSmallerStep:
            kind = .split
            title = "Split"
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

    func todayShellSummaries(
        goals: [Goal],
        draftsByGoalID: [String: PersistedGoalDraft],
        actionableSteps: [Step],
        now: Date
    ) async throws -> [TodayActionTarget: GoalShellSummaryState] {
        guard let goalIntelligenceService else { return [:] }

        var targets: [TodayActionTarget] = []
        var requests: [RuntimeGoalIntelligenceRequest] = []
        targets.reserveCapacity(actionableSteps.prefix(3).count + 2)
        requests.reserveCapacity(actionableSteps.prefix(3).count + 2)

        for step in actionableSteps.prefix(3) {
            guard let goal = goals.first(where: { $0.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true }) else {
                continue
            }
            let draft = draftsByGoalID[goal.id]
            let target = TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
            targets.append(target)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: goal.id, draftID: draft?.id),
                    primaryStepID: step.id,
                    includeWhyNow: true
                )
            )
        }

        if let milestoneGoal = goals.sorted(by: { timingSortKey(for: $0.timing) < timingSortKey(for: $1.timing) }).first {
            let draft = draftsByGoalID[milestoneGoal.id]
            let target = TodayActionTarget(goalID: milestoneGoal.id, draftID: draft?.id)
            targets.append(target)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: milestoneGoal.id, draftID: draft?.id),
                    primaryStepID: actionableSteps.first(where: { step in
                        milestoneGoal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == step.id }) == true
                    })?.id ?? shellPrimaryStepID(goal: milestoneGoal, draft: draft),
                    includeWhyNow: true
                )
            )
        }

        let contexts = try await goalIntelligenceService.loadContexts(requests, now: now)
        let projector = GoalShellSummaryProjector()
        return Dictionary(uniqueKeysWithValues: zip(targets, contexts).compactMap { target, context in
            guard let context else { return nil }
            return (target, projector.makeState(from: context))
        })
    }

    func shellPrimaryStepID(goal: Goal?, draft: PersistedGoalDraft?) -> String? {
        let steps = (goal?.plan ?? draft?.stagedPlan)?.sections.flatMap(\.steps) ?? []
        return steps.first(where: { $0.state != .completed && $0.state != .cancelled })?.id ?? steps.first?.id
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
                    title: "Rescheduled",
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
                title: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep) ? "Ritual logged" : "Completion recorded",
                body: HabitGoalSemantics.isHabitLike(goal: goal, step: selectedStep)
                    ? "\"\(selectedStep.title)\" was recorded for today and kept alive as an ongoing rhythm."
                    : "\"\(selectedStep.title)\" is now reflected in native evidence and feedback.",
                state: .success
            )
        case .defer:
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
        case .reschedule:
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
                title: "Rescheduled",
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
                    linkedGoalID: goalID,
                    kind: .goalSupportingTask,
                    route: .captureInbox,
                    goalRelationship: CaptureGoalRelationship(goalID: goalID, relationshipKind: .nextAction)
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
            message = TodayInlineMessage(
                title: "Use Time for Calendar access",
                body: "Today will not request Calendar permission or write calendar blocks. Open Time to make planning calendar-aware from there.",
                state: .warning
            )
        case .split:
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
                title: "A calmer next step is ready",
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
                ?? "\(selectedStep.title) matters because it carries \(goal.title.lowercased()) forward with visible evidence."
            message = TodayInlineMessage(
                title: "Why this matters",
                body: explanation,
                state: .selected
            )
        case .startStepSession, .pauseStepSession, .stopStepSession, .closeActionClosure, .openDetail, .openPlan, .protectLater, .dismissCelebration:
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
            TodayPillState(id: "steps", title: "\(actionableCount) live steps", icon: "bolt.fill", state: .default)
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
        completion: (done: Int, total: Int),
        shellSummaries: [TodayActionTarget: GoalShellSummaryState]
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
                    kind: .defer,
                    title: "Defer",
                    systemImage: "clock.arrow.circlepath",
                    state: .default,
                    target: TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
                ),
                shellSummary: shellSummaries[TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)]
            )
        }

        return TodayDailyTargetsState(
            title: mode == .empty ? "No live targets yet" : "Daily targets",
            subtitle: mode == .empty
                ? "Once a goal exists, Today will surface only the few steps worth acting on."
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
        evidence: [ProgressEvidence],
        shellSummaries: [TodayActionTarget: GoalShellSummaryState]
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
                    subtitle: "There is a blocker, but Today still offers a recommended step instead of a dead end.",
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
                    message: "Today stays calm when there is no clear next step. Untimed work can wait until it actually fits.",
                    actions: []
                )
            )
        }

        let draft = draftsByGoalID[goal.id]
        let target = TodayActionTarget(goalID: goal.id, stepID: step.id, draftID: draft?.id)
        let progress = focusProgress(for: step, feedback: feedback, evidence: evidence)
        let selection = rankedSelections.first(where: { $0.goal.id == goal.id && $0.step.id == step.id })
        let shellSummary = shellSummaries[target]

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
                        TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: target),
                        TodayInlineAction(kind: .defer, title: "Defer", systemImage: "clock.arrow.circlepath", state: .default, target: target),
                        TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .default, target: target),
                        TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: target),
                        TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
                    ],
                    shellSummary: shellSummary
                )
            )
        }

        return .planned(
            TodayFocusPlannedState(
                title: step.title,
                subtitle: goal.title,
                reason: selection?.candidate.whyNow?.conciseReason ?? focusReason(for: goal, step: step),
                timingLabel: timingLabel(for: step.timing, goalMode: goal.mode),
                energyLabel: shellSummary?.indicators.first(where: { $0.kind == .energy })?.title ?? energyLabel(for: goal.mode),
                progress: progress,
                supportingText: supportingText(for: goal, step: step),
                actions: [
                    TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
                    TodayInlineAction(kind: .defer, title: "Defer", systemImage: "clock.arrow.circlepath", state: .default, target: target),
                    TodayInlineAction(kind: .reschedule, title: "Reschedule", systemImage: "forward.fill", state: .warning, target: target),
                    TodayInlineAction(kind: .split, title: "Split", systemImage: "scissors", state: .selected, target: target),
                    TodayInlineAction(kind: .protectLater, title: "Adjust plan", systemImage: "calendar.badge.clock", state: .default, target: target),
                    TodayInlineAction(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default, target: target),
                    TodayInlineAction(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
                ],
                shellSummary: shellSummary
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
                : "These are valid steps when the day opens up, especially for untimed, delegated, or exploratory work.",
            opportunities: Array(opportunities.prefix(3))
        )
    }

    func makeMilestone(
        goals: [Goal],
        draftsByGoalID: [String: PersistedGoalDraft],
        shellSummaries: [TodayActionTarget: GoalShellSummaryState]
    ) -> TodayMilestoneState {
        let ordered = goals.sorted { lhs, rhs in
            timingSortKey(for: lhs.timing) < timingSortKey(for: rhs.timing)
        }
        guard let goal = ordered.first else {
            return TodayMilestoneState(
                title: "Milestone prompt",
                subtitle: "No active milestone yet",
                prompt: "Once a goal exists, Today will pull the next milestone cue from the real plan.",
                confidenceLabel: "Waiting on first goal",
                action: nil,
                shellSummary: nil
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

        let target = TodayActionTarget(goalID: goal.id, draftID: draftsByGoalID[goal.id]?.id)
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
                target: target
            ),
            shellSummary: shellSummaries[target]
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
            subtitle: "Ask for help when the next step is still too large or too vague.",
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
            return "This step supports \(goal.actor.displayName) without turning the relationship into compliance work."
        }
        if HabitGoalSemantics.isHabitLike(goal: goal, step: step) {
            return "Consistency matters more than intensity here. A smaller clean repetition is better than a loud miss."
        }
        return step.summary ?? goal.summary ?? "This is the cleanest next step from the current native plan."
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
            return "A non-punitive support step"
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
        case .startStepSession, .pauseStepSession, .stopStepSession:
            return nil
        case .defer:
            return .delay
        case .reschedule:
            return .skip
        case .split:
            return .askForSmallerStep
        case .askForHelp:
            return .stuck
        case .complete, .closeActionClosure, .createReminder, .createCalendarEvent, .askWhyThisMatters, .markNotRelevant, .openDetail, .openPlan, .protectLater, .quickLog, .dismissCelebration:
            return nil
        }
    }

    func note(for kind: TodayActionKind, step: Step) -> String {
        switch kind {
        case .startStepSession:
            return "Started step from Today."
        case .pauseStepSession:
            return "Paused Step Session from Today."
        case .stopStepSession:
            return "Stopped Step Session from Today."
        case .complete:
            return "Completed from Today."
        case .defer:
            return "Deferred from Today to reduce pressure."
        case .reschedule:
            return "Rescheduled from Today without punitive language."
        case .split:
            return "Asked for a smaller version from Today."
        case .askWhyThisMatters:
            return "Asked why this matters from Today."
        case .protectLater:
            return "Rescheduled from Today."
        case .quickLog:
            return "Quick log from Today."
        case .createReminder:
            return "Created reminder from Today."
        case .createCalendarEvent:
            return "Created calendar event from Today."
        case .markNotRelevant:
            return "Marked not relevant from Today."
        case .closeActionClosure:
            return "Closed the loop from Today."
        case .openDetail, .openPlan, .askForHelp, .dismissCelebration:
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

private extension TodayFocusState {
    var shellSummary: GoalShellSummaryState? {
        switch self {
        case let .planned(state):
            return state.shellSummary
        case let .starter(state):
            return state.shellSummary
        case .clarification, .blocked, .empty:
            return nil
        }
    }

    var primaryActionsForRecovery: [TodayInlineAction] {
        switch self {
        case let .planned(state):
            return state.actions
        case let .starter(state):
            return state.actions
        case let .clarification(state):
            return state.actions
        case let .blocked(state):
            return state.actions
        case let .empty(state):
            return state.actions
        }
    }
}
