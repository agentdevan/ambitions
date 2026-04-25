import XCTest
@testable import Ambitions

final class GoalBelievabilityProjectorTests: XCTestCase {
    func testBaselineAssessmentWorksWithoutRealitySnapshotOrCalendar() {
        let goal = makeGoal(id: "goal-baseline", title: "Draft proposal", mode: .project, domain: .career, dueAt: iso(hours: 240))

        let assessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .work,
                effortMinutes: 45,
                consequence: .moderate,
                importance: .moderate
            )
        )

        XCTAssertEqual(assessment.status, .believable)
        XCTAssertEqual(assessment.capacityFit.summary, "No Reality Snapshot is attached, so this uses a baseline capacity assumption.")
        XCTAssertTrue(assessment.assumptions.contains { $0.fieldKey == "capacity" })
        XCTAssertFalse(assessment.hasCalendarDerivedEvidence)
        XCTAssertEqual(assessment.privacy, .standard)
        XCTAssertTrue(assessment.localOnly)
    }

    func testBelievableGoalUsesEnoughCapacityFromRealitySnapshot() {
        let goal = makeGoal(id: "goal-roomy", title: "Prepare outline", mode: .project, domain: .career, dueAt: iso(hours: 240))
        let snapshot = reality(openMinutes: 240, busyRanges: [], calendar: false, lens: .work)

        let assessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: snapshot,
                effortMinutes: 60,
                consequence: .moderate,
                importance: .high
            )
        )

        XCTAssertEqual(assessment.status, .believable)
        XCTAssertTrue(assessment.signals.contains(.enoughCapacity))
        XCTAssertEqual(assessment.relatedRealitySnapshotID, snapshot.id)
        XCTAssertEqual(assessment.capacityFit.availableOpenMinutes, 240)
    }

    func testTightGoalWithLimitedCapacity() {
        let goal = makeGoal(id: "goal-tight", title: "Submit draft", mode: .project, domain: .career, dueAt: iso(hours: 10))
        let snapshot = reality(openMinutes: 60, busyRanges: [(60, 240)], calendar: false, lens: .work)

        let assessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: snapshot,
                effortMinutes: 90,
                consequence: .moderate,
                importance: .high
            )
        )

        XCTAssertEqual(assessment.status, .tight)
        XCTAssertTrue(assessment.signals.contains(.limitedCapacity))
        XCTAssertTrue(assessment.reasons.contains { $0.summary.contains("tight") })
    }

    func testAtRiskDeadlineBoundCommitmentWithNoOpenWindow() {
        let capture = Capture(
            id: "capture-kaylee",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Create spreadsheet and send it to Kaylee by EOD Tuesday",
            sourceType: .todayQuickCapture,
            status: .scheduled,
            linkedGoalID: nil,
            kind: .oneTimeCommitment,
            route: .planSeed,
            triageStatus: .assumedRoute,
            commitmentKind: .oneTime,
            deadlineText: "EOD Tuesday",
            deadlineKind: .hard,
            contextLensHint: .work,
            priorityHints: CapturePriorityHints(importance: .high, urgency: .high, consequence: .high, deadline: .high, effort: .high)
        )
        let snapshot = reality(openMinutes: 0, busyRanges: [(0, 240)], calendar: true, lens: .work)

        let assessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .captureCommitment,
                capture: capture,
                planID: "plan-seed",
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: snapshot,
                effortMinutes: 90
            )
        )

        XCTAssertEqual(assessment.status, .unrealistic)
        XCTAssertTrue(assessment.signals.contains(.noOpenWindow))
        XCTAssertTrue(assessment.signals.contains(.hardDeadline))
        XCTAssertTrue(assessment.signals.contains(.highConsequence))
        XCTAssertTrue(assessment.hasCalendarDerivedEvidence)
        XCTAssertEqual(assessment.privacy, .calendarDerived)
    }

    func testPassiveFlexibleGoalCanMoveSlowly() {
        let piano = makeGoal(id: "goal-piano", title: "Learn piano", mode: .learning, domain: .creativity, dueAt: nil, state: .paused)

        let assessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: piano,
                generatedAt: now,
                activeContextLens: .freeTime
            )
        )

        XCTAssertEqual(assessment.status, .passive)
        XCTAssertEqual(assessment.posture, .passive)
        XCTAssertTrue(assessment.signals.contains(.passiveFlexible))
        XCTAssertTrue(assessment.reasons.contains { $0.summary == "This can move slowly because it is passive and flexible." })
    }

    func testHighConsequenceCribOutranksPassivePianoWithoutScheduling() {
        let dueSoon = iso(hours: 36)
        let crib = makeGoal(id: "goal-crib", title: "Build the baby crib before the due date", mode: .project, domain: .home, dueAt: dueSoon)
        let piano = makeGoal(id: "goal-piano", title: "Learn piano", mode: .learning, domain: .creativity, dueAt: nil, state: .paused)
        let snapshot = reality(openMinutes: 180, busyRanges: [(180, 300)], calendar: false, lens: .freeTime)

        let cribAssessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: crib,
                generatedAt: now,
                activeContextLens: .freeTime,
                realitySnapshot: snapshot,
                effortMinutes: 120,
                consequence: .high,
                importance: .high
            )
        )
        let pianoAssessment = projector.assess(
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

        XCTAssertTrue(rank(cribAssessment.priorityReality.overallPressure) > rank(pianoAssessment.priorityReality.overallPressure))
        XCTAssertTrue(cribAssessment.signals.contains(.hardDeadline))
        XCTAssertTrue(cribAssessment.signals.contains(.highConsequence))
        XCTAssertEqual(pianoAssessment.status, .passive)
        XCTAssertNil(cribAssessment.recommendations.first?.summary.range(of: "scheduled"))
    }

    func testCapturePlanSeedAndDeliverableSeedCanBeAssessed() {
        let planSeed = Capture(
            id: "capture-plan",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Draft launch checklist",
            sourceType: .todayQuickCapture,
            status: .scheduled,
            linkedGoalID: nil,
            kind: .oneTimeCommitment,
            route: .planSeed,
            triageStatus: .routed,
            commitmentKind: .oneTime,
            deadlineText: "Friday",
            deadlineKind: .hard,
            contextLensHint: .work,
            priorityHints: CapturePriorityHints(importance: .moderate, urgency: .moderate, deadline: .high)
        )
        let deliverable = Capture(
            id: "capture-song",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Add another song to the album",
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

        let planAssessment = projector.assess(
            GoalBelievabilityInput(subjectKind: .planSeed, capture: planSeed, planID: "plan-1", generatedAt: now, activeContextLens: .work)
        )
        let deliverableAssessment = projector.assess(
            GoalBelievabilityInput(subjectKind: .deliverableSeed, capture: deliverable, generatedAt: now, activeContextLens: .creative)
        )

        XCTAssertEqual(planAssessment.subjectKind, .planSeed)
        XCTAssertEqual(planAssessment.planID, "plan-1")
        XCTAssertEqual(planAssessment.captureID, "capture-plan")
        XCTAssertTrue(deliverableAssessment.signals.contains(.deliverableAdded))
        XCTAssertEqual(deliverableAssessment.goalID, "goal-album")
    }

    func testWaitingOptionalContextMismatchAndCalendarConflictSignals() {
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
            contextLensHint: .work,
            waitingMetadata: CaptureWaitingMetadata(waitingOn: "Kaylee")
        )
        let optional = Capture(
            id: "capture-optional",
            createdAt: DomainTimestamp.string(from: now),
            updatedAt: DomainTimestamp.string(from: now),
            rawText: "Maybe learn watercolor someday",
            sourceType: .todayQuickCapture,
            status: .optionalSomeday,
            linkedGoalID: nil,
            kind: .optionalSomeday,
            route: .optionalSomeday,
            triageStatus: .routed,
            priorityHints: CapturePriorityHints(optionalSomeday: true, passive: true)
        )
        let workGoal = makeGoal(id: "goal-work", title: "Work report", mode: .project, domain: .career, dueAt: iso(hours: 12))
        let snapshot = reality(openMinutes: 120, busyRanges: [(30, 90), (60, 120)], calendar: true, lens: .personal)

        let waitingAssessment = projector.assess(GoalBelievabilityInput(subjectKind: .captureCommitment, capture: waiting, generatedAt: now))
        let optionalAssessment = projector.assess(GoalBelievabilityInput(subjectKind: .captureCommitment, capture: optional, generatedAt: now))
        let mismatchAssessment = projector.assess(
            GoalBelievabilityInput(subjectKind: .goal, goal: workGoal, generatedAt: now, activeContextLens: .personal, realitySnapshot: snapshot, effortMinutes: 30)
        )

        XCTAssertEqual(waitingAssessment.status, .waiting)
        XCTAssertTrue(waitingAssessment.signals.contains(.blockedByWaiting))
        XCTAssertEqual(optionalAssessment.status, .optionalSomeday)
        XCTAssertTrue(mismatchAssessment.signals.contains(.contextMismatch))
        XCTAssertTrue(mismatchAssessment.signals.contains(.calendarDerivedConflict))
        XCTAssertTrue(mismatchAssessment.hasCalendarDerivedEvidence)
    }

    func testExplanationGenerationReferencesAssessmentLedgerAndRealityWithoutWritingLedger() {
        let ledgerEntry = EventLedgerEntry(
            id: "ledger-priority",
            kind: .priorityChanged,
            occurredAt: DomainTimestamp.string(from: now),
            source: .recommendation,
            goalID: "goal-1",
            title: "Priority changed"
        )
        let goal = makeGoal(id: "goal-1", title: "Finish brief", mode: .project, domain: .career, dueAt: iso(hours: 24))
        let assessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: reality(openMinutes: 90, busyRanges: [], calendar: false, lens: .work),
                eventLedgerEntries: [ledgerEntry],
                effortMinutes: 60,
                consequence: .high,
                importance: .high
            )
        )

        let explanation = projector.makeExplanation(for: assessment, type: .whyBelievable)

        XCTAssertEqual(explanation.type, .whyBelievable)
        XCTAssertTrue(explanation.referencesEventLedger)
        XCTAssertEqual(explanation.relations.eventLedgerEntryIDs, ["ledger-priority"])
        XCTAssertTrue(explanation.containsPriorityRealityEvidence)
        XCTAssertTrue(explanation.containsDeadlineEvidence)
        XCTAssertFalse(assessment.eventLedgerEntryIDs.contains { $0.hasPrefix("ledger.believability") })
    }

    func testNowAndCommandAdaptersAreSideEffectFree() {
        let goal = makeGoal(id: "goal-risk", title: "Finish high stakes item", mode: .project, domain: .career, dueAt: iso(hours: 4))
        let assessment = projector.assess(
            GoalBelievabilityInput(
                subjectKind: .goal,
                goal: goal,
                generatedAt: now,
                activeContextLens: .work,
                realitySnapshot: reality(openMinutes: 0, busyRanges: [(0, 240)], calendar: false, lens: .work),
                effortMinutes: 120,
                consequence: .high,
                importance: .high
            )
        )

        let nowSummary = projector.nowGoalPressureSummary(from: assessment)
        let commandMetadata = projector.commandNeedsConfirmationMetadata(from: assessment)

        XCTAssertEqual(nowSummary?.goalID, "goal-risk")
        XCTAssertEqual(commandMetadata["needsConfirmation"], "true")
        XCTAssertEqual(commandMetadata["believabilityStatus"], assessment.status.rawValue)
    }

    func testAssessmentOrderingIsDeterministic() {
        let goal = makeGoal(id: "goal-deterministic", title: "Deterministic output", mode: .project, domain: .career, dueAt: iso(hours: 24))
        let input = GoalBelievabilityInput(
            subjectKind: .goal,
            goal: goal,
            generatedAt: now,
            activeContextLens: .work,
            realitySnapshot: reality(openMinutes: 120, busyRanges: [], calendar: false, lens: .work),
            eventLedgerEntries: [
                EventLedgerEntry(id: "ledger-b", kind: .deadlineChanged, occurredAt: DomainTimestamp.string(from: now), source: .goals, title: "B"),
                EventLedgerEntry(id: "ledger-a", kind: .priorityChanged, occurredAt: DomainTimestamp.string(from: now), source: .goals, title: "A")
            ],
            effortMinutes: 60,
            consequence: .moderate,
            importance: .high
        )

        let first = projector.assess(input)
        let second = projector.assess(input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.eventLedgerEntryIDs, ["ledger-a", "ledger-b"])
        XCTAssertEqual(first.reasons.map(\.id), first.reasons.map(\.id).sorted())
    }
}

private extension GoalBelievabilityProjectorTests {
    var projector: GoalBelievabilityProjector { GoalBelievabilityProjector() }
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
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(TimeInterval(max(openMinutes, 240) * 60)))
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
        case .none: return 0
        case .low: return 1
        case .moderate: return 2
        case .elevated: return 3
        case .high: return 4
        case .critical: return 5
        }
    }
}
