import XCTest
@testable import Ambitions

final class ExecutionResilienceProjectorTests: XCTestCase {
    func testEmptyBaselineIsStableAndCalendarFree() {
        let assessment = projector.assess(ExecutionResilienceInput(generatedAt: now))

        XCTAssertEqual(assessment.status, .stable)
        XCTAssertTrue(assessment.disruptions.isEmpty)
        XCTAssertEqual(assessment.recoveryOptions.first?.strategy, .doSmallestNextStep)
        XCTAssertEqual(assessment.recommendedRecoveryOptionID, "option.keep.stable")
        XCTAssertEqual(assessment.privacy, .standard)
        XCTAssertTrue(assessment.localOnly)
    }

    func testMissedActionCreatesSmallestUsefulNextStepOptionWithoutLedgerWrite() {
        let goal = makeGoal(id: "goal-slip", title: "Send follow-up", mode: .project, domain: .career, dueAt: iso(hours: 24))
        let believability = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: reality(openMinutes: 60, busyRanges: [(0, 180)], calendar: false, lens: .work),
                effortMinutes: 90,
                consequence: .high,
                importance: .high
            )
        )
        let skipped = EventLedgerEntry(
            id: "ledger-skipped",
            kind: .actionSkipped,
            occurredAt: DomainTimestamp.string(from: now),
            source: .today,
            goalID: goal.id,
            title: "Action skipped"
        )

        let assessment = projector.assess(
            ExecutionResilienceInput(
                generatedAt: now,
                activeContextLens: .work,
                believabilityAssessments: [believability],
                eventLedgerEntries: [skipped]
            )
        )

        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .missedAction })
        XCTAssertTrue(assessment.recoveryOptions.contains { $0.strategy == .doSmallestNextStep })
        XCTAssertNotNil(assessment.smallestUsefulNextStep)
        XCTAssertEqual(assessment.eventLedgerEntryIDs, ["ledger-skipped"])
        XCTAssertFalse(assessment.eventLedgerEntryIDs.contains { $0.hasPrefix("ledger.resilience") })
    }

    func testCribDeadlineWorkIsProtectedAndPassivePianoDefersCalmly() {
        let crib = makeGoal(id: "goal-crib", title: "Build the baby crib before the due date", mode: .project, domain: .home, dueAt: iso(hours: 36))
        let piano = makeGoal(id: "goal-piano", title: "Learn piano", mode: .learning, domain: .creativity, dueAt: nil, state: .paused)
        let snapshot = reality(openMinutes: 120, busyRanges: [(120, 420)], calendar: false, lens: .freeTime)
        let cribAssessment = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: crib,
                generatedAt: now,
                activeContextLens: .freeTime,
                realitySnapshot: snapshot,
                effortMinutes: 150,
                consequence: .high,
                importance: .high
            )
        )
        let pianoAssessment = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: piano,
                generatedAt: now,
                activeContextLens: .freeTime,
                realitySnapshot: snapshot,
                effortMinutes: 30,
                consequence: .low,
                importance: .low
            )
        )

        let assessment = projector.assess(
            ExecutionResilienceInput(
                generatedAt: now,
                activeContextLens: .freeTime,
                believabilityAssessments: [pianoAssessment, cribAssessment],
                realitySnapshot: snapshot
            )
        )

        XCTAssertTrue(assessment.protectedHighPriorityWork.contains { $0.relatedGoalID == "goal-crib" })
        XCTAssertTrue(assessment.passiveWorkDeferredCalmly.contains { $0.relatedGoalID == "goal-piano" })
        XCTAssertTrue(assessment.displacedLowerPriorityWork.contains { $0.relatedGoalID == "goal-piano" })
        XCTAssertEqual(assessment.recommendedRecoveryOption?.strategy, .protectDeadlineWork)
        XCTAssertTrue(assessment.recommendedRecoveryOption?.protectsHighPriorityWork == true)
        XCTAssertTrue(assessment.recommendedRecoveryOption?.defersPassiveOrFlexibleWork == true)
    }

    func testOneTimeWorkCommitmentWithNoOpenWindowBecomesAtRiskRecovery() {
        let capture = Capture(
            id: "capture-kaylee",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Create spreadsheet and send it to Kaylee by EOD Tuesday",
            sourceType: .todayQuickCapture,
            status: .scheduled,
            linkedGoalID: nil,
            kind: .oneTimeCommitment,
            route: .timeSeed,
            triageStatus: .assumedRoute,
            commitmentKind: .oneTime,
            deadlineText: "EOD Tuesday",
            deadlineKind: .hard,
            contextLensHint: .work,
            priorityHints: CapturePriorityHints(importance: .high, urgency: .high, consequence: .high, deadline: .high, effort: .high)
        )
        let snapshot = reality(openMinutes: 0, busyRanges: [(0, 480)], calendar: true, lens: .work)
        let believability = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .captureCommitment,
                capture: capture,
                planID: "plan-work",
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: snapshot,
                effortMinutes: 90
            )
        )

        let assessment = projector.assess(
            ExecutionResilienceInput(
                generatedAt: now,
                activeContextLens: .work,
                believabilityAssessments: [believability],
                realitySnapshot: snapshot,
                captures: [capture],
                timeID: "time-work"
            )
        )

        XCTAssertEqual(assessment.status, .atRisk)
        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .noOpenWindow })
        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .slippedDeadline })
        XCTAssertTrue(assessment.recoveryOptions.contains { $0.strategy == .openTime })
        XCTAssertTrue(assessment.recoveryOptions.allSatisfy { $0.relatedCommandKind != .scheduleItem })
    }

    func testWaitingBlockedItemsStopPressuringTodayThroughHelperOnly() {
        let waiting = Capture(
            id: "capture-waiting",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Waiting on Kaylee",
            sourceType: .todayQuickCapture,
            status: .waiting,
            linkedGoalID: nil,
            kind: .waitingItem,
            route: .waiting,
            triageStatus: .waiting,
            commitmentKind: .waiting,
            waitingMetadata: CaptureWaitingMetadata(waitingOn: "Kaylee")
        )
        let believability = believabilityProjector.assess(
            GoalBelievabilityInput(subjectKind: .captureCommitment, capture: waiting, generatedAt: now)
        )

        let assessment = projector.assess(
            ExecutionResilienceInput(generatedAt: now, believabilityAssessments: [believability], captures: [waiting])
        )

        XCTAssertEqual(assessment.status, .blocked)
        XCTAssertTrue(assessment.waitingOrBlockedRemovedFromPressure.contains { $0.relatedCaptureID == "capture-waiting" })
        XCTAssertEqual(projector.nowRecoveryState(from: assessment), .blocked)
        XCTAssertEqual(projector.nowRecoverySummary(from: assessment).level, .low)
        XCTAssertEqual(assessment.recommendedRecoveryOption?.strategy, .moveToWaiting)
    }

    func testOverloadedDaySuggestsSplitDeferAndClarifyOptions() {
        let overloaded = reality(openMinutes: 30, busyRanges: [(0, 600)], calendar: false, lens: .work)
        let underdefined = believabilityProjector.assess(
            GoalBelievabilityInput(subjectKind: .goal, generatedAt: now, activeContextLens: .work, realitySnapshot: overloaded)
        )
        let passive = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: makeGoal(id: "goal-piano", title: "Learn piano", mode: .learning, domain: .creativity, dueAt: nil, state: .paused),
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: overloaded
            )
        )

        let assessment = projector.assess(
            ExecutionResilienceInput(
                generatedAt: now,
                activeContextLens: .work,
                believabilityAssessments: [underdefined, passive],
                realitySnapshot: overloaded
            )
        )

        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .underdefinedNextStep })
        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .overloadedDay })
        XCTAssertTrue(assessment.recoveryOptions.contains { $0.strategy == .doSmallestNextStep })
        XCTAssertTrue(assessment.recoveryOptions.contains { $0.strategy == .deferPassiveWork })
        XCTAssertTrue(assessment.recoveryOptions.contains { $0.strategy == .clarifyNextStep })
    }

    func testScopeIncreaseAndDeliverableAddedCreateRecoveryRecommendation() {
        let scopeCapture = Capture(
            id: "capture-scope",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Add two songs to the album",
            sourceType: .todayQuickCapture,
            status: .goalBound,
            linkedGoalID: "goal-album",
            kind: .deliverableSeed,
            route: .deliverableSeed,
            triageStatus: .routed,
            commitmentKind: .goalSupporting,
            goalRelationship: CaptureGoalRelationship(goalID: "goal-album", relationshipKind: .deliverable),
            deliverableHint: "song"
        )
        let deliverable = believabilityProjector.assess(
            GoalBelievabilityInput(subjectKind: .deliverableSeed, capture: scopeCapture, generatedAt: now, activeContextLens: .creative)
        )
        let scope = believabilityProjector.assess(
            GoalBelievabilityInput(subjectKind: .scopeChangeSeed, capture: scopeCapture, generatedAt: now, activeContextLens: .creative)
        )

        let assessment = projector.assess(
            ExecutionResilienceInput(generatedAt: now, believabilityAssessments: [deliverable, scope], captures: [scopeCapture])
        )

        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .deliverableAdded })
        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .scopeIncrease })
        XCTAssertTrue(assessment.recoveryOptions.contains { $0.strategy == .reduceScope || $0.strategy == .clarifyNextStep })
        XCTAssertNotNil(assessment.recommendation)
    }

    func testCalendarConflictMarkerHandledWithoutCalendarRequirementOrWrites() {
        let snapshot = reality(openMinutes: 120, busyRanges: [(30, 120), (60, 180)], calendar: true, lens: .work)
        let goal = makeGoal(id: "goal-work", title: "Finish work item", mode: .project, domain: .career, dueAt: iso(hours: 12))
        let believability = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: snapshot,
                effortMinutes: 60,
                consequence: .high,
                importance: .high
            )
        )

        let assessment = projector.assess(
            ExecutionResilienceInput(generatedAt: now, believabilityAssessments: [believability], realitySnapshot: snapshot)
        )

        XCTAssertTrue(assessment.disruptions.contains { $0.kind == .calendarConflict })
        XCTAssertEqual(assessment.privacy, .calendarDerived)
        XCTAssertTrue(assessment.recoveryOptions.contains { $0.strategy == .openTime })
        XCTAssertTrue(assessment.recoveryOptions.allSatisfy { $0.relatedCommandKind != .scheduleItem })
    }

    func testExplanationGenerationReferencesRecoveryPriorityDeferralAndCalendarEvidence() {
        let explanation = RecommendationExplanation(
            id: "explanation-priority",
            type: .whyPrioritized,
            title: "Why protected",
            summary: "Deadline work is protected.",
            recommendationTitle: "Protect work",
            lastUpdatedAt: DomainTimestamp.string(from: now),
            source: .recommendation
        )
        let crib = makeGoal(id: "goal-crib", title: "Build crib", mode: .project, domain: .home, dueAt: iso(hours: 24))
        let cribAssessment = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: crib,
                generatedAt: now,
                activeContextLens: .freeTime,
                realitySnapshot: reality(openMinutes: 60, busyRanges: [], calendar: false, lens: .freeTime),
                effortMinutes: 90,
                consequence: .high,
                importance: .high
            )
        )
        let assessment = projector.assess(
            ExecutionResilienceInput(
                generatedAt: now,
                believabilityAssessments: [cribAssessment],
                recommendationExplanations: [explanation]
            )
        )

        let recoveryExplanation = projector.makeExplanation(for: assessment, option: assessment.recommendedRecoveryOption, type: .whyRecovered)

        XCTAssertEqual(recoveryExplanation.type, .whyRecovered)
        XCTAssertTrue(recoveryExplanation.evidenceCategories.contains(.recovery))
        XCTAssertTrue(recoveryExplanation.containsPriorityRealityEvidence || recoveryExplanation.containsDeadlineEvidence)
        XCTAssertEqual(recoveryExplanation.relations.goalIDs, ["goal-crib"])
        XCTAssertFalse(recoveryExplanation.referencesEventLedger)
    }

    func testCommandMappingIsRepresentationalAndUnsupportedExecutionHasNoSideEffects() async throws {
        let goal = makeGoal(id: "goal-crib", title: "Build crib", mode: .project, domain: .home, dueAt: iso(hours: 24))
        let believability = believabilityProjector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .freeTime,
                realitySnapshot: reality(openMinutes: 30, busyRanges: [], calendar: false, lens: .freeTime),
                effortMinutes: 90,
                consequence: .high,
                importance: .high
            )
        )
        let assessment = projector.assess(
            ExecutionResilienceInput(generatedAt: now, believabilityAssessments: [believability])
        )
        let option = try XCTUnwrap(assessment.recommendedRecoveryOption)
        let command = try XCTUnwrap(projector.command(for: option, assessment: assessment))
        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor(eventLedger: ledger)

        XCTAssertEqual(command.kind, .recoverAction)
        XCTAssertEqual(command.payload.metadata["resilienceAssessmentID"], assessment.id)
        XCTAssertEqual(command.payload.metadata["recoveryStrategy"], option.strategy.rawValue)

        let result = await executor.execute(command, context: CommandExecutionContext(now: now))
        let events = try await ledger.fetchRecent(limit: 10)

        XCTAssertEqual(result.status, .unsupported)
        XCTAssertEqual(result.metadata["blockedBy"], "owning_system_not_implemented")
        XCTAssertTrue(events.isEmpty)
    }

    func testDeterministicOutputOrdering() {
        let crib = makeGoal(id: "goal-crib", title: "Build crib", mode: .project, domain: .home, dueAt: iso(hours: 24))
        let piano = makeGoal(id: "goal-piano", title: "Learn piano", mode: .learning, domain: .creativity, dueAt: nil, state: .paused)
        let snapshot = reality(openMinutes: 90, busyRanges: [(90, 240)], calendar: false, lens: .freeTime)
        let inputs = [
            believabilityProjector.assess(GoalBelievabilityInput(subjectKind: .goal, goal: piano, generatedAt: now, activeContextLens: .freeTime, realitySnapshot: snapshot, effortMinutes: 30, consequence: .low, importance: .low)),
            believabilityProjector.assess(GoalBelievabilityInput(subjectKind: .goal, goal: crib, generatedAt: now, activeContextLens: .freeTime, realitySnapshot: snapshot, effortMinutes: 120, consequence: .high, importance: .high))
        ]
        let input = ExecutionResilienceInput(generatedAt: now, activeContextLens: .freeTime, believabilityAssessments: inputs, realitySnapshot: snapshot)

        let first = projector.assess(input)
        let second = projector.assess(input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.disruptions.map(\.id), first.disruptions.map(\.id).sorted { lhs, rhs in
            let left = first.disruptions.first { $0.id == lhs }?.severity ?? .none
            let right = first.disruptions.first { $0.id == rhs }?.severity ?? .none
            if left != right { return rank(left) > rank(right) }
            return lhs < rhs
        })
        XCTAssertEqual(first.protectedHighPriorityWork.map(\.id), first.protectedHighPriorityWork.map(\.id).sorted())
    }
}

private extension ExecutionResilienceProjectorTests {
    var projector: ExecutionResilienceProjector { ExecutionResilienceProjector() }
    var believabilityProjector: GoalBelievabilityProjector { GoalBelievabilityProjector() }
    var now: Date { Date(timeIntervalSince1970: 1_777_113_600) }

    func iso(hours: TimeInterval) -> String {
        DomainTimestamp.string(from: now.addingTimeInterval(hours * 3_600))
    }

    func makeGoal(
        id: String,
        title: String,
        mode: GoalMode,
        domain: LifeDomainKey,
        dueAt: String?,
        state: GoalLifecycleState = .active
    ) -> Goal {
        let actor = GoalActor.localOwner
        let timing = GoalTiming(
            tempo: dueAt == nil ? .untimed : .deadlineBased,
            timingType: dueAt == nil ? .logWhenDone : .dueAt,
            startsOn: nil,
            dueAt: dueAt,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
        let step = Step(
            id: "step-\(id)",
            sectionID: "section-\(id)",
            title: "Next action for \(title)",
            summary: nil,
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Done"],
            actionability: StepActionability(
                action: "Start \(title)",
                completionDefinition: "Done",
                evidenceOfCompletion: ["Done"],
                fallbackMicroStep: "Open the first step.",
                contextRequirements: []
            )
        )
        let strategy = PlanningStrategy(
            strategyKind: .sequential,
            allowParallelSteps: false,
            maxActiveSteps: 1,
            preferredSectionOrder: [.activeSteps],
            defaultStepType: .actionUnit,
            autoGenerateReviewSection: false,
            preferShortSteps: true,
            revisitCadenceDays: 7
        )
        let progress = ProgressStrategy(
            metricKind: .stepCompletion,
            rollupMethod: .ratio,
            targetStepCount: 1,
            targetEvidenceCount: nil,
            targetMinutes: nil,
            supportsUntimedProgress: true,
            countsChildGoals: false,
            countsSupportGoals: false
        )
        let section = PlanSection(
            id: "section-\(id)",
            goalID: id,
            title: "Active",
            summary: nil,
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let plan = GoalPlan(
            id: "plan-\(id)",
            goalID: id,
            version: 1,
            generatedAt: DomainTimestamp.string(from: now),
            summary: nil,
            strategy: strategy,
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: id, planVersion: 1, isValid: true, issueCount: 0, issues: [])
        )
        return Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: id,
            revision: 1,
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            state: state,
            title: title,
            summary: nil,
            mode: mode,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: timing,
            planningStrategy: strategy,
            progressStrategy: progress,
            plan: plan,
            lifeGraph: LifeGraphContext(domains: [LifeDomainAssignment(domain: domain)])
        )
    }

    func reality(
        openMinutes: Int,
        busyRanges: [(startMinute: Int, endMinute: Int)],
        calendar: Bool,
        lens: NowContextLens
    ) -> RealitySnapshot {
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(TimeInterval(max(openMinutes, 480) * 60)))
        let busy = busyRanges.enumerated().map { index, range in
            RealityWindow(
                id: "busy-\(index)",
                kind: calendar ? .calendarDerivedBusy : .blockedBusy,
                source: calendar ? .calendarDerived : .userDefined,
                start: now.addingTimeInterval(TimeInterval(range.startMinute * 60)),
                end: now.addingTimeInterval(TimeInterval(range.endMinute * 60)),
                title: "Busy",
                contextLens: lens
            )
        }
        let context = calendar
            ? CalendarDerivedContext(
                permissionState: .readWrite,
                observedRangeStart: horizon.start,
                observedRangeEnd: horizon.end,
                derivedBusyWindowCount: busyRanges.count,
                userInitiatedPlanAction: "Find real open windows",
                explanation: "Calendar-derived busy windows stayed local."
            )
            : nil
        return RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                activeContextLens: lens,
                protectedWindows: calendar ? [] : busy,
                calendarBusyWindows: calendar ? busy : [],
                calendarContext: context,
                deadlineHints: [now.addingTimeInterval(48 * 3_600)],
                minimumWindowMinutes: 15
            )
        )
    }

    func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none: 0
        case .low: 1
        case .moderate: 2
        case .elevated: 3
        case .high: 4
        case .critical: 5
        }
    }
}
