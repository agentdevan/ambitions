import AmbitionsDesignSystem
import Foundation

struct TodayReadModelProjector {
    let selector: PlanningNextStepSelector

    func project(
        mode: TodayExperienceMode,
        snapshot: RepositoryBackedTodayService.Snapshot,
        activeGoals: [Goal],
        hero: TodayHeroState,
        support: TodaySupportLayerState,
        now: Date,
        entryContext: TodayEntryContext
    ) -> TodayExecutionViewState {
        let activeLens = activeContextLens(
            entryContext: entryContext,
            goals: activeGoals,
            captures: snapshot.captures
        )
        let reality = makeRealitySnapshot(now: now, lens: activeLens, goals: activeGoals, captures: snapshot.captures)
        let believabilityProjector = GoalBelievabilityProjector()
        let goalAssessments = activeGoals.flatMap { goal in
            goalBelievabilityInputs(
                goal: goal,
                reality: reality,
                now: now,
                activeLens: activeLens,
                eventLedger: snapshot.eventLedger
            ).map {
                believabilityProjector.assess($0)
            }
        }
        let captureAssessments = snapshot.captures.prefix(8).map { capture in
            believabilityProjector.assess(
                GoalBelievabilityInput(
                    subjectKind: .captureCommitment,
                    capture: capture,
                    planID: capture.route == .planSeed ? "plan.today" : nil,
                    generatedAt: now,
                    activeContextLens: activeLens,
                    realitySnapshot: reality,
                    eventLedgerEntries: snapshot.eventLedger
                )
            )
        }
        let believability = goalAssessments + captureAssessments
        let believabilityExplanations = believability.prefix(6).map {
            believabilityProjector.makeExplanation(for: $0, type: .whyPrioritized)
        }
        let nowState = CanonicalNowStateProjector(selector: selector).project(
            input: NowStateProjectionInput(
                now: now,
                activeContextLens: activeLens,
                lensSource: entryContext == .recovery ? .recovery : .domain,
                goals: snapshot.goals,
                captures: snapshot.captures,
                progressEvidence: snapshot.evidence,
                feedbackEvents: snapshot.feedback,
                eventLedgerEntries: snapshot.eventLedger,
                recommendationExplanations: believabilityExplanations
            )
        )
        let resilienceProjector = ExecutionResilienceProjector()
        let resilience = resilienceProjector.assess(
            ExecutionResilienceInput(
                generatedAt: now,
                activeContextLens: activeLens,
                believabilityAssessments: believability,
                realitySnapshot: reality,
                nowState: nowState,
                captures: snapshot.captures,
                eventLedgerEntries: snapshot.eventLedger,
                recommendationExplanations: believabilityExplanations,
                planID: "plan.today"
            )
        )
        let recoveryExplanation = resilienceProjector.makeExplanation(
            for: resilience,
            option: resilience.recommendedRecoveryOption,
            type: resilience.status == .stable ? .whyNow : .whyRecovered
        )
        let oneStepGoalsProjection = oneStepGoalsProjection(
            from: snapshot.captures,
            goals: activeGoals,
            now: now
        )

        return TodayExecutionProjector().project(
            TodayExecutionProjectionInput(
                mode: mode,
                legacyHero: hero,
                legacySupport: support,
                nowState: nowState,
                realitySnapshot: reality,
                believabilityAssessments: believability,
                resilienceAssessment: resilience,
                explanations: believabilityExplanations + [recoveryExplanation],
                captures: snapshot.captures,
                oneStepGoalsProjection: oneStepGoalsProjection
            )
        )
    }
}

private extension TodayReadModelProjector {
    func oneStepGoalsProjection(from captures: [Capture], goals: [Goal], now: Date) -> OneStepGoalsProjection {
        let oneStepGoals = captures.compactMap { capture -> OneStepGoal? in
            guard capture.linkedGoalID == nil else { return nil }
            switch capture.kind {
            case .oneTimeCommitment, .deadlineTask:
                break
            case .raw, .goalSeed, .goalSupportingTask, .deliverableSeed, .waitingItem, .optionalSomeday, .archiveItem:
                return nil
            }

            return OneStepGoal(
                id: OneStepGoalID(rawValue: "capture.\(capture.id)"),
                title: capture.rawText,
                note: nil,
                lifeAreaID: nil,
                status: oneStepGoalStatus(for: capture),
                timing: OneStepGoalTimingMetadata(
                    dueAt: nil,
                    dueLabel: capture.deadlineText,
                    reminderAt: nil,
                    reminderLabel: nil,
                    reviewAfter: nil
                ),
                source: .capture,
                sourceCaptureID: capture.id,
                createdAt: capture.createdAt,
                updatedAt: capture.updatedAt,
                lastReferencedAt: DomainTimestamp.string(from: now)
            )
        }

        return OneStepGoalProjector().projection(
            from: OneStepGoalProjector.Input(
                oneStepGoals: oneStepGoals,
                goals: goals,
                includeArchived: false,
                maxOneStepGoalsPerArea: 3
            )
        )
    }

    func oneStepGoalStatus(for capture: Capture) -> OneStepGoalStatus {
        switch capture.status {
        case .scheduled:
            return .scheduled
        case .waiting, .delegated:
            return .waiting
        case .optionalSomeday:
            return .parked
        case .archived:
            return .archived
        case .needsTriage, .seed:
            return .reviewLater
        case .actionable, .goalBound:
            return capture.deadlineKind == .hard ? .today : .ready
        }
    }

    func activeContextLens(entryContext: TodayEntryContext, goals: [Goal], captures: [Capture]) -> NowContextLens {
        switch entryContext.normalized {
        case .recovery:
            return .recovery
        case .stepSession:
            return .deepFocus
        case .standard, .focus:
            break
        }

        if let captureLens = captures.compactMap(\.contextLensHint).first {
            return captureLens
        }

        let goalLenses = goals.compactMap { goal -> NowContextLens? in
            guard let domain = goal.lifeGraph?.domains.first?.domain else { return nil }
            switch domain {
            case .career, .education:
                return .work
            case .finance, .home:
                return .admin
            case .creativity:
                return .creative
            case .health:
                return .recovery
            case .relationships, .personalGrowth:
                return .personal
            }
        }

        return goalLenses.first ?? .all
    }

    func makeRealitySnapshot(now: Date, lens: NowContextLens, goals: [Goal], captures: [Capture]) -> RealitySnapshot {
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(24 * 60 * 60))
        let deadlineHints = deadlineDates(goals: goals, captures: captures)

        return RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                activeContextLens: lens,
                deadlineHints: deadlineHints,
                minimumWindowMinutes: 30
            )
        )
    }

    func goalBelievabilityInputs(
        goal: Goal,
        reality: RealitySnapshot,
        now: Date,
        activeLens: NowContextLens,
        eventLedger: [EventLedgerEntry]
    ) -> [GoalBelievabilityInput] {
        let steps = goal.plan?.sections.flatMap(\.steps).filter { $0.state != .completed && $0.state != .cancelled } ?? []
        let selectedSteps = steps.isEmpty ? [nil] : Array(steps.prefix(2).map(Optional.some))

        return selectedSteps.map { step in
            GoalBelievabilityInput(
                subjectKind: step == nil ? .goal : .goalNextAction,
                goal: goal,
                step: step,
                planID: goal.plan?.id,
                generatedAt: now,
                activeContextLens: activeLens,
                realitySnapshot: reality,
                eventLedgerEntries: eventLedger
            )
        }
    }

    func deadlineDates(goals: [Goal], captures: [Capture]) -> [Date] {
        let goalDates = goals.flatMap { goal -> [Date] in
            let goalDate = date(from: goal.timing.dueAt ?? goal.timing.targetBy ?? goal.timing.windowEnd)
            let stepDates = goal.plan?.sections.flatMap(\.steps).compactMap { step in
                date(from: step.timing.dueAt ?? step.timing.targetBy ?? step.timing.windowEnd)
            } ?? []

            return [goalDate].compactMap { $0 } + stepDates
        }

        let captureDates = captures.compactMap { capture -> Date? in
            guard capture.deadlineKind == .hard || capture.priorityHints.deadline == .high || capture.priorityHints.deadline == .critical else {
                return nil
            }
            return date(from: capture.revisitAfter)
        }

        return goalDates + captureDates
    }

    func date(from value: String?) -> Date? {
        guard let value else { return nil }
        if let full = DomainTimestamp.date(from: value) { return full }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}
